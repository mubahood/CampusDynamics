-- ============================================================
-- OmniPass ID Card Status — Schema Migration
-- Run once on the campus_dynamics database
-- ============================================================

ALTER TABLE acad_student
  ADD COLUMN IF NOT EXISTS id_card_status      VARCHAR(30)  DEFAULT NULL COMMENT 'PRINTED | NOT_PRINTED | NOT_FOUND | ERROR | UNKNOWN',
  ADD COLUMN IF NOT EXISTS id_card_checked_at  DATETIME     DEFAULT NULL COMMENT 'Last OmniPass API check timestamp';

-- Index for admin queries that filter by status
CREATE INDEX IF NOT EXISTS idx_student_card_status ON acad_student (id_card_status);
