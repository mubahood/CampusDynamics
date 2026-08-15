-- =====================================================================
--  COURSE RECORDS CORRECTION CENTRE — schema
--
--  Two tables carry every correction ever made:
--    acad_correction_batch  one row per run (who / what / when / why)
--    acad_correction_row    one row per record touched, holding a COMPLETE
--                           before- and after-image so the change can be
--                           reversed later without this module's help.
--
--  Re-runnable: every statement is IF NOT EXISTS / INSERT ... ON DUPLICATE.
--  Engine InnoDB + charset utf8 to match campus_dynamics, so joins to
--  acad_student / acad_course stay index-backed.
-- =====================================================================
USE campus_dynamics;

CREATE TABLE IF NOT EXISTS acad_correction_batch (
    id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    batch_ref          VARCHAR(30)  NOT NULL,
    operation          VARCHAR(24)  NOT NULL,          -- COURSE_TRANSFER | TERM_TRANSFER | COURSE_MERGE | REVERSAL
    status             VARCHAR(24)  NOT NULL DEFAULT 'APPLIED',  -- APPLIED | REVERSED | PARTIALLY_REVERSED | FAILED
    source_code        CHAR(25)     NULL,
    target_code        CHAR(25)     NULL,
    source_year        CHAR(25)     NULL,
    target_year        CHAR(25)     NULL,
    source_semester    INT          NULL,
    target_semester    INT          NULL,
    config_json        LONGTEXT     NULL,
    scope_label        VARCHAR(200) NULL,
    rows_scanned       INT          NOT NULL DEFAULT 0,
    rows_applied       INT          NOT NULL DEFAULT 0,
    rows_skipped       INT          NOT NULL DEFAULT 0,
    students_affected  INT          NOT NULL DEFAULT 0,
    residual_rows      INT          NOT NULL DEFAULT 0,   -- records still on the old code afterwards
    tables_touched     VARCHAR(500) NULL,
    performed_by       VARCHAR(150) NOT NULL,
    performed_at       DATETIME     NOT NULL,
    performed_ip       VARCHAR(45)  NULL,
    reason             VARCHAR(400) NULL,
    duration_ms        INT          NOT NULL DEFAULT 0,
    reversed_by        VARCHAR(150) NULL,
    reversed_at        DATETIME     NULL,
    reverse_reason     VARCHAR(400) NULL,
    reverse_batch_ref  VARCHAR(30)  NULL,
    reverses_batch_id  BIGINT UNSIGNED NULL,             -- set when this batch IS a reversal
    notes              TEXT         NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_batch_ref (batch_ref),
    KEY ix_op_time  (operation, performed_at),
    KEY ix_status   (status),
    KEY ix_by       (performed_by),
    KEY ix_reverses (reverses_batch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS acad_correction_row (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    batch_id      BIGINT UNSIGNED NOT NULL,
    db_name       VARCHAR(64)  NOT NULL,
    table_name    VARCHAR(64)  NOT NULL,
    pk_column     VARCHAR(64)  NOT NULL,
    pk_value      VARCHAR(64)  NOT NULL,
    regno         VARCHAR(25)  NULL,
    course_code   VARCHAR(25)  NULL,
    action        VARCHAR(16)  NOT NULL,      -- UPDATE | INSERT | DELETE | SKIP
    verdict       VARCHAR(32)  NOT NULL,      -- MOVED | SKIPPED_DUPLICATE | SKIPPED_RESULT_CLASH | ...
    before_json   LONGTEXT     NULL,
    after_json    LONGTEXT     NULL,
    note          VARCHAR(300) NULL,
    reversed      TINYINT(1)   NOT NULL DEFAULT 0,
    reversed_at   DATETIME     NULL,
    PRIMARY KEY (id),
    KEY ix_batch   (batch_id),
    KEY ix_regno   (regno),
    KEY ix_target  (db_name, table_name, pk_value),
    KEY ix_verdict (verdict)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ---------------------------------------------------------------------
--  Navigation: one hub screen + one register screen, under Academics > Exam
-- ---------------------------------------------------------------------
INSERT INTO sys_menu_items (menu_slug, label, section, item_type, parent_slug, url, sort_order, is_active)
VALUES
 ('academics.exam.course_correction', 'Course Records Correction', 'academics', 'subitem', 'academics.exam',
  '~/COOPERP/NewScreens/CourseCorrectionCentre.aspx', 158, 1),
 ('academics.exam.correction_register', 'Correction Register', 'academics', 'subitem', 'academics.exam',
  '~/COOPERP/NewScreens/CourseCorrectionRegister.aspx', 159, 1)
ON DUPLICATE KEY UPDATE label=VALUES(label), url=VALUES(url), sort_order=VALUES(sort_order), is_active=1;

-- Grants: administrators, registrar, exam officers, deans and HODs.
-- (Course Code Merge is further restricted to administrators inside the page.)
INSERT INTO sys_role_permissions (role_id, menu_slug, can_view, can_edit, can_delete, granted_by)
SELECT r.id, m.slug, 1, 1, 0, 'course-correction-install'
  FROM sys_roles r
  JOIN (SELECT 'academics.exam.course_correction' slug
        UNION ALL SELECT 'academics.exam.correction_register') m
 WHERE r.role_code IN ('admin','registrar','exam_officer','dean','hod')
   AND NOT EXISTS (SELECT 1 FROM sys_role_permissions p WHERE p.role_id=r.id AND p.menu_slug=m.slug);

-- Widen on an existing install (PARTIALLY_REVERSED is 18 characters).
ALTER TABLE acad_correction_batch MODIFY status VARCHAR(24) NOT NULL DEFAULT 'APPLIED';

SELECT 'schema ready' AS status,
       (SELECT COUNT(*) FROM information_schema.tables
         WHERE table_schema='campus_dynamics' AND table_name IN ('acad_correction_batch','acad_correction_row')) AS tables_present,
       (SELECT COUNT(*) FROM sys_menu_items WHERE menu_slug LIKE 'academics.exam.co%') AS menu_rows,
       (SELECT COUNT(*) FROM sys_role_permissions WHERE menu_slug LIKE 'academics.exam.co%') AS grants;
