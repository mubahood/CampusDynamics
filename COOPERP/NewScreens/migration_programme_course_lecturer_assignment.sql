-- ============================================================================
-- MIGRATION: Programme Course Lecturer Assignment
-- Run against: campus_dynamics
-- Date: 2026-04-17
-- Purpose:
--   Extend acad_programmecourses so each programme-course row can track
--   lecturer assignment status and active/inactive state.
-- ============================================================================

START TRANSACTION;

-- 1) Add columns (idempotent)
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'acad_programmecourses'
    AND COLUMN_NAME = 'is_lecturere_assigned'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE acad_programmecourses ADD COLUMN is_lecturere_assigned VARCHAR(3) NOT NULL DEFAULT ''No'' AFTER course_type',
  'SELECT ''is_lecturere_assigned already exists'''
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'acad_programmecourses'
    AND COLUMN_NAME = 'lecturer_id'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE acad_programmecourses ADD COLUMN lecturer_id INT(10) UNSIGNED NULL AFTER is_lecturere_assigned',
  'SELECT ''lecturer_id already exists'''
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Ensure lecturer_id datatype matches hrm_employee.empID (INT UNSIGNED)
ALTER TABLE acad_programmecourses
  MODIFY COLUMN lecturer_id INT(10) UNSIGNED NULL;

SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'acad_programmecourses'
    AND COLUMN_NAME = 'status'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE acad_programmecourses ADD COLUMN status VARCHAR(8) NOT NULL DEFAULT ''Active'' AFTER lecturer_id',
  'SELECT ''status already exists'''
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2) Normalize existing data for integrity
UPDATE acad_programmecourses
SET is_lecturere_assigned = CASE
      WHEN UPPER(IFNULL(is_lecturere_assigned,'')) = 'YES' THEN 'Yes'
      ELSE 'No'
    END,
    status = CASE
      WHEN UPPER(IFNULL(status,'')) = 'INACTIVE' THEN 'Inactive'
      ELSE 'Active'
    END;

-- If assignment says "No", lecturer_id must be NULL
UPDATE acad_programmecourses
SET lecturer_id = NULL
WHERE IFNULL(is_lecturere_assigned,'No') <> 'Yes';

-- If lecturer_id points to non-existing employee, clear it and set to No
UPDATE acad_programmecourses pc
LEFT JOIN hrm_employee e ON e.empID = pc.lecturer_id
SET pc.lecturer_id = NULL,
    pc.is_lecturere_assigned = 'No'
WHERE pc.lecturer_id IS NOT NULL
  AND e.empID IS NULL;

-- 3) Add supporting index (idempotent)
SET @idx_exists := (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'acad_programmecourses'
    AND INDEX_NAME = 'idx_programmecourses_lecturer_id'
);
SET @sql := IF(
  @idx_exists = 0,
  'ALTER TABLE acad_programmecourses ADD INDEX idx_programmecourses_lecturer_id (lecturer_id)',
  'SELECT ''idx_programmecourses_lecturer_id already exists'''
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 4) Add foreign key relationship (idempotent)
SET @fk_exists := (
  SELECT COUNT(*)
  FROM information_schema.REFERENTIAL_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE()
    AND CONSTRAINT_NAME = 'fk_programmecourses_lecturer'
);
SET @sql := IF(
  @fk_exists = 0,
  'ALTER TABLE acad_programmecourses
     ADD CONSTRAINT fk_programmecourses_lecturer
     FOREIGN KEY (lecturer_id)
     REFERENCES hrm_employee(empID)
     ON UPDATE CASCADE
     ON DELETE SET NULL',
  'SELECT ''fk_programmecourses_lecturer already exists'''
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

COMMIT;
