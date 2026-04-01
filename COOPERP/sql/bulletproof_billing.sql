-- =====================================================================
-- BULLETPROOF BILLING SYSTEM - Phase 10
-- Campus Dynamics Accounts
-- =====================================================================
-- This script hardens the billing system against double billing by:
-- 1. Recreating fin_TransactionCreatorFn2 with INSERT IGNORE + tracking
-- 2. Recreating fin_TransactionCreatorFn (v1) with same protections
-- 3. Recreating fin_TermlyItemBillingFN with double-guard
-- 4. Recreating fin_SingleTermlyItemBillingFN with improvements
-- 5. Recreating fin_CustomTermlyItemBillingFN with improvements
-- 6. Creating fin_AuditBillingIntegrity SP for anomaly detection
-- =====================================================================

-- =====================================================
-- FUNCTION 1: fin_TransactionCreatorFn2 (HARDENED)
-- Called by: fin_TermlyItemBillingFN
-- Changes: tracking_ref extraction, source_system, INSERT IGNORE
-- =====================================================
DROP FUNCTION IF EXISTS fin_TransactionCreatorFn2;

DELIMITER //

CREATE FUNCTION fin_TransactionCreatorFn2(
    CRaccountcode CHAR(25),
    CRaccountType CHAR(25),
    CRParticulars VARCHAR(350),
    DRaccountcode CHAR(25),
    DRaccountType CHAR(25),
    DRParticulars VARCHAR(350),
    transaction_amount BIGINT,
    voucherNo INT,
    transactionDate DATE,
    teller CHAR(25),
    folio VARCHAR(150),
    curr CHAR(25)
) RETURNS CHAR(65) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE v_tracking_ref INT UNSIGNED DEFAULT NULL;
    DECLARE v_source VARCHAR(25) DEFAULT 'Manual';
    DECLARE v_dr_created INT DEFAULT 0;
    DECLARE v_cr_created INT DEFAULT 0;

    -- Extract tracking_ref from BillNo: folio pattern
    IF folio LIKE 'BillNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 8) AS UNSIGNED);
        SET v_source = 'Billing';
    ELSEIF folio LIKE 'PayNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 7) AS UNSIGNED);
        SET v_source = 'Payment';
    END IF;

    -- INSERT IGNORE: if UNIQUE(tracking_ref, accountcode, transactionType) 
    -- already exists, the insert is silently skipped (no error, no duplicate)
    INSERT IGNORE INTO fin_ledger(
        accountcode, account_type, transactionType, transaction_amount,
        particulars, voucherNo, transactionDate, teller, folio,
        TimeLog, trans_currency, tracking_ref, source_system
    ) VALUES(
        DRaccountcode, DRaccountType, 'DR', transaction_amount,
        DRParticulars, voucherNo, transactionDate, teller, folio,
        SYSDATE(), curr, v_tracking_ref, v_source
    );
    SET v_dr_created = ROW_COUNT();

    INSERT IGNORE INTO fin_ledger(
        accountcode, account_type, transactionType, transaction_amount,
        particulars, voucherNo, transactionDate, teller, folio,
        TimeLog, trans_currency, tracking_ref, source_system
    ) VALUES(
        CRaccountcode, CRaccountType, 'CR', transaction_amount,
        CRParticulars, voucherNo, transactionDate, teller, folio,
        SYSDATE(), curr, v_tracking_ref, v_source
    );
    SET v_cr_created = ROW_COUNT();

    -- Return status: Created/Skipped/Partial
    IF v_dr_created = 1 AND v_cr_created = 1 THEN
        RETURN 'Created';
    ELSEIF v_dr_created = 0 AND v_cr_created = 0 THEN
        RETURN 'Skipped:Exists';
    ELSE
        RETURN 'Partial:Check';
    END IF;
END //

DELIMITER ;


