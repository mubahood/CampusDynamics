-- ============================================================================
-- fin_SchoolPayHealReceipt (campus_dynamics_accounts)   2026-08-07
-- ----------------------------------------------------------------------------
-- The single self-healing poster for ONE SchoolPay receipt. Given a receipt, it
-- inspects the actual ledger state and brings it to the ONE correct form: exactly
-- one CR to the student + one DR to the bank. It is the shared brain behind the
-- student "Refresh SchoolPay payments" button, the admin batch pull, and the
-- autosweep, so every path heals identically.
--
-- Scenarios covered (all detected in the 2026-08 incident):
--   * MISSING     (0 ledger rows)                       -> post one clean double-entry
--   * OVER-POSTED (runaway repeats, e.g. 1653 DR rows)  -> wipe + post one clean pair
--   * DR-ONLY     (bank debited, student NOT credited)  -> wipe + post one clean pair
--   * MIS-CREDITED(CR went to the wrong account)        -> wipe + post one clean pair
--   * CLEAN       (1 DR + 1 CR to student, <=2 rows)    -> leave; just fix the flag
--   * LEGACY single student credit (0 DR, 1 CR, 1 row)  -> left untouched (student is credited)
--   * NO STUDENT  (regno blank / not in acad_student)   -> left Pending for manual mapping
--
-- SAFE: the wipe + re-post run in ONE transaction (fin_TransactionCreator has no
-- internal COMMIT), so a failure never leaves a payment deleted-but-unposted. The
-- receipt's source of truth (fin_schoolpaydata / SchoolPay) is never modified, so any
-- transient failure self-heals on the next run. NEVER double-posts (it wipes first).
--
-- p_outcome: Existed | Posted | Rebuilt | NoStudent | Failed
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_SchoolPayHealReceipt;
DELIMITER $$
CREATE PROCEDURE fin_SchoolPayHealReceipt(IN p_receipt VARCHAR(45), OUT p_outcome VARCHAR(20))
BEGIN
    DECLARE v_reg       VARCHAR(45)  DEFAULT NULL;
    DECLARE v_name      VARCHAR(75)  DEFAULT '';
    DECLARE v_channel   VARCHAR(45)  DEFAULT '';
    DECLARE v_amount    DOUBLE       DEFAULT 0;
    DECLARE v_date      DATETIME     DEFAULT NULL;
    DECLARE v_rows      INT          DEFAULT 0;
    DECLARE v_dr        INT          DEFAULT 0;
    DECLARE v_crstud    INT          DEFAULT 0;
    DECLARE v_hasstud   INT          DEFAULT 0;
    DECLARE v_bankCode  VARCHAR(25);
    DECLARE v_ledger    VARCHAR(200);
    DECLARE v_acad      VARCHAR(200) DEFAULT NULL;
    DECLARE v_semes     INT          DEFAULT NULL;
    DECLARE v_syear     INT          DEFAULT NULL;
    DECLARE v_CRpart    VARCHAR(350);
    DECLARE v_DRpart    VARCHAR(350);
    DECLARE v_folio     VARCHAR(150);

    -- any failure => roll back the in-flight rebuild and report Failed (self-heals next run)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_outcome = 'Failed';
    END;

    SET p_outcome = 'Failed';
    SET v_folio = CONCAT('TransCode:', p_receipt);

    SELECT regno, stud_name, amount_paid, datePaid, channelPaid
      INTO v_reg, v_name, v_amount, v_date, v_channel
      FROM fin_schoolpaydata WHERE ReceiptNo = p_receipt LIMIT 1;
    IF v_reg IS NULL THEN
        SET p_outcome = 'Failed';            -- no SchoolPay record to heal from
    ELSE
        SET v_reg = TRIM(IFNULL(v_reg, ''));
        SELECT COUNT(*) INTO v_hasstud FROM campus_dynamics.acad_student WHERE TRIM(regno) = v_reg;

        IF v_reg = '' OR v_hasstud = 0 THEN
            -- Unresolvable student (e.g. paid but not yet in acad_student): a valid student
            -- credit is impossible, so ANY ledger rows on this folio are phantom (the DR-only
            -- runaway). Remove them so they stop corrupting the bank/GL; the payment stays
            -- recorded in fin_schoolpaydata (Pending) for manual mapping / orphan backfill.
            SELECT COUNT(*) INTO v_rows FROM fin_ledger WHERE folio = v_folio;
            IF v_rows > 0 THEN
                SET v_bankCode = CASE
                    WHEN LOWER(v_channel) LIKE '%dfcu%'      THEN 'AC1303'
                    WHEN LOWER(v_channel) LIKE '%centenary%' THEN 'AC1303'
                    WHEN LOWER(v_channel) LIKE '%eco%'       THEN 'AC1308'
                    ELSE 'AC1302' END;
                START TRANSACTION;
                    DELETE FROM fin_ledger WHERE folio = v_folio;
                COMMIT;
                CALL fin_UpdateLedgerBalances(v_bankCode);
            END IF;
            UPDATE fin_schoolpaydata SET captureStatus = 'Pending' WHERE ReceiptNo = p_receipt;
            SET p_outcome = 'NoStudent';
        ELSE
            SELECT COUNT(*),
                   SUM(transactionType = 'DR'),
                   SUM(transactionType = 'CR' AND accountcode = v_reg)
              INTO v_rows, v_dr, v_crstud
              FROM fin_ledger WHERE folio = v_folio;
            SET v_dr = IFNULL(v_dr, 0); SET v_crstud = IFNULL(v_crstud, 0);

            IF v_crstud = 1 AND v_rows <= 2 AND v_dr <= 1 THEN
                -- already correct (clean double-entry, or legacy single student credit): leave it
                UPDATE fin_schoolpaydata SET captureStatus = 'Captured' WHERE ReceiptNo = p_receipt;
                SET p_outcome = 'Existed';
            ELSE
                -- MISSING or MALFORMED -> rebuild to exactly one clean double-entry
                SET v_bankCode = CASE
                    WHEN LOWER(v_channel) LIKE '%dfcu%'      THEN 'AC1303'
                    WHEN LOWER(v_channel) LIKE '%centenary%' THEN 'AC1303'
                    WHEN LOWER(v_channel) LIKE '%eco%'       THEN 'AC1308'
                    ELSE 'AC1302' END;
                SET v_ledger = fin_GetStudentLedgerName(v_reg);
                SELECT acad_year, semester, studyYear INTO v_acad, v_semes, v_syear
                  FROM campus_dynamics.acad_registration WHERE regno = v_reg ORDER BY ID DESC LIMIT 1;

                SET v_CRpart = CONCAT('Fees Payment for ', IFNULL(CAST(v_syear AS CHAR), ''), ' ',
                    IFNULL(v_semes, ''), ', ', IFNULL(v_acad, ''), ' on ', DATE_FORMAT(v_date, '%d/%m/%Y'),
                    ' thru ', IFNULL(v_channel, 'SchoolPay'), ' TNo: ', p_receipt);
                SET v_DRpart = CONCAT('Paid on ', DATE_FORMAT(v_date, '%d/%m/%Y'), ' by ',
                    IFNULL(v_name, ''), ' TNo: ', p_receipt);

                START TRANSACTION;
                    DELETE FROM fin_ledger WHERE folio = v_folio;
                    CALL fin_TransactionCreator(v_reg, v_ledger, v_CRpart, v_bankCode, 'Chart Account',
                         v_DRpart, v_amount, 0, SYSDATE(), 'selfheal', 'UGX', v_folio);
                    -- exactly one tracking row for this receipt (dedup by TNo)
                    DELETE FROM fin_studentfeestracking WHERE regno = v_reg AND detail LIKE CONCAT('%TNo: ', p_receipt);
                    INSERT INTO fin_studentfeestracking
                        (regno, acadyear, semester, amount, item_code, trans_type, detail, trans_date, post_status)
                    VALUES (v_reg, IFNULL(v_acad, ''), IFNULL(v_semes, 0), v_amount, 0, 'Payment', v_CRpart, SYSDATE(), 'Posted');
                    UPDATE fin_schoolpaydata SET captureStatus = 'Captured' WHERE ReceiptNo = p_receipt;
                COMMIT;

                CALL fin_UpdateLedgerBalances(v_reg);
                CALL fin_UpdateLedgerBalances(v_bankCode);
                SET p_outcome = IF(v_rows = 0, 'Posted', 'Rebuilt');
            END IF;
        END IF;
    END IF;
END$$
DELIMITER ;
