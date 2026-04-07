-- =============================================================================
-- Campus Dynamics — Marks Management System
-- Performance Index Migration (H-03)
-- Run once against campus_dynamics schema.
-- All statements use IF NOT EXISTS / IF EXISTS so the script is re-runnable.
-- =============================================================================

USE campus_dynamics;

-- ---------------------------------------------------------------------------
-- acad_examresults_faculty  (primary marks store)
-- The hottest read path: load a sheet for a given course / prog / year context
-- ---------------------------------------------------------------------------

-- Composite index that covers the full eight-column sheet-context filter used
-- by MarksSheetService.LoadSheet and MarksSheetSyncService.SyncRegistrations.
ALTER TABLE acad_examresults_faculty
    ADD INDEX IF NOT EXISTS idx_marks_sheet_context
    (course_id, progid, acad_year, semester, study_year, campus, stud_session);

-- Secondary index for per-student queries (audit trail look-ups, reconciliation)
ALTER TABLE acad_examresults_faculty
    ADD INDEX IF NOT EXISTS idx_marks_regno_year
    (regno, acad_year);

-- Covering index used by the grade-distribution aggregation in TeacherDashboard
ALTER TABLE acad_examresults_faculty
    ADD INDEX IF NOT EXISTS idx_marks_grade_context
    (course_id, progid, acad_year, semester, study_year, campus, stud_session, grade);

-- ---------------------------------------------------------------------------
-- acad_marks_audit  (audit trail; append-only, high-volume)
-- AuditCentre paging relies on date-range and course/user filters.
-- ---------------------------------------------------------------------------

-- Date-ordered paging (primary sort column for AuditCentre)
ALTER TABLE acad_marks_audit
    ADD INDEX IF NOT EXISTS idx_audit_date
    (change_date);

-- Course + year filter (most common search combination in AuditCentre)
ALTER TABLE acad_marks_audit
    ADD INDEX IF NOT EXISTS idx_audit_course_year
    (course_id, acad_year);

-- Auditor look-up (filter by who made the change)
ALTER TABLE acad_marks_audit
    ADD INDEX IF NOT EXISTS idx_audit_user
    (changed_by);

-- Student look-up across audit history
ALTER TABLE acad_marks_audit
    ADD INDEX IF NOT EXISTS idx_audit_student
    (student_id);

-- ---------------------------------------------------------------------------
-- acad_marks_deadlines  (small table — one row per course context per sy/sem)
-- MarksDeadlineService reads by partial context; a composite helps.
-- ---------------------------------------------------------------------------

ALTER TABLE acad_marks_deadlines
    ADD INDEX IF NOT EXISTS idx_deadline_context
    (course_id, progid, acad_year, semester);

-- ---------------------------------------------------------------------------
-- acad_marks_locks  (locking table — queried on every sheet open / save)
-- ---------------------------------------------------------------------------

ALTER TABLE acad_marks_locks
    ADD INDEX IF NOT EXISTS idx_lock_context
    (course_id, progid, acad_year, semester, study_year, campus, stud_session, lock_type);

-- ---------------------------------------------------------------------------
-- acad_registration  (source of truth for enrollment sync)
-- MarksSheetSyncService joins this table on the full context.
-- ---------------------------------------------------------------------------

ALTER TABLE acad_registration
    ADD INDEX IF NOT EXISTS idx_reg_sync_context
    (progcode, acad_year, semester, campusid, studysession, study_year);

-- ---------------------------------------------------------------------------
-- acad_marks_action_log  (structured action log — G-03)
-- Queried by course, user, and date range in future reporting.
-- ---------------------------------------------------------------------------

ALTER TABLE acad_marks_action_log
    ADD INDEX IF NOT EXISTS idx_action_log_date
    (action_time);

ALTER TABLE acad_marks_action_log
    ADD INDEX IF NOT EXISTS idx_action_log_course
    (course_id, acad_year);

ALTER TABLE acad_marks_action_log
    ADD INDEX IF NOT EXISTS idx_action_log_user
    (performed_by);

-- =============================================================================
-- End of migration
-- =============================================================================
