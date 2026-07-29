-- ============================================================
-- Migration: fin_billing_errors
-- Tracks billing failures that occurred during registration
-- so administrators can identify and fix unbilled students.
-- ============================================================

CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_billing_errors (
    id              INT            NOT NULL AUTO_INCREMENT,
    regno           VARCHAR(50)    NOT NULL,
    acad_year       VARCHAR(20)    NOT NULL,
    semester        TINYINT        NOT NULL,
    triggered_by    VARCHAR(100)   NOT NULL DEFAULT 'SYSTEM',
    trigger_source  VARCHAR(50)    NOT NULL DEFAULT 'AutoBill',
    error_message   TEXT           NULL,
    resolved        TINYINT(1)     NOT NULL DEFAULT 0,
    resolved_at     DATETIME       NULL,
    resolved_by     VARCHAR(100)   NULL,
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_regno   (regno),
    INDEX idx_period  (acad_year, semester),
    INDEX idx_resolved (resolved, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Billing failures during registration — allows admin to find and fix unbilled students';


-- ============================================================
-- Fix fin_Autobilling: remove SET usr=reg that overwrites the
-- caller-supplied username with the student regno.
-- Impact: fin_ledger.teller will now show the actual triggering
-- user (admin username or student regno) instead of always
-- showing the student regno — improves audit accountability.
-- ============================================================

DROP PROCEDURE IF EXISTS fin_Autobilling;

DELIMITER $$

CREATE PROCEDURE fin_Autobilling(
    reg CHAR(35),
    acad CHAR(15),
    sems INT,
    typ CHAR(25),
    usr CHAR(45),
    csid CHAR(25)
)
BEGIN
    DECLARE noItems,yr,cyr,noBilled,ItemID,bid INT;
    DECLARE prog,sess,regStat,resStat,Intk,rep CHAR(25);
    DECLARE done INT DEFAULT 0;
    DECLARE v_has_pf INT DEFAULT 0;

    -- Get student info
    SELECT progid, studsesion, intake, billingID, entryyear
    INTO prog, sess, Intk, bid, yr
    FROM campus_dynamics.acad_student WHERE regno=reg LIMIT 1;

    -- Get registration info
    SELECT regstatus, studyyear, residence_status
    INTO regStat, cyr, resStat
    FROM campus_dynamics.acad_registration sr
    WHERE regno=reg AND acad_year=acad AND semester=sems LIMIT 1;

    -- NOTE: usr is intentionally NOT overridden here.
    -- The caller sets usr to the actual triggering user (admin or student regno).
    -- This preserves the audit trail in fin_ledger.teller.

    -- Check if this programme has an active fee structure in the new table
    SELECT COUNT(*) INTO v_has_pf
    FROM fin_programme_fees
    WHERE progcode=prog AND is_active='Yes';

    IF typ='REG' THEN

        IF regStat IN ('REGISTERED','LATE REGISTERED') THEN

            IF v_has_pf > 0 THEN
                -- NEW PATH: Use programme fees for Tuition + Functional
                CALL fin_BillProgrammeFees(reg, prog, sess, cyr, sems, acad, usr, csid);

                -- Bill remaining non-tuition, non-functional items from pay schedule
                IF sess != 'Remote Learning' THEN
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemID, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_pay_schedule fs
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND stud_session=sess AND semester=sems
                    AND fs.ItemID NOT IN (1, 52);
                ELSE
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_structure fs, academicbillingitems bi
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND studsession=sess AND semester=sems
                    AND bi.ItemCode=fs.ItemCode
                    AND fs.ItemCode NOT IN (1, 52)
                    AND itemname NOT LIKE '%Tuition%';
                END IF;

            ELSE
                -- OLD PATH: No active programme fee structure, use legacy tables
                IF sess != 'Remote Learning' THEN
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemID, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_pay_schedule fs
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND stud_session=sess AND semester=sems;
                ELSE
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_structure fs, academicbillingitems bi
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND studsession=sess AND semester=sems
                    AND bi.ItemCode=fs.ItemCode AND itemname NOT LIKE '%Tuition%';
                END IF;
            END IF;

            -- Late registration surcharge
            IF regStat LIKE '%LATE%' THEN
                SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                    DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
                FROM fin_fees_structure fs, academicbillingitems bi
                WHERE progid=prog AND curr_year=yr
                AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid
                AND ItemName LIKE '%Late Reg%' LIMIT 1;
            END IF;

        ELSEIF regStat='DEAD YEAR' THEN
            SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
            FROM fin_fees_structure fs, academicbillingitems bi
            WHERE progid=prog AND curr_year=yr AND study_year=cyr
            AND semester=sems AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid
            AND ItemName LIKE '%Dead Year%' LIMIT 1;

        END IF;

    ELSEIF typ IN ('RT','RR','SPECIAL','SUPPLEMENTARY') THEN
        SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
            DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
        FROM fin_fees_structure fs, academicbillingitems bi
        WHERE progid=prog AND curr_year=yr AND studsession=sess AND fs.ItemCode=bi.ItemCode
        AND billingID=bid AND ItemName LIKE CONCAT('%',typ,'%') LIMIT 1;

    ELSEIF typ='ACCOMO' AND resStat='RESIDENT' THEN
        SELECT fin_TermlyItemBillingFN('Bill', reg, bi.ItemCode, sems, prog, sess,
            DATE(SYSDATE()), usr, cyr, acad, csid, price) INTO rep
        FROM campus_dynamics.acad_residence r, campus_dynamics.acad_halls h, academicbillingitems bi
        WHERE semester=sems AND acadyear=acad AND regno=reg AND h.ID=r.hall_id
        AND ItemName LIKE '%Accomoda%' LIMIT 1;

    END IF;

END$$

DELIMITER ;
