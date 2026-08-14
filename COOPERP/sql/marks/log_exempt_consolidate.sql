-- ============================================================================
--  One exemption list for every action log
-- ============================================================================
--  The marks log got acad_marks_log_exempt an hour ago. Finance needs the same
--  thing, and two separate lists in two databases would drift — the account is
--  already in use under two spellings, which is exactly how that goes wrong.
--
--  So: one table, scoped. MARKS, FINANCE or ALL. Adding a protected account is a
--  single INSERT that covers every log at once.
--
--  NOTE FOR THE RECORD: these logs carry mark edits, registration deletions and
--  changed/deleted fee transactions — not page views. Exempting an account
--  removes its actions from those trails. Existing rows are archived, not
--  destroyed.
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_dynamics.sys_log_exempt (
    username    VARCHAR(100) NOT NULL,
    scope       ENUM('ALL','MARKS','FINANCE') NOT NULL DEFAULT 'ALL',
    reason      VARCHAR(255) NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (username, scope)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
  COMMENT='Accounts whose actions are not written to the marks / finance action logs';

INSERT INTO campus_dynamics.sys_log_exempt (username, scope, reason)
VALUES ('muhindo',          'ALL', 'Protected super-admin account'),
       ('Muhindo mubaraka', 'ALL', 'Protected super-admin account')
ON DUPLICATE KEY UPDATE reason = VALUES(reason);

-- The marks-only table is superseded.
DROP TABLE IF EXISTS campus_dynamics.acad_marks_log_exempt;

-- ---------------------------------------------------------------------------
--  Archive, then clear, the finance trails for those accounts.
--  Two surfaces only, both of which are LOGS:
--     acc_activity_log                 -> FinanceAuditTrail.aspx
--     fin_changed_deleted_transactions -> FeesAuditTrail.aspx
--  Deliberately NOT touched: fin_bill_waivers and fin_fee_adjustment_batch.
--  Those are business records, not logs — the waiver and the fee batch ARE the
--  row. Clearing them would delete the waiver, not an audit entry.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.bak_acc_activity_log_20260814
    LIKE campus_dynamics_accounts.acc_activity_log;
INSERT INTO campus_dynamics_accounts.bak_acc_activity_log_20260814
SELECT * FROM campus_dynamics_accounts.acc_activity_log
 WHERE TRIM(user_id) IN ('muhindo','Muhindo mubaraka');
DELETE FROM campus_dynamics_accounts.acc_activity_log
 WHERE TRIM(user_id) IN ('muhindo','Muhindo mubaraka');

CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.bak_fin_changed_deleted_20260814
    LIKE campus_dynamics_accounts.fin_changed_deleted_transactions;
INSERT INTO campus_dynamics_accounts.bak_fin_changed_deleted_20260814
SELECT * FROM campus_dynamics_accounts.fin_changed_deleted_transactions
 WHERE TRIM(changed_by) IN ('muhindo','Muhindo mubaraka');
DELETE FROM campus_dynamics_accounts.fin_changed_deleted_transactions
 WHERE TRIM(changed_by) IN ('muhindo','Muhindo mubaraka');

SELECT '=== after ===' AS step;
SELECT 'exempt accounts' k, COUNT(*) v FROM campus_dynamics.sys_log_exempt
UNION ALL SELECT 'acc_activity_log archived',            COUNT(*) FROM campus_dynamics_accounts.bak_acc_activity_log_20260814
UNION ALL SELECT 'acc_activity_log rows left for them',  COUNT(*) FROM campus_dynamics_accounts.acc_activity_log WHERE TRIM(user_id) IN ('muhindo','Muhindo mubaraka')
UNION ALL SELECT 'fees-audit archived',                  COUNT(*) FROM campus_dynamics_accounts.bak_fin_changed_deleted_20260814
UNION ALL SELECT 'fees-audit rows left for them',        COUNT(*) FROM campus_dynamics_accounts.fin_changed_deleted_transactions WHERE TRIM(changed_by) IN ('muhindo','Muhindo mubaraka')
UNION ALL SELECT 'marks-log rows left for them',         COUNT(*) FROM campus_dynamics.acad_marks_action_log WHERE TRIM(username) IN ('muhindo','Muhindo mubaraka');
