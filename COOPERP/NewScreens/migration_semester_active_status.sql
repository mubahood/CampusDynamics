-- =============================================================
--  Migration: Semester Active Status columns
--  Purpose:   Allows admins to mark each semester of an academic
--             year as Active or Inactive. Registration is blocked
--             in inactive semesters.
--  Table:     campus_dynamics.acad_acadyears
--  Date:      2026-03-25
-- =============================================================

ALTER TABLE `campus_dynamics`.`acad_acadyears`
    ADD COLUMN `semester_1_is_active` ENUM('Yes','No') NOT NULL DEFAULT 'No'
        COMMENT 'Whether Semester 1 is currently open for registration'
        AFTER `semester_count`,
    ADD COLUMN `semester_2_is_active` ENUM('Yes','No') NOT NULL DEFAULT 'No'
        COMMENT 'Whether Semester 2 is currently open for registration'
        AFTER `semester_1_is_active`,
    ADD COLUMN `semester_3_is_active` ENUM('Yes','No') NOT NULL DEFAULT 'No'
        COMMENT 'Whether Semester 3 is currently open for registration'
        AFTER `semester_2_is_active`;

-- Verify the change
SELECT ID, acadyear, semester_count,
       semester_1_is_active, semester_2_is_active, semester_3_is_active
FROM `campus_dynamics`.`acad_acadyears`
ORDER BY acadyear DESC
LIMIT 10;
