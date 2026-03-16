-- Migration: create_fin_approve_journal_safe
-- Logical database: accounts
-- Generated: 2026-03-16T22:51:44
-- D2: Create fin_ApproveJournal_Safe stored procedure
-- This replaces fin_ApproveJournal as the SINGLE gate for all journal approvals.
-- Unlike fin_ApproveJournal which blindly marks journals as Posted, this procedure
-- runs all four balance/period checks (via fin_ValidateAndPostJournal logic) first.
--
-- Checks performed:
--   1. Journal exists and is in 'Pending' status
--   2. At least 2 ledger lines exist in fin_journal_details (minimum for double-entry)
--   3. SUM(DR) = SUM(CR) and neither is zero (fundamental accounting rule)
--   4. Financial period is open and today falls within it
--
-- On success:
--   - Sets PostStatus = 'Posted', Teller = p_user, journalDate = CURDATE()
--   - Calls fin_UpdateAllLedgerBalances() to recalculate running totals
--   - Writes an audit log entry to acc_activity_log
--
-- Returns: result_message (SELECT) with 'OK' on success or error description.
-- The existing fin_ApproveJournal procedure is preserved for backward compatibility
-- until all callers have been migrated (D3-D7).
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

DELIMITER $$

DROP PROCEDURE IF EXISTS `fin_ApproveJournal_Safe`$$

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
        -- 2. Check at least 2 ledger lines exist
        SELECT COUNT(*) INTO v_line_count
        FROM fin_journal_details
        WHERE journal_no = p_journal_no;

        IF v_line_count < 2 THEN
            SET v_result = CONCAT('Error! Journal must have at least 2 entries (DR + CR). Found: ', v_line_count);
        ELSE
            -- 3. Check DR = CR balance (for ALL journal types)
            SELECT COALESCE(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0),
                   COALESCE(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0)
            INTO v_dr_total, v_cr_total
            FROM fin_journal_details
            WHERE journal_no = p_journal_no;

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
                    -- All checks passed — approve the journal
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
                        CONCAT('JournalNo=', p_journal_no, ',VoucherNo=', v_voucher_no,
                               ',Type=', IFNULL(p_journal_type, 'Normal Journal')),
                        CONCAT('DR=', FORMAT(v_dr_total, 0), ',CR=', FORMAT(v_cr_total, 0)),
                        NOW()
                    );

                    SET v_result = 'OK';
                END IF;
            END IF;
        END IF;
    END IF;

    SELECT v_result AS result_message;
END$$

DELIMITER ;
