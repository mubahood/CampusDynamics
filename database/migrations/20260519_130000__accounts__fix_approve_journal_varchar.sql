-- Migration: fix_approve_journal_varchar
-- Fixes VARCHAR/INT comparison bug in fin_ApproveJournal and fin_GetJournalTotalCR_DR
-- Root cause: fin_journal_details.journal_no is VARCHAR(45) containing 'JN-XXXXXX' or '214244'.
-- Comparing directly to an INT forces MySQL to DOUBLE-cast VARCHAR, producing:
--   "Truncated incorrect DOUBLE value: 'JN-214244 '"

-- ── 1. Fix fin_GetJournalTotalCR_DR ─────────────────────────────────────────
DROP FUNCTION IF EXISTS fin_GetJournalTotalCR_DR;

DELIMITER $$

CREATE FUNCTION `fin_GetJournalTotalCR_DR`(typ CHAR(5), jno INT) RETURNS double
BEGIN
    DECLARE amt DOUBLE;
    DECLARE jtype CHAR(25);

    SELECT journaltype INTO jType
    FROM fin_journalnumbers
    WHERE JournalNo = jno
    LIMIT 1;

    SELECT SUM(transaction_amount) INTO amt
    FROM fin_journal_details
    WHERE (TRIM(journal_no) = CAST(jno AS CHAR) OR TRIM(journal_no) = CONCAT('JN-', jno))
      AND transactionType = typ
      AND journal_type = jtype;

    RETURN IF(amt IS NULL, 0, amt);
END$$

DELIMITER ;

-- ── 2. Fix fin_ApproveJournal ────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS fin_ApproveJournal;

DELIMITER $$

CREATE PROCEDURE `fin_ApproveJournal`(jno INT, usr CHAR(25), typ CHAR(25))
BEGIN
    DECLARE vno  INT;
    DECLARE DRTotal, CRTotal BIGINT;
    DECLARE VStat, comm, curr, base_curr, curType CHAR(65);
    DECLARE details     VARCHAR(250);
    DECLARE forexRate   DOUBLE;
    DECLARE invoiceDate DATE;

    SET vno = fin_NextVoucherNo(usr);

    SELECT PostStatus, journalParticulars, journal_currency, j.transactionDate
    INTO VStat, details, curr, invoiceDate
    FROM fin_journalnumbers j
    WHERE journalNo = jno;

    -- FIX: compare VARCHAR journal_no to VARCHAR to avoid implicit DOUBLE cast
    SELECT base_currency INTO base_curr
    FROM fin_journal_details jd
    INNER JOIN fin_subaccounts sa ON jd.AccountCode = sa.AccountCode
    WHERE (TRIM(jd.journal_no) = CAST(jno AS CHAR) OR TRIM(jd.journal_no) = CONCAT('JN-', jno))
      AND base_currency != 'UGX'
    LIMIT 1;

    SET base_curr = IF(base_curr IS NULL, 'UGX', base_curr);
    SET curType   = IF(base_curr = 'UGX', 'UG', 'US');

    IF (fin_GetJournalTotalCR_DR('DR', jno) != fin_GetJournalTotalCR_DR('CR', jno) AND typ = 'Normal Journal') THEN
        SET comm = 'Error! Inbalace in CR and DR Totals';

    ELSEIF (fin_GetJournalTotalCR_DR('DR', jno) = 0 AND fin_GetJournalTotalCR_DR('CR', jno) = 0) THEN
        SET comm = 'Error! Enter Transactions before posting';

    ELSEIF VStat = 'Pending' THEN
        -- FIX: removed the redundant INNER JOIN on fin_journalnumbers (j alias
        -- was never referenced in SELECT); replaced implicit numeric comparison
        -- (d.journal_no = jno) with explicit VARCHAR comparison handling both
        -- '214244' and 'JN-214244' formats.
        INSERT INTO fin_ledger(
            accountcode, account_type, transactionType, voucherNo,
            transactionDate, teller, timeLog, folio,
            particulars, transaction_amount, trans_currency,
            actual_amount, forex_rate, ugx_amount, InvoiceDate, RefNo
        )
        SELECT
            accountcode, account_type, transactionType, vno,
            SYSDATE(), usr, SYSDATE(), jno,
            CONCAT(details), transaction_amount, curr,
            0, fin_real_rate(base_curr, trans_currency, curType), 0,
            invoiceDate, d.refno
        FROM fin_journal_details d
        WHERE TRIM(d.journal_no) = CAST(jno AS CHAR)
           OR TRIM(d.journal_no) = CONCAT('JN-', jno);

        UPDATE fin_journalnumbers SET GL_VoucherNo = vno WHERE journalno = jno;

        UPDATE fin_ledger
        SET actual_amount = IF(
                forex_rate != 1 AND fin_GetBaseCurrency(accountcode) != 'UGX' AND trans_currency = 'UGX',
                FLOOR(transaction_amount / forex_rate),
                IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)
            ),
            ugx_amount = IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)
        WHERE journal_no = '-';

        UPDATE fin_ledger
        SET journal_no = fin_transactionNo(accountcode, account_type, TID)
        WHERE journal_no = '-';

        UPDATE fin_journalnumbers SET PostStatus = 'Posted' WHERE journalno = jno;

        SET comm = 'Posting Completed';
    ELSE
        SET comm = 'Posting Already Done';
    END IF;

    CALL fin_UpdateAllLedgerBalances();
    SELECT comm FROM DUAL;
END$$

DELIMITER ;
