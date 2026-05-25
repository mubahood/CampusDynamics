-- Migration: fix_approve_journal_safe_varchar_journal_no
-- Logical database: accounts
-- Generated: 2026-05-19
-- ============================================================================
-- BUG: fin_journal_details.journal_no is VARCHAR(45) and can contain values
-- in 'JN-XXXXXX' format (with prefix and optional trailing space) as well as
-- plain numeric strings like '214244'. The previous stored procedure compared
-- d.journal_no (VARCHAR) directly to p_journal_no (INT), forcing MySQL to
-- cast the VARCHAR to DOUBLE. When the value is 'JN-214244 ', the cast fails:
--   "Truncated incorrect DOUBLE value: 'JN-214244 '"
--
-- FIX: Remove the unnecessary JOIN on fin_journalnumbers (j was never used in
-- the SELECT list), and rewrite the WHERE clause to compare VARCHAR to VARCHAR,
-- handling both plain numeric ('214244') and prefixed ('JN-214244') formats.
-- ============================================================================

DROP PROCEDURE IF EXISTS fin_ApproveJournal_Safe;

DELIMITER $$

CREATE PROCEDURE `fin_ApproveJournal_Safe`(
    IN p_journal_no INT,
    IN p_user CHAR(25),
    IN p_journal_type CHAR(25)
)
BEGIN
    DECLARE v_status VARCHAR(15);
    DECLARE v_voucher_no INT DEFAULT 0;
    DECLARE v_line_count INT DEFAULT 0;
    DECLARE v_dr_total DOUBLE DEFAULT 0;
    DECLARE v_cr_total DOUBLE DEFAULT 0;
    DECLARE v_period_count INT DEFAULT 0;
    DECLARE v_period_start DATE;
    DECLARE v_period_end DATE;
    DECLARE v_result VARCHAR(250);

    -- Variables for posting logic (from original fin_ApproveJournal)
    DECLARE vno INT;
    DECLARE v_curr CHAR(65);
    DECLARE v_base_curr CHAR(65);
    DECLARE v_curType CHAR(5);
    DECLARE v_details VARCHAR(250);
    DECLARE v_invoiceDate DATE;

    -- 1. Check journal exists and is Pending
    SELECT PostStatus, IFNULL(GL_VoucherNo, 0)
    INTO v_status, v_voucher_no
    FROM fin_journalnumbers
    WHERE JournalNo = p_journal_no
    LIMIT 1;

    IF v_status IS NULL THEN
        SET v_result = 'Error! Journal does not exist';
    ELSEIF v_status = 'Posted' THEN
        SET v_result = 'Error! Journal has already been posted';
    ELSEIF v_status = 'Void' THEN
        SET v_result = 'Error! Cannot approve a voided journal';
    ELSEIF v_status != 'Pending' THEN
        SET v_result = CONCAT('Error! Journal status is invalid: ', v_status);
    ELSE
        -- 2. Check at least 2 lines exist in fin_journal_details
        -- FIX: compare VARCHAR journal_no to VARCHAR to avoid implicit DOUBLE cast
        SELECT COUNT(*) INTO v_line_count
        FROM fin_journal_details
        WHERE TRIM(journal_no) = CAST(p_journal_no AS CHAR)
           OR TRIM(journal_no) = CONCAT('JN-', p_journal_no);

        IF v_line_count < 2 THEN
            SET v_result = CONCAT('Error! Journal must have at least 2 entries (DR + CR). Found: ', v_line_count);
        ELSE
            -- 3. Check DR = CR balance (for ALL journal types — fixes original bug)
            SELECT COALESCE(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0),
                   COALESCE(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0)
            INTO v_dr_total, v_cr_total
            FROM fin_journal_details
            WHERE TRIM(journal_no) = CAST(p_journal_no AS CHAR)
               OR TRIM(journal_no) = CONCAT('JN-', p_journal_no);

            IF v_dr_total != v_cr_total THEN
                SET v_result = CONCAT('Error! DR/CR imbalance. DR Total: ', FORMAT(v_dr_total, 0),
                                      ', CR Total: ', FORMAT(v_cr_total, 0),
                                      ', Difference: ', FORMAT(ABS(v_dr_total - v_cr_total), 0));
            ELSEIF v_dr_total = 0 AND v_cr_total = 0 THEN
                SET v_result = 'Error! Enter transactions before approving (all amounts are zero)';
            ELSE
                -- 4. Check financial period is open and today is within it
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
                    -- =========================================================
                    -- ALL VALIDATION PASSED — NOW DO THE ACTUAL POSTING
                    -- =========================================================

                    -- Generate next voucher number
                    SET vno = fin_NextVoucherNo(p_user);

                    -- Get journal metadata
                    SELECT journalParticulars, journal_currency, transactionDate
                    INTO v_details, v_curr, v_invoiceDate
                    FROM fin_journalnumbers
                    WHERE JournalNo = p_journal_no;

                    -- Determine base currency for forex handling
                    SELECT base_currency INTO v_base_curr
                    FROM fin_journal_details jd
                    INNER JOIN fin_subaccounts sa ON jd.AccountCode = sa.AccountCode
                    WHERE (TRIM(jd.journal_no) = CAST(p_journal_no AS CHAR)
                        OR TRIM(jd.journal_no) = CONCAT('JN-', p_journal_no))
                      AND base_currency != 'UGX'
                    LIMIT 1;

                    SET v_base_curr = IF(v_base_curr IS NULL, 'UGX', v_base_curr);
                    SET v_curType   = IF(v_base_curr = 'UGX', 'UG', 'US');

                    -- Copy entries from fin_journal_details to fin_ledger
                    -- FIX: removed the redundant JOIN on fin_journalnumbers (j alias was
                    -- never referenced in the SELECT) and replaced the implicit numeric
                    -- comparison (d.journal_no = p_journal_no) with an explicit VARCHAR
                    -- comparison to handle both '214244' and 'JN-214244' formats.
                    INSERT INTO fin_ledger(
                        accountcode, account_type, transactionType, voucherNo,
                        transactionDate, teller, timeLog, folio,
                        particulars, transaction_amount, trans_currency,
                        actual_amount, forex_rate, ugx_amount, InvoiceDate, RefNo
                    )
                    SELECT
                        d.accountcode, d.account_type, d.transactionType, vno,
                        SYSDATE(), p_user, SYSDATE(), p_journal_no,
                        CONCAT(v_details), d.transaction_amount, v_curr,
                        0, fin_real_rate(v_base_curr, d.trans_currency, v_curType), 0,
                        v_invoiceDate, d.refno
                    FROM fin_journal_details d
                    WHERE TRIM(d.journal_no) = CAST(p_journal_no AS CHAR)
                       OR TRIM(d.journal_no) = CONCAT('JN-', p_journal_no);

                    -- Set GL_VoucherNo on the journal header
                    UPDATE fin_journalnumbers
                    SET GL_VoucherNo = vno
                    WHERE JournalNo = p_journal_no;

                    -- Calculate actual amounts for forex entries
                    UPDATE fin_ledger
                    SET actual_amount = IF(
                            forex_rate != 1 AND fin_GetBaseCurrency(accountcode) != 'UGX' AND trans_currency = 'UGX',
                            FLOOR(transaction_amount / forex_rate),
                            IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)
                        ),
                        ugx_amount = IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)
                    WHERE journal_no = '-';

                    -- Assign ledger journal_no (running account transaction number)
                    UPDATE fin_ledger
                    SET journal_no = fin_transactionNo(accountcode, account_type, TID)
                    WHERE journal_no = '-';

                    -- Mark journal as Posted
                    UPDATE fin_journalnumbers
                    SET PostStatus  = 'Posted',
                        Teller      = p_user,
                        journalDate = CURDATE()
                    WHERE JournalNo = p_journal_no;

                    -- Recalculate running balances for all affected accounts
                    CALL fin_UpdateAllLedgerBalances();

                    -- Write audit trail entry
                    INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)
                    VALUES (
                        p_user,
                        'JOURNAL_APPROVED',
                        CONCAT('JournalNo=', p_journal_no, ',VoucherNo=', vno,
                               ',Type=', IFNULL(p_journal_type, 'Normal Journal')),
                        CONCAT('DR=', FORMAT(v_dr_total, 0), ',CR=', FORMAT(v_cr_total, 0)),
                        NOW()
                    );

                    SET v_result = 'Posting Completed';
                END IF;
            END IF;
        END IF;
    END IF;

    SELECT v_result AS result_message;
END$$

DELIMITER ;
