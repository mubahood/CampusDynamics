-- ============================================================================
-- BACKUP (pre-fix) of fin_GetStudentLedger — campus_dynamics_accounts
-- Captured 2026-06-25 before applying the payment-dedup "Fix B".
-- Rollback: run this file to restore the ORIGINAL (buggy) behaviour.
-- The ONLY difference vs the fixed version is the dedup clause:
--   ORIGINAL: AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_GetStudentLedger;
DELIMITER $$
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_GetStudentLedger`(reg CHAR(25) CHARSET utf8)
BEGIN
    DECLARE accName CHAR(100);
    SET accName = CONCAT(campus_dynamics.acad_GetStudNameByID(reg), ' [', reg, ']');

    UPDATE fin_ledger
       SET curr_balance = fin_GetCurrentBalance(accountcode, TID, account_type)
     WHERE accountcode = reg;

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
           DATE_FORMAT(t.trans_date, '%D %M, %Y')                                AS formated_date,
           t.TID,
           t.regno                                                               AS accountcode,
           'Student'                                                             AS account_type,
           CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END AS transactionType,
           t.amount                                                              AS transaction_amount,
           t.detail                                                              AS particulars,
           CAST(t.TID AS CHAR)                                                   AS voucherNo,
           CAST(t.TID AS CHAR)                                                   AS realVoucherno,
           t.trans_date                                                          AS transactionDate,
           ''                                                                    AS teller,
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
