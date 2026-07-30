-- ============================================================================
-- StudentsRegistration.aspx — recovery backup tables for the rich delete flow
-- ----------------------------------------------------------------------------
-- The semester-registration delete can optionally remove the semester's courses and
-- fee bills/payments (+ GL mirror). fin_ledger is MyISAM (non-transactional), so before
-- ANY delete the affected rows are copied into these *_regdel_bak tables — the recovery
-- guarantee. Created as column-only copies (no keys) so appends never hit a constraint.
-- Applied to production 2026-07-31.
--
-- Recover a specific deletion: find its rows in the bak tables by regno (+ acadyear/semester),
-- then INSERT ... SELECT back into the source table.
-- ============================================================================
CREATE TABLE IF NOT EXISTS campus_dynamics.acad_registration_regdel_bak
    AS SELECT * FROM campus_dynamics.acad_registration WHERE 1=0;
CREATE TABLE IF NOT EXISTS campus_dynamics_portal.acad_course_registration_regdel_bak
    AS SELECT * FROM campus_dynamics_portal.acad_course_registration WHERE 1=0;
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_studentfeestracking_regdel_bak
    AS SELECT * FROM campus_dynamics_accounts.fin_studentfeestracking WHERE 1=0;
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_ledger_regdel_bak
    AS SELECT * FROM campus_dynamics_accounts.fin_ledger WHERE 1=0;
