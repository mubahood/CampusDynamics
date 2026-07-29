-- ============================================================================
-- Track 3 (monitoring) — read-only reconciliation view. 2026-06-25.
-- Per student: canonical balance (from the cache) vs ledger-only vs tracking-only,
-- so finance can spot any drift / residual duplication immediately.
-- Convention: balance = paid - billed  ( + = OVERPAID/credit, - = OWING ).
-- Safe: a VIEW definition changes no data. Filter by regno for fast reads.
-- Note: MySQL 5.6 disallows FROM-clause subqueries in views, so the two
-- comparison balances use correlated scalar subqueries.
-- ============================================================================
CREATE OR REPLACE VIEW v_student_fee_reconciliation AS
SELECT
    c.regno,
    c.total_billed,
    c.total_paid,
    c.total_balance AS canonical_balance,
    ( SELECT IFNULL(SUM(CASE WHEN fl.transactionType='CR' THEN fl.transaction_amount ELSE 0 END)
                  - SUM(CASE WHEN fl.transactionType='DR' THEN fl.transaction_amount ELSE 0 END), 0)
        FROM fin_ledger fl
       WHERE fl.accountcode = c.regno AND fl.transaction_amount > 0 ) AS ledger_only_balance,
    ( SELECT IFNULL(SUM(CASE WHEN t.trans_type IN ('Payment','Waiver') THEN t.amount ELSE 0 END)
                  - SUM(CASE WHEN t.trans_type='Bill' THEN t.amount ELSE 0 END), 0)
        FROM fin_studentfeestracking t
       WHERE t.regno = c.regno AND t.post_status='Posted' ) AS tracking_only_balance,
    c.updated_at
FROM fin_student_balance_cache c;
