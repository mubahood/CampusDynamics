-- =============================================================================
-- GRADUATE THESIS / SUPERVISOR INTEGRATION — Migration Script
-- =============================================================================
-- Purpose: Ensures the existing acad_graduate_research table has proper
--          thesis tracking columns, and updates the transcript stored procedure
--          to include thesis_title and supervisor_name in its output.
--
-- Run this against the campus_dynamics database.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Add thesis_title column to acad_graduate_research if it doesn't exist
--    (The res_topic column already serves as the research topic. thesis_title
--     is a formal, separate field for the exact title on the certificate.)
-- ---------------------------------------------------------------------------
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'acad_graduate_research'
      AND COLUMN_NAME  = 'thesis_title');

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE acad_graduate_research ADD COLUMN thesis_title VARCHAR(500) NULL DEFAULT NULL AFTER res_topic',
    'SELECT ''Column thesis_title already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- ---------------------------------------------------------------------------
-- 2. Back-fill thesis_title from res_topic where thesis_title is NULL
--    (preserves existing data for students who already have a research topic)
-- ---------------------------------------------------------------------------
UPDATE acad_graduate_research
   SET thesis_title = res_topic
 WHERE thesis_title IS NULL
   AND res_topic IS NOT NULL
   AND TRIM(res_topic) != '';


-- ---------------------------------------------------------------------------
-- 3. Add an index on (regno) for fast lookups from the transcript query
-- ---------------------------------------------------------------------------
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'acad_graduate_research'
      AND INDEX_NAME   = 'idx_grad_research_regno');

SET @sql = IF(@idx_exists = 0,
    'ALTER TABLE acad_graduate_research ADD INDEX idx_grad_research_regno (regno)',
    'SELECT ''Index idx_grad_research_regno already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- ---------------------------------------------------------------------------
-- 4. Update the acad_GetBatchStudentTranscriptData stored procedure
--    to include thesis_title and supervisor_name via LEFT JOINs.
--
--    NOTE: If you cannot modify this stored procedure, the application
--    code (CertificateDataHelper / GraduateHelper) will fall back to
--    querying these columns directly. But including them here is the
--    cleanest approach.
-- ---------------------------------------------------------------------------
-- To keep this migration safe, we do NOT DROP the existing proc.
-- Instead, run this ALTER or re-CREATE as appropriate for your environment.
--
-- Example of the columns to add to the SELECT list of the stored procedure:
--
--   SELECT
--       ... existing columns ...,
--       IFNULL(gr.thesis_title, IFNULL(gr.res_topic, '')) AS thesis_title,
--       IFNULL(sv.supervior_name, '') AS supervisor_name
--   FROM acad_graduands g
--   LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(g.regno)
--   ... existing joins ...
--   LEFT JOIN acad_graduate_research gr ON TRIM(gr.regno) = TRIM(g.regno)
--   LEFT JOIN acad_superviors sv ON sv.Id = gr.supervior_id
--   ... existing WHERE clause ...
--
-- ---------------------------------------------------------------------------

-- Verification query — run this to confirm the migration worked:
-- SELECT gr.regno, gr.thesis_title, gr.res_topic, sv.supervior_name
-- FROM acad_graduate_research gr
-- LEFT JOIN acad_superviors sv ON sv.Id = gr.supervior_id
-- LIMIT 20;
