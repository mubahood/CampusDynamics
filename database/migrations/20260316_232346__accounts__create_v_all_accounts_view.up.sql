-- Migration: create_v_all_accounts_view
-- Logical database: accounts
-- Generated: 2026-03-16T23:23:46
-- E4: Create v_all_accounts view
--
-- Provides a single lookup source for ALL valid account codes:
--   1. Chart accounts from fin_subaccounts (AC1xxx, AC2xxx, AC6xxx, etc.)
--   2. Student accounts from campus_dynamics.acad_student (MRUxxxx format)
--
-- This resolves the 68,058 "orphan account codes" finding where student
-- IDs appear in fin_ledger.accountcode but not in fin_subaccounts,
-- because student IDs are stored in the main database by design.
--
-- Usage:
--   SELECT * FROM v_all_accounts WHERE account_code = 'MRU2024001';
--   SELECT * FROM v_all_accounts WHERE account_source = 'CHART';
--
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

CREATE OR REPLACE VIEW v_all_accounts AS

-- Chart of accounts (AC1xxx, AC2xxx, AC6xxx, AC7xxx, AC9xxx)
SELECT
    s.AccountCode       AS account_code,
    s.AccountName       AS account_name,
    s.MainAccountCode   AS main_account_code,
    s.accounttype       AS account_type,
    s.collectionLedgerType AS ledger_type,
    'CHART'             AS account_source
FROM fin_subaccounts s

UNION ALL

-- Student accounts (MRUxxxx) from the main database
SELECT
    TRIM(st.regno)                                      AS account_code,
    TRIM(CONCAT(
        IFNULL(st.firstname, ''),
        CASE WHEN TRIM(IFNULL(st.othername, '')) != ''
             THEN CONCAT(' ', TRIM(st.othername))
             ELSE ''
        END
    ))                                                  AS account_name,
    'STUDENT'                                           AS main_account_code,
    'Student Account'                                   AS account_type,
    IFNULL(p.progname, 'Unknown Programme')             AS ledger_type,
    'STUDENT'                                           AS account_source
FROM campus_dynamics.acad_student st
LEFT JOIN campus_dynamics.acad_programme p
    ON TRIM(st.progid) = TRIM(p.progcode)
WHERE TRIM(IFNULL(st.regno, '')) != '';
