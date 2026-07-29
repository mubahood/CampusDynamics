-- ============================================================================
-- FIX: align fin_GetLimitedStudentLedger NET to the canonical balance (2026-06-26)
-- Cause: SB/CB display-suppression over-counted duplicate same-day tracking payments
--        (report showed 803,000CR vs canonical 783,000CR for MRU2024001364).
--  1) keep ALL fin_ledger rows (drop step-1 SB/CB suppression)
--  2) step-2 tracking dedup matches ANY ledger row (drop SB/CB exclusion) -> twin suppressed
--  3) cosmetic relabel kept bank/cash credit rows on the printout
-- Backup/rollback: _backup_routines_20260626.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_GetLimitedStudentLedger;
DELIMITER $$
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_GetLimitedStudentLedger`(

    reg CHAR(25) CHARSET utf8,

    sDate DATE,

    eDate DATE

)
BEGIN

    DECLARE accName, photo CHAR(100) CHARSET utf8;

    DECLARE opDate DATE;

    DECLARE opBalanceNum DECIMAL(20,2) DEFAULT 0.00;



    SET accName = CONCAT(campus_dynamics.acad_GetStudnameByID(reg), ' [', reg, ']');



    SELECT photofile

      INTO photo

      FROM campus_dynamics.acad_student

     WHERE regno = reg

     LIMIT 1;



    UPDATE fin_ledger

       SET curr_balance = fin_GetCurrentBalance(accountcode, TID, account_type)

     WHERE accountcode = reg;



    UPDATE fin_ledger

       SET journal_no = fin_transactionNo(accountcode, account_type, TID)

     WHERE journal_no = '-'

       AND accountcode = reg;



    DROP TEMPORARY TABLE IF EXISTS tmp_student_ledger_all;



    CREATE TEMPORARY TABLE tmp_student_ledger_all

    (

        source_rank INT NOT NULL,

        TID BIGINT NOT NULL,

        accountcode VARCHAR(50),

        account_type VARCHAR(80),

        transactionType VARCHAR(5),

        transaction_amount DECIMAL(20,2),

        dr_num DECIMAL(20,2),

        cr_num DECIMAL(20,2),

        particulars TEXT,

        voucherNo VARCHAR(120),

        realVoucherno VARCHAR(120),

        transactionDate DATE,

        teller VARCHAR(100),

        timeLog DATETIME,

        folio VARCHAR(120),

        trans_currency VARCHAR(20),

        KEY idx_date_tid (transactionDate, TID)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /*

      1. Normal fin_ledger rows.

      SB/CB migration rows are shown only if there is no matching tracking payment.

    */

    INSERT INTO tmp_student_ledger_all

    (

        source_rank, TID, accountcode, account_type, transactionType,

        transaction_amount, dr_num, cr_num, particulars,

        voucherNo, realVoucherno, transactionDate, teller, timeLog, folio, trans_currency

    )

    SELECT

        1 AS source_rank,

        fl.TID,

        fl.accountcode,

        fl.account_type,

        fl.transactionType,

        CASE

            WHEN fl.actual_amount IS NOT NULL AND fl.actual_amount <> 0

            THEN fl.actual_amount

            ELSE fl.transaction_amount

        END AS transaction_amount,

        CASE

            WHEN fl.transactionType = 'DR'

            THEN CASE

                    WHEN fl.actual_amount IS NOT NULL AND fl.actual_amount <> 0

                    THEN fl.actual_amount

                    ELSE fl.transaction_amount

                 END

            ELSE 0

        END AS dr_num,

        CASE

            WHEN fl.transactionType = 'CR'

            THEN CASE

                    WHEN fl.actual_amount IS NOT NULL AND fl.actual_amount <> 0

                    THEN fl.actual_amount

                    ELSE fl.transaction_amount

                 END

            ELSE 0

        END AS cr_num,

        CASE WHEN fl.transactionType='CR' AND COALESCE(fl.source_system,'') IN ('SB_COLLECTIONS','CB_COLLECTIONS') THEN 'Fees Payment (Bank/Cash Collection)' ELSE fl.particulars END,

        fl.journal_no AS voucherNo,

        fl.voucherNo AS realVoucherno,

        DATE(fl.transactionDate) AS transactionDate,

        fl.teller,

        fl.timeLog,

        fl.folio,

        fl.trans_currency

    FROM fin_ledger fl

    WHERE fl.accountcode = reg

      AND DATE(fl.transactionDate) <= eDate

      ;



    /*

      2. Tracking fallback rows.

      This keeps DR bills/payments that are not in normal fin_ledger.

      Created By is blank, not Tracking.

    */

    INSERT INTO tmp_student_ledger_all

    (

        source_rank, TID, accountcode, account_type, transactionType,

        transaction_amount, dr_num, cr_num, particulars,

        voucherNo, realVoucherno, transactionDate, teller, timeLog, folio, trans_currency

    )

    SELECT

        2 AS source_rank,

        t.TID,

        t.regno AS accountcode,

        'Student' AS account_type,

        CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END AS transactionType,

        t.amount AS transaction_amount,

        CASE WHEN t.trans_type = 'Bill' THEN t.amount ELSE 0 END AS dr_num,

        CASE WHEN t.trans_type IN ('Payment','Waiver') THEN t.amount ELSE 0 END AS cr_num,

        t.detail AS particulars,

        CAST(t.TID AS CHAR) AS voucherNo,

        CAST(t.TID AS CHAR) AS realVoucherno,

        DATE(t.trans_date) AS transactionDate,

        '' AS teller,

        t.trans_date AS timeLog,

        t.regno AS folio,

        'UGX' AS trans_currency

    FROM fin_studentfeestracking t

    WHERE t.regno = reg

      AND t.post_status = 'Posted'

      AND DATE(t.trans_date) <= eDate

      AND NOT EXISTS (

          SELECT 1

            FROM fin_ledger fl2

           WHERE fl2.accountcode = t.regno

             AND (

                    fl2.voucherNo = CAST(t.TID AS CHAR)

                 OR fl2.folio    = CONCAT('BillNo:', CAST(t.TID AS CHAR))

                 OR (

                        DATE(fl2.transactionDate) = DATE(t.trans_date)

                    AND fl2.transactionType =

                        CASE

                            WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR'

                            ELSE 'DR'

                        END

                    AND ROUND(

                            CASE

                                WHEN fl2.actual_amount IS NOT NULL AND fl2.actual_amount <> 0

                                THEN fl2.actual_amount

                                ELSE fl2.transaction_amount

                            END, 2

                        ) = ROUND(t.amount, 2)

                    AND (

                            fl2.particulars = t.detail

                         OR t.detail IS NULL

                         OR t.detail = ''

                         OR t.trans_type IN ('Payment','Waiver')

                        )

                    )

             )

      );



    SELECT

        COALESCE(SUM(dr_num - cr_num), 0)

      INTO opBalanceNum

      FROM tmp_student_ledger_all

     WHERE transactionDate < sDate;



    SELECT

        COALESCE(MAX(transactionDate), sDate)

      INTO opDate

      FROM tmp_student_ledger_all

     WHERE transactionDate < sDate;



    DROP TEMPORARY TABLE IF EXISTS tmp_student_ledger_period;



    CREATE TEMPORARY TABLE tmp_student_ledger_period

    (

        seq BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,

        source_rank INT NOT NULL,

        TID BIGINT NOT NULL,

        accountcode VARCHAR(50),

        account_type VARCHAR(80),

        transactionType VARCHAR(5),

        transaction_amount DECIMAL(20,2),

        dr_num DECIMAL(20,2),

        cr_num DECIMAL(20,2),

        particulars TEXT,

        voucherNo VARCHAR(120),

        realVoucherno VARCHAR(120),

        transactionDate DATE,

        teller VARCHAR(100),

        timeLog DATETIME,

        folio VARCHAR(120),

        trans_currency VARCHAR(20)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_student_ledger_period

    (

        source_rank, TID, accountcode, account_type, transactionType,

        transaction_amount, dr_num, cr_num, particulars,

        voucherNo, realVoucherno, transactionDate, teller, timeLog, folio, trans_currency

    )

    SELECT

        source_rank, TID, accountcode, account_type, transactionType,

        transaction_amount, dr_num, cr_num, particulars,

        voucherNo, realVoucherno, transactionDate, teller, timeLog, folio, trans_currency

    FROM tmp_student_ledger_all

    WHERE transactionDate BETWEEN sDate AND eDate

    ORDER BY transactionDate, TID, source_rank;



    SET @runningBal := opBalanceNum;



    SELECT

        z.photo,

        z.accName,

        z.stud_details,

        z.dr_amount,

        z.cr_amount,

        z.formated_date,

        z.TID,

        z.accountcode,

        z.account_type,

        z.transactionType,

        z.transaction_amount,

        z.particulars,

        z.voucherNo,

        z.realVoucherno,

        z.transactionDate,

        z.teller,

        z.timeLog,

        z.folio,

        z.curr_balance,

        z.trans_currency

    FROM

    (

        SELECT

            0 AS out_seq,

            photo AS photo,

            accName AS accName,

            CONCAT(fin_GetStudyDetails(reg),

                   ' \nLEDGER PERIOD [', DATE_FORMAT(sDate,'%d-%m-%Y'),

                   ' TO ', DATE_FORMAT(eDate,'%d-%m-%Y'), ']') AS stud_details,

            '' AS dr_amount,

            '' AS cr_amount,

            '' AS formated_date,

            0 AS TID,

            '' AS accountcode,

            '' AS account_type,

            '' AS transactionType,

            0 AS transaction_amount,

            'Opening Balance' AS particulars,

            '' AS voucherNo,

            '' AS realVoucherno,

            opDate AS transactionDate,

            '' AS teller,

            SYSDATE() AS timeLog,

            '' AS folio,

            CASE

                WHEN opBalanceNum > 0 THEN CONCAT(FORMAT(opBalanceNum,0), 'DR')

                WHEN opBalanceNum < 0 THEN CONCAT(FORMAT(ABS(opBalanceNum),0), 'CR')

                ELSE '0CR'

            END AS curr_balance,

            '' AS trans_currency



        UNION ALL



        SELECT

            q.seq AS out_seq,

            photo AS photo,

            accName AS accName,

            CONCAT(fin_GetStudyDetails(reg),

                   ' \nLEDGER PERIOD [', DATE_FORMAT(sDate,'%d-%m-%Y'),

                   ' TO ', DATE_FORMAT(eDate,'%d-%m-%Y'), ']') AS stud_details,

            IF(q.dr_num > 0, FORMAT(q.dr_num,0), '') AS dr_amount,

            IF(q.cr_num > 0, FORMAT(q.cr_num,0), '') AS cr_amount,

            DATE_FORMAT(q.transactionDate, '%d-%m-%Y') AS formated_date,

            q.TID,

            q.accountcode,

            q.account_type,

            q.transactionType,

            q.transaction_amount,

            q.particulars,

            q.voucherNo,

            q.realVoucherno,

            q.transactionDate,

            q.teller,

            q.timeLog,

            q.folio,

            CASE

                WHEN q.running_balance > 0 THEN CONCAT(FORMAT(q.running_balance,0), 'DR')

                WHEN q.running_balance < 0 THEN CONCAT(FORMAT(ABS(q.running_balance),0), 'CR')

                ELSE '0CR'

            END AS curr_balance,

            q.trans_currency

        FROM

        (

            SELECT

                p.*,

                (@runningBal := @runningBal + p.dr_num - p.cr_num) AS running_balance

            FROM tmp_student_ledger_period p

            ORDER BY p.seq

        ) q

    ) z

    ORDER BY z.out_seq;



    DROP TEMPORARY TABLE IF EXISTS tmp_student_ledger_period;

    DROP TEMPORARY TABLE IF EXISTS tmp_student_ledger_all;



END$$
DELIMITER ;

