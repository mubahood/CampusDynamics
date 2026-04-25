-- ============================================================
--  BULK FIX: 75 staff with usernames='-' and bogus placeholder email
--  Root cause: bulk HR import set usernames='-' and emp_email='sserwaddaa@mru.ac.ug'
--              as placeholders for all un-configured staff rows.
--  Safe approach: set usernames = EMP_CODE for all dash rows (unique per staff)
--                 clear the bogus placeholder email only where it is wrong.
--  Run: 2026-04-20
-- ============================================================

-- Step 1: Set usernames = EMP_CODE for every row where username is dash/empty/null
--         but EMP_CODE is populated.  empID 252 (Dr Sserwadda) already fixed.
UPDATE campus_dynamics.hrm_employee
SET    usernames = TRIM(EMP_CODE)
WHERE  (usernames IS NULL OR TRIM(usernames) = '' OR TRIM(usernames) = '-')
  AND  EMP_CODE IS NOT NULL
  AND  TRIM(EMP_CODE) <> ''
  AND  TRIM(EMP_CODE) <> '-';

-- Step 2: Clear the bogus placeholder email for every row that:
--   a) still has sserwaddaa@mru.ac.ug as the email, AND
--   b) is NOT empID 252 (Dr Sserwadda's real record)
--   We set it to NULL so it doesn't pollute email-based lookups.
UPDATE campus_dynamics.hrm_employee
SET    emp_email = ''
WHERE  LOWER(TRIM(IFNULL(emp_email,''))) = 'sserwaddaa@mru.ac.ug'
  AND  empID <> 252;

-- Step 3: Verify counts
SELECT
  SUM(CASE WHEN usernames IS NULL OR TRIM(usernames)='' OR TRIM(usernames)='-' THEN 1 ELSE 0 END) AS still_missing_username,
  SUM(CASE WHEN LOWER(TRIM(emp_email))='sserwaddaa@mru.ac.ug' THEN 1 ELSE 0 END) AS bogus_email_rows
FROM campus_dynamics.hrm_employee;

-- Step 4: Spot-check the previously affected rows
SELECT empID, emp_name, EMP_CODE, usernames, IF(emp_email='','(cleared)',emp_email) AS emp_email
FROM campus_dynamics.hrm_employee
WHERE empID IN (252,314,308,310,305,316,315)
ORDER BY empID;
