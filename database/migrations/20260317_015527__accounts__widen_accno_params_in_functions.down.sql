-- Rollback: widen_accno_params_in_functions
-- Logical database: accounts
-- Generated: 2026-03-17T01:55:27
-- WARNING: Rolling back will revert accNo/accCode to CHAR(15).
--          If any account codes longer than 15 chars still exist
--          in fin_subaccounts, fin_TrialBalance will break again.

-- 1. Restore fin_GetOpeningBalance with CHAR(15)
DROP FUNCTION IF EXISTS fin_GetOpeningBalance;

DELIMITER $$

CREATE FUNCTION fin_GetOpeningBalance(startDate DATE, accNo CHAR(15))
RETURNS BIGINT(20)
DETERMINISTIC
BEGIN
    DECLARE totalCR, totalDR, bal, openingBal BIGINT;
    DECLARE accType, ledgerTypes, accCat CHAR(45);
    SELECT collectionLedgerType, accounttype, generalCategory
      INTO ledgerTypes, accType, accCat
      FROM fin_subaccounts s, fin_mainaccounts m
     WHERE s.AccountCode = accNo AND s.mainaccountcode = m.accountcode;
    SET openingBal = 0;
    IF accType = 'Basic Account' THEN
        SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f
         WHERE transactiontype = 'CR' AND accountcode = accNo AND transactiondate < startDate;
        SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f
         WHERE transactiontype = 'DR' AND accountcode = accNo AND transactiondate < startDate;
    ELSE
        SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f
         WHERE transactiontype = 'CR' AND account_type = ledgerTypes AND transactiondate < startDate;
        SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f
         WHERE transactiontype = 'DR' AND account_type = ledgerTypes AND transactiondate < startDate;
    END IF;
    IF totalDR IS NULL THEN SET totalDR = 0; END IF;
    IF totalCR IS NULL THEN SET totalCR = 0; END IF;
    RETURN (totalDR - totalCR);
END$$

DELIMITER ;

-- 2. Restore fin_GetPeriodBalance with CHAR(15)
DROP FUNCTION IF EXISTS fin_GetPeriodBalance;

DELIMITER $$

CREATE FUNCTION fin_GetPeriodBalance(startDate DATE, endDate DATE, accNo CHAR(15), balType CHAR(25))
RETURNS DOUBLE
DETERMINISTIC
BEGIN
    DECLARE totalCR, totalDR, bal, openingBal BIGINT;
    DECLARE accType, ledgerTypes, accCat CHAR(45);
    SELECT collectionLedgerType, accounttype, generalCategory
      INTO ledgerTypes, accType, accCat
      FROM fin_subaccounts s, fin_mainaccounts m
     WHERE s.AccountCode = accNo AND s.mainaccountcode = m.accountcode;
    SET openingBal = 0;
    IF accCat IN ('Assets','Liabilities','Equity') THEN
        SET openingBal = fin_GetOpeningBalance(startDate, accNo);
    END IF;
    IF accType = 'Basic Account' THEN
        IF balType = 'Period' THEN
            SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f
             WHERE transactiontype = 'CR' AND accountcode = accNo AND transactiondate BETWEEN startDate AND endDate;
            SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f
             WHERE transactiontype = 'DR' AND accountcode = accNo AND transactiondate BETWEEN startDate AND endDate;
        ELSEIF balType = 'Opening' THEN
            SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f
             WHERE transactiontype = 'CR' AND accountcode = accNo AND transactiondate < startDate;
            SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f
             WHERE transactiontype = 'DR' AND accountcode = accNo AND transactiondate < startDate;
        END IF;
    ELSE
        IF balType = 'Period' THEN
            SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f
             WHERE transactiontype = 'CR' AND account_type = ledgerTypes AND transactiondate BETWEEN startDate AND endDate;
            SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f
             WHERE transactiontype = 'DR' AND account_type = ledgerTypes AND transactiondate BETWEEN startDate AND endDate;
        ELSEIF balType = 'Opening' THEN
            SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f
             WHERE transactiontype = 'CR' AND account_type = ledgerTypes AND transactiondate < startDate;
            SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f
             WHERE transactiontype = 'DR' AND account_type = ledgerTypes AND transactiondate < startDate;
        END IF;
    END IF;
    IF totalDR IS NULL THEN SET totalDR = 0; END IF;
    IF totalCR IS NULL THEN SET totalCR = 0; END IF;
    RETURN (totalDR - totalCR) + openingBal;
END$$

DELIMITER ;

-- 3. Restore fin_GetTrialBalanceGroup with CHAR(15)
DROP FUNCTION IF EXISTS fin_GetTrialBalanceGroup;

DELIMITER $$

CREATE FUNCTION fin_GetTrialBalanceGroup(accCode CHAR(15))
RETURNS CHAR(25) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE MAC CHAR(25);
    SELECT GeneralCategory INTO MAC
      FROM fin_mainaccounts ma
      JOIN fin_subaccounts sa ON ma.accountCode = sa.MainAccountCode
     WHERE sa.accountCode = accCode;
    RETURN MAC;
END$$

DELIMITER ;