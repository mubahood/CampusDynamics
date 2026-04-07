-- ============================================================================
-- TEST SCRIPT: Bill Waiver Module Verification
-- Student: MRU2027000002 (Sabia)
-- Database: campus_dynamics_accounts
--
-- Run this AFTER the migration_bill_waivers.sql migration.
--
-- Steps:
--   1. Create test bills for MRU2027000002
--   2. Verify bills appear in the system
--   3. After applying a waiver through the UI, run the verification queries
-- ============================================================================

-- ── STEP 1: Check existing bills for MRU2027000002 ─────────────────────

SELECT 'EXISTING BILLS FOR MRU2027000002' AS section;
SELECT TID, regno, amount, trans_type, detail, trans_date, acadyear, semester, post_status
FROM fin_studentfeestracking
WHERE regno = 'MRU2027000002' AND trans_type = 'Bill'
ORDER BY trans_date DESC;

-- ── STEP 2: Create test bills (only if none exist yet) ─────────────────
-- These are Tuition (item_code=1) and Function Fees (item_code=2) bills.

INSERT INTO fin_studentfeestracking
    (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
VALUES
    ('MRU2027000002', 1, '2026/2027', 630000, 1, 'Bill', 'Tuition Fees Sem :1, 2026/2027: MRU2027000002 [Test Bill]', NOW(), 'Posted'),
    ('MRU2027000002', 1, '2026/2027', 663000, 2, 'Bill', 'Function Fees Sem :1, 2026/2027: MRU2027000002 [Test Bill]', NOW(), 'Posted'),
    ('MRU2027000002', 1, '2026/2027', 630000, 1, 'Bill', 'Tuition Fees Sem :1, 2026/2027: MRU2027000002 [DUPLICATE - Test Double Bill]', NOW(), 'Posted');

-- Also create mirrored GL entries (dual-write) for the test bills
-- Get the TIDs of the bills we just created
SET @tid1 = LAST_INSERT_ID();
SET @tid2 = @tid1 + 1;
SET @tid3 = @tid1 + 2;

INSERT INTO fin_ledger
    (accountcode, account_type, transactionType, transaction_amount, particulars,
     voucherNo, transactionDate, teller, timeLog, folio,
     journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
VALUES
    ('MRU2027000002', 'Student', 'DR', 630000, 'Tuition Fees Sem :1, 2026/2027: MRU2027000002 [Test Bill]',
     @tid1, CURDATE(), 'TestScript', NOW(), 'MRU2027000002', '-', 'UGX', 630000, 0, 1, 630000),
    ('MRU2027000002', 'Student', 'DR', 663000, 'Function Fees Sem :1, 2026/2027: MRU2027000002 [Test Bill]',
     @tid2, CURDATE(), 'TestScript', NOW(), 'MRU2027000002', '-', 'UGX', 663000, 0, 1, 663000),
    ('MRU2027000002', 'Student', 'DR', 630000, 'Tuition Fees Sem :1, 2026/2027: MRU2027000002 [DUPLICATE - Test Double Bill]',
     @tid3, CURDATE(), 'TestScript', NOW(), 'MRU2027000002', '-', 'UGX', 630000, 0, 1, 630000);

SELECT 'TEST BILLS CREATED' AS result, @tid1 AS tid_tuition, @tid2 AS tid_function, @tid3 AS tid_duplicate;


-- ════════════════════════════════════════════════════════════════════════
-- POST-WAIVER VERIFICATION QUERIES
-- Run these AFTER applying a waiver through the Bill Waivers wizard UI
-- ════════════════════════════════════════════════════════════════════════

-- ── V1: Check waivers created ──────────────────────────────────────────
SELECT 'V1: WAIVERS' AS verification;
SELECT w.waiver_id, w.regno, w.waiver_category, w.waiver_reason,
       w.total_amount, w.credit_tid, w.credit_gl_tid, w.status, w.created_by,
       w.created_at
FROM fin_bill_waivers w
WHERE w.regno = 'MRU2027000002'
ORDER BY w.created_at DESC;

-- ── V2: Check waiver line items ────────────────────────────────────────
SELECT 'V2: WAIVER ITEMS' AS verification;
SELECT wi.item_id, wi.waiver_id, wi.original_tid, wi.bill_amount, wi.waived_amount, wi.bill_detail
FROM fin_bill_waiver_items wi
INNER JOIN fin_bill_waivers w ON w.waiver_id = wi.waiver_id
WHERE w.regno = 'MRU2027000002';

-- ── V3: Check credit transaction was created ───────────────────────────
SELECT 'V3: CREDIT TRANSACTION IN TRACKING' AS verification;
SELECT TID, regno, amount, trans_type, detail, trans_date, post_status
FROM fin_studentfeestracking
WHERE regno = 'MRU2027000002' AND detail LIKE 'Bill Waiver%';

-- ── V4: Check GL credit entry was created ──────────────────────────────
SELECT 'V4: GL CREDIT ENTRY' AS verification;
SELECT TID, accountcode, transactionType, transaction_amount, particulars, voucherNo, transactionDate
FROM fin_ledger
WHERE accountcode = 'MRU2027000002' AND particulars LIKE 'Bill Waiver%';

-- ── V5: Full student balance check ─────────────────────────────────────
SELECT 'V5: STUDENT BALANCE' AS verification;
SELECT
    SUM(CASE WHEN trans_type = 'Bill' THEN amount ELSE 0 END) AS total_billed,
    SUM(CASE WHEN trans_type = 'Payment' THEN amount ELSE 0 END) AS total_paid,
    SUM(CASE WHEN trans_type = 'Bill' THEN amount ELSE 0 END)
    - SUM(CASE WHEN trans_type = 'Payment' THEN amount ELSE 0 END) AS balance
FROM fin_studentfeestracking
WHERE regno = 'MRU2027000002' AND post_status = 'Posted';

-- ── V6: GL balance check ───────────────────────────────────────────────
SELECT 'V6: GL BALANCE' AS verification;
SELECT
    SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) AS total_dr,
    SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS total_cr,
    SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END)
    - SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS gl_balance
FROM fin_ledger
WHERE accountcode = 'MRU2027000002';

-- ════════════════════════════════════════════════════════════════════════
-- EXPECTED RESULTS AFTER WAIVING THE DUPLICATE BILL (TID @tid3, 630,000):
--
-- V1: 1 waiver record with status='Active', total_amount=630000
-- V2: 1 waiver item linking original_tid to @tid3
-- V3: 1 Payment record for 630,000 with detail='Bill Waiver (Double Billing): ...'
-- V4: 1 CR GL entry for 630,000 matching the credit_tid
-- V5: total_billed=1,923,000 (3 bills), total_paid=630,000 (waiver credit), balance=1,293,000
-- V6: total_dr=1,923,000, total_cr=630,000, gl_balance=1,293,000
--
-- The waiver credit of 630,000 offsets the duplicate 630,000 bill exactly.
-- Student now owes: Tuition 630,000 + Function 663,000 = 1,293,000
-- ════════════════════════════════════════════════════════════════════════
