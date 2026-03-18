-- ============================================================
-- Migration: widen_remaining_accno_params (UP)
-- Logical database: accounts
-- Generated: 2026-03-17T02:07:03
-- Purpose:   Widen accNo/accCode/ID CHAR(15) → CHAR(25) in three
--            additional functions missed in the first pass.
--
-- Affected functions:
--   1. fin_GetPeriodOpeningBalance  — accNo  CHAR(15) → CHAR(25)
--   2. fin_GetChartAccountLegderType — accCode CHAR(15) → CHAR(25)
--   3. fin_GetVoucherAccountNames  — ID CHAR(15) → CHAR(25)
-- ============================================================

-- -----------------------------------------------
-- 1. fin_GetPeriodOpeningBalance
-- -----------------------------------------------
DROP FUNCTION IF EXISTS fin_GetPeriodOpeningBalance;

DELIMITER $$

CREATE FUNCTION fin_GetPeriodOpeningBalance(startDate DATE, endDate DATE, accNo CHAR(25), balType CHAR(25))
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

    IF accCat IN ('Assets','Liabilities') THEN
        SET openingBal = fin_GetPeriodBalance(startDate, endDate, accNo, 'Opening');
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
-- 2. fin_GetChartAccountLegderType
-- -----------------------------------------------
DROP FUNCTION IF EXISTS fin_GetChartAccountLegderType;

DELIMITER $$

CREATE FUNCTION fin_GetChartAccountLegderType(accCode CHAR(25))
RETURNS CHAR(100) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE accType CHAR(100);

    SELECT collectionLedgerType INTO accType
      FROM fin_subaccounts f
     WHERE accountcode = accCode;

    RETURN IF(accType IS NULL, '-', accType);
END$$

DELIMITER ;

-- -----------------------------------------------
-- 3. fin_GetVoucherAccountNames
-- -----------------------------------------------
DROP FUNCTION IF EXISTS fin_GetVoucherAccountNames;

DELIMITER $$

CREATE FUNCTION fin_GetVoucherAccountNames(typ CHAR(25), ID CHAR(25))
RETURNS VARCHAR(150) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE nm VARCHAR(150);

    IF typ IN (SELECT LedgerTypeName FROM fin_ledgertypes f WHERE ledgertypecategory = 'Supplier') THEN
        SELECT supplierName INTO nm FROM supplier WHERE supplierID = ID;
    ELSEIF typ IN (SELECT LedgerTypeName FROM fin_ledgertypes f WHERE ledgertypecategory = 'Student') THEN
        SELECT CONCAT(stud_names) INTO nm FROM schoolmis.student WHERE adm_no = ID;
    ELSEIF typ IN (SELECT LedgerTypeName FROM fin_ledgertypes f WHERE ledgertypecategory = 'Employee') THEN
        SELECT emp_name INTO nm FROM campus_dynamics.hrm_employee WHERE empID = ID LIMIT 1;
    ELSE
        SELECT accountname INTO nm FROM fin_subaccounts WHERE accountcode = ID;
    END IF;

    RETURN IF(nm IS NULL, '-', nm);
END$$

DELIMITER ;