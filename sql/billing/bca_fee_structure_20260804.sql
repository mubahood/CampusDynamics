-- ============================================================================
--  BCA (Bachelor of Science in Agriculture) — 2026/2027 fee structure + billing.
--  2026-08-04. Follow-up to autoreg-cleanup-guardrail-selfheal.
--
--  PROBLEM: BCA is a NEW 2026 programme (faculty 01, level 3, 26 students, all Y1).
--  It had NO row in fin_programme_fees, so fin_AutoBillOnRegistration produced nothing
--  and every BCA student (incl. 4 who had already PAID) was left unbilled.
--
--  FEE DERIVATION (not fabricated): BSc Agriculture is a general-science bachelor
--  (not engineering, not computing). Every non-engineering / non-computing
--  "Bachelor of Science" programme at MRU charges the identical standard rate
--  (BSAF, BSCED, BSDE, BSPM all = Y1S1 630,000 tuition / 767,000 functional,
--   Y1S2 630,000 / 677,000; 3-year, has_year_4=No). It is also the modal bachelor
--  fee (28 programmes). Engineering = 1,455,000; computing/software = 780,000.
--  So BCA takes the standard BSc rate. We CLONE a clean reference row (BSAF) rather
--  than hand-type amounts.  ==> If finance wants a different (e.g. lab-premium)
--  agriculture rate, UPDATE this single row and re-run billing; it is easy to adjust.
--
--  Applied live 2026-08-04 (documented here for the record):
-- ----------------------------------------------------------------------------

-- 1) Create the BCA fee row by cloning the standard-BSc reference (BSAF).
INSERT INTO campus_dynamics_accounts.fin_programme_fees
 (progcode, has_year_1, y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional, y1_s3_tuition, y1_s3_functional,
  has_year_2, y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional, y2_s3_tuition, y2_s3_functional,
  has_year_3, has_year_4, y3_s1_tuition, y3_s1_functional, y3_s2_tuition, y3_s2_functional, y3_s3_tuition, y3_s3_functional,
  y4_s1_tuition, y4_s1_functional, y4_s2_tuition, y4_s2_functional, y4_s3_tuition, y4_s3_functional,
  is_active, created_at, updated_at, created_by)
 SELECT 'BCA', has_year_1, y1_s1_tuition, y1_s1_functional, y1_s2_tuition, y1_s2_functional, y1_s3_tuition, y1_s3_functional,
  has_year_2, y2_s1_tuition, y2_s1_functional, y2_s2_tuition, y2_s2_functional, y2_s3_tuition, y2_s3_functional,
  has_year_3, has_year_4, y3_s1_tuition, y3_s1_functional, y3_s2_tuition, y3_s2_functional, y3_s3_tuition, y3_s3_functional,
  y4_s1_tuition, y4_s1_functional, y4_s2_tuition, y4_s2_functional, y4_s3_tuition, y4_s3_functional,
  'Yes', NOW(), NOW(), 'std_BSc_clone_from_BSAF_20260804'
 FROM campus_dynamics_accounts.fin_programme_fees
 WHERE progcode='BSAF'
   AND NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_programme_fees x WHERE x.progcode='BCA');

-- 2) Bill the REGISTERED BCA Y1S1 students (fin_AutoBillOnRegistration only bills
--    regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED') — it deliberately skips
--    UNREGISTERED, which is a manual admin decision via BillingReconciliation.aspx).
--    Done for the 4 REGISTERED students: MRU2026005642, …742, …781, …788
--    -> each billed 1,397,000 (630,000 tuition + 767,000 functional).
--    CALL fin_AutoBillOnRegistration('<regno>','2026/2027',1,'<regno>');

-- 3) NOT auto-billed (regstatus=UNREGISTERED — registrar to review via the wizard):
--    MRU2026005129 (paid 20,000), MRU2026005418 (paid 520,000!), MRU2026005859 (paid 0).