-- =====================================================
-- FUNCTION 2: fin_TransactionCreatorFn (v1 HARDENED)
-- Called by: fin_SingleTermlyItemBillingFN, fin_CustomTermlyItemBillingFN
-- Changes: tracking_ref extraction, source_system, INSERT IGNORE
-- Note: v1 has extra params: invoiceDate, Ref_no
-- =====================================================
DROP FUNCTION IF EXISTS fin_TransactionCreatorFn;

DELIMITER //

CREATE FUNCTION fin_TransactionCreatorFn(
    CRaccountcode CHAR(25),
    CRaccountType CHAR(25),
    CRParticulars VARCHAR(350),
    DRaccountcode CHAR(25),
    DRaccountType CHAR(25),
    DRParticulars VARCHAR(350),
    transaction_amount BIGINT,
    voucherNo INT,
    transactionDate DATE,
    teller CHAR(25),
    folio VARCHAR(150),
    curr CHAR(25),
    invoiceDate DATE,
    Ref_no CHAR(35)
) RETURNS CHAR(65) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE v_tracking_ref INT UNSIGNED DEFAULT NULL;
    DECLARE v_source VARCHAR(25) DEFAULT 'Manual';
    DECLARE v_dr_created INT DEFAULT 0;
    DECLARE v_cr_created INT DEFAULT 0;

    -- Extract tracking_ref from BillNo: folio pattern
    IF folio LIKE 'BillNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 8) AS UNSIGNED);
        SET v_source = 'Billing';
    ELSEIF folio LIKE 'PayNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 7) AS UNSIGNED);
        SET v_source = 'Payment';
    END IF;

    -- INSERT IGNORE: UNIQUE constraint prevents duplicates at DB level
    INSERT IGNORE INTO fin_ledger(
        accountcode, account_type, transactionType, transaction_amount,
        particulars, voucherNo, transactionDate, teller, folio,
        TimeLog, trans_currency, InvoiceDate, RefNo,
        tracking_ref, source_system
    ) VALUES(
        DRaccountcode, DRaccountType, 'DR', transaction_amount,
        DRParticulars, voucherNo, transactionDate, teller, folio,
        SYSDATE(), curr, invoiceDate, Ref_no,
        v_tracking_ref, v_source
    );
    SET v_dr_created = ROW_COUNT();

    INSERT IGNORE INTO fin_ledger(
        accountcode, account_type, transactionType, transaction_amount,
        particulars, voucherNo, transactionDate, teller, folio,
        TimeLog, trans_currency, invoiceDate, RefNo,
        tracking_ref, source_system
    ) VALUES(
        CRaccountcode, CRaccountType, 'CR', transaction_amount,
        CRParticulars, voucherNo, transactionDate, teller, folio,
        SYSDATE(), curr, invoiceDate, Ref_no,
        v_tracking_ref, v_source
    );
    SET v_cr_created = ROW_COUNT();

    IF v_dr_created = 1 AND v_cr_created = 1 THEN
        RETURN 'Created';
    ELSEIF v_dr_created = 0 AND v_cr_created = 0 THEN
        RETURN 'Skipped:Exists';
    ELSE
        RETURN 'Partial:Check';
    END IF;
END //

DELIMITER ;


-- =====================================================
-- FUNCTION 3: fin_TermlyItemBillingFN (HARDENED)
-- The main billing orchestrator
-- Changes: Added secondary ledger check, better status returns
-- =====================================================
DROP FUNCTION IF EXISTS fin_TermlyItemBillingFN;

DELIMITER //

