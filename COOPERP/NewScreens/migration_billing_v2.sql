-- ============================================================================
-- BILLING SP INTEGRATION: fin_AutobillingV2
-- Uses fin_programme_fees for Tuition (ItemCode=1) and Functional Fees (ItemCode=52)
-- when an active programme fee structure exists; falls back to old behavior otherwise.
-- ============================================================================

DELIMITER $$

-- ── Helper: Get tuition + functional from programme fees table ──
DROP PROCEDURE IF EXISTS fin_BillProgrammeFees$$
CREATE PROCEDURE fin_BillProgrammeFees(
    IN p_regno CHAR(35),
    IN p_progcode CHAR(25),
    IN p_session CHAR(25),
    IN p_study_year INT,
    IN p_semester INT,
    IN p_acad_year CHAR(15),
    IN p_user CHAR(45),
    IN p_csid CHAR(25)
)
BEGIN
    DECLARE v_tuition DECIMAL(15,2) DEFAULT 0;
    DECLARE v_functional DECIMAL(15,2) DEFAULT 0;
    DECLARE v_dummy CHAR(25);

    -- Use the existing SP to get fees
    CALL fin_GetProgrammeFee(p_progcode, p_study_year, p_semester, v_tuition, v_functional);

    -- Bill tuition (ItemCode = 1) if amount > 0
    IF v_tuition > 0 THEN
        SELECT fin_TermlyItemBillingFN('Bill', p_regno, 1, p_semester, p_progcode,
            p_session, DATE(SYSDATE()), p_user, p_study_year, p_acad_year, p_csid, v_tuition)
        INTO v_dummy;
    END IF;

    -- Bill functional fee (ItemCode = 52) if amount > 0
    IF v_functional > 0 THEN
        SELECT fin_TermlyItemBillingFN('Bill', p_regno, 52, p_semester, p_progcode,
            p_session, DATE(SYSDATE()), p_user, p_study_year, p_acad_year, p_csid, v_functional)
        INTO v_dummy;
    END IF;
END$$


-- ── Updated billing SP: checks programme fees first, falls back to old ──
DROP PROCEDURE IF EXISTS fin_AutobillingV2$$
CREATE PROCEDURE fin_AutobillingV2(
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

    SET usr=reg;

    -- Check if this programme has an active fee structure in the new table
    SELECT COUNT(*) INTO v_has_pf
    FROM fin_programme_fees
    WHERE progcode=prog AND is_active='Yes';

    IF typ='REG' THEN

        IF regStat IN ('REGISTERED','LATE REGISTERED') THEN

            IF v_has_pf > 0 THEN
                -- ── NEW PATH: Use programme fees for Tuition + Functional ──
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
                -- ── OLD PATH: No active programme fee structure, use legacy tables ──
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

            -- Late registration surcharge (unchanged - always from fin_fees_structure)
            IF regStat LIKE '%LATE%' THEN
                SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                    DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
                FROM fin_fees_structure fs, academicbillingitems bi
                WHERE progid=prog AND curr_year=yr
                AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid
                AND ItemName LIKE '%Late Reg%' LIMIT 1;
            END IF;

        ELSEIF regStat='DEAD YEAR' THEN
            -- Dead year billing (unchanged)
            SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
            FROM fin_fees_structure fs, academicbillingitems bi
            WHERE progid=prog AND curr_year=yr AND study_year=cyr
            AND semester=sems AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid
            AND ItemName LIKE '%Dead Year%' LIMIT 1;

        END IF;

    ELSEIF typ IN ('RT','RR','SPECIAL','SUPPLEMENTARY') THEN
        -- Retake/Special billing (unchanged)
        SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
            DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
        FROM fin_fees_structure fs, academicbillingitems bi
        WHERE progid=prog AND curr_year=yr AND studsession=sess AND fs.ItemCode=bi.ItemCode
        AND billingID=bid AND ItemName LIKE CONCAT('%',typ,'%') LIMIT 1;

    ELSEIF typ='ACCOMO' AND resStat='RESIDENT' THEN
        -- Accommodation billing (unchanged)
        SELECT fin_TermlyItemBillingFN('Bill', reg, bi.ItemCode, sems, prog, sess,
            DATE(SYSDATE()), usr, cyr, acad, csid, price) INTO rep
        FROM campus_dynamics.acad_residence r, campus_dynamics.acad_halls h, academicbillingitems bi
        WHERE semester=sems AND acadyear=acad AND regno=reg AND h.ID=r.hall_id
        AND ItemName LIKE '%Accomoda%' LIMIT 1;

    END IF;

END$$

DELIMITER ;
