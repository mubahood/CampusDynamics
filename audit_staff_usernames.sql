-- ============================================================
--  Audit: staff with missing/dash usernames but valid EMP_CODE
-- ============================================================

-- 1. See all affected rows
SELECT empID, emp_name, EMP_CODE, usernames, emp_email
FROM campus_dynamics.hrm_employee
WHERE (usernames IS NULL OR TRIM(usernames) = '' OR TRIM(usernames) = '-')
  AND EMP_CODE IS NOT NULL AND TRIM(EMP_CODE) <> ''
ORDER BY empID DESC
LIMIT 100;

-- 2. Count
SELECT COUNT(*) AS staff_missing_usernames
FROM campus_dynamics.hrm_employee
WHERE (usernames IS NULL OR TRIM(usernames) = '' OR TRIM(usernames) = '-');
