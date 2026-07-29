-- ============================================================================
-- BACKUP (pre-Phase-3) of the two "current balance" functions — 2026-06-25
-- ORIGINAL behaviour = LEDGER-ONLY (Σ DR − Σ CR). Run this file to ROLL BACK
-- the Phase-3 convergence (revert to ledger-only). Does NOT drop the additive
-- fin_GetCanonicalStudentBalance (harmless to leave).
-- ============================================================================
DROP FUNCTION IF EXISTS fin_GetCurrentFeesBalance;
DELIMITER $$
CREATE FUNCTION fin_GetCurrentFeesBalance(regno CHAR(25)) RETURNS char(45) CHARSET latin1
READS SQL DATA
BEGIN
    DECLARE curTrmBal DOUBLE;
    SELECT (SUM(IF(TransactionType='DR',transaction_amount,0))-SUM(IF(TransactionType='CR',transaction_amount,0)))
      INTO curTrmBal FROM fin_ledger WHERE accountcode=regno;
    IF curTrmBal IS NULL THEN SET curTrmBal=0; END IF;
    IF curTrmBal<=0 THEN
        RETURN CONCAT(FORMAT(ABS(curTrmBal),0),' CREDIT');
    ELSE
        RETURN CONCAT(FORMAT(ABS(curTrmBal),0),' DEBIT');
    END IF;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS fin_GetCurrentStudentBalance;
DELIMITER $$
CREATE FUNCTION fin_GetCurrentStudentBalance(accCode CHAR(25)) RETURNS char(45) CHARSET utf8
READS SQL DATA
BEGIN
    DECLARE balance,CR,DR DOUBLE;
    SELECT SUM(transaction_amount) INTO CR FROM fin_ledger WHERE accountcode=accCode AND transactionType='CR';
    SELECT SUM(transaction_amount) INTO DR FROM fin_ledger WHERE accountcode=accCode AND transactionType='DR';
    IF DR IS NULL THEN SET DR=0; END IF;
    IF CR IS NULL THEN SET CR=0; END IF;
    SET balance=DR-CR;
    RETURN IF(balance < 0, CONCAT(FORMAT(ABS(balance),0),' CREDIT'),CONCAT(FORMAT(ABS(balance),0),' DEBIT'));
END$$
DELIMITER ;
