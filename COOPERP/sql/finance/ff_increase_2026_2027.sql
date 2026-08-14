-- ============================================================================
--  Functional-fee correction — 2026/2027 only
-- ============================================================================
--  The functional fee in fin_programme_fees was raised by 95,000 on 14 Aug 2026
--  (batches 4 and 5 in fin_fee_adjustment_batch). Students billed BEFORE that
--  carry the old figure, so their bills no longer agree with the structure.
--
--  This corrects the EXISTING bill in place — it does not raise a new one — for
--  2026/2027 only. Both ledger legs move together so the voucher stays balanced,
--  and the matching fin_studentfeestracking row moves with them so the two
--  sources the canonical balance reads from cannot disagree.
--
--  Scope is deliberately narrow. Only rows whose shortfall is EXACTLY 95,000 are
--  touched, and only where the ledger voucher is a clean, balanced 1 DR + 1 CR
--  pair. Anything else — a different gap, an odd voucher shape, or a student
--  never billed at all — is left alone and reported.
--
--  Requires _fftarget, built by ff_target.sql.
-- ============================================================================

USE campus_dynamics_accounts;

-- Every row about to change, with the value it held. Reversible from this alone.
CREATE TABLE IF NOT EXISTS bak_ff_increase_20260814 (
    id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    src_table   VARCHAR(40)     NOT NULL,
    row_id      BIGINT UNSIGNED NOT NULL,
    regno       VARCHAR(45)     NOT NULL,
    semester    INT             NOT NULL,
    old_amount  DECIMAL(14,2)   NOT NULL,
    new_amount  DECIMAL(14,2)   NOT NULL,
    changed_at  DATETIME        NOT NULL,
    PRIMARY KEY (id), KEY (src_table, row_id), KEY (regno)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

START TRANSACTION;

-- 1. record ------------------------------------------------------------------
INSERT INTO bak_ff_increase_20260814 (src_table,row_id,regno,semester,old_amount,new_amount,changed_at)
SELECT 'fin_ledger.DR', t.dr_tid, t.regno, t.semester, t.billed, t.expected_ff, NOW() FROM _fftarget t;

INSERT INTO bak_ff_increase_20260814 (src_table,row_id,regno,semester,old_amount,new_amount,changed_at)
SELECT 'fin_ledger.CR', t.cr_tid, t.regno, t.semester, l.transaction_amount, t.expected_ff, NOW()
  FROM _fftarget t JOIN fin_ledger l ON l.TID = t.cr_tid;

INSERT INTO bak_ff_increase_20260814 (src_table,row_id,regno,semester,old_amount,new_amount,changed_at)
SELECT 'fin_studentfeestracking', k.TID, t.regno, t.semester, k.amount, t.expected_ff, NOW()
  FROM _fftarget t
  JOIN fin_studentfeestracking k
    ON k.TID = t.track_tid AND k.item_code = 52 AND k.trans_type = 'Bill';

-- 2. correct -----------------------------------------------------------------
--    Both legs of the voucher move by the same amount, so it stays balanced.
UPDATE fin_ledger l JOIN _fftarget t ON t.dr_tid = l.TID
   SET l.transaction_amount = t.expected_ff;

UPDATE fin_ledger l JOIN _fftarget t ON t.cr_tid = l.TID
   SET l.transaction_amount = t.expected_ff;

UPDATE fin_studentfeestracking k JOIN _fftarget t ON t.track_tid = k.TID
   SET k.amount = t.expected_ff
 WHERE k.item_code = 52 AND k.trans_type = 'Bill';

INSERT INTO campus_dynamics.acad_activity_log (user_id, page_function, par, comments, access_date)
SELECT 'admin', 'Functional Fee Correction', '2026/2027',
       CONCAT('Corrected ', COUNT(*), ' functional-fee bills to the current fee structure (+95,000 each); ',
              'both ledger legs and the tracking row updated. Reversible from bak_ff_increase_20260814.'),
       NOW()
  FROM _fftarget;

COMMIT;
