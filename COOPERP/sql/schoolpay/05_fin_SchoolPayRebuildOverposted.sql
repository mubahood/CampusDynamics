-- ============================================================================
-- fin_SchoolPayRebuildOverposted (campus_dynamics_accounts)   2026-08-07
-- ----------------------------------------------------------------------------
-- One-off remediation for the pre-fix runaway double-post: before the folio guard
-- existed, the old engine re-posted some receipts every 10 minutes for a week,
-- creating up to 1,653 DR-only rows per receipt (~13.5B UGX phantom bank debits,
-- no student credit). This drives every over-posted TransCode folio through the ONE
-- shared, SAFE self-healing poster fin_SchoolPayHealReceipt (see 06_*): resolvable
-- students get one clean double-entry; orphan (unmapped) students get their phantom
-- rows wiped and the payment kept Pending for manual mapping.
--
-- Idempotent: once folios are healed they are no longer selected. Atomic per receipt
-- (heal wipes + re-posts in one transaction — no delete-then-lose window). Safe to
-- re-run. Requires 06_* (fin_SchoolPayHealReceipt) deployed FIRST.
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_SchoolPayRebuildOverposted;
DELIMITER $$
CREATE PROCEDURE fin_SchoolPayRebuildOverposted()
BEGIN
    DECLARE v_i        INT DEFAULT 1;
    DECLARE v_max      INT DEFAULT 0;
    DECLARE v_receipt  VARCHAR(45);
    -- snapshot the over-posted receipts (resolvable OR orphan — the heal poster decides
    -- what each needs: rebuild to a clean pair, or wipe phantom rows for an unmapped student).
    DROP TEMPORARY TABLE IF EXISTS tmp_over;
    CREATE TEMPORARY TABLE tmp_over (rid INT AUTO_INCREMENT PRIMARY KEY, ReceiptNo VARCHAR(45));
    INSERT INTO tmp_over(ReceiptNo)
        SELECT REPLACE(folio, 'TransCode:', '')
        FROM (
            SELECT folio FROM fin_ledger WHERE folio LIKE 'TransCode:%'
            GROUP BY folio HAVING SUM(transactionType='DR')>1 OR SUM(transactionType='CR')>1
        ) g;
    SELECT IFNULL(MAX(rid), 0) INTO v_max FROM tmp_over;

    WHILE v_i <= v_max DO
        SELECT ReceiptNo INTO v_receipt FROM tmp_over WHERE rid = v_i;
        -- SAFE atomic rebuild via the one shared poster (no autocommit-delete data-loss window)
        CALL fin_SchoolPayHealReceipt(v_receipt, @oc);
        SET v_i = v_i + 1;
    END WHILE;

    DROP TEMPORARY TABLE IF EXISTS tmp_over;
END$$
DELIMITER ;
