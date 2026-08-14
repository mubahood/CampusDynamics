-- ============================================================================
--  Repair trg_fin_ledger_after_update
-- ============================================================================
--  edit_ledger began life as a full mirror of a ledger row — accountcode,
--  account_type, particulars, voucherNo, teller and the rest are all NOT NULL
--  with no default. The trigger_* columns were bolted on later, and the trigger
--  fills only those.
--
--  Under STRICT_TRANS_TABLES (which this server runs) that INSERT fails on the
--  first NOT-NULL column it does not supply, and because it fires from an AFTER
--  UPDATE trigger the failure takes the UPDATE down with it. The practical
--  effect: NO ledger amount could be corrected at all. Any attempt died with
--  "Field 'accountcode' doesn't have a default value", which names the audit
--  table rather than the statement, so the cause is not obvious.
--
--  The trigger now records the whole OLD row alongside the before/after values,
--  which is what the table was shaped for in the first place — the audit becomes
--  genuinely useful rather than merely present.
-- ============================================================================

DROP TRIGGER IF EXISTS campus_dynamics_accounts.trg_fin_ledger_after_update;

DELIMITER $$

CREATE TRIGGER campus_dynamics_accounts.trg_fin_ledger_after_update
AFTER UPDATE ON campus_dynamics_accounts.fin_ledger
FOR EACH ROW
BEGIN
    IF OLD.transaction_amount <> NEW.transaction_amount
       OR OLD.transactionType <> NEW.transactionType THEN

        INSERT INTO campus_dynamics_accounts.edit_ledger
            (TID, accountcode, account_type, transactionType, transaction_amount,
             particulars, voucherNo, transactionDate, teller, timeLog, folio,
             journal_no, trans_currency, actual_amount, curr_balance,
             trigger_tid, old_transaction_amount, new_transaction_amount,
             old_transactionType, new_transactionType, triggered_by, trigger_date)
        VALUES
            (OLD.TID, OLD.accountcode, OLD.account_type, OLD.transactionType, OLD.transaction_amount,
             OLD.particulars, OLD.voucherNo, OLD.transactionDate, OLD.teller,
             IFNULL(OLD.timeLog, NOW()), OLD.folio,
             IFNULL(OLD.journal_no,'-'), IFNULL(OLD.trans_currency,'UGX'),
             IFNULL(OLD.actual_amount,0), IFNULL(OLD.curr_balance,'-'),
             OLD.TID, OLD.transaction_amount, NEW.transaction_amount,
             OLD.transactionType, NEW.transactionType, USER(), NOW());
    END IF;
END$$

DELIMITER ;
