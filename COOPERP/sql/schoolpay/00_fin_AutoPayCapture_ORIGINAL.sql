-- ============================================================================
-- ORIGINAL fin_AutoPayCapture (campus_dynamics_accounts) — pre-2026-06-30 backup.
-- Kept verbatim for ROLLBACK only. Run this file to restore the original engine
-- (note: the original is NOT double-post-proof — re-capturing a partial row would
-- double-credit the student; that is exactly why 01_fin_AutoPayCapture_hardened.sql
-- replaced it). Do not deploy this except to revert.
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_AutoPayCapture;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutoPayCapture`(reg CHAR(25), stud_nm CHAR(65),bankCode CHAR(25),amount DOUBLE,TDate DATE,
teller CHAR(25),bankName VARCHAR(250),tid CHAR(45))
BEGIN

DECLARE CRaccountType,DRParticulars,CRParticulars,StudySys,acad VARCHAR(200);
DECLARE TransNo,semes,TCheck,currYear INT;

SELECT acad_year,semester,studyYear INTO acad,semes,currYear FROM campus_dynamics.acad_registration WHERE regno=reg ORDER BY ID DESC LIMIT 1;

SELECT COUNT(*) INTO TCheck FROM fin_schoolpaydata WHERE receiptno=tid AND CaptureStatus='Pending';


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

  CALL fin_TransactionCreator(reg,CRaccountType,CRParticulars,bankCode, 'Chart Account',DRParticulars,amount,0, SYSDATE(), teller,'UGX',CONCAT('TransCode:',tid));

  INSERT IGNORE INTO fin_studentfeestracking(regno, acadyear,semester,amount, item_code, trans_type,detail,trans_date,post_status)
  SELECT reg,acad,semes,amount,0,'Payment',CRParticulars,SYSDATE(),'Posted' FROM DUAL;

  UPDATE fin_schoolpaydata SET CaptureStatus='Captured' WHERE ReceiptNo=tid;
  CALL fin_UpdateLedgerBalances(reg);
  CALL fin_UpdateLedgerBalances(bankCode);

END IF;

COMMIT;

END$$
DELIMITER ;
