-- ============================================================
-- Bursary Payment Transaction Backfill
-- Creates missing Payment transactions for all Approved
-- bursary beneficiaries and updates transaction_ref links.
-- ============================================================

USE campus_dynamics_accounts;

DROP PROCEDURE IF EXISTS sp_backfill_bursary_payments;

DELIMITER $$

CREATE PROCEDURE sp_backfill_bursary_payments()
BEGIN
    DECLARE done      INT DEFAULT FALSE;
    DECLARE v_stid    INT;
    DECLARE v_regno   VARCHAR(25);
    DECLARE v_sem     INT;
    DECLARE v_yr      VARCHAR(45);
    DECLARE v_amt     DOUBLE;
    DECLARE v_detail  VARCHAR(250);
    DECLARE v_new_tid BIGINT;
    DECLARE v_count   INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT ss.stid,
               ss.adm_no,
               ss.scholarhipTerm,
               ss.scholarhipYear,
               ss.amount_offered,
               CONCAT('Bursary: ', IFNULL(sc.scholarshipName, 'Scholarship')) AS detail
        FROM scholarshipstudents ss
        JOIN scholarships sc ON sc.scholarshipID = ss.scholarshipID
        LEFT JOIN fin_studentfeestracking ft
          ON ft.TID = ss.transaction_ref AND ft.trans_type = 'Payment'
        WHERE ss.status = 'Approved'
          AND (ss.transaction_ref IS NULL OR ft.TID IS NULL)
        ORDER BY ss.stid;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_stid, v_regno, v_sem, v_yr, v_amt, v_detail;
        IF done THEN LEAVE read_loop; END IF;

        -- Insert the Payment transaction
        INSERT INTO fin_studentfeestracking
            (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
        VALUES
            (v_regno, v_sem, v_yr, v_amt, 75, 'Payment', v_detail, NOW(), 'Posted');

        SET v_new_tid = LAST_INSERT_ID();

        -- Update the beneficiary record to point to the new Payment TID
        UPDATE scholarshipstudents
        SET transaction_ref = v_new_tid
        WHERE stid = v_stid;

        SET v_count = v_count + 1;
    END LOOP;

    CLOSE cur;

    SELECT v_count AS transactions_created;
END$$

DELIMITER ;

-- Run it
CALL sp_backfill_bursary_payments();

-- Clean up
DROP PROCEDURE IF EXISTS sp_backfill_bursary_payments;

-- Verify
SELECT COUNT(*) AS still_missing
FROM scholarshipstudents ss
LEFT JOIN fin_studentfeestracking ft
  ON ft.TID = ss.transaction_ref AND ft.trans_type = 'Payment'
WHERE ss.status = 'Approved'
  AND (ss.transaction_ref IS NULL OR ft.TID IS NULL);
