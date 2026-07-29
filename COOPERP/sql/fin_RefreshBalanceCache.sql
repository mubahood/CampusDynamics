-- ============================================================================
--  fin_RefreshBalanceCache(regno)  —  recompute ONE student's row in
--  fin_student_balance_cache from the canonical dedup (GL + non-duplicated Posted
--  tracking), keeping the cache in step with the authoritative balance
--  (fin_GetCanonicalStudentBalance). cache.total_balance = paid - billed.
--
--  Called after any billing operation (e.g. inside fin_ReconcileEnrolledBilling)
--  so a freshly-posted bill never leaves a stale cached balance. Upserts, so it
--  works whether or not the student already has a cache row.
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_RefreshBalanceCache;
DELIMITER $$
CREATE PROCEDURE fin_RefreshBalanceCache(IN p_regno CHAR(35))
BEGIN
  DECLARE v_billed, v_paid DECIMAL(20,2) DEFAULT 0;
  DECLARE v_txc INT DEFAULT 0;

  SELECT IFNULL(SUM(CASE WHEN x.ttype='DR' THEN x.amt ELSE 0 END),0),
         IFNULL(SUM(CASE WHEN x.ttype='CR' THEN x.amt ELSE 0 END),0),
         COUNT(*)
    INTO v_billed, v_paid, v_txc
  FROM (
     SELECT fl.transactionType ttype, fl.transaction_amount amt
       FROM fin_ledger fl WHERE fl.accountcode=p_regno AND fl.transaction_amount>0
     UNION ALL
     SELECT CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END, t.amount
       FROM fin_studentfeestracking t
      WHERE t.regno=p_regno AND t.post_status='Posted'
        AND NOT EXISTS (SELECT 1 FROM fin_ledger fl2 WHERE fl2.accountcode=t.regno
             AND (fl2.voucherNo=CAST(t.TID AS CHAR) OR fl2.folio=CONCAT('BillNo:',CAST(t.TID AS CHAR))
                  OR (fl2.transaction_amount=t.amount AND DATE(fl2.transactionDate)=DATE(t.trans_date)
                      AND fl2.transactionType=CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END)))
  ) x;

  INSERT INTO fin_student_balance_cache (regno,total_billed,total_paid,total_balance,tx_count,updated_at)
  VALUES (p_regno, v_billed, v_paid, v_paid - v_billed, v_txc, NOW())
  ON DUPLICATE KEY UPDATE
    total_billed=v_billed, total_paid=v_paid, total_balance=v_paid - v_billed, tx_count=v_txc, updated_at=NOW();
END$$
DELIMITER ;
