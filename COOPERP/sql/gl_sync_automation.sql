-- =============================================================================
-- GL SYNC AUTOMATION
-- =============================================================================
-- Problem:  fin_studentfeestracking rows sometimes exist without a matching
--           fin_ledger (GL) entry. This happens when:
--           (a) fin_TermlyItemBillingFN's call to fin_TransactionCreatorFn2
--               fails silently (the function is non-transactional)
--           (b) Batch scripts write to tracking with post_status='Posted'
--               but never insert into fin_ledger
--           (c) Any future code path that forgets the GL mirror
--
-- Solution (3 layers of defence):
--   1. STORED PROCEDURE  fin_SyncTrackingToLedger  — batch-repair any orphans
--   2. SCHEDULED EVENT    evt_GLSyncRepair          — runs the SP every 15 min
--   3. TRIGGER (INSERT)   trg_fst_after_insert      — mirrors on write
--   4. TRIGGER (UPDATE)   trg_fst_after_update      — mirrors when Pending→Posted
--
-- Safe to run multiple times — all objects use IF NOT EXISTS or DROP+CREATE.
-- =============================================================================

USE campus_dynamics_accounts;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. STORED PROCEDURE: fin_SyncTrackingToLedger
--    Finds all 'Posted' rows in fin_studentfeestracking that have no matching
--    row in fin_ledger and inserts the missing GL entries.
--    Also logs each repair for audit.
-- ─────────────────────────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS fin_SyncTrackingToLedger;

DELIMITER $$

CREATE PROCEDURE fin_SyncTrackingToLedger()
BEGIN

    DECLARE v_inserted INT DEFAULT 0;
    DECLARE v_normalised INT DEFAULT 0;

    -- ── A) Insert missing GL entries ─────────────────────────────────────────
    -- Match criteria: same regno, same amount, same date, same direction,
    -- AND either same detail text or same voucherNo=TID.
    -- This is the same dedup logic used by FixGLSync.aspx.cs.

    INSERT INTO fin_ledger
        (accountcode, account_type, transactionType, transaction_amount,
         particulars, voucherNo, transactionDate, teller, timeLog,
         folio, journal_no, trans_currency, actual_amount,
         curr_balance, forex_rate, ugx_amount)
    SELECT
        fst.regno,
        'Student',
        CASE WHEN fst.trans_type IN ('Payment', 'Waiver') THEN 'CR' ELSE 'DR' END,
        fst.amount,
        IFNULL(fst.detail, CONCAT(fst.trans_type, ' TID ', fst.TID)),
        fst.TID,
        fst.trans_date,
        'GLSync',
        NOW(),
        fst.regno,
        CONCAT('Sync:', fst.TID),
        'UGX',
        fst.amount,
        0,
        1,
        fst.amount
    FROM fin_studentfeestracking fst
    WHERE fst.post_status = 'Posted'
      AND fst.amount > 0
      AND NOT EXISTS (
          SELECT 1 FROM fin_ledger fl
          WHERE fl.accountcode = fst.regno
            AND fl.transaction_amount = fst.amount
            AND DATE(fl.transactionDate) = DATE(fst.trans_date)
            AND fl.transactionType = CASE
                WHEN fst.trans_type IN ('Payment', 'Waiver') THEN 'CR'
                ELSE 'DR'
            END
            AND (
              fl.particulars = fst.detail
              OR fl.voucherNo = fst.TID
              OR fl.folio = CONCAT('BillNo:', fst.TID)
            )
      );

    SET v_inserted = ROW_COUNT();

    -- ── B) Normalise account_type for student GL rows ────────────────────────
    -- AUTO billing SPs sometimes write account_type as the programme code
    -- or other values. fin_GetStudentLedger filters on account_type='Student',
    -- so rows with wrong types become invisible.

    UPDATE fin_ledger fl
    INNER JOIN campus_dynamics.acad_student s ON s.regno = fl.accountcode
    SET fl.account_type = 'Student'
    WHERE fl.account_type NOT IN ('Student', 'Chart Account');

    SET v_normalised = ROW_COUNT();

    -- ── C) Log the run ──────────────────────────────────────────────────────
    -- Uses a lightweight log table. If it doesn't exist, skip logging silently.

    BEGIN
        DECLARE CONTINUE HANDLER FOR 1146 BEGIN END;  -- Table doesn't exist
        INSERT INTO fin_gl_sync_log (run_time, rows_inserted, rows_normalised)
        VALUES (NOW(), v_inserted, v_normalised);
    END;

