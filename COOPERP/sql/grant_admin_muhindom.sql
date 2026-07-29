-- Grant full admin (super) rights to Muhindo Mubaraka
-- Run this once against the campus_dynamics database.

-- Step 1: Confirm the membership username exists
-- (should return one row)
SELECT UserName FROM aspnet_Users
WHERE LOWER(UserName) IN ('muhindom', 'muhindom@mru.ac.ug', 'mm15022026it')
   OR LoweredUserName IN ('muhindom', 'muhindom@mru.ac.ug', 'mm15022026it');

-- Step 2: Confirm the admin role exists
SELECT id, role_code, role_name FROM sys_roles WHERE role_code = 'admin';

-- Step 3: Assign admin role to muhindom
--   ON DUPLICATE KEY UPDATE re-activates the row if it was previously revoked.
INSERT INTO sys_user_roles (username, role_id, assigned_by, is_active, notes)
SELECT
    'muhindom',
    id,
    'system',
    1,
    'Full admin — Muhindo Mubaraka, ICT Officer'
FROM sys_roles
WHERE role_code = 'admin'
ON DUPLICATE KEY UPDATE
    is_active   = 1,
    assigned_by = 'system',
    notes       = 'Full admin — Muhindo Mubaraka, ICT Officer',
    assigned_at = NOW();

-- Step 4: Verify
SELECT ur.username, r.role_code, r.role_name, ur.is_active, ur.assigned_at
FROM sys_user_roles ur
JOIN sys_roles r ON ur.role_id = r.id
WHERE ur.username = 'muhindom';
