-- ============================================================================
--  Teller aliasing — post shared/admin accounts under a system name
-- ============================================================================
--  Some logins are shared administrative accounts rather than a named cashier.
--  Transactions they raise should not carry a person's name on the ledger, the
--  student statement or the fees reports; they belong to the system.
--
--  `muhindo` is such an account. Every finance transaction it has raised, and
--  every one it raises from now on, is stamped `autocapture` — the name the
--  SchoolPay auto-capture engine already uses for machine-posted entries.
--
--  Enforcement is in the database, not the application, because the ledger is
--  written from many directions: the NewScreens C#, the classic WebForms
--  SqlDataSources, ~20 stored procedures, the SchoolPay webhook and its sweep,
--  and the pull-sync job. A trigger is the only point all of them pass through.
--
--  DELIBERATELY NOT ALIASED
--  ------------------------
--  * fin_transaction_numbers.username and fin_vouchernumbers.Teller.
--    These look like attribution but are ALLOCATION KEYS. fin_NextVoucherNo()
--    inserts a row for the user then reads back MAX(voucherID) WHERE
--    username = <that user>, and fin_GetLatestVoucherNo() does the same over
--    fin_vouchernumbers. Rewriting the stored name would make the read-back
--    miss the row it just wrote and hand out a stale — or, once history is
--    rewritten too, a restarted-from-1 — voucher number. Colliding voucher
--    numbers, silently. These columns stay exactly as they are.
--
--  * acc_activity_log, fin_changed_deleted_transactions.changed_by,
--    fin_deleted_ledger.deleted_by, fin_bill_waivers.created_by/reversed_by,
--    fin_batch_billing_jobs.created_by, fin_schoolpay_synclog.triggered_by.
--    These are audit and approval trails — the record of who did something,
--    which is the one thing that must not be anonymised.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. The mapping. Adding a shared account later is an INSERT, not a code change.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.fin_teller_alias (
    username   VARCHAR(45)  NOT NULL,
    post_as    VARCHAR(45)  NOT NULL,
    reason     VARCHAR(255) NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Shared logins whose finance transactions post under a system name';

INSERT INTO campus_dynamics_accounts.fin_teller_alias (username, post_as, reason)
VALUES ('muhindo', 'autocapture', 'Shared admin account - transactions are institutional, not personal')
ON DUPLICATE KEY UPDATE post_as = VALUES(post_as), reason = VALUES(reason);

-- ---------------------------------------------------------------------------
-- 2. fin_ledger — the stamp that reaches the student statement.
--    MySQL allows one trigger per timing/event, and these two already existed
--    carrying the DR/CR and amount guards. Those guards are reproduced verbatim;
--    only the alias rewrite at the end is new.
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS campus_dynamics_accounts.trg_fin_ledger_before_insert;
DROP TRIGGER IF EXISTS campus_dynamics_accounts.trg_fin_ledger_before_update;

DELIMITER $$

CREATE TRIGGER campus_dynamics_accounts.trg_fin_ledger_before_insert
BEFORE INSERT ON campus_dynamics_accounts.fin_ledger
FOR EACH ROW
BEGIN
    IF NEW.transaction_amount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transaction_amount must be greater than 0';
    END IF;

    IF NEW.transactionType NOT IN ('DR', 'CR') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transactionType must be DR or CR';
    END IF;

    IF NEW.accountcode = '' OR NEW.accountcode IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'accountcode must not be empty';
    END IF;

    -- Shared logins post under their system name.
    SET NEW.teller = IFNULL(
        (SELECT post_as FROM campus_dynamics_accounts.fin_teller_alias
          WHERE username = NEW.teller), NEW.teller);
END$$

CREATE TRIGGER campus_dynamics_accounts.trg_fin_ledger_before_update
BEFORE UPDATE ON campus_dynamics_accounts.fin_ledger
FOR EACH ROW
BEGIN
    IF NEW.transaction_amount <> OLD.transaction_amount AND NEW.transaction_amount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transaction_amount must be greater than 0';
    END IF;

    IF NEW.transactionType <> OLD.transactionType AND NEW.transactionType NOT IN ('DR', 'CR') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'transactionType must be DR or CR';
    END IF;

    IF (NEW.accountcode <> OLD.accountcode OR (OLD.accountcode IS NOT NULL AND NEW.accountcode IS NULL))
       AND (NEW.accountcode = '' OR NEW.accountcode IS NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'accountcode must not be empty';
    END IF;

    SET NEW.teller = IFNULL(
        (SELECT post_as FROM campus_dynamics_accounts.fin_teller_alias
          WHERE username = NEW.teller), NEW.teller);
END$$

-- ---------------------------------------------------------------------------
-- 3. Journals. Neither column is read back for allocation — fin_NextJournalSerial
--    keys off journal type, not teller — so aliasing them is safe.
-- ---------------------------------------------------------------------------
CREATE TRIGGER campus_dynamics_accounts.trg_fin_journal_details_bi
BEFORE INSERT ON campus_dynamics_accounts.fin_journal_details
FOR EACH ROW
BEGIN
    SET NEW.teller = IFNULL(
        (SELECT post_as FROM campus_dynamics_accounts.fin_teller_alias
          WHERE username = NEW.teller), NEW.teller);
END$$

CREATE TRIGGER campus_dynamics_accounts.trg_fin_journal_details_bu
BEFORE UPDATE ON campus_dynamics_accounts.fin_journal_details
FOR EACH ROW
BEGIN
    SET NEW.teller = IFNULL(
        (SELECT post_as FROM campus_dynamics_accounts.fin_teller_alias
          WHERE username = NEW.teller), NEW.teller);
END$$

CREATE TRIGGER campus_dynamics_accounts.trg_fin_journalnumbers_bi
BEFORE INSERT ON campus_dynamics_accounts.fin_journalnumbers
FOR EACH ROW
BEGIN
    SET NEW.Teller = IFNULL(
        (SELECT post_as FROM campus_dynamics_accounts.fin_teller_alias
          WHERE username = NEW.Teller), NEW.Teller);
END$$

CREATE TRIGGER campus_dynamics_accounts.trg_fin_journalnumbers_bu
BEFORE UPDATE ON campus_dynamics_accounts.fin_journalnumbers
FOR EACH ROW
BEGIN
    SET NEW.Teller = IFNULL(
        (SELECT post_as FROM campus_dynamics_accounts.fin_teller_alias
          WHERE username = NEW.Teller), NEW.Teller);
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------
-- 4. History. fin_deleted_ledger keeps the original transaction's teller, so it
--    is restamped too; its deleted_by (who deleted it) is left alone.
-- ---------------------------------------------------------------------------
-- Reversible: every row about to change, with the name it had.
CREATE TABLE IF NOT EXISTS campus_dynamics_accounts.bak_teller_alias_20260812 (
    src_table VARCHAR(64) NOT NULL,
    row_id    BIGINT      NOT NULL,
    old_value VARCHAR(45) NOT NULL,
    KEY (src_table, row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO campus_dynamics_accounts.bak_teller_alias_20260812 (src_table, row_id, old_value)
SELECT 'fin_ledger', l.TID, l.teller
  FROM campus_dynamics_accounts.fin_ledger l
  JOIN campus_dynamics_accounts.fin_teller_alias a ON a.username = l.teller;

INSERT INTO campus_dynamics_accounts.bak_teller_alias_20260812 (src_table, row_id, old_value)
SELECT 'fin_deleted_ledger', d.TID, d.teller
  FROM campus_dynamics_accounts.fin_deleted_ledger d
  JOIN campus_dynamics_accounts.fin_teller_alias a ON a.username = d.teller;

UPDATE campus_dynamics_accounts.fin_ledger          l
  JOIN campus_dynamics_accounts.fin_teller_alias    a ON a.username = l.teller
   SET l.teller = a.post_as;

UPDATE campus_dynamics_accounts.fin_deleted_ledger  d
  JOIN campus_dynamics_accounts.fin_teller_alias    a ON a.username = d.teller
   SET d.teller = a.post_as;

UPDATE campus_dynamics_accounts.fin_journal_details j
  JOIN campus_dynamics_accounts.fin_teller_alias    a ON a.username = j.teller
   SET j.teller = a.post_as;

UPDATE campus_dynamics_accounts.fin_journalnumbers  n
  JOIN campus_dynamics_accounts.fin_teller_alias    a ON a.username = n.Teller
   SET n.Teller = a.post_as;

INSERT INTO campus_dynamics_accounts.acc_activity_log (user_id, page_function, par, comments, access_date)
VALUES ('admin', 'TELLER_ALIAS', 'muhindo->autocapture',
        'Shared admin account aliased; ledger/journal history restamped, trigger enforces it going forward', NOW());