END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- 1b. Create the audit log table (lightweight)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS fin_gl_sync_log (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    run_time    DATETIME NOT NULL,
    rows_inserted   INT NOT NULL DEFAULT 0,
    rows_normalised INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. SCHEDULED EVENT: evt_GLSyncRepair
--    Runs fin_SyncTrackingToLedger every 15 minutes.
--    Requires:  SET GLOBAL event_scheduler = ON;
-- ─────────────────────────────────────────────────────────────────────────────

-- Ensure event scheduler is on (needs SUPER or EVENT privilege)
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS evt_GLSyncRepair;

DELIMITER $$

CREATE EVENT evt_GLSyncRepair
ON SCHEDULE EVERY 15 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL fin_SyncTrackingToLedger();
END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. TRIGGER: trg_fst_after_insert
--    When a row is inserted into fin_studentfeestracking with
--    post_status = 'Posted', immediately mirror it to fin_ledger.
--    This prevents the 15-minute window where data could be stale.
-- ─────────────────────────────────────────────────────────────────────────────

DROP TRIGGER IF EXISTS trg_fst_after_insert;

DELIMITER $$

CREATE TRIGGER trg_fst_after_insert
AFTER INSERT ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    -- Only mirror Posted rows with positive amounts
    IF NEW.post_status = 'Posted' AND NEW.amount > 0 THEN

        -- Guard: only insert if not already mirrored
        -- (handles the case where both trigger AND the original code path
        -- both try to insert — the billing function already calls
        -- fin_TransactionCreatorFn2 which also writes to fin_ledger)
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
                NEW.regno,
                'Student',
                CASE WHEN NEW.trans_type IN ('Payment', 'Waiver') THEN 'CR' ELSE 'DR' END,
                NEW.amount,
                IFNULL(NEW.detail, CONCAT(NEW.trans_type, ' TID ', NEW.TID)),
                NEW.TID,
                NEW.trans_date,
                'GLSync-Trigger',
                NOW(),
                NEW.regno,
                CONCAT('Sync:', NEW.TID),
                'UGX',
                NEW.amount,
                0,
                1,
                NEW.amount
            );

        END IF;

    END IF;
END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4. TRIGGER: trg_fst_after_update
--    When a tracking row's post_status changes from non-Posted → 'Posted',
--    mirror it to fin_ledger. This covers:
--    (a) fin_TermlyItemBillingFN which sets Pending → Posted after billing
--    (b) Manual status changes via admin UI
-- ─────────────────────────────────────────────────────────────────────────────

DROP TRIGGER IF EXISTS trg_fst_after_update;

DELIMITER $$

CREATE TRIGGER trg_fst_after_update
AFTER UPDATE ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    -- Only fire when status transitions TO 'Posted'
    IF NEW.post_status = 'Posted'
       AND (OLD.post_status IS NULL OR OLD.post_status <> 'Posted')
       AND NEW.amount > 0
    THEN

        -- Guard: only insert if not already mirrored
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
                NEW.regno,
                'Student',
                CASE WHEN NEW.trans_type IN ('Payment', 'Waiver') THEN 'CR' ELSE 'DR' END,
                NEW.amount,
                IFNULL(NEW.detail, CONCAT(NEW.trans_type, ' TID ', NEW.TID)),
                NEW.TID,
                NEW.trans_date,
                'GLSync-Trigger',
                NOW(),
                NEW.regno,
                CONCAT('Sync:', NEW.TID),
                'UGX',
                NEW.amount,
                0,
                1,
                NEW.amount
            );

        END IF;

    END IF;
END$$

DELIMITER ;


-- ─────────────────────────────────────────────────────────────────────────────
-- 5. IMMEDIATE FIX: Run the sync now to repair all existing orphans
-- ─────────────────────────────────────────────────────────────────────────────

CALL fin_SyncTrackingToLedger();

-- Check how many were repaired
SELECT * FROM fin_gl_sync_log ORDER BY id DESC LIMIT 5;


-- ─────────────────────────────────────────────────────────────────────────────
-- 6. VERIFY: Check MRU2025004200 specifically
-- ─────────────────────────────────────────────────────────────────────────────

-- All GL rows for the student
SELECT TID, transactionDate, voucherNo, transactionType,
       transaction_amount, particulars, teller
FROM fin_ledger
WHERE accountcode = 'MRU2025004200'
  AND account_type = 'Student'
ORDER BY transactionDate, TID;

-- Summary
SELECT
    SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) AS total_billed,
    SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS total_paid,
    SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END)
  - SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END) AS outstanding
FROM fin_ledger
WHERE accountcode = 'MRU2025004200'
  AND account_type = 'Student';

-- Via stored procedure (same as portal)
CALL fin_GetStudentLedger('MRU2025004200');


-- ─────────────────────────────────────────────────────────────────────────────
-- 7. SYSTEM-WIDE CHECK: How many orphans existed across ALL students?
-- ─────────────────────────────────────────────────────────────────────────────

SELECT * FROM fin_gl_sync_log ORDER BY id DESC LIMIT 10;
