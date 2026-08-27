-- ============================================================================
--  Stop automatic billing of historic semesters
--  Muteesa I Royal University                                     2026-08-27
--
--  THE FAULT
--  ---------
--  Students registering a HISTORIC semester through the eportal wizard were
--  having that semester billed at today's fee structure. MRU2023000619 raised
--  it: on 26 Aug 2026 she was billed UGX 1,720,250 for Semester 2 of 2023/2024,
--  a semester that ended two years ago.
--
--  The trigger is the student's own action. acad_StudentRegistration (and
--  fin_AutoBillOnRegistration) bill whatever period is being registered, with
--  no lower bound, so back-filling an old registration raises a live invoice.
--  It is visible in the ledger: the `teller` on these rows is the STUDENT'S OWN
--  regno, because the procedures pass the signed-in user through as the biller.
--
--  Since 1 July 2026 this produced 259 bills against 130 students totalling
--  UGX 344,944,500, reaching as far back as 2019/2020.
--
--  THE GUARD
--  ---------
--  The floor goes in fin_Autobilling itself, because that is the one procedure
--  through which every automatic path actually raises a fee:
--
--      acad_StudentRegistration ─┐
--      fin_AutoBillOnRegistration┼─> fin_Autobilling ─> fin_TermlyItemBillingFN
--      BillUnbilledStudents ─────┤
--      fin_CorrectionBilling ────┘
--
--  Guarding the callers instead would leave every future caller free to
--  reintroduce the fault. Guarding here cannot be bypassed.
--
--  Deliberate back-billing is still possible: a caller that passes
--  csid = 'BACKFILL' is exempt. No automatic path uses that value, so it can
--  only be reached by someone who meant it. fin_CorrectionBilling — whose whole
--  purpose is to delete and re-raise one chosen semester — is updated to pass
--  it, so finance staff can still correct a historic bill on purpose.
--
--  The floor is a row in fin_billing_policy, not a literal, so finance can move
--  it each year without a code change.
--
--  Safe to re-run.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. The policy table.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_billing_policy (
    policy_key   VARCHAR(50)  NOT NULL PRIMARY KEY,
    policy_value VARCHAR(50)  NOT NULL,
    description  VARCHAR(255) NULL,
    updated_by   VARCHAR(100) NULL,
    updated_at   DATETIME     NULL
) ENGINE=InnoDB;

INSERT INTO campus_dynamics_accounts.fin_billing_policy
       (policy_key, policy_value, description, updated_by, updated_at)
