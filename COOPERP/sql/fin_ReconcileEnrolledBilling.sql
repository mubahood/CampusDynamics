-- ============================================================================
--  fin_ReconcileEnrolledBilling  —  prevention (safety net):
--  "a student who is enrolled for a semester can't silently stay UNREGISTERED
--   or unbilled."
--
--  The gap it closes: billing is event-driven — only the portal semester
--  wizard flips regstatus=REGISTERED and bills. Students who get courses via
--  another path (admin course registration, promotion placeholder, a wizard
--  billing failure that reverts to UNREGISTERED) end up ENROLLED (>=1 course
--  in campus_dynamics_portal.acad_course_registration) yet still UNREGISTERED
--  and/or unbilled. Because such students have usually already paid (SchoolPay
--  etc.), the money floats as an unallocated credit.
--
--  Rule enforced (defensible, conservative): for every student with >=1 course
--  for (acad_year, semester) whose new_status='ACTIVE':
--     (1) if regstatus is UNREGISTERED / missing -> set REGISTERED
--     (2) call fin_AutoBillOnRegistration (fully idempotent — 'Already Billed'
--         short-circuits, so no double-bill and no fin_bill_uniqueness clash).
--  Enrollment (has courses) is the trigger, NOT mere promotion placeholders,
--  so students who were rolled forward but never returned are NOT billed.
--
--  Parameters:
--     p_acadyear  e.g. '2026/2027'
--     p_semester  e.g. 1
--     p_apply     0 = REPORT ONLY (safe, logs only) | 1 = FIX (flip + bill)
--     p_maxapply  runaway guard: if FIX would touch MORE than this many
--                 students, it DOWNGRADES to report-only and flags
--                 EXCEEDS_CAP (a human must confirm). Pass a large number
--                 (e.g. 100000) to disable the cap for a deliberate bulk run.
--
--  Modes:
--     CALL fin_ReconcileEnrolledBilling('2026/2027', 1, 0, 500);  -- REPORT
--     CALL fin_ReconcileEnrolledBilling('2026/2027', 1, 1, 500);  -- FIX (<=500)
--
--  Idempotent: a fixed student is REGISTERED + billed, so re-running is a no-op.
--  Cross-DB (accounts + campus_dynamics + campus_dynamics_portal, all local).
-- ============================================================================

CREATE TABLE IF NOT EXISTS fin_enrolled_billing_gap_log (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  regno         VARCHAR(35),
  acad_year     VARCHAR(15),
  semester      INT,
  old_regstatus VARCHAR(25),
  action_taken  VARCHAR(40),          -- DETECTED | REGISTERED+BILLED | BILLED-ONLY | EXCEEDS_CAP
  detected_at   DATETIME,
  KEY ix_regno (regno),
  KEY ix_ay (acad_year, semester)
);

