-- =============================================================================
-- Fix: Make fin_GetStudentLedger & fin_GetLimitedStudentLedger include tracking
--      rows that have no corresponding GL entry.
--
-- Problem:  These SPs only read fin_ledger. When a billing row exists ONLY in
--           fin_studentfeestracking (e.g. the GL entry was wrongly deleted, or
--           the dual-write trigger hadn't been deployed yet), the SP misses it
--           and reports a lower balance than StudentFees.aspx which merges both
--           tables.
--
-- Fix:      Add  UNION ALL  fin_studentfeestracking rows with NOT EXISTS dedup.
--           Uses 3 match strategies identical to StudentFees.aspx.cs:
--             1. fl.voucherNo = tracking.TID   (GLSync rows use TID as voucherNo)
--             2. fl.folio = 'BillNo:<TID>'     (original billing writes folio)
--             3. amount + date + type + particulars  (fallback)
--
-- Safe to run multiple times — DROP IF EXISTS + CREATE.
-- =============================================================================

DELIMITER $$

-- ─────────────────────────────────────────────────────────────
-- 1) fin_GetStudentLedger  (used by dashboard, admin StudentLedger)
-- ─────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS fin_GetStudentLedger$$

CREATE PROCEDURE fin_GetStudentLedger(reg CHAR(25) CHARSET utf8)
BEGIN
    DECLARE accName CHAR(100);

    SET accName = CONCAT(campus_dynamics.acad_GetStudNameByID(reg), ' [', reg, ']');

    UPDATE fin_ledger
       SET curr_balance = fin_GetCurrentBalance(accountcode, TID, account_type)
     WHERE accountcode = reg;

    -- Main SELECT: fin_ledger rows  UNION ALL  tracking-only rows
    SELECT accName,
           fin_GetStudyDetails(reg)                                   AS stud_details,
           IF(transactionType = 'DR', FORMAT(transaction_amount,0), '') AS dr_amount,
           IF(transactionType = 'CR', FORMAT(transaction_amount,0), '') AS cr_amount,
           DATE_FORMAT(transactionDate, '%D %M, %Y')                  AS formated_date,
           TID, accountcode, account_type, transactionType,
           transaction_amount, particulars,
           journal_no  AS voucherNo,
           voucherNo   AS realVoucherno,
           transactionDate, teller, timeLog, folio,
           curr_balance, trans_currency
      FROM fin_ledger
     WHERE accountcode = reg

    UNION ALL

    SELECT accName,
           fin_GetStudyDetails(reg)                                              AS stud_details,
           IF(t.trans_type = 'Bill', FORMAT(t.amount,0), '')                     AS dr_amount,
           IF(t.trans_type IN ('Payment','Waiver'), FORMAT(t.amount,0), '')      AS cr_amount,
           DATE_FORMAT(t.trans_date, '%D %M, %Y')                               AS formated_date,
           t.TID,
           t.regno                                                               AS accountcode,
           'Student'                                                             AS account_type,
           CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END AS transactionType,
           t.amount                                                              AS transaction_amount,
           t.detail                                                              AS particulars,
           CAST(t.TID AS CHAR)                                                   AS voucherNo,
           CAST(t.TID AS CHAR)                                                   AS realVoucherno,
           t.trans_date                                                          AS transactionDate,
           'Tracking'                                                            AS teller,
           t.trans_date                                                          AS timeLog,
           t.regno                                                               AS folio,
           ''                                                                    AS curr_balance,
           'UGX'                                                                 AS trans_currency
      FROM fin_studentfeestracking t
     WHERE t.regno = reg
       AND t.post_status = 'Posted'
       AND NOT EXISTS (
           SELECT 1 FROM fin_ledger fl2
            WHERE fl2.accountcode = t.regno
              AND (
                    fl2.voucherNo = CAST(t.TID AS CHAR)
                 OR fl2.folio    = CONCAT('BillNo:', CAST(t.TID AS CHAR))
                 OR (     fl2.transaction_amount = t.amount
                      AND DATE(fl2.transactionDate) = DATE(t.trans_date)
                      AND fl2.transactionType = CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END
                      AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
                    )
              )
       )
    ORDER BY TID;
END$$


-- ─────────────────────────────────────────────────────────────
-- 2) fin_GetLimitedStudentLedger  (used by doc_verification StudentLedger report)
-- ─────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS fin_GetLimitedStudentLedger$$

