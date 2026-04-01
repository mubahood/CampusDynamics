-- Deploy fixed GLSync triggers with folio back-reference check
-- Run on: campus_dynamics_accounts
-- Date: 2026-03-31

USE campus_dynamics_accounts;

DELIMITER $$

CREATE TRIGGER trg_fst_after_insert
AFTER INSERT ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    IF NEW.post_status = 'Posted' AND NEW.amount > 0 THEN
        IF NOT EXISTS (
            SELECT 1 FROM fin_ledger fl
            WHERE fl.accountcode = NEW.regno
              AND fl.transaction_amount = NEW.amount
              AND DATE(fl.transactionDate) = DATE(NEW.trans_date)
              AND fl.transactionType = CASE
                  WHEN NEW.trans_type IN ('Payment', 'Waiver') THEN 'CR'
                  ELSE 'DR'
              END
              AND (
                fl.particulars = NEW.detail
                OR fl.voucherNo = NEW.TID
                OR fl.folio = CONCAT('BillNo:', NEW.TID)
              )
        ) THEN
            INSERT INTO fin_ledger
                (accountcode, account_type, transactionType, transaction_amount,
                 particulars, voucherNo, transactionDate, teller, timeLog,
                 folio, journal_no, trans_currency, actual_amount,
                 curr_balance, forex_rate, ugx_amount)
            VALUES (
                NEW.regno, 'Student',
                CASE WHEN NEW.trans_type IN ('Payment', 'Waiver') THEN 'CR' ELSE 'DR' END,
                NEW.amount,
                IFNULL(NEW.detail, CONCAT(NEW.trans_type, ' TID ', NEW.TID)),
                NEW.TID, NEW.trans_date, 'GLSync-Trigger', NOW(),
                NEW.regno, CONCAT('Sync:', NEW.TID), 'UGX',
                NEW.amount, 0, 1, NEW.amount
            );
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_fst_after_update
AFTER UPDATE ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    IF NEW.post_status = 'Posted'
       AND (OLD.post_status IS NULL OR OLD.post_status <> 'Posted')
       AND NEW.amount > 0
    THEN
        IF NOT EXISTS (
            SELECT 1 FROM fin_ledger fl
            WHERE fl.accountcode = NEW.regno
              AND fl.transaction_amount = NEW.amount
              AND DATE(fl.transactionDate) = DATE(NEW.trans_date)
              AND fl.transactionType = CASE
                  WHEN NEW.trans_type IN ('Payment', 'Waiver') THEN 'CR'
                  ELSE 'DR'
              END
              AND (
                fl.particulars = NEW.detail
                OR fl.voucherNo = NEW.TID
                OR fl.folio = CONCAT('BillNo:', NEW.TID)
              )
        ) THEN
            INSERT INTO fin_ledger
                (accountcode, account_type, transactionType, transaction_amount,
                 particulars, voucherNo, transactionDate, teller, timeLog,
                 folio, journal_no, trans_currency, actual_amount,
                 curr_balance, forex_rate, ugx_amount)
            VALUES (
                NEW.regno, 'Student',
                CASE WHEN NEW.trans_type IN ('Payment', 'Waiver') THEN 'CR' ELSE 'DR' END,
                NEW.amount,
                IFNULL(NEW.detail, CONCAT(NEW.trans_type, ' TID ', NEW.TID)),
                NEW.TID, NEW.trans_date, 'GLSync-Trigger', NOW(),
                NEW.regno, CONCAT('Sync:', NEW.TID), 'UGX',
                NEW.amount, 0, 1, NEW.amount
            );
        END IF;
    END IF;
END$$

DELIMITER ;

-- Re-enable the scheduled event
ALTER EVENT evt_GLSyncRepair ENABLE;
