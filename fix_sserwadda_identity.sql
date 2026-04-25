-- ============================================================
--  Fix: Dr Abubakhari Sserwadda identity (empID=252)
--  Problem 1: hrm_employee.usernames = '-' (dash placeholder)
--             → set to local-part of email so lookups work
--  Problem 2: portal my_aspnet_users.user_type = 'STUDENT'
--             → set to LECTURER
-- ============================================================

-- Step 1: Give Dr Sserwadda a real staff username key
UPDATE campus_dynamics.hrm_employee
SET    usernames = 'sserwaddaa'
WHERE  empID = 252
  AND  (usernames IS NULL OR TRIM(usernames) = '' OR TRIM(usernames) = '-');

-- Step 2: Fix portal account user_type
UPDATE campus_dynamics_portal.my_aspnet_users
SET    user_type = 'LECTURER'
WHERE  LOWER(TRIM(name)) = 'sserwaddaa@mru.ac.ug';

-- Verify
SELECT empID, emp_name, EMP_CODE, usernames, emp_email
FROM   campus_dynamics.hrm_employee
WHERE  empID = 252;

SELECT name, verified_email, user_type
FROM   campus_dynamics_portal.my_aspnet_users
WHERE  LOWER(TRIM(name)) = 'sserwaddaa@mru.ac.ug';
