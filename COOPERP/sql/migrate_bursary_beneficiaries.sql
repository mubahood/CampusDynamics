-- ============================================================================
-- BURSARY BENEFICIARY MIGRATION
-- Date: 2026-03-29
-- Purpose: Create scholarshipstudents records for all students who were
--          charged "Late Bursary renewal" (item_code=62) — proof they are
--          bursary holders.
--
-- INVESTIGATION FINDINGS:
-- ============================================================================
-- 1. fin_studentfeestracking has 135 "Late Bursary renewal" charges
--    across 117 unique students, spanning 2022/2023 to 2025/2026.
-- 2. NO bursary PAYMENT/CREDIT transactions exist in the system.
-- 3. acad_studetsponsors, otherstudent_info, applic_form — no bursary mappings.
-- 4. There is NO data linking individual students to specific schemes.
--
-- DECISION:
-- Since "Late Bursary renewal" is a university-internal charge, and
-- there is no scheme mapping, we assign all to scheme ID=7 ("MRU —
-- Muteesa University Bursary", UGX 1,300,000) as the default.
-- The admin can later reassign individual students to correct schemes
-- (KEF, SAZZA, DISTRICT, etc.) via the UI.
--
-- RULES ENFORCED:
-- - Each record is: 1 student + 1 semester + 1 academic year + 1 scheme
-- - Study year = (academic_year_start - admission_year) + 1
-- - amount_offered = scheme's bursary_amount (1,300,000)
-- - status = 'Approved' (they were already approved — the late renewal
--   charge proves they were active bursary holders)
-- - transaction_ref = TID of the Late Bursary renewal charge (links records)
-- - notes = descriptive narration
-- - Existing record for MRU2023000990 (stid=1) is excluded
-- - NO new fee transactions created — the late bursary charges are BILLS
--   (debits to the student), NOT bursary credits. Creating fictitious
--   payment credits would falsely reduce student balances.
-- ============================================================================

-- Step 1: Create a temporary staging table with computed values
DROP TEMPORARY TABLE IF EXISTS tmp_bursary_staging;

CREATE TEMPORARY TABLE tmp_bursary_staging AS
SELECT
    f.regno                                                        AS adm_no,
    7                                                              AS scholarshipID,
    f.semester                                                     AS scholarhipTerm,
    f.acadyear                                                     AS scholarhipYear,
    0                                                              AS amountDue,
    1300000                                                        AS amount_offered,
    f.TID                                                          AS transaction_ref,
    'Approved'                                                     AS status,
    f.trans_date                                                   AS date_added,
    CONCAT(
        'Migrated from Late Bursary renewal charge (TID:',
        f.TID,
        '). Scheme: MRU Bursary. Yr ',
        CAST(SUBSTRING(f.acadyear,1,4) AS UNSIGNED)
            - CAST(SUBSTRING(f.regno,4,4) AS UNSIGNED) + 1,
        ' Sem ', f.semester,
        ' of ', f.acadyear, '.'
    )                                                              AS notes
FROM fin_studentfeestracking f
WHERE f.item_code = 62
  -- Exclude the one already-existing beneficiary record
  AND NOT EXISTS (
      SELECT 1 FROM scholarshipstudents ss
      WHERE ss.adm_no        = f.regno
        AND ss.scholarhipYear = f.acadyear
        AND ss.scholarhipTerm = f.semester
  )
ORDER BY f.regno, f.acadyear, f.semester;

-- Step 2: Verify staging count before insert
SELECT COUNT(*) AS records_to_insert FROM tmp_bursary_staging;

-- Step 3: Insert into scholarshipstudents
INSERT INTO scholarshipstudents
    (adm_no, scholarshipID, scholarhipTerm, scholarhipYear,
     amountDue, amount_offered, transaction_ref, status, date_added, notes)
SELECT
    adm_no, scholarshipID, scholarhipTerm, scholarhipYear,
    amountDue, amount_offered, transaction_ref, status, date_added, notes
FROM tmp_bursary_staging;

-- Step 4: Verify final state
SELECT COUNT(*) AS total_beneficiary_records FROM scholarshipstudents;

SELECT
    ss.scholarhipYear,
    ss.scholarhipTerm AS sem,
    COUNT(*)          AS records,
    SUM(ss.amount_offered) AS total_amount
FROM scholarshipstudents ss
GROUP BY ss.scholarhipYear, ss.scholarhipTerm
ORDER BY ss.scholarhipYear, ss.scholarhipTerm;

DROP TEMPORARY TABLE IF EXISTS tmp_bursary_staging;
