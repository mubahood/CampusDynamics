-- ============================================================
-- Migration: widen_accno_params_in_functions (UP)
-- Logical database: accounts
-- Generated: 2026-03-17T01:55:27
-- Purpose:   Widen accNo / accCode CHAR(15) → CHAR(25) in three
--            MySQL functions so that longer account codes such as
--            'AC-RECONCILE-DIFF' (17 chars, created by E2 data
--            repair) no longer cause "Data too long for column
--            'accNo'" when fin_TrialBalance is called.
--
-- Affected functions:
--   1. fin_GetOpeningBalance    — accNo  CHAR(15) → CHAR(25)
--   2. fin_GetPeriodBalance     — accNo  CHAR(15) → CHAR(25)
--   3. fin_GetTrialBalanceGroup — accCode CHAR(15) → CHAR(25)
-- ============================================================

-- -----------------------------------------------
-- 1. fin_GetOpeningBalance  (must come FIRST
--    because fin_GetPeriodBalance calls it)
-- -----------------------------------------------
DROP FUNCTION IF EXISTS fin_GetOpeningBalance;

DELIMITER $$

CREATE FUNCTION fin_GetOpeningBalance(startDate DATE, accNo CHAR(25))
RETURNS BIGINT(20)
DETERMINISTIC
BEGIN
    DECLARE totalCR, totalDR, bal, openingBal BIGINT;
    DECLARE accType, ledgerTypes, accCat CHAR(45);

    SELECT collectionLedgerType, accounttype, generalCategory
      INTO ledgerTypes, accType, accCat
      FROM fin_subaccounts s, fin_mainaccounts m
     WHERE s.AccountCode = accNo
       AND s.mainaccountcode = m.accountcode;

    SET openingBal = 0;

    IF accType = 'Basic Account' THEN
        SELECT SUM(transaction_amount) INTO totalCR
          FROM fin_ledger f
         WHERE transactiontype = 'CR'
           AND accountcode = accNo
           AND transactiondate < startDate;

        SELECT SUM(transaction_amount) INTO totalDR
          FROM fin_ledger f
         WHERE transactiontype = 'DR'
           AND accountcode = accNo
           AND transactiondate < startDate;
    ELSE
        SELECT SUM(transaction_amount) INTO totalCR
          FROM fin_ledger f
         WHERE transactiontype = 'CR'
           AND account_type = ledgerTypes
           AND transactiondate < startDate;

        SELECT SUM(transaction_amount) INTO totalDR
          FROM fin_ledger f
         WHERE transactiontype = 'DR'
           AND account_type = ledgerTypes
           AND transactiondate < startDate;
    END IF;

    IF totalDR IS NULL THEN SET totalDR = 0; END IF;
    IF totalCR IS NULL THEN SET totalCR = 0; END IF;

    RETURN (totalDR - totalCR);
END$$

DELIMITER ;

-- -----------------------------------------------
-- 2. fin_GetPeriodBalance
-- -----------------------------------------------
DROP FUNCTION IF EXISTS fin_GetPeriodBalance;

DELIMITER $$

CREATE FUNCTION fin_GetPeriodBalance(startDate DATE, endDate DATE, accNo CHAR(25), balType CHAR(25))
RETURNS DOUBLE
DETERMINISTIC
BEGIN
    DECLARE totalCR, totalDR, bal, openingBal BIGINT;
    DECLARE accType, ledgerTypes, accCat CHAR(45);

    SELECT collectionLedgerType, accounttype, generalCategory
      INTO ledgerTypes, accType, accCat
      FROM fin_subaccounts s, fin_mainaccounts m
     WHERE s.AccountCode = accNo
       AND s.mainaccountcode = m.accountcode;

    SET openingBal = 0;

    IF accCat IN ('Assets','Liabilities','Equity') THEN
        SET openingBal = fin_GetOpeningBalance(startDate, accNo);
    END IF;

    IF accType = 'Basic Account' THEN
        IF balType = 'Period' THEN
            SELECT SUM(transaction_amount) INTO totalCR
              FROM fin_ledger f
             WHERE transactiontype = 'CR'
               AND accountcode = accNo
               AND transactiondate BETWEEN startDate AND endDate;

            SELECT SUM(transaction_amount) INTO totalDR
              FROM fin_ledger f
             WHERE transactiontype = 'DR'
               AND accountcode = accNo
               AND transactiondate BETWEEN startDate AND endDate;

        ELSEIF balType = 'Opening' THEN
            SELECT SUM(transaction_amount) INTO totalCR
              FROM fin_ledger f
             WHERE transactiontype = 'CR'
               AND accountcode = accNo
               AND transactiondate < startDate;

            SELECT SUM(transaction_amount) INTO totalDR
              FROM fin_ledger f
             WHERE transactiontype = 'DR'
               AND accountcode = accNo
               AND transactiondate < startDate;
        END IF;
    ELSE
        IF balType = 'Period' THEN
            SELECT SUM(transaction_amount) INTO totalCR
              FROM fin_ledger f
             WHERE transactiontype = 'CR'
               AND account_type = ledgerTypes
               AND transactiondate BETWEEN startDate AND endDate;

            SELECT SUM(transaction_amount) INTO totalDR
              FROM fin_ledger f
             WHERE transactiontype = 'DR'
               AND account_type = ledgerTypes
               AND transactiondate BETWEEN startDate AND endDate;

        ELSEIF balType = 'Opening' THEN
            SELECT SUM(transaction_amount) INTO totalCR
              FROM fin_ledger f
             WHERE transactiontype = 'CR'
               AND account_type = ledgerTypes
               AND transactiondate < startDate;

            SELECT SUM(transaction_amount) INTO totalDR
              FROM fin_ledger f
             WHERE transactiontype = 'DR'
               AND account_type = ledgerTypes
               AND transactiondate < startDate;
        END IF;
    END IF;

    IF totalDR IS NULL THEN SET totalDR = 0; END IF;
    IF totalCR IS NULL THEN SET totalCR = 0; END IF;

    RETURN (totalDR - totalCR) + openingBal;
END$$

DELIMITER ;

-- -----------------------------------------------
-- 3. fin_GetTrialBalanceGroup
-- -----------------------------------------------
DROP FUNCTION IF EXISTS fin_GetTrialBalanceGroup;

DELIMITER $$

CREATE FUNCTION fin_GetTrialBalanceGroup(accCode CHAR(25))
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