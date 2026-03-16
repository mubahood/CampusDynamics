-- Rollback H1: Remove daily balance verification event
DROP EVENT IF EXISTS `evt_daily_balance_check`;
