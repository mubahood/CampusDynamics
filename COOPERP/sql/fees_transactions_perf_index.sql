-- ============================================================================
-- FeesTransactions.aspx performance — composite index for the GL-orphan detector
-- ----------------------------------------------------------------------------
-- The page merges fin_studentfeestracking (manual) with GL-only "orphan" rows from
-- fin_ledger (entries with no matching tracking row). The orphan test is a correlated
-- NOT EXISTS against fin_studentfeestracking on (regno, amount, trans_type, same-day).
-- Without a composite index (and with the old DATE(trans_date)=DATE(...) wrapping that
-- made it non-sargable) this ran ~45s for ~179k ledger rows. This index + the sargable
-- date range rewrite in BuildInnerUnion() take that branch to ~1.5s.
--   Applied to production 2026-07-31.
-- ============================================================================
USE campus_dynamics_accounts;

CREATE INDEX idx_orphan_match
    ON fin_studentfeestracking (regno, amount, trans_type, trans_date);

-- Rollback: DROP INDEX idx_orphan_match ON fin_studentfeestracking;
