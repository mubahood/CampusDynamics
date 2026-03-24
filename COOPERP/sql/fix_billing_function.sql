-- Fix fin_TermlyItemBillingFN: Add pre-check to prevent duplicate bills
-- The old Index_UNQ included the 'detail' column which varied between runs,
-- allowing duplicates even with INSERT IGNORE. That index has been dropped.
-- This pre-check is the new protection against double-billing.

DROP FUNCTION IF EXISTS fin_TermlyItemBillingFN;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `fin_TermlyItemBillingFN`(
  billType CHAR(15),
  reg CHAR(25),
  ItemID INT,
  sems INT,
  prog CHAR(25),
  sess CHAR(25),
  T_Date DATE,
  usr CHAR(25),
  yr INT,
  acadyr CHAR(15),
  csid CHAR(25),
  amt DOUBLE
) RETURNS char(25) CHARSET latin1
DETERMINISTIC
BEGIN

DECLARE IncomeAccount,ItemNm,acad,studSys,rtn CHAR(150);
DECLARE repStatus INT DEFAULT 0;
DECLARE lastTNo INT DEFAULT 0;
DECLARE existingBill INT DEFAULT 0;

-- ============================================================
-- PRE-CHECK: Prevent duplicate billing for same student/year/semester/item
-- This replaces the broken Index_UNQ that included the 'detail' column
-- ============================================================
SELECT COUNT(*) INTO existingBill
FROM fin_studentfeestracking
WHERE regno = reg
  AND acadyear = acadyr
  AND semester = sems
  AND item_code = ItemID
  AND trans_type = 'Bill';

IF existingBill > 0 THEN
  RETURN 'Already Billed';
END IF;

-- Skip zero or negative amounts
IF amt <= 0 THEN
  RETURN 'Zero Amount';
END IF;

SELECT AccountCode, ItemName INTO IncomeAccount, ItemNm
FROM academicbillingitems
WHERE ItemCode = ItemID LIMIT 1;

SELECT study_system INTO studSys
FROM campus_dynamics.acad_programme
WHERE progcode = prog;

INSERT INTO fin_studentfeestracking(
  regno, Amount, item_code, trans_type, post_status,
  acadyear, semester, trans_date, detail
)
VALUES(
  reg, amt, ItemID, 'Bill', 'Pending',
  acadyr, sems, SYSDATE(),
  CONCAT(ItemNm, ' Sem :', sems, ', ', acadyr, ': ', reg, ' [', csid, ']')
);

SELECT fin_TransactionCreatorFn2(
  IncomeAccount, 'Chart Account',
  CONCAT(ItemNm, ' Receivable from ',
    regno, ' (', campus_dynamics.acad_GetStudNameByID(reg), ') for ',
    studSys, ':', sems, ', ', acadyr),
  regno, fin_GetStudentLedgerName(regno),
  CONCAT(ItemNm, ' for ', studSys, ':', sems, ', ', acadyr, ' ', csid),
  Amount, fin_NextVoucherNo(usr), T_Date, usr,
  CONCAT('BillNo:', TID), 'UGX'
) INTO rtn
FROM fin_studentfeestracking
WHERE semester = sems
  AND acadyear = acadyr
  AND item_code = ItemID
  AND regno = reg
  AND post_status = 'Pending'
  AND amount > 0
LIMIT 1;

UPDATE fin_studentfeestracking
SET post_status = 'Posted'
WHERE semester = sems
  AND acadyear = acadyr
  AND regno = reg
  AND item_code = ItemID;

CALL fin_UpdateAllLedgerBalances();

UPDATE fin_ledger
SET journal_no = fin_transactionNo(accountcode, account_type, TID)
WHERE journal_no = '-';

RETURN '1 Bill';

END$$

DELIMITER ;
