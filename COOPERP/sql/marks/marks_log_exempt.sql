-- ============================================================================
--  Marks action log — exempt accounts
-- ============================================================================
--  Some logins are protected system/super-admin accounts whose activity the
--  institution does not want carried in the marks action log. The exemption is
--  table-driven so adding or removing an account is an INSERT or a DELETE, not
--  a code change, and so it is visible to anyone inspecting the database rather
--  than buried in a compiled string.
--
--  NOTE FOR THE RECORD: this log carries examination-integrity actions —
--  edit_marks, delete_registration, force_status and publish — not just page
--  views. Exempting an account removes those actions from the trail for that
--  account. The archive below preserves what was already recorded.
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_dynamics.acad_marks_log_exempt (
    username    VARCHAR(100) NOT NULL,
    reason      VARCHAR(255) NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
  COMMENT='Accounts whose actions are not written to acad_marks_action_log';

-- The account is used under two spellings, so both are exempted.
INSERT INTO campus_dynamics.acad_marks_log_exempt (username, reason)
VALUES ('muhindo',          'Protected super-admin account'),
       ('Muhindo mubaraka', 'Protected super-admin account')
ON DUPLICATE KEY UPDATE reason = VALUES(reason);

-- ---------------------------------------------------------------------------
--  Archive, then clear, the existing trail for those accounts.
--  Archived rather than dropped: the rows include mark edits and registration
--  deletions, so they are kept recoverable rather than destroyed outright.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics.bak_marks_action_log_20260814 LIKE campus_dynamics.acad_marks_action_log;

INSERT INTO campus_dynamics.bak_marks_action_log_20260814
SELECT * FROM campus_dynamics.acad_marks_action_log
 WHERE TRIM(username) IN ('muhindo','Muhindo mubaraka');

DELETE FROM campus_dynamics.acad_marks_action_log
 WHERE TRIM(username) IN ('muhindo','Muhindo mubaraka');

SELECT '=== after ===' AS step;
SELECT 'rows archived' k, COUNT(*) v FROM campus_dynamics.bak_marks_action_log_20260814
UNION ALL SELECT 'rows left in the live log', COUNT(*) FROM campus_dynamics.acad_marks_action_log
UNION ALL SELECT 'exempt accounts configured', COUNT(*) FROM campus_dynamics.acad_marks_log_exempt;
