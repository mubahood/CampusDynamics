-- ============================================================================
-- Fix: "Data too long for column 'user_id'" on student registration (and any
-- page logging an email-style username). 2026-06-26.
--
-- Root cause: campus_dynamics.acad_activity_log.user_id was CHAR(20). Usernames
-- are emails (e.g. 'kiwalabyejf@mru.ac.ug' = 21 chars). Under STRICT sql_mode the
-- over-length value ERRORS instead of silently truncating, aborting the INSERT
-- (NewStudentRegistration step 6d) and the whole registration.
-- (12,924 historic rows were already silently truncated at 20 chars.)
--
-- Fix: widen to VARCHAR(100) (covers emails; matches api_tokens.user_id width).
-- Safe widening ALTER — no data loss; all 221,680 rows preserved; NOT NULL kept.
-- Applied live 2026-06-26.
-- ============================================================================
ALTER TABLE campus_dynamics.acad_activity_log
    MODIFY user_id VARCHAR(100) NOT NULL;

-- App-side hardening (NewStudentRegistration.aspx.cs step 6d): the audit-log
-- INSERT is now wrapped in try/catch and the user_id capped to 100, so audit
-- logging can never abort or partially-commit a registration again.
