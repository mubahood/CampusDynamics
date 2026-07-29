-- ============================================================================
-- Retake Registration — schema migration (idempotent, additive)
-- Applied 2026-06-30. Run order: this file, then the 4 *.sql stored procedures
-- in this folder (acad_CreateTranscript, acad_GetSingleStudentTranscript_Col1/_Col2,
-- acad_GetStudentTranscript) which add the "(RT)" transcript marker.
-- ============================================================================

-- 1) Independent retake tracking record (snapshot of the original attempt)
CREATE TABLE IF NOT EXISTS campus_dynamics_portal.acad_retake_registrations (
  ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
  regno VARCHAR(25) NOT NULL,
  courseID VARCHAR(25) NOT NULL,
  course_name VARCHAR(150) NULL,
  prog_id VARCHAR(25) NULL,
  credit_units DOUBLE NULL,
  retake_acad_year VARCHAR(25) NOT NULL,
  retake_semester INT NOT NULL,
  retake_study_year INT NULL,
  course_reg_id INT NULL,                 -- FK -> acad_course_registration.ID (the new RETAKE row)
  orig_acad_year VARCHAR(25) NULL,
  orig_semester INT NULL,
  orig_study_year INT NULL,
  orig_course_work INT NULL,
  orig_exam INT NULL,
  orig_total INT NULL,
  orig_grade VARCHAR(5) NULL,
  orig_gradept DOUBLE NULL,
  orig_result_id INT NULL,
  attempt_no INT NOT NULL DEFAULT 2,
  retake_fee DOUBLE NOT NULL DEFAULT 50000,
  fee_tid INT NULL,                       -- fin_studentfeestracking.TID of the 50k bill
  fee_billed ENUM('Yes','No') NOT NULL DEFAULT 'No',
  status VARCHAR(20) NOT NULL DEFAULT 'REGISTERED',  -- REGISTERED|COMPLETED|CANCELLED
  new_total INT NULL,
  new_grade VARCHAR(5) NULL,
  new_gradept DOUBLE NULL,
  registered_by VARCHAR(45) NULL,
  registered_at DATETIME NULL,
  notes VARCHAR(500) NULL,
  PRIMARY KEY (ID),
  KEY ix_rr_regno (regno),
  KEY ix_rr_course (courseID),
  KEY ix_rr_regid (course_reg_id),
  UNIQUE KEY ux_rr_active (regno, courseID, retake_acad_year, retake_semester)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2) Tag the registration row as a retake (type RT) + back-link to the tracking record.
--    (Run guarded — these are additive; drop the columns to reverse.)
ALTER TABLE campus_dynamics_portal.acad_course_registration
  ADD COLUMN registration_type VARCHAR(10) NOT NULL DEFAULT 'NORMAL';
ALTER TABLE campus_dynamics_portal.acad_course_registration
  ADD COLUMN retake_registration_id INT NULL;

-- 3) Mark published retake results so the transcript can show RT.
ALTER TABLE campus_dynamics.acad_results
  ADD COLUMN is_retake TINYINT(1) NOT NULL DEFAULT 0;

-- 4) Carry the retake flag into the materialised transcript table.
ALTER TABLE campus_dynamics.acad_transcript_results
  ADD COLUMN is_retake TINYINT(1) NOT NULL DEFAULT 0;

-- Billing: the 50,000 retake fee uses the EXISTING item academicbillingitems
--   ItemCode 21 = 'Retake fee', revenue account AC6016. No new item needed.

-- 5) FIX (2026-06-30): acad_transcript_results.result_comment was latin1 but the source
--    acad_results.result_comment is utf8 — acad_CreateTranscript threw on any Unicode
--    char (e.g. '→'). Widen target to utf8 so the copy never fails. (Pre-existing bug.)
ALTER TABLE campus_dynamics.acad_transcript_results MODIFY result_comment TEXT CHARACTER SET utf8;
