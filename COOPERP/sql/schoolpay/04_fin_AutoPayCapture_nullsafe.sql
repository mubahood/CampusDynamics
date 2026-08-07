-- ============================================================================
-- fin_AutoPayCapture — null-safe particulars + restored folio double-post guard
--   campus_dynamics_accounts   revised 2026-08-07
-- ----------------------------------------------------------------------------
-- Reconciles the LIVE-deployed proc (which had diverged from
-- 01_fin_AutoPayCapture_hardened.sql) with two corrections:
--
--   1. NULL-SAFE PARTICULARS. A student who paid but was never registered has no
--      acad_registration row, so `semes`/`acad` come back NULL. The old CONCAT then
--      produced a NULL particulars, and fin_TransactionCreator (STRICT_TRANS_TABLES)
--      rejected it with "Column 'particulars' cannot be null" — leaving genuine
--      payments stuck 'Pending' forever. Every dynamic part is now IFNULL-guarded, so
--      the GL entry always posts (registered students are byte-for-byte unchanged).
--
--   2. RESTORED FOLIO DOUBLE-POST GUARD. Idempotency no longer depends solely on the
--      captureStatus flag: the GL double-entry is created at most once per receipt
--      (folio = 'TransCode:<tid>', indexed). Safe for the re-arming reconcile/sweep and
--      any caller (live webhook, admin recapture, autosweep). On a re-capture it only
--      back-fills the fin_studentfeestracking row if missing.
--
-- Preserves the live proc's other traits: dbmanager definer, StudySys from studyYear,
-- teller literal 'autocapture'.
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_AutoPayCapture;
DELIMITER $$
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_AutoPayCapture`(
    reg CHAR(25),
    stud_nm CHAR(65),
    bankCode CHAR(25),
    amount DOUBLE,
    TDate DATE,
    teller CHAR(25),
    bankName VARCHAR(250),
    tid INT
)
BEGIN
    DECLARE CRaccountType, DRParticulars, CRParticulars, StudySys, acad VARCHAR(200);
    DECLARE TransNo, semes, TCheck, currYear INT;
    DECLARE alreadyPosted INT DEFAULT 0;

    SELECT acad_year, semester, studyYear
      INTO acad, semes, currYear
      FROM campus_dynamics.acad_registration
     WHERE regno = reg
     ORDER BY ID DESC
     LIMIT 1;

    SELECT COUNT(*)
      INTO TCheck
      FROM fin_schoolpaydata
     WHERE receiptno = tid AND CaptureStatus = 'Pending';

    -- has the GL double-entry for this receipt already been posted? (indexed on folio)
    SELECT COUNT(*)
      INTO alreadyPosted
      FROM fin_ledger
     WHERE folio = CONCAT('TransCode:', tid);

    START TRANSACTION;

    IF TCheck = 1 THEN

        SET StudySys = IFNULL(CAST(currYear AS CHAR), '');
        SET CRaccountType = fin_GetStudentLedgerName(reg);

        -- NULL-SAFE: unregistered students have NULL semes/acad; never build a NULL particulars.
        SET CRParticulars = CONCAT(
            'Fees Payment for ', StudySys, ' ', IFNULL(semes, ''), ', ', IFNULL(acad, ''), ' on ',
            DATE_FORMAT(TDate, '%d/%m/%Y'), ' thru ', IFNULL(bankName, 'SchoolPay'), ' TNo: ', tid
        );
        SET DRParticulars = CONCAT(
            'Paid on ', DATE_FORMAT(TDate, '%d/%m/%Y'), ' by ', IFNULL(stud_nm, ''), ' TNo: ', tid
        );

        IF alreadyPosted = 0 THEN
            -- FRESH receipt: post the GL double-entry + tracking row.
            CALL fin_TransactionCreator(
                reg, CRaccountType, CRParticulars, bankCode, 'Chart Account',
                DRParticulars, amount, 0, SYSDATE(), 'autocapture', 'UGX', CONCAT('TransCode:', tid)
            );
            INSERT IGNORE INTO fin_studentfeestracking
                (regno, acadyear, semester, amount, item_code, trans_type, detail, trans_date, post_status)
            SELECT reg, IFNULL(acad, ''), IFNULL(semes, 0), amount, 0, 'Payment', CRParticulars, SYSDATE(), 'Posted' FROM DUAL;
        ELSE
            -- ALREADY posted (re-capture / partial): never re-post the GL; add the tracking row only if missing.
            INSERT INTO fin_studentfeestracking
                (regno, acadyear, semester, amount, item_code, trans_type, detail, trans_date, post_status)
            SELECT reg, IFNULL(acad, ''), IFNULL(semes, 0), amount, 0, 'Payment', CRParticulars, SYSDATE(), 'Posted' FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM fin_studentfeestracking WHERE regno = reg AND detail LIKE CONCAT('%TNo: ', tid));
        END IF;

        UPDATE fin_schoolpaydata SET CaptureStatus = 'Captured' WHERE ReceiptNo = tid;
        CALL fin_UpdateLedgerBalances(reg);
        CALL fin_UpdateLedgerBalances(bankCode);

    END IF;

    COMMIT;
END$$
DELIMITER ;
