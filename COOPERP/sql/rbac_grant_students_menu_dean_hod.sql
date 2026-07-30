-- ============================================================================
-- Grant the Students submenu (incl. Student Course Registration) to Dean + HOD
-- ----------------------------------------------------------------------------
-- eadmin RBAC gates sidebar visibility via sys_role_permissions(role_id, menu_slug,
-- can_view). Before this: HOD (role 43) could not see the Students submenu at all;
-- Dean (role 2) saw it but only 3 of 13 items and neither had Student Course
-- Registration. This grants the Students parent + every child to both roles.
--   Roles: 2 = dean, 43 = hod. Menu: academics.students (parent) + its 13 subitems.
-- Idempotent (ON DUPLICATE KEY UPDATE via uq_role_slug); menu visibility only.
-- ============================================================================
USE campus_dynamics;

-- Backup the two roles' current grants (restore point).
DROP TABLE IF EXISTS sys_role_permissions_bak_studmenu_20260730;
CREATE TABLE sys_role_permissions_bak_studmenu_20260730 AS
  SELECT * FROM sys_role_permissions WHERE role_id IN (2, 43);

-- Grant the Students parent + all its children (view) to Dean (2) and HOD (43).
INSERT INTO sys_role_permissions (role_id, menu_slug, can_view, granted_by, granted_at)
SELECT rid, mi.menu_slug, 1, 'mis-grant-students', NOW()
  FROM (SELECT 2 AS rid UNION ALL SELECT 43) roles
  JOIN sys_menu_items mi
    ON mi.menu_slug = 'academics.students' OR mi.parent_slug = 'academics.students'
ON DUPLICATE KEY UPDATE can_view = 1;

-- Belt-and-braces: make sure both keep the parent 'academics' heading (needed for the
-- group to render). Both already have it; this is a no-op safety net.
INSERT INTO sys_role_permissions (role_id, menu_slug, can_view, granted_by, granted_at)
SELECT rid, 'academics', 1, 'mis-grant-students', NOW()
  FROM (SELECT 2 AS rid UNION ALL SELECT 43) roles
ON DUPLICATE KEY UPDATE can_view = 1;

-- Verify: each role should now hold the parent + 13 children (14 rows).
SELECT p.role_id,
       SUM(p.menu_slug = 'academics.students')            AS has_parent,
       SUM(p.menu_slug LIKE 'academics.students.%')        AS children,
       MAX(p.menu_slug = 'academics.students.course_registration') AS has_course_reg
  FROM sys_role_permissions p
 WHERE p.role_id IN (2, 43) AND p.can_view = 1
   AND p.menu_slug LIKE 'academics.students%'
 GROUP BY p.role_id;

-- ---- ROLLBACK ----
-- DELETE FROM sys_role_permissions WHERE role_id IN (2,43);
-- INSERT INTO sys_role_permissions SELECT * FROM sys_role_permissions_bak_studmenu_20260730;
