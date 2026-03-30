-- =====================================================================
-- Migration: Change scholarships from percentage to fixed-amount bursary
-- Date: 2026-03-29
-- =====================================================================

-- 1. Add bursary_amount column to scholarships table
ALTER TABLE campus_dynamics_accounts.scholarships
    ADD COLUMN bursary_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00
    COMMENT 'Fixed bursary amount (UGX) awarded per semester'
    AFTER percentagePay;

-- 2. Migrate existing percentage data to amount (if any rows have percentagePay values)
--    This is a one-off; percentage concept is being retired.
--    You may want to manually set proper amounts after migration.
-- UPDATE campus_dynamics_accounts.scholarships SET bursary_amount = percentagePay WHERE percentagePay > 0;

-- 3. Ensure academicbillingitems has a "Bursary" item for fee transactions
-- Check if it exists first:
INSERT INTO campus_dynamics_accounts.academicbillingitems (ItemCode, ItemName)
SELECT 999, 'Bursary/Scholarship'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM campus_dynamics_accounts.academicbillingitems 
    WHERE ItemName LIKE '%Bursary%' OR ItemName LIKE '%Scholarship%'
);

-- Show current billing items to find the correct code:
-- SELECT ItemCode, ItemName FROM campus_dynamics_accounts.academicbillingitems ORDER BY ItemCode;
