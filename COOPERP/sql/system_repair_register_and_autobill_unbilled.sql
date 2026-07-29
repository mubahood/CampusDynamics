-- ============================================================================
-- SYSTEM REPAIR: Register + Auto-Bill unbilled semester registrations
-- ----------------------------------------------------------------------------
-- Purpose
--   1) Find real students in acad_registration (latest row per regno/year/semester)
--      who are not billed yet in fin_studentfeestracking (trans_type='Bill').
--   2) Set their status to REGISTERED through system-side UPDATE logic.
--   3) Trigger billing through the system procedure fin_AutoBillOnRegistration
--      (NO manual fee/ledger inserts in this script).
--
-- Safety
--   - Uses live relational checks across campus_dynamics + campus_dynamics_accounts.
--   - Excludes staff identity rows (hrm_employee) and non-student rows.
--   - Excludes discontinued/halted/dead-year rows.
--   - Supports recent-window repair using p_min_reg_id.
--   - Produces per-student execution log and summary counts.
--
-- Tested for MySQL 5.6 style syntax.
-- ============================================================================

DROP PROCEDURE IF EXISTS campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled;

DELIMITER $$

CREATE PROCEDURE campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled(
    IN p_acadyear   VARCHAR(15),
    IN p_semester   INT,
    IN p_min_reg_id INT,
    IN p_actor      VARCHAR(45)
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id INT;
    DECLARE v_regno CHAR(35);

    DECLARE v_old_status CHAR(25);
    DECLARE v_old_newreg CHAR(10);
    DECLARE v_before_bills INT DEFAULT 0;
    DECLARE v_after_bills INT DEFAULT 0;

    DECLARE v_failed INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT c.ID, c.regno
        FROM tmp_repair_candidates c
        ORDER BY c.ID DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    IF p_semester NOT IN (1,2,3) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid semester. Expected 1,2,3.';
    END IF;

    IF p_acadyear IS NULL OR TRIM(p_acadyear) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Academic year is required.';
    END IF;

    IF p_actor IS NULL OR TRIM(p_actor) = '' THEN
        SET p_actor = 'SYSTEM-REPAIR';
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_repair_candidates;
    CREATE TEMPORARY TABLE tmp_repair_candidates (
        ID INT NOT NULL,
        regno CHAR(35) NOT NULL,
        acad_year VARCHAR(15) NOT NULL,
        semester INT NOT NULL,
        studyyear INT NULL,
        regstatus CHAR(25) NULL,
        conducted_new_registration CHAR(10) NULL,
        PRIMARY KEY (ID),
        KEY idx_tmp_rep_regno (regno)
    ) ENGINE=Memory;

    DROP TEMPORARY TABLE IF EXISTS tmp_repair_result;
    CREATE TEMPORARY TABLE tmp_repair_result (
        reg_id INT NOT NULL,
        regno CHAR(35) NOT NULL,
        old_status CHAR(25) NULL,
        old_conducted_new_registration CHAR(10) NULL,
        before_bill_count INT NOT NULL DEFAULT 0,
        after_bill_count INT NOT NULL DEFAULT 0,
        action_status VARCHAR(20) NOT NULL,
        action_note VARCHAR(120) NULL,
        processed_at DATETIME NOT NULL,
        KEY idx_tmp_rep_res_regno (regno)
    ) ENGINE=Memory;

    INSERT INTO tmp_repair_candidates (ID, regno, acad_year, semester, studyyear, regstatus, conducted_new_registration)
    SELECT
        r.ID,
        r.regno,
        r.acad_year,
        r.semester,
        r.studyyear,
        r.regstatus,
        IFNULL(r.conducted_new_registration, 'No')
    FROM campus_dynamics.acad_registration r
    INNER JOIN (
        SELECT regno, acad_year, semester, MAX(ID) AS max_id
        FROM campus_dynamics.acad_registration
        WHERE acad_year = p_acadyear
          AND semester = p_semester
          AND (p_min_reg_id IS NULL OR p_min_reg_id <= 0 OR ID >= p_min_reg_id)
        GROUP BY regno, acad_year, semester
    ) x ON x.max_id = r.ID
    INNER JOIN campus_dynamics.acad_student s
        ON TRIM(s.regno) = TRIM(r.regno)
    LEFT JOIN campus_dynamics.hrm_employee e
        ON LOWER(TRIM(e.EMP_CODE)) = LOWER(TRIM(r.regno))
        OR LOWER(TRIM(e.usernames)) = LOWER(TRIM(r.regno))
    WHERE e.EMP_CODE IS NULL
      AND NOT EXISTS (
          SELECT 1
          FROM campus_dynamics_accounts.fin_studentfeestracking ft
          WHERE TRIM(ft.regno) = TRIM(r.regno)
            AND ft.acadyear = r.acad_year
            AND ft.semester = r.semester
            AND UPPER(TRIM(ft.trans_type)) = 'BILL'
          LIMIT 1
      )
      AND UPPER(TRIM(IFNULL(r.regstatus,''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR');

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_id, v_regno;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_failed = 0;

        SELECT IFNULL(TRIM(regstatus), ''), IFNULL(conducted_new_registration, 'No')
        INTO v_old_status, v_old_newreg
        FROM campus_dynamics.acad_registration
        WHERE ID = v_id
        LIMIT 1;

        SELECT COUNT(*) INTO v_before_bills
        FROM campus_dynamics_accounts.fin_studentfeestracking ft
        WHERE TRIM(ft.regno) = TRIM(v_regno)
          AND ft.acadyear = p_acadyear
          AND ft.semester = p_semester
          AND UPPER(TRIM(ft.trans_type)) = 'BILL';

        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_failed = 1;

            -- Update ALL rows for this (regno, year, semester) so that
            -- fin_AutoBillOnRegistration (which uses LIMIT 1 without ORDER BY)
            -- is guaranteed to read REGISTERED status regardless of which row it picks.
            UPDATE campus_dynamics.acad_registration
            SET regstatus = 'REGISTERED',
                conducted_new_registration = 'Yes',
                examClearance = CASE
                    WHEN IFNULL(TRIM(examClearance), '') = '' THEN 'UNCLEARED'
                    ELSE examClearance
                END,
                registeredBy = CASE
                    WHEN IFNULL(TRIM(registeredBy), '') = '' THEN p_actor
                    ELSE registeredBy
                END
            WHERE regno = v_regno
              AND acad_year = p_acadyear
              AND semester = p_semester
              AND UPPER(TRIM(IFNULL(regstatus, ''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR','DE-REGISTERED');

            CALL campus_dynamics_accounts.fin_AutoBillOnRegistration(v_regno, p_acadyear, p_semester, p_actor);
        END;

        SELECT COUNT(*) INTO v_after_bills
        FROM campus_dynamics_accounts.fin_studentfeestracking ft
        WHERE TRIM(ft.regno) = TRIM(v_regno)
          AND ft.acadyear = p_acadyear
          AND ft.semester = p_semester
          AND UPPER(TRIM(ft.trans_type)) = 'BILL';

        INSERT INTO tmp_repair_result
        (
            reg_id, regno,
            old_status, old_conducted_new_registration,
            before_bill_count, after_bill_count,
            action_status, action_note, processed_at
        )
        VALUES
        (
            v_id, v_regno,
            v_old_status, v_old_newreg,
            IFNULL(v_before_bills, 0), IFNULL(v_after_bills, 0),
            CASE
                WHEN v_failed = 1 THEN 'FAILED'
                WHEN IFNULL(v_after_bills,0) > IFNULL(v_before_bills,0) THEN 'BILLED'
                WHEN IFNULL(v_after_bills,0) > 0 THEN 'ALREADY_BILLED'
                ELSE 'NO_BILL_CREATED'
            END,
            CASE
                WHEN v_failed = 1 THEN 'Procedure error while processing row'
                WHEN IFNULL(v_after_bills,0) > IFNULL(v_before_bills,0) THEN 'Billing triggered successfully'
                WHEN IFNULL(v_after_bills,0) > 0 THEN 'Bill already existed after status sync'
                ELSE 'No bill row present after system trigger'
            END,
            NOW()
        );

    END LOOP;

    CLOSE cur;

    -- Pre-compute all counts into variables to avoid MySQL 5.6 "Can't reopen table" on temp tables
    BEGIN
        DECLARE v_cand_count   INT DEFAULT 0;
        DECLARE v_billed_now   INT DEFAULT 0;
        DECLARE v_alr_billed   INT DEFAULT 0;
        DECLARE v_no_bill      INT DEFAULT 0;
        DECLARE v_failed_cnt   INT DEFAULT 0;

        SELECT COUNT(*) INTO v_cand_count FROM tmp_repair_candidates;

        SELECT
            SUM(CASE WHEN action_status = 'BILLED'        THEN 1 ELSE 0 END),
            SUM(CASE WHEN action_status = 'ALREADY_BILLED' THEN 1 ELSE 0 END),
            SUM(CASE WHEN action_status = 'NO_BILL_CREATED' THEN 1 ELSE 0 END),
            SUM(CASE WHEN action_status = 'FAILED'         THEN 1 ELSE 0 END)
        INTO v_billed_now, v_alr_billed, v_no_bill, v_failed_cnt
        FROM tmp_repair_result;

        SELECT
            'SUMMARY'          AS section,
            p_acadyear         AS acad_year,
            p_semester         AS semester,
            v_cand_count       AS candidate_count,
            IFNULL(v_billed_now,  0) AS billed_now,
            IFNULL(v_alr_billed,  0) AS already_billed,
            IFNULL(v_no_bill,     0) AS no_bill_created,
            IFNULL(v_failed_cnt,  0) AS failed_rows;
    END;

    SELECT *
    FROM tmp_repair_result
    ORDER BY reg_id DESC;

END$$

DELIMITER ;

-- ============================================================================
-- HOW TO RUN (EXAMPLE)
-- ----------------------------------------------------------------------------
-- 1) PREVIEW candidate volume only (safe read-only):
--    SELECT COUNT(*)
--    FROM campus_dynamics.acad_registration r
--    WHERE r.acad_year='2025/2026' AND r.semester=2
--      AND NOT EXISTS (
--        SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking ft
--        WHERE ft.regno=r.regno AND ft.acadyear=r.acad_year AND ft.semester=r.semester
--          AND UPPER(TRIM(ft.trans_type))='BILL' LIMIT 1
--      );
--
-- 2) Execute system repair for recent rows (example min ID = 53668):
--    CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled(
--         '2025/2026',
--         2,
--         53668,
--         'SYSTEM-REPAIR'
--    );
--
-- 3) Execute for semester 1 / 3 as needed:
--    CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026',1,53668,'SYSTEM-REPAIR');
--    CALL campus_dynamics.sp_SystemRepair_RegisterAndAutoBill_Unbilled('2025/2026',3,53668,'SYSTEM-REPAIR');
-- ============================================================================