CREATE PROCEDURE fin_GetLimitedStudentLedger(reg CHAR(25) CHARSET utf8, sDate DATE, eDate DATE)
BEGIN
    DECLARE accName, op_balance, cr_bal, dr_bal, photo CHAR(100) CHARSET utf8;
    DECLARE opDate DATE;
    DECLARE yr, trm INT;

    SET accName = CONCAT(campus_dynamics.acad_GetStudnameByID(reg), ' [', reg, ']');

    SELECT photofile INTO photo
      FROM campus_dynamics.acad_student
     WHERE regno = reg;

    UPDATE fin_ledger
       SET curr_balance = fin_GetCurrentBalance(accountcode, TID, account_type)
     WHERE accountcode = reg;

    UPDATE fin_ledger
       SET journal_no = fin_transactionNo(accountcode, account_type, TID)
     WHERE journal_no = '-' AND accountcode = reg;

    SELECT curr_balance, transactionDate
      INTO op_balance, opDate
      FROM fin_ledger
     WHERE accountcode = reg AND transactionDate < sDate
     ORDER BY TID DESC LIMIT 1;

    SET op_balance = IF(op_balance IS NULL, '0CR', op_balance);
    SET opDate     = IF(opDate IS NULL, sDate, opDate);

    -- Opening-balance row
    SELECT photo, accName,
           CONCAT(fin_GetStudyDetails(reg),
                  ' \nLEDGER PERIOD [', DATE_FORMAT(sDate,'%d-%m-%Y'),
                  ' TO ', DATE_FORMAT(eDate,'%d-%m-%Y'), ']') AS stud_details,
           dr_bal  AS dr_amount,
           cr_bal  AS cr_amount,
           ''      AS formated_date,
           0       AS TID,
           ''      AS accountcode,
           ''      AS account_type,
           ''      AS transactionType,
           0       AS transaction_amount,
           'Opening Balance' AS particulars,
           ''      AS voucherNo,
           ''      AS realVoucherno,
           opDate  AS transactionDate,
           ''      AS teller,
           SYSDATE() AS timeLog,
           ''      AS folio,
           op_balance AS curr_balance,
           ''      AS trans_currency
      FROM DUAL

    UNION

    -- GL entries
    SELECT photo, accName,
           fin_GetStudyDetails(reg) AS stud_details,
           IF(transactionType = 'DR', FORMAT(transaction_amount,0), '') AS dr_amount,
           IF(transactionType = 'CR', FORMAT(transaction_amount,0), '') AS cr_amount,
           DATE_FORMAT(transactionDate, '%d-%m-%Y') AS formated_date,
           TID, accountcode, account_type, transactionType,
           transaction_amount, particulars,
           journal_no AS voucherNo,
           voucherNo  AS realVoucherno,
           transactionDate, teller, timeLog, folio,
           curr_balance, trans_currency
      FROM fin_ledger
     WHERE accountcode = reg

    UNION ALL

    -- Tracking-only rows (no corresponding GL entry)
    SELECT photo, accName,
           fin_GetStudyDetails(reg)                                              AS stud_details,
           IF(t.trans_type = 'Bill', FORMAT(t.amount,0), '')                     AS dr_amount,
           IF(t.trans_type IN ('Payment','Waiver'), FORMAT(t.amount,0), '')      AS cr_amount,
           DATE_FORMAT(t.trans_date, '%d-%m-%Y')                                 AS formated_date,
           t.TID,
           t.regno                                                               AS accountcode,
           'Student'                                                             AS account_type,
           CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END AS transactionType,
           t.amount                                                              AS transaction_amount,
           t.detail                                                              AS particulars,
           CAST(t.TID AS CHAR)                                                   AS voucherNo,
           CAST(t.TID AS CHAR)                                                   AS realVoucherno,
           t.trans_date                                                          AS transactionDate,
           'Tracking'                                                            AS teller,
           t.trans_date                                                          AS timeLog,
           t.regno                                                               AS folio,
           ''                                                                    AS curr_balance,
           'UGX'                                                                 AS trans_currency
      FROM fin_studentfeestracking t
     WHERE t.regno = reg
       AND t.post_status = 'Posted'
       AND NOT EXISTS (
           SELECT 1 FROM fin_ledger fl2
            WHERE fl2.accountcode = t.regno
              AND (
                    fl2.voucherNo = CAST(t.TID AS CHAR)
                 OR fl2.folio    = CONCAT('BillNo:', CAST(t.TID AS CHAR))
                 OR (     fl2.transaction_amount = t.amount
                      AND DATE(fl2.transactionDate) = DATE(t.trans_date)
                      AND fl2.transactionType = CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END
                      AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
                    )
              )
       )

    ORDER BY TID;
END$$

DELIMITER ;
