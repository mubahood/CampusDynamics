-- ============================================================================
-- PHASE 3 — converge the "current balance" DB functions onto ONE canonical
-- dual-source (fin_ledger + fin_studentfeestracking, deduped, Fix B) source.
-- 2026-06-25.  Backup/rollback: _backup_balance_funcs_20260625.sql
--
-- 1) fin_GetCanonicalStudentBalance(reg) -> DECIMAL  (billed - paid; owing +)
--    ADDITIVE, single source of truth for an all-time student balance.
-- 2) fin_GetCurrentFeesBalance / fin_GetCurrentStudentBalance now DELEGATE to it,
--    keeping their exact "X CREDIT" / "X DEBIT" string output (callers such as
--    fin_StudentClearance parse 'LIKE %CREDIT', and the portal public API shows
--    the string) — only the underlying NUMBER becomes canonical.
-- ============================================================================

-- 1. Canonical numeric balance (additive) ------------------------------------
DROP FUNCTION IF EXISTS fin_GetCanonicalStudentBalance;
DELIMITER $$
CREATE FUNCTION fin_GetCanonicalStudentBalance(reg VARCHAR(50))
RETURNS DECIMAL(20,2)
READS SQL DATA
BEGIN
    DECLARE bal DECIMAL(20,2);
    SELECT IFNULL( SUM(CASE WHEN x.ttype='DR' THEN x.amt ELSE 0 END)
                 - SUM(CASE WHEN x.ttype='CR' THEN x.amt ELSE 0 END), 0)
      INTO bal
    FROM (
        SELECT fl.transactionType AS ttype, fl.transaction_amount AS amt
          FROM fin_ledger fl
         WHERE fl.accountcode = reg AND fl.transaction_amount > 0
        UNION ALL
        SELECT CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END AS ttype,
               t.amount AS amt
          FROM fin_studentfeestracking t
         WHERE t.regno = reg AND t.post_status = 'Posted'
           AND NOT EXISTS (
               SELECT 1 FROM fin_ledger fl2
                WHERE fl2.accountcode = t.regno
                  AND ( fl2.voucherNo = CAST(t.TID AS CHAR)
                     OR fl2.folio    = CONCAT('BillNo:', CAST(t.TID AS CHAR))
                     OR ( fl2.transaction_amount = t.amount
                          AND DATE(fl2.transactionDate) = DATE(t.trans_date)
                          AND fl2.transactionType = CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END
                          AND (t.trans_type IN ('Payment','Waiver') OR fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
                        )
                  )
           )
    ) x;
    RETURN IFNULL(bal, 0);
END$$
DELIMITER ;

-- 2a. fin_GetCurrentFeesBalance -> delegate (string format preserved) ---------
DROP FUNCTION IF EXISTS fin_GetCurrentFeesBalance;
DELIMITER $$
CREATE FUNCTION fin_GetCurrentFeesBalance(regno CHAR(25)) RETURNS char(45) CHARSET latin1
READS SQL DATA
BEGIN
    DECLARE curTrmBal DOUBLE;
    SET curTrmBal = fin_GetCanonicalStudentBalance(regno);
    IF curTrmBal IS NULL THEN SET curTrmBal=0; END IF;
    IF curTrmBal<=0 THEN
        RETURN CONCAT(FORMAT(ABS(curTrmBal),0),' CREDIT');
    ELSE
        RETURN CONCAT(FORMAT(ABS(curTrmBal),0),' DEBIT');
    END IF;
END$$
DELIMITER ;

-- 2b. fin_GetCurrentStudentBalance -> delegate (string format preserved) ------
DROP FUNCTION IF EXISTS fin_GetCurrentStudentBalance;
DELIMITER $$
CREATE FUNCTION fin_GetCurrentStudentBalance(accCode CHAR(25)) RETURNS char(45) CHARSET utf8
READS SQL DATA
BEGIN
    DECLARE balance DOUBLE;
    SET balance = fin_GetCanonicalStudentBalance(accCode);
    IF balance IS NULL THEN SET balance=0; END IF;
    RETURN IF(balance < 0, CONCAT(FORMAT(ABS(balance),0),' CREDIT'),CONCAT(FORMAT(ABS(balance),0),' DEBIT'));
END$$
DELIMITER ;
