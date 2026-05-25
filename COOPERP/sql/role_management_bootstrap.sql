-- ============================================================================
-- role_management_bootstrap.sql
-- Run ONCE after role_management_schema.sql has been executed.
-- Sets the first super admin user in sys_user_roles.
-- ============================================================================

-- IMPORTANT: Replace 'YOUR_ADMIN_USERNAME' with the actual admin membership
-- username from aspnet_Users. To find it:
--   SELECT UserName FROM aspnet_Users LIMIT 20;

SET @admin_username = 'YOUR_ADMIN_USERNAME';

INSERT IGNORE INTO sys_user_roles (username, role_id, granted_by, notes)
SELECT @admin_username, id, 'system', 'Initial super admin bootstrap — set at deployment'
FROM sys_roles
WHERE role_code = 'admin';

-- Verify the insert succeeded:
SELECT
    ur.username,
    r.role_name,
    r.role_code,
    ur.granted_at,
    ur.notes
FROM sys_user_roles ur
JOIN sys_roles r ON ur.role_id = r.id
WHERE ur.username = @admin_username;