VALUES ('min_auto_bill_acad_year', '2026/2027',
        'Automatic billing will not raise fees for any academic year below this. Callers passing csid=''BACKFILL'' are exempt (deliberate correction). Raise this each year once the new year opens.',
        'system', NOW())
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- ---------------------------------------------------------------------------
-- 1b. Where blocked attempts are recorded.
--     Without this, the floor would be silent and nobody would know how often
--     it fires or which students are trying to register historic semesters —
--     which is itself the thing worth watching.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_billing_floor_log (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    regno        VARCHAR(35)  NULL,
    acadyear     VARCHAR(15)  NULL,
    semester     INT          NULL,
    bill_type    VARCHAR(25)  NULL,
    attempted_by VARCHAR(45)  NULL,
    csid         VARCHAR(25)  NULL,
    floor_value  VARCHAR(15)  NULL,
    blocked_at   DATETIME     NULL,
    KEY ix_when (blocked_at),
    KEY ix_regno (regno)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 2. fin_Autobilling, with the floor.
--    Body is otherwise byte-for-byte the original (backed up alongside this
--    file as fin_Autobilling_ORIGINAL_20260827.sql); the only additions are the
--    two DECLAREs, the labelled block and the LEAVE.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS campus_dynamics_accounts.fin_Autobilling;

DELIMITER $$
CREATE PROCEDURE campus_dynamics_accounts.fin_Autobilling(
    IN reg  CHAR(35),
    IN acad CHAR(15),
    IN sems INT(11),
    IN typ  CHAR(25),
    IN usr  CHAR(45),
    IN csid CHAR(25))
BEGIN
    DECLARE noItems,yr,cyr,noBilled,ItemID,bid INT;
    DECLARE prog,sess,regStat,resStat,Intk,rep CHAR(25);
    DECLARE done INT DEFAULT 0;
    DECLARE v_has_pf INT DEFAULT 0;
    DECLARE v_floor  VARCHAR(15) DEFAULT '2026/2027';

    autobill: BEGIN

        -- ── FLOOR ────────────────────────────────────────────────────────────
        -- Refuse to raise fees for a semester older than the policy floor.
        -- Academic years are 'YYYY/YYYY', so a plain string comparison orders
        -- them correctly. csid='BACKFILL' marks a deliberate correction and is
        -- exempt. Leaving quietly (rather than signalling) is intentional: this
        -- runs inside student-facing registration, and a hard error there would
        -- block the registration itself over a fee that should not be raised.
        SELECT policy_value INTO v_floor
          FROM campus_dynamics_accounts.fin_billing_policy
         WHERE policy_key = 'min_auto_bill_acad_year' LIMIT 1;

        IF v_floor IS NOT NULL AND v_floor <> ''
           AND IFNULL(acad,'') <> '' AND acad < v_floor
           AND IFNULL(csid,'') <> 'BACKFILL' THEN

            INSERT INTO campus_dynamics_accounts.fin_billing_floor_log
                   (regno, acadyear, semester, bill_type, attempted_by, csid, floor_value, blocked_at)
            VALUES (reg, acad, sems, typ, usr, csid, v_floor, NOW());

            LEAVE autobill;
        END IF;
        -- ─────────────────────────────────────────────────────────────────────

        SELECT progid,studsesion,intake,billingID,entryyear
        INTO prog,sess,Intk,bid,yr
        FROM campus_dynamics.acad_student WHERE regno=reg LIMIT 1;

        SELECT regstatus,studyyear,residence_status
        INTO regStat,cyr,resStat
        FROM campus_dynamics.acad_registration sr
        WHERE regno=reg AND acad_year=acad AND semester=sems LIMIT 1;

        SELECT COUNT(*) INTO v_has_pf
        FROM fin_programme_fees
        WHERE progcode=prog AND is_active='Yes';

        IF typ='REG' THEN
            IF regStat IN ('REGISTERED','LATE REGISTERED') THEN
                IF v_has_pf > 0 THEN
                    CALL fin_BillProgrammeFees(reg,prog,sess,cyr,sems,acad,usr,csid);
                    IF sess != 'Remote Learning' THEN
                        SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemID,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                        FROM fin_fees_pay_schedule fs
                        WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND stud_session=sess AND semester=sems AND fs.ItemID NOT IN (1,52);
                    ELSE
                        SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                        FROM fin_fees_structure fs,academicbillingitems bi
                        WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND studsession=sess AND semester=sems
                        AND bi.ItemCode=fs.ItemCode AND fs.ItemCode NOT IN (1,52) AND itemname NOT LIKE '%Tuition%';
                    END IF;
                ELSE
                    IF sess != 'Remote Learning' THEN
                        SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemID,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                        FROM fin_fees_pay_schedule fs
                        WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND stud_session=sess AND semester=sems;
                    ELSE
                        SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                        FROM fin_fees_structure fs,academicbillingitems bi
                        WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND studsession=sess AND semester=sems
                        AND bi.ItemCode=fs.ItemCode AND itemname NOT LIKE '%Tuition%';
                    END IF;
                END IF;
                IF regStat LIKE '%LATE%' THEN
                    SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,SUM(amount)) INTO rep
                    FROM fin_fees_structure fs,academicbillingitems bi
                    WHERE progid=prog AND curr_year=yr AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid AND ItemName LIKE '%Late Reg%' LIMIT 1;
                END IF;
            ELSEIF regStat='DEAD YEAR' THEN
                SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,SUM(amount)) INTO rep
                FROM fin_fees_structure fs,academicbillingitems bi
                WHERE progid=prog AND curr_year=yr AND study_year=cyr AND semester=sems AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid AND ItemName LIKE '%Dead Year%' LIMIT 1;
            END IF;
        ELSEIF typ IN ('RT','RR','SPECIAL','SUPPLEMENTARY') THEN
            SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,SUM(amount)) INTO rep
            FROM fin_fees_structure fs,academicbillingitems bi
            WHERE progid=prog AND curr_year=yr AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid AND ItemName LIKE CONCAT('%',typ,'%') LIMIT 1;
        ELSEIF typ='ACCOMO' AND resStat='RESIDENT' THEN
            SELECT fin_TermlyItemBillingFN('Bill',reg,bi.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,price) INTO rep
            FROM campus_dynamics.acad_residence r,campus_dynamics.acad_halls h,academicbillingitems bi
            WHERE semester=sems AND acadyear=acad AND regno=reg AND h.ID=r.hall_id AND ItemName LIKE '%Accomoda%' LIMIT 1;
        END IF;

    END autobill;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 3. Let deliberate correction billing through.
--    fin_CorrectionBilling deletes a chosen semester's bills and re-raises
--    them; an admin has already picked the semester, so it is exempt.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS campus_dynamics_accounts.fin_CorrectionBilling;

DELIMITER $$
CREATE PROCEDURE campus_dynamics_accounts.fin_CorrectionBilling(
    IN regn CHAR(35),
    IN acad CHAR(15),
    IN sems INT(11),
    IN typ  CHAR(25),
    IN usr  CHAR(45),
    IN res  CHAR(25))
BEGIN
    DELETE FROM fin_ledger WHERE folio IN (SELECT CONCAT('BillNo:',TID) FROM fin_studentfeestracking
    WHERE regno=regn AND semester=sems AND acadyear=acad AND trans_type='Bill');

    DELETE FROM fin_studentfeestracking WHERE regno=regn AND semester=sems AND acadyear=acad AND trans_type='Bill';

    CALL fin_autobilling(regn,acad,sems,typ,usr,'BACKFILL');

    IF res='RESIDENT' THEN
        CALL fin_autobilling(regn,acad,sems,'ACCOMO',usr,'BACKFILL');
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 4. Verification.
-- ---------------------------------------------------------------------------
SELECT '--- floor in force ---' AS check_1;
SELECT policy_key, policy_value FROM campus_dynamics_accounts.fin_billing_policy;

SELECT '--- both procedures recreated (expect 2) ---' AS check_2;
SELECT COUNT(*) AS procedures_present FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA='campus_dynamics_accounts'
   AND ROUTINE_NAME IN ('fin_Autobilling','fin_CorrectionBilling');
