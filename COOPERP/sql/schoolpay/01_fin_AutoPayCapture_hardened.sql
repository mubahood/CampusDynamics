-- ============================================================================
-- HARDENED fin_AutoPayCapture  (campus_dynamics_accounts)   deployed 2026-06-30
-- ----------------------------------------------------------------------------
-- The SchoolPay GL-posting engine, made double-post-proof for EVERY caller
-- (live webhook, admin "Recapture Selected" button, and the auto-sweep).
--
-- Only change vs the original: an indexed guard (folio = 'TransCode:<tid>',
-- Index_3 on fin_ledger) so the GL double-entry is created AT MOST ONCE per
-- receipt, and the fin_studentfeestracking row is added at most once.
--   * FRESH receipt  -> identical to the original (alreadyPosted = 0). Hot path
--                       unchanged: one indexed COUNT(*) then the normal post.
--   * RE-CAPTURE / PARTIAL (alreadyPosted > 0) -> never re-posts the GL; adds the
--                       tracking row only if missing (regno-narrowed NOT EXISTS,
--                       runs only on this rare path). Self-heals partial posts.
-- Rollback: restore 00_fin_AutoPayCapture_ORIGINAL.sql.
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_AutoPayCapture;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutoPayCapture`(reg CHAR(25), stud_nm CHAR(65), bankCode CHAR(25), amount DOUBLE, TDate DATE,
teller CHAR(25), bankName VARCHAR(250), tid CHAR(45))
BEGIN

DECLARE CRaccountType,DRParticulars,CRParticulars,StudySys,acad VARCHAR(200);
DECLARE TransNo,semes,TCheck,currYear INT;
DECLARE alreadyPosted INT DEFAULT 0;

SELECT acad_year,semester,studyYear INTO acad,semes,currYear FROM campus_dynamics.acad_registration WHERE regno=reg ORDER BY ID DESC LIMIT 1;

SELECT COUNT(*) INTO TCheck FROM fin_schoolpaydata WHERE receiptno=tid AND CaptureStatus='Pending';

-- has the GL double-entry for this receipt already been posted? (indexed on folio)
SELECT COUNT(*) INTO alreadyPosted FROM fin_ledger WHERE folio=CONCAT('TransCode:',tid);

START TRANSACTION;

IF TCheck=1 THEN

  SET CRaccountType=fin_GetStudentLedgerName(reg);
  SET CRParticulars=CONCAT('Fees Payment for ',StudySys,' ',semes,', ',acad,' on ',
  DATE_FORMAT(TDate,'%d/%m/%Y'),' thru ',bankName,' TNo: ',tid);
  SET DRParticulars=CONCAT('Paid on ',DATE_FORMAT(TDate,'%d/%m/%Y'),' by ',stud_nm,' TNo: ',tid);

  IF CRParticulars IS NULL THEN
  SET CRParticulars=CONCAT('Fees Payment  on ',
  DATE_FORMAT(TDate,'%d/%m/%Y'),' thru ',bankName,' TNo: ',tid);
  END IF;

  IF alreadyPosted=0 THEN
    -- FRESH receipt (hot path): post the GL double-entry + tracking row (identical to the
    -- original; nothing exists yet so no de-dup check is needed and the hot path stays fast)
    CALL fin_TransactionCreator(reg,CRaccountType,CRParticulars,bankCode, 'Chart Account',DRParticulars,amount,0, SYSDATE(), teller,'UGX',CONCAT('TransCode:',tid));
    INSERT IGNORE INTO fin_studentfeestracking(regno, acadyear,semester,amount, item_code, trans_type,detail,trans_date,post_status)
    SELECT reg,acad,semes,amount,0,'Payment',CRParticulars,SYSDATE(),'Posted' FROM DUAL;
  ELSE
    -- ALREADY posted (re-capture / partial completion): never re-post the GL; add the
    -- tracking row only if it is missing (regno-narrowed; only runs on this rare path).
    INSERT INTO fin_studentfeestracking(regno, acadyear,semester,amount, item_code, trans_type,detail,trans_date,post_status)
    SELECT reg,acad,semes,amount,0,'Payment',CRParticulars,SYSDATE(),'Posted' FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM fin_studentfeestracking WHERE regno=reg AND detail LIKE CONCAT('%TNo: ',tid));
  END IF;

  UPDATE fin_schoolpaydata SET CaptureStatus='Captured' WHERE ReceiptNo=tid;
  CALL fin_UpdateLedgerBalances(reg);
  CALL fin_UpdateLedgerBalances(bankCode);

END IF;

COMMIT;

END$$
DELIMITER ;
