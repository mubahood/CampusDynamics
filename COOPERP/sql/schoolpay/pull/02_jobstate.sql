-- =====================================================================
-- SchoolPay AUTO-SYNC job state / heartbeat
-- DB: campus_dynamics_accounts
--
-- One row ('AUTO_SYNC') drives + monitors the in-process auto-sync engine
-- (App_Code/SchoolPay/SchoolPaySyncJob.cs). The engine ALSO self-creates this
-- table on first run (CREATE TABLE IF NOT EXISTS), so running this script is
-- optional — it only makes the row visible immediately for the controller.
--
--   enabled          1 = auto-sync runs, 0 = paused (persisted across recycles)
--   interval_minutes ping cadence (default 5)
--   window_days      rolling pull window each tick (default 2 = catch late settlements)
--   last_heartbeat   set EVERY tick (even when paused) -> proves the engine is alive
--   last_run         set when a pull is actually claimed -> distributed single-flight guard
--   status           IDLE / RUNNING / OK / ERROR / PAUSED
-- =====================================================================
USE campus_dynamics_accounts;

CREATE TABLE IF NOT EXISTS fin_schoolpay_jobstate (
  job_name         VARCHAR(40)  NOT NULL PRIMARY KEY,
  enabled          TINYINT(1)   NOT NULL DEFAULT 1,
  interval_minutes INT          NOT NULL DEFAULT 5,
  window_days      INT          NOT NULL DEFAULT 2,
  status           VARCHAR(20)  NOT NULL DEFAULT 'IDLE',
  last_heartbeat   DATETIME     NULL,
  last_run         DATETIME     NULL,
  last_finished    DATETIME     NULL,
  last_run_id      VARCHAR(40)  NULL,
  last_message     VARCHAR(500) NULL,
  last_error       VARCHAR(500) NULL,
  last_fetched     INT          NOT NULL DEFAULT 0,
  last_new         INT          NOT NULL DEFAULT 0,
  last_captured    INT          NOT NULL DEFAULT 0,
  last_existed     INT          NOT NULL DEFAULT 0,
  last_failed      INT          NOT NULL DEFAULT 0,
  total_runs       BIGINT       NOT NULL DEFAULT 0,
  total_captured   BIGINT       NOT NULL DEFAULT 0,
  worker_id        VARCHAR(80)  NULL,
  updated_at       DATETIME     NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO fin_schoolpay_jobstate
  (job_name, enabled, interval_minutes, window_days, status)
VALUES
  ('AUTO_SYNC', 1, 5, 2, 'IDLE');