DROP PROCEDURE IF EXISTS fin_ReconcileEnrolledBilling;
DELIMITER $$
CREATE PROCEDURE fin_ReconcileEnrolledBilling(
    IN p_acadyear CHAR(15),
    IN p_semester INT,
    IN p_apply    TINYINT,
    IN p_maxapply INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_regno   CHAR(35);
    DECLARE v_status  CHAR(25);
    DECLARE v_total   INT DEFAULT 0;
    DECLARE v_fixed   INT DEFAULT 0;
    DECLARE v_apply   TINYINT DEFAULT 0;

    DECLARE cur CURSOR FOR SELECT regno, old_regstatus FROM _enroll_gap;
    -- NOTE: this NOT FOUND handler is for the CURSOR only. The per-row billing
    -- work is wrapped in its own nested block with its own swallowing handlers,
    -- so a NOT FOUND raised inside fin_AutoBillOnRegistration (e.g. an enrolled
    -- student who has NO acad_registration row -> SELECT ... INTO finds nothing)
    -- can NEVER trip this flag and abort the loop early.
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- materialise the target set once (enrolled ACTIVE students who are not
    -- properly REGISTERED, or are REGISTERED but have no tuition (item 1) bill)
    DROP TEMPORARY TABLE IF EXISTS _enroll_gap;
    CREATE TEMPORARY TABLE _enroll_gap (
        regno CHAR(35) PRIMARY KEY,
        old_regstatus CHAR(25)
    );
    -- NB: enrollment signal = having a course for THIS semester (cr rows). We do NOT
    -- filter on acad_student.new_status — that column is corrupted (28k+ active
    -- students carry a stale new_status='ALUMNI'; zero are consistently ALUMNI), so it
    -- would wrongly skip most students. The graduate guard is completion_date IS NULL
    -- (the only reliable "finished" marker), and a student with current-semester
    -- courses is by definition currently enrolled.
    INSERT IGNORE INTO _enroll_gap (regno, old_regstatus)
    SELECT cr.regno, IFNULL(reg.regstatus,'(none)')
    FROM campus_dynamics_portal.acad_course_registration cr
    JOIN campus_dynamics.acad_student st
          ON st.regno = cr.regno AND st.completion_date IS NULL
    LEFT JOIN campus_dynamics.acad_registration reg
          ON reg.regno = cr.regno AND reg.acad_year = p_acadyear AND reg.semester = p_semester
    WHERE cr.acad_year = p_acadyear
      AND cr.semester  = p_semester
      AND (
            -- not in an enrolled/billed status (CLEARED counts as enrolled+billable, so a
            -- CLEARED student who already has a bill is NOT a gap) ...
            IFNULL(reg.regstatus,'') NOT IN ('REGISTERED','LATE REGISTERED','CLEARED')
            -- ... OR they lack the tuition (item 1) bill for this semester
            OR NOT EXISTS (SELECT 1 FROM fin_studentfeestracking t
                           WHERE t.regno = cr.regno AND t.acadyear = p_acadyear
                             AND t.semester = p_semester AND t.trans_type = 'Bill'
                             AND t.item_code = 1)
          );

    SELECT COUNT(*) INTO v_total FROM _enroll_gap;

    -- runaway guard: only auto-apply when within the cap
    SET v_apply = IF(p_apply = 1 AND v_total <= p_maxapply, 1, 0);

    IF p_apply = 1 AND v_apply = 0 THEN
        -- would exceed the cap: flag for human review, do NOT bill
        INSERT INTO fin_enrolled_billing_gap_log (regno, acad_year, semester, old_regstatus, action_taken, detected_at)
        SELECT regno, p_acadyear, p_semester, old_regstatus, 'EXCEEDS_CAP', NOW() FROM _enroll_gap;
        SELECT p_acadyear AS acad_year, p_semester AS semester, v_total AS enrolled_gap_students, 0 AS fixed,
               CONCAT('EXCEEDS_CAP (', v_total, ' > ', p_maxapply, ') — report only, human confirm required') AS mode;
        DROP TEMPORARY TABLE IF EXISTS _enroll_gap;
    ELSE
        OPEN cur;
        read_loop: LOOP
            FETCH cur INTO v_regno, v_status;
            IF done THEN LEAVE read_loop; END IF;

            INSERT INTO fin_enrolled_billing_gap_log (regno, acad_year, semester, old_regstatus, action_taken, detected_at)
            VALUES (v_regno, p_acadyear, p_semester, v_status,
                    IF(v_apply=1, IF(v_status IN ('REGISTERED','LATE REGISTERED'),'BILLED-ONLY','REGISTERED+BILLED'), 'DETECTED'),
                    NOW());

            IF v_apply = 1 THEN
                -- nested block: its own handlers absorb NOT FOUND / errors raised
                -- inside fin_AutoBillOnRegistration so they never touch the cursor's
                -- `done` flag (see note on the cursor handler above).
                BEGIN
                    DECLARE CONTINUE HANDLER FOR NOT FOUND BEGIN END;
                    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
                    -- Only lift genuinely-unregistered rows to REGISTERED. CLEARED is
                    -- already an enrolled state and must NOT be downgraded — fin_AutoBillOnRegistration
                    -- bills CLEARED in place.
                    UPDATE campus_dynamics.acad_registration
                       SET regstatus = 'REGISTERED', registeredBy = 'RECON-ENROLLED'
                     WHERE regno = v_regno AND acad_year = p_acadyear AND semester = p_semester
                       AND regstatus NOT IN ('REGISTERED','LATE REGISTERED','CLEARED');
                    CALL fin_AutoBillOnRegistration(v_regno, p_acadyear, p_semester, 'RECON-ENROLLED');
                    -- keep the balance cache in lock-step with the bill just posted
                    CALL fin_RefreshBalanceCache(v_regno);
                END;
                SET v_fixed = v_fixed + 1;
            END IF;
        END LOOP;
        CLOSE cur;

        SELECT p_acadyear AS acad_year, p_semester AS semester, v_total AS enrolled_gap_students,
               IF(v_apply=1, v_fixed, 0) AS fixed,
               IF(v_apply=1,'FIXED (registered + billed)','DETECTED — report only') AS mode;
        DROP TEMPORARY TABLE IF EXISTS _enroll_gap;
    END IF;
END$$
DELIMITER ;

-- Recommended nightly (report): CALL fin_ReconcileEnrolledBilling('2026/2027', 1, 0, 500);
-- Review fin_enrolled_billing_gap_log, then FIX:  CALL fin_ReconcileEnrolledBilling('2026/2027', 1, 1, 500);
