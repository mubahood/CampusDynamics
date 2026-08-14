-- ============================================================================
--  Batch fee adjustment — audit and undo
-- ============================================================================
--  A fee structure drives what every student on that programme is billed, so a
--  batch change to it is one of the highest-consequence actions on the system.
--  Before this, an adjustment left no record of what the figures had been: the
--  old code multiplied the columns in place and reported a toast.
--
--  Every cell that changes is now written here first, with its old and new
--  value, under a batch id. That makes the operation auditable after the fact
--  and, more usefully, reversible — the wizard's Undo replays these rows back.
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_fee_adjustment_batch (
    batch_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    performed_by  VARCHAR(100)  NOT NULL,
    performed_at  DATETIME      NOT NULL,
    fee_type      VARCHAR(20)   NOT NULL,      -- TUITION | FUNCTIONAL
    direction     CHAR(1)       NOT NULL,      -- + | -
    amount        DECIMAL(14,2) NOT NULL,      -- block figure, per cell
    years_csv     VARCHAR(20)   NOT NULL,      -- e.g. 1,2,3
    sems_csv      VARCHAR(20)   NOT NULL,      -- e.g. 1,2
    structures    INT           NOT NULL,
    cells_changed INT           NOT NULL,
    cells_skipped INT           NOT NULL,
    note          VARCHAR(255)  NULL,
    reverted_at   DATETIME      NULL,
    reverted_by   VARCHAR(100)  NULL,
    PRIMARY KEY (batch_id),
    KEY (performed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_fee_adjustment_line (
    line_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    batch_id   INT UNSIGNED  NOT NULL,
    pf_id      INT UNSIGNED  NOT NULL,         -- fin_programme_fees.ID
    progcode   VARCHAR(25)   NOT NULL,
    col_name   VARCHAR(40)   NOT NULL,         -- e.g. y2_s1_functional
    old_value  DECIMAL(14,2) NOT NULL,
    new_value  DECIMAL(14,2) NOT NULL,
    PRIMARY KEY (line_id),
    KEY (batch_id),
    KEY (pf_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