CREATE FUNCTION fin_TermlyItemBillingFN(
    trans CHAR(25),
    reg CHAR(25),
    ItemID INT,
    sems INT,
    prog CHAR(25),
    sess CHAR(25),
    T_Date DATE,
    usr CHAR(25),
    syr INT,
    acadyr CHAR(25),
    csid CHAR(25),
    amt DOUBLE
) RETURNS CHAR(65) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE IncomeAccount, ItemNm, rtn CHAR(150);
    DECLARE existingBill INT DEFAULT 0;
    DECLARE existingLedger INT DEFAULT 0;
    DECLARE lastTID INT DEFAULT 0;

    -- GUARD 1: Check tracking table for existing bill
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

    -- Validate amount
    IF amt <= 0 THEN
        RETURN 'Zero Amount';
    END IF;

    -- Get billing item details
    SELECT AccountCode, ItemName INTO IncomeAccount, ItemNm
    FROM academicbillingitems WHERE ItemCode = ItemID;

    IF IncomeAccount IS NULL THEN
        RETURN 'Invalid Item';
    END IF;

    -- GUARD 2: Check ledger directly for existing DR entry for this student+item
    -- (Belt-and-suspenders: catches cases where tracking was deleted but ledger wasn't)
    SELECT COUNT(*) INTO existingLedger
    FROM fin_ledger
    WHERE accountcode = reg
      AND account_type = 'Student'
      AND transactionType = 'DR'
      AND folio LIKE CONCAT('BillNo:%')
      AND particulars LIKE CONCAT(ItemNm, '%')
      AND particulars LIKE CONCAT('%', acadyr, '%')
      AND particulars LIKE CONCAT('%Term:', sems, '%');

    IF existingLedger > 0 THEN
        RETURN 'Already In Ledger';
    END IF;

    -- Insert tracking entry (Pending)
    INSERT INTO fin_studentfeestracking(
        regno, Amount, item_code, trans_type, post_status,
        acadyear, semester, trans_date, detail
    ) VALUES(
        reg, amt, ItemID, 'Bill', 'Pending',
        acadyr, sems, SYSDATE(),
        CONCAT(ItemNm, ' Term:', sems, ', ', acadyr, ': ', reg)
    );

    SET lastTID = LAST_INSERT_ID();

    -- Create ledger entries via hardened TransactionCreator
    -- The UNIQUE index on (tracking_ref, accountcode, transactionType) provides DB-level guard
    SELECT fin_TransactionCreatorFn2(
        IncomeAccount, 'Chart Account',
        CONCAT(ItemNm, ' Receivable from ', reg,
               ' (', schooldynamics.adm_GetStudNameByAdmNo(reg), ') for Term:', sems, ', ', acadyr),
        reg, 'Student',
        CONCAT(ItemNm, ' for Term:', sems, ', ', acadyr),
        amt,
        fin_NextVoucherNo(usr),
        T_Date, usr,
        CONCAT('BillNo:', lastTID),
        'UGX'
    ) INTO rtn;

    -- Update tracking to Posted
    UPDATE fin_studentfeestracking
    SET post_status = 'Posted'
    WHERE TID = lastTID;

    -- Recalculate balances
    CALL fin_UpdateAllLedgerBalances();

    -- Update journal numbers
    UPDATE fin_ledger
    SET journal_no = CONCAT('JN-', TID)
    WHERE journal_no = '-'
      AND folio = CONCAT('BillNo:', lastTID);

    RETURN CONCAT('Success:', lastTID);
END //

DELIMITER ;


-- =====================================================
-- FUNCTION 4: fin_SingleTermlyItemBillingFN (HARDENED)
-- Changes: Uses INSERT IGNORE, tracking_ref auto-set via v1 function
-- =====================================================
DROP FUNCTION IF EXISTS fin_SingleTermlyItemBillingFN;

DELIMITER //

CREATE FUNCTION fin_SingleTermlyItemBillingFN(
    reg CHAR(25),
    ItemID INT,
    trm INT,
    T_Date DATE,
    usr CHAR(25),
    yr INT,
    cls CHAR(5),
    amt DOUBLE
) RETURNS CHAR(45) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE IncomeAccount, ItemNm, acad, studSys, rtn CHAR(150);
    DECLARE repStatus INT DEFAULT 0;
    DECLARE lastTNo INT DEFAULT 0;
    DECLARE existingBill INT DEFAULT 0;

    -- GUARD: Check for existing bill first
    SELECT COUNT(*) INTO existingBill
    FROM fin_studentfeestracking
    WHERE regno = reg AND acadyear = yr AND semester = trm
      AND item_code = ItemID AND trans_type = 'Bill';

    IF existingBill > 0 THEN
        RETURN 'Already Billed';
    END IF;

    IF amt <= 0 THEN
        RETURN 'Zero Amount';
    END IF;

    SELECT AccountCode, ItemName INTO IncomeAccount, ItemNm
    FROM academicbillingitems WHERE ItemCode = ItemID;

    -- Use INSERT IGNORE to handle race conditions
    INSERT IGNORE INTO fin_studentfeestracking(
        regno, Amount, item_code, trans_type, post_status,
        acadyear, semester, trans_date, detail
    ) VALUES(
        reg, amt, ItemID, 'Bill', 'Pending',
        yr, trm, SYSDATE(),
        CONCAT(ItemNm, ' Term :', trm, ', ', yr, ': ', reg)
    );

    IF ROW_COUNT() = 0 THEN
        RETURN 'Already Billed';
    END IF;

    -- Create ledger entries (v1 function with invoiceDate and RefNo)
    SELECT fin_TransactionCreatorFn(
        IncomeAccount, 'Chart Account',
        CONCAT(ItemNm, ' Receivable from ', regno,
               ' (', schooldynamics.adm_GetStudNameByAdmNo(reg), ') for Term:', trm, ', ', yr),
        regno, 'Student',
        CONCAT(ItemNm, ' for Term :', trm, ', ', yr),
        Amount, fin_NextVoucherNo(usr), T_Date, usr,
        CONCAT('BillNo:', TID), 'UGX', T_Date, NULL
    ) INTO rtn
    FROM fin_studentfeestracking
    WHERE semester = trm AND acadyear = yr AND item_code = ItemID
      AND regno LIKE reg AND post_status != 'Posted' AND amount > 0;

    UPDATE fin_studentfeestracking
    SET post_status = 'Posted'
    WHERE semester = trm AND acadyear = yr AND regno = reg AND item_code = ItemID;

    CALL fin_UpdateAllLedgerBalances();

    RETURN CONCAT('Success');
END //

DELIMITER ;


-- =====================================================
-- FUNCTION 5: fin_CustomTermlyItemBillingFN (HARDENED)
-- Changes: Added existingBill check, INSERT IGNORE, tracking_ref
-- =====================================================
DROP FUNCTION IF EXISTS fin_CustomTermlyItemBillingFN;

DELIMITER //

CREATE FUNCTION fin_CustomTermlyItemBillingFN(
    reg CHAR(25),
    ItemID INT,
    trm INT,
    T_Date DATE,
    usr CHAR(25),
    yr INT,
    amount DOUBLE
) RETURNS CHAR(45) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE IncomeAccount, ItemNm, acad, studSys, rtn CHAR(150);
    DECLARE repStatus INT DEFAULT 0;
    DECLARE lastTNo, nextVNo INT DEFAULT 0;
    DECLARE existingBill INT DEFAULT 0;

    -- GUARD: Check for existing bill first
    SELECT COUNT(*) INTO existingBill
    FROM fin_studentfeestracking
    WHERE regno = reg AND acadyear = yr AND semester = trm
      AND item_code = ItemID AND trans_type = 'Bill';

    IF existingBill > 0 THEN
        RETURN 'Already Billed';
    END IF;

    IF amount <= 0 THEN
        RETURN 'Zero Amount';
    END IF;

    SET nextVNo = fin_NextVoucherNo(usr);
    SELECT AccountCode, ItemName INTO IncomeAccount, ItemNm
    FROM academicbillingitems WHERE ItemCode = ItemID;

    -- Use INSERT IGNORE to handle race conditions
    INSERT IGNORE INTO fin_studentfeestracking(
        regno, Amount, item_code, trans_type, post_status,
        acadyear, semester, trans_date, detail
    ) VALUES(
        reg, amount, ItemID, 'Bill', 'Pending',
        yr, trm, SYSDATE(),
        CONCAT(ItemNm, ' Term :', trm, ', ', yr)
    );

    IF ROW_COUNT() = 0 THEN
        RETURN 'Already Billed';
    END IF;

    SELECT fin_TransactionCreatorFn(
        IncomeAccount, 'Chart Account',
        CONCAT(ItemNm, ' Receivable from ', regno,
               ' (', schooldynamics.adm_GetStudNameByAdmNo(reg), ') for Term:', trm, ', ', yr),
        regno, 'Student',
        CONCAT(ItemNm, ' for Term :', trm, ', ', yr),
        Amount, nextVNo, T_Date, usr,
        CONCAT('BillNo:', TID), 'UGX', T_Date, NULL
    ) INTO rtn
    FROM fin_studentfeestracking
    WHERE semester = trm AND acadyear = yr AND item_code = ItemID
      AND regno LIKE reg AND post_status != 'Posted' AND amount > 0;

    UPDATE fin_studentfeestracking
    SET post_status = 'Posted'
    WHERE semester = trm AND acadyear = yr AND regno = reg AND item_code = ItemID;

    RETURN CONCAT('Success');
END //

DELIMITER ;


-- =====================================================
-- PROCEDURE 6: fin_AuditBillingIntegrity
-- On-demand anomaly detection and reporting
-- =====================================================
DROP PROCEDURE IF EXISTS fin_AuditBillingIntegrity;

DELIMITER //

CREATE PROCEDURE fin_AuditBillingIntegrity(
    IN p_regno VARCHAR(25)  -- NULL = check all students, or specific student
)
BEGIN
    -- 1. ORPHAN TRACKING ENTRIES: tracking rows with post_status='Posted' but no matching ledger entry
    SELECT 'ORPHAN_TRACKING' AS issue_type,
           t.TID AS tracking_tid, t.regno, t.acadyear, t.semester,
           t.item_code, t.amount, t.trans_type, t.post_status,
           CONCAT('Tracking TID ', t.TID, ' has no matching ledger entry') AS description
    FROM fin_studentfeestracking t
    WHERE t.post_status = 'Posted'
      AND t.trans_type = 'Bill'
      AND (p_regno IS NULL OR t.regno = p_regno)
      AND NOT EXISTS (
          SELECT 1 FROM fin_ledger l
          WHERE l.folio = CONCAT('BillNo:', t.TID)
            AND l.transactionType = 'DR'
      )
    LIMIT 100;

    -- 2. ORPHAN LEDGER ENTRIES: ledger BillNo entries with no matching tracking row
    SELECT 'ORPHAN_LEDGER' AS issue_type,
           l.TID AS ledger_tid, l.accountcode, l.folio, l.tracking_ref,
           l.transactionType, l.transaction_amount, l.transactionDate,
           CONCAT('Ledger TID ', l.TID, ' (folio=', l.folio, ') has no matching tracking entry') AS description
    FROM fin_ledger l
    WHERE l.folio LIKE 'BillNo:%'
      AND l.transactionType = 'DR'
      AND l.account_type = 'Student'
      AND (p_regno IS NULL OR l.accountcode = p_regno)
      AND NOT EXISTS (
          SELECT 1 FROM fin_studentfeestracking t
          WHERE CONCAT('BillNo:', t.TID) = l.folio
      )
    LIMIT 100;

    -- 3. DUPLICATE BILLING IN TRACKING: same student billed twice for same item/semester
    SELECT 'DUPLICATE_TRACKING' AS issue_type,
           t.regno, t.acadyear, t.semester, t.item_code, t.trans_type,
           COUNT(*) AS duplicate_count,
           GROUP_CONCAT(t.TID ORDER BY t.TID) AS tracking_tids,
           CONCAT('Student ', t.regno, ' billed ', COUNT(*), ' times for item ', t.item_code) AS description
    FROM fin_studentfeestracking t
    WHERE t.trans_type = 'Bill'
      AND (p_regno IS NULL OR t.regno = p_regno)
    GROUP BY t.regno, t.acadyear, t.semester, t.item_code, t.trans_type
    HAVING COUNT(*) > 1
    LIMIT 100;

    -- 4. DR/CR MISMATCH: billing entries where DR count != CR count for same tracking_ref
    -- Note: DR goes to student account, CR goes to income account (different accountcodes)
    -- So we look at ALL entries for each tracking_ref, not filtered by single account
    IF p_regno IS NOT NULL THEN
        SELECT 'DR_CR_MISMATCH' AS issue_type,
               sub.tracking_ref,
               sub.dr_count,
               sub.cr_count,
               sub.accounts,
               CONCAT('tracking_ref ', sub.tracking_ref, ' has ', sub.dr_count, ' DR and ', sub.cr_count, ' CR') AS description
        FROM (
            SELECT l.tracking_ref,
                   SUM(CASE WHEN l.transactionType = 'DR' THEN 1 ELSE 0 END) AS dr_count,
                   SUM(CASE WHEN l.transactionType = 'CR' THEN 1 ELSE 0 END) AS cr_count,
                   GROUP_CONCAT(DISTINCT l.accountcode) AS accounts
            FROM fin_ledger l
            WHERE l.tracking_ref IS NOT NULL
              AND l.source_system = 'Billing'
              AND l.tracking_ref IN (
                  SELECT DISTINCT tracking_ref FROM fin_ledger
                  WHERE accountcode = p_regno AND tracking_ref IS NOT NULL
              )
            GROUP BY l.tracking_ref
            HAVING dr_count != cr_count
        ) sub
        LIMIT 100;
    ELSE
        SELECT 'DR_CR_MISMATCH' AS issue_type,
               l.tracking_ref,
               SUM(CASE WHEN l.transactionType = 'DR' THEN 1 ELSE 0 END) AS dr_count,
               SUM(CASE WHEN l.transactionType = 'CR' THEN 1 ELSE 0 END) AS cr_count,
               GROUP_CONCAT(DISTINCT l.accountcode) AS accounts,
               CONCAT('tracking_ref ', l.tracking_ref, ' has mismatched DR/CR count') AS description
        FROM fin_ledger l
        WHERE l.tracking_ref IS NOT NULL
          AND l.source_system = 'Billing'
        GROUP BY l.tracking_ref
        HAVING dr_count != cr_count
        LIMIT 100;
    END IF;

    -- 5. SUMMARY STATS
    SELECT 'SUMMARY' AS report_type,
           (SELECT COUNT(*) FROM fin_studentfeestracking WHERE trans_type = 'Bill'
            AND (p_regno IS NULL OR regno = p_regno)) AS total_bills,
           (SELECT COUNT(*) FROM fin_ledger WHERE source_system = 'Billing'
            AND (p_regno IS NULL OR accountcode = p_regno)) AS total_billing_ledger_entries,
           (SELECT COUNT(*) FROM fin_ledger WHERE tracking_ref IS NOT NULL
            AND (p_regno IS NULL OR accountcode = p_regno)) AS total_tracked_entries,
           (SELECT COUNT(DISTINCT tracking_ref) FROM fin_ledger WHERE tracking_ref IS NOT NULL
            AND (p_regno IS NULL OR accountcode = p_regno)) AS unique_tracking_refs;
END //

DELIMITER ;


-- =====================================================
-- PROCEDURE 7: fin_FindDuplicateBilling
-- Quick duplicate finder for a specific student
-- =====================================================
DROP PROCEDURE IF EXISTS fin_FindDuplicateBilling;

DELIMITER //

CREATE PROCEDURE fin_FindDuplicateBilling(
    IN p_regno VARCHAR(25)
)
BEGIN
    -- Show tracking entries
    SELECT 'TRACKING' AS source, t.TID, t.regno, t.acadyear, t.semester,
           t.item_code, t.amount, t.trans_type, t.post_status, t.detail
    FROM fin_studentfeestracking t
    WHERE t.regno = p_regno AND t.trans_type = 'Bill'
    ORDER BY t.acadyear, t.semester, t.item_code;

    -- Show ledger billing entries with tracking link
    SELECT 'LEDGER' AS source, l.TID, l.accountcode, l.transactionType,
           l.transaction_amount, l.folio, l.tracking_ref, l.source_system,
           l.transactionDate, l.particulars
    FROM fin_ledger l
    WHERE l.accountcode = p_regno AND l.account_type = 'Student'
      AND l.folio LIKE 'BillNo:%'
    ORDER BY l.transactionDate, l.TID;

    -- Cross-reference: tracking entries vs ledger entries
    SELECT t.TID AS tracking_tid,
           t.amount AS tracking_amount,
           t.item_code,
           t.acadyear, t.semester,
           IFNULL(l_dr.TID, 'MISSING') AS ledger_dr_tid,
           IFNULL(l_cr.TID, 'MISSING') AS ledger_cr_tid,
           CASE
               WHEN l_dr.TID IS NOT NULL AND l_cr.TID IS NOT NULL THEN 'OK'
               WHEN l_dr.TID IS NULL AND l_cr.TID IS NULL THEN 'ORPHAN_TRACKING'
               ELSE 'PARTIAL'
           END AS status
    FROM fin_studentfeestracking t
    LEFT JOIN fin_ledger l_dr ON l_dr.folio = CONCAT('BillNo:', t.TID)
                              AND l_dr.accountcode = p_regno
                              AND l_dr.transactionType = 'DR'
    LEFT JOIN fin_ledger l_cr ON l_cr.folio = CONCAT('BillNo:', t.TID)
                              AND l_cr.account_type = 'Chart Account'
                              AND l_cr.transactionType = 'CR'
    WHERE t.regno = p_regno AND t.trans_type = 'Bill'
    ORDER BY t.acadyear, t.semester, t.item_code;

    -- Balance summary
    SELECT
        IFNULL(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0) AS total_debits,
        IFNULL(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0) AS total_credits,
        IFNULL(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0) -
        IFNULL(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0) AS net_balance
    FROM (
        -- Ledger entries
        SELECT transactionType, transaction_amount
        FROM fin_ledger
        WHERE accountcode = p_regno AND account_type = 'Student'

        UNION ALL

        -- Tracking entries NOT in ledger (the UNION ALL display logic)
        SELECT 'DR' AS transactionType, t.amount AS transaction_amount
        FROM fin_studentfeestracking t
        WHERE t.regno = p_regno AND t.trans_type = 'Bill'
        AND NOT EXISTS (
            SELECT 1 FROM fin_ledger l
            WHERE l.accountcode = t.regno AND l.account_type = 'Student'
              AND l.transactionType = 'DR' AND l.voucherNo = t.TID
        )
        AND NOT EXISTS (
            SELECT 1 FROM fin_ledger l
            WHERE l.accountcode = t.regno AND l.account_type = 'Student'
              AND l.transactionType = 'DR' AND l.folio = CONCAT('BillNo:', t.TID)
        )
        AND NOT EXISTS (
            SELECT 1 FROM fin_ledger l
            WHERE l.accountcode = t.regno AND l.account_type = 'Student'
              AND l.transactionType = 'DR'
              AND l.transaction_amount = t.amount
              AND l.transactionDate = DATE(t.trans_date)
              AND l.particulars LIKE CONCAT('%', t.detail, '%')
        )
    ) combined;
END //

DELIMITER ;
