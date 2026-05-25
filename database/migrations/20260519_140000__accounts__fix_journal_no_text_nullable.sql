-- Migration: fix_journal_no_text_nullable
-- Makes fin_journal_details.journal_no TEXT NULL (was VARCHAR(45) NOT NULL)
-- and fixes all remaining stored procedures that compare journal_no to an INT parameter,
-- which forces MySQL to DOUBLE-cast the VARCHAR → "Truncated incorrect DOUBLE value" error.
-- Affected SPs: fin_ClearJournalDetails, fin_GetJournalDetails, fin_ValidateAndPostJournal

-- ── 1. Alter the column ──────────────────────────────────────────────────────
ALTER TABLE fin_journal_details
    MODIFY COLUMN journal_no TEXT NULL;

-- ── 2. Fix fin_ClearJournalDetails ──────────────────────────────────────────
DROP PROCEDURE IF EXISTS fin_ClearJournalDetails;

DELIMITER $$

CREATE PROCEDURE `fin_ClearJournalDetails`(jno TEXT)
BEGIN
    DELETE FROM fin_journal_details
    WHERE TRIM(journal_no) = TRIM(jno)
       OR TRIM(journal_no) = CONCAT('JN-', TRIM(jno));
END$$

DELIMITER ;

-- ── 3. Fix fin_GetJournalDetails ─────────────────────────────────────────────
DROP PROCEDURE IF EXISTS fin_GetJournalDetails;

DELIMITER $$

CREATE PROCEDURE `fin_GetJournalDetails`(jno TEXT)
BEGIN
    DECLARE gl_voucher INT;
    DECLARE jStat, jType CHAR(25);

    SELECT GL_VoucherNo, PostStatus, journalType
    INTO gl_voucher, jStat, jType
    FROM fin_journalnumbers
    WHERE JournalNo = CAST(TRIM(jno) AS UNSIGNED)
    LIMIT 1;

    IF (jStat = 'Posted') THEN
        SELECT fin_GetLedgerAccountName(account_type, accountcode) AS accountname,
               UPPER(jType) AS 'jType', l.*
        FROM fin_ledger l
        WHERE voucherno = gl_voucher;
    ELSE
        SELECT fin_GetLedgerAccountName(account_type, accountcode) AS accountname,
               UPPER(jType) AS 'jType', l.*
        FROM fin_journal_details l
        WHERE (TRIM(l.journal_no) = TRIM(jno) OR TRIM(l.journal_no) = CONCAT('JN-', TRIM(jno)))
          AND journal_type = jType;
    END IF;
END$$

DELIMITER ;

-- ── 4. Fix fin_ValidateAndPostJournal ────────────────────────────────────────
DROP PROCEDURE IF EXISTS fin_ValidateAndPostJournal;

DELIMITER $$

CREATE PROCEDURE `fin_ValidateAndPostJournal`(
    IN p_journal_no TEXT,
    IN p_user CHAR(25)
)
BEGIN
    DECLARE v_status VARCHAR(15);
    DECLARE v_line_count INT DEFAULT 0;
    DECLARE v_dr_total DOUBLE DEFAULT 0;
    DECLARE v_cr_total DOUBLE DEFAULT 0;
    DECLARE v_period_count INT DEFAULT 0;
    DECLARE v_period_start DATE;
    DECLARE v_period_end DATE;
    DECLARE v_result VARCHAR(250);

    -- 1. Check journal exists and is Pending
    SELECT PostStatus INTO v_status
    FROM fin_journalnumbers
    WHERE JournalNo = CAST(TRIM(p_journal_no) AS UNSIGNED)
    LIMIT 1;

    IF v_status IS NULL THEN
        SET v_result = 'Error! Journal does not exist';
    ELSEIF v_status = 'Posted' THEN
        SET v_result = 'Error! Journal has already been posted';
    ELSEIF v_status = 'Void' THEN
        SET v_result = 'Error! Cannot post a voided journal';
    ELSEIF v_status != 'Pending' THEN
        SET v_result = CONCAT('Error! Journal status is invalid: ', v_status);
    ELSE
        -- 2. Check at least 2 ledger lines exist
        SELECT COUNT(*) INTO v_line_count
        FROM fin_journal_details
        WHERE TRIM(journal_no) = TRIM(p_journal_no)
           OR TRIM(journal_no) = CONCAT('JN-', TRIM(p_journal_no));

        IF v_line_count < 2 THEN
            SET v_result = CONCAT('Error! Journal must have at least 2 entries (DR + CR). Found: ', v_line_count);
        ELSE
            -- 3. Check DR = CR balance
            SELECT COALESCE(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0),
                   COALESCE(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0)
            INTO v_dr_total, v_cr_total
            FROM fin_journal_details
            WHERE TRIM(journal_no) = TRIM(p_journal_no)
               OR TRIM(journal_no) = CONCAT('JN-', TRIM(p_journal_no));

            IF v_dr_total != v_cr_total THEN
                SET v_result = CONCAT('Error! DR/CR imbalance. DR Total: ', FORMAT(v_dr_total, 0),
                                      ', CR Total: ', FORMAT(v_cr_total, 0),
                                      ', Difference: ', FORMAT(ABS(v_dr_total - v_cr_total), 0));
            ELSEIF v_dr_total = 0 AND v_cr_total = 0 THEN
                SET v_result = 'Error! Enter transactions before posting (all amounts are zero)';
            ELSE
                -- 4. Check financial period is open
                SELECT COUNT(*), MIN(start_date), MIN(end_date)
                INTO v_period_count, v_period_start, v_period_end
                FROM fin_financial_years
                WHERE status = 'Open';

                IF v_period_count = 0 THEN
                    SET v_result = 'Error! No financial year is currently Open';
                ELSEIF CURDATE() < v_period_start OR CURDATE() > v_period_end THEN
                    SET v_result = CONCAT('Error! Current date is outside the open financial period (',
                                          DATE_FORMAT(v_period_start, '%d/%m/%Y'), ' - ',
                                          DATE_FORMAT(v_period_end, '%d/%m/%Y'), ')');
                ELSE
                    SET v_result = 'OK';
                END IF;
            END IF;
        END IF;
    END IF;

    SELECT v_result AS result_message;
END$$

DELIMITER ;
