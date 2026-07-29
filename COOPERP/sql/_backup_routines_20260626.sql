-- MySQL dump 10.13  Distrib 5.6.43, for Win64 (x86_64)
--
-- Host: 102.34.160.47    Database: campus_dynamics_accounts
-- ------------------------------------------------------
-- Server version	5.6.43-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'campus_dynamics_accounts'
--
/*!50003 DROP FUNCTION IF EXISTS `acad_GetStudentClearanceStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `acad_GetStudentClearanceStatus`(reg varchar(25),sems int,acads varchar(15)) RETURNS varchar(25) CHARSET latin1
BEGIN

DECLARE stat VARCHAR(25);



SELECT examClearance INTO stat FROM campus_dynamics.acad_registration WHERE regno=reg AND acad_year=acads AND

semester=sems ORDER BY studyyear DESC LIMIT 1;



RETURN stat;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `acc_GetNameByAdmno` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `acc_GetNameByAdmno`(adm CHAR(25)) RETURNS char(35) CHARSET utf8
BEGIN



DECLARE nm CHAR(35);

SELECT stud_names INTO nm FROM student WHERE adm_no=adm LIMIT 1;

RETURN IF(nm IS NULL,'-',nm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `acc_NewAdmNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `acc_NewAdmNo`(entyr INTEGER,stat VARCHAR(15),clas INT) RETURNS char(25) CHARSET utf8
BEGIN



DECLARE admn CHAR(25);

DECLARE lastNo INT;





SELECT MAX(SUBSTRING(adm_no,13,3)) INTO lastNo FROM student WHERE entry_year=entyr ;





IF lastNo IS NULL THEN

   SET lastNo=1;

ELSE

   SET lastNo=lastNo+1;

END IF;



SET admn=CONCAT('ZIPS-',clas,IF(stat='BOARDING','B','D'),'-',SUBSTRING(entyr,3,2),'-',LPAD(lastNo,3,0));









RETURN admn;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_AutoClearance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_AutoClearance`(cat CHAR(25),reg CHAR(25), acad CHAR(15), sem INT,cyr INT,

usr CHAR(35)) RETURNS char(45) CHARSET utf8
BEGIN

DECLARE prog,studSys,c_stat,sess,r_stat CHAR(45);

DECLARE eyr INT;

DECLARE t_amount,f_amount,p_amount,e_amount,op_amount,cur_bal,b_amount DOUBLE;

DECLARE sDate,eDate DATE;



SELECT progid,entryyear,studsesion INTO prog,eyr,sess FROM campus_dynamics.acad_student WHERE regno=reg;

SELECT study_system INTO studSys FROM campus_dynamics.acad_programme WHERE progcode=prog;

SELECT examClearance,regstatus INTO c_stat,r_stat FROM campus_dynamics.acad_registration WHERE regno=reg AND acad_year=acad AND semester=sem LIMIT 1;



SELECT amount INTO t_amount FROM fin_fees_structure fs, fin_fees_pay_schedule ps,academicbillingitems bi

WHERE ps.ItemID=fs.ID AND bi.ItemCode=fs.ItemCode AND progid=prog AND studyyear=cyr AND semester=sem AND studsession=sess

AND ItemName LIKE 'Tuition%' AND entry_year=eyr LIMIT 1;



SELECT SUM(amount) INTO f_amount FROM fin_fees_structure fs, fin_fees_pay_schedule ps,academicbillingitems bi

WHERE ps.ItemID=fs.ID AND bi.ItemCode=fs.ItemCode AND progid=prog AND studyyear=cyr AND semester=sem AND studsession=sess

AND ItemName NOT LIKE 'Tuition%' AND entry_year=eyr;



SELECT event_date INTO sDate FROM campus_dynamics.acad_calenda WHERE acad_year=acad AND semester=sem AND item_name='Start Date'

AND study_system=studSys ;

SELECT event_date INTO eDate FROM campus_dynamics.acad_calenda WHERE acad_year=acad AND semester=sem AND item_name='End Date'

AND study_system=studSys;



SET op_amount=fin_GetFeesBalance('Opening',sDate,eDate,reg);

SET p_amount=fin_GetFeesBalance('TotalPay',sDate,eDate,reg);

SET b_amount=fin_GetFeesBalance('TotalBill',sDate,eDate,reg);

SET cur_bal=fin_GetFeesBalance('Current',sDate,eDate,reg);



SET e_amount=(t_amount*0.6)+f_amount;



IF cat='REG' THEN



  IF (op_amount+p_amount)>=e_amount  THEN



   IF r_stat='UNREGISTERED' AND b_amount!=0 THEN

    UPDATE campus_dynamics.acad_registration SET regstatus='CLEARED' WHERE regno=reg AND acad_year=acad AND semester=sem;

    INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

    VALUES (usr,'Reg. Clearance',CONCAT('REG NO: ',reg,'STAT: ',r_stat,', ACAD: ',acad,', SEM: ',sem),'Cleared Student for Registration',SYSDATE());

   END IF;

   RETURN CONCAT('CLEARED');

  ELSE

  RETURN CONCAT(r_stat);

  END IF;



ELSE



  IF (cur_bal<=0) THEN



   IF r_stat NOT IN ('UNREGISTERED','DEAD YEAR') AND c_stat!='CLEARED' AND b_amount!=0 THEN

     UPDATE campus_dynamics.acad_registration SET examClearance='CLEARED',examClearanceDate=SYSDATE(),clearedBy=usr

     WHERE regno=reg AND acad_year=acad AND semester=sem;

     INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

     VALUES (usr,'Exam Clearance',CONCAT('REG NO: ',reg,'STAT: ',r_stat,', ACAD: ',acad,', SEM: ',sem),'Cleared Student for Exams',SYSDATE());

   END IF;



  RETURN CONCAT('CLEARED');

  ELSE

  RETURN 'UNCLEARED';

  END IF;



END IF;













END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_AutoReco` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_AutoReco`(bid INT,parts CHAR(250),dt DATE, amt DOUBLE, threshold INT) RETURNS int(11)
BEGIN

DECLARE trackNo INT;



SELECT TID INTO trackNo FROM fin_ledger WHERE MATCH (particulars) AGAINST (parts) AND transactionType='DR'

 AND transaction_amount=amt AND transactiondate BETWEEN DATE_SUB(dt,INTERVAL threshold DAY) and  DATE_ADD(dt,INTERVAL threshold DAY) AND TID NOT IN

 (SELECT match_TID FROM fin_reco_bank_entries) LIMIT 1;

SET trackNo=IF(trackNo IS NULL,0,trackNo);

UPDATE fin_reco_bank_entries SET match_tid=trackNo WHERE ID=bid;

RETURN trackNo;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_BalanceSheetSubTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_BalanceSheetSubTotals`(typ CHAR(15), sDate DATE, eDate DATE, item CHAR(25)) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus BIGINT;

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE SubCategory=item)

AS findata;


RETURN IF(typ='CR',IF(cramt=0,'',FORMAT(cramt,0)),IF(dramt=0,'',FORMAT(dramt,0)));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_BalanceSheetTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_BalanceSheetTotals`(typ CHAR(15), sDate DATE, eDate DATE, item CHAR(25)) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus BIGINT;

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory=item)

AS findata;


RETURN IF(typ='CR',IF(cramt=0,'',FORMAT(cramt,0)),IF(dramt=0,'',FORMAT(dramt,0)));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_basicVoucherDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_basicVoucherDetails`(vno INT) RETURNS text CHARSET utf8
BEGIN

DECLARE vDetails,drName TEXT;

SELECT fin_GetVoucherAccountNames(account_type,accountcode) INTO drName FROM fin_voucher

WHERE voucherNo=vno AND transactiontype='CR';

SELECT particulars INTO vDetails FROM fin_voucher WHERE voucherNo=vno AND transactiontype='CR';

RETURN IF(vDetails IS NULL,'-',CONCAT(vDetails,' thru ',drName));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_BenefitCaculator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_BenefitCaculator`(memno CHAR(25), bid INT, percent DOUBLE) RETURNS bigint(20)
BEGIN

DECLARE billItem CHAR(25);

DECLARE amount BIGINT;

SELECT amountsetting INTO billItem FROM fin_benefits f where benefitid=bid;

IF billItem='Shares' THEN

SELECT SUM(transaction_amount)*percent INTO amount FROM fin_ledger WHERE  transactiontype='CR' and account_type='Shares'

AND accountcode=memno;

ELSE

SELECT SUM(transaction_amount)*percent INTO amount FROM fin_ledger WHERE  transactiontype='CR' and account_type='Savings'

AND accountcode=memno;

END IF;



RETURN IF(amount IS NULL,0,amount);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_BenefitCheck` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_BenefitCheck`(memID CHAR(25), mnth CHAR(15), yr INT, pid INT) RETURNS int(11)
BEGIN

DECLARE chck INT;

SELECT COUNT(*) INTO chck FROM fin_benefitpayments WHERE memberID=memID AND benefit_month=mnth AND benefit_year=yr AND benefitID=pid;

RETURN chck;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_BenefitQualifier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_BenefitQualifier`(memno CHAR(25), bid INT, percent DOUBLE) RETURNS bigint(20)
BEGIN

DECLARE billItem CHAR(25);

DECLARE amount BIGINT;

SELECT amountsetting INTO billItem FROM fin_benefits f where benefitid=bid;

IF billItem='Shares' THEN

SELECT SUM(transaction_amount) INTO amount FROM fin_ledger WHERE  transactiontype='CR' and account_type='Shares'

AND accountcode=memno;

ELSE

SELECT SUM(transaction_amount) INTO amount FROM fin_ledger WHERE  transactiontype='CR' and account_type='Savings'

AND accountcode=memno;

END IF;



RETURN IF(amount IS NULL OR amount<500000,0,1);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_BillCounter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_BillCounter`(reg CHAR(25),sems INT,acad CHAR(25)) RETURNS int(11)
BEGIN

DECLARE counter INT;

SELECT COUNT(*) INTO counter FROM fin_studentfeestracking WHERE regno=reg AND semester=sems AND trans_type='Bill' AND acadyear=acad;

RETURN counter;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_CheckStudentBillItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_CheckStudentBillItem`(admno CHAR(25),ItemID INT,trm INT, yr  CHAR(15), cls CHAR(25)) RETURNS int(11)
BEGIN

DECLARE chk INT;

SELECT COUNT(*) INTO chk FROM fin_studentfeestracking

WHERE term_sem=trm AND acadyear=yr AND class_course=cls AND stream=strm AND itemCode=ItemID AND adm_no = admno ;

RETURN chk;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_CustomTermlyItemBillingFN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_CustomTermlyItemBillingFN`(
    reg CHAR(25),
    ItemID INT,
    trm INT,
    T_Date DATE,
    usr CHAR(25),
    yr INT,
    amount DOUBLE
) RETURNS char(45) CHARSET utf8
    DETERMINISTIC
BEGIN
    DECLARE IncomeAccount, ItemNm, acad, studSys, rtn CHAR(150);
    DECLARE repStatus INT DEFAULT 0;
    DECLARE lastTNo, nextVNo INT DEFAULT 0;
    DECLARE existingBill INT DEFAULT 0;

    
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_DeleteStudentBillLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_DeleteStudentBillLedger`(admno CHAR(25),ItemID INT,trm INT, yr  CHAR(15), cls CHAR(25)) RETURNS int(11)
BEGIN

DELETE FROM fin_Ledger WHERE folio LIKE CONCAT(admno,',Item:',ItemID,',Term:',trm,',Year:',yr,',Class:',cls);

RETURN 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_EquityLiabilityTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_EquityLiabilityTotals`(typ CHAR(15), sDate DATE, eDate DATE) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus,balances BIGINT;

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory IN

('Expense','Income','Equity','Liabilities'))

AS findata;

SET balances=dramt-cramt+fin_GetSurplusDeficit(sDate);

RETURN IF(typ='CR',IF(balances>0,'',FORMAT(ABS(balances),0)),IF(balances<0,'',FORMAT(ABS(balances),0)));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_EquityTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_EquityTotals`(typ CHAR(15), sDate DATE, eDate DATE) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus,balances BIGINT;

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory IN ('Expense','Income','Equity'))

AS findata;

SET balances=dramt-cramt;

RETURN IF(typ='CR',IF(balances>0,'',FORMAT(ABS(balances),0)),IF(balances<0,'',FORMAT(ABS(balances),0)));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_ExpenseTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_ExpenseTotals`(typ CHAR(15), sDate DATE, eDate DATE) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus BIGINT;

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory='Expense')

AS findata;

RETURN IF(typ='CR',IF(cramt=0,'',FORMAT(cramt,0)),IF(dramt=0,'',FORMAT(dramt,0)));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_FeesTrackTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_FeesTrackTotals`(admno CHAR(25), TType CHAR(25), trm INT,yr INT,cls INT) RETURNS double
BEGIN

DECLARE totalAMount DOUBLE;

SELECT SUM(T_Amount) INTO totalAMount FROM fin_studentfeestracking

WHERE class_course=cls AND stream=strm AND acadyear=yr AND term_sem=trm AND adm_no=admno AND T_Type=TType;

RETURN IF(totalAMount IS NULL,0,totalAMount);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GeneralJournalCreator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GeneralJournalCreator`(_TID INT, jtype CHAR(200)) RETURNS int(11)
BEGIN



DECLARE nextVNo INT;

DECLARE details,billno VARCHAR(250);

DECLARE usr CHAR(45);



SELECT voucherno,particulars,Teller INTO nextVNo,details,usr FROM fin_ledger WHERE TID=_TID;



INSERT IGNORE INTO fin_journalnumbers(Teller, PostStatus, journalType, journalDate, journalParticulars, journal_serialno,GL_Voucherno)

VALUES(usr,'Posted',jtype,DATE(SYSDATE()),details,fin_NextJournalSerial(jtype),nextVno);



RETURN 1;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetAccountByLedgerType` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetAccountByLedgerType`(typ CHAR(25)) RETURNS char(20) CHARSET latin1
BEGIN

DECLARE acc_code CHAR(20);

SELECT accountcode INTO acc_code from fin_subaccounts where collectionledgertype=typ LIMIT 1;

RETURN IF(acc_code IS NULL,'-',acc_code);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetAccountByVoucherNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetAccountByVoucherNo`(typ CHAR(25)) RETURNS char(20) CHARSET latin1
BEGIN

DECLARE acc_code CHAR(20);

SELECT accountcode INTO acc_code from fin_subaccounts where collectionledgertype=typ LIMIT 1;

RETURN IF(acc_code IS NULL,'-',acc_code);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetAccountCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetAccountCategory`(accNo CHAR(25)) RETURNS char(45) CHARSET utf8
BEGIN

DECLARE accCat CHAR(45);

SELECT generalCategory INTO accCat FROM fin_subaccounts s, fin_mainaccounts m WHERE s.AccountCode=accNo AND

s.mainaccountcode=m.accountcode LIMIT 1;

RETURN IF(accCat IS NULL,'-',accCat);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetAccountName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetAccountName`(code CHAR(35)) RETURNS char(150) CHARSET utf8
BEGIN

DECLARE acc_name CHAR(150);

SELECT AccountName INTO acc_name FROM fin_subaccounts WHERE accountCode=code;

RETURN IF(acc_name IS NULL,'-',acc_name);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetAccountSubCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetAccountSubCategory`(accNo CHAR(25)) RETURNS char(45) CHARSET utf8
BEGIN

DECLARE accCat CHAR(45);

SELECT subCategory INTO accCat FROM fin_subaccounts s, fin_mainaccounts m WHERE s.AccountCode=accNo AND

s.mainaccountcode=m.accountcode;

RETURN IF(accCat IS NULL,'-',accCat);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetAssetLedgerCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetAssetLedgerCategory`(code CHAR(15), typ CHAR(25)) RETURNS char(30) CHARSET utf8
BEGIN



DECLARE category CHAR(30);

SELECT erp.proper_case(AssetCategoryName) INTO category FROM fixedassetregister r JOIN assetcategory a ON r.assetCategory=a.catID WHERE assetID=code;

RETURN IF(category IS NULL,'-',IF(typ='Asset',CONCAT('Asset ',category),CONCAT('Depreciation ',category)));



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetBaseCurrency` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetBaseCurrency`(acc CHAR(30)) RETURNS char(5) CHARSET utf8
BEGIN

DECLARE b_curr CHAR(5);

SELECT base_currency INTO b_curr FROM fin_subaccounts WHERE AccountCode=acc;

RETURN IF(b_curr IS NULL,'UGX',b_curr);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetBillItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetBillItems`(reg CHAR(25), acad CHAR(25),sem INT) RETURNS varchar(250) CHARSET utf8
BEGIN

DECLARE billItems CHAR(250);

SELECT GROUP_CONCAT(ItemName) INTO billItems FROM academicbillingitems it JOIN fin_studentfeestracking ft

ON it.ItemCode=ft.item_code WHERE ft.regno=reg AND acadyear=acad AND semester=sem;

RETURN IF(billItems IS NULL,'-',billItems);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetBudgetValues` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetBudgetValues`(fyr INT, acc CHAR(25),cat CHAR(25)) RETURNS double
BEGIN



DECLARE totalCR,totalDR,bal DOUBLE;

DECLARE sDate,eDate DATE;

SELECT start_date,end_date INTO sDate,eDate FROM fin_financial_periods WHERE ID=fyr LIMIT 1;

SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger WHERE accountcode=acc AND transactiontype='CR' AND transactionDate BETWEEN sDate AND eDate;

SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger WHERE accountcode=acc AND transactiontype='DR' AND transactionDate BETWEEN sDate AND eDate;





SET totalCR=IF(totalCR IS NULL,0,totalCR);

SET totalDR=IF(totalDR IS NULL,0,totalDR);



IF cat='Income' THEN

  SET bal=totalCR-totalDR;

ELSE

  SET bal=totalDR-totalCR;

END IF;





RETURN IF(bal IS NULL,0,bal);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetCanonicalStudentBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetCanonicalStudentBalance`(reg VARCHAR(50)) RETURNS decimal(20,2)
    READS SQL DATA
BEGIN
    DECLARE bal DECIMAL(20,2);
    SELECT IFNULL( SUM(CASE WHEN x.ttype='DR' THEN x.amt ELSE 0 END)
                 - SUM(CASE WHEN x.ttype='CR' THEN x.amt ELSE 0 END), 0)
      INTO bal
    FROM (
        SELECT fl.transactionType AS ttype, fl.transaction_amount AS amt
          FROM fin_ledger fl
         WHERE fl.accountcode = reg AND fl.transaction_amount > 0
        UNION ALL
        SELECT CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END AS ttype,
               t.amount AS amt
          FROM fin_studentfeestracking t
         WHERE t.regno = reg AND t.post_status = 'Posted'
           AND NOT EXISTS (
               SELECT 1 FROM fin_ledger fl2
                WHERE fl2.accountcode = t.regno
                  AND ( fl2.voucherNo = CAST(t.TID AS CHAR)
                     OR fl2.folio    = CONCAT('BillNo:', CAST(t.TID AS CHAR))
                     OR ( fl2.transaction_amount = t.amount
                          AND DATE(fl2.transactionDate) = DATE(t.trans_date)
                          AND fl2.transactionType = CASE WHEN t.trans_type IN ('Payment','Waiver') THEN 'CR' ELSE 'DR' END
                          AND (t.trans_type IN ('Payment','Waiver') OR fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
                        )
                  )
           )
    ) x;
    RETURN IFNULL(bal, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetChartAccountLegderType` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetChartAccountLegderType`(accCode CHAR(25)) RETURNS char(100) CHARSET utf8
    DETERMINISTIC
BEGIN

    DECLARE accType CHAR(100);



    SELECT collectionLedgerType INTO accType

      FROM fin_subaccounts f

     WHERE accountcode = accCode;



    RETURN IF(accType IS NULL, '-', accType);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetCurrentBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetCurrentBalance`(accCode CHAR(25),T_ID INT,typ CHAR(45)) RETURNS char(45) CHARSET utf8
BEGIN

DECLARE balance,CR,DR DOUBLE;



IF LENGTH(accCode)>10 THEN



SELECT SUM(transaction_amount) INTO CR FROM fin_ledger WHERE accountcode=accCode AND TID<=T_ID AND transactionType='CR';

SELECT SUM(transaction_amount) INTO DR FROM fin_ledger WHERE accountcode=accCode AND TID<=T_ID AND transactionType='DR';



ELSE



SELECT SUM(transaction_amount) INTO CR FROM fin_ledger WHERE accountcode=accCode AND TID<=T_ID AND transactionType='CR' AND

account_type=typ;

SELECT SUM(transaction_amount) INTO DR FROM fin_ledger WHERE accountcode=accCode AND TID<=T_ID AND transactionType='DR' AND

account_type=typ;



END IF;



IF DR IS NULL THEN

SET DR=0;

END IF;



IF CR IS NULL THEN

SET CR=0;

END IF;



SET balance=DR-CR;



RETURN IF(balance < 0, CONCAT(FORMAT(ABS(balance),0),'CR'),CONCAT(FORMAT(ABS(balance),0),'DR'));



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetCurrentFeesBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetCurrentFeesBalance`(regno CHAR(25)) RETURNS char(45) CHARSET latin1
    READS SQL DATA
BEGIN
    DECLARE curTrmBal DOUBLE;
    SET curTrmBal = fin_GetCanonicalStudentBalance(regno);
    IF curTrmBal IS NULL THEN SET curTrmBal=0; END IF;
    IF curTrmBal<=0 THEN
        RETURN CONCAT(FORMAT(ABS(curTrmBal),0),' CREDIT');
    ELSE
        RETURN CONCAT(FORMAT(ABS(curTrmBal),0),' DEBIT');
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetCurrentStudentBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetCurrentStudentBalance`(accCode CHAR(25)) RETURNS char(45) CHARSET utf8
    READS SQL DATA
BEGIN
    DECLARE balance DOUBLE;
    SET balance = fin_GetCanonicalStudentBalance(accCode);
    IF balance IS NULL THEN SET balance=0; END IF;
    RETURN IF(balance < 0, CONCAT(FORMAT(ABS(balance),0),' CREDIT'),CONCAT(FORMAT(ABS(balance),0),' DEBIT'));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetDateCurrentBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetDateCurrentBalance`(accCode CHAR(25),dt DATE, typ CHAR(45),T_ID INT) RETURNS char(45) CHARSET utf8
BEGIN

DECLARE balance,CR,DR,CR_Corr,DR_Corr DOUBLE;



IF LENGTH(accCode)>10 THEN



SELECT SUM(actual_amount) INTO CR FROM fin_ledger WHERE accountcode=accCode AND transactionDate<=dt AND TID<=T_ID AND transactionType='CR'

ORDER BY transactionDate, TID;

SELECT SUM(actual_amount) INTO DR FROM fin_ledger WHERE accountcode=accCode AND transactionDate<=dt AND TID<=T_ID AND transactionType='DR'

ORDER BY transactionDate, TID;



SELECT SUM(actual_amount) INTO CR_Corr FROM fin_ledger WHERE accountcode=accCode AND transactionDate<dt AND TID>T_ID AND transactionType='CR'

ORDER BY transactionDate, TID;

SELECT SUM(transaction_amount) INTO DR_Corr FROM fin_ledger WHERE accountcode=accCode AND transactionDate<dt AND TID>T_ID AND transactionType='DR'

ORDER BY transactionDate, TID;



ELSE



SELECT SUM(actual_amount) INTO CR FROM fin_ledger WHERE accountcode=accCode AND transactionDate<=dt AND TID<=T_ID AND transactionType='CR' AND

account_type=typ ORDER BY transactionDate, TID;



SELECT SUM(actual_amount) INTO DR FROM fin_ledger WHERE accountcode=accCode AND transactionDate<=dt AND TID<=T_ID AND transactionType='DR' AND

account_type=typ ORDER BY transactionDate, TID;



SELECT SUM(actual_amount) INTO CR_Corr FROM fin_ledger WHERE accountcode=accCode AND transactionDate<dt AND TID>T_ID AND transactionType='CR' AND

account_type=typ ORDER BY transactionDate, TID;



SELECT SUM(actual_amount) INTO DR_Corr FROM fin_ledger WHERE accountcode=accCode AND transactionDate<dt AND TID>T_ID AND transactionType='DR' AND

account_type=typ ORDER BY transactionDate, TID;



END IF;



SET CR_Corr=IF(CR_Corr IS NULL,0,CR_Corr);

SET DR_Corr=IF(DR_Corr IS NULL,0,DR_Corr);



IF DR IS NULL THEN

SET DR=0;

END IF;



IF CR IS NULL THEN

SET CR=0;

END IF;



SET balance=(DR+DR_Corr)-(CR+CR_Corr);



RETURN IF(balance < 0, CONCAT(FORMAT(ABS(balance),0),'CR'),CONCAT(FORMAT(ABS(balance),0),'DR'));



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetDepreciation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetDepreciation`(assetCode CHAR(15)) RETURNS int(20)
BEGIN



DECLARE depreciation,origCost DOUBLE;

SELECT depreciationrate,originalCost INTO depreciation,origCost FROM fixedassetregister WHERE assetID=assetCode;

RETURN IF(depreciation IS NULL,0,depreciation*origCost/1200);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetDepreciationValues` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetDepreciationValues`(assetID CHAR(25), months CHAR(15),yr INT,cat CHAR(15)) RETURNS int(20)
BEGIN



DECLARE amount INT(20);



IF cat='Monthly' THEN



SELECT depAmount INTO Amount FROM  depreciationrecords WHERE assetCode=assetID AND currMonth=months AND currYear=yr;



ELSE



SELECT SUM(depAmount) INTO   Amount FROM  depreciationrecords WHERE assetCode=assetID;



END IF;



RETURN IF(Amount IS NULL,0,Amount);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetDrillDownCloseBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetDrillDownCloseBalance`(
    accNo CHAR(30),
    startDate DATE,
    endDate DATE,
    l_type CHAR(35)
) RETURNS bigint(20)
    DETERMINISTIC
BEGIN
    DECLARE op_num DOUBLE;

    DECLARE totalCR, totalDR, bal, openingBal BIGINT;
    DECLARE accType, ledgerTypes, accCat CHAR(45);

    SELECT collectionLedgerType, accounttype, generalCategory
    INTO ledgerTypes, accType, accCat
    FROM fin_subaccounts s, fin_mainaccounts m
    WHERE s.AccountCode = accNo
      AND s.mainaccountcode = m.accountcode;

    SET openingBal = 0;

    IF accType IS NOT NULL THEN

        SELECT SUM(transaction_amount)
        INTO totalCR
        FROM fin_ledger f
        WHERE transactiontype = 'CR'
          AND account_type = accType
          AND transactiondate BETWEEN startDate AND endDate
          AND accountcode = accNo;

        SELECT SUM(transaction_amount)
        INTO totalDR
        FROM fin_ledger f
        WHERE transactiontype = 'DR'
          AND account_type = accType
          AND transactiondate BETWEEN startDate AND endDate
          AND accountcode = accNo;

    ELSE

        SELECT SUM(transaction_amount)
        INTO totalCR
        FROM fin_ledger f
        WHERE transactiontype = 'CR'
          AND accountcode = accNo
          AND transactiondate BETWEEN startDate AND endDate;

        SELECT SUM(transaction_amount)
        INTO totalDR
        FROM fin_ledger f
        WHERE transactiontype = 'DR'
          AND accountcode = accNo
          AND transactiondate BETWEEN startDate AND endDate;

    END IF;

    IF totalDR IS NULL THEN
        SET totalDR = 0;
    END IF;

    IF totalCR IS NULL THEN
        SET totalCR = 0;
    END IF;

    RETURN (totalDR - totalCR);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetFeesBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetFeesBalance`(typ CHAR(15),

sDate DATE,eDate DATE, regno CHAR(25)) RETURNS double
BEGIN

DECLARE curTrmBal,lastTrmBal,lastYrBal,totalPay,TotalBill DOUBLE;





SELECT (SUM(IF(TransactionType='DR',transaction_amount,0))-SUM(IF(TransactionType='CR',transaction_amount,0))) INTO lastYrBal FROM

fin_ledger WHERE transactionDate<sDate AND accountcode=regno;



IF typ='Current' THEN



SELECT (SUM(IF(TransactionType='DR',transaction_amount,0))-SUM(IF(TransactionType='CR',transaction_amount,0))) INTO curTrmBal FROM

fin_ledger WHERE transactionDate BETWEEN sDate AND eDate AND accountcode=regno;

END IF;



IF typ IN ('TotalBill','TotalPay') THEN



SELECT SUM(IF(TransactionType='DR',transaction_amount,0)),SUM(IF(TransactionType='CR',transaction_amount,0))

INTO TotalBill,totalPay FROM fin_ledger WHERE transactionDate BETWEEN sDate AND eDate AND accountcode=regno;



END IF;



IF lastYrBal IS NULL THEN

SET lastYrBal=0;

END IF;



IF curTrmBal IS NULL THEN

SET curTrmBal=0;

END IF;



IF typ='Opening' THEN

  RETURN lastYrBal;

ELSEIF typ='TotalPay' THEN

  RETURN IF(totalPay IS NULL,0,totalPay);

ELSEIF typ='TotalBill' THEN

  RETURN IF(TotalBill IS NULL,0,TotalBill);

ELSE

  RETURN lastYrBal+curTrmBal;

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetFeesPayable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetFeesPayable`(reg CHAR(25),itemID INT, yr INT, sem INT,cyr INT) RETURNS double
BEGIN

DECLARE stat,scholarshipAmount,billAmount DOUBLE;

DECLARE eyr INT;

DECLARE prog,sess VARCHAR(25);



SELECT progid,studsesion INTO prog,sess FROM campus_dynamics.acad_student WHERE regno=reg;



SELECT amount INTO billAmount FROM fin_fees_structure f WHERE progid=prog AND curr_year=yr AND itemCode=itemID AND studsession=sess AND

study_year=cyr LIMIT 1;



RETURN IF(billAmount IS NULL,0,billAmount);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetGLPeriodBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetGLPeriodBalance`(startDate DATE, endDate DATE, accNo CHAR(35), mainacc CHAR(25)

 ) RETURNS char(35) CHARSET utf8
BEGIN

DECLARE totalCR, totalDR, bal,openingBal DOUBLE;

DECLARE accType,ledgerTypes,accCat CHAR(45);

SELECT collectionLedgerType, accounttype,generalCategory INTO ledgerTypes,accType,accCat FROM fin_subaccounts s, fin_mainaccounts m

WHERE s.AccountCode=mainacc AND s.mainaccountcode=m.accountcode;



SET openingBal=0;



IF accCat IN ('Assets','Liabilities','Equity') THEN

SET openingBal=fin_GetOpeningBalance(startDate,accNo);

END IF;





SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f

WHERE transactiontype='CR' AND accountcode=accNo  AND transactiondate BETWEEN startDate AND endDate;

SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f

WHERE transactiontype='DR' AND accountcode=accNo  AND transactiondate BETWEEN startDate AND endDate;



IF totalDR IS NULL THEN

SET totalDR=0;

END IF;

IF totalCR IS NULL THEN

SET totalCR=0;

END IF;

SET bal=(totalDR-totalCR)+openingBal;

RETURN CONCAT(FORMAT(ABS(bal),0),IF(bal<0,'CR','DR'));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetIncomeAccountByVoucherNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetIncomeAccountByVoucherNo`(typ CHAR(25), vno INT) RETURNS char(20) CHARSET latin1
BEGIN

DECLARE acc_code,reg,ltype CHAR(30);

IF(typ='LedgerType') THEN

SELECT accountcode INTO reg FROM fin_ledger WHERE voucherno=vno AND transactiontype='DR' LIMIT 1;

SET acc_code=fin_GetStudentIncomeName(reg);

ELSE

SELECT accountcode INTO reg FROM fin_ledger WHERE voucherno=vno AND transactiontype='DR' LIMIT 1;

SET ltype=fin_GetStudentIncomeName(reg);

SELECT accountcode INTO acc_code from fin_subaccounts where collectionledgertype=ltype LIMIT 1;

END IF;



RETURN IF(acc_code IS NULL,'-',acc_code);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetIncomeRuningBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetIncomeRuningBalance`(amt DOUBLE, typ CHAR(15)) RETURNS char(30) CHARSET utf8
BEGIN

IF @initial_amt IS NULL THEN

IF typ='CR' THEN

SET @initial_amt=amt;

ELSE

SET @initial_amt=(amt*-1);

END IF;

ELSE

IF typ='CR' THEN

SET @initial_amt=@initial_amt+amt;

ELSE

SET @initial_amt=@initial_amt-amt;

END IF;

END IF;



RETURN IF(@initial_amt<0,CONCAT(FORMAT(ABS(@initial_amt),0),'DR'),CONCAT(FORMAT(ABS(@initial_amt),0),'CR'));





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetJournalTotalCR_DR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetJournalTotalCR_DR`(typ CHAR(5), jno INT) RETURNS double
BEGIN
    DECLARE amt DOUBLE;
    DECLARE jtype CHAR(25);

    SELECT journaltype INTO jType
    FROM fin_journalnumbers
    WHERE JournalNo = jno
    LIMIT 1;

    SELECT SUM(transaction_amount) INTO amt
    FROM fin_journal_details
    WHERE (TRIM(journal_no) = CAST(jno AS CHAR) OR TRIM(journal_no) = CONCAT('JN-', jno))
      AND transactionType = typ
      AND journal_type = jtype;

    RETURN IF(amt IS NULL, 0, amt);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetJournalType` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetJournalType`(acc CHAR(25)) RETURNS char(200) CHARSET utf8
BEGIN

DECLARE jn_type,mainacc_name,maincode,acc_name CHAR(200);

SELECT mainaccountcode,accountname INTO maincode,acc_name FROM fin_subaccounts WHERE accountcode=acc LIMIT 1;

SELECT AccountName INTO mainacc_name FROM fin_mainaccounts WHERE AccountCode=maincode LIMIT 1;



IF mainacc_name LIKE '%CASH%' OR mainacc_name LIKE '%BANK%' THEN



RETURN CONCAT(acc_name);



ELSE

RETURN 'Student';

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetLedgerAccountName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetLedgerAccountName`(accType CHAR(25), accNo CHAR(25)) RETURNS varchar(150) CHARSET utf8
BEGIN



  DECLARE accName VARCHAR(150);



  IF accType = 'Chart Account' THEN



    SELECT accountName INTO accName FROM fin_subaccounts WHERE accountcode = accNo LIMIT 1;

    IF accName IS NULL THEN

      SET accName = CONCAT('[DELETED: ', accNo, ']');

    END IF;



  ELSEIF accType IN (SELECT LedgerTypeName FROM fin_ledgertypes WHERE ledgertypecategory = 'Student') THEN



    SELECT CONCAT(othername, ' ', firstname) INTO accName FROM campus_dynamics.acad_student WHERE regno = accNo LIMIT 1;

    IF accName IS NULL OR TRIM(accName) = '' THEN

      SET accName = CONCAT('[STUDENT: ', accNo, ']');

    END IF;



  ELSEIF accType IN (SELECT LedgerTypeName FROM fin_ledgertypes WHERE ledgertypecategory = 'Employee') THEN



    SELECT emp_name INTO accName FROM campus_dynamics.hrm_employee WHERE empID = accNo LIMIT 1;

    IF accName IS NULL THEN

      SET accName = CONCAT('[STAFF: ', accNo, ']');

    END IF;



  ELSEIF accType = 'Sponsor' THEN



    SELECT scholarshipName INTO accName FROM scholarships WHERE scholarshipID = accNo LIMIT 1;

    IF accName IS NULL THEN

      SET accName = CONCAT('[SPONSOR: ', accNo, ']');

    END IF;



  ELSEIF accType = 'Supplier' THEN



    SELECT supplierName INTO accName FROM inv_supplierdetails WHERE suppliercode = accNo LIMIT 1;

    IF accName IS NULL THEN

      SET accName = CONCAT('[SUPPLIER: ', accNo, ']');

    END IF;



  ELSE



    SET accName = CONCAT('[TYPE?: ', accType, ' / ', accNo, ']');



  END IF;



  RETURN accName;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetLedgerClosingBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetLedgerClosingBalance`(endDate DATE,accNo CHAR(30),l_type CHAR(35)) RETURNS bigint(20)
BEGIN

DECLARE totalCR, totalDR, bal,openingBal BIGINT;

DECLARE accType,ledgerTypes,accCat CHAR(45);

SELECT collectionLedgerType, accounttype,generalCategory INTO ledgerTypes,accType,accCat

FROM fin_subaccounts s, fin_mainaccounts m WHERE s.AccountCode=accNo AND

s.mainaccountcode=m.accountcode;



IF l_type='Student' THEN

SET l_type=fin_GetStudentLedgerName(accno);

END IF;



SET openingBal=0;



IF accType IS NULL THEN





SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f

WHERE transactiontype='CR' AND account_type=l_type AND transactiondate <= endDate AND accountcode=accNo;

SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f

WHERE transactiontype='DR' AND account_type=l_type AND transactiondate <= endDate AND accountcode=accNo;



ELSE





SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f

WHERE transactiontype='CR' AND accountcode=accNo  AND transactiondate <= endDate;

SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f

WHERE transactiontype='DR' AND accountcode=accNo AND transactiondate <= endDate;





END  IF;





IF totalDR IS NULL THEN

SET totalDR=0;

END IF;

IF totalCR IS NULL THEN

SET totalCR=0;

END IF;

RETURN (totalDR-totalCR);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetLedgerOpeningBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetLedgerOpeningBalance`(startDate DATE,accNo CHAR(30),l_type CHAR(35)) RETURNS bigint(20)
BEGIN

DECLARE totalCR, totalDR, bal,openingBal BIGINT;

DECLARE accType,ledgerTypes,accCat CHAR(45);

SELECT collectionLedgerType, accounttype,generalCategory INTO ledgerTypes,accType,accCat

FROM fin_subaccounts s, fin_mainaccounts m WHERE s.AccountCode=accNo AND

s.mainaccountcode=m.accountcode;



IF l_type='Student' THEN

SET l_type=fin_GetStudentLedgerName(accno);

END IF;



SET openingBal=0;



IF accType IS NULL OR accType='' THEN





SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f

WHERE transactiontype='CR' AND account_type=l_type AND transactiondate < startDate AND accountcode=accNo;

SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f

WHERE transactiontype='DR' AND account_type=l_type AND transactiondate < startDate AND accountcode=accNo;



ELSE



SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f

WHERE transactiontype='CR' AND accountcode=accNo  AND transactiondate < startDate;

SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f

WHERE transactiontype='DR' AND accountcode=accNo AND transactiondate < startDate;





END  IF;





IF totalDR IS NULL THEN

SET totalDR=0;

END IF;

IF totalCR IS NULL THEN

SET totalCR=0;

END IF;

RETURN (totalDR-totalCR);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetLimitedStudentBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetLimitedStudentBalance`(reg CHAR(30),edate DATE) RETURNS char(30) CHARSET utf8
BEGIN

DECLARE curBalance CHAR(25);

SELECT curr_balance INTO curBalance FROM fin_ledger WHERE accountcode=reg AND transactiondate<=edate ORDER BY TID DESC LIMIT 1;

RETURN IF(curBalance IS NULL,'-',curBalance);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetMemberOutstandings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetMemberOutstandings`(memno CHAR(25), item CHAR(45), eDate DATE) RETURNS bigint(20)
BEGIN

DECLARE totalBillAmount,totalPayAmount BIGINT;



SELECT sum(transaction_amount) INTO totalPayAmount FROM fin_ledger f where accountcode=memNo AND transactionDate<=eDate

  AND transactiontype='CR' AND account_type=item;

SELECT sum(transaction_amount) INTO totalBillAmount FROM fin_ledger f where accountcode=memNo AND transactionDate<=eDate

  AND transactiontype='DR' AND account_type=item;



IF totalPayAmount IS NULL THEN

SET totalPayAmount=0;

END IF;



IF totalBillAmount IS NULL THEN

SET totalBillAmount=0;

END IF;





RETURN totalBillAmount-totalPayAmount;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetNewFeesBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetNewFeesBalance`(typ CHAR(15),trm INT, yr INT, reg CHAR(25)) RETURNS double
BEGIN



DECLARE curTrmBal,lastTrmBal,lastYrBal,TotalPay,TotalBill,lastYrPay,lastYrBill,lastTrmPay,lastTrmBill DOUBLE;




IF typ IN ('TotalBill','TotalPay','Current') THEN



SELECT SUM(amount) INTO TotalPay FROM fin_studentfeestracking WHERE regno=reg AND trans_type='Payment' AND acadyear=yr AND semester=trm;

SELECT SUM(amount) INTO TotalBill FROM fin_studentfeestracking WHERE regno=reg AND trans_type='Bill' AND acadyear=yr AND semester=trm;



SET TotalPay=IF(TotalPay IS NULL,0,TotalPay);

SET TotalBill=IF(TotalBill IS NULL,0,TotalBill);

SET curTrmBal=TotalBill-TotalPay;



END IF;





IF typ IN ('Opening','Current') THEN



  SELECT SUM(amount) INTO lastTrmPay FROM fin_studentfeestracking WHERE regno=reg AND trans_type='Payment' AND acadyear=yr AND semester<trm;

  SELECT SUM(amount) INTO lastTrmBill FROM fin_studentfeestracking WHERE regno=reg AND trans_type='Bill' AND acadyear=yr AND semester<trm;



  SELECT SUM(amount) INTO lastYrPay FROM fin_studentfeestracking WHERE regno=reg AND trans_type='Payment' AND acadyear<yr;

  SELECT SUM(amount) INTO lastYrBill FROM fin_studentfeestracking WHERE regno=reg AND trans_type='Bill' AND acadyear<yr;



  SET lastYrPay=IF(lastYrPay IS NULL,0,lastYrPay);

  SET lastYrBill=IF(lastYrBill IS NULL,0,lastYrBill);



  SET lastTrmPay=IF(lastTrmPay IS NULL,0,lastTrmPay);

  SET lastTrmBill=IF(lastTrmBill IS NULL,0,lastTrmBill);



  SET lastYrBal=(lastYrBill-lastYrPay);

  SET lastTrmBal=(lastTrmBill-lastTrmPay);

  SET lastYrBal=lastYrBal+lastTrmBal;





END IF;





IF typ='Opening' THEN

  RETURN lastYrBal;

ELSEIF typ='TotalPay' THEN

  RETURN IF(totalPay IS NULL,0,totalPay);

ELSEIF typ='TotalBill' THEN

  RETURN IF(TotalBill IS NULL,0,TotalBill);

ELSE

  RETURN IF(ABS(lastYrBal+curTrmBal)<10000,0,(lastYrBal+curTrmBal));

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetOpeningBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetOpeningBalance`(startDate DATE, accNo CHAR(25)) RETURNS bigint(20)
    DETERMINISTIC
BEGIN

    DECLARE totalCR, totalDR, bal, openingBal BIGINT;

    DECLARE accType, ledgerTypes, accCat CHAR(45);



    SELECT collectionLedgerType, accounttype, generalCategory

      INTO ledgerTypes, accType, accCat

      FROM fin_subaccounts s, fin_mainaccounts m

     WHERE s.AccountCode = accNo

       AND s.mainaccountcode = m.accountcode;



    SET openingBal = 0;



    IF accType = 'Basic Account' THEN

        SELECT SUM(transaction_amount) INTO totalCR

          FROM fin_ledger f

         WHERE transactiontype = 'CR'

           AND accountcode = accNo

           AND transactiondate < startDate;



        SELECT SUM(transaction_amount) INTO totalDR

          FROM fin_ledger f

         WHERE transactiontype = 'DR'

           AND accountcode = accNo

           AND transactiondate < startDate;

    ELSE

        SELECT SUM(transaction_amount) INTO totalCR

          FROM fin_ledger f

         WHERE transactiontype = 'CR'

           AND account_type = ledgerTypes

           AND transactiondate < startDate;



        SELECT SUM(transaction_amount) INTO totalDR

          FROM fin_ledger f

         WHERE transactiontype = 'DR'

           AND account_type = ledgerTypes

           AND transactiondate < startDate;

    END IF;



    IF totalDR IS NULL THEN SET totalDR = 0; END IF;

    IF totalCR IS NULL THEN SET totalCR = 0; END IF;



    RETURN (totalDR - totalCR);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetPeriodBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetPeriodBalance`(startDate DATE, endDate DATE, accNo CHAR(25), balType CHAR(25)) RETURNS double
    DETERMINISTIC
BEGIN

    DECLARE totalCR, totalDR, bal, openingBal BIGINT;

    DECLARE accType, ledgerTypes, accCat CHAR(45);



    SELECT collectionLedgerType, accounttype, generalCategory

      INTO ledgerTypes, accType, accCat

      FROM fin_subaccounts s, fin_mainaccounts m

     WHERE s.AccountCode = accNo

       AND s.mainaccountcode = m.accountcode;



    SET openingBal = 0;



    IF accCat IN ('Assets','Liabilities','Equity') THEN

        SET openingBal = fin_GetOpeningBalance(startDate, accNo);

    END IF;



    IF accType = 'Basic Account' THEN

        IF balType = 'Period' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND accountcode = accNo

               AND transactiondate BETWEEN startDate AND endDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND accountcode = accNo

               AND transactiondate BETWEEN startDate AND endDate;



        ELSEIF balType = 'Opening' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND accountcode = accNo

               AND transactiondate < startDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND accountcode = accNo

               AND transactiondate < startDate;

        END IF;

    ELSE

        IF balType = 'Period' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND account_type = ledgerTypes

               AND transactiondate BETWEEN startDate AND endDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND account_type = ledgerTypes

               AND transactiondate BETWEEN startDate AND endDate;



        ELSEIF balType = 'Opening' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND account_type = ledgerTypes

               AND transactiondate < startDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND account_type = ledgerTypes

               AND transactiondate < startDate;

        END IF;

    END IF;



    IF totalDR IS NULL THEN SET totalDR = 0; END IF;

    IF totalCR IS NULL THEN SET totalCR = 0; END IF;



    RETURN (totalDR - totalCR) + openingBal;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetPeriodOpeningBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetPeriodOpeningBalance`(startDate DATE, endDate DATE, accNo CHAR(25), balType CHAR(25)) RETURNS bigint(20)
    DETERMINISTIC
BEGIN

    DECLARE totalCR, totalDR, bal, openingBal BIGINT;

    DECLARE accType, ledgerTypes, accCat CHAR(45);



    SELECT collectionLedgerType, accounttype, generalCategory

      INTO ledgerTypes, accType, accCat

      FROM fin_subaccounts s, fin_mainaccounts m

     WHERE s.AccountCode = accNo

       AND s.mainaccountcode = m.accountcode;



    SET openingBal = 0;



    IF accCat IN ('Assets','Liabilities') THEN

        SET openingBal = fin_GetPeriodBalance(startDate, endDate, accNo, 'Opening');

    END IF;



    IF accType = 'Basic Account' THEN

        IF balType = 'Period' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND accountcode = accNo

               AND transactiondate BETWEEN startDate AND endDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND accountcode = accNo

               AND transactiondate BETWEEN startDate AND endDate;



        ELSEIF balType = 'Opening' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND accountcode = accNo

               AND transactiondate < startDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND accountcode = accNo

               AND transactiondate < startDate;

        END IF;

    ELSE

        IF balType = 'Period' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND account_type = ledgerTypes

               AND transactiondate BETWEEN startDate AND endDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND account_type = ledgerTypes

               AND transactiondate BETWEEN startDate AND endDate;



        ELSEIF balType = 'Opening' THEN

            SELECT SUM(transaction_amount) INTO totalCR

              FROM fin_ledger f

             WHERE transactiontype = 'CR'

               AND account_type = ledgerTypes

               AND transactiondate < startDate;



            SELECT SUM(transaction_amount) INTO totalDR

              FROM fin_ledger f

             WHERE transactiontype = 'DR'

               AND account_type = ledgerTypes

               AND transactiondate < startDate;

        END IF;

    END IF;



    IF totalDR IS NULL THEN SET totalDR = 0; END IF;

    IF totalCR IS NULL THEN SET totalCR = 0; END IF;



    RETURN (totalDR - totalCR) + openingBal;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetSFPBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetSFPBalance`(

    startDate DATE,

    endDate DATE,

    accNo CHAR(25),

    balType CHAR(25)

) RETURNS double
    DETERMINISTIC
BEGIN

    DECLARE totalCR DECIMAL(20,2) DEFAULT 0;

    DECLARE totalDR DECIMAL(20,2) DEFAULT 0;

    DECLARE openingBal DECIMAL(20,2) DEFAULT 0;

    DECLARE accType CHAR(45);

    DECLARE ledgerTypes CHAR(45);

    DECLARE accCat CHAR(45);



    SELECT s.collectionLedgerType, s.accounttype, m.generalCategory

      INTO ledgerTypes, accType, accCat

      FROM fin_subaccounts s

      INNER JOIN fin_mainaccounts m ON s.mainaccountcode = m.accountcode

     WHERE s.AccountCode = accNo

     LIMIT 1;



    IF accCat IN ('Assets','Liabilities','Equity') THEN

        SET openingBal = COALESCE(fin_GetOpeningBalance(startDate, accNo), 0);

    END IF;



    IF accType = 'Basic Account' THEN

        IF balType = 'Period' THEN

            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalCR

              FROM fin_ledger

             WHERE transactiontype = 'CR'

               AND accountcode = accNo

               AND transactiondate BETWEEN startDate AND endDate;



            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalDR

              FROM fin_ledger

             WHERE transactiontype = 'DR'

               AND accountcode = accNo

               AND transactiondate BETWEEN startDate AND endDate;



        ELSEIF balType = 'Opening' THEN

            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalCR

              FROM fin_ledger

             WHERE transactiontype = 'CR'

               AND accountcode = accNo

               AND transactiondate < startDate;



            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalDR

              FROM fin_ledger

             WHERE transactiontype = 'DR'

               AND accountcode = accNo

               AND transactiondate < startDate;

        END IF;

    ELSE

        IF balType = 'Period' THEN

            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalCR

              FROM fin_ledger

             WHERE transactiontype = 'CR'

               AND transactiondate BETWEEN startDate AND endDate

               AND (account_type = ledgerTypes OR accountcode = accNo);



            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalDR

              FROM fin_ledger

             WHERE transactiontype = 'DR'

               AND transactiondate BETWEEN startDate AND endDate

               AND (account_type = ledgerTypes OR accountcode = accNo);



        ELSEIF balType = 'Opening' THEN

            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalCR

              FROM fin_ledger

             WHERE transactiontype = 'CR'

               AND transactiondate < startDate

               AND (account_type = ledgerTypes OR accountcode = accNo);



            SELECT COALESCE(SUM(transaction_amount),0)

              INTO totalDR

              FROM fin_ledger

             WHERE transactiontype = 'DR'

               AND transactiondate < startDate

               AND (account_type = ledgerTypes OR accountcode = accNo);

        END IF;

    END IF;



    RETURN (totalDR - totalCR) + openingBal;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetStudClassStream` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetStudClassStream`(adm CHAR(25), yr INT, trm INT, what CHAR(15)) RETURNS char(25) CHARSET utf8
BEGIN

DECLARE stClass,stStream CHAR(25);

SELECT stud_class,stream INTO stClass,stStream FROM schoolmis.class_manager WHERE adm_no=adm AND year=yr AND term=trm;

IF what='Class' THEN

  RETURN IF(stClass IS NULL,'-',stClass);

ELSE

    RETURN IF(stStream IS NULL,'-',stStream);

END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetStudentClassInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetStudentClassInfo`(adm CHAR(25), yrs INT, trm INT) RETURNS varchar(200) CHARSET utf8
BEGIN

DECLARE resStatus CHAR(25);

DECLARE details,strm VARCHAR(200);

DECLARE curClass INTEGER;



SELECT MAX(study_class),stream INTO curClass,strm FROM schooldynamics.adm_studentclasses WHERE adm_no=adm AND study_year=yrs AND study_term=trm;



SET details=  CONCAT('SENIOR ',curClass);

RETURN IF(details IS NULL,'-',details);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetStudentIncomeName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetStudentIncomeName`(regno CHAR(25)) RETURNS char(25) CHARSET utf8
BEGIN

DECLARE ledgernm,faxCode CHAR(25);

SET faxCode=campus_dynamics.acad_GetFacultyCodeFromRegNo(regno);

SELECT CONCAT('Income',abbrev) INTO ledgernm FROM campus_dynamics.acad_faculty WHERE faculty_code=faxCode;



RETURN IF(ledgernm IS NULL, '-',ledgernm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetStudentLedgerName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetStudentLedgerName`(regno CHAR(25)) RETURNS char(25) CHARSET utf8
BEGIN

DECLARE ledgernm,faxCode CHAR(25);

SET faxCode=campus_dynamics.acad_GetFacultyCodeFromRegNo(regno);

SELECT CONCAT(abbrev,'Fees') INTO ledgernm FROM campus_dynamics.acad_faculty WHERE faculty_code=faxCode;


RETURN IF(ledgernm IS NULL, '-',ledgernm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetStudyDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetStudyDetails`(adm CHAR(25)) RETURNS varchar(200) CHARSET utf8
BEGIN

DECLARE resStatus,prog,sess,yrs,trm CHAR(25);

DECLARE details,strm VARCHAR(200);

DECLARE curClass INTEGER;





SELECT acad_year,semester,studyyear,residence_status INTO yrs,trm,curClass,resStatus  FROM campus_dynamics.acad_registration

WHERE regno=adm ORDER BY acad_year DESC,semester DESC LIMIT 1;



SELECT campus_dynamics.acad_GetProgAbbrevByCode(progid),studsesion INTO prog,sess FROM campus_dynamics.acad_student WHERE regno=adm LIMIT 1;



SET details=  CONCAT(prog,' [',sess,']',', YR ',curClass,' ,',UPPER(resStatus),', ACAD YEAR ',yrs,', SEM=',trm);

RETURN IF(details IS NULL,'-',details);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetSumStudyDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetSumStudyDetails`(adm CHAR(25)) RETURNS varchar(200) CHARSET utf8
BEGIN

DECLARE resStatus CHAR(25);

DECLARE details,strm VARCHAR(200);

DECLARE curClass,yrs,trm INTEGER;



SELECT residential_status INTO resStatus FROM schooldynamics.adm_student WHERE adm_no=adm;

SELECT study_class,stream,study_year,study_term INTO curClass,strm,yrs,trm

 FROM schooldynamics.adm_studentclasses WHERE adm_no=adm ORDER BY study_year DESC,study_term DESC LIMIT 1;



SET details=  CONCAT('S',curClass,' ',strm,' TERM ',trm,', ',yrs);

RETURN IF(details IS NULL,'-',details);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetSurplusDeficit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetSurplusDeficit`(startDate DATE) RETURNS bigint(20)
BEGIN

DECLARE totalCR, totalDR BIGINT;



SELECT SUM(transaction_amount) INTO totalCR FROM fin_ledger f

WHERE transactiontype='CR'  AND transactiondate < startDate AND fin_GetAccountCategory(accountcode) IN ('Income','Expense');

SELECT SUM(transaction_amount) INTO totalDR FROM fin_ledger f

WHERE transactiontype='DR' AND transactiondate < startDate AND fin_GetAccountCategory(accountcode) IN ('Income','Expense');



IF totalDR IS NULL THEN

SET totalDR=0;

END IF;

IF totalCR IS NULL THEN

SET totalCR=0;

END IF;

RETURN (totalDR-totalCR);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetTransactionProgFaculty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_GetTransactionProgFaculty`(vno INT, accno CHAR(25)) RETURNS char(250) CHARSET utf8
BEGIN



DECLARE fax,progs VARCHAR(250);



SET progs=campus_dynamics.acad_GetProgAbbrevByRegNo(accno);

SET fax=campus_dynamics.acad_GetFacultyFromRegno(accno);



UPDATE fin_ledgers_prog

SET prog = progs,

    faculty = fax

WHERE voucherno = vno

AND (faculty = '-'

OR prog = '-');

RETURN CONCAT(progs,' ',fax);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetTrialBalanceGroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetTrialBalanceGroup`(accCode CHAR(25)) RETURNS char(25) CHARSET utf8
    DETERMINISTIC
BEGIN

    DECLARE MAC CHAR(25);



    SELECT GeneralCategory INTO MAC

      FROM fin_mainaccounts ma

      JOIN fin_subaccounts sa ON ma.accountCode = sa.MainAccountCode

     WHERE sa.accountCode = accCode;



    RETURN MAC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetVoucherAccountNames` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetVoucherAccountNames`(typ CHAR(25), ID CHAR(25)) RETURNS varchar(150) CHARSET utf8
    DETERMINISTIC
BEGIN

    DECLARE nm VARCHAR(150);



    IF typ IN (SELECT LedgerTypeName FROM fin_ledgertypes f WHERE ledgertypecategory = 'Supplier') THEN

        SELECT supplierName INTO nm FROM supplier WHERE supplierID = ID;

    ELSEIF typ IN (SELECT LedgerTypeName FROM fin_ledgertypes f WHERE ledgertypecategory = 'Student') THEN

        SELECT CONCAT(stud_names) INTO nm FROM schoolmis.student WHERE adm_no = ID;

    ELSEIF typ IN (SELECT LedgerTypeName FROM fin_ledgertypes f WHERE ledgertypecategory = 'Employee') THEN

        SELECT emp_name INTO nm FROM campus_dynamics.hrm_employee WHERE empID = ID LIMIT 1;

    ELSE

        SELECT accountname INTO nm FROM fin_subaccounts WHERE accountcode = ID;

    END IF;



    RETURN IF(nm IS NULL, '-', nm);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_GetVoucherStudName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_GetVoucherStudName`(vno INT,

 typ VARCHAR(30)) RETURNS varchar(60) CHARSET latin1
BEGIN

DECLARE st_nm,accno VARCHAR(60);

SELECT campus_dynamics.acad_GetStudnameByID(accountcode),accountcode INTO st_nm,accno

 FROM fin_ledger WHERE

voucherno=vno AND transactiontype=typ LIMIT 1;

RETURN IF(st_nm IS NULL,'',CONCAT(' for ',st_nm,' (',accno,')'));



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_IncomeTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_IncomeTotals`(typ CHAR(15), sDate DATE, eDate DATE) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus BIGINT;

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory='Income')

AS findata;

RETURN IF(typ='CR',IF(cramt=0,'',FORMAT(cramt,0)),IF(dramt=0,'',FORMAT(dramt,0)));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_MonthNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_MonthNo`(mnth CHAR(35)) RETURNS int(11)
BEGIN

IF mnth='JANUARY' THEN

RETURN 1;

ELSEIF mnth='FEBRUARY' THEN

RETURN 2;

ELSEIF mnth='MARCH' THEN

RETURN 3;

ELSEIF mnth='APRIL' THEN

RETURN 4;

ELSEIF mnth='MAY' THEN

RETURN 5;

ELSEIF mnth='JUNE' THEN

RETURN 6;

ELSEIF mnth='JULY' THEN

RETURN 7;

ELSEIF mnth='AUGUST' THEN

RETURN 8;

ELSEIF mnth='SEPTEMBER' THEN

RETURN 9;

ELSEIF mnth='OCTOBER' THEN

RETURN 10;

ELSEIF mnth='NOVEMBER' THEN

RETURN 11;

ELSE

RETURN 12;

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_NextAccountCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_NextAccountCode`(main_acc CHAR(25)) RETURNS char(25) CHARSET utf8
BEGIN



DECLARE next_code CHAR(15);

SELECT MAX(SUBSTRING(accountcode,3,4))+1 INTO next_code FROM fin_subaccounts

WHERE SUBSTRING(accountcode,1,3)=SUBSTRING(main_acc,1,3);

RETURN IF(next_code IS NULL,CONCAT('AC',SUBSTRING(main_acc,3,4)+1),CONCAT('AC',next_code));



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_NextJournalSerial` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_NextJournalSerial`(typ CHAR(150)) RETURNS char(10) CHARSET utf8
BEGIN

DECLARE maxno INT;

SELECT MAX(journal_serialno) INTO maxno FROM fin_journalnumbers WHERE journalType=typ;

IF maxno IS NULL THEN

RETURN '00001';

ELSE

RETURN LPAD(maxno+1,5,0);

END IF;



RETURN maxno;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_NextVoucherNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_NextVoucherNo`(usr CHAR(25)) RETURNS int(11)
BEGIN



DECLARE maxNo,genMax INT;

INSERT INTO fin_transaction_numbers(username) VALUES (usr);

SELECT MAX(voucherID) INTO maxNo FROM fin_transaction_numbers WHERE username=usr;

RETURN IF(maxNo IS NULL,1,maxNo+1);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_OperatingIncome` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_OperatingIncome`(typ CHAR(15), sDate DATE, eDate DATE) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus,balances BIGINT;

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory IN ('Expense','Income'))

AS findata;

SET balances=dramt-cramt;

RETURN IF(typ='CR',IF(balances>0,'',FORMAT(ABS(balances),0)),IF(balances<0,'',FORMAT(ABS(balances),0)));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_real_amount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_real_amount`(base_curr CHAR(10), amt DOUBLE, curr CHAR(10), typ CHAR(15)) RETURNS double
BEGIN

DECLARE base_curr CHAR(10);

DECLARE real_amt,buy_rt,sal_rt,rate DOUBLE;



IF typ='UG' THEN

SELECT IF(base_curr='UGX',rates,buy_rates) INTO rate FROM fin_currency WHERE code=curr;





IF curr='UGX' THEN

SET real_amt=amt;

ELSE

SET real_amt=amt*rate;

END IF;



ELSE

SELECT IF(base_curr!='UGX',rates,buy_rates) INTO rate FROM fin_currency WHERE code=base_curr;





IF curr!='UGX' THEN

SET real_amt=amt;

ELSE

SET real_amt=amt*rate;

END IF;



END IF;



RETURN IF(real_amt IS NULL,amt,real_amt);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_real_rate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_real_rate`(base_curr CHAR(10), curr CHAR(15),typ CHAR(25)) RETURNS double
BEGIN

DECLARE real_amt,buy_rt,sal_rt,rate DOUBLE;



IF typ='UG' THEN

SELECT IF(base_curr='UGX',rates,buy_rates) INTO rate FROM fin_currency WHERE code=curr;



IF curr='UGX' THEN

SET rate=1;

END IF;



ELSE



SELECT IF(base_curr!='UGX',rates,buy_rates) INTO rate FROM fin_currency WHERE code=base_curr;



END IF;



RETURN IF(rate IS NULL,1,rate);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_receiptVoucherSummary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_receiptVoucherSummary`(recNO INT) RETURNS varchar(150) CHARSET utf8
BEGIN

DECLARE CRAccount, DRAccount,comm,vTYPE,parts VARCHAR(150);

DECLARE amount BIGINT;

SELECT vouchertype INTO vTYPE FROM fin_vouchernumbers f WHERE voucherno=recNO;

SELECT fin_GetVoucherAccountNames(account_type,accountcode) INTO CRAccount FROM fin_voucher j WHERE voucherNo=recNO AND

TransactionType='CR';

SELECT fin_GetVoucherAccountNames(account_type,accountcode) INTO DRAccount FROM fin_voucher j WHERE voucherNo=recNO AND

TransactionType='DR';

SELECT MAX(transaction_amount),MIN(particulars) INTO amount,parts FROM fin_voucher j WHERE voucherNo=recNO;

IF(vTYPE='Receipt') THEN

SET comm=CONCAT(FORMAT(amount,0),', ',parts,' by ',CRAccount);

ELSE

SET comm=CONCAT(FORMAT(amount,0),', ',parts,' to ',DRAccount, ' thru ',CRAccount);

END IF;

RETURN IF(comm IS NULL,'-',comm);





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_RedBal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_RedBal`(amt INT) RETURNS double
BEGIN



SET @redbal=@redbal+amt;

RETURN @dr_amt-@redbal;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_red_balance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_red_balance`(amt DOUBLE) RETURNS double
BEGIN

SET @redbal=IF(@redbal=0,amt,@redbal-amt);

RETURN @redbal;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_SingleTermlyItemBillingFN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_SingleTermlyItemBillingFN`(
    reg CHAR(25),
    ItemID INT,
    trm INT,
    T_Date DATE,
    usr CHAR(25),
    yr INT,
    cls CHAR(5),
    amt DOUBLE
) RETURNS char(45) CHARSET utf8
    DETERMINISTIC
BEGIN
    DECLARE IncomeAccount, ItemNm, acad, studSys, rtn CHAR(150);
    DECLARE repStatus INT DEFAULT 0;
    DECLARE lastTNo INT DEFAULT 0;
    DECLARE existingBill INT DEFAULT 0;

    
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_studStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_studStatus`(adm CHAR(25), yrs INT, trm INT) RETURNS char(10) CHARSET utf8
BEGIN



DECLARE lastTerm,lastYr,statusCheck INTEGER;



IF(trm=1) THEN

SET lastTerm=3;

SET lastYr=yrs-1;

ELSE

SET lastTerm=trm-1;

SET lastYr=yrs;

END IF;



SELECT COUNT(*) INTO statusCheck FROM schoolmis.class_manager WHERE adm_no=adm AND year=lastYr AND term=lastTerm;



RETURN IF(statusCheck=0,'New','Old');



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_SubscriptionCheck` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_SubscriptionCheck`(memID CHAR(25), mnth CHAR(15), yr INT, pid INT) RETURNS int(11)
BEGIN

DECLARE chck INT;

SELECT COUNT(*) INTO chck FROM fin_subscription WHERE memberID=memID AND sub_month=mnth AND sub_year=yr AND productID=pid;

RETURN chck;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_TermlyItemBillingFN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_TermlyItemBillingFN`(
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
) RETURNS char(65) CHARSET utf8
    DETERMINISTIC
BEGIN
    DECLARE IncomeAccount, ItemNm, rtn CHAR(150);
    DECLARE existingBill INT DEFAULT 0;
    DECLARE existingLedger INT DEFAULT 0;
    DECLARE lastTID INT DEFAULT 0;

    
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

    
    IF amt <= 0 THEN
        RETURN 'Zero Amount';
    END IF;

    
    SELECT AccountCode, ItemName INTO IncomeAccount, ItemNm
    FROM academicbillingitems WHERE ItemCode = ItemID;

    IF IncomeAccount IS NULL THEN
        RETURN 'Invalid Item';
    END IF;

    
    
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

    
    INSERT INTO fin_studentfeestracking(
        regno, Amount, item_code, trans_type, post_status,
        acadyear, semester, trans_date, detail
    ) VALUES(
        reg, amt, ItemID, 'Bill', 'Pending',
        acadyr, sems, SYSDATE(),
        CONCAT(ItemNm, ' Term:', sems, ', ', acadyr, ': ', reg)
    );

    SET lastTID = LAST_INSERT_ID();

    
    
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

    
    UPDATE fin_studentfeestracking
    SET post_status = 'Posted'
    WHERE TID = lastTID;

    
    CALL fin_UpdateAllLedgerBalances();

    
    UPDATE fin_ledger
    SET journal_no = CONCAT('JN-', TID)
    WHERE journal_no = '-'
      AND folio = CONCAT('BillNo:', lastTID);

    RETURN CONCAT('Success:', lastTID);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_TermlyItemBilling_StudentCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_TermlyItemBilling_StudentCount`(ItemID INT,trm INT,yr INT, cls CHAR(25), strm CHAR(25)) RETURNS int(11)
BEGIN

DECLARE cnt INT;

SELECT COUNT(*) INTO cnt FROM fin_studentfeestracking WHERE itemCode=ItemID AND term_sem=trm AND acadyear=yr AND stream=strm

AND class_course=cls;



RETURN cnt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_TotalPayments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_TotalPayments`(reg VARCHAR(25), sems INT, acad VARCHAR(15)) RETURNS double
BEGIN

DECLARE total_paid DOUBLE;

SELECT SUM(amount) INTO total_paid FROM fin_studentfeestracking WHERE regno=reg AND acadyear=acad AND semester=sems AND trans_type='Payment';

RETURN IF(total_paid IS NULL,0,total_paid);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_TransactionCreatorFn` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_TransactionCreatorFn`(
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
) RETURNS char(65) CHARSET utf8
    DETERMINISTIC
BEGIN
    DECLARE v_tracking_ref INT UNSIGNED DEFAULT NULL;
    DECLARE v_source VARCHAR(25) DEFAULT 'Manual';
    DECLARE v_dr_created INT DEFAULT 0;
    DECLARE v_cr_created INT DEFAULT 0;

    
    IF folio LIKE 'BillNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 8) AS UNSIGNED);
        SET v_source = 'Billing';
    ELSEIF folio LIKE 'PayNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 7) AS UNSIGNED);
        SET v_source = 'Payment';
    END IF;

    
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_TransactionCreatorFn2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` FUNCTION `fin_TransactionCreatorFn2`(
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
) RETURNS char(65) CHARSET utf8
    DETERMINISTIC
BEGIN
    DECLARE v_tracking_ref INT UNSIGNED DEFAULT NULL;
    DECLARE v_source VARCHAR(25) DEFAULT 'Manual';
    DECLARE v_dr_created INT DEFAULT 0;
    DECLARE v_cr_created INT DEFAULT 0;

    
    IF folio LIKE 'BillNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 8) AS UNSIGNED);
        SET v_source = 'Billing';
    ELSEIF folio LIKE 'PayNo:%' THEN
        SET v_tracking_ref = CAST(SUBSTRING(folio, 7) AS UNSIGNED);
        SET v_source = 'Payment';
    END IF;

    
    
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

    
    IF v_dr_created = 1 AND v_cr_created = 1 THEN
        RETURN 'Created';
    ELSEIF v_dr_created = 0 AND v_cr_created = 0 THEN
        RETURN 'Skipped:Exists';
    ELSE
        RETURN 'Partial:Check';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_transactionNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_transactionNo`(

    acc CHAR(35),

    typ CHAR(35),

    _TID INT

) RETURNS char(25) CHARSET utf8
BEGIN

    DECLARE maxJ INT DEFAULT 0;



    SELECT MAX(CAST(TRIM(journal_no) AS UNSIGNED))

    INTO maxJ

    FROM fin_ledger

    WHERE accountcode = acc

      AND account_type = typ

      AND TID < _TID

      AND TRIM(journal_no) REGEXP '^[0-9]+$';



    SET maxJ = IFNULL(maxJ, 0) + 1;



    RETURN LPAD(maxJ, 5, '0');

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_TrialbalanceTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_TrialbalanceTotals`(typ CHAR(15), sDate DATE, eDate DATE) RETURNS char(20) CHARSET utf8
BEGIN

DECLARE dramt,cramt,surplus BIGINT;

SET surplus=fin_GetSurplusDeficit(sDate);

SELECT SUM(IF(balance>0,balance,0)), SUM(IF(balance<0,ABS(balance),0)) INTO dramt,cramt

FROM (SELECT accountcode,accountname, fin_GetPeriodBalance(sDate,eDate,accountcode,'Period') AS balance

FROM fin_subaccounts

UNION

SELECT '','',surplus FROM DUAL) AS findata;

RETURN IF(typ='CR',FORMAT(cramt,0),FORMAT(dramt,0));

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_UpdateBudgetIncome` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_UpdateBudgetIncome`(acc CHAR(15),vyear INT, v_amount DOUBLE) RETURNS int(11)
BEGIN



UPDATE fin_budget SET actual_amount=actual_amount+v_amount WHERE item_code=acc AND budget_year=vyear;

RETURN 0;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_UpdateSubAccountCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_UpdateSubAccountCode`(oldcode CHAR(15),newcode CHAR(15)) RETURNS int(11)
BEGIN

UPDATE fin_subaccounts SET accountcode=newcode WHERE accountcode=oldcode;

UPDATE fin_ledger SET accountcode=newcode WHERE accountcode=oldcode;

RETURN 1;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fin_VoucherCreatorFn` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fin_VoucherCreatorFn`(vNo BIGINT, CRaccountcode CHAR(25),CRaccountType CHAR(25), CRParticulars VARCHAR(350),

DRaccountcode CHAR(25), DRaccountType CHAR(25),DRParticulars VARCHAR(350), transaction_amount BIGINT,voucherNo INT, transactionDate DATE, teller CHAR(25)) RETURNS char(65) CHARSET utf8
BEGIN



INSERT IGNORE INTO fin_voucher(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller)

VALUES(DRaccountcode,DRaccountType,'DR',transaction_amount,DRParticulars,vNo,transactionDate,teller);



INSERT IGNORE INTO fin_voucher(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller)

VALUES(CRaccountcode,CRaccountType,'CR',transaction_amount,CRParticulars,vNo,transactionDate,teller);



RETURN '-';



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetNSSFNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNSSFNo`(eid CHAR(25)) RETURNS char(45) CHARSET utf8
BEGIN



DECLARE nssf_no CHAR(45);

SELECT nssfno INTO nssf_no FROM erp.lecturer WHERE  lecturer_id=eid;

IF nssf_no IS NULL THEN

SELECT nssfCod INTO nssf_no FROM hurmis.tempview_nssf WHERE  empCode=eid;

END IF;



RETURN IF(nssf_no IS NULL,'-',nssf_no);





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetPayrollTotal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetPayrollTotal`(pid INT) RETURNS bigint(50)
BEGIN



DECLARE totals BIGINT;

SELECT SUM(netPay) INTO totals FROM ptl_paydetails WHERE payrollID=pid;

RETURN IF(totals IS NULL,0,totals);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_ded_all_total` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_ded_all_total`(emp_id CHAR(15),payid INT, cat CHAR(25)) RETURNS decimal(10,0)
BEGIN



DECLARE amt DOUBLE;

SELECT SUM(amount) INTO amt FROM hrm_monthly_ded_allowance

WHERE empid=emp_id AND  payrollID=payid AND typ=cat;



IF amt IS NULL THEN

RETURN 0;

ELSE

RETURN amt;

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_fc_CalculateStaffByGender` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_fc_CalculateStaffByGender`(SX VARCHAR(45), ST VARCHAR(45)) RETURNS int(11)
BEGIN



DECLARE TT INT;



SELECT COUNT(*) INTO TT FROM hrm_employee WHERE Gender = SX AND Entry_Satation = ST;

RETURN TT;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_fc_CalculateStaffByQualification` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_fc_CalculateStaffByQualification`(grd VARCHAR(45), ST VARCHAR(45)) RETURNS int(11)
BEGIN



DECLARE TT INT;



SELECT COUNT(*) INTO TT FROM hrm_employee WHERE emp_qualifications = grd AND Entry_Satation = ST;

RETURN TT;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_fc_getempDepartment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_fc_getempDepartment`(emp INT) RETURNS varchar(50) CHARSET utf8
BEGIN

DECLARE name VARCHAR(50);

DECLARE dpt  INT;

SELECT departmentID INTO dpt FROM hrm_emp_contracts WHERE empID = emp;

SELECT dept_name INTO name FROM hrm_departments WHERE ID = dpt;



RETURN name;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_fc_getEmpDesignation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_fc_getEmpDesignation`(emp INT) RETURNS varchar(50) CHARSET utf8
BEGIN

DECLARE Designation VARCHAR(50);



SELECT hrm_fc_getJobName(jobID) INTO Designation FROM hrm_emp_contracts WHERE empID = emp;



RETURN Designation;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_fc_getEmpName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_fc_getEmpName`(emp INT) RETURNS varchar(50) CHARSET utf8
BEGIN

DECLARE name VARCHAR(50);

SELECT emp_name INTO name FROM hrm_employee WHERE empID = emp;

RETURN name;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_fc_getEmpStation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_fc_getEmpStation`(emp INT) RETURNS varchar(50) CHARSET utf8
BEGIN

DECLARE Station VARCHAR(50);

SELECT Entry_Satation INTO Station FROM hrm_employee WHERE empID = emp;

RETURN Station;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_fc_getJobName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_fc_getJobName`(JID INT) RETURNS varchar(50) CHARSET utf8
BEGIN

DECLARE name VARCHAR(50);

SELECT jobname INTO name FROM hrm_jobs WHERE ID = JID;

RETURN name;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetDedAllNameByID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetDedAllNameByID`(did INT) RETURNS char(100) CHARSET utf8
BEGIN

DECLARE all_name CHAR(100);

SELECT dedall_name INTO all_name FROM hrm_allowance_deductions WHERE ID=did;

RETURN IF (all_name IS NULL,'-',all_name);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetDedAll_Amount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetDedAll_Amount`(eid INT, dedAllID INT,pid INT) RETURNS double
BEGIN



DECLARE dedCat,comp CHAR(25);

DECLARE grossPay,amt,finalamt DOUBLE;



SET grossPay=hrm_GetGrossPay(eid,pid);

SELECT dedall_type,computation_by,dedall_amount INTO dedCat,comp,amt FROM hrm_allowance_deductions WHERE ID=dedAllID;

IF comp='PERCENTAGE' THEN

  SET finalamt=grossPay*amt/100;

ELSEIF comp='FIXED' THEN

  SET finalamt=amt;

ELSEIF comp='DYNAMIC' THEN

  SET finalamt=0;

ELSE

  SET finalamt=0;

END IF;



RETURN finalamt;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetEmpBankData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetEmpBankData`(ID INT, cat CHAR(25)) RETURNS char(250) CHARSET utf8
BEGIN



DECLARE bnkID INT;

DECLARE bnk,acc VARCHAR(250);

SELECT bankID,bankAccount INTO bnkID,acc FROM hrm_employee WHERE empID=ID;

IF cat='Bank' THEN

SELECT bank_name INTO bnk FROM banks WHERE bank_id=bnkID;

RETURN IF(bnk IS NULL,'-',bnk);

ELSE

RETURN IF(acc IS NULL,'-',acc);

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetEmpContactsByID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetEmpContactsByID`(id INT) RETURNS char(65) CHARSET utf8
BEGIN

DECLARE emp_nm CHAR(60);

SELECT CONCAT(emp_phone,' ',emp_email) INTO emp_nm FROM hrm_employee WHERE empID=id;

RETURN IF(emp_nm IS NULL,'-',emp_nm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetEmployeeCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetEmployeeCode`(ID INT) RETURNS char(25) CHARSET utf8
BEGIN

DECLARE code CHAR(25);

SELECT emp_code INTO code FROM hrm_employee WHERE empID=ID;

RETURN IF(code IS NULL,'-',code);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetEmployeeStation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetEmployeeStation`(ID INT) RETURNS varchar(250) CHARSET utf8
BEGIN

DECLARE stn VARCHAR(250);

SELECT entry_satation INTO stn FROM hrm_employee WHERE empID=ID;

RETURN IF(stn IS NULL,'-',stn);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetEmpNameByID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetEmpNameByID`(id INT) RETURNS char(65) CHARSET utf8
BEGIN

DECLARE emp_nm CHAR(60);

SELECT emp_name INTO emp_nm FROM hrm_employee WHERE empID=id;

RETURN IF(emp_nm IS NULL,'-',emp_nm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetEmpPhoneByID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetEmpPhoneByID`(id INT) RETURNS char(65) CHARSET utf8
BEGIN

DECLARE emp_nm CHAR(60);

SELECT emp_phone INTO emp_nm FROM hrm_employee WHERE empID=id;

RETURN IF(emp_nm IS NULL,'-',emp_nm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetGrossPay` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetGrossPay`(emp_id INT, pid INT) RETURNS double
BEGIN

DECLARE basicpay,allowances DOUBLE;

SET basicpay=hrm_GetPayAmount(emp_id);

SET allowances=hrm_ded_all_total(emp_id,pid,'Allowance');

RETURN basicpay+allowances;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_GetPayAmount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_GetPayAmount`(emp_id INT) RETURNS double
BEGIN



DECLARE curScale INT;

DECLARE payamount DOUBLE;

SELECT payscale,fixedamount INTO curScale,payamount FROM hrm_emp_contracts WHERE empID=emp_id AND contractStatus='VALID';

IF payamount=0 THEN

SELECT basicpay INTO payamount FROM hrm_payscales WHERE ID=curScale;

END IF;



RETURN IF(payamount IS NULL,0,payamount);





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_netwage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_netwage`(emp_id INTEGER, pid INT) RETURNS int(11)
BEGIN

DECLARE gross DECIMAL;

SET gross=hrm_GetGrossPay(emp_id,pid);

RETURN gross-hrm_paye(emp_id,gross)-hrm_nssf('EMP',emp_id,gross)-hrm_ded_all_total(emp_id,pid,'Deduction');

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_nssf` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_nssf`(cat CHAR(15),emp_id CHAR(15),amt INT) RETURNS int(11)
BEGIN

DECLARE ex_stat INTEGER;

DECLARE basic INTEGER;

SELECT COUNT(*) INTO ex_stat FROM hrm_exemptions WHERE empid=emp_id AND ded_allID=2;



IF ex_stat=0 THEN



IF cat='EMP' THEN

        RETURN amt*0.05;

ELSE

        RETURN amt*0.10;

END IF;

ELSE

RETURN 0;

END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hrm_paye` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hrm_paye`(emp_id CHAR(15),amt decimal(10,0)) RETURNS int(11)
BEGIN

DECLARE ex_stat INTEGER;



SELECT COUNT(*) INTO ex_stat FROM hrm_exemptions WHERE empid=emp_id AND ded_allID=1;



IF ex_stat=0 THEN





if amt<235000 then

return 0;





elseif amt<=335000 and amt>235000 then





return (amt-235000)*(10/100);





elseif amt>335000 and amt <=410000 then



return ((amt-335000)*(20/100))+10000;





else

return ((amt-410000)*(30/100))+25000;

end if;



ELSE

return 0;

END IF;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_Deduct_unitQtyConversion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_Deduct_unitQtyConversion`(Icode INT, Ucode INT) RETURNS int(11)
BEGIN



DECLARE UQty     INT;

DECLARE CHK      INT;



SELECT COUNT(*) INTO CHK FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;





      IF CHK > 0 THEN

          SELECT Qty INTO UQty FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          RETURN UQty;

      ELSE

          SELECT ConversionToMainQty INTO UQty FROM inv_itemunitdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          RETURN UQty;

      END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_getAdjustPrimaryUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_getAdjustPrimaryUnit`(ICD INT) RETURNS varchar(45) CHARSET utf8
BEGIN



DECLARE Uname VARCHAR(45);

SELECT inv_fc_getUnitShortname(UnitCode) INTO Uname FROM inv_itemdetails WHERE ItemCode= ICD;



RETURN Uname;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_GetCurrentItemQty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_GetCurrentItemQty`(Icode INT) RETURNS int(11)
BEGIN



DECLARE CQTY VARCHAR(45);

SELECT QTY INTO CQTY FROM inv_inventory WHERE ItemCode = Icode;

RETURN IF(CQTY IS NULL,0,CQTY);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_getItemName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_getItemName`(icode INT) RETURNS varchar(45) CHARSET utf8
BEGIN



DECLARE INAME VARCHAR(45);

SELECT ItemName INTO INAME FROM inv_itemdetails WHERE ItemCode = icode;

RETURN INAME;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_getStoreName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_getStoreName`(Lcode INT) RETURNS varchar(45) CHARSET utf8
BEGIN



DECLARE Lname VARCHAR(45);

SELECT ShortName INTO Lname FROM inv_storelocation WHERE LocationCode = Lcode;

RETURN Lname;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_getSupplierName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_getSupplierName`(Scode INT) RETURNS varchar(45) CHARSET utf8
BEGIN



DECLARE Sname VARCHAR(45);

SELECT SupplierName INTO Sname FROM inv_supplierdetails WHERE SupplierCode = Scode;

RETURN Sname;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_GetUnitQtyConversion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_GetUnitQtyConversion`(SQTY DOUBLE, Icode INT, Ucode INT) RETURNS double
BEGIN



DECLARE UQty     INT;

DECLARE CHK      INT;



SELECT COUNT(*) INTO CHK FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;



      IF CHK > 0 THEN

          SELECT Qty*SQTY INTO UQty FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          RETURN UQty;

      ELSE

          SELECT ConversionToMainQty*SQTY INTO UQty FROM inv_itemunitdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          RETURN UQty;

      END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_getUnitShortname` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_getUnitShortname`(Ucode INT) RETURNS varchar(45) CHARSET utf8
BEGIN



DECLARE Sname VARCHAR(45);

SELECT UnitShortName INTO Sname FROM inv_itemunits WHERE UnitCode = Ucode;

RETURN Sname;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_NextCaptureSheetNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_NextCaptureSheetNo`() RETURNS int(11)
BEGIN



DECLARE maxNo INT;



SELECT MAX(SheetNo) INTO maxNo FROM inv_stockcapture;

RETURN IF(maxNo IS NULL,1,maxNo+1);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_NextPoNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_NextPoNo`() RETURNS int(11)
BEGIN



DECLARE maxNo INT;



SELECT MAX(Po_No) INTO maxNo FROM inv_purchaseorder;

RETURN IF(maxNo IS NULL,1,maxNo+1);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_NextPo_Serial` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_NextPo_Serial`(PO INT) RETURNS int(11)
BEGIN



DECLARE maxNo INT;



SELECT MAX(S_no) INTO maxNo FROM inv_purchaseorder_items WHERE Po_No = PO;

RETURN IF(maxNo IS NULL,1,maxNo+1);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_StockunitQtyConversion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_StockunitQtyConversion`(Icode INT, Ucode INT) RETURNS double(20,3)
BEGIN



DECLARE UQty        DOUBLE;

DECLARE CHK         INT;

DECLARE SQTY        BIGINT;

DECLARE ConvertQty  DOUBLE;



SELECT COUNT(*) INTO CHK FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

SELECT Qty INTO SQTY FROM inv_inventory WHERE ItemCode = Icode;



      IF CHK > 0 THEN

          SELECT Qty*SQTY INTO UQty FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          RETURN UQty;

      ELSE

          SELECT SQTY/ConversionToMainQty INTO UQty FROM inv_itemunitdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          

          RETURN UQTY;

      END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_unitQtyConversion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_unitQtyConversion`(shtN INT, Icode INT, Ucode INT) RETURNS int(11)
BEGIN



DECLARE UQty     INT;

DECLARE CHK      INT;

DECLARE SQTY     INT;



SELECT COUNT(*) INTO CHK FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

SELECT Qty INTO SQTY FROM inv_stock_on_sheet WHERE ItemCode = Icode AND UnitCode = Ucode AND SheetNo = shtN;



      IF CHK > 0 THEN

          SELECT Qty*SQTY INTO UQty FROM inv_itemdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          RETURN UQty;

      ELSE

          SELECT ConversionToMainQty*SQTY INTO UQty FROM inv_itemunitdetails WHERE ItemCode = Icode AND UnitCode = Ucode;

          RETURN UQty;

      END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_fc_VATCalculator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_fc_VATCalculator`(ICD INT, UCD INT,

                                                                  TAXPRICE VARCHAR(45), QTY DOUBLE) RETURNS double(20,3)
BEGIN



DECLARE taxCod  INT;

DECLARE taxAmt  DOUBLE(20,3);

DECLARE vatAmt  DOUBLE(20,3);



SELECT TaxCode INTO taxCod FROM inv_itemdetails WHERE ItemCode = ICD;



  IF taxCod = 1 THEN

      IF TAXPRICE = 'COST' THEN

          SELECT inv_GetItemCostPrice(ICD,UCD) * QTY INTO taxAmt FROM DUAL;

          SELECT taxAmt/118*18 INTO vatAmt FROM DUAL;

          RETURN vatAmt;

      ELSEIF TAXPRICE = 'SELLING' THEN

          SELECT inv_GetItemSellingPrice(ICD,UCD) * QTY INTO taxAmt FROM DUAL;

          SELECT taxAmt/118*18 INTO vatAmt FROM DUAL;

          RETURN vatAmt;

      END IF;

  ELSE

          SET vatAmt = 0;

          RETURN vatAmt;

  END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetBranchNameByID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetBranchNameByID`(bid INT) RETURNS varchar(150) CHARSET utf8
BEGIN



DECLARE br_name VARCHAR(150);

SELECT branch_name INTO br_name FROM schoolmis.school_branches WHERE branchID=bid LIMIT 1;

RETURN IF(br_name IS NULL,'-',br_name);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetCategoryByItemCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetCategoryByItemCode`(icode INT) RETURNS char(100) CHARSET utf8
BEGIN

DECLARE cat_name CHAR(100);

SELECT ItemGroupName INTO cat_name FROM inv_itemgroup WHERE ItemGroupCode IN

(SELECT ItemGroupCode FROM inv_itemdetails WHERE itemcode=icode);

RETURN IF(cat_name IS NULL,'-',cat_name);





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetIDByCatName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetIDByCatName`(cat CHAR(150)) RETURNS int(11)
BEGIN

DECLARE IDS INT;

SELECT unitcode INTO IDS FROM inv_itemunits WHERE unitSHORTname=cat;

RETURN IF(IDS IS NULL,1,IDS);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetItemCostPrice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetItemCostPrice`(ICD INT, Ucode INT) RETURNS double(20,3)
BEGIN

DECLARE COSTP    DOUBLE(20,3);

DECLARE CHK      INT;





SELECT COUNT(*) INTO CHK FROM inv_itemdetails WHERE ItemCode = ICD AND UnitCode = Ucode;



      IF CHK > 0 THEN

          SELECT CostPrice INTO COSTP FROM inv_itemdetails WHERE ItemCode = ICD;

          RETURN COSTP;

      ELSE

          SELECT CostPrice  INTO COSTP FROM inv_itemunitdetails WHERE ItemCode = ICD AND UnitCode = Ucode;

          RETURN COSTP;

      END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetItemSellingPrice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetItemSellingPrice`(ICD INT, Ucode INT) RETURNS double(20,3)
BEGIN

DECLARE COSTP    DOUBLE(20,3);

DECLARE CHK      INT;





SELECT COUNT(*) INTO CHK FROM inv_itemdetails WHERE ItemCode = ICD AND UnitCode = Ucode;



      IF CHK > 0 THEN

          SELECT SellingPrice INTO COSTP FROM inv_itemdetails WHERE ItemCode = ICD;

          RETURN COSTP;

      ELSE

          SELECT SellingPrice  INTO COSTP FROM inv_itemunitdetails WHERE ItemCode = ICD AND UnitCode = Ucode;

          RETURN COSTP;

      END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetItemShortName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetItemShortName`(code INT) RETURNS char(10) CHARSET utf8
BEGIN

DECLARE nm CHAR(10);

SELECT UnitShortName INTO nm FROM inv_itemunits WHERE unitCode=code;

RETURN IF (nm IS NULL,'-',nm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetMaterialBF` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetMaterialBF`(bid INT, icode INT, trm INT, yr INT) RETURNS double
BEGIN

DECLARE bal DOUBLE;

IF trm=1 THEN

  SET trm=3;

  SET yr=yr-1;

ELSE

  SET trm=trm-1;

END IF;



SELECT balance INTO bal FROM inv_budgetrequisitions WHERE branchID=bid AND  budget_year=yr AND term=trm AND item_code=icode;

RETURN IF(bal IS NULL,0,bal);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `inv_GetMaterialTotals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `inv_GetMaterialTotals`(icode INT, trm INT, yr INT,typ CHAR(15)) RETURNS double
BEGIN

DECLARE budget_total,rec_total,bal_total DOUBLE;

SELECT SUM(budget_amount), SUM(total_requisition),SUM(balance) INTO budget_total,rec_total,bal_total

FROM inv_budgetrequisitions WHERE item_code=icode AND term=trm AND budget_year=yr;



IF typ='B' THEN

  RETURN IF(budget_total IS NULL,0,budget_total);

ELSEIF typ='R' THEN

  RETURN IF(rec_total IS NULL,0,rec_total);

ELSE

  RETURN IF(bal_total IS NULL,0,bal_total);

END IF;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `nssf_employer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `nssf_employer`(empid CHAR(15),amt INT) RETURNS int(11)
BEGIN

DECLARE ex_stat INTEGER;

DECLARE basic INTEGER;

SELECT COUNT(*) INTO ex_stat FROM exemptions WHERE emp_id=empid AND type='NSSF';

SELECT emp_salary INTO basic FROM employee WHERE emp_id=empid;



IF ex_stat=0 THEN

RETURN amt*0.1;

ELSE

RETURN 0;

END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `acad_ExamPass` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acad_ExamPass`(reg CHAR(45) charset utf8, acad  CHAR(45) charset utf8, sem INT,

prog CHAR(25)  charset utf8, typ CHAR(25)  charset utf8)
BEGIN

DECLARE curr_bal,full_name,photo,cyear,reg_stat,clear_stat CHAR(250);



IF reg='ALL' THEN



SELECT typ,entryno,s.regno,CONCAT(othername,' ',firstname) AS full_name,

CONCAT('',photofile) AS photo,acad,UPPER(progname) progname,

study_system,acad,sem,campus_dynamics_accounts.fin_GetLimitedStudentBalance(s.regno,DATE(SYSDATE())) AS curr_bal,

studsesion,studyyear AS cyear,regstatus AS reg_stat

FROM acad_student s, acad_programme p,acad_registration r WHERE  s.progid=p.progcode AND progid=prog AND acad_year=acad

AND semester=sem AND examClearance='CLEARED' AND r.regno=s.regno;



ELSE



SET full_name=acad_GetStudNameByID(reg);



SELECT studyyear,regstatus,examClearance INTO cyear,reg_stat,clear_stat FROM acad_registration WHERE regno=reg AND acad_year=acad AND semester=sem LIMIT 1;



SET curr_bal=campus_dynamics_accounts.fin_GetLimitedStudentBalance(reg,DATE(SYSDATE()));



SET photo=CONCAT('',acad_GetTranscriptStudData(reg,'PHOTO'));

IF curr_bal IS NULL THEN

SET curr_bal='NILL';

ELSEIF curr_bal LIKE '%DR' THEN

SET curr_bal=CONCAT(REPLACE(curr_bal,'DR',''),' DEBIT');

ELSEIF curr_bal LIKE '%CR' THEN

SET curr_bal=CONCAT(REPLACE(curr_bal,'CR',''),' CREDIT');

END IF;



SELECT typ,entryno,regno,full_name,photo,acad,UPPER(progname) progname,study_system,acad,sem,curr_bal,studsesion,cyear,reg_stat

FROM acad_student s, acad_programme p WHERE regno=reg AND s.progid=p.progcode;







END IF;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `acad_FlushAccountsDB` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acad_FlushAccountsDB`()
BEGIN

START TRANSACTION;



TRUNCATE acc_activity_log;

TRUNCATE accountingperiod;

TRUNCATE assetlocations;


TRUNCATE depreciationrecords;

TRUNCATE exemptions;

TRUNCATE external_funders;

TRUNCATE fin_assetlocations;

TRUNCATE fin_budget;

TRUNCATE fin_fees_pay_schedule;

TRUNCATE fin_fees_structure;

TRUNCATE fin_financial_periods;

TRUNCATE fin_journal;

TRUNCATE fin_journal_details;

TRUNCATE fin_journalnumbers;

TRUNCATE fin_ledger;

TRUNCATE fin_ledger_prog;

TRUNCATE fin_notifications;

TRUNCATE fin_paymenttracker;

TRUNCATE fin_payrollpostrecords;

TRUNCATE fin_reco_adjustments;

TRUNCATE fin_reco_bank_entries;

TRUNCATE fin_reconciliationstatement;

TRUNCATE fin_schoolpaydata;

TRUNCATE fin_studentfeestracking;

TRUNCATE fin_temp_balance;

TRUNCATE fin_transaction_numbers;

TRUNCATE fixedassetregister;

TRUNCATE hrm_ded_allowance_stafflist;

TRUNCATE hrm_departments;

TRUNCATE hrm_emp_contracts;

TRUNCATE hrm_employee_accprofile;

TRUNCATE hrm_employee_emp_profile;

TRUNCATE hrm_employee_other;

TRUNCATE hrm_jobs;

TRUNCATE hrm_monthly_ded_allowance;

TRUNCATE hrm_payroll;

TRUNCATE hrm_payroll_details;

TRUNCATE hrm_payscales;

TRUNCATE inv_inventory;

TRUNCATE inv_inventory_out;

TRUNCATE inv_purchaseorder;

TRUNCATE inv_purchaseorder_items;

TRUNCATE inv_schoolreqdetails;

TRUNCATE inv_schoolrequisition;

TRUNCATE inv_stock_on_sheet;

TRUNCATE inv_stockcapture;

TRUNCATE inv_stockdeductions;

TRUNCATE inv_supplierdetails;

TRUNCATE inv_supplierwithitems;

TRUNCATE journalentries;

TRUNCATE journalnumbers;

TRUNCATE ledgerentries;

TRUNCATE payroll_postaccounts;

TRUNCATE payrollpoststatus;

TRUNCATE scholarships;

TRUNCATE scholarshipstudents;

TRUNCATE school_budget;

TRUNCATE smis_payrolldetails;

TRUNCATE stud_billing;

TRUNCATE temp_gta_transactions;

TRUNCATE temp_pending;

TRUNCATE temp_reg;



COMMIT;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AccountEditor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AccountEditor`(usr CHAR(25),AccCode CHAR(25), MainAccountCode CHAR(15),

AccountName CHAR(45), Details VARCHAR(150), accountType CHAR(45),collectionLedgerType CHAR(45))
BEGIN



START TRANSACTION;



SELECT COUNT(*) INTO @chk FROM  fin_subaccounts WHERE AccountCode=AccCode;



INSERT INTO fin_subaccounts(AccountCode, MainAccountCode, AccountName, Details,accountType,collectionLedgerType)

VALUES (AccCode, MainAccountCode, AccountName, Details,accountType,collectionLedgerType)

ON DUPLICATE KEY UPDATE MainAccountCode=MainAccountCode, AccountName=AccountName, Details=Details,

accountType=accountType,collectionLedgerType=collectionLedgerType;



INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

VALUES (usr,'Accounts Management',CONCAT('AccCode=',AccCode,'AccName=',

AccountName),IF(@chk=1,'Updated Account','Created Account'),SYSDATE());



COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `acc_GetParentPhones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acc_GetParentPhones`(admno CHAR(25))
BEGIN



DECLARE P_Phone CHAR(35);

SELECT telephone INTO P_Phone FROM student WHERE adm_no=admno;

SELECT IF(P_Phone IS NULL,'-',P_Phone) AS telephone FROM DUAL;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `acc_parentContactList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acc_parentContactList`(cls INTEGER, strm CHAR(25), yr INTEGER, trm INTEGER)
BEGIN



   SELECT c.adm_no,s.stud_names,s.sex AS gender,s.combination, s.telephone,c.stud_class,c.stream,c.year,c.term,

   c.classID,parent_name,residence_status,house

   FROM schoolmis.student s, class_manager c

   WHERE c.adm_no=s.adm_no

   AND c.year=yr

   AND c.stud_class=cls

   AND c.term=trm

   AND c.stream=strm ORDER BY stud_names;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `acc_Recomputations` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acc_Recomputations`(subcode CHAR(15),c_year INTEGER,

studclass INTEGER,pap INTEGER, strm CHAR(15), trm INTEGER)
BEGIN



DECLARE lev CHAR;



IF studclass > 4 THEN



          SET lev='A';

          

          UPDATE examination SET

          grade=acc_newgrader('GRD',stud_class,total_mark),

          grade_value=acc_newgrader('PTS',stud_class,total_mark),

          term_comments= acc_newgrader('COM',stud_class,total_mark)

          WHERE adm_no=adm_no AND sub_code=subcode AND Year=c_year AND paper=pap AND stream=strm AND term=trm;



          UPDATE examination SET alevel_grade=if(total_mark=0,'',acc_New_A_Grader('GRD',adm_no,subcode,trm,c_year)),

          alevel_gvalue=acc_New_A_Grader('PTS',adm_no,subcode,trm,c_year),

          a_comm=acc_New_A_Grader('COM',adm_no,subcode,trm,c_year) WHERE adm_no=adm_no AND sub_code=subcode AND Year=c_year AND stream=strm AND term=trm;



          UPDATE examination set term_comments='', grade='', alevel_grade='' WHERE total_mark=0 AND term_comments NOT LIKE 'Missed%';



ELSE

          SET lev='O';



          UPDATE examination SET

          grade=acc_newgrader('GRD',stud_class,total_mark),

          grade_value=acc_newgrader('PTS',stud_class,total_mark)

          WHERE adm_no=adm_no AND sub_code=subcode AND Year=c_year AND paper=pap AND stud_class=studclass

          AND stream=strm AND term=trm;



          UPDATE examination SET

          term_comments= acc_newgrader('COM',stud_class,total_mark)

          WHERE adm_no=adm_no AND sub_code=subcode AND Year=c_year AND paper=pap AND stud_class=studclass AND stream=strm

          AND term=trm;



          UPDATE examination set term_comments='', grade='', alevel_grade='' WHERE total_mark=0 AND term_comments NOT LIKE 'Missed%';



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `acc_schoolPromotion_fees` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acc_schoolPromotion_fees`(cls INT,trm INTEGER,yr INTEGER,newcls INT,admno VARCHAR(30))
BEGIN



START TRANSACTION;

IF cls IN(1,2,3,4,5,6,7) THEN

 IF trm=3 THEN



 INSERT IGNORE INTO class_manager(adm_no, stud_class, stream, year, term)

 (SELECT adm_no,stud_class+1,stream,year+1,

 1 FROM class_manager WHERE year=yr AND term=trm AND stud_class = cls);





 ELSE



 INSERT IGNORE INTO class_manager(adm_no, stud_class, stream, year, term)

 (SELECT adm_no,stud_class,stream,year,trm+1 FROM class_manager WHERE year=yr AND term=trm AND stud_class = cls);





 END IF;



ELSEIF cls=8 THEN



IF trm=2 THEN

INSERT IGNORE INTO class_manager(adm_no, stud_class, stream, year, term)

 (SELECT adm_no,stud_class,stream,year+1,

 1 FROM class_manager WHERE year=yr AND term=trm AND stud_class=8);

ELSE



INSERT IGNORE INTO class_manager(adm_no, stud_class, stream, year, term)

(SELECT adm_no,stud_class,stream,year,trm+1 FROM class_manager WHERE year=yr AND term=trm AND stud_class=8);



END IF;



ELSEIF cls=9 THEN

IF trm=3 THEN

INSERT IGNORE INTO class_manager(adm_no, stud_class, stream, year, term)

 (SELECT adm_no,newcls,stream,year+1,

 1 FROM class_manager WHERE year=yr AND term=trm AND stud_class = 9 AND adm_no=admno);



ELSE



INSERT IGNORE INTO class_manager(adm_no, stud_class, stream, year, term)

(SELECT adm_no,stud_class,stream,year,trm+1 FROM class_manager WHERE year=yr AND term=trm AND stud_class=9 AND adm_no=admno);



END IF;

END IF;



COMMIT;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `adm_GetClassLists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `adm_GetClassLists`(cls CHAR(5),yr CHAR(5),trm INT,strm CHAR(45))
BEGIN

SELECT c.ID, c.adm_no,CONCAT_WS(' ',first_name,IF(othernames='-','',othernames)) AS StudentName, study_class, study_year,

study_term, stream,fn_GetDetails(6,c.adm_no) AS Parent,SUBSTRING_INDEX(fn_GetDetails(4,c.adm_no),',',2) AS ParentPhone,

fn_GetDetails(5,'')School,fn_SchoolLogo()schoollogo,first_name,othernames,IF(gender='F','FEMALE','MALE')gender,residential_status,house,

fn_GetDetails(11,c.adm_no)SubjectCombination FROM adm_studentclasses c,adm_student s

WHERE s.adm_no=c.adm_no AND  study_class=cls AND study_year=yr AND  study_term=trm AND stream=strm ORDER BY StudentName;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `BillUnbilledStudents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `BillUnbilledStudents`(
  IN p_acadyear CHAR(15),
  IN p_semester INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_regno CHAR(35);

    DECLARE cur CURSOR FOR
        SELECT r.regno
        FROM campus_dynamics.acad_registration r
        WHERE r.acad_year = p_acadyear
          AND r.semester = p_semester
          AND r.regstatus IN ('REGISTERED', 'LATE REGISTERED')
          AND r.regno NOT IN (
              SELECT DISTINCT regno
              FROM campus_dynamics_accounts.fin_studentfeestracking
              WHERE acadyear = p_acadyear
                AND semester = p_semester
                AND trans_type = 'Bill'
          );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    loop1: LOOP
        FETCH cur INTO v_regno;
        IF done = 1 THEN LEAVE loop1; END IF;
        CALL campus_dynamics_accounts.fin_Autobilling(v_regno, p_acadyear, p_semester, 'REG', 'admin', 'BATCH');
        CALL campus_dynamics_accounts.fin_Autobilling(v_regno, p_acadyear, p_semester, 'ACCOMO', 'admin', 'BATCH');
    END LOOP;
    CLOSE cur;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteAccount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteAccount`(usr CHAR(25),AccCode CHAR(15))
BEGIN



START TRANSACTION;



SELECT accountname INTO @accountnm FROM fin_subaccounts WHERE accountcode=AccCode;



DELETE FROM fin_subaccounts WHERE accountcode=AccCode;





INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

VALUES (usr,'Accounts Management',CONCAT('AccCode=',AccCode,'AccName=',

@accountnm),'Deleted Account',SYSDATE());



COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteMainAccount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteMainAccount`(usr CHAR(25),AccCode CHAR(15))
BEGIN



START TRANSACTION;



SELECT accountname INTO @accountnm FROM fin_mainaccounts WHERE accountcode=AccCode;



DELETE FROM fin_mainaccounts WHERE accountcode=AccCode;





INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

VALUES (usr,'Main Accounts Management',CONCAT('AccCode=',AccCode,'AccName=',

@accountnm),'Deleted a Main Account',SYSDATE());



COMMIT;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `finPerformAutoReconciliation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `finPerformAutoReconciliation`(rid INT)
BEGIN

DROP TABLE IF EXISTS temp_bank_data;

CREATE TABLE temp_bank_data AS SELECT * FROM fin_reco_bank_entries WHERE RecoID=rid AND match_TID=0;

SELECT fin_AutoReco(ID,details,STR_TO_DATE(trans_date,'%m/%d/%Y'), amount, 5) AS ID FROM temp_bank_data;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AddBillStructureItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AddBillStructureItems`(ItemID INT, yr INT, sem INT, style CHAR(25),prog CHAR(25))
BEGIN



DECLARE progDur,curYear INT;

DECLARE studySys CHAR(25);



SELECT couselength,study_system INTO progDur,studySys FROM campus_dynamics.acad_programme WHERE progcode=prog;







IF style='ALL' THEN



SET curYear=1;

WHILE (curYear<=progDur) DO



INSERT IGNORE INTO fin_fees_pay_schedule(ItemID,studyyear,semester) SELECT ItemID,curYear,1 FROM DUAL;

INSERT IGNORE INTO fin_fees_pay_schedule(ItemID,studyyear,semester) SELECT ItemID,curYear,2 FROM DUAL;



IF studySys IN ('Term','Quarter') THEN

INSERT IGNORE INTO fin_fees_pay_schedule(ItemID,studyyear,semester) SELECT ItemID,curYear,3 FROM DUAL;

END IF;



SET curYear=curYear+1;



END WHILE;



ELSE



INSERT IGNORE INTO fin_fees_pay_schedule(ItemID,studyyear,semester) SELECT ItemID,yr,sem FROM DUAL;





END IF;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AddFeesScheduleItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AddFeesScheduleItems`(ItemID_ INT,yr_ INT,sems_ INT, style CHAR(30) charset utf8,

prog CHAR(30) charset utf8,sess CHAR(30) charset utf8,eyr INT, bid INT)
BEGIN

DECLARE curYear,dur INT;

SELECT CEILING(couselength) INTO dur FROM campus_dynamics.acad_programme WHERE progcode=prog;

SET curYear=1;



IF style='Programme' THEN



WHILE (curYear<=dur) DO



INSERT IGNORE INTO fin_fees_pay_schedule(ItemID, studyyear, semester, amount, curr_year, progid, stud_session,billingID)

SELECT ItemCode,curYear,1,amount,curr_year,progid,studsession,bid FROM fin_fees_structure

WHERE itemCode=itemID_ AND progid=prog AND studsession=sess AND curr_year=eyr AND semester=1  AND study_year=1 AND billingID=bid;



INSERT IGNORE INTO fin_fees_pay_schedule(ItemID, studyyear, semester, amount, curr_year, progid, stud_session,billingID)

SELECT ItemCode,curYear,2,amount,curr_year,progid,studsession,bid FROM fin_fees_structure

WHERE itemCode=itemID_ AND progid=prog AND studsession=sess AND curr_year=eyr AND semester=1 AND study_year=1;



SET curYear=curYear+1;



END WHILE;



ELSEIF style='Semester' THEN



INSERT  IGNORE INTO fin_fees_pay_schedule(ItemID, studyyear, semester, amount, curr_year, progid, stud_session,billingID)

SELECT ItemCode,yr_,sems_,amount,eyr,progid,studsession,bid FROM fin_fees_structure

WHERE itemCode=itemID_ AND progid=prog AND studsession=sess AND curr_year=eyr AND semester=1  AND study_year=1 AND billingID=bid;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AddJournalDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AddJournalDetails`(jno INT,usr CHAR(25),accCode CHAR(25),AccType CHAR(65),details VARCHAR(250),

typ CHAR(25),

refNo CHAR(85)

)
BEGIN

DECLARE vno,curVNo INT;

DECLARE forexRate DOUBLE;

DECLARE journalStat,curr,jType CHAR(25);

DECLARE v_empID CHAR(65);

DECLARE v_empType CHAR(65);

DECLARE vInvoiceDate DATE;







SELECT voucherNo INTO curVNo FROM fin_ledger WHERE folio=jno LIMIT 1;

SELECT journal_currency,PostStatus,journalType,transactionDate INTO curr,journalStat,jType,vInvoiceDate FROM fin_journalnumbers WHERE JournalNo=jno LIMIT 1;

SELECT 1 INTO forexRate FROM DUAL;



IF curVNo IS NULL THEN

SET vno=fin_NextVoucherNo(usr);

ELSE

SET vno=curVno;

END IF;



IF accCode LIKE '%|%' THEN

  SET v_empID   = SUBSTRING_INDEX(accCode,'|',1);

  SET v_empType = SUBSTRING_INDEX(accCode,'|',-1);

ELSE

  SET v_empID   = accCode;

  SET v_empType = AccType;

END IF;





IF(journalStat='Pending') THEN





INSERT INTO fin_journal_details(accountcode, account_type, transactionType, voucherNo, transactionDate, teller, timeLog, folio,

particulars, transaction_amount,trans_currency,journal_no,journal_type, refno, InvoiceDate)

VALUES (v_empID, v_empType,typ,0,SYSDATE(),usr,SYSDATE(),jno,details,0,curr,jno,jType, refNo, vInvoiceDate);









ELSE



INSERT INTO fin_ledger(accountcode, account_type, transactionType, voucherNo, transactionDate, teller, timeLog, folio,

particulars, transaction_amount,trans_currency,InvoiceDate,RefNo) VALUES (v_empID, v_empType,typ,vno,SYSDATE(),usr,SYSDATE(),jno,details,0,curr,vInvoiceDate,refNo);



UPDATE fin_journalnumbers  SET GL_VoucherNo=vno WHERE journalno=jno;



UPDATE fin_ledger SET journal_no=fin_transactionNo(accountcode,account_type,TID) WHERE journal_no='-';





END IF;













END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AddReceiptDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AddReceiptDetails`(jno INT,usr CHAR(25),accCode CHAR(25),AccType CHAR(65),details VARCHAR(250),

typ CHAR(25),amt DOUBLE)
BEGIN

DECLARE vno,curVNo INT;

DECLARE forexRate DOUBLE;

DECLARE journalStat,curr,jType CHAR(25);



SELECT voucherNo INTO curVNo FROM fin_ledger WHERE folio=jno LIMIT 1;

SELECT 'UGX',PostStatus,journalType INTO curr,journalStat,jType FROM fin_journalnumbers WHERE JournalNo=jno LIMIT 1;

SELECT 1 INTO forexRate FROM DUAL;



IF curVNo IS NULL THEN

SET vno=fin_NextVoucherNo(usr);

ELSE

SET vno=curVno;

END IF;



IF(journalStat='Pending') THEN



INSERT INTO fin_journal_details(accountcode, account_type, transactionType, voucherNo, transactionDate, teller, timeLog, folio,

particulars, transaction_amount,trans_currency,journal_no,journal_type)

VALUES (accCode,AccType,typ,0,SYSDATE(),usr,SYSDATE(),jno,details,amt,curr,jno,jType);









ELSE



INSERT INTO fin_ledger(accountcode, account_type, transactionType, voucherNo, transactionDate, teller, timeLog, folio,

particulars, transaction_amount,trans_currency) VALUES (accCode,AccType,typ,vno,SYSDATE(),usr,SYSDATE(),jno,details,amt,curr);



UPDATE fin_journalnumbers  SET GL_VoucherNo=vno WHERE journalno=jno;

UPDATE fin_ledger SET journal_no=fin_transactionNo(accountcode,account_type,TID) WHERE journal_no='-';





END IF;











END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AddSponsorJournalDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AddSponsorJournalDetails`(jno INT,usr CHAR(25),accCode CHAR(25),details VARCHAR(250),

 amt DOUBLE, acad CHAR(25), sem INT)
BEGIN

DECLARE vno,curVNo,noStuds INT;

DECLARE forexRate,st_amount DOUBLE;

DECLARE journalStat,curr,jType,sp_name VARCHAR(350);



SELECT voucherNo INTO curVNo FROM fin_ledger WHERE folio=jno LIMIT 1;

SELECT 'UGX',PostStatus,journalType INTO curr,journalStat,jType FROM fin_journalnumbers WHERE JournalNo=jno LIMIT 1;

SELECT 1 INTO forexRate FROM DUAL;



SELECT scholarshipName INTO sp_name FROM scholarships WHERE scholarshipID=accCode;

SELECT COUNT(*) INTO noStuds FROM scholarshipstudents WHERE scholarshipID=accCode AND scholarhipYear=acad AND scholarhipTerm=sem;



IF curVNo IS NULL THEN

SET vno=fin_NextVoucherNo(usr);

ELSE

SET vno=curVno;

END IF;



IF(journalStat='Pending') THEN



INSERT IGNORE INTO fin_journal_details(accountcode, account_type, transactionType, voucherNo, transactionDate, teller, timeLog, folio,

particulars, transaction_amount,trans_currency,journal_no,journal_type)

VALUES (accCode,'Sponsor','DR',amt,SYSDATE(),usr,SYSDATE(),jno,details,amt,curr,jno,jType);



SET st_amount=amt/noStuds;



INSERT IGNORE INTO fin_journal_details(accountcode, account_type, transactionType, voucherNo, transactionDate, teller, timeLog, folio,

particulars, transaction_amount,trans_currency,journal_no,journal_type)

SELECT adm_no,fin_GetStudentLedgerName(adm_no),'CR',vno,SYSDATE(),usr,SYSDATE(),'-',

CONCAT('Fees Payment via sponsor [',sp_name,'] for ',acad,' semester ',sem),

0,'UGX',jno,jType FROM scholarshipstudents WHERE scholarshipID=accCode AND scholarhipYear=acad AND scholarhipTerm=sem;





END IF;











END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_adoptStructure` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_adoptStructure`(old_prog CHAR(15),

old_sess CHAR(15), eyr CHAR(15), new_prog CHAR(15), new_sess CHAR(15),

inc_schedule CHAR(15),new_yr INT)
BEGIN



INSERT IGNORE INTO fin_fees_structure(ItemCode, progid, studsession, amount, curr_year, semester, study_year)

SELECT ItemCode, new_prog, new_sess, amount, new_yr, semester, study_year FROM fin_fees_structure

WHERE curr_year=eyr AND progid=old_prog AND studsession=old_sess;



IF inc_schedule='Yes' THEN



INSERT IGNORE  INTO fin_fees_pay_schedule(ItemID, studyyear, semester, amount, curr_year, progid, stud_session)

SELECT ItemID, studyyear, semester, amount, new_yr, new_prog, new_sess FROM fin_fees_pay_schedule

WHERE curr_year=eyr AND progid=old_prog AND stud_session=old_sess;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_APIStudentData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_APIStudentData`(reg CHAR(25))
BEGIN



DECLARE curBalance CHAR(50);

SELECT curr_balance INTO curBalance FROM fin_ledger WHERE accountCode=reg ORDER BY TID DESC LIMIT 1;

SET curBalance=IF(curBalance IS NULL,'0',REPLACE(curBalance,',',''));

SET curBalance=IF(curBalance LIKE '%CR',CONCAT('-',curBalance),curBalance);

SET curBalance=ABS(REPLACE(REPLACE(curBalance,'CR',''),'DR',''));



SELECT regno,CONCAT(othername,' ',firstname) AS studnames,'MRU' AS stud_campus,

studphone,email,curBalance FROM campus_dynamics.acad_student WHERE regno=reg

UNION

SELECT form_no, applic_name,'MRU',applic_phone,applic_name,'0'

FROM campus_dynamics_admissions.applic_form WHERE form_no=reg AND

form_no NOT IN (SELECT regno FROM campus_dynamics.acad_student)

UNION

SELECT stud_entry_no, stud_name,'MRU',stud_phone,stud_email,'0'

FROM campus_dynamics.acad_applications WHERE stud_entry_no=reg AND

stud_entry_no NOT IN (SELECT regno FROM campus_dynamics.acad_student);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ApproveJournal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ApproveJournal`(jno INT, usr CHAR(25), typ CHAR(25))
BEGIN

    DECLARE vno  INT;

    DECLARE DRTotal, CRTotal BIGINT;

    DECLARE VStat, comm, curr, base_curr, curType CHAR(65);

    DECLARE details     VARCHAR(250);

    DECLARE forexRate   DOUBLE;

    DECLARE invoiceDate DATE;



    SET vno = fin_NextVoucherNo(usr);



    SELECT PostStatus, journalParticulars, journal_currency, j.transactionDate

    INTO VStat, details, curr, invoiceDate

    FROM fin_journalnumbers j

    WHERE journalNo = jno;





    SELECT base_currency INTO base_curr

    FROM fin_journal_details jd

    INNER JOIN fin_subaccounts sa ON jd.AccountCode = sa.AccountCode

    WHERE (TRIM(jd.journal_no) = CAST(jno AS CHAR) OR TRIM(jd.journal_no) = CONCAT('JN-', jno))

      AND base_currency != 'UGX'

    LIMIT 1;



    SET base_curr = IF(base_curr IS NULL, 'UGX', base_curr);

    SET curType   = IF(base_curr = 'UGX', 'UG', 'US');



    IF (fin_GetJournalTotalCR_DR('DR', jno) != fin_GetJournalTotalCR_DR('CR', jno) AND typ = 'Normal Journal') THEN

        SET comm = 'Error! Inbalace in CR and DR Totals';



    ELSEIF (fin_GetJournalTotalCR_DR('DR', jno) = 0 AND fin_GetJournalTotalCR_DR('CR', jno) = 0) THEN

        SET comm = 'Error! Enter Transactions before posting';



    ELSEIF VStat = 'Pending' THEN

        

        

        

        

        INSERT INTO fin_ledger(

            accountcode, account_type, transactionType, voucherNo,

            transactionDate, teller, timeLog, folio,

            particulars, transaction_amount, trans_currency,

            actual_amount, forex_rate, ugx_amount, InvoiceDate, RefNo

        )

        SELECT

            accountcode, account_type, transactionType, vno,

            SYSDATE(), usr, SYSDATE(), jno,

            CONCAT(details), transaction_amount, curr,

            0, fin_real_rate(base_curr, trans_currency, curType), 0,

            invoiceDate, d.refno

        FROM fin_journal_details d

        WHERE TRIM(d.journal_no) = CAST(jno AS CHAR)

           OR TRIM(d.journal_no) = CONCAT('JN-', jno);



        UPDATE fin_journalnumbers SET GL_VoucherNo = vno WHERE journalno = jno;



        UPDATE fin_ledger

        SET actual_amount = IF(

                forex_rate != 1 AND fin_GetBaseCurrency(accountcode) != 'UGX' AND trans_currency = 'UGX',

                FLOOR(transaction_amount / forex_rate),

                IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)

            ),

            ugx_amount = IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)

        WHERE voucherNo = vno

          AND journal_no = '-';



        UPDATE fin_ledger

        SET journal_no = fin_transactionNo(accountcode, account_type, TID)

        WHERE voucherNo = vno

          AND journal_no = '-';



        UPDATE fin_journalnumbers SET PostStatus = 'Posted' WHERE journalno = jno;



        SET comm = 'Posting Completed';

    ELSE

        SET comm = 'Posting Already Done';

    END IF;



    CALL fin_UpdateAllLedgerBalances();

    SELECT comm FROM DUAL;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ApproveJournal_Safe` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ApproveJournal_Safe`(

    IN p_journal_no INT,

    IN p_user CHAR(25),

    IN p_journal_type CHAR(25)

)
BEGIN

    DECLARE v_status VARCHAR(15);

    DECLARE v_voucher_no INT DEFAULT 0;

    DECLARE v_line_count INT DEFAULT 0;

    DECLARE v_dr_total DOUBLE DEFAULT 0;

    DECLARE v_cr_total DOUBLE DEFAULT 0;

    DECLARE v_period_count INT DEFAULT 0;

    DECLARE v_period_start DATE;

    DECLARE v_period_end DATE;

    DECLARE v_result VARCHAR(500);



    DECLARE vno INT;

    DECLARE v_curr CHAR(65);

    DECLARE v_base_curr CHAR(65);

    DECLARE v_curType CHAR(5);

    DECLARE v_details VARCHAR(250);

    DECLARE v_invoiceDate DATE;



    DECLARE EXIT HANDLER FOR SQLEXCEPTION

    BEGIN

        GET DIAGNOSTICS CONDITION 1

            @sql_errno = MYSQL_ERRNO,

            @sql_state = RETURNED_SQLSTATE,

            @sql_msg = MESSAGE_TEXT;



        ROLLBACK;



        SELECT CONCAT(

            'Error! Posting failed. No partial posting was saved. ',

            'MYSQL_ERRNO=', @sql_errno,

            ', SQLSTATE=', @sql_state,

            ', MESSAGE=', @sql_msg

        ) AS result_message;

    END;



    SELECT PostStatus, IFNULL(GL_VoucherNo, 0)

    INTO v_status, v_voucher_no

    FROM fin_journalnumbers

    WHERE JournalNo = p_journal_no

    LIMIT 1;



    IF v_status IS NULL THEN

        SET v_result = 'Error! Journal does not exist';



    ELSEIF v_status = 'Posted' THEN

        SET v_result = 'Error! Journal has already been posted';



    ELSEIF v_status = 'Void' THEN

        SET v_result = 'Error! Cannot approve a voided journal';



    ELSEIF v_status != 'Pending' THEN

        SET v_result = CONCAT('Error! Journal status is invalid: ', v_status);



    ELSE

        SELECT COUNT(*) INTO v_line_count

        FROM fin_journal_details

        WHERE TRIM(journal_no) = CAST(p_journal_no AS CHAR)

           OR TRIM(journal_no) = CONCAT('JN-', p_journal_no);



        IF v_line_count < 2 THEN

            SET v_result = CONCAT('Error! Journal must have at least 2 entries (DR + CR). Found: ', v_line_count);



        ELSE

            SELECT COALESCE(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0),

                   COALESCE(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0)

            INTO v_dr_total, v_cr_total

            FROM fin_journal_details

            WHERE TRIM(journal_no) = CAST(p_journal_no AS CHAR)

               OR TRIM(journal_no) = CONCAT('JN-', p_journal_no);



            IF v_dr_total != v_cr_total THEN

                SET v_result = CONCAT(

                    'Error! DR/CR imbalance. DR Total: ', FORMAT(v_dr_total, 0),

                    ', CR Total: ', FORMAT(v_cr_total, 0),

                    ', Difference: ', FORMAT(ABS(v_dr_total - v_cr_total), 0)

                );



            ELSEIF v_dr_total = 0 AND v_cr_total = 0 THEN

                SET v_result = 'Error! Enter transactions before approving (all amounts are zero)';



            ELSE

                SELECT COUNT(*), MIN(start_date), MIN(end_date)

                INTO v_period_count, v_period_start, v_period_end

                FROM fin_financial_years

                WHERE status = 'Open';



                IF v_period_count = 0 THEN

                    SET v_result = 'Error! No financial year is currently Open';



                ELSEIF CURDATE() < v_period_start OR CURDATE() > v_period_end THEN

                    SET v_result = CONCAT(

                        'Error! Current date is outside the open financial period (',

                        DATE_FORMAT(v_period_start, '%d/%m/%Y'), ' - ',

                        DATE_FORMAT(v_period_end, '%d/%m/%Y'), ')'

                    );



                ELSE

                    START TRANSACTION;



                    SET vno = fin_NextVoucherNo(p_user);



                    SELECT journalParticulars, journal_currency, transactionDate

                    INTO v_details, v_curr, v_invoiceDate

                    FROM fin_journalnumbers

                    WHERE JournalNo = p_journal_no;



                    SELECT base_currency INTO v_base_curr

                    FROM fin_journal_details jd

                    INNER JOIN fin_subaccounts sa ON jd.AccountCode = sa.AccountCode

                    WHERE (TRIM(jd.journal_no) = CAST(p_journal_no AS CHAR)

                        OR TRIM(jd.journal_no) = CONCAT('JN-', p_journal_no))

                      AND base_currency != 'UGX'

                    LIMIT 1;



                    SET v_base_curr = IF(v_base_curr IS NULL, 'UGX', v_base_curr);

                    SET v_curType   = IF(v_base_curr = 'UGX', 'UG', 'US');



                    INSERT INTO fin_ledger(

                        accountcode, account_type, transactionType, voucherNo,

                        transactionDate, teller, timeLog, folio,

                        particulars, transaction_amount, trans_currency,

                        actual_amount, forex_rate, ugx_amount, InvoiceDate, RefNo

                    )

                    SELECT

                        d.accountcode, d.account_type, d.transactionType, vno,

                        SYSDATE(), p_user, SYSDATE(), p_journal_no,

                        d.particulars, d.transaction_amount, v_curr,

                        0, fin_real_rate(v_base_curr, d.trans_currency, v_curType), 0,

                        v_invoiceDate, d.refno

                    FROM fin_journal_details d

                    WHERE TRIM(d.journal_no) = CAST(p_journal_no AS CHAR)

                       OR TRIM(d.journal_no) = CONCAT('JN-', p_journal_no);



                    UPDATE fin_ledger

                    SET actual_amount = IF(

                            forex_rate != 1 AND fin_GetBaseCurrency(accountcode) != 'UGX' AND trans_currency = 'UGX',

                            FLOOR(transaction_amount / forex_rate),

                            IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)

                        ),

                        ugx_amount = IF(trans_currency = 'UGX', transaction_amount, transaction_amount * forex_rate)

                    WHERE voucherNo = vno;



                    UPDATE fin_ledger

                    SET journal_no = fin_transactionNo(accountcode, account_type, TID)

                    WHERE voucherNo = vno

                      AND (journal_no = '-' OR journal_no IS NULL OR journal_no = '');



                    UPDATE fin_journalnumbers

                    SET GL_VoucherNo = vno,

                        PostStatus  = 'Posted',

                        Teller      = p_user,

                        journalDate = CURDATE()

                    WHERE JournalNo = p_journal_no;



                    CALL fin_UpdateAllLedgerBalances();



                    INSERT INTO acc_activity_log (user_id, page_function, par, comments, access_date)

                    VALUES (

                        p_user,

                        'JOURNAL_APPROVED',

                        CONCAT('JournalNo=', p_journal_no, ',VoucherNo=', vno,

                               ',Type=', IFNULL(p_journal_type, 'Normal Journal')),

                        CONCAT('DR=', FORMAT(v_dr_total, 0), ',CR=', FORMAT(v_cr_total, 0)),

                        NOW()

                    );



                    COMMIT;



                    SET v_result = 'Posting Completed';

                END IF;

            END IF;

        END IF;

    END IF;



    SELECT v_result AS result_message;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ApproveStudentReceipt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ApproveStudentReceipt`(VNo INT, ApprovalType CHAR(25),

yr INT, trm INT, admn CHAR(25))
BEGIN

DECLARE VNumber,TransNo INT;

DECLARE VStat CHAR(25);

SET VNumber=fin_NextVoucherNo();



SELECT PostStatus INTO VStat FROM fin_vouchernumbers WHERE voucherno=VNo;

SELECT MAX(TNo) INTO TransNo FROM fin_studentfeestracking WHERE adm_no=admn AND T_Type='Payment' AND term_sem=trm AND acadyear=yr;

IF TransNo IS NULL THEN

SET TransNo=1;

ELSE

SET TransNo=1+TransNo;

END IF;



START TRANSACTION;



INSERT INTO fin_ledger(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller,folio)

SELECT accountcode, account_type, transactionType, transaction_amount, particulars, VNumber, transactionDate, teller,CONCAT('Voucher No',VNo)

FROM fin_voucher WHERE voucherno=VNo AND VStat='New';



INSERT INTO fin_studentfeestracking(adm_no, term_sem, acadyear, T_Amount, class_course, stream, itemCode, T_Type, TNo, PostStatus)

SELECT accountCode,trm,yr,transaction_amount,fin_GetStudClassStream(accountCode,yr,trm,'Class'),

fin_GetStudClassStream(accountCode,yr,trm,'Stream'),0,'Payment',TransNo,'Posted' FROM fin_voucher WHERE voucherno=VNo AND VStat='New'

AND transactionType='CR';



UPDATE fin_vouchernumbers SET PostStatus=ApprovalType WHERE voucherno=VNo;



COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ApproveVoucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ApproveVoucher`(VNo INT)
BEGIN

DECLARE VNumber INT;

DECLARE VStat CHAR(25);

SET VNumber=fin_NextVoucherNo();

SELECT PostStatus INTO VStat FROM fin_vouchernumbers WHERE voucherno=VNo;

INSERT INTO fin_ledger(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller,folio)

SELECT accountcode, account_type, transactionType, transaction_amount, particulars, VNumber, transactionDate, teller,CONCAT('Voucher No',VNo)

FROM fin_voucher WHERE voucherno=VNo AND VStat='New';

UPDATE fin_vouchernumbers SET PostStatus='Approved' WHERE voucherno=VNo;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AssetDeprecitionPostAccounts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AssetDeprecitionPostAccounts`()
BEGIN



SELECT sa.* FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON ma.accountCode=sa.MainAccountCode

WHERE ma.AccountName LIKE '%DEPRECIA%';



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AuditBillingIntegrity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_AuditBillingIntegrity`(
    IN p_regno VARCHAR(25)  
)
BEGIN
    
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

    
    SELECT 'SUMMARY' AS report_type,
           (SELECT COUNT(*) FROM fin_studentfeestracking WHERE trans_type = 'Bill'
            AND (p_regno IS NULL OR regno = p_regno)) AS total_bills,
           (SELECT COUNT(*) FROM fin_ledger WHERE source_system = 'Billing'
            AND (p_regno IS NULL OR accountcode = p_regno)) AS total_billing_ledger_entries,
           (SELECT COUNT(*) FROM fin_ledger WHERE tracking_ref IS NOT NULL
            AND (p_regno IS NULL OR accountcode = p_regno)) AS total_tracked_entries,
           (SELECT COUNT(DISTINCT tracking_ref) FROM fin_ledger WHERE tracking_ref IS NOT NULL
            AND (p_regno IS NULL OR accountcode = p_regno)) AS unique_tracking_refs;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_Autobilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_Autobilling`(
    reg CHAR(35), acad CHAR(15), sems INT, typ CHAR(25), usr CHAR(45), csid CHAR(25)
)
BEGIN
    DECLARE noItems,yr,cyr,noBilled,ItemID,bid INT;
    DECLARE prog,sess,regStat,resStat,Intk,rep CHAR(25);
    DECLARE done INT DEFAULT 0;
    DECLARE v_has_pf INT DEFAULT 0;

    SELECT progid,studsesion,intake,billingID,entryyear
    INTO prog,sess,Intk,bid,yr
    FROM campus_dynamics.acad_student WHERE regno=reg LIMIT 1;

    SELECT regstatus,studyyear,residence_status
    INTO regStat,cyr,resStat
    FROM campus_dynamics.acad_registration sr
    WHERE regno=reg AND acad_year=acad AND semester=sems LIMIT 1;

    SELECT COUNT(*) INTO v_has_pf
    FROM fin_programme_fees
    WHERE progcode=prog AND is_active='Yes';

    IF typ='REG' THEN
        IF regStat IN ('REGISTERED','LATE REGISTERED') THEN
            IF v_has_pf > 0 THEN
                CALL fin_BillProgrammeFees(reg,prog,sess,cyr,sems,acad,usr,csid);
                IF sess != 'Remote Learning' THEN
                    SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemID,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                    FROM fin_fees_pay_schedule fs
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND stud_session=sess AND semester=sems AND fs.ItemID NOT IN (1,52);
                ELSE
                    SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                    FROM fin_fees_structure fs,academicbillingitems bi
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND studsession=sess AND semester=sems
                    AND bi.ItemCode=fs.ItemCode AND fs.ItemCode NOT IN (1,52) AND itemname NOT LIKE '%Tuition%';
                END IF;
            ELSE
                IF sess != 'Remote Learning' THEN
                    SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemID,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                    FROM fin_fees_pay_schedule fs
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND stud_session=sess AND semester=sems;
                ELSE
                    SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,amount)
                    FROM fin_fees_structure fs,academicbillingitems bi
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr AND billingID=bid AND studsession=sess AND semester=sems
                    AND bi.ItemCode=fs.ItemCode AND itemname NOT LIKE '%Tuition%';
                END IF;
            END IF;
            IF regStat LIKE '%LATE%' THEN
                SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,SUM(amount)) INTO rep
                FROM fin_fees_structure fs,academicbillingitems bi
                WHERE progid=prog AND curr_year=yr AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid AND ItemName LIKE '%Late Reg%' LIMIT 1;
            END IF;
        ELSEIF regStat='DEAD YEAR' THEN
            SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,SUM(amount)) INTO rep
            FROM fin_fees_structure fs,academicbillingitems bi
            WHERE progid=prog AND curr_year=yr AND study_year=cyr AND semester=sems AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid AND ItemName LIKE '%Dead Year%' LIMIT 1;
        END IF;
    ELSEIF typ IN ('RT','RR','SPECIAL','SUPPLEMENTARY') THEN
        SELECT fin_TermlyItemBillingFN('Bill',reg,fs.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,SUM(amount)) INTO rep
        FROM fin_fees_structure fs,academicbillingitems bi
        WHERE progid=prog AND curr_year=yr AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid AND ItemName LIKE CONCAT('%',typ,'%') LIMIT 1;
    ELSEIF typ='ACCOMO' AND resStat='RESIDENT' THEN
        SELECT fin_TermlyItemBillingFN('Bill',reg,bi.ItemCode,sems,prog,sess,DATE(SYSDATE()),usr,cyr,acad,csid,price) INTO rep
        FROM campus_dynamics.acad_residence r,campus_dynamics.acad_halls h,academicbillingitems bi
        WHERE semester=sems AND acadyear=acad AND regno=reg AND h.ID=r.hall_id AND ItemName LIKE '%Accomoda%' LIMIT 1;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AutobillingV2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutobillingV2`(
    reg CHAR(35),
    acad CHAR(15),
    sems INT,
    typ CHAR(25),
    usr CHAR(45),
    csid CHAR(25)
)
BEGIN
    DECLARE noItems,yr,cyr,noBilled,ItemID,bid INT;
    DECLARE prog,sess,regStat,resStat,Intk,rep CHAR(25);
    DECLARE done INT DEFAULT 0;
    DECLARE v_has_pf INT DEFAULT 0;

    
    SELECT progid, studsesion, intake, billingID, entryyear
    INTO prog, sess, Intk, bid, yr
    FROM campus_dynamics.acad_student WHERE regno=reg LIMIT 1;

    
    SELECT regstatus, studyyear, residence_status
    INTO regStat, cyr, resStat
    FROM campus_dynamics.acad_registration sr
    WHERE regno=reg AND acad_year=acad AND semester=sems LIMIT 1;

    SET usr=reg;

    
    SELECT COUNT(*) INTO v_has_pf
    FROM fin_programme_fees
    WHERE progcode=prog AND is_active='Yes';

    IF typ='REG' THEN

        IF regStat IN ('REGISTERED','LATE REGISTERED') THEN

            IF v_has_pf > 0 THEN
                
                CALL fin_BillProgrammeFees(reg, prog, sess, cyr, sems, acad, usr, csid);

                
                IF sess != 'Remote Learning' THEN
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemID, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_pay_schedule fs
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND stud_session=sess AND semester=sems
                    AND fs.ItemID NOT IN (1, 52);
                ELSE
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_structure fs, academicbillingitems bi
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND studsession=sess AND semester=sems
                    AND bi.ItemCode=fs.ItemCode
                    AND fs.ItemCode NOT IN (1, 52)
                    AND itemname NOT LIKE '%Tuition%';
                END IF;

            ELSE
                
                IF sess != 'Remote Learning' THEN
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemID, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_pay_schedule fs
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND stud_session=sess AND semester=sems;
                ELSE
                    SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                        DATE(SYSDATE()), usr, cyr, acad, csid, amount)
                    FROM fin_fees_structure fs, academicbillingitems bi
                    WHERE progid=prog AND curr_year=yr AND studyyear=cyr
                    AND billingID=bid AND studsession=sess AND semester=sems
                    AND bi.ItemCode=fs.ItemCode AND itemname NOT LIKE '%Tuition%';
                END IF;
            END IF;

            
            IF regStat LIKE '%LATE%' THEN
                SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                    DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
                FROM fin_fees_structure fs, academicbillingitems bi
                WHERE progid=prog AND curr_year=yr
                AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid
                AND ItemName LIKE '%Late Reg%' LIMIT 1;
            END IF;

        ELSEIF regStat='DEAD YEAR' THEN
            
            SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
                DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
            FROM fin_fees_structure fs, academicbillingitems bi
            WHERE progid=prog AND curr_year=yr AND study_year=cyr
            AND semester=sems AND studsession=sess AND fs.ItemCode=bi.ItemCode AND billingID=bid
            AND ItemName LIKE '%Dead Year%' LIMIT 1;

        END IF;

    ELSEIF typ IN ('RT','RR','SPECIAL','SUPPLEMENTARY') THEN
        
        SELECT fin_TermlyItemBillingFN('Bill', reg, fs.ItemCode, sems, prog, sess,
            DATE(SYSDATE()), usr, cyr, acad, csid, SUM(amount)) INTO rep
        FROM fin_fees_structure fs, academicbillingitems bi
        WHERE progid=prog AND curr_year=yr AND studsession=sess AND fs.ItemCode=bi.ItemCode
        AND billingID=bid AND ItemName LIKE CONCAT('%',typ,'%') LIMIT 1;

    ELSEIF typ='ACCOMO' AND resStat='RESIDENT' THEN
        
        SELECT fin_TermlyItemBillingFN('Bill', reg, bi.ItemCode, sems, prog, sess,
            DATE(SYSDATE()), usr, cyr, acad, csid, price) INTO rep
        FROM campus_dynamics.acad_residence r, campus_dynamics.acad_halls h, academicbillingitems bi
        WHERE semester=sems AND acadyear=acad AND regno=reg AND h.ID=r.hall_id
        AND ItemName LIKE '%Accomoda%' LIMIT 1;

    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AutoBillOnRegistration` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutoBillOnRegistration`(
  IN p_regno CHAR(35),
  IN p_acadyear CHAR(15),
  IN p_semester INT,
  IN p_user CHAR(45)
)
BEGIN

  DECLARE v_regstatus CHAR(25) DEFAULT '';
  DECLARE v_resstatus CHAR(25) DEFAULT '';

  
  SELECT regstatus, residence_status
  INTO v_regstatus, v_resstatus
  FROM campus_dynamics.acad_registration
  WHERE regno = p_regno
    AND acad_year = p_acadyear
    AND semester = p_semester
  LIMIT 1;

  
  IF v_regstatus IN ('REGISTERED', 'LATE REGISTERED') THEN

    
    CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'REG', p_user, 'AUTO');

    
    IF v_resstatus = 'RESIDENT' THEN
      CALL fin_Autobilling(p_regno, p_acadyear, p_semester, 'ACCOMO', p_user, 'AUTO');
    END IF;

  END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AutoFeesCapture` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutoFeesCapture`(reg_no CHAR(25), stud_nm CHAR(65),bankCode CHAR(25),amount DOUBLE,TDate DATE,

teller CHAR(25), tx CHAR(150), tid INT)
BEGIN



DECLARE CRaccountType,DRParticulars,CRParticulars,yr,bankName,rtn  VARCHAR(150);

DECLARE TransNo,trm,nextVNo INT;



SELECT study_year,study_term INTO yr,trm FROM schooldynamics.adm_studentclasses WHERE adm_no=reg_no;





SELECT COUNT(*) INTO TransNo FROM fin_studentfeestracking WHERE regno=reg_no AND trans_type='Payment'

AND semester=trm AND acadyear=yr;



SET nextVNo=fin_NextVoucherNo(teller);



IF TransNo IS NULL THEN

SET TransNo=1;

ELSE

SET TransNo=1+TransNo;

END IF;



START TRANSACTION;



INSERT IGNORE INTO fin_studentfeestracking(regno, Amount, item_code,trans_type, post_status, acadyear, semester, trans_date,detail)

SELECT reg_no,amount,0,'Payment','Pending',yr,trm,SYSDATE(),CONCAT('Fees for Term : ',trm,', ',yr,' Payment No. ',TransNo) FROM DUAL;



SET CRaccountType='Student';

SET CRParticulars=CONCAT('Fees Payment for Term ',trm,', ',yr,' on ',DATE_FORMAT(TDate,'%d/%m/%Y'),' thru DFCU Bank TNo: ',tx);

SET DRParticulars=CONCAT('Paid on ',DATE_FORMAT(TDate,'%d/%m/%Y'),' by ',stud_nm,' TNo: ',tid);



SELECT fin_TransactionCreatorFn(regno,'Student',CRParticulars,

bankCode,'Chart Account',DRParticulars,amount,nextVNo,TDate,teller,CONCAT('ReceiptNo:',tid),'UGX') INTO rtn

FROM fin_studentfeestracking WHERE semester=trm AND acadyear=yr AND trans_type='Payment' AND regno=reg_no AND post_status!='Posted' AND amount>0;



UPDATE fin_studentfeestracking SET post_status='Posted' WHERE semester=trm AND acadyear=yr AND regno=reg_no AND trans_type='Payment';



UPDATE fin_ledger SET journal_no=fin_transactionNo(accountcode,account_type,TID) WHERE journal_no='-';





COMMIT;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AutoGTPAPayCapture` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutoGTPAPayCapture`(sec_key CHAR(100),tid CHAR(45))
BEGIN



DECLARE amount_ DOUBLE;

DECLARE TDate DATE;

DECLARE CRaccountType,DRParticulars,CRParticulars,StudySys,acad,reg,stud_nm,bankCode,teller,bankName,Curr VARCHAR(200);

DECLARE TransNo,semes,TCheck,currYear INT;



SELECT COUNT(*) INTO TCheck FROM temp_gta_transactions WHERE secure_code=sec_key AND confirm_status='Pending';





START TRANSACTION;



IF TCheck=1 THEN



  SELECT reg_no,amount,trans_currency INTO reg,amount_,Curr FROM temp_gta_transactions WHERE secure_code=sec_key;



  SET teller='Auto Capture';

  SET bankCode=IF(Curr='USD','AC5003','AC5001');

  SET bankName='Guaranty Trust Bank';

  SET TDate=DATE(SYSDATE());



  SET stud_nm=campus_dynamics.acad_GetStudNameByID(reg);

  SELECT acad_year,semester,studyYear INTO acad,semes,currYear FROM campus_dynamics.acad_registration WHERE regno=reg ORDER BY ID DESC LIMIT 1;



  SET CRaccountType=fin_GetStudentLedgerName(reg);

  SET CRParticulars=CONCAT('Fees Payment for ',StudySys,' ',semes,', ',acad,' on ',

  DATE_FORMAT(TDate,'%d/%m/%Y'),' thru ',bankName,' TNo: ',tid);

  SET DRParticulars=CONCAT('Paid on ',DATE_FORMAT(TDate,'%d/%m/%Y'),' by ',stud_nm,' TNo: ',tid);



  IF CRParticulars IS NULL THEN

  SET CRParticulars=CONCAT('Fees Payment  on ',

  DATE_FORMAT(TDate,'%d/%m/%Y'),' thru ',bankName,' TNo: ',tid);

  END IF;



  CALL fin_TransactionCreator(reg,CRaccountType,CRParticulars,bankCode, 'Chart Account',DRParticulars,amount_,0, SYSDATE(), teller,Curr,

  CONCAT('TransCode:',tid));



  INSERT IGNORE INTO fin_studentfeestracking(regno, acadyear,semester,amount, item_code, trans_type,detail,trans_date,post_status)

  SELECT reg,acad,semes,amount_,0,'Payment',CRParticulars,SYSDATE(),'Posted' FROM DUAL;



  UPDATE temp_gta_transactions SET confirm_status='Captured' WHERE secure_code=sec_key;

  CALL fin_UpdateLedgerBalances(reg);

  CALL fin_UpdateLedgerBalances(bankCode);



  SELECT 'Transaction Completed' AS comm FROM DUAL;



ELSE



  SELECT 'No Matching Transaction Found' AS comm FROM DUAL;





END IF;



COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AutoPayCapture` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_AutoProcessClearances` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_AutoProcessClearances`(acad CHAR(25), sem INT, clearance_type CHAR(25), stat CHAR(25),usr CHAR(35))
BEGIN





DROP TABLE IF EXISTS temp_reg;

CREATE TABLE temp_reg AS SELECT * FROM campus_dynamics.acad_registration;



IF clearance_type='Examination' THEN



IF stat='Pending' THEN

SET stat='-';

END IF;



SELECT fin_AutoClearance ('EXAM',regno, acad, sem,studyyear,usr) AS stats

 FROM temp_reg r WHERE acad_year=acad AND semester=sem AND examClearance='UNCLEARED';



ELSE



IF stat='Pending' THEN

SET stat='UNREGISTERED';

ELSE

SET stat='%';

END IF;



SELECT fin_AutoClearance ('REG',regno, acad, sem,studyyear,usr) AS stats FROM temp_reg r

WHERE acad_year=acad AND semester=sem  AND (regstatus LIKE stat AND regstatus!=IF(stat='%','UNREGISTERED',''));



END IF;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_BalanceSheet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_BalanceSheet`(sDate DATE, eDate DATE)
BEGIN



DECLARE surplus BIGINT;

SET surplus=fin_GetSurplusDeficit(sDate);







SELECT 'BALANCE SHEET' AS docHeader,'ASSETS' header,DATE_FORMAT(sDate,'%d/%m/%Y') AS startDate,DATE_FORMAT(eDate,'%d/%m/%Y') endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'Current Assets' header,DATE_FORMAT(sDate,'%d/%m/%Y') AS startDate,DATE_FORMAT(eDate,'%d/%m/%Y') endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'',DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,

FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE SubCategory='Current Assets')

AS findata



UNION



SELECT 'BALANCE SHEET' AS docHeader,'Total Current Assets','','','','',fin_BalanceSheetSubTotals('DR',sDate,eDate,'Current Assets') AS DRTotal,

fin_BalanceSheetSubTotals('CR',sDate,eDate,'Current Assets') AS CRTotal FROM DUAL





UNION



SELECT 'BALANCE SHEET' AS docHeader,'Fixed Assets' header,DATE_FORMAT(sDate,'%d/%m/%Y') AS startDate,DATE_FORMAT(eDate,'%d/%m/%Y') endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'',DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,

FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE SubCategory='Fixed Assets')

AS findata



UNION



SELECT 'BALANCE SHEET' AS docHeader,'Total Fixed Assets','','','','',fin_BalanceSheetSubTotals('DR',sDate,eDate,'Fixed Assets') AS DRTotal,

fin_BalanceSheetSubTotals('CR',sDate,eDate,'Fixed Assets') AS CRTotal FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'TOTAL ASSETS','','','','',fin_BalanceSheetTotals('DR',sDate,eDate,'Assets') AS DRTotal,

fin_BalanceSheetTotals('CR',sDate,eDate,'Assets') AS CRTotal FROM DUAL



UNION





SELECT 'BALANCE SHEET' AS docHeader,'','','','','','' AS DRTotal,'' AS CRTotal FROM DUAL



UNION





SELECT 'BALANCE SHEET' AS docHeader,'LIABILITIES & EQUITY' header,'' startDate,'' endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'LIABILITIES' header,'' startDate,'' endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'Current Liabilities' header,DATE_FORMAT(sDate,'%d/%m/%Y') AS startDate,DATE_FORMAT(eDate,'%d/%m/%Y') endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'',DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,

FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE SubCategory='Current Liabilities')

AS findata



UNION



SELECT 'BALANCE SHEET' AS docHeader,'Total Current Liabilities','','','','',fin_BalanceSheetSubTotals('DR',sDate,eDate,'Current Liabilities') AS DRTotal,

fin_BalanceSheetSubTotals('CR',sDate,eDate,'Current Assets') AS CRTotal FROM DUAL





UNION



SELECT 'BALANCE SHEET' AS docHeader,'Fixed Liabilities' header,DATE_FORMAT(sDate,'%d/%m/%Y') AS startDate,DATE_FORMAT(eDate,'%d/%m/%Y') endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'',DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,

FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE SubCategory='Fixed Liabilities')

AS findata



UNION



SELECT 'BALANCE SHEET' AS docHeader,'Total Fixed Liabilities','','','','',fin_BalanceSheetSubTotals('DR',sDate,eDate,'Fixed Liabilities') AS DRTotal,

fin_BalanceSheetSubTotals('CR',sDate,eDate,'Fixed Assets') AS CRTotal FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'TOTAL LIABILITIES','','','','',fin_BalanceSheetTotals('DR',sDate,eDate,'Liabilities') AS DRTotal,

fin_BalanceSheetTotals('CR',sDate,eDate,'Liabilities') AS CRTotal FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'EQUITY' header,'' startDate,'' endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'',DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,

FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory

IN ('Equity'))

AS findata



UNION



SELECT 'BALANCE SHEET' AS docHeader,'','','','','Net Income',fin_OperatingIncome('DR',sDate,eDate) AS DRTotal,

fin_OperatingIncome('CR',sDate,eDate) AS CRTotal FROM DUAL



UNION



SELECT 'BALANCE SHEET' AS docHeader,'','','',accountcode,accountname,

IF(surplus>0,FORMAT(surplus,0),'') AS DRBalance,IF(surplus<0,FORMAT(ABS(surplus),0),'') AS CRBalance FROM fin_subaccounts

WHERE Accountname LIKE 'Retained%'



UNION



SELECT 'BALANCE SHEET' AS docHeader,'Total Equity','','','','',fin_EquityTotals('DR',sDate,eDate) AS DRTotal,

fin_EquityTotals('CR',sDate,eDate) AS CRTotal FROM DUAL





UNION



SELECT 'BALANCE SHEET' AS docHeader,'TOTAL LIABILITIES & EQUITY','','','','',fin_EquityLiabilityTotals('DR',sDate,eDate) AS DRTotal,

fin_EquityLiabilityTotals('CR',sDate,eDate) AS CRTotal FROM DUAL;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_BenefitPayment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_BenefitPayment`(usr CHAR(25),memID CHAR(25), mnth CHAR(25),yr INT, amount INT,

bankAccount CHAR(15), TDate DATE, prodID INT)
BEGIN



DECLARE subscriptAccount,acctype,paycheck,prod_name,custLedger CHAR(65);

DECLARE vno INT;

SET vno=fin_NextVoucherNo();

SELECT paymentMethod INTO bankAccount FROM mem_membership WHERE memberno=memID;



SELECT collectionLedgertype INTO acctype FROM fin_subaccounts s WHERE accountcode=bankAccount;



SELECT customerLedgerType,benefitName INTO custLedger,prod_name FROM fin_benefits WHERE benefitID=prodID;



START TRANSACTION;



  UPDATE fin_benefitpayments SET PayStatus='Paid',datePaid=TDate  WHERE memberID=memID AND benefitID=prodID AND benefit_month=mnth

  AND benefit_year=yr;

  SELECT fin_transactioncreatorFn

  (bankAccount,acctype,CONCAT(prod_name,' payment for ',surname,' For ',mnth,', ',yr),

   memID,custLedger,CONCAT('Payment of ',prod_name, ' for the month of ',mnth,', ',yr),

   amount,vno,TDate,usr) FROM mem_membership WHERE memberno=memID;



COMMIT;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_BenefitsBilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_BenefitsBilling`(yr INT, mnth CHAR(25), TDate DATE,usr CHAR(25), prodID BIGINT,

percent double)
BEGIN

DECLARE subscriptAccount,acctype,custLedger,prodType,prodName,amtSetting CHAR(150);

DECLARE vno INT;

DECLARE amt BIGINT;



SET vno=fin_NextVoucherNo();

SELECT chartAccount, customerLedgerType,benefitType,benefitName,amountSetting

INTO subscriptAccount,custLedger,prodType,prodName,amtSetting FROM fin_benefits

WHERE benefitID=prodID;

SET accType=fin_GetChartAccountLegderType(subscriptAccount);



INSERT INTO fin_benefitpayments(memberID, benefit_month, benefit_year, benefit_amount, benefit_comments,benefitID)

SELECT memberno,mnth,yr,fin_BenefitCaculator(memberno,prodID,percent),

fin_transactioncreatorFn

(memberno,custLedger,CONCAT(prodName,' for ',mnth,', ',yr),

subscriptAccount,acctype,CONCAT(prodName,'for ',surname,' For ',mnth,', ',yr),

fin_BenefitCaculator(memberno,prodID,percent),vno,TDate,usr),prodID FROM mem_membership

WHERE status='Active' AND fin_BenefitCheck(memberno,mnth,yr,prodID)=0

AND fin_BenefitCaculator(memberno,prodID,percent)>0 AND fin_BenefitQualifier(memberno,prodID,percent)=1;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_BillFix_Apply` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_BillFix_Apply`(IN p_batch VARCHAR(40), IN p_max INT)
BEGIN
  DECLARE v_done INT DEFAULT 0;
  DECLARE v_err  INT DEFAULT 0;
  DECLARE v_reg  VARCHAR(35);
  DECLARE v_acad VARCHAR(15);
  DECLARE v_sem  INT;
  DECLARE v_yr   INT;
  DECLARE v_prog VARCHAR(25);
  DECLARE v_sess VARCHAR(25);
  DECLARE v_n    INT DEFAULT 0;

  DECLARE cur CURSOR FOR
    SELECT DISTINCT regno, acadyear, semester, studyyear, progid, session
    FROM fin_billfix_worklist
    WHERE batch_id = p_batch AND status = 'PLANNED'
    ORDER BY regno, acadyear, semester;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_err = 1;

  OPEN cur;
  loop1: LOOP
    IF p_max > 0 AND v_n >= p_max THEN LEAVE loop1; END IF;
    SET v_done = 0;
    FETCH cur INTO v_reg, v_acad, v_sem, v_yr, v_prog, v_sess;
    IF v_done = 1 THEN LEAVE loop1; END IF;

    SET v_err = 0;
    CALL fin_BillProgrammeFees(v_reg, v_prog, COALESCE(NULLIF(TRIM(v_sess),''),'Day'),
                               v_yr, v_sem, v_acad, 'system', 'AUTO');

    IF v_err = 1 THEN
      UPDATE fin_billfix_worklist
        SET status = 'FAILED', reason = 'billing error', applied_at = NOW()
        WHERE batch_id = p_batch AND regno = v_reg AND acadyear = v_acad
          AND semester = v_sem AND status = 'PLANNED';
    ELSE
      
      UPDATE fin_studentfeestracking t
        JOIN fin_billfix_worklist w
          ON w.batch_id = p_batch AND w.regno = t.regno AND w.acadyear = t.acadyear
         AND w.semester = t.semester AND w.item_code = t.item_code
        SET t.fix_batch_id = p_batch
        WHERE t.trans_type = 'Bill' AND t.fix_batch_id IS NULL
          AND t.regno = v_reg AND t.acadyear = v_acad AND t.semester = v_sem;

      
      UPDATE fin_ledger l
        JOIN fin_studentfeestracking t ON l.folio = CONCAT('BillNo:', t.TID)
        SET l.source_system = 'BILLFIX', l.RefNo = p_batch
        WHERE t.fix_batch_id = p_batch AND t.regno = v_reg AND t.acadyear = v_acad
          AND t.semester = v_sem
          AND (l.source_system IS NULL OR l.source_system <> 'BILLFIX');

      
      UPDATE fin_billfix_worklist w
        JOIN fin_studentfeestracking t
          ON t.regno = w.regno AND t.acadyear = w.acadyear AND t.semester = w.semester
         AND t.item_code = w.item_code AND t.trans_type = 'Bill' AND t.fix_batch_id = p_batch
        SET w.status = 'APPLIED', w.tracking_tid = t.TID,
            w.ledger_dr_tid = (SELECT TID FROM fin_ledger WHERE folio = CONCAT('BillNo:', t.TID) AND transactionType = 'DR' LIMIT 1),
            w.ledger_cr_tid = (SELECT TID FROM fin_ledger WHERE folio = CONCAT('BillNo:', t.TID) AND transactionType = 'CR' LIMIT 1),
            w.balance_after = w.balance_before - w.amount,
            w.applied_at = NOW()
        WHERE w.batch_id = p_batch AND w.regno = v_reg AND w.acadyear = v_acad
          AND w.semester = v_sem AND w.status = 'PLANNED';

      
      UPDATE fin_billfix_worklist
        SET status = 'SKIPPED', reason = 'no bill created (fee 0 / already billed)', applied_at = NOW()
        WHERE batch_id = p_batch AND regno = v_reg AND acadyear = v_acad
          AND semester = v_sem AND status = 'PLANNED';
    END IF;

    SET v_n = v_n + 1;
  END LOOP;
  CLOSE cur;

  SELECT v_n AS groups_processed;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_BillProgrammeFees` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_BillProgrammeFees`(
    IN p_regno CHAR(35),
    IN p_progcode CHAR(25),
    IN p_session CHAR(25),
    IN p_study_year INT,
    IN p_semester INT,
    IN p_acad_year CHAR(15),
    IN p_user CHAR(45),
    IN p_csid CHAR(25)
)
BEGIN
    DECLARE v_tuition DECIMAL(15,2) DEFAULT 0;
    DECLARE v_functional DECIMAL(15,2) DEFAULT 0;
    DECLARE v_dummy CHAR(25);

    
    CALL fin_GetProgrammeFee(p_progcode, p_study_year, p_semester, v_tuition, v_functional);

    
    IF v_tuition > 0 THEN
        SELECT fin_TermlyItemBillingFN('Bill', p_regno, 1, p_semester, p_progcode,
            p_session, DATE(SYSDATE()), p_user, p_study_year, p_acad_year, p_csid, v_tuition)
        INTO v_dummy;
    END IF;

    
    IF v_functional > 0 THEN
        SELECT fin_TermlyItemBillingFN('Bill', p_regno, 52, p_semester, p_progcode,
            p_session, DATE(SYSDATE()), p_user, p_study_year, p_acad_year, p_csid, v_functional)
        INTO v_dummy;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_BuildReportTBBalances` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_BuildReportTBBalances`(IN sDate DATE, IN eDate DATE)
BEGIN

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_subaccounts;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_balances;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_subaccounts

    (

        AccountCode VARCHAR(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        accounttype VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        collectionLedgerType VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        PRIMARY KEY(AccountCode),

        KEY idx_collectionLedgerType(collectionLedgerType)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_report_tb_subaccounts

    SELECT

        CONVERT(s.AccountCode USING utf8),

        LEFT(CONVERT(s.AccountName USING utf8), 191),

        CONVERT(s.accounttype USING utf8),

        CONVERT(s.collectionLedgerType USING utf8),

        CONVERT(fin_GetTrialBalanceGroup(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountCategory(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountSubCategory(s.AccountCode) USING utf8)

    FROM fin_subaccounts s;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_movements

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /* Same direct COA logic as fin_TrialBalance. */

    INSERT INTO tmp_mru_report_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'DR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS DRTotal,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'CR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS CRTotal,

        COALESCE(SUM(CASE

            WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            ELSE 0 END), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_report_tb_subaccounts s

        ON s.AccountCode = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= sDate

      AND f.transactionDate < DATE_ADD(eDate, INTERVAL 1 DAY)

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY s.MAC, s.category, s.subcategory, s.AccountCode, s.AccountName;



    /* Same subledger-control logic as fin_TrialBalance. */

    INSERT INTO tmp_mru_report_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'DR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS DRTotal,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'CR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS CRTotal,

        COALESCE(SUM(CASE

            WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            ELSE 0 END), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_report_tb_subaccounts s

        ON s.collectionLedgerType = CONVERT(f.account_type USING utf8)

    LEFT JOIN fin_subaccounts directcoa

        ON CONVERT(directcoa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= sDate

      AND f.transactionDate < DATE_ADD(eDate, INTERVAL 1 DAY)

      AND directcoa.AccountCode IS NULL

      AND IFNULL(s.collectionLedgerType,'') <> ''

      AND IFNULL(s.accounttype,'') <> 'Basic Account'

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY s.MAC, s.category, s.subcategory, s.AccountCode, s.AccountName;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_balances

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode),

        KEY idx_category(category)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_report_tb_balances

    SELECT

        MAC,

        category,

        subcategory,

        AccountCode,

        AccountName,

        SUM(DRTotal) AS DRTotal,

        SUM(CRTotal) AS CRTotal,

        SUM(balance) AS balance

    FROM tmp_mru_report_tb_movements

    GROUP BY MAC, category, subcategory, AccountCode, AccountName

    HAVING ROUND(SUM(balance), 2) <> 0

        OR ROUND(SUM(DRTotal), 2) <> 0

        OR ROUND(SUM(CRTotal), 2) <> 0;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_subaccounts;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ChangeMainAccountCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ChangeMainAccountCode`(oldcode cHaR(25),newCode CHAR(25))
BEGIN



UPDATE fin_mainaccounts SET AccountCode=newCode WHERE AccountCode=oldcode;

UPDATE fin_subaccounts SET MainAccountCode=newCode WHERE MainAccountCode=oldcode;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ChangeSubAccoutCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ChangeSubAccoutCode`(oldcode cHaR(25),newCode CHAR(25))
BEGIN

UPDATE IGNORE fin_subaccounts SET accountcode=newcode WHERE accountcode=oldcode;

UPDATE fin_ledger SET accountcode=newcode WHERE accountcode=oldcode;

UPDATE fin_journal_details SET accountcode=newcode WHERE accountcode=oldcode;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CheckClearance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CheckClearance`(cat CHAR(25),reg CHAR(25), acad CHAR(15), sem INT,cyr INT)
BEGIN

DECLARE prog,studSys,c_stat,sess,r_stat CHAR(45);

DECLARE eyr INT;

DECLARE t_amount,f_amount,p_amount,e_amount,op_amount,cur_bal,b_amount DOUBLE;

DECLARE sDate,eDate DATE;



SELECT progid,entryyear,studsesion INTO prog,eyr,sess FROM campus_dynamics.acad_student WHERE regno=reg;

SELECT study_system INTO studSys FROM campus_dynamics.acad_programme WHERE progcode=prog;

SELECT examClearance,regstatus INTO c_stat,r_stat FROM campus_dynamics.acad_registration WHERE regno=reg AND acad_year=acad AND semester=sem LIMIT 1;



SELECT ps.amount INTO t_amount FROM fin_fees_structure fs, fin_fees_pay_schedule ps,academicbillingitems bi

WHERE ps.ItemID=fs.ID AND bi.ItemCode=fs.ItemCode AND progid=prog AND studyyear=cyr AND semester=sem AND studsession=sess

AND ItemName LIKE 'Tuition%' AND entry_year=eyr LIMIT 1;



SELECT SUM(ps.amount) INTO f_amount FROM fin_fees_structure fs, fin_fees_pay_schedule ps,academicbillingitems bi

WHERE ps.ItemID=fs.ID AND bi.ItemCode=fs.ItemCode AND progid=prog AND studyyear=cyr AND semester=sem AND studsession=sess

AND ItemName NOT LIKE 'Tuition%' AND entry_year=eyr;



SELECT event_date INTO sDate FROM campus_dynamics.acad_calenda WHERE acad_year=acad AND semester=sem AND item_name='Start Date'

AND study_system=studSys ;

SELECT event_date INTO eDate FROM campus_dynamics.acad_calenda WHERE acad_year=acad AND semester=sem AND item_name='End Date'

AND study_system=studSys;



SET op_amount=fin_GetFeesBalance('Opening',sDate,eDate,reg);

SET p_amount=fin_GetFeesBalance('TotalPay',sDate,eDate,reg);

SET b_amount=fin_GetFeesBalance('TotalBill',sDate,eDate,reg);

SET cur_bal=fin_GetFeesBalance('Current',sDate,eDate,reg);



SET e_amount=(t_amount*0.6)+f_amount;



IF cat='REG' THEN



  IF (op_amount+p_amount)>=e_amount  THEN

   SELECT CONCAT('CLEARED') AS stat FROM DUAL;

  ELSE

  SELECT CONCAT('UNCLEARED') AS stat FROM DUAL;

  END IF;



ELSE



  IF (cur_bal<=0) THEN



   SELECT CONCAT('CLEARED') AS stat FROM DUAL;

  ELSE

  SELECT 'UNCLEARED' AS stat FROM DUAL;

  END IF;



END IF;













END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ClearJournalDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ClearJournalDetails`(jno TEXT)
BEGIN
    DELETE FROM fin_journal_details
    WHERE TRIM(journal_no) = TRIM(jno)
       OR TRIM(journal_no) = CONCAT('JN-', TRIM(jno));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ClearLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_ClearLedger`(acc CHAR(25), typ CHAR(25),usr CHAR(35))
BEGIN

DECLARE st_typ CHAR(35);



IF typ='Student' THEN

  SET st_typ='%Fees';

ELSE

  SET st_typ='-';

END IF;



INSERT INTO fin_deleted_ledger (TID, accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo,

transactionDate, teller, timeLog, folio, journal_no, trans_currency, actual_amount, curr_balance,del_status)

SELECT TID, accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo,

DATE(SYSDATE()), usr, SYSDATE(), folio, journal_no, trans_currency, actual_amount, curr_balance,'Pending'

FROM fin_ledger WHERE voucherNo IN (SELECT voucherNo FROM fin_ledger WHERE accountcode=acc AND

(account_type=typ OR account_type LIKE st_typ));



DELETE FROM fin_ledger WHERE TID IN (SELECT TID FROM fin_deleted_ledger WHERE del_status='Pending');



IF typ='Student' OR st_typ!='-' THEN

   DELETE FROM fin_studentfeestracking WHERE regno=acc;

END IF;



UPDATE fin_deleted_ledger SET del_status='Deleted' WHERE del_status='Pending';



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CorrectionBilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CorrectionBilling`(regn CHAR(35), acad CHAR(15), sems INT,typ CHAR(25),usr CHAR(45),res CHAR(25))
BEGIN





DELETE FROM fin_ledger WHERE folio IN (SELECT CONCAT('BillNo:',TID) FROM fin_studentfeestracking

WHERE regno=regn AND semester=sems AND acadyear=acad AND trans_type='Bill');



DELETE FROM fin_studentfeestracking WHERE regno=regn AND semester=sems AND acadyear=acad AND trans_type='Bill';



CALL fin_autobilling(regn,acad,sems,typ,usr,'-');



IF res='RESIDENT' THEN

CALL fin_autobilling(regn,acad,sems,'ACCOMO',usr,'-');

END IF;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CreateBudget` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CreateBudget`(yr INT, cat CHAR(15))
BEGIN



IF cat='EXPENDITURE' THEN

SET cat='Expense';

END IF;



INSERT IGNORE INTO fin_budget(item_code, details, planned_amount, actual_amount, vote_status, item_category, budget_year)

SELECT s.accountcode,'-',0,0,'Normal',cat,yr FROM fin_subaccounts s, fin_mainaccounts m WHERE m.accountcode=s.mainaccountcode

AND generalcategory=cat;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CreateFinDocuments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CreateFinDocuments`(s_date DATE, e_date DATE,doc VARCHAR(25),usr VARCHAR(45))
BEGIN



DELETE

  FROM fin_accounts_docs

WHERE created_by = usr;



IF (doc='Trial Balance (Detail)') THEN

INSERT INTO fin_accounts_docs (account_code, total_dr, total_cr, opening, created_by, sdate, edate)

  SELECT

    IF(gl_account IS NULL, op.op_account, gl_account),

    total_dr,

    total_cr,

    opbal,

    usr,

    s_date,

    e_date

  FROM (SELECT

      fin_GetTransactionGL(accountcode, account_type) AS gl_account,

      SUM(IF(transactionType = 'DR', transaction_amount, 0)) AS total_dr,

      SUM(IF(transactionType = 'CR', transaction_amount, 0)) AS total_cr,

      usr

    FROM fin_ledger

    WHERE transactiondate BETWEEN s_date AND

    e_date

    GROUP BY fin_GetTransactionGL(accountcode, account_type)) AS core

    LEFT OUTER JOIN (SELECT

        fin_GetTransactionGL(accountcode, account_type) AS op_account,

        SUM(IF(transactionType = 'DR', transaction_amount, 1 * transaction_amount)) AS opbal

      FROM fin_ledger

      WHERE transactiondate < s_date

      GROUP BY fin_GetTransactionGL(accountcode, account_type)) AS op

      ON op.op_account = core.gl_account;



UPDATE fin_accounts_docs d, fin_subaccounts s, fin_mainaccounts m

SET account_name = s.AccountName,

    item_category = m.GeneralCategory,

    item_sub_category = m.SubCategory

WHERE d.account_code = s.AccountCode

AND m.AccountCode = s.MainAccountCode

AND created_by = usr;



UPDATE fin_accounts_docs

SET opening = 0

WHERE item_category IN ('Income', 'Expense')

AND created_by = usr

OR opening IS NULL;



UPDATE fin_accounts_docs

SET balance = (opening + total_dr - total_cr),

    print_order = fin_print_order(item_category)

WHERE created_by = usr;



ELSEIF (doc = 'Trial Balance (Summary)') THEN

INSERT INTO fin_accounts_docs (account_code, account_name, total_dr, total_cr, opening, created_by, sdate, edate, item_category, item_sub_category)

  SELECT

    s.MainAccountCode,

    m.AccountName,

    SUM(total_dr),

    SUM(db.total_cr),

    SUM(db.opbal),

    usr,

    s_date,

    e_date,

    m.GeneralCategory,

    m.SubCategory

  FROM (SELECT

           IF(gl_account IS NULL, op.op_account, gl_account) AS gl_account,

           total_dr,

           total_cr,

           opbal,

           usr,

           s_date,

           e_date

         FROM (SELECT

             fin_GetTransactionGL(accountcode, account_type) AS gl_account,

             SUM(IF(transactionType = 'DR', transaction_amount, 0)) AS total_dr,

             SUM(IF(transactionType = 'CR', transaction_amount, 0)) AS total_cr,

             usr

           FROM fin_ledger

           WHERE transactiondate BETWEEN s_date AND

           e_date

           GROUP BY fin_GetTransactionGL(accountcode, account_type)) AS core

           LEFT OUTER JOIN (SELECT

               fin_GetTransactionGL(accountcode, account_type) AS op_account,

               SUM(IF(transactionType = 'DR', transaction_amount, 1 * transaction_amount)) AS opbal

             FROM fin_ledger

             WHERE transactiondate < s_date

             GROUP BY fin_GetTransactionGL(accountcode, account_type)) AS op

             ON op.op_account = core.gl_account) AS db,

       fin_mainaccounts m,

       fin_subaccounts s

  WHERE m.AccountCode = s.MainAccountCode

  AND s.AccountCode = db.gl_account

  GROUP BY s.MainAccountCode;



UPDATE fin_accounts_docs

SET opening = 0

WHERE item_category IN ('Income', 'Expense')

AND created_by = usr

OR opening IS NULL;



UPDATE fin_accounts_docs

SET balance = (opening + total_dr - total_cr),

    print_order = fin_print_order(item_category)

WHERE created_by = usr;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CreateGraduationClearanceList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CreateGraduationClearanceList`(acad CHAR(15))
BEGIN

DELETE FROM acad_graduation_clearance WHERE stud_reg_no NOT IN (SELECT regno FROM campus_dynamics.acad_graduands);

INSERT IGNORE INTO acad_graduation_clearance(ID,stud_reg_no,comp_year,cur_balance,clear_status,stud_name,progid)

SELECT ID,regno,acadyear,fin_GetCurrentFeesBalance(regno),'Pending',stud_name,progcode 

FROM campus_dynamics.acad_graduands WHERE acadyear=acad;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CreateJournal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CreateJournal`(typ CHAR(25), JDate DATE, usr CHAR(25))
BEGIN



INSERT INTO fin_journalnumbers(Teller, PostStatus, journalType, journalDate,

journalParticulars, journal_serialno, voucherType, GL_VoucherNo,RefNo)

VALUES (usr,'Pending',typ,JDate,'-',fin_NextJournalSerial(typ),'General Voucher','0','-');



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CreateNewBatchStructure` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CreateNewBatchStructure`(Item INT, sess CHAR(15), yr INT, sem INT,cyr INT,amt DOUBLE,bid INT)
BEGIN



INSERT IGNORE INTO fin_fees_structure(ItemCode, progid, studsession, amount, curr_year,semester,study_year,billingID)

SELECT Item,progcode,sess,amt,yr,sem,cyr,bid FROM campus_dynamics.acad_programme;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CreateNewStructure` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CreateNewStructure`(prog CHAR(25), sess CHAR(15), yr INT, sem INT,cyr INT,bid INT)
BEGIN



INSERT IGNORE INTO fin_fees_structure(ItemCode, progid, studsession, amount, curr_year,semester,study_year,billingID)

SELECT ItemCode,prog,sess,0,yr,sem,cyr,bid FROM academicbillingitems;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CreateSupplierTransaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CreateSupplierTransaction`(sid CHAR(25),sname VARCHAR(200),

typ CHAR(25),amt DOUBLE, details VARCHAR(255),acc_code CHAR(25),acc_name VARCHAR(250),usr CHAR(35),InvoDate date, ref_no CHAR(35))
BEGIN



IF typ='BANK' THEN



SELECT fin_TransactionCreatorFn(

acc_code,'Chart Account',CONCAT(details,' By ',sname),

sid,'Supplier',CONCAT(details,' thru ',acc_name),

amt,fin_NextVoucherNo(usr),SYSDATE(),usr,'-','UGX',InvoDate,ref_no) FROM DUAL;



INSERT INTO acc_activity_log(user_id, page_function, par, comments, access_date)

VALUES(usr,'Supplier Transactions',CONCAT('PAYMENT Transaction. Supplier: ',sname,', Bank: ',acc_name),'Created Payment Transaction',SYSDATE());



ELSEIF typ='EXPENSE' THEN



SELECT fin_TransactionCreatorFn(

sid,'Supplier',CONCAT(details,' Expense Acc: ',acc_name),

acc_code,'Chart Account',CONCAT(details,' By ',sname),

amt,fin_NextVoucherNo(usr),SYSDATE(),usr,'-','UGX',InvoDate,ref_no) FROM DUAL;



INSERT INTO acc_activity_log(user_id, page_function, par, comments, access_date)

VALUES(usr,'Supplier Transactions',CONCAT('INVOICE Transaction. Supplier: ',sname,', Expense ACC: ',acc_name),'Created Payment Transaction',SYSDATE());



END IF;



UPDATE fin_ledger SET journal_no=fin_transactionNo(accountcode,account_type,TID) WHERE journal_no='-';



CALL fin_UpdateAllLedgerBalances();









END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_CustomBilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_CustomBilling`(reg CHAR(35), trm INT, yr INT, usr CHAR(25),dt DATE,ItemID INT, amount DOUBLE)
BEGIN

DECLARE noItems,eyr,cyr,noBilled INT;

DECLARE prog,sess CHAR(25);




    SELECT fin_CustomTermlyItemBillingFN(reg,ItemID,trm,dt,usr,yr,amount) FROM DUAL;



    UPDATE fin_ledger SET journal_no=fin_transactionNo(accountcode,account_type,TID) WHERE journal_no='-';





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DeleteAsset` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_DeleteAsset`(usr CHAR(25),AID CHAR(25))
BEGIN



START TRANSACTION;



DELETE FROM fixedassetregister WHERE AssetID=AID;



COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DeleteBenefitInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_DeleteBenefitInfo`(subID INT, usr CHAR(25))
BEGIN

DECLARE submonth, memno,payStat,ledgerType,benefName CHAR(150);



DECLARE subYear,BillVoucher,payVoucher,prodID INT;



SELECT memberID, benefit_month, benefit_year, PayStatus, benefitID

INTO memno,submonth,subYear,payStat,prodID

FROM fin_benefitpayments WHERE BID=subID;



SELECT customerLedgerType,benefitName

INTO ledgerType,benefName FROM fin_benefits WHERE benefitID=prodID;



SELECT voucherno INTO BillVoucher FROM fin_ledger WHERE accountcode=memno AND account_type=ledgerType

AND particulars LIKE CONCAT('%',submonth,', ',subYear,'%') AND particulars LIKE CONCAT('%',ledgerType,'%') AND transactiontype='DR';

SELECT voucherno INTO payVoucher FROM fin_ledger WHERE accountcode=memno AND account_type=ledgerType

AND particulars LIKE CONCAT('%',submonth,', ',subYear,'%') AND particulars LIKE CONCAT('%',ledgerType,'%') AND transactiontype='CR';



IF payvoucher IS NULL THEN

  SET payvoucher=0;

END IF;





DELETE FROM fin_benefitpayments WHERE BID=subID;

DELETE FROM fin_ledger WHERE voucherno IN (BillVoucher,payVoucher);







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DeleteLedgerCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_DeleteLedgerCategory`(lid INT)
BEGIN



DELETE FROM fin_ledgertypes WHERE LedgerTypeID=lid;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DeleteSubscriptionInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_DeleteSubscriptionInfo`(subID INT, usr CHAR(25))
BEGIN

DECLARE submonth, memno,payStat,ledgerType CHAR(25);

DECLARE subYear,BillVoucher,payVoucher,prodID INT;

SELECT memberID, sub_month, sub_year, PayStatus, productID

INTO memno,submonth,subYear,payStat,prodID

FROM fin_subscription WHERE SID=subID;

SELECT customerLedgerType

INTO ledgerType

FROM fin_products WHERE productID=prodID;

SELECT voucherno INTO BillVoucher FROM fin_ledger WHERE accountcode=memno AND account_type=ledgerType AND particulars LIKE CONCAT('%',submonth,', ',subYear,'%') AND transactiontype='DR';

SELECT voucherno INTO payVoucher FROM fin_ledger WHERE accountcode=memno AND account_type=ledgerType AND particulars LIKE CONCAT('%',submonth,', ',subYear,'%') AND transactiontype='CR';



IF payvoucher IS NULL THEN

  SET payvoucher=0;

END IF;





DELETE FROM  fin_subscription WHERE SID=subID;

DELETE FROM fin_ledger WHERE voucherno IN (BillVoucher,payVoucher);







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_delete_journal_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_delete_journal_item`(_id INT,jno INT)
BEGIN



DECLARE stat CHAR(25);

SELECT PostStatus INTO stat FROM fin_journalnumbers WHERE JournalNo=jno;

IF stat='Pending' THEN

DELETE FROM fin_journal_details WHERE TID=_id;

ELSE

DELETE FROM fin_ledger WHERE TID=_id;

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_Depreciator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_Depreciator`(

assetCodes CHAR(25),

TransactionDate DATE,

Teller CHAR(15), depAccount CHAR(15),months CHAR(15), yr INT)
BEGIN



DECLARE particulars CHAR(150);

DECLARE Amount,CurValue DOUBLE;

DECLARE depStatus INT;



SELECT COUNT(*) INTO depStatus FROM depreciationrecords WHERE assetCode=assetCodes AND currMonth=months;



IF depStatus=0 THEN



SET Amount=fin_GetDepreciation(assetCodes);

SELECT originalcost-fin_GetDepreciationValues(AssetID,months,yr,'Cumulative') INTO CurValue FROM fixedassetregister WHERE assetID=assetCodes;



IF curValue>Amount THEN



SET particulars=CONCAT('Depreciation Expense for ',months,', ',yr);





START TRANSACTION;



CALL fin_TransactionCreator(assetCodes,fin_GetAssetLedgerCategory(assetCodes,'Depreciation'),particulars,

depAccount,'Chart Account',CONCAT(particulars,' for Asset No: ',assetCodes),Amount,fin_NextVoucherNo(),

TransactionDate,Teller);



INSERT INTO depreciationrecords(assetCode, currMonth, currYear, DepAmount)

VALUES (assetCodes,months,yr,Amount) ON DUPLICATE KEY UPDATE DepAmount=Amount;





COMMIT;



END IF;



END IF;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_Cashbook` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_Cashbook`(

    IN p_start_date DATE,

    IN p_end_date DATE

)
BEGIN

    DROP TEMPORARY TABLE IF EXISTS tmp_cb_opening;

    DROP TEMPORARY TABLE IF EXISTS tmp_cb_txns_raw;

    DROP TEMPORARY TABLE IF EXISTS tmp_cb_rows;

    DROP TEMPORARY TABLE IF EXISTS tmp_cb_ordered;



    CREATE TEMPORARY TABLE tmp_cb_opening

    (

        AccountCode VARCHAR(50) NOT NULL,

        AccountName VARCHAR(191) NOT NULL,

        OpeningBalance DECIMAL(20,2) NOT NULL DEFAULT 0,

        PRIMARY KEY(AccountCode)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /* Opening balances: same source as the 3-tab TB opening sheet. */

    INSERT INTO tmp_cb_opening(AccountCode, AccountName, OpeningBalance)

    SELECT

        x.AccountCode,

        MAX(x.AccountName) AS AccountName,

        SUM(x.balance) AS OpeningBalance

    FROM

    (

        SELECT

            CONVERT(sa.AccountCode USING utf8) AS AccountCode,

            LEFT(CONVERT(sa.AccountName USING utf8),191) AS AccountName,

            CASE

                WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                ELSE 0

            END AS balance

        FROM fin_ledger f

        INNER JOIN fin_subaccounts sa

            ON CONVERT(sa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)

        WHERE

        (

            f.transactionDate < p_start_date

            OR

            (

                f.transactionDate >= p_start_date

                AND f.transactionDate < DATE_ADD(p_start_date, INTERVAL 1 DAY)

                AND

                (

                    UPPER(IFNULL(f.particulars,'')) LIKE '%OPENING BALANCE%'

                    OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OB-%'

                    OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OPENING%'

                    OR UPPER(IFNULL(f.source_system,'')) LIKE '%OPENING%'

                    OR UPPER(IFNULL(f.teller,'')) LIKE '%OPENING%'

                )

            )

        )

        AND NOT

        (

            UPPER(IFNULL(f.source_system,'')) IN

            (

                'RSL_GL_SIDE',

                'RESTORED_STUDENT_LEDGER',

                'RESTORED_GL_SIDE',

                'RESTORED_STUDENT_LEDGER_GL_SIDE'

            )

            OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

            OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

        )

    ) x

    WHERE x.AccountCode IN ('AC1301','AC1302','AC1303','AC1304','AC1305','AC1308','AC1321')

    GROUP BY x.AccountCode

    HAVING ROUND(SUM(x.balance),2) <> 0;



    CREATE TEMPORARY TABLE tmp_cb_txns_raw

    (

        TID INT NOT NULL,

        ReportAccountCode VARCHAR(50) NOT NULL,

        AccountName VARCHAR(191) NOT NULL,

        transactionDate DATE NOT NULL,

        voucherNo VARCHAR(50),

        journal_no VARCHAR(80),

        particulars VARCHAR(350),

        teller VARCHAR(80),

        transactionType VARCHAR(5),

        amount DECIMAL(20,2) NOT NULL DEFAULT 0,

        source_bucket VARCHAR(20) NOT NULL,

        signed_amount DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_report_account(ReportAccountCode),

        KEY idx_order(ReportAccountCode, transactionDate, TID)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /* Direct COA rows, normalized using the same special mappings as the 3-tab TB export. */

    INSERT INTO tmp_cb_txns_raw

    SELECT

        f.TID,

        CASE

            WHEN UPPER(IFNULL(f.source_system,'')) = 'CB_COLLECTIONS'

                 AND CONVERT(f.accountcode USING utf8) = 'AC2130'

                 AND UPPER(CONCAT(IFNULL(f.particulars,''),' ',IFNULL(sa.AccountName,''))) LIKE '%LOANS STANDING ORDER%'

                THEN 'AC1321'

            ELSE CONVERT(f.accountcode USING utf8)

        END AS ReportAccountCode,

        LEFT(COALESCE(target_sa.AccountName, sa.AccountName),191) AS AccountName,

        f.transactionDate,

        CAST(f.voucherNo AS CHAR) AS voucherNo,

        f.journal_no,

        f.particulars,

        f.teller,

        UPPER(TRIM(f.transactionType)) AS transactionType,

        COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) AS amount,

        CASE

            WHEN UPPER(IFNULL(f.source_system,'')) = 'SB_COLLECTIONS' THEN 'SB'

            WHEN UPPER(IFNULL(f.source_system,'')) = 'CB_COLLECTIONS' THEN 'CB'

            WHEN UPPER(IFNULL(f.source_system,'')) = 'LOAN' THEN 'LOAN'

            WHEN UPPER(IFNULL(f.source_system,'')) = 'DFCU' THEN 'DFCU'

            WHEN UPPER(IFNULL(f.source_system,'')) = 'CB_OPERATIONS' THEN 'CBOP'

            WHEN UPPER(IFNULL(f.source_system,'')) IN ('PC_MASAKA','PC-MASAKA') THEN 'PCMASAKA'

            WHEN UPPER(IFNULL(f.source_system,'')) IN ('PC_KAMPALA','PC-KAMPALA') THEN 'PCKAMPALA'

            WHEN UPPER(IFNULL(f.source_system,'')) = 'JOURNAL_VOUCHERS' THEN 'JOURNAL'

            ELSE 'JOURNAL'

        END AS source_bucket,

        CASE

            WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            ELSE 0

        END AS signed_amount

    FROM fin_ledger f

    INNER JOIN fin_subaccounts sa

        ON CONVERT(sa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)

    LEFT JOIN fin_subaccounts target_sa

        ON target_sa.AccountCode =

            CASE

                WHEN UPPER(IFNULL(f.source_system,'')) = 'CB_COLLECTIONS'

                     AND CONVERT(f.accountcode USING utf8) = 'AC2130'

                     AND UPPER(CONCAT(IFNULL(f.particulars,''),' ',IFNULL(sa.AccountName,''))) LIKE '%LOANS STANDING ORDER%'

                    THEN 'AC1321'

                ELSE CONVERT(f.accountcode USING utf8)

            END

    WHERE

    (

        (

            f.transactionDate >= p_start_date

            AND f.transactionDate < DATE_ADD(p_end_date, INTERVAL 1 DAY)

        )

        OR

        (

            UPPER(IFNULL(f.source_system,'')) = 'PC_KAMPALA'

            AND CAST(f.voucherNo AS CHAR) = DATE_FORMAT(p_end_date, '%Y%m%d')

            AND f.transactionDate >= DATE_ADD(p_end_date, INTERVAL 1 DAY)

            AND CONVERT(f.accountcode USING utf8) <> 'AC1304'

        )

    )

    AND NOT

    (

        UPPER(IFNULL(f.source_system,'')) IN

        (

            'RSL_GL_SIDE',

            'RESTORED_STUDENT_LEDGER',

            'RESTORED_GL_SIDE',

            'RESTORED_STUDENT_LEDGER_GL_SIDE'

        )

        OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

        OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

    )

    AND NOT

    (

        f.transactionDate >= p_start_date

        AND f.transactionDate < DATE_ADD(p_start_date, INTERVAL 1 DAY)

        AND

        (

            UPPER(IFNULL(f.particulars,'')) LIKE '%OPENING BALANCE%'

            OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OB-%'

            OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OPENING%'

            OR UPPER(IFNULL(f.source_system,'')) LIKE '%OPENING%'

            OR UPPER(IFNULL(f.teller,'')) LIKE '%OPENING%'

        )

    );



    CREATE TEMPORARY TABLE tmp_cb_rows

    (

        SortDate DATE NOT NULL,

        SortTid INT NOT NULL,

        AccountCode VARCHAR(50) NOT NULL,

        AccountName VARCHAR(191) NOT NULL,

        `Date` DATE NOT NULL,

        `Voucher No` VARCHAR(50),

        `Journal No` VARCHAR(80),

        `Cash / Bank Account` VARCHAR(191),

        `Particulars` VARCHAR(350),

        `Receipts` DECIMAL(20,2) NOT NULL DEFAULT 0,

        `Payments` DECIMAL(20,2) NOT NULL DEFAULT 0,

        SignedAmount DECIMAL(20,2) NOT NULL DEFAULT 0,

        `Entered By` VARCHAR(80),

        KEY idx_order(AccountCode, SortDate, SortTid)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /* Opening rows included so Cashbook final balance equals TB closing balance. */

    INSERT INTO tmp_cb_rows

    SELECT

        p_start_date AS SortDate,

        -1 AS SortTid,

        o.AccountCode,

        o.AccountName,

        p_start_date AS `Date`,

        'OPENING' AS `Voucher No`,

        'OPENING' AS `Journal No`,

        o.AccountName AS `Cash / Bank Account`,

        CONCAT('Opening balance as at ', DATE_FORMAT(DATE_SUB(p_start_date, INTERVAL 1 DAY), '%d/%m/%Y')) AS `Particulars`,

        IF(o.OpeningBalance > 0, o.OpeningBalance, 0) AS `Receipts`,

        IF(o.OpeningBalance < 0, ABS(o.OpeningBalance), 0) AS `Payments`,

        o.OpeningBalance AS SignedAmount,

        'migration' AS `Entered By`

    FROM tmp_cb_opening o;



    /* Only movements that the Trial Balance allocates to each bank/cash account. */

    INSERT INTO tmp_cb_rows

    SELECT

        r.transactionDate AS SortDate,

        r.TID AS SortTid,

        r.ReportAccountCode AS AccountCode,

        r.AccountName,

        r.transactionDate AS `Date`,

        r.voucherNo AS `Voucher No`,

        r.journal_no AS `Journal No`,

        r.AccountName AS `Cash / Bank Account`,

        r.particulars AS `Particulars`,

        IF(r.transactionType = 'DR', r.amount, 0) AS `Receipts`,

        IF(r.transactionType = 'CR', r.amount, 0) AS `Payments`,

        r.signed_amount AS SignedAmount,

        r.teller AS `Entered By`

    FROM tmp_cb_txns_raw r

    WHERE

        (r.ReportAccountCode = 'AC1301' AND r.source_bucket = 'CBOP')

        OR (r.ReportAccountCode = 'AC1302' AND r.source_bucket = 'SB')

        OR (r.ReportAccountCode = 'AC1303' AND r.source_bucket = 'CB')

        OR (r.ReportAccountCode = 'AC1304' AND r.source_bucket IN ('CBOP','PCKAMPALA'))

        OR (r.ReportAccountCode = 'AC1305' AND r.source_bucket IN ('CBOP','PCMASAKA'))

        OR (r.ReportAccountCode = 'AC1308' AND r.source_bucket = 'DFCU')

        OR (r.ReportAccountCode = 'AC1321' AND ((r.source_bucket = 'CB' AND r.transactionType = 'DR') OR (r.source_bucket = 'LOAN' AND r.transactionType = 'CR')));



    CREATE TEMPORARY TABLE tmp_cb_ordered

    SELECT

        @bal := IF(@acct = r.AccountCode, @bal + r.SignedAmount, r.SignedAmount) AS RunningBalance,

        @acct := r.AccountCode AS VarAccount,

        r.*

    FROM

    (

        SELECT * FROM tmp_cb_rows

        ORDER BY AccountCode, SortDate, SortTid

    ) r

    CROSS JOIN (SELECT @acct := '', @bal := 0) vars;



    SELECT

        `Date`,

        `Voucher No`,

        `Journal No`,

        `Cash / Bank Account`,

        `Particulars`,

        `Receipts`,

        `Payments`,

        CASE

            WHEN ROUND(RunningBalance,2) = 0 THEN '0CR'

            WHEN RunningBalance > 0 THEN CONCAT(FORMAT(RunningBalance,0),'DR')

            ELSE CONCAT(FORMAT(ABS(RunningBalance),0),'CR')

        END AS `Balance`,

        `Entered By`

    FROM tmp_cb_ordered

    ORDER BY AccountCode, SortDate, SortTid;



    DROP TEMPORARY TABLE IF EXISTS tmp_cb_opening;

    DROP TEMPORARY TABLE IF EXISTS tmp_cb_txns_raw;

    DROP TEMPORARY TABLE IF EXISTS tmp_cb_rows;

    DROP TEMPORARY TABLE IF EXISTS tmp_cb_ordered;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_CashFlow` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_CashFlow`(IN sDate DATE, IN eDate DATE)
BEGIN

    DECLARE vOpening DECIMAL(20,2) DEFAULT 0;

    DECLARE vClosing DECIMAL(20,2) DEFAULT 0;

    DECLARE vOperating DECIMAL(20,2) DEFAULT 0;

    DECLARE vInvesting DECIMAL(20,2) DEFAULT 0;

    DECLARE vFinancing DECIMAL(20,2) DEFAULT 0;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_cash_accounts;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_cash_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_cashflow_output;



    CREATE TEMPORARY TABLE tmp_mru_cash_accounts

    (

        AccountCode VARCHAR(45) NOT NULL,

        PRIMARY KEY(AccountCode)

    ) ENGINE=MEMORY;



    CREATE TEMPORARY TABLE tmp_mru_cash_movements

    (

        Section VARCHAR(80),

        Amount DECIMAL(20,2) NOT NULL DEFAULT 0

    ) ENGINE=MEMORY;



    CREATE TEMPORARY TABLE tmp_mru_cashflow_output

    (

        row_no INT NOT NULL AUTO_INCREMENT,

        Section VARCHAR(80),

        Description VARCHAR(160),

        Amount DECIMAL(20,2),

        PRIMARY KEY(row_no)

    ) ENGINE=MEMORY;



    INSERT IGNORE INTO tmp_mru_cash_accounts(AccountCode)

    SELECT sa.AccountCode

    FROM fin_subaccounts sa

    INNER JOIN fin_mainaccounts ma ON ma.AccountCode = sa.MainAccountCode

    WHERE ma.GeneralCategory = 'Assets'

      AND (

            UPPER(ma.AccountName) LIKE '%CASH%'

            OR UPPER(ma.AccountName) LIKE '%BANK%'

            OR UPPER(ma.SubCategory) LIKE '%CASH%'

            OR UPPER(ma.SubCategory) LIKE '%BANK%'

            OR UPPER(sa.AccountName) LIKE '%CASH%'

            OR UPPER(sa.AccountName) LIKE '%BANK%'

          );



    SELECT COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN -l.transaction_amount ELSE 0 END),0)

      INTO vOpening

    FROM fin_ledger l

    INNER JOIN tmp_mru_cash_accounts ca ON ca.AccountCode = l.accountcode

    WHERE l.transactionDate < sDate;



    SELECT COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN -l.transaction_amount ELSE 0 END),0)

      INTO vClosing

    FROM fin_ledger l

    INNER JOIN tmp_mru_cash_accounts ca ON ca.AccountCode = l.accountcode

    WHERE l.transactionDate <= eDate;



    INSERT INTO tmp_mru_cash_movements(Section, Amount)

    SELECT

        CASE

            WHEN EXISTS (

                SELECT 1

                FROM fin_ledger c

                INNER JOIN fin_subaccounts csa ON csa.AccountCode = c.accountcode

                INNER JOIN fin_mainaccounts cma ON cma.AccountCode = csa.MainAccountCode

                WHERE c.voucherNo = l.voucherNo

                  AND c.transactionDate = l.transactionDate

                  AND NOT (

                        UPPER(cma.AccountName) LIKE '%CASH%'

                        OR UPPER(cma.AccountName) LIKE '%BANK%'

                        OR UPPER(cma.SubCategory) LIKE '%CASH%'

                        OR UPPER(cma.SubCategory) LIKE '%BANK%'

                        OR UPPER(csa.AccountName) LIKE '%CASH%'

                        OR UPPER(csa.AccountName) LIKE '%BANK%'

                      )

                  AND cma.GeneralCategory = 'Assets'

                  AND UPPER(cma.SubCategory) NOT LIKE '%RECEIVABLE%'

                  AND UPPER(cma.SubCategory) NOT LIKE '%CASH%'

                  AND UPPER(cma.SubCategory) NOT LIKE '%BANK%'

            ) THEN 'Investing Activities'

            WHEN EXISTS (

                SELECT 1

                FROM fin_ledger c

                INNER JOIN fin_subaccounts csa ON csa.AccountCode = c.accountcode

                INNER JOIN fin_mainaccounts cma ON cma.AccountCode = csa.MainAccountCode

                WHERE c.voucherNo = l.voucherNo

                  AND c.transactionDate = l.transactionDate

                  AND NOT (

                        UPPER(cma.AccountName) LIKE '%CASH%'

                        OR UPPER(cma.AccountName) LIKE '%BANK%'

                        OR UPPER(cma.SubCategory) LIKE '%CASH%'

                        OR UPPER(cma.SubCategory) LIKE '%BANK%'

                        OR UPPER(csa.AccountName) LIKE '%CASH%'

                        OR UPPER(csa.AccountName) LIKE '%BANK%'

                      )

                  AND (cma.GeneralCategory = 'Equity'

                       OR UPPER(cma.SubCategory) LIKE '%LOAN%'

                       OR UPPER(cma.SubCategory) LIKE '%BORROW%'

                       OR UPPER(csa.AccountName) LIKE '%LOAN%'

                       OR UPPER(csa.AccountName) LIKE '%BORROW%'

                       OR UPPER(csa.AccountName) LIKE '%SHARE CAPITAL%')

            ) THEN 'Financing Activities'

            ELSE 'Operating Activities'

        END AS Section,

        CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN -l.transaction_amount ELSE 0 END AS Amount

    FROM fin_ledger l

    INNER JOIN tmp_mru_cash_accounts ca ON ca.AccountCode = l.accountcode

    WHERE l.transactionDate BETWEEN sDate AND eDate;



    SELECT COALESCE(SUM(Amount),0) INTO vOperating FROM tmp_mru_cash_movements WHERE Section = 'Operating Activities';

    SELECT COALESCE(SUM(Amount),0) INTO vInvesting FROM tmp_mru_cash_movements WHERE Section = 'Investing Activities';

    SELECT COALESCE(SUM(Amount),0) INTO vFinancing FROM tmp_mru_cash_movements WHERE Section = 'Financing Activities';



    INSERT INTO tmp_mru_cashflow_output(Section, Description, Amount)

    VALUES('Opening', 'Opening cash and bank balance', vOpening),

          ('Operating Activities', 'Net cash from operating activities', vOperating),

          ('Investing Activities', 'Net cash from investing activities', vInvesting),

          ('Financing Activities', 'Net cash from financing activities', vFinancing),

          ('Net Movement', 'Net increase / decrease in cash and bank', vOperating + vInvesting + vFinancing),

          ('Closing', 'Closing cash and bank balance', vClosing);



    SELECT Section, Description, Amount

    FROM tmp_mru_cashflow_output

    ORDER BY row_no;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_cash_accounts;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_cash_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_cashflow_output;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_FundChanges` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_FundChanges`(

    IN p_start_date DATE,

    IN p_end_date DATE

)
BEGIN

    DECLARE v_retained_earnings DECIMAL(20,2) DEFAULT 0;

    DECLARE v_surplus_deficit DECIMAL(20,2) DEFAULT 0;

    DECLARE v_revaluation_reserve DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_reserves DECIMAL(20,2) DEFAULT 0;

    DECLARE v_capital_fund DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_equity DECIMAL(20,2) DEFAULT 0;

    DECLARE v_opening_adjustment DECIMAL(20,2) DEFAULT 0;

    DECLARE v_capital_and_reserves DECIMAL(20,2) DEFAULT 0;

    DECLARE v_closing_equity DECIMAL(20,2) DEFAULT 0;

    DECLARE v_ppe DECIMAL(20,2) DEFAULT 0;

    DECLARE v_intangible DECIMAL(20,2) DEFAULT 0;

    DECLARE v_deferred_tax_asset DECIMAL(20,2) DEFAULT 0;

    DECLARE v_deferred_tax_liability DECIMAL(20,2) DEFAULT 0;

    DECLARE v_prepaid_noncurrent DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_noncurrent_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_noncurrent_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_cash_bank DECIMAL(20,2) DEFAULT 0;

    DECLARE v_bank_overdrafts DECIMAL(20,2) DEFAULT 0;

    DECLARE v_student_receivables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_student_credit_balances DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_receivables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_liability_debit_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_asset_credit_balances DECIMAL(20,2) DEFAULT 0;

    DECLARE v_prepayments DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_current_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_equity DECIMAL(20,2) DEFAULT 0;

    DECLARE v_staff_gratuity DECIMAL(20,2) DEFAULT 0;

    DECLARE v_longterm_borrowings DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_noncurrent_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_noncurrent_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_trade_payables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_statutory_payables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_salary_payroll DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_current_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_current_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_liabilities DECIMAL(20,2) DEFAULT 0;



    /* Build TB-source balances inside this procedure. No helper procedure is created. */

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_subaccounts;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_balances;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_subaccounts

    (

        AccountCode VARCHAR(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        accounttype VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        collectionLedgerType VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        PRIMARY KEY(AccountCode),

        KEY idx_collectionLedgerType(collectionLedgerType)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_report_tb_subaccounts

    SELECT

        CONVERT(s.AccountCode USING utf8),

        LEFT(CONVERT(s.AccountName USING utf8), 191),

        CONVERT(s.accounttype USING utf8),

        CONVERT(s.collectionLedgerType USING utf8),

        CONVERT(fin_GetTrialBalanceGroup(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountCategory(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountSubCategory(s.AccountCode) USING utf8)

    FROM fin_subaccounts s;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_movements

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /* Same direct COA logic as fin_TrialBalance. */

    INSERT INTO tmp_mru_report_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'DR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS DRTotal,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'CR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS CRTotal,

        COALESCE(SUM(CASE

            WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            ELSE 0 END), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_report_tb_subaccounts s

        ON s.AccountCode = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= p_start_date

      AND f.transactionDate < DATE_ADD(p_end_date, INTERVAL 1 DAY)

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY s.MAC, s.category, s.subcategory, s.AccountCode, s.AccountName;



    /* Same subledger-control logic as fin_TrialBalance. */

    INSERT INTO tmp_mru_report_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'DR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS DRTotal,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'CR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS CRTotal,

        COALESCE(SUM(CASE

            WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            ELSE 0 END), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_report_tb_subaccounts s

        ON s.collectionLedgerType = CONVERT(f.account_type USING utf8)

    LEFT JOIN fin_subaccounts directcoa

        ON CONVERT(directcoa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= p_start_date

      AND f.transactionDate < DATE_ADD(p_end_date, INTERVAL 1 DAY)

      AND directcoa.AccountCode IS NULL

      AND IFNULL(s.collectionLedgerType,'') <> ''

      AND IFNULL(s.accounttype,'') <> 'Basic Account'

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY s.MAC, s.category, s.subcategory, s.AccountCode, s.AccountName;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_balances

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode),

        KEY idx_category(category)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_report_tb_balances

    SELECT

        MAC,

        category,

        subcategory,

        AccountCode,

        AccountName,

        SUM(DRTotal) AS DRTotal,

        SUM(CRTotal) AS CRTotal,

        SUM(balance) AS balance

    FROM tmp_mru_report_tb_movements

    GROUP BY MAC, category, subcategory, AccountCode, AccountName

    HAVING ROUND(SUM(balance), 2) <> 0

        OR ROUND(SUM(DRTotal), 2) <> 0

        OR ROUND(SUM(CRTotal), 2) <> 0;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_subaccounts;



    /* Use the same SFP classification to calculate the dynamic adjustment for Fund Changes. */

    SELECT COALESCE(SUM(b.balance),0) INTO v_ppe

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'PPE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(b.balance),0) INTO v_intangible

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'INTANGIBLE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_deferred_tax_asset

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'DEFERRED_TAX' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_deferred_tax_liability

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'DEFERRED_TAX' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_prepaid_noncurrent

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'PREPAID_OPERATING_LEASE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_cash_bank

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CASH_BANK' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_bank_overdrafts

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CASH_BANK' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_student_receivables

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STUDENT_RECEIVABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_student_credit_balances

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STUDENT_RECEIVABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_prepayments

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'PREPAYMENTS' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)))

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m2 WHERE m2.IsActive = 1 AND m2.LineCode = 'PREPAID_OPERATING_LEASE' AND ((m2.AccountScope='MAIN' AND m2.AccountCode=b.MAC) OR (m2.AccountScope='SUB' AND m2.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_other_noncurrent_assets

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Assets'

      AND (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%NON%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('PPE','INTANGIBLE','DEFERRED_TAX','PREPAID_OPERATING_LEASE','PREPAYMENTS','CASH_BANK','STUDENT_RECEIVABLES') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_other_receivables

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Assets'

      AND NOT (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%NON%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('PPE','INTANGIBLE','DEFERRED_TAX','PREPAID_OPERATING_LEASE','PREPAYMENTS','CASH_BANK','STUDENT_RECEIVABLES') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    /* Debit balances sitting in liability accounts are assets/receivables in TB terms. */

    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_liability_debit_assets

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Liabilities';



    SET v_other_receivables = v_other_receivables + v_liability_debit_assets;



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_asset_credit_balances

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Assets'

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('CASH_BANK','STUDENT_RECEIVABLES') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SET v_total_noncurrent_assets = v_ppe + v_intangible + v_deferred_tax_asset + v_prepaid_noncurrent + v_other_noncurrent_assets;

    SET v_total_current_assets = v_cash_bank + v_student_receivables + v_other_receivables + v_prepayments;

    SET v_total_assets = v_total_noncurrent_assets + v_total_current_assets;



    SELECT COALESCE(SUM(-b.balance),0) INTO v_retained_earnings

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'RETAINED_EARNINGS' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_revaluation_reserve

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'REVALUATION_RESERVE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_other_reserves

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'OTHER_RESERVES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_capital_fund

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CAPITAL_FUND' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_other_equity

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Equity'

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('RETAINED_EARNINGS','REVALUATION_RESERVE','OTHER_RESERVES','CAPITAL_FUND') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT -COALESCE(SUM(b.balance),0) INTO v_surplus_deficit

    FROM tmp_mru_report_tb_balances b

    WHERE b.category IN ('Income','Expense','Expenses');



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_longterm_borrowings

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'LONG_TERM_BORROWINGS' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_staff_gratuity

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STAFF_GRATUITY' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_trade_payables

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'TRADE_PAYABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_statutory_payables

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STATUTORY_PAYABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_salary_payroll

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'SALARY_PAYROLL' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_other_noncurrent_liabilities

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Liabilities'

      AND (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%LONG%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('LONG_TERM_BORROWINGS','STAFF_GRATUITY','TRADE_PAYABLES','STATUTORY_PAYABLES','SALARY_PAYROLL') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SET v_other_noncurrent_liabilities = v_other_noncurrent_liabilities + v_deferred_tax_liability;



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_other_current_liabilities

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Liabilities'

      AND NOT (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%LONG%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('LONG_TERM_BORROWINGS','STAFF_GRATUITY','TRADE_PAYABLES','STATUTORY_PAYABLES','SALARY_PAYROLL') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SET v_total_noncurrent_liabilities = v_staff_gratuity + v_longterm_borrowings + v_other_noncurrent_liabilities;

    SET v_total_current_liabilities = v_trade_payables + v_statutory_payables + v_salary_payroll + v_bank_overdrafts + v_student_credit_balances + v_asset_credit_balances + v_other_current_liabilities;

    SET v_total_liabilities = v_total_noncurrent_liabilities + v_total_current_liabilities;



    /* No plug: SFP is balanced by TB debit/credit classification. */

    SET v_opening_adjustment = 0;



    SET v_total_equity = v_retained_earnings + v_surplus_deficit + v_revaluation_reserve + v_other_reserves + v_capital_fund + v_other_equity + v_opening_adjustment;



    SELECT COALESCE(SUM(-b.balance),0) INTO v_retained_earnings

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'RETAINED_EARNINGS' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT -COALESCE(SUM(b.balance),0) INTO v_surplus_deficit

    FROM tmp_mru_report_tb_balances b

    WHERE b.category IN ('Income','Expense','Expenses');



    SELECT COALESCE(SUM(-b.balance),0) INTO v_revaluation_reserve

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'REVALUATION_RESERVE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_other_reserves

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'OTHER_RESERVES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_capital_fund

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CAPITAL_FUND' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_other_equity

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Equity'

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('RETAINED_EARNINGS','REVALUATION_RESERVE','OTHER_RESERVES','CAPITAL_FUND') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SET v_capital_and_reserves = v_revaluation_reserve + v_other_reserves + v_capital_fund + v_other_equity;

    SET v_closing_equity = v_retained_earnings + v_surplus_deficit + v_capital_and_reserves + v_opening_adjustment;



    SELECT 'Accumulated Fund' AS Section,

           'Accumulated fund / retained earnings' AS Description,

           v_retained_earnings AS Amount

    UNION ALL

    SELECT 'Current Result',

           'Surplus / deficit for the period',

           v_surplus_deficit

    UNION ALL

    SELECT 'Capital and Reserves',

           'Share capital, revaluation reserve and other reserves',

           v_capital_and_reserves

    UNION ALL

    SELECT 'Opening Balance Adjustment',

           'Opening balance reconciliation adjustment',

           v_opening_adjustment

    UNION ALL

    SELECT 'Closing Fund / Equity',

           'Closing fund / equity balance',

           v_closing_equity;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_balances;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_GeneralLedgerSummary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_GeneralLedgerSummary`(IN sDate DATE, IN eDate DATE)
BEGIN

    SELECT

        q.`Date`, q.`Voucher No`, q.`Journal No`, q.`Category`, q.`Sub Category`,

        q.`Account Code`, q.`Account Name`, q.`Particulars`, q.`Debit`, q.`Credit`, q.`Balance`

    FROM

    (

        SELECT

            l.transactionDate AS `Date`,

            l.voucherNo AS `Voucher No`,

            l.journal_no AS `Journal No`,

            ma.GeneralCategory AS `Category`,

            ma.SubCategory AS `Sub Category`,

            sa.AccountCode AS `Account Code`,

            sa.AccountName AS `Account Name`,

            l.particulars AS `Particulars`,

            CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount ELSE 0 END AS `Debit`,

            CASE WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN l.transaction_amount ELSE 0 END AS `Credit`,

            l.curr_balance AS `Balance`,

            l.TID AS SortID

        FROM fin_ledger l

        INNER JOIN fin_subaccounts sa ON sa.AccountCode = l.accountcode

        INNER JOIN fin_mainaccounts ma ON ma.AccountCode = sa.MainAccountCode

        WHERE l.transactionDate BETWEEN sDate AND eDate



        UNION ALL



        SELECT

            l.transactionDate AS `Date`,

            l.voucherNo AS `Voucher No`,

            l.journal_no AS `Journal No`,

            ma.GeneralCategory AS `Category`,

            ma.SubCategory AS `Sub Category`,

            sa.AccountCode AS `Account Code`,

            sa.AccountName AS `Account Name`,

            l.particulars AS `Particulars`,

            CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount ELSE 0 END AS `Debit`,

            CASE WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN l.transaction_amount ELSE 0 END AS `Credit`,

            l.curr_balance AS `Balance`,

            l.TID AS SortID

        FROM fin_ledger l

        INNER JOIN fin_subaccounts sa ON sa.collectionLedgerType = l.account_type

        INNER JOIN fin_mainaccounts ma ON ma.AccountCode = sa.MainAccountCode

        LEFT JOIN fin_subaccounts directcoa ON directcoa.AccountCode = l.accountcode

        WHERE l.transactionDate BETWEEN sDate AND eDate

          AND directcoa.AccountCode IS NULL

          AND IFNULL(sa.collectionLedgerType,'') NOT IN ('','-','Chart Account')

    ) q

    ORDER BY q.`Date`, q.SortID;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_Payables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_Payables`(IN sDate DATE, IN eDate DATE)
BEGIN

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_payables;



    CREATE TEMPORARY TABLE tmp_mru_payables

    (

        PayableCategory VARCHAR(120),

        AccountCode VARCHAR(100),

        AccountName VARCHAR(191),

        Credit DECIMAL(20,2) NOT NULL DEFAULT 0,

        Debit DECIMAL(20,2) NOT NULL DEFAULT 0,

        Balance DECIMAL(20,2) NOT NULL DEFAULT 0

    ) ENGINE=MEMORY;



    INSERT INTO tmp_mru_payables

    SELECT

        ma.SubCategory,

        sa.AccountCode,

        sa.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN l.transaction_amount ELSE 0 END), 0),

        COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount ELSE 0 END), 0),

        COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN l.transaction_amount WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN -l.transaction_amount ELSE 0 END), 0)

    FROM fin_ledger l

    INNER JOIN fin_subaccounts sa ON sa.AccountCode = l.accountcode

    INNER JOIN fin_mainaccounts ma ON ma.AccountCode = sa.MainAccountCode

    WHERE l.transactionDate <= eDate

      AND ma.GeneralCategory = 'Liabilities'

    GROUP BY ma.SubCategory, sa.AccountCode, sa.AccountName;



    INSERT INTO tmp_mru_payables

    SELECT

        ma.SubCategory,

        sa.AccountCode,

        sa.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN l.transaction_amount ELSE 0 END), 0),

        COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount ELSE 0 END), 0),

        COALESCE(SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN l.transaction_amount WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN -l.transaction_amount ELSE 0 END), 0)

    FROM fin_ledger l

    INNER JOIN fin_subaccounts sa ON sa.collectionLedgerType = l.account_type

    INNER JOIN fin_mainaccounts ma ON ma.AccountCode = sa.MainAccountCode

    LEFT JOIN fin_subaccounts directcoa ON directcoa.AccountCode = l.accountcode

    WHERE l.transactionDate <= eDate

      AND ma.GeneralCategory = 'Liabilities'

      AND directcoa.AccountCode IS NULL

      AND IFNULL(sa.collectionLedgerType,'') NOT IN ('','-','Chart Account')

    GROUP BY ma.SubCategory, sa.AccountCode, sa.AccountName;



    SELECT

        PayableCategory AS `Payable Category`,

        AccountCode AS `Account Code`,

        AccountName AS `Account Name`,

        SUM(Credit) AS `Credit`,

        SUM(Debit) AS `Debit`,

        SUM(Balance) AS `Outstanding Payable`

    FROM tmp_mru_payables

    GROUP BY PayableCategory, AccountCode, AccountName

    HAVING ROUND(SUM(Balance),2) <> 0

    ORDER BY PayableCategory, AccountName;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_payables;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_Payments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_Payments`(IN sDate DATE, IN eDate DATE)
BEGIN

    SELECT

        l.transactionDate AS `Date`,

        l.voucherNo AS `Voucher No`,

        l.journal_no AS `Journal No`,

        sa.AccountName AS `Paid From`,

        l.particulars AS `Particulars`,

        l.transaction_amount AS `Amount Paid`,

        l.teller AS `Entered By`

    FROM fin_ledger l

    INNER JOIN fin_subaccounts sa ON sa.AccountCode = l.accountcode

    INNER JOIN fin_mainaccounts ma ON ma.AccountCode = sa.MainAccountCode

    WHERE l.transactionDate BETWEEN sDate AND eDate

      AND UPPER(TRIM(l.transactionType)) = 'CR'

      AND ma.GeneralCategory = 'Assets'

      AND (UPPER(ma.AccountName) LIKE '%CASH%' OR UPPER(ma.AccountName) LIKE '%BANK%' OR UPPER(ma.SubCategory) LIKE '%CASH%' OR UPPER(ma.SubCategory) LIKE '%BANK%' OR UPPER(sa.AccountName) LIKE '%CASH%' OR UPPER(sa.AccountName) LIKE '%BANK%')

    ORDER BY l.transactionDate, l.TID;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_ReceivablesDefaulters` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_ReceivablesDefaulters`(IN sDate DATE, IN eDate DATE)
BEGIN

    SELECT

        l.accountcode AS `Student / Account No`,

        TRIM(CONCAT(COALESCE(MAX(st.firstname), ''), ' ', COALESCE(MAX(st.othername), ''))) AS `Student Name`,

        MAX(COALESCE(st.progid, '-')) AS `Programme`,

        MAX(l.account_type) AS `Account Type`,

        SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount ELSE 0 END) AS `Billed / Debit`,

        SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN l.transaction_amount ELSE 0 END) AS `Paid / Credit`,

        SUM(CASE WHEN UPPER(TRIM(l.transactionType)) = 'DR' THEN l.transaction_amount WHEN UPPER(TRIM(l.transactionType)) = 'CR' THEN -l.transaction_amount ELSE 0 END) AS `Outstanding Balance`

    FROM fin_ledger l

    LEFT JOIN campus_dynamics.acad_student st ON st.regno = l.accountcode OR st.entryno = l.accountcode

    WHERE l.transactionDate <= eDate

      AND (

            l.account_type IN (

                SELECT DISTINCT sa.collectionLedgerType

                FROM fin_subaccounts sa

                INNER JOIN fin_mainaccounts ma ON ma.AccountCode = sa.MainAccountCode

                WHERE ma.GeneralCategory = 'Assets'

                  AND UPPER(ma.SubCategory) LIKE '%RECEIVABLE%'

                  AND IFNULL(sa.collectionLedgerType,'') NOT IN ('','-','Chart Account')

            )

            OR l.account_type = 'Student'

            OR l.account_type LIKE '%Fees%'

            OR l.accountcode LIKE 'MRU%'

          )

    GROUP BY l.accountcode

    HAVING `Outstanding Balance` > 0

    ORDER BY `Outstanding Balance` DESC, `Student / Account No`;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_DocumentCentre_StatementOfFinancialPosition` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_DocumentCentre_StatementOfFinancialPosition`(

    IN p_start_date DATE,

    IN p_end_date DATE

)
BEGIN

    DECLARE v_ppe DECIMAL(20,2) DEFAULT 0;

    DECLARE v_intangible DECIMAL(20,2) DEFAULT 0;

    DECLARE v_deferred_tax_asset DECIMAL(20,2) DEFAULT 0;

    DECLARE v_deferred_tax_liability DECIMAL(20,2) DEFAULT 0;

    DECLARE v_prepaid_noncurrent DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_noncurrent_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_noncurrent_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_cash_bank DECIMAL(20,2) DEFAULT 0;

    DECLARE v_bank_overdrafts DECIMAL(20,2) DEFAULT 0;

    DECLARE v_student_receivables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_student_credit_balances DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_receivables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_liability_debit_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_asset_credit_balances DECIMAL(20,2) DEFAULT 0;

    DECLARE v_prepayments DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_current_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_assets DECIMAL(20,2) DEFAULT 0;

    DECLARE v_retained_earnings DECIMAL(20,2) DEFAULT 0;

    DECLARE v_surplus_deficit DECIMAL(20,2) DEFAULT 0;

    DECLARE v_revaluation_reserve DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_reserves DECIMAL(20,2) DEFAULT 0;

    DECLARE v_capital_fund DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_equity DECIMAL(20,2) DEFAULT 0;

    DECLARE v_opening_adjustment DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_equity DECIMAL(20,2) DEFAULT 0;

    DECLARE v_staff_gratuity DECIMAL(20,2) DEFAULT 0;

    DECLARE v_longterm_borrowings DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_noncurrent_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_noncurrent_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_trade_payables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_statutory_payables DECIMAL(20,2) DEFAULT 0;

    DECLARE v_salary_payroll DECIMAL(20,2) DEFAULT 0;

    DECLARE v_other_current_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_current_liabilities DECIMAL(20,2) DEFAULT 0;

    DECLARE v_total_liabilities DECIMAL(20,2) DEFAULT 0;



    /* Build TB-source balances inside this procedure. No helper procedure is created. */

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_subaccounts;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_balances;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_subaccounts

    (

        AccountCode VARCHAR(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        accounttype VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        collectionLedgerType VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        PRIMARY KEY(AccountCode),

        KEY idx_collectionLedgerType(collectionLedgerType)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_report_tb_subaccounts

    SELECT

        CONVERT(s.AccountCode USING utf8),

        LEFT(CONVERT(s.AccountName USING utf8), 191),

        CONVERT(s.accounttype USING utf8),

        CONVERT(s.collectionLedgerType USING utf8),

        CONVERT(fin_GetTrialBalanceGroup(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountCategory(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountSubCategory(s.AccountCode) USING utf8)

    FROM fin_subaccounts s;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_movements

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /* Same direct COA logic as fin_TrialBalance. */

    INSERT INTO tmp_mru_report_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'DR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS DRTotal,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'CR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS CRTotal,

        COALESCE(SUM(CASE

            WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            ELSE 0 END), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_report_tb_subaccounts s

        ON s.AccountCode = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= p_start_date

      AND f.transactionDate < DATE_ADD(p_end_date, INTERVAL 1 DAY)

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY s.MAC, s.category, s.subcategory, s.AccountCode, s.AccountName;



    /* Same subledger-control logic as fin_TrialBalance. */

    INSERT INTO tmp_mru_report_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'DR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS DRTotal,

        COALESCE(SUM(CASE WHEN UPPER(TRIM(f.transactionType)) = 'CR'

            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) ELSE 0 END), 0) AS CRTotal,

        COALESCE(SUM(CASE

            WHEN UPPER(TRIM(f.transactionType)) = 'DR' THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            WHEN UPPER(TRIM(f.transactionType)) = 'CR' THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

            ELSE 0 END), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_report_tb_subaccounts s

        ON s.collectionLedgerType = CONVERT(f.account_type USING utf8)

    LEFT JOIN fin_subaccounts directcoa

        ON CONVERT(directcoa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= p_start_date

      AND f.transactionDate < DATE_ADD(p_end_date, INTERVAL 1 DAY)

      AND directcoa.AccountCode IS NULL

      AND IFNULL(s.collectionLedgerType,'') <> ''

      AND IFNULL(s.accounttype,'') <> 'Basic Account'

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY s.MAC, s.category, s.subcategory, s.AccountCode, s.AccountName;



    CREATE TEMPORARY TABLE tmp_mru_report_tb_balances

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode),

        KEY idx_category(category)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_report_tb_balances

    SELECT

        MAC,

        category,

        subcategory,

        AccountCode,

        AccountName,

        SUM(DRTotal) AS DRTotal,

        SUM(CRTotal) AS CRTotal,

        SUM(balance) AS balance

    FROM tmp_mru_report_tb_movements

    GROUP BY MAC, category, subcategory, AccountCode, AccountName

    HAVING ROUND(SUM(balance), 2) <> 0

        OR ROUND(SUM(DRTotal), 2) <> 0

        OR ROUND(SUM(CRTotal), 2) <> 0;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_subaccounts;



    DROP TEMPORARY TABLE IF EXISTS tmp_sfp_lines;

    CREATE TEMPORARY TABLE tmp_sfp_lines

    (

        RowNo INT NOT NULL AUTO_INCREMENT,

        SortNo INT NOT NULL,

        ReportTitle VARCHAR(80) NOT NULL,

        DateCaption VARCHAR(80) NOT NULL,

        SectionName VARCHAR(80) NOT NULL,

        LineDescription VARCHAR(160) NOT NULL,

        Amount DECIMAL(20,2) NULL,

        LineType VARCHAR(20) NOT NULL,

        PRIMARY KEY(RowNo)

    ) ENGINE=MEMORY;



    SELECT COALESCE(SUM(b.balance),0) INTO v_ppe

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'PPE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(b.balance),0) INTO v_intangible

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'INTANGIBLE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_deferred_tax_asset

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'DEFERRED_TAX' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_deferred_tax_liability

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'DEFERRED_TAX' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_prepaid_noncurrent

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'PREPAID_OPERATING_LEASE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_cash_bank

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CASH_BANK' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_bank_overdrafts

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CASH_BANK' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_student_receivables

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STUDENT_RECEIVABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_student_credit_balances

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STUDENT_RECEIVABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_prepayments

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'PREPAYMENTS' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)))

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m2 WHERE m2.IsActive = 1 AND m2.LineCode = 'PREPAID_OPERATING_LEASE' AND ((m2.AccountScope='MAIN' AND m2.AccountCode=b.MAC) OR (m2.AccountScope='SUB' AND m2.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_other_noncurrent_assets

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Assets'

      AND (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%NON%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('PPE','INTANGIBLE','DEFERRED_TAX','PREPAID_OPERATING_LEASE','PREPAYMENTS','CASH_BANK','STUDENT_RECEIVABLES') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_other_receivables

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Assets'

      AND NOT (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%NON%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('PPE','INTANGIBLE','DEFERRED_TAX','PREPAID_OPERATING_LEASE','PREPAYMENTS','CASH_BANK','STUDENT_RECEIVABLES') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    /* Debit balances sitting in liability accounts are assets/receivables in TB terms. */

    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0) INTO v_liability_debit_assets

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Liabilities';



    SET v_other_receivables = v_other_receivables + v_liability_debit_assets;



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_asset_credit_balances

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Assets'

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('CASH_BANK','STUDENT_RECEIVABLES') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SET v_total_noncurrent_assets = v_ppe + v_intangible + v_deferred_tax_asset + v_prepaid_noncurrent + v_other_noncurrent_assets;

    SET v_total_current_assets = v_cash_bank + v_student_receivables + v_other_receivables + v_prepayments;

    SET v_total_assets = v_total_noncurrent_assets + v_total_current_assets;



    SELECT COALESCE(SUM(-b.balance),0) INTO v_retained_earnings

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'RETAINED_EARNINGS' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_revaluation_reserve

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'REVALUATION_RESERVE' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_other_reserves

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'OTHER_RESERVES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_capital_fund

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CAPITAL_FUND' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(-b.balance),0) INTO v_other_equity

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Equity'

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('RETAINED_EARNINGS','REVALUATION_RESERVE','OTHER_RESERVES','CAPITAL_FUND') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT -COALESCE(SUM(b.balance),0) INTO v_surplus_deficit

    FROM tmp_mru_report_tb_balances b

    WHERE b.category IN ('Income','Expense','Expenses');



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_longterm_borrowings

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'LONG_TERM_BORROWINGS' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_staff_gratuity

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STAFF_GRATUITY' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_trade_payables

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'TRADE_PAYABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_statutory_payables

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'STATUTORY_PAYABLES' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_salary_payroll

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'SALARY_PAYROLL' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_other_noncurrent_liabilities

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Liabilities'

      AND (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%LONG%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('LONG_TERM_BORROWINGS','STAFF_GRATUITY','TRADE_PAYABLES','STATUTORY_PAYABLES','SALARY_PAYROLL') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SET v_other_noncurrent_liabilities = v_other_noncurrent_liabilities + v_deferred_tax_liability;



    SELECT COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0) INTO v_other_current_liabilities

    FROM tmp_mru_report_tb_balances b

    WHERE b.category = 'Liabilities'

      AND NOT (UPPER(COALESCE(b.subcategory,'')) LIKE '%NON%' OR UPPER(COALESCE(b.AccountName,'')) LIKE '%LONG%')

      AND NOT EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode IN ('LONG_TERM_BORROWINGS','STAFF_GRATUITY','TRADE_PAYABLES','STATUTORY_PAYABLES','SALARY_PAYROLL') AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SET v_total_noncurrent_liabilities = v_staff_gratuity + v_longterm_borrowings + v_other_noncurrent_liabilities;

    SET v_total_current_liabilities = v_trade_payables + v_statutory_payables + v_salary_payroll + v_bank_overdrafts + v_student_credit_balances + v_asset_credit_balances + v_other_current_liabilities;

    SET v_total_liabilities = v_total_noncurrent_liabilities + v_total_current_liabilities;



    /* No plug: SFP is balanced by TB debit/credit classification. */

    SET v_opening_adjustment = 0;



    SET v_total_equity = v_retained_earnings + v_surplus_deficit + v_revaluation_reserve + v_other_reserves + v_capital_fund + v_other_equity + v_opening_adjustment;



    INSERT INTO tmp_sfp_lines(SortNo, ReportTitle, DateCaption, SectionName, LineDescription, Amount, LineType) VALUES

    (10,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Non-Current Assets',NULL,'HEADER'),

    (20,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Property, plant and equipment',v_ppe,'LINE'),

    (30,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Intangible assets',v_intangible,'LINE'),

    (40,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Deferred tax asset',v_deferred_tax_asset,'LINE'),

    (50,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Prepaid operating lease rentals',v_prepaid_noncurrent,'LINE'),

    (60,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Other non-current assets',v_other_noncurrent_assets,'LINE'),

    (70,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Total Non-Current Assets',v_total_noncurrent_assets,'SUBTOTAL'),

    (80,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Current Assets',NULL,'HEADER'),

    (90,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Cash and bank balances',v_cash_bank,'LINE'),

    (100,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Student receivables',v_student_receivables,'LINE'),

    (110,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Other receivables',v_other_receivables,'LINE'),

    (120,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Prepayments',v_prepayments,'LINE'),

    (130,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','Total Current Assets',v_total_current_assets,'SUBTOTAL'),

    (140,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'ASSETS','TOTAL ASSETS',v_total_assets,'GRANDTOTAL'),

    (200,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Fund / Equity',NULL,'HEADER'),

    (210,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Accumulated fund / retained earnings',v_retained_earnings,'LINE'),

    (220,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Surplus / deficit for the period',v_surplus_deficit,'LINE'),

    (230,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Asset revaluation reserve',v_revaluation_reserve,'LINE'),

    (240,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Other reserves',v_other_reserves,'LINE'),

    (250,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Capital fund / share capital',v_capital_fund,'LINE'),

    (260,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Other fund / equity balances',v_other_equity,'LINE'),

    (270,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Opening balance reconciliation adjustment',v_opening_adjustment,'LINE'),

    (280,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'FUND / EQUITY','Total Fund / Equity',v_total_equity,'SUBTOTAL'),

    (300,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Non-Current Liabilities',NULL,'HEADER'),

    (310,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Staff gratuity provision',v_staff_gratuity,'LINE'),

    (320,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Long-term borrowings',v_longterm_borrowings,'LINE'),

    (330,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Other non-current liabilities',v_other_noncurrent_liabilities,'LINE'),

    (340,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Total Non-Current Liabilities',v_total_noncurrent_liabilities,'SUBTOTAL'),

    (350,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Current Liabilities',NULL,'HEADER'),

    (360,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Trade payables',v_trade_payables,'LINE'),

    (370,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Statutory payables',v_statutory_payables,'LINE'),

    (380,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Salary and payroll liabilities',v_salary_payroll,'LINE'),

    (390,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Bank overdrafts',v_bank_overdrafts,'LINE'),

    (400,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Student/customer credit balances',v_student_credit_balances,'LINE'),

    (410,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Other current asset credit balances',v_asset_credit_balances,'LINE'),

    (420,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Other current liabilities',v_other_current_liabilities,'LINE'),

    (430,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','Total Current Liabilities',v_total_current_liabilities,'SUBTOTAL'),

    (440,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','TOTAL LIABILITIES',v_total_liabilities,'GRANDTOTAL'),

    (450,'STATEMENT OF FINANCIAL POSITION',CONCAT('AS AT ',DATE_FORMAT(p_end_date,'%d/%m/%Y')),'LIABILITIES','TOTAL FUND / EQUITY AND LIABILITIES',v_total_equity + v_total_liabilities,'GRANDTOTAL');



    SELECT RowNo, ReportTitle, DateCaption, SectionName, LineDescription,

           CASE WHEN ROUND(COALESCE(Amount,0),2) = 0 AND LineType = 'LINE' THEN NULL ELSE Amount END AS Amount,

           LineType

    FROM tmp_sfp_lines

    ORDER BY SortNo, RowNo;



    DROP TEMPORARY TABLE IF EXISTS tmp_sfp_lines;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_balances;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_dynamicsMigration` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_dynamicsMigration`()
BEGIN



truncate fin_vouchernumbers;

truncate fin_voucher;

TRUNCATE fin_subaccounts;

TRUNCATE fin_mainaccounts;

TRUNCATE fin_ledger;



INSERT IGNORE INTO fin_journal(TID, accountcode, account_type, transactionType, transaction_amount,

 particulars, voucherNo, transactionDate, teller, timeLog)

 SELECT JID, AccountCode, AccountCategory,IF(CRamount=0,'DR','CR'),IF(CRamount=0,DRamount,CRAmount),

 Particulars,JournalNo,TransactionDate,'Rashidah',SYSDATE() FROM journalentries;



INSERT IGNORE INTO fin_journalnumbers(JournalNo, Teller, PostStatus, journalType, journalDate, journalParticulars)

SELECT DISTINCT journalnumbers.JournalNo, Teller, PostStatus, Journaltype,transactiondate,particulars  FROM journalentries,journalnumbers WHERE journalentries.journalno=journalnumbers.journalno ;

SELECT transactiondate FROM journalentries,journalnumbers WHERE journalentries.journalno=journalnumbers.journalno ;



UPDATE fin_journalnumbers SET journaltype='General';



INSERT IGNORE INTO fin_mainaccounts(AccountCode, AccountName, GeneralCategory, SubCategory)

SELECT AccountCode, AccountName, GeneralCategory, SubCategory FROM mainaccounts;



INSERT IGNORE INTO fin_subaccounts(AccountCode, MainAccountCode, AccountName, Details, collectionLedgerType, accounttype)

SELECT AccountCode, MainAccountCode, AccountName, Details,'Chart Account','Basic Account' FROM accountingpackage.subaccounts;



INSERT IGNORE INTO fin_voucher(TID, accountcode, account_type, transactionType, transaction_amount,

 particulars, voucherNo, transactionDate, teller, timeLog)

 SELECT VID, AccountCode, AccountCategory,IF(CRamount=0,'DR','CR'),IF(CRamount=0,DRamount,CRAmount),

 Particulars,voucherNo,TransactionDate,'Rashidah',SYSDATE() FROM voucherentries;



INSERT INTO fin_vouchernumbers(VoucherNo, Teller, PostStatus, vouchertype, voucherDate)

SELECT DISTINCT vouchernumbers.VoucherNo, Teller, PostStatus, vouchertype,transactiondate

FROM voucherentries,vouchernumbers WHERE voucherentries.voucherno=vouchernumbers.voucherno ;



INSERT INTO fin_ledger(TID, accountcode, account_type,

transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller, timeLog, folio)

SELECT TID, AccountCode, Accountcategory,IF(CRamount=0,'DR','CR'),IF(CRamount=0,DRamount,CRAmount),Particulars,

VoucherNo,TransactionDate,Teller, SYSDATE(),Folio FROM ledgerentries;



INSERT INTO fin_studentfeestracking

(TID, adm_no, term_sem, acadyear, T_Amount, class_course, stream, itemCode, T_Type, TNo, PostStatus)

SELECT trackerID, adm_no, bill_term, bill_year, currBalance, stud_class, stud_stream,1,'Bill',1,'Posted' FROM fin_paymenttracker;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_FeesStructurePrint` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_FeesStructurePrint`(yr char(15), prog char(15), bid int)
BEGIN

  DECLARE bs_nm char(200);

  SET prog = IF(prog = '-', '%', prog);

  SELECT

    UPPER(bs_name) INTO bs_nm

  FROM fin_billing_systems

  WHERE ID = bid;

  SELECT

    ID,

    bs_nm,

    a.ItemName,

    ffs.ItemCode,

    progid,

    studsession,

    amount,

    ROUND((0.4 * amount), 0) AS 'Instalment1',

    ROUND((0.3 * amount), 0) AS 'Instalment2',

    ROUND((0.3 * amount), 0) AS 'Instalment3',

    curr_year,

    study_year,

    yr AS acad_year,

    campus_dynamics.acad_GetProgNameByCode(progid) AS progname

  FROM fin_fees_structure ffs,

       academicbillingitems a

  WHERE a.ItemCode = FFS.ItemCode

  AND ffs.billingID = bid

  AND ffs.curr_year = SUBSTRING(yr, 1, 4)

  AND ffs.progid LIKE prog

  AND amount > 0;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_fees_deposit_analysis` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_fees_deposit_analysis`(sDate DATE, eDate DATE)
BEGIN



SELECT sDate,eDate,SUM(transaction_amount) AS total_amount,faculty_name FROM payment_analytics WHERE transactiondate  BETWEEN sDate AND eDate GROUP BY

faculty_name;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_FindDuplicateBilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_FindDuplicateBilling`(
    IN p_regno VARCHAR(25)
)
BEGIN
    
    SELECT 'TRACKING' AS source, t.TID, t.regno, t.acadyear, t.semester,
           t.item_code, t.amount, t.trans_type, t.post_status, t.detail
    FROM fin_studentfeestracking t
    WHERE t.regno = p_regno AND t.trans_type = 'Bill'
    ORDER BY t.acadyear, t.semester, t.item_code;

    
    SELECT 'LEDGER' AS source, l.TID, l.accountcode, l.transactionType,
           l.transaction_amount, l.folio, l.tracking_ref, l.source_system,
           l.transactionDate, l.particulars
    FROM fin_ledger l
    WHERE l.accountcode = p_regno AND l.account_type = 'Student'
      AND l.folio LIKE 'BillNo:%'
    ORDER BY l.transactionDate, l.TID;

    
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

    
    SELECT
        IFNULL(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0) AS total_debits,
        IFNULL(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0) AS total_credits,
        IFNULL(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0) -
        IFNULL(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0) AS net_balance
    FROM (
        
        SELECT transactionType, transaction_amount
        FROM fin_ledger
        WHERE accountcode = p_regno AND account_type = 'Student'

        UNION ALL

        
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_fixedAssetEditor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_fixedAssetEditor`(usr CHAR(25),AID CHAR(20), AssetCode CHAR(25), AcquisitionDate DATE, OfficerAssigned CHAR(35),

CurrentLocation INT, Remarks CHAR(25), DepreciationMethod CHAR(25),

DepreciationRate INT, OriginalCost BIGINT, CurrentState CHAR(25), AssetCategory INT, Description VARCHAR(150))
BEGIN

DECLARE Assetchk INT;

DECLARE newID CHAR(20);



SELECT COUNT(*) INTO Assetchk FROM  fixedassetregister WHERE assetID=AID;



IF Assetchk=0 THEN



SELECT CONCAT('IUFA',LPAD(max(substring(assetid,5,5))+1,5,0)) INTO newID FROM fixedassetregister;



INSERT INTO fixedassetregister

(AssetID, AssetCode, AcquisitionDate, OfficerAssigned, CurrentLocation,

Remarks, DepreciationMethod, DepreciationRate, OriginalCost, CurrentState, AssetCategory, Description)

VALUES

(newID, AssetCode, AcquisitionDate, OfficerAssigned, CurrentLocation,

Remarks, DepreciationMethod, DepreciationRate, OriginalCost, CurrentState, AssetCategory, Description);



ELSE



UPDATE fixedassetregister SET AssetCode=AssetCode, AcquisitionDate=AcquisitionDate, OfficerAssigned=OfficerAssigned, CurrentLocation=CurrentLocation,

Remarks=Remarks, DepreciationMethod=DepreciationMethod, DepreciationRate=DepreciationRate, OriginalCost=OriginalCost, CurrentState=CurrentState,

AssetCategory=AssetCategory, Description=Description WHERE assetID=AID;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_FunderEditor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_FunderEditor`(fID INT, funderName VARCHAR(250), funderPhone CHAR(150), funderEmail CHAR(150), funderType CHAR(20))
BEGIN



DECLARE funderCheck TINYINT;



SELECT COUNT(*) INTO funderCheck FROM external_funders WHERE funderID=fID;



IF funderCheck=0 THEN



 INSERT INTO external_funders (funderName, funderPhone, funderEmail, funderType)

 VALUES(funderName, funderPhone, funderEmail, funderType);



ELSE



 UPDATE external_funders SET funderName=funderName, funderPhone=funderPhone, funderEmail=funderEmail, funderType=funderType WHERE funderID=fID;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAccountLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAccountLedger`(accno CHAR(45) charset utf8,sDate DATE,eDate DATE,

typ CHAR(65) charset utf8,displayCurr CHAR(5) charset utf8)
BEGIN



DECLARE CR_OP_Balance,DR_OP_Balance,clBalance,CR_CL_Balance,

DR_CL_Balance,accName,TotalCR,totalDR CHAR(200) charset utf8;

DECLARE opBalance,closingBalance,last_jno CHAR(45) charset utf8;

DECLARE bal,Total_CR,total_DR DOUBLE;



SET accName = CONCAT(UPPER(fin_GetLedgerAccountName(typ,accno)),' [',accno,']');

SET @initial_amt=NULL;

SET @jno=1;



IF typ='Student' THEN

SET typ='Student';

END IF;







IF displayCurr!='UGX' AND fin_GetBaseCurrency(accno)!='UGX' THEN



UPDATE fin_ledger SET actual_amount=IF(trans_currency!='UGX',transaction_amount,transaction_amount/forex_rate),

ugx_amount=(if(trans_currency='UGX',transaction_amount,transaction_amount/forex_rate)) WHERE accountcode=accno;



ELSEIF displayCurr='UGX' AND fin_GetBaseCurrency(accno)!='UGX' THEN



UPDATE fin_ledger SET actual_amount=IF(trans_currency='UGX',transaction_amount,transaction_amount*forex_rate),

ugx_amount=(if(trans_currency='UGX',transaction_amount,transaction_amount*forex_rate)) WHERE accountcode=accno;



END IF;



IF displayCurr='UGX' AND fin_GetBaseCurrency(accno)='UGX' THEN



UPDATE fin_ledger SET actual_amount=IF(trans_currency='UGX',transaction_amount,transaction_amount*forex_rate),

ugx_amount=(if(trans_currency='UGX',transaction_amount,transaction_amount*forex_rate)) WHERE accountcode=accno;





END IF;







UPDATE fin_ledger SET curr_balance=

fin_GetIncomeRuningBalance(actual_amount,transactionType)  WHERE accountcode=accno

AND account_type=typ ORDER BY transactiondate,tid;





SELECT voucherno INTO last_jno FROM fin_ledger f WHERE accountcode=accno

AND account_type=typ AND transactiondate < sDate  ORDER BY voucherno LIMIT 1;



SELECT curr_balance INTO opBalance FROM fin_ledger WHERE accountcode=accno AND voucherno=last_jno LIMIT 1;

SELECT curr_balance INTO closingBalance FROM fin_ledger WHERE accountcode=accno

AND transactiondate<=eDate ORDER BY voucherno DESC LIMIT 1;



SELECT FORMAT(SUM(actual_amount),0) INTO TotalCR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='CR';



SELECT FORMAT(SUM(actual_amount),0) INTO TotalDR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='DR';









IF opBalance LIKE '%DR' THEN



SET DR_OP_Balance=opBalance;

SET CR_OP_Balance='';



ELSE



SET CR_OP_Balance=opBalance;

SET DR_OP_Balance='';



END IF;



IF closingBalance LIKE '%CR' THEN



SET DR_CL_Balance=closingBalance;

SET CR_CL_Balance='';



ELSE



SET CR_CL_Balance=closingBalance;

SET DR_CL_Balance='';



END IF;







IF fin_GetAccountCategory(accno) IN ('Income','Expense') THEN



SELECT SUM(transaction_amount) INTO Total_CR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='CR';



SELECT SUM(transaction_amount) INTO Total_DR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='DR';



SET Total_CR=IF(Total_CR is null,0,Total_CR);

SET Total_DR=IF(Total_DR is null,0,Total_DR);



SET bal=(Total_CR-Total_DR);



IF bal<0 THEN



SET DR_CL_Balance=CONCAT(FORMAT(ABS(bal),0),'DR');

SET CR_CL_Balance='';



ELSE



SET CR_CL_Balance=CONCAT(FORMAT(ABS(bal),0),'CR');

SET DR_CL_Balance='';



END IF;



END IF;







SELECT '1' AS voucherno,accName,sDate,eDate,

'' AS jnumber,'' AS curr,intro.* FROM

(SELECT IF(fin_GetAccountCategory(accno) NOT IN ('Income','Expense'),'Opening Balance','') as title,''

transactiondate,'' teller,'' account_type,'' curr_balance,'' accountcode,'' journal_no,

IF(fin_GetAccountCategory(accno) NOT IN ('Income','Expense'),CR_OP_Balance,'') AS cramount,

IF(fin_GetAccountCategory(accno) NOT IN ('Income','Expense'),DR_OP_Balance,'') AS dramount,'' voucherno,''

particulars,'' AS trans_currency, 0 AS TID FROM DUAL) AS intro



UNION ALL



SELECT voucherno,accName,sDate,eDate,journal_no AS jnumber,trans_currency,

trans.* FROM

(SELECT '',DATE_FORMAT(transactiondate,'%d/%m/%Y') AS transactiondate,teller,account_type,

IF(fin_GetAccountCategory(accno) IN ('Income','Expense'),

fin_GetIncomeRuningBalance(actual_amount,transactionType),curr_balance) AS curr_balance,accountcode,journal_no,

IF(transactiontype='CR',FORMAT(actual_amount,0),'') AS cramount,

IF(transactiontype='DR',FORMAT(actual_amount,0),'') AS dramount,voucherno,

particulars,trans_currency,TID  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ AND transactiondate BETWEEN sDate AND eDate

ORDER BY journal_no) AS trans







UNION ALL



SELECT '3',accName,sDate,eDate,'' AS jnumber,'' AS curr,footer.* FROM

(SELECT 'CLOSING BALANCE' as title,'' transactiondate,'' teller,'' account_type,'' cur_balance,'' accountcode,'' journal_no,

CR_CL_Balance AS cramount,

DR_CL_Balance AS dramount,'' voucherno,

'' particulars, '' AS trans_currency, 1000000 AS TID FROM DUAL) AS footer ORDER BY TID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAdmissionFeesStructure` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAdmissionFeesStructure`(prog char(25), sess char(15), yr int, intk char(25), bid int)
BEGIN

  DECLARE dollar_rate double;

  SELECT

    rates INTO dollar_rate

  FROM fin_currency

  WHERE code = 'USD';

  SELECT

    ItemName,

    bi.ItemCode,

    amount,

    CEILING(amount / dollar_rate) AS dollar_amount,

    study_year,

    semester

  FROM fin_fees_structure fs,

       academicbillingitems bi

  WHERE fs.ItemCode = bi.ItemCode

  AND progid = prog

  AND studsession = sess

  AND curr_year = yr

  AND amount > 0

  AND study_year = 1

  AND semester = 1

  AND billingID = bid

  ORDER BY amount DESC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAllAssets` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAllAssets`()
BEGIN



SELECT a.* FROM fixedassetregister a JOIN fin_assetlocations l JOIN assetCategory c ON l.locationID=a.CurrentLocation AND c.CatID=a.AssetCategory ORDER BY Description;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAllLedgerCategories` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAllLedgerCategories`()
BEGIN



SELECT  LedgerTypeID, LedgerTypeName, LedgerTypeCategory FROM fin_ledgertypes ORDER BY LedgerTypeName;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAllowanceList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAllowanceList`(yr INT, months CHAR(25), allID INT, typ CHAR(15))
BEGIN



IF typ='Allowances' THEN



SELECT hurmis.get_empname(empCode) AS empName,title,

currYear, currMonth, empCode, amount

FROM (SELECT * FROM hurmis.payroll_emp_allowance WHERE currYear=yr AND currMonth=months AND allowanceid=allID) AS p

JOIN hurmis.payroll_allowance a ON a.allowanceid=p.allowanceid ORDER BY hurmis.get_empname(empCode);



ELSEIF typ='Deductions' THEN



SELECT hurmis.get_empname(empCode) AS empName,title,

currYear, currMonth, empCode, amount

FROM (SELECT * FROM hurmis.payroll_emp_deduction WHERE currYear=yr AND currMonth=months AND deductionid=allID) AS p

JOIN hurmis.payroll_deduction a ON a.deductionid=p.deductionid ORDER BY hurmis.get_empname(empCode);



ELSE



SELECT hurmis.get_empname(empCode) AS empName,'Gross Pay' AS title,

currYear, currMonth, empCode, hurmis.get_grosspay(yr,months,empCode) AS amount

FROM hurmis.payroll_payment p WHERE currYear=yr AND currMonth=months;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAllPayrollTransactions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAllPayrollTransactions`(T_Type CHAR(15))
BEGIN



IF T_Type='Allowance' THEN



  SELECT allowanceId AS ID, title AS transactionName FROM hurmis.payroll_allowance ORDER BY title;



ELSEIF T_Type='Deduction' THEN



  SELECT deductionId AS ID, title  AS transactionName FROM hurmis.payroll_deduction ORDER BY title;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAnnualSubscription` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAnnualSubscription`(memID CHAR(25), yr INT, prodID INT)
BEGIN



SELECT * FROM fin_subscription WHERE memberID=memID AND sub_year=yr AND productID=prodID ORDER BY fin_MonthNo(sub_month) DESC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAssetListByCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAssetListByCategory`(catCode INT)
BEGIN



SELECT a.* FROM fixedassetregister a JOIN fin_assetlocations l JOIN assetCategory c ON l.locationID=a.CurrentLocation

AND c.CatID=a.AssetCategory  WHERE assetCategory=catCode ORDER BY Description; 



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetAssetsByCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetAssetsByCategory`(catCode INT, months CHAR(15), yr INT)
BEGIN



SELECT fin_GetDepreciationValues(AssetID,months,yr,'Monthly') AS monthDepreciation,

fin_GetDepreciationValues(AssetID,months,yr,'Cumulative') AS accumulatedDepreciation,

(originalcost-

fin_GetDepreciationValues(AssetID,months,yr,'Cumulative')) NetBookValue,

AssetID, AssetCode,OriginalCost, Description,months AS month, yr AS year,

AssetCategoryName AS CategoryName,(SELECT OfficeInCharges FROM fin_assetlocations WHERE locationID=currentLocation) AS Location FROM fixedassetregister a JOIN assetcategory c

ON a.assetCategory=c.catID WHERE c.catID=catCode ORDER BY Description;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetBankCharge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetBankCharge`(bCode CHAR(15))
BEGIN



DECLARE charge INT;

SELECT bankcharge INTO charge FROM bankchargerates WHERE bankcode=bCode;

SELECT IF(charge IS NULL,0,charge) AS BankCharge FROM DUAL;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetBankChargeRates` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetBankChargeRates`()
BEGIN



SELECT accountName,br.* FROM bankchargerates br, subaccounts s

WHERE s.accountcode=br.bankcode;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetBankRecoStatementData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetBankRecoStatementData`(cat CHAR(15), RID INT)
BEGIN



IF cat='ALL' THEN



SELECT Curr_Balance, ID, RecoID, amount, details, match_TID, track_no, trans_date, trans_typ FROM fin_reco_bank_entries

 WHERE (RecoID = RID) ORDER BY match_TID DESC, ID;



ELSEIF cat='Pending' THEN



SELECT Curr_Balance, ID, RecoID, amount, details, match_TID, track_no, trans_date, trans_typ FROM fin_reco_bank_entries

 WHERE (RecoID = RID) AND match_TID='0' ORDER BY match_TID DESC, ID;



ELSE



SELECT Curr_Balance, ID, RecoID, amount, details, match_TID, track_no, trans_date, trans_typ FROM fin_reco_bank_entries

 WHERE (RecoID = RID) AND match_TID!='0' ORDER BY match_TID DESC, ID;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetBudget` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetBudget`(yr INT, cat CHAR(15))
BEGIN



IF cat='ALL' THEN

SET cat='%';

ELSEIF cat='EXPENDITURE' THEN

SET cat='Expense';

END IF;



SELECT accountname,b.* FROM fin_budget b, fin_subaccounts s WHERE b.item_code=s.accountcode AND item_category LIKE cat AND

budget_year=yr ORDER BY item_category DESC,item_code ASC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetClearanceLists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetClearanceLists`(acad CHAR(25), sem INT,

clearance_type CHAR(25), stat CHAR(25), intk CHAR(25),prog CHAR(25),f_stat CHAR(25),entyear INT)
BEGIN

DECLARE sDate,eDate DATE;



SET eDate=DATE(SYSDATE());

SET sDate=DATE_SUB(SYSDATE(),INTERVAL 1 YEAR);



UPDATE campus_dynamics.acad_registration set examclearance='UNCLEARED' WHERE examclearance='-';



SET prog=IF(prog='-','%',prog);



IF clearance_type='Examination' THEN



IF stat='Pending' THEN

SET stat='UNCLEARED';

END IF;



IF f_stat='Cleared' THEN



SELECT CONCAT(othername, ' ',firstname) AS stud_names,entryno,photofile,

fin_GetFeesBalance('Current',sDate,eDate,r.regno) AS cur_balance,r.* FROM campus_dynamics.acad_registration r,campus_dynamics.acad_student s

WHERE acad_year=acad AND semester=sem AND entryyear = entyear AND examClearance=stat AND r.regno=s.regno AND progid LIKE prog AND intake=intk AND

fin_GetFeesBalance('Current',sDate,eDate,r.regno)<=0 AND fin_BillCounter(r.regno,sem,acad)>0

ORDER BY othername;



ELSEIF f_stat='Pending' THEN



SELECT CONCAT(othername, ' ',firstname) AS stud_names,entryno,photofile,

fin_GetFeesBalance('Current',sDate,eDate,r.regno) AS cur_balance,r.* FROM campus_dynamics.acad_registration r,campus_dynamics.acad_student s

WHERE acad_year=acad AND semester=sem AND entryyear = entyear  AND examClearance=stat AND r.regno=s.regno AND progid LIKE prog AND intake=intk AND

(fin_GetFeesBalance('Current',sDate,eDate,r.regno)>=0 OR fin_BillCounter(r.regno,sem,acad)=0)

ORDER BY othername;





ELSE



SELECT CONCAT(othername, ' ',firstname) AS stud_names,entryno,photofile,

fin_GetFeesBalance('Current',sDate,eDate,r.regno) AS cur_balance,r.* FROM campus_dynamics.acad_registration r,campus_dynamics.acad_student s

WHERE acad_year=acad AND semester=sem AND entryyear = entyear  AND examClearance=stat AND r.regno=s.regno AND progid LIKE prog AND intake=intk

ORDER BY othername;



END IF;



ELSE



IF stat='Pending' THEN

SET stat='UNREGISTERED';

ELSE

SET stat='%';

END IF;



SELECT CONCAT(othername, ' ',firstname) AS stud_names,entryno,photofile,

fin_GetFeesBalance('Current',sDate,eDate,r.regno) AS cur_balance,r.* FROM campus_dynamics.acad_registration r,campus_dynamics.acad_student s

WHERE acad_year=acad AND semester=sem  AND r.regno=s.regno AND (regstatus LIKE stat AND regstatus!=IF(stat='%','UNREGISTERED',''))

AND progid LIKE prog  AND intake=intk AND entryyear = entyear ORDER BY  othername;



END IF;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetCompanyInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetCompanyInfo`()
BEGIN



SELECT * FROM companyinfo;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetDrillDownDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_GetDrillDownDetails`(

    acc CHAR(25),

    sDate DATE,

    eDate DATE

)
BEGIN



    DECLARE p_acc CHAR(25);

    DECLARE v_accounttype CHAR(50) DEFAULT NULL;

    DECLARE v_collectiontype CHAR(50) DEFAULT NULL;

    DECLARE v_ledger_type CHAR(50) DEFAULT NULL;



    DECLARE v_open DECIMAL(20,2) DEFAULT 0.00;

    DECLARE v_period DECIMAL(20,2) DEFAULT 0.00;

    DECLARE v_close DECIMAL(20,2) DEFAULT 0.00;



    DECLARE v_open_type CHAR(2) DEFAULT 'DR';

    DECLARE v_close_type CHAR(2) DEFAULT 'DR';



    DECLARE v_open_amount DECIMAL(20,2) DEFAULT 0.00;

    DECLARE v_close_amount DECIMAL(20,2) DEFAULT 0.00;



    DECLARE v_open_balance CHAR(100) DEFAULT '0DR';

    DECLARE v_close_balance CHAR(100) DEFAULT '0DR';



    SET p_acc = acc;



    -- Determine ledger type

    SELECT accounttype, collectionLedgerType

    INTO v_accounttype, v_collectiontype

    FROM fin_subaccounts

    WHERE accountcode = p_acc

    LIMIT 1;



    IF v_accounttype = 'Collection Account' THEN

        SET v_ledger_type = v_collectiontype;

    ELSE

        SET v_ledger_type = 'Chart Account';

    END IF;



    IF v_accounttype IS NULL THEN

        SELECT l.account_type

        INTO v_ledger_type

        FROM fin_ledger l

        WHERE l.accountcode = p_acc

        ORDER BY l.transactionDate, l.TID

        LIMIT 1;

    END IF;



    -- Opening balance (all transactions before sDate) using base currency

    SELECT ROUND(

        COALESCE(SUM(

            CASE

                WHEN l.transactionType = 'DR' THEN COALESCE(l.ugx_amount, l.actual_amount, l.transaction_amount, 0)

                WHEN l.transactionType = 'CR' THEN -COALESCE(l.ugx_amount, l.actual_amount, l.transaction_amount, 0)

                ELSE 0

            END

        ), 0), 2)

    INTO v_open

    FROM fin_ledger l

    WHERE l.accountcode = p_acc

      AND l.account_type = v_ledger_type

      AND l.transactionDate < sDate;



    -- Period net change (all transactions between sDate and eDate)

    SELECT ROUND(

        COALESCE(SUM(

            CASE

                WHEN l.transactionType = 'DR' THEN COALESCE(l.ugx_amount, l.actual_amount, l.transaction_amount, 0)

                WHEN l.transactionType = 'CR' THEN -COALESCE(l.ugx_amount, l.actual_amount, l.transaction_amount, 0)

                ELSE 0

            END

        ), 0), 2)

    INTO v_period

    FROM fin_ledger l

    WHERE l.accountcode = p_acc

      AND l.account_type = v_ledger_type

      AND l.transactionDate BETWEEN sDate AND eDate;



    SET v_close = v_open + v_period;



    -- Format opening balance

    IF v_open < 0 THEN

        SET v_open_type = 'CR';

        SET v_open_amount = ABS(v_open);

        SET v_open_balance = CONCAT(FORMAT(ABS(v_open), 2), ' CR');

    ELSE

        SET v_open_type = 'DR';

        SET v_open_amount = ABS(v_open);

        SET v_open_balance = CONCAT(FORMAT(ABS(v_open), 2), ' DR');

    END IF;



    -- Format closing balance

    IF v_close < 0 THEN

        SET v_close_type = 'CR';

        SET v_close_amount = ABS(v_close);

        SET v_close_balance = CONCAT(FORMAT(ABS(v_close), 2), ' CR');

    ELSE

        SET v_close_type = 'DR';

        SET v_close_amount = ABS(v_close);

        SET v_close_balance = CONCAT(FORMAT(ABS(v_close), 2), ' DR');

    END IF;



    -- Final result: opening summary → period transactions → closing summary

    SELECT *

    FROM (

        -- 1. Synthetic opening balance row (date = start date)

        SELECT

            fin_GetLedgerAccountName(v_ledger_type, p_acc) AS acc_name,

            900000 AS TID,

            p_acc AS acc,

            v_ledger_type AS acc_type,

            v_open_type AS transactionType,

            v_open_amount AS transaction_amount,

            'OPENING BALANCE' AS particulars,

            0 AS voucherNo,

            sDate AS transactionDate,   -- <<< changed: use start date

            'system' AS teller,

            NULL AS timeLog,

            '' AS folio,

            '' AS journal_no,

            'UGX' AS trans_currency,

            v_open_amount AS actual_amount,

            v_open_balance AS curr_balance,

            1 AS forex_rate,

            v_open_amount AS ugx_amount,

            1 AS sort_order



        UNION ALL



        -- 2. All real period transactions (keep their original dates)

        SELECT

            fin_GetLedgerAccountName(l.account_type, l.accountcode) AS acc_name,

            l.TID,

            p_acc AS acc,

            l.account_type AS acc_type,

            l.transactionType,

            l.transaction_amount,

            l.particulars,

            l.voucherNo,

            l.transactionDate,

            l.teller,

            l.timeLog,

            l.folio,

            l.journal_no,

            l.trans_currency,

            COALESCE(l.actual_amount, l.transaction_amount, 0) AS actual_amount,

            l.curr_balance,

            l.forex_rate,

            COALESCE(l.ugx_amount, l.actual_amount, l.transaction_amount, 0) AS ugx_amount,

            2 AS sort_order

        FROM fin_ledger l

        WHERE l.accountcode = p_acc

          AND l.account_type = v_ledger_type

          AND l.transactionDate BETWEEN sDate AND eDate



        UNION ALL



        -- 3. Synthetic closing balance row (date = end date)

        SELECT

            fin_GetLedgerAccountName(v_ledger_type, p_acc) AS acc_name,

            1000000 AS TID,

            p_acc AS acc,

            v_ledger_type AS acc_type,

            v_close_type AS transactionType,

            v_close_amount AS transaction_amount,

            'CLOSING BALANCE' AS particulars,

            0 AS voucherNo,

            eDate AS transactionDate,   -- <<< changed: use end date

            'system' AS teller,

            NULL AS timeLog,

            '' AS folio,

            '' AS journal_no,

            'UGX' AS trans_currency,

            v_close_amount AS actual_amount,

            v_close_balance AS curr_balance,

            1 AS forex_rate,

            v_close_amount AS ugx_amount,

            3 AS sort_order

    ) AS final_ledger

    ORDER BY sort_order, transactionDate, TID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetFeesAnalysis` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetFeesAnalysis`(typ CHAR(25),sDate DATE, eDate DATE)
BEGIN

IF typ='INCOME' THEN



SELECT transactionDate, l.voucherno, IF(transactiontype='DR',-1*transaction_amount,transaction_amount) AS actualamount,transactiontype,

fin_GetAccountname(accountcode) AS LedgerName, faculty,prog AS programme FROM fin_ledger l JOIN

fin_ledger_prog p ON l.TID=p.TID AND transactionDate BETWEEN sDate AND eDate AND faculty!='-'

AND accountcode IN (SELECT s.AccountCode FROM fin_subaccounts s JOIN fin_mainaccounts m ON s.MainAccountCode=m.AccountCode WHERE m.AccountName=typ);



ELSE



SELECT transactionDate, l.voucherno, IF(transactiontype='CR',-1*transaction_amount,transaction_amount) AS actualamount,transactiontype,

fin_GetAccountname(accountcode) AS LedgerName, faculty,prog AS programme FROM fin_ledger l JOIN

fin_ledger_prog p ON l.TID=p.TID AND transactionDate BETWEEN sDate AND eDate AND faculty!='-'

AND accountcode IN (SELECT s.AccountCode FROM fin_subaccounts s JOIN fin_mainaccounts m ON s.MainAccountCode=m.AccountCode WHERE m.AccountName=typ);



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetFeesDashboard` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetFeesDashboard`(sDate DATE,eDate DATE,usr VARCHAR(65))
BEGIN

DELETE

  FROM fin_fees_analysis_semester

WHERE created_by = usr;

INSERT INTO fin_fees_analysis_semester (regno, s_date, e_date, opening, total_bills, total_pay, created_by)

  SELECT

    IF(op.accountcode IS NULL, d.accountcode, op.accountcode) AS stud_code,

    sDate,

    eDate,

    IF((op.total_dr - op.total_cr) IS NULL, 0, (op.total_dr - op.total_cr)) AS opening,

    d.total_cr,

    d.total_dr,

    usr

  FROM (SELECT

      accountcode,

      SUM(IF(transactionType = 'CR', transaction_amount, 0)) AS total_cr,

      SUM(IF(transactionType = 'DR', transaction_amount, 0)) AS total_dr

    FROM fin_ledger

    WHERE accountcode LIKE 'MRU%'

    AND transactionDate BETWEEN sDate AND eDate

    GROUP BY accountcode

    ORDER BY accountcode) AS d

    LEFT OUTER JOIN (SELECT

        accountcode,

        SUM(IF(transactionType = 'CR', transaction_amount, 0)) AS total_cr,

        SUM(IF(transactionType = 'DR', transaction_amount, 0)) AS total_dr

      FROM fin_ledger

      WHERE accountcode LIKE 'MRU%'

      AND transactionDate < sDate

      GROUP BY accountcode

      ORDER BY accountcode) AS op

      ON op.accountcode = d.accountcode;



UPDATE fin_fees_analysis_semester

SET campus = campus_dynamics.acad_GetCampusNameFromID(campus_dynamics.acad_GetStudentCampus(regno))

WHERE created_by = usr;



UPDATE fin_fees_analysis_semester

SET faculty = campus_dynamics.acad_GetFacultyFromRegno(regno)

WHERE created_by = usr;



UPDATE fin_fees_analysis_semester

SET programme = campus_dynamics.acad_GetProgNameByRegNo(regno)

WHERE created_by = usr;



UPDATE fin_fees_analysis_semester

SET total_pending = (total_bills + opening - total_pay)

WHERE created_by = usr;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetGeneralDrillDownDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetGeneralDrillDownDetails`(acc CHAR(25), sDate DATE, eDate DATE)
BEGIN



DECLARE acc_type,collectionAcc CHAR(25);

SELECT accounttype,collectionLedgerType INTO acc_type,collectionAcc  FROM fin_subaccounts f WHERE accountcode=acc;



IF acc_type='Basic Account' THEN



SELECT accountcode,fin_GetLedgerAccountName(account_type,accountcode) AS acc_name,

fin_GetGLPeriodBalance(sDate,eDate,accountcode,acc) AS balance FROM (SELECT DISTINCT accountcode,account_type FROM fin_ledger

WHERE accountcode=acc AND transactiondate BETWEEN sDate AND eDate GROUP BY accountcode) AS basicData;



ELSE



SELECT DISTINCT accountcode,fin_GetLedgerAccountName(account_type,accountcode) AS acc_name,

fin_GetGLPeriodBalance(sDate,eDate,accountcode,acc) AS balance FROM fin_ledger l

WHERE account_type=collectionAcc AND transactiondate BETWEEN sDate AND eDate GROUP BY accountcode;





END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetJournalAccounts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetJournalAccounts`(txt CHAR(35),typ CHAR(50))
BEGIN

    SET txt=CONCAT('%',txt,'%');



    IF typ LIKE '%Gratuity%' THEN

        SET typ='Gratuity';

    ELSEIF typ LIKE '%Advance%' THEN

        SET typ='Salary Advance';

    END IF;



    IF typ!='Sponsor' AND typ!='Supplier' AND typ!='Payments' THEN



        SELECT AccountCode,AccountName,'Chart Account' AS category 

        FROM fin_subaccounts

        WHERE AccountName LIKE txt OR AccountCode LIKE txt



        UNION

        SELECT regno, CONCAT(othername,' ',firstname), fin_GetStudentLedgerName(regno) 

        FROM campus_dynamics.acad_student 

        WHERE CONCAT(othername,' ',firstname) LIKE txt OR regno LIKE txt



        UNION

        SELECT CONCAT(empID,'|Salary Advance') AS AccountCode,

               emp_name AS AccountName,

               'Salary Advance' AS category

        FROM campus_dynamics.hrm_employee

        WHERE emp_name LIKE txt OR empID LIKE txt



        UNION

        SELECT CONCAT(empID,'|Gratuity') AS AccountCode,

               emp_name AS AccountName,

               'Gratuity' AS category

        FROM campus_dynamics.hrm_employee

        WHERE emp_name LIKE txt OR empID LIKE txt



        UNION

        SELECT supplierID AS accountCode, supplierName AS accountName, 'Supplier' AS category 

        FROM supplier 

        WHERE supplierName LIKE txt



        UNION

        SELECT scholarshipID AS AccountCode, scholarshipName AS AccountName, 'Sponsor' AS category 

        FROM scholarships;



    ELSEIF typ='Supplier' THEN

        SELECT supplierID AS accountCode, supplierName AS accountName, 'Supplier' AS category 

        FROM supplier 

        ORDER BY supplierName;



    ELSEIF typ='Payments' OR typ='Journal' THEN

        SELECT * FROM

        (

            SELECT supplierID AS accountCode, supplierName AS accountName, 'Supplier' AS category FROM supplier

            UNION

            SELECT AccountCode,AccountName,'Chart Account' AS category FROM fin_subaccounts 

            WHERE MainAccountCode IN (SELECT AccountCode FROM fin_mainaccounts WHERE AccountName LIKE '%EXPENSE%')

            UNION

            SELECT AccountCode,AccountName,'Chart Account' AS category FROM fin_subaccounts 

            WHERE MainAccountCode IN (SELECT AccountCode FROM fin_mainaccounts WHERE AccountName LIKE '%LIABILI%')

            UNION

            SELECT CONCAT(empID,'|Salary Advance') AS AccountCode,

                   emp_name AS AccountName,

                   'Salary Advance' AS category

            FROM campus_dynamics.hrm_employee

            WHERE emp_name LIKE txt OR empID LIKE txt

            UNION

            SELECT CONCAT(empID,'|Gratuity') AS AccountCode,

                   emp_name AS AccountName,

                   'Gratuity' AS category

            FROM campus_dynamics.hrm_employee

            WHERE emp_name LIKE txt OR empID LIKE txt

            UNION

            SELECT regno, CONCAT(othername,' ',firstname), fin_GetStudentLedgerName(regno) 

            FROM campus_dynamics.acad_student 

            WHERE CONCAT(othername,' ',firstname) LIKE txt OR regno LIKE txt

        ) AS db 

        ORDER BY AccountName;



    ELSE

        -- Keep scholarships if nothing else matches

        SELECT scholarshipID AS AccountCode, scholarshipName AS AccountName, 'Sponsor' AS category 

        FROM scholarships 

        ORDER BY scholarshipName;



    END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetJournalDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetJournalDetails`(jno TEXT)
BEGIN
    DECLARE gl_voucher INT;
    DECLARE jStat, jType CHAR(25);

    SELECT GL_VoucherNo, PostStatus, journalType
    INTO gl_voucher, jStat, jType
    FROM fin_journalnumbers
    WHERE JournalNo = CAST(TRIM(jno) AS UNSIGNED)
    LIMIT 1;

    IF (jStat = 'Posted') THEN
        SELECT fin_GetLedgerAccountName(account_type, accountcode) AS accountname,
               UPPER(jType) AS 'jType', l.*
        FROM fin_ledger l
        WHERE voucherno = gl_voucher;
    ELSE
        SELECT fin_GetLedgerAccountName(account_type, accountcode) AS accountname,
               UPPER(jType) AS 'jType', l.*
        FROM fin_journal_details l
        WHERE (TRIM(l.journal_no) = TRIM(jno) OR TRIM(l.journal_no) = CONCAT('JN-', TRIM(jno)))
          AND journal_type = jType;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetJournalTransactions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetJournalTransactions`(JNo INT)
BEGIN



SELECT fin_GetVoucherAccountNames(account_type,accountcode) AS accountname,j.* FROM fin_journal j WHERE voucherNo=JNo;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetLatestVoucherNo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetLatestVoucherNo`(usr CHAR(25), typ CHAR(25), cat CHAR(25))
BEGIN

DECLARE VNo,chk INT;



SELECT MAX(VoucherNo) INTO VNo  FROM fin_vouchernumbers WHERE Teller=usr;

SELECT COUNT(*) INTO chk FROM fin_voucher WHERE voucherno=VNo;



IF VNo IS NULL OR (cat='New' AND chk>0) THEN



INSERT INTO fin_vouchernumbers(Teller, PostStatus, Vouchertype) VALUE(usr,'New',typ);



END IF;



SELECT MAX(VoucherNo) AS VoucherNo FROM fin_vouchernumbers WHERE Teller=usr;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetLederMainTypes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetLederMainTypes`()
BEGIN



SELECT DISTINCT LedgerTypeCategory FROM fin_ledgertypes ORDER BY LedgerTypeCategory;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetLedgerCategories` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetLedgerCategories`()
BEGIN



SELECT DISTINCT LedgerTypeCategory FROM fin_ledgertypes f ORDER BY LedgerTypeCategory;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetLedgerTypesByCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetLedgerTypesByCategory`(cat CHAR(15))
BEGIN



SELECT  LedgerTypeID, LedgerTypeName, LedgerTypeCategory FROM fin_ledgertypes WHERE

LedgerTypeCategory=cat;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetLimitedStudentLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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

        fl.particulars,

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

      AND NOT (

            COALESCE(fl.source_system, '') IN ('SB_COLLECTIONS', 'CB_COLLECTIONS')

            AND EXISTS (

                SELECT 1

                  FROM fin_studentfeestracking t0

                 WHERE t0.regno = fl.accountcode

                   AND t0.post_status = 'Posted'

                   AND t0.trans_type IN ('Payment','Waiver')

                   AND DATE(t0.trans_date) = DATE(fl.transactionDate)

                   AND ROUND(t0.amount, 2) =

                       ROUND(

                           CASE

                               WHEN fl.actual_amount IS NOT NULL AND fl.actual_amount <> 0

                               THEN fl.actual_amount

                               ELSE fl.transaction_amount

                           END, 2

                       )

            )

      );



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

             AND COALESCE(fl2.source_system, '') NOT IN ('SB_COLLECTIONS', 'CB_COLLECTIONS')

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



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetLimitedSupplierLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetLimitedSupplierLedger`(

    sid CHAR(25),

    sDate DATE,

    eDate DATE

)
BEGIN



    DECLARE accName, op_balance, cr_bal, dr_bal,Ref_no CHAR(100);

    DECLARE opDate DATE;

    DECLARE InvoiceDate DATE;



    SELECT UPPER(supplierName) INTO accName

    FROM inv_supplierdetails

    WHERE supplierCode = sid;



    SET accName = CONCAT(accName,' [',sid,']');



    UPDATE fin_ledger 

    SET curr_balance = fin_GetCurrentBalance(accountcode, TID, account_type)

    WHERE accountcode = sid AND Account_type='Supplier';



    SELECT curr_balance, transactionDate INTO op_balance, opDate 

    FROM fin_ledger l

    WHERE accountcode = sid AND l.transactionDate < sDate AND Account_type='Supplier'

    ORDER BY TID DESC LIMIT 1;



    SET op_balance = IF(op_balance IS NULL,'0CR',op_balance);

    SET opDate = IF(opDate IS NULL,sDate,opDate);



    SELECT

        accName,

        CONCAT('LEDGER PERIOD [',DATE_FORMAT(sDate,'%d-%m-%Y'),' TO ',DATE_FORMAT(eDate,'%d-%m-%Y'),']') AS stud_details,

        dr_bal AS dr_amount,

        cr_bal AS cr_amount,

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

        op_balance AS curr_balance,

        '' AS trans_currency,

        null AS InvoiceDate,

        Ref_no

    FROM DUAL



    UNION



    SELECT

        accName,

        'Supplier' AS stud_details,

        IF(transactionType='DR', FORMAT(transaction_amount,0), '') AS dr_amount,

        IF(transactionType='CR', FORMAT(transaction_amount,0), '') AS cr_amount,

        DATE_FORMAT(l.transactionDate,'%D %M, %Y') AS formated_date,

        TID,

        accountcode,

        account_type,

        transactionType,

        transaction_amount,

        particulars,

        journal_no AS voucherNo,

        voucherNo AS realVoucherno,

        l.transactionDate,

        l.teller,

        timeLog,

        folio,

        curr_balance,

        trans_currency,

        DATE_FORMAT(l.InvoiceDate, '%d %M %Y') AS InvoiceDate,

        l.RefNo

    FROM fin_ledger l

    LEFT JOIN fin_journalnumbers j ON l.journal_no = j.JournalNo

    WHERE l.accountcode = sid

      AND l.transactionDate BETWEEN sDate AND eDate

      AND l.account_type = 'Supplier'

    ORDER BY transactionDate, voucherNo, TID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetLocationsByCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetLocationsByCategory`(cat CHAR(15))
BEGIN

SELECT * FROM fin_assetlocations WHERE locationCategory=cat;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetMemberProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetMemberProduct`(memID CHAR(25))
BEGIN



SELECT productname,mp.* FROM fin_products p, fin_memberproducts mp WHERE mp.productid=p.productid AND mp.memberID=memID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetMonthlyBenefits` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetMonthlyBenefits`(mnth CHAR(15), yr INT, prodID INT)
BEGIN

DECLARE freq CHAR(25);

SELECT frequency INTO freq FROM fin_benefits WHERE benefitID=prodID;

IF freq='Monthly' THEN

SELECT mem_GetDataByID(memberID,'Name') AS mem_name,mem_GetDataByID(memberID,'Number') AS mem_no,

s.* FROM fin_benefitpayments s WHERE benefit_month=mnth AND benefit_year=yr AND benefitID=prodID ORDER BY memberID;

ELSEIF freq='Annual' THEN

SELECT mem_GetDataByID(memberID,'Name') AS mem_name,mem_GetDataByID(memberID,'Number') AS mem_no,

s.* FROM fin_benefitpayments s WHERE sub_year=yr AND benefitID=prodID ORDER BY memberID;

ELSE

SELECT mem_GetDataByID(memberID,'Name') AS mem_name,mem_GetDataByID(memberID,'Number') AS mem_no,

s.* FROM fin_benefitpayments s WHERE  benefitID=prodID ORDER BY memberID;

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetMonthlySubscription` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetMonthlySubscription`(mnth CHAR(15), yr INT, prodID INT)
BEGIN

DECLARE freq CHAR(25);

SELECT frequency INTO freq FROM fin_products WHERE productID=prodID;

IF freq='Monthly' THEN

SELECT mem_GetDataByID(memberID,'Name') AS mem_name,mem_GetDataByID(memberID,'Number') AS mem_no,

s.* FROM fin_subscription s WHERE sub_month=mnth AND sub_year=yr AND productID=prodID ORDER BY memberID;

ELSEIF freq='Annual' THEN

SELECT mem_GetDataByID(memberID,'Name') AS mem_name,mem_GetDataByID(memberID,'Number') AS mem_no,

s.* FROM fin_subscription s WHERE sub_year=yr AND productID=prodID ORDER BY memberID;

ELSE

SELECT mem_GetDataByID(memberID,'Name') AS mem_name,mem_GetDataByID(memberID,'Number') AS mem_no,

s.* FROM fin_subscription s WHERE  productID=prodID ORDER BY memberID;

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetMonthlySubscriptionReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetMonthlySubscriptionReport`(mnth CHAR(15), yr INT, cat CHAR(25),prodID INT)
BEGIN



DECLARE prodName VARCHAR(200);

SELECT UPPER(productName) INTO prodName FROM fin_products WHERE productID=prodID;



IF cat='Defaulters' THEN



SELECT mem_GetDataByID(memberID,'Name') AS mem_name,CONCAT(prodName,' ',UPPER(cat)) AS reportheader,

s.* FROM fin_subscription s WHERE sub_month=mnth AND sub_year=yr AND PayStatus='Unpaid' AND productID=prodID ORDER BY mem_GetDataByID(memberID,'Name');



ELSE



SELECT mem_GetDataByID(memberID,'Name') AS mem_name,CONCAT(prodName,' ',UPPER(cat)) AS reportheader,

s.* FROM fin_subscription s WHERE sub_month=mnth AND sub_year=yr  AND PayStatus='Paid' AND productID=prodID ORDER BY mem_GetDataByID(memberID,'Name');



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetOtherStudentFees` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetOtherStudentFees`(reg CHAR(25) CHARSET utf8)
BEGIN
DECLARE nation,eyr,prog,sess,curr,bid CHAR(45)  CHARSET utf8;
DECLARE other_fees TEXT;
DECLARE c_rate DOUBLE DEFAULT 1;

SELECT nationality,entryyear,progid,studsesion,billingID INTO nation,eyr,prog,sess,bid FROM campus_dynamics.acad_student WHERE regno=reg;
IF nation IS NULL THEN
  SELECT stud_nationality,stud_entry_year,billingID INTO nation,eyr,bid FROM campus_dynamics.acad_applications WHERE stud_entry_no=reg;
  SELECT prog_id,adm_session INTO prog,sess FROM campus_dynamics.acad_applicant_choices WHERE stud_entry_no=reg AND choice=1;
END IF;

SELECT bs_currency INTO curr FROM fin_billing_systems WHERE ID=bid;

SELECT fs.itemcode,itemname,FORMAT(CEILING((amount)),0) AS amount from fin_fees_structure fs, academicbillingitems i
 WHERE progid=prog AND curr_year=eyr and i.itemcode=fs.itemcode and semester=1 and study_year=1 and studsession=sess AND
 fs.itemCode NOT IN (SELECT itemid  from fin_fees_pay_schedule WHERE progid=prog AND curr_year=eyr AND billingID=bid) AND amount>0 AND billingID=bid;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetPayeeAccounts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetPayeeAccounts`(typ CHAR(25))
BEGIN



IF typ='Supplier' THEN

  SELECT supplierID AS accountCode, supplierName AS accountName FROM supplier ORDER BY supplierName;

ELSEIF typ='Student' THEN

  SELECT adm_no AS accountCode, CONCAT(stud_names) AS accountName FROM schoolmis.student LIMIT 80;

ELSEIF typ='Bank' THEN

  SELECT sa.accountCode, sa.accountName FROM fin_subAccounts sa, fin_mainaccounts ma WHERE MainAccountCode=ma.AccountCode

  AND (ma.AccountName LIKE '%Bank%' OR ma.AccountName LIKE '%Cash%');

ELSEIF (typ='Salary Advance' OR typ='Payroll' OR typ='Employee') THEN

SELECT empID AS accountCode,emp_name AS accountName

FROM campus_dynamics.hrm_employee ORDER BY emp_name;

ELSE

  SELECT accountCode, accountName FROM fin_subAccounts;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetPaymentLedgerTypes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetPaymentLedgerTypes`(typ CHAR(25))
BEGIN



SELECT * FROM fin_ledgertypes f WHERE ledgerTypeCategory=typ;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_getperiodicGL` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_getperiodicGL`(

    s_date DATE,

    e_date DATE

)
BEGIN

    DECLARE base_tid BIGINT DEFAULT 2000000000;

    SET @r := 0;

    SET @c := 0;



    SELECT *

    FROM

    (

        /* =============================

           Overall Opening Balance Row

           ============================= */

        SELECT

            'OPEN BALANCE' AS accountname,

            0 AS tid,

            '-' AS accountcode,

            '-' AS account_type,

            CASE WHEN SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                               WHEN transactionType='CR' THEN -transaction_amount

                               ELSE 0 END) >= 0 THEN 'DR' ELSE 'CR' END AS transactionType,

            ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                         WHEN transactionType='CR' THEN -transaction_amount

                         ELSE 0 END)) AS transaction_amount,

            'Overall Opening Balance' AS particulars,

            0 AS voucherNo,

            '' AS RefNo,

            s_date AS transactionDate,

            'SYSTEM' AS teller,

            CONCAT(s_date,' 00:00:00') AS timeLog,

            '-' AS folio,

            'OPENING' AS journal_no,

            'UGX' AS trans_currency,

            ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                         WHEN transactionType='CR' THEN -transaction_amount

                         ELSE 0 END)) AS actual_amount,

            '-' AS curr_balance,

            1 AS forex_rate,

            ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                         WHEN transactionType='CR' THEN -transaction_amount

                         ELSE 0 END)) AS ugx_amount,

            s_date AS InvoiceDate,

            0 AS sortOrder,

            '-' AS MainAccountCode,

            '-' AS subAccountName,

            '' AS Details,

            '' AS collectionLedgerType,

            '' AS subaccount_type,

            'UGX' AS base_currency

        FROM (

            SELECT

                CASE WHEN op.opBalance >= 0 THEN 'DR' ELSE 'CR' END AS transactionType,

                ABS(op.opBalance) AS transaction_amount

            FROM (

                SELECT accountcode, account_type,

                       SUM(CASE WHEN transactionDate < s_date AND transactionType='DR' THEN transaction_amount

                                WHEN transactionDate < s_date AND transactionType='CR' THEN -transaction_amount

                                ELSE 0 END) AS opBalance

                FROM fin_ledger

                GROUP BY accountcode, account_type

            ) op

        ) t1



        UNION ALL



        /* =============================

           Account Opening Balances

           ============================= */

        SELECT

            fin_GetLedgerAccountName(op.account_type, op.accountcode) AS accountname,

            base_tid + (@r := @r + 1) AS tid,

            op.accountcode,

            op.account_type,

            CASE WHEN op.opBalance >= 0 THEN 'DR' ELSE 'CR' END AS transactionType,

            ABS(op.opBalance) AS transaction_amount,

            'Opening Balance' AS particulars,

            0 AS voucherNo,

            '' AS RefNo,

            s_date AS transactionDate,

            'SYSTEM' AS teller,

            CONCAT(s_date,' 00:00:00') AS timeLog,

            '-' AS folio,

            'OPENING' AS journal_no,

            'UGX' AS trans_currency,

            ABS(op.opBalance) AS actual_amount,

            '-' AS curr_balance,

            1 AS forex_rate,

            ABS(op.opBalance) AS ugx_amount,

            s_date AS InvoiceDate,

            1 AS sortOrder,

            sa.MainAccountCode,

            sa.AccountName AS subAccountName,

            sa.Details,

            sa.collectionLedgerType,

            sa.accounttype AS subaccount_type,

            sa.base_currency

        FROM (

            SELECT accountcode, account_type,

                   SUM(CASE WHEN transactionDate < s_date AND transactionType='DR' THEN transaction_amount

                            WHEN transactionDate < s_date AND transactionType='CR' THEN -transaction_amount

                            ELSE 0 END) AS opBalance

            FROM fin_ledger

            GROUP BY accountcode, account_type

        ) op

        LEFT JOIN fin_subaccounts sa ON sa.AccountCode = op.accountcode



        UNION ALL



        /* =============================

           Period Transactions

           ============================= */

        SELECT

            fin_GetLedgerAccountName(l.account_type,l.accountcode) AS accountname,

            l.tid,

            l.accountcode,

            l.account_type,

            l.transactionType,

            l.transaction_amount,

            l.particulars,

            l.voucherNo,

            l.RefNo,

            l.transactionDate,

            l.teller,

            l.timeLog,

            l.folio,

            l.journal_no,

            l.trans_currency,

            l.actual_amount,

            l.curr_balance,

            l.forex_rate,

            l.ugx_amount,

            l.InvoiceDate,

            2 AS sortOrder,

            sa.MainAccountCode,

            sa.AccountName AS subAccountName,

            sa.Details,

            sa.collectionLedgerType,

            sa.accounttype AS subaccount_type,

            sa.base_currency

        FROM fin_ledger l

        LEFT JOIN fin_subaccounts sa ON sa.AccountCode = l.accountcode

        WHERE l.transactionDate BETWEEN s_date AND e_date



        UNION ALL



        /* =============================

           Account Closing Balances

           ============================= */

        SELECT

            fin_GetLedgerAccountName(cl.account_type, cl.accountcode) AS accountname,

            base_tid + 1000000 + (@c := @c + 1) AS tid,

            cl.accountcode,

            cl.account_type,

            CASE WHEN cl.clBalance >= 0 THEN 'DR' ELSE 'CR' END AS transactionType,

            ABS(cl.clBalance) AS transaction_amount,

            'Closing Balance' AS particulars,

            0 AS voucherNo,

            '' AS RefNo,

            e_date AS transactionDate,

            'SYSTEM' AS teller,

            CONCAT(e_date,' 23:59:59') AS timeLog,

            '-' AS folio,

            'CLOSING' AS journal_no,

            'UGX' AS trans_currency,

            ABS(cl.clBalance) AS actual_amount,

            '-' AS curr_balance,

            1 AS forex_rate,

            ABS(cl.clBalance) AS ugx_amount,

            e_date AS InvoiceDate,

            3 AS sortOrder,

            sa.MainAccountCode,

            sa.AccountName AS subAccountName,

            sa.Details,

            sa.collectionLedgerType,

            sa.accounttype AS subaccount_type,

            sa.base_currency

        FROM (

            SELECT accountcode, account_type,

                   SUM(CASE WHEN transactionDate <= e_date AND transactionType='DR' THEN transaction_amount

                            WHEN transactionDate <= e_date AND transactionType='CR' THEN -transaction_amount

                            ELSE 0 END) AS clBalance

            FROM fin_ledger

            GROUP BY accountcode, account_type

        ) cl

        LEFT JOIN fin_subaccounts sa ON sa.AccountCode = cl.accountcode



        UNION ALL



        /* =============================

           Overall Closing Balance Row

           ============================= */

        SELECT

            'CLOSING BALANCE' AS accountname,

            999999999 AS tid,

            '-' AS accountcode,

            '-' AS account_type,

            CASE WHEN SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                               WHEN transactionType='CR' THEN -transaction_amount

                               ELSE 0 END) >= 0 THEN 'DR' ELSE 'CR' END AS transactionType,

            ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                         WHEN transactionType='CR' THEN -transaction_amount

                         ELSE 0 END)) AS transaction_amount,

            'Overall Closing Balance' AS particulars,

            0 AS voucherNo,

            '' AS RefNo,

            e_date AS transactionDate,

            'SYSTEM' AS teller,

            CONCAT(e_date,' 23:59:59') AS timeLog,

            '-' AS folio,

            'CLOSING' AS journal_no,

            'UGX' AS trans_currency,

            ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                         WHEN transactionType='CR' THEN -transaction_amount

                         ELSE 0 END)) AS actual_amount,

            '-' AS curr_balance,

            1 AS forex_rate,

            ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount

                         WHEN transactionType='CR' THEN -transaction_amount

                         ELSE 0 END)) AS ugx_amount,

            e_date AS InvoiceDate,

            4 AS sortOrder,

            '-' AS MainAccountCode,

            '-' AS subAccountName,

            '' AS Details,

            '' AS collectionLedgerType,

            '' AS subaccount_type,

            'UGX' AS base_currency

        FROM (

            SELECT

                CASE WHEN op.opBalance >= 0 THEN 'DR' ELSE 'CR' END AS transactionType,

                ABS(op.opBalance) AS transaction_amount

            FROM (

                SELECT accountcode, account_type,

                       SUM(CASE WHEN transactionDate <= e_date AND transactionType='DR' THEN transaction_amount

                                WHEN transactionDate <= e_date AND transactionType='CR' THEN -transaction_amount

                                ELSE 0 END) AS opBalance

                FROM fin_ledger

                GROUP BY accountcode, account_type

            ) op

            UNION ALL

            SELECT transactionType, transaction_amount

            FROM fin_ledger

        ) t_final



    ) AS final_gl

    ORDER BY

        CASE WHEN tid = 999999999 THEN 1 ELSE 0 END,

        COALESCE(MainAccountCode, accountcode),

        COALESCE(fin_GetLedgerAccountName(account_type, accountcode), accountcode),

        COALESCE(subAccountName, accountcode),

        sortOrder,

        tid;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetPeriodicJournals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetPeriodicJournals`(startDate DATE, endDate DATE, typ CHAR(15))
BEGIN



IF typ='ALL' THEN

SET typ='%';

END IF;



SELECT * FROM fin_journalnumbers WHERE journalDate BETWEEN startDate AND endDate AND journalType LIKE typ ORDER BY JournalNo DESC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetPeriodicVouchers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetPeriodicVouchers`(startDate DATE, endDate DATE, typ CHAR(25))
BEGIN





SELECT fin_receiptVoucherSummary(voucherno) AS summary,vn.* FROM fin_vouchernumbers vn WHERE voucherDate BETWEEN startDate AND endDate AND vouchertype=typ

ORDER BY voucherNo DESC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetProductMembers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetProductMembers`(prodID INT)
BEGIN



SELECT mem_GetDataByID(memberID,'Name') AS member_name,'-'AS productname,mp.* FROM  fin_memberproducts mp

WHERE mp.productid=prodID ORDER BY memberID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetProgrammeFee` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetProgrammeFee`(
  IN p_progcode CHAR(25),
  IN p_study_year INT,
  IN p_semester INT,
  OUT p_tuition DOUBLE,
  OUT p_functional DOUBLE
)
BEGIN
  SET p_tuition = 0;
  SET p_functional = 0;

  IF p_study_year = 1 AND p_semester = 1 THEN
    SELECT y1_s1_tuition, y1_s1_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 1 AND p_semester = 2 THEN
    SELECT y1_s2_tuition, y1_s2_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 1 AND p_semester = 3 THEN
    SELECT y1_s3_tuition, y1_s3_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 2 AND p_semester = 1 THEN
    SELECT y2_s1_tuition, y2_s1_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 2 AND p_semester = 2 THEN
    SELECT y2_s2_tuition, y2_s2_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 2 AND p_semester = 3 THEN
    SELECT y2_s3_tuition, y2_s3_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 3 AND p_semester = 1 THEN
    SELECT y3_s1_tuition, y3_s1_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 3 AND p_semester = 2 THEN
    SELECT y3_s2_tuition, y3_s2_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  ELSEIF p_study_year = 3 AND p_semester = 3 THEN
    SELECT y3_s3_tuition, y3_s3_functional INTO p_tuition, p_functional
    FROM fin_programme_fees WHERE progcode = p_progcode AND is_active = 'Yes' LIMIT 1;
  END IF;

  
  SET p_tuition = COALESCE(p_tuition, 0);
  SET p_functional = COALESCE(p_functional, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetRecoLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetRecoLedger`(accno CHAR(45) charset utf8,sDate DATE,eDate DATE, typ CHAR(65) charset utf8,

cat CHAR(15) charset utf8)
BEGIN



DECLARE CR_OP_Balance,DR_OP_Balance,clBalance,CR_CL_Balance,DR_CL_Balance,accName,TotalCR,totalDR CHAR(200) charset utf8;

DECLARE opBalance,closingBalance,last_jno CHAR(45) charset utf8;

DECLARE bal,Total_CR,total_DR DOUBLE;



SET accName = CONCAT(UPPER(fin_GetLedgerAccountName(typ,accno)),' [',accno,']');

SET @initial_amt=NULL;



IF typ='Student' THEN

SET typ='Student';

END IF;







SELECT LPAD(journal_no-1,5,0) INTO last_jno FROM

(SELECT journal_no,particulars  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ AND transactiondate BETWEEN sDate AND eDate

ORDER BY TID,transactiondate DESC) AS trans LIMIT 1;



SELECT curr_balance INTO opBalance FROM fin_ledger WHERE accountcode=accno AND journal_no=last_jno;

SELECT curr_balance INTO closingBalance FROM fin_ledger WHERE accountcode=accno AND transactiondate<=eDate ORDER BY journal_no DESC LIMIT 1;



SELECT FORMAT(SUM(transaction_amount),0) INTO TotalCR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='CR';



SELECT FORMAT(SUM(transaction_amount),0) INTO TotalDR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='DR';









IF opBalance LIKE '%DR' THEN



SET DR_OP_Balance=opBalance;

SET CR_OP_Balance='';



ELSE



SET CR_OP_Balance=opBalance;

SET DR_OP_Balance='';



END IF;



IF closingBalance LIKE '%CR' THEN



SET DR_CL_Balance=closingBalance;

SET CR_CL_Balance='';



ELSE



SET CR_CL_Balance=closingBalance;

SET DR_CL_Balance='';



END IF;





IF fin_GetAccountCategory(accno) IN ('Income','Expense') THEN



SELECT SUM(transaction_amount) INTO Total_CR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='CR';



SELECT SUM(transaction_amount) INTO Total_DR  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ

AND transactiondate BETWEEN sDate AND eDate AND transactionType='DR';



SET bal=(Total_CR-total_DR);



IF bal<0 THEN



SET DR_CL_Balance=CONCAT(FORMAT(ABS(bal),0),'DR');

SET CR_CL_Balance='';



ELSE



SET CR_CL_Balance=CONCAT(FORMAT(ABS(bal),0),'CR');

SET DR_CL_Balance='';



END IF;



END IF;



IF cat='ALL' THEN



SELECT voucherno,accName,sDate,eDate,journal_no AS jnumber,

trans.* FROM

(SELECT TID,DATE_FORMAT(transactiondate,'%d/%m/%Y') AS transactiondate,teller,account_type,

IF(fin_GetAccountCategory(accno) IN ('Income','Expense'),

fin_GetIncomeRuningBalance(transaction_amount,transactionType),curr_balance) AS curr_balance,accountcode,journal_no,

IF(transactiontype='CR',FORMAT(transaction_amount,0),'') AS cramount,

IF(transactiontype='DR',FORMAT(transaction_amount,0),'') AS dramount,voucherno,

particulars,trans_currency  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ AND transactiondate BETWEEN sDate AND eDate

 ORDER BY TID DESC) AS trans;



ELSEIF cat='Pending' THEN



SELECT voucherno,accName,sDate,eDate,journal_no AS jnumber,

trans.* FROM

(SELECT TID,DATE_FORMAT(transactiondate,'%d/%m/%Y') AS transactiondate,teller,account_type,

IF(fin_GetAccountCategory(accno) IN ('Income','Expense'),

fin_GetIncomeRuningBalance(transaction_amount,transactionType),curr_balance) AS curr_balance,accountcode,journal_no,

IF(transactiontype='CR',FORMAT(transaction_amount,0),'') AS cramount,

IF(transactiontype='DR',FORMAT(transaction_amount,0),'') AS dramount,voucherno,

particulars,trans_currency  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ AND transactiondate BETWEEN sDate AND eDate

AND TID NOT IN (SELECT match_TID FROM fin_reco_bank_entries)  ORDER BY TID DESC) AS trans;



ELSE



SELECT voucherno,accName,sDate,eDate,journal_no AS jnumber,

trans.* FROM

(SELECT TID,DATE_FORMAT(transactiondate,'%d/%m/%Y') AS transactiondate,teller,account_type,

IF(fin_GetAccountCategory(accno) IN ('Income','Expense'),

fin_GetIncomeRuningBalance(transaction_amount,transactionType),curr_balance) AS curr_balance,accountcode,journal_no,

IF(transactiontype='CR',FORMAT(transaction_amount,0),'') AS cramount,

IF(transactiontype='DR',FORMAT(transaction_amount,0),'') AS dramount,voucherno,

particulars,trans_currency  FROM fin_ledger f WHERE accountcode=accno AND account_type=typ AND transactiondate BETWEEN sDate AND eDate

AND TID IN (SELECT match_TID FROM fin_reco_bank_entries)  ORDER BY TID DESC) AS trans;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetReconciliationStatement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetReconciliationStatement`(RID INT,bankcode CHAR(25))
BEGIN

DECLARE s_balance,ledger_balance DOUBLE;

DECLARE reco_date DATE;



SELECT statement_balance,rec_date INTO s_balance,reco_date FROM fin_reconciliationstatement WHERE ID=RID;

SET ledger_balance=fin_GetPeriodBalance(reco_date,reco_date,bankcode,'Opening');



SELECT reco_date,'SUMMARY' AS category, ' Cashbook Ledger Balance' AS adj_account, '-' trans_type, RID AS recoID, bankcode AS bank_code, ledger_balance AS amount,

' ' AS particulars fROM DUAL



UNION ALL



SELECT reco_date,'SUMMARY' AS category, adj_account, trans_type, recoID, bank_code, SUM(amount) AS amount,CONCAT('')AS particulars

FROM fin_reco_adjustments WHERE recoID=RID GROUP BY adj_account



UNION ALL



SELECT reco_date,UPPER(CONCAT(trans_type,' DETAILS')) AS category, adj_account, trans_type, recoID, bank_code, amount, particulars FROM fin_reco_adjustments

 WHERE recoID=RID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetSchoolPayList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetSchoolPayList`(yr INT)
BEGIN



SELECT substring_index(stud_name,' ',1) as last_name,

replace(stud_name,substring_index(stud_name,' ',1),'') as first_name,'' as middlename,stud_birthdate,stud_reg_no,stud_sex,stud_email,stud_phone,

stud_nationality,'-' AS disability,'-' as disability_form,stud_parent,'Parent' as guardian_relation,'-' As guuardian_email,'-' as guardian_phone

from erp.student WHERE stud_entry_year=yr;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetSelectedAccounts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetSelectedAccounts`(acctype CHAR(25))
BEGIN



SELECT s.* FROM fin_subaccounts s, fin_mainaccounts m

WHERE m.accountcode=s.mainaccountcode AND m.accountname LIKE CONCAT('%',acctype,'%');



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetSingleReceipt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetSingleReceipt`(VNO int)
BEGIN

  DECLARE bankName VARCHAR(250);

  DECLARE yr,trm INT;



  SELECT year,term INTO yr,trm FROM schoolmis.class_manager WHERE adm_no=

  (SELECT accountcode FROM fin_voucher WHERE voucherno=VNO AND transactionType='CR')

  ORDER BY classID DESC LIMIT 1;



  SELECT fin_GetVoucherAccountNames(account_type,accountcode) INTO bankName

  FROM fin_voucher v WHERE voucherno=VNO AND transactionType='DR';



  SELECT fin_GetVoucherAccountNames(account_type,accountcode) as accountname,bankName,

  FORMAT(fin_GetFeesBalance('Current',yr,trm,accountcode),0) AS balance,

  v.* FROM fin_voucher v WHERE voucherno=VNO AND transactionType='CR';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetSingleTransactionDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetSingleTransactionDetails`(Vno INT)
BEGIN



SELECT fin_GetLedgerAccountName(account_type,accountcode) AS accountname, l.* FROM fin_ledger l WHERE voucherno=Vno ORDER BY TID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetSingleVoucher` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetSingleVoucher`(VNO int)
BEGIN

  DECLARE bankName VARCHAR(250);



  SELECT fin_GetLedgerAccountName(account_type,accountcode) INTO bankName

  FROM fin_journal_details WHERE journal_no=VNO AND transactionType='CR' LIMIT 1;



  SELECT fin_GetLedgerAccountName(account_type,accountcode) as accountname,bankName,

  v.* FROM fin_journal_details v WHERE journal_no=VNO AND transactionType='DR';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetStudentAccount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetStudentAccount`(txt CHAR(25), trm INT, yr INT)
BEGIN



IF txt LIKE 'Chart Account' THEN

SELECT accountCode,accountName,details FROM fin_subaccounts WHERE accounttype='Basic Account';

ELSE

SET txt=CONCAT('%',txt,'%');



SELECT adm_no AS accountCode,stud_names AS accountName,fin_GetStudyDetails(adm_no,yr,trm) AS details FROM schoolmis.student

WHERE stud_names LIKE txt LIMIT 300;

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetStudentAccountsList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_GetStudentAccountsList`(cr_date DATE,prog CHAR(25))
BEGIN



IF prog='-' THEN

SET prog='%';

END IF;



SELECT id,name,IF(othername='-',firstname,CONCAT(firstname,' ',othername)) AS stud_name,m.lastActivityDate,IsLockedOut,LastLoginDate,

studphone,s.email

FROM campus_dynamics_portal.my_aspnet_users u,campus_dynamics_portal.my_aspnet_membership m,campus_dynamics.acad_student s

WHERE m.userId=u.id  AND name=regno AND DATE(CreationDate)>cr_date AND progid LIKE prog ORDER BY firstname;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetStudentFeesSchedule` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetStudentFeesSchedule`(reg CHAR(25) CHARSET utf8)
BEGIN
DECLARE nation,eyr,prog,sess,curr,bid CHAR(45)  CHARSET utf8;
DECLARE other_fees TEXT;
DECLARE c_rate DOUBLE DEFAULT 1;

SELECT nationality,entryyear,progid,studsesion,billingID INTO nation,eyr,prog,sess,bid FROM campus_dynamics.acad_student WHERE regno=reg;
IF nation IS NULL THEN
  SELECT stud_nationality,stud_entry_year,billingID INTO nation,eyr,bid FROM campus_dynamics.acad_applications WHERE stud_entry_no=reg;
  SELECT prog_id,adm_session INTO prog,sess FROM campus_dynamics.acad_applicant_choices WHERE stud_entry_no=reg AND choice=1;
END IF;

SELECT bs_currency INTO curr FROM fin_billing_systems WHERE ID=bid;


SELECT curr,bid,itemName, ID, ItemID, studyyear, semester, CEILING((amount)) AS amount,curr, curr_year, progid, stud_session,'-' AS other_fees
FROM fin_fees_pay_schedule s,
academicbillingitems i WHERE progid=prog AND stud_session=sess AND curr_year=eyr AND s.billingID=bid AND i.itemcode=ItemID ORDER BY studyyear,semester;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetStudentFeesStructure` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_GetStudentFeesStructure`(reg CHAR(25),cyr INT,sem INT,yr INT)
BEGIN



DECLARE prog,sess,ink CHAR(45);

SELECT progid,studsesion,intake INTO prog,sess,ink FROM campus_dynamics.acad_student WHERE regno=reg;



SELECT ItemName,fs.*

FROM fin_fees_structure fs, academicbillingitems bi WHERE fs.ItemCode=bi.ItemCode AND

progid=prog AND curr_year=yr AND study_year=cyr AND semester=sem

AND studsession=sess AND amount>0 AND studIntake=ink ORDER BY ItemName;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetStudentFeesTrackList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetStudentFeesTrackList`(prog CHAR(25),sess CHAR(25), acad CHAR(25), sem INT, yr INT, stat CHAR(15),

sDate DATE, eDate DATE)
BEGIN



SET prog=IF(prog='-','%',prog);



IF stat='Completed' THEN



SELECT  ID,sDate,eDate, entryno,r.regno, semester, acad_year,studyyear, CONCAT(othername,' ',firstname) AS stud_names,

'FULL FEES PAYMENT' AS feesStat,SYSDATE() AS ReportDate,

residence_status AS residence,fin_GetFeesBalance('Opening',sDate,eDate,r.regno) AS opBal,fin_GetBillItems(r.regno,acad,sem) AS billItems,

fin_GetFeesBalance('TotalBill',sDate,eDate,r.regno) AS TotalDR,fin_GetFeesBalance('TotalPay',sDate,eDate,r.regno) AS TotalCR,

fin_GetFeesBalance('Current',sDate,eDate,r.regno) AS CurBal,

campus_dynamics.acad_GetProgNameByCode(progid) AS progname, studsesion,regstatus FROM campus_dynamics.acad_registration r JOIN

campus_dynamics.acad_student s ON s.regno=r.regno WHERE progid LIKE prog AND studsesion=sess AND acad_year=acad AND semester=sem AND studyyear=yr AND

fin_GetFeesBalance('Current',sDate,eDate,r.regno)<=0 AND fin_BillCounter(r.regno,sem,acad)>0 ORDER BY CONCAT(othername,' ',firstname);



ELSEIF stat='Pending' THEN



SELECT  ID,sDate,eDate, entryno,r.regno, semester, acad_year,studyyear,CONCAT(othername,' ',firstname) AS stud_names,

'PENDING FEES PAYMENT' AS feesStat,SYSDATE() AS ReportDate,

residence_status AS residence,fin_GetFeesBalance('Opening',sDate,eDate,r.regno) AS opBal,fin_GetBillItems(r.regno,acad,sem) AS billItems,

fin_GetFeesBalance('TotalBill',sDate,eDate,r.regno) AS TotalDR,fin_GetFeesBalance('TotalPay',sDate,eDate,r.regno) AS TotalCR,

fin_GetFeesBalance('Current',sDate,eDate,r.regno) AS CurBal,

campus_dynamics.acad_GetProgNameByCode(progid) AS progname, studsesion,regstatus FROM campus_dynamics.acad_registration r JOIN

campus_dynamics.acad_student s ON s.regno=r.regno WHERE progid LIKE prog AND studsesion=sess AND acad_year=acad AND semester=sem AND studyyear=yr AND

(fin_GetFeesBalance('Current',sDate,eDate,r.regno)>=0 OR fin_BillCounter(r.regno,sem,acad)=0) ORDER BY CONCAT(othername,' ',firstname);



ELSE



SELECT  ID,sDate,eDate, entryno,r.regno, semester, acad_year,studyyear,CONCAT(othername,' ',firstname) AS stud_names,

'ALL FEES PAYMENT' AS feesStat,SYSDATE() AS ReportDate,

residence_status AS residence,fin_GetFeesBalance('Opening',sDate,eDate,r.regno) AS opBal,fin_GetBillItems(r.regno,acad,sem) AS billItems,

fin_GetFeesBalance('TotalBill',sDate,eDate,r.regno) AS TotalDR,fin_GetFeesBalance('TotalPay',sDate,eDate,r.regno) AS TotalCR,

fin_GetFeesBalance('Current',sDate,eDate,r.regno) AS CurBal,

campus_dynamics.acad_GetProgNameByCode(progid) AS progname, studsesion,regstatus FROM campus_dynamics.acad_registration r JOIN

campus_dynamics.acad_student s ON s.regno=r.regno WHERE progid LIKE prog AND studsesion=sess AND acad_year=acad AND semester=sem AND studyyear=yr

 ORDER BY CONCAT(othername,' ',firstname);



END IF;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetStudentLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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
                      AND (t.trans_type IN ('Payment','Waiver') OR fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')
                    )
              )
       )
    ORDER BY TID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetStudentsByScholarship` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetStudentsByScholarship`(sid INT, yr CHAR(25), trm INT)
BEGIN

DECLARE scholarshipNm VARCHAR(200);

SELECT UPPER(scholarshipName) INTO scholarshipNm FROM scholarships WHERE scholarshipID=sid;

SELECT campus_dynamics.acad_GetStudNameByID(adm_no) AS stud_name,scholarshipNm AS scholarshipName,

fin_GetStudyDetails(adm_no) AS studyDetails,

s.* FROM scholarshipstudents s

 WHERE scholarshipID=sid AND scholarhipYear=yr AND scholarhipTerm=trm;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetSummaryStatements` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetSummaryStatements`(memNo CHAR(25), eDate DATE, usr CHAR(25))
BEGIN

  DECLARE memName CHAR(65);

  DECLARE entryDate DATE;

  DECLARE statementNotes TEXT;

  SELECT surname,joiningDate INTO memName,entryDate FROM mem_membership WHERE memberno=memNo;

  SELECT notes INTO statementNotes FROM fin_statementnotes;



  SELECT usr,memNo,memName,eDate,entryDate,'A' as category,'FUNDS RECEIVED' as categoryheader,statementNotes, account_type,sum(transaction_amount) as amount FROM fin_ledger f where accountcode=memNo

  AND transactionDate<=eDate

  AND transactiontype='CR' AND account_type NOT IN ('Dividends','Interest')

  GROUP BY account_type,transactiontype



  UNION



  SELECT usr,memNo,memName,eDate,entryDate,'B' as category,'OUTSTANDING' as categoryheader,statementNotes,  account_type,fin_GetMemberOutstandings(accountcode,account_type,eDate) as amount

  FROM fin_ledger f where accountcode=memNo

  AND transactionDate<=eDate AND transactiontype='DR'

  AND fin_GetMemberOutstandings(accountcode,account_type,eDate)>0

  group by account_type,transactiontype



  UNION



  SELECT usr,memNo,memName,eDate,entryDate,'C' as category,'INCOMES EARNED' as categoryheader,statementNotes,  account_type,sum(transaction_amount) as amount FROM fin_ledger f where accountcode=memNo

  AND transactionDate<=eDate   AND transactiontype='CR' AND account_type IN ('Dividends','Interest')

  GROUP BY account_type,transactiontype



  UNION



  SELECT usr,memNo,memName,eDate,entryDate,'D' as category,'TOTAL' as categoryheader,statementNotes,  'Total Value',sum(transaction_amount) as amount FROM fin_ledger f where accountcode=memNo

  AND transactionDate<=eDate AND transactiontype='CR' AND account_type NOT IN ('Membership Fees');

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetVoucherStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetVoucherStatus`(VNO INT)
BEGIN



SELECT postStatus FROM fin_vouchernumbers WHERE voucherno=VNO;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_GetVoucherTransactions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_GetVoucherTransactions`(VNo INT)
BEGIN



SELECT fin_GetVoucherAccountNames(account_type,accountcode) AS accountname,j.* FROM fin_voucher j WHERE voucherNo=VNo

ORDER BY TID DESC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_IncomeStatement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_IncomeStatement`(sDate DATE, eDate DATE)
BEGIN



DECLARE surplus BIGINT;

SET surplus=fin_GetSurplusDeficit(sDate);





SELECT 'INCOME STATEMENT' AS docHeader,'REVENUE' header,DATE_FORMAT(sDate,'%d/%m/%Y') AS startDate,DATE_FORMAT(eDate,'%d/%m/%Y') endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'INCOME STATEMENT' AS docHeader,'',DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,

FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory='Income')

AS findata



UNION



SELECT 'INCOME STATEMENT' AS docHeader,'TOTAL REVENUE','','','','',fin_IncomeTotals('DR',sDate,eDate) AS DRTotal,

fin_IncomeTotals('CR',sDate,eDate) AS CRTotal FROM DUAL



UNION





SELECT 'INCOME STATEMENT' AS docHeader,'EXPENSES' header,'' startDate,'' endDate,'' accountcode,'' accountname,

'' DRBalance,'' CRBalance FROM DUAL



UNION



SELECT 'INCOME STATEMENT' AS docHeader,'',DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,

FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT sa.accountcode,sa.accountname, fin_GetPeriodBalance(sDate,eDate,sa.accountcode,'Period') AS balance

FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON sa.mainaccountcode=ma.accountcode WHERE GeneralCategory='Expense')

AS findata



UNION



SELECT 'INCOME STATEMENT' AS docHeader,'TOTAL EXPENSES','','','','',fin_ExpenseTotals('DR',sDate,eDate) AS DRTotal,

fin_ExpenseTotals('CR',sDate,eDate) AS CRTotal FROM DUAL



UNION



SELECT 'INCOME STATEMENT' AS docHeader,'OPERATING INCOME','','','','',fin_OperatingIncome('DR',sDate,eDate) AS DRTotal,

fin_OperatingIncome('CR',sDate,eDate) AS CRTotal FROM DUAL



UNION



SELECT 'INCOME STATEMENT' AS docHeader,'NET INCOME','','','','',fin_OperatingIncome('DR',sDate,eDate) AS DRTotal,

fin_OperatingIncome('CR',sDate,eDate) AS CRTotal FROM DUAL;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_LedgerCategoryEditor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_LedgerCategoryEditor`(LedgerTypeID INT, LedgerTypeName CHAR(45), LedgerTypeCategory CHAR(45))
BEGIN



INSERT INTO fin_ledgertypes(LedgerTypeID, LedgerTypeName, LedgerTypeCategory)

VALUES(LedgerTypeID, LedgerTypeName, LedgerTypeCategory) ON DUPLICATE KEY UPDATE LedgerTypeName=LedgerTypeName, LedgerTypeCategory=LedgerTypeCategory;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ManualClearance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ManualClearance`(cat CHAR(25), reg CHAR(35), acad CHAR(15), sem INT, usr CHAR(25))
BEGIN



IF cat='Examination' THEN



  UPDATE campus_dynamics.acad_registration SET examClearance=IF(examClearance='CLEARED','PRINTED','CLEARED'),examClearanceDate=SYSDATE(),clearedBy=usr

  WHERE regno=reg AND acad_year=acad AND semester=sem;



  INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

  VALUES (usr,'Exam Clearance',CONCAT('REG NO: ',reg,', ACAD: ',acad,', SEM: ',sem),'Manual Exam Clearance',SYSDATE());



ELSE



  UPDATE campus_dynamics.acad_registration SET regstatus='CLEARED' WHERE regno=reg AND acad_year=acad AND semester=sem;



  INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

  VALUES (usr,'Registration Clearance',CONCAT('REG NO: ',reg,', ACAD: ',acad,', SEM: ',sem),'Manual Registration Clearance',SYSDATE());



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_MonthlyPayment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_MonthlyPayment`(usr CHAR(25),memID CHAR(25), mnth CHAR(25),yr INT, amount INT,

bankAccount CHAR(15), TDate DATE, prodID INT)
BEGIN



DECLARE subscriptAccount,acctype,paycheck,prod_name,custLedger CHAR(65);

DECLARE vno INT;

SET vno=fin_NextVoucherNo();

SELECT paymentMethod INTO bankAccount FROM mem_membership WHERE memberno=memID;

SELECT collectionLedgertype INTO acctype FROM fin_subaccounts s WHERE accountcode=bankAccount;

SELECT productName,customerLedgerType INTO prod_name,custLedger FROM fin_products WHERE productID=prodID;



START TRANSACTION;



  UPDATE fin_subscription SET PayStatus='Paid',datePaid=TDate  WHERE memberID=memID AND productID=prodID AND sub_month=mnth

  AND sub_year=yr;

  SELECT fin_transactioncreatorFn

  (memID,custLedger,CONCAT('Payment of ',prod_name, ' for the month of ',mnth,', ',yr),

  bankAccount,acctype,CONCAT(prod_name,' payment for ',surname,' For ',mnth,', ',yr),amount,vno,TDate,usr) FROM

  mem_membership WHERE memberno=memID;

COMMIT;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_MonthlyReconciliation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_MonthlyReconciliation`(

    IN p_year  CHAR(4),

    IN p_month CHAR(2)

)
BEGIN

    -- Summary by main account category

    SELECT

        COALESCE(m.AccountName, 'Unknown')       AS account_category,

        s.AccountCode                             AS sub_account,

        s.AccountName                             AS sub_account_name,

        SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END) AS total_dr,

        SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END) AS total_cr,

        SUM(CASE WHEN l.transactionType = 'DR' THEN l.transaction_amount ELSE 0 END)

        - SUM(CASE WHEN l.transactionType = 'CR' THEN l.transaction_amount ELSE 0 END) AS net_balance,

        COUNT(DISTINCT l.voucherNo)               AS voucher_count,

        COUNT(*)                                   AS line_count

    FROM fin_ledger l

    JOIN fin_journalnumbers j  ON j.JournalNo = l.voucherNo

    LEFT JOIN fin_subaccounts s ON s.AccountCode = l.accountcode

    LEFT JOIN fin_mainaccounts m ON m.AccountCode = s.MainAccountCode

    WHERE j.PostStatus = 'Posted'

      AND YEAR(l.transactionDate)  = p_year

      AND MONTH(l.transactionDate) = p_month

    GROUP BY m.AccountName, s.AccountCode, s.AccountName

    ORDER BY m.AccountName, s.AccountCode;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_OpeningBalanceEntry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_OpeningBalanceEntry`(accountcode CHAR(25),accountType CHAR(25), Particulars VARCHAR(350),

 amount DOUBLE, transactionDate DATE, teller CHAR(25),curr CHAR(25))
BEGIN



DECLARE vNo INT;

DECLARE T_Type CHAR(2);



SET T_Type=if(amount<0,'DR','CR');

SET vNo=fin_NextVoucherNo(teller);



INSERT INTO fin_ledger(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate,

 teller, timeLog, folio, journal_no, trans_currency, actual_amount, curr_balance)

VALUES(accountcode,accountType,T_Type,abs(amount),Particulars,vNo,transactionDate,teller,SYSDATE(),'OP Balance',0,curr,abs(amount),'-');







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_payrollPosting` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_payrollPosting`(PostCategory CHAR(25),Teller CHAR(15),Tdate DATE, itemCode INT)
BEGIN





DECLARE acadGrossWage,adminGrossWage,SupportGrossWage,PostAmount,NSSF_Payable,NSSF_EmpContrib BIGINT;

DECLARE empID,empName,postLedgerCat,postAccount VARCHAR(150);

DECLARE catID,done,vNo,chkValue INT;





DECLARE salaryPosting CURSOR FOR

SELECT empCode,hurmis.get_netpay(Yrs,months,empCode) FROM hurmis.payroll_payment

WHERE currYear=Yrs AND currMonth=months AND fin_GetPayrollPostStatus('Salary',Yrs,months)=0;



IF PostCategory='Deductions' THEN



SET chkValue = fin_GetPayrollPostStatus('Deductions',Yrs,months);





IF chkValue=0 THEN 











SET NSSF_Payable=fin_GetNSSFSummaries(Yrs,months,'Payable');

SET NSSF_EmpContrib=fin_GetNSSFSummaries(Yrs,months,'EmpCont');











END IF;



INSERT INTO fin_payrollpostrecords(postItem,postYear,postMonth) VALUES ('Deductions',Yrs,months);





END IF;





IF PostCategory='Salary' THEN



SET done=0;



SET chkValue = fin_GetPayrollPostStatus('Salary',Yrs,months);



IF chkValue=0 THEN









INSERT INTO fin_payrollpostrecords(postItem,postYear,postMonth) VALUES ('Salary',Yrs,months);



END IF;



END IF;



CALL fin_BalanceUpdates();



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_PrintChartOfAccounts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_PrintChartOfAccounts`()
BEGIN
SELECT m.AccountName AS MainAccountName,GeneralCategory,SubCategory, s.* FROM fin_mainaccounts m,fin_subaccounts s WHERE m.AccountCode=s.mainAccountCode;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_PrintReceipt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_PrintReceipt`(Vno INT)
BEGIN



DECLARE bank_name,stud_name,stud_balance VARCHAR(250);



SELECT CONCAT(fin_GetLedgerAccountName(account_type,accountcode),' [',accountcode,']'),curr_balance INTO stud_name,stud_balance FROM fin_ledger WHERE voucherno=Vno AND transactionType='CR' LIMIT 1;

SELECT fin_GetLedgerAccountName(account_type,accountcode) AS  bank_name,stud_name,stud_balance,l.* FROM fin_ledger l

WHERE voucherno=Vno AND transactionType='DR' LIMIT 1;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ReceiptRemover` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ReceiptRemover`(vno INT, usr CHAR(25))
BEGIN

DECLARE v_amount DOUBLE;

DECLARE admno,curClass,curStream CHAR(35);

DECLARE TN INT;



SELECT accountcode,transaction_amount INTO admno,v_amount FROM fin_voucher WHERE voucherNo=vno AND transactionType='CR';

SELECT TID INTO TN FROM fin_studentfeestracking

WHERE adm_no=admno AND T_Type='Payment' AND T_Amount=v_amount ORDER BY TID DESC LIMIT 1;



START TRANSACTION;



-- Reset SchoolPay status if this receipt came from SchoolPay

UPDATE fin_schoolpaydata 

SET captureStatus = 'Pending' 

WHERE ReceiptNo IN (

  SELECT REPLACE(folio, 'TransCode:', '') 

  FROM fin_ledger 

  WHERE folio LIKE 'TransCode:%' 

  AND voucherNo = vno

);



DELETE FROM fin_vouchernumbers WHERE voucherNo=vno;

DELETE FROM fin_ledger WHERE folio=CONCAT('Voucher No',vno);

DELETE FROM fin_studentfeestracking WHERE TID=TN;

INSERT INTO acc_activity_log(user_id,page_function,par,comments)

VALUES(usr,'Receipt Mgt',CONCAT('ReceiptNo:',vno,' ',fin_receiptvouchersummary(vno)),'Deleted Receipt');

COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_RegisterMemberProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_RegisterMemberProduct`(memberID INT, productID INT, amount BIGINT, Details CHAR(45))
BEGIN



INSERT INTO fin_memberproducts(memberID, productID, amount, Details) VALUES (memberID, productID, amount, Details)

ON DUPLICATE KEY UPDATE productID=productID,amount=amount, details=Details; 



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_RenewBursary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_RenewBursary`(sid INT, trm INT, yr INT, admno CHAR(25), usr CHAR(25))
BEGIN



DECLARE new_term,new_year INT;

IF trm=3 THEN

SET new_term=1;

SET new_year=yr+1;

ELSE

SET new_term=trm+1;

SET new_year=yr;

END IF;



INSERT INTO scholarshipstudents(adm_no,scholarshipID,scholarhipTerm,scholarhipYear)

SELECT adm_no,scholarshipID,new_term,new_year FROM scholarshipstudents WHERE adm_no=admno AND scholarshipID=sid AND scholarhipYear=yr AND scholarhipTerm=trm;



INSERT INTO acc_activity_log(user_id, page_function, par, comments, access_date) VALUES (usr,'Fees Management',

CONCAT('Stud No=',admno,', Term=',trm,', Year=',yr),'Extended Scholarship',SYSDATE());



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ReportTBReconciliationCheck` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_ReportTBReconciliationCheck`(

    IN p_start_date DATE,

    IN p_end_date DATE

)
BEGIN

    DECLARE v_tb_cash_dr DECIMAL(20,2) DEFAULT 0;

    DECLARE v_tb_cash_cr DECIMAL(20,2) DEFAULT 0;

    DECLARE v_tb_net_dr DECIMAL(20,2) DEFAULT 0;

    DECLARE v_tb_net_cr DECIMAL(20,2) DEFAULT 0;



    CALL fin_BuildReportTBBalances(p_start_date, p_end_date);



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0),

           COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0)

      INTO v_tb_cash_dr, v_tb_cash_cr

    FROM tmp_mru_report_tb_balances b

    WHERE EXISTS (SELECT 1 FROM fin_sfp_mapping m WHERE m.IsActive = 1 AND m.LineCode = 'CASH_BANK' AND ((m.AccountScope='MAIN' AND m.AccountCode=b.MAC) OR (m.AccountScope='SUB' AND m.AccountCode=b.AccountCode)));



    SELECT COALESCE(SUM(CASE WHEN b.balance > 0 THEN b.balance ELSE 0 END),0),

           COALESCE(SUM(CASE WHEN b.balance < 0 THEN -b.balance ELSE 0 END),0)

      INTO v_tb_net_dr, v_tb_net_cr

    FROM tmp_mru_report_tb_balances b;



    SELECT 'TB cash/bank DR total = SFP Cash and bank balances' AS CheckName,

           v_tb_cash_dr AS Amount

    UNION ALL

    SELECT 'TB cash/bank CR total = SFP Bank overdrafts',

           v_tb_cash_cr

    UNION ALL

    SELECT 'TB total debit balances',

           v_tb_net_dr

    UNION ALL

    SELECT 'TB total credit balances',

           v_tb_net_cr

    UNION ALL

    SELECT 'TB debit minus credit should be zero',

           v_tb_net_dr - v_tb_net_cr;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_report_tb_balances;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_RevokeClearance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_RevokeClearance`(cat CHAR(25), reg CHAR(35), acad CHAR(15), sem INT, usr CHAR(25))
BEGIN



IF cat='Examination' THEN



  UPDATE campus_dynamics.acad_registration SET examClearance='UNCLEARED' WHERE regno=reg AND acad_year=acad AND semester=sem;

  INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

  VALUES (usr,'Exam Clearance',CONCAT('REG NO: ',reg,', ACAD: ',acad,', SEM: ',sem),'Revoked Exam Clearance',SYSDATE());



ELSE



  UPDATE campus_dynamics.acad_registration SET regstatus='UNREGISTERED' WHERE regno=reg AND acad_year=acad AND semester=sem;

  INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

  VALUES (usr,'Registration Clearance',CONCAT('REG NO: ',reg,', ACAD: ',acad,', SEM: ',sem),'Revoked Registration Clearance',SYSDATE());



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_Singlebilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_Singlebilling`(reg CHAR(35), acad CHAR(15), sems INT,usr CHAR(45),

item_code INT, amt DOUBLE)
BEGIN

DECLARE noItems,yr,cyr,noBilled,ItemID INT;

DECLARE prog,sess,regStat,resStat,Intk CHAR(25);

DECLARE done INT DEFAULT 0;



SELECT progid,studsesion,intake INTO prog,sess,Intk FROM campus_dynamics.acad_student WHERE regno=reg LIMIT 1;



SELECT regstatus,studyyear,residence_status,SUBSTRING(acad_year,6,4) INTO regStat,cyr,resStat,yr FROM campus_dynamics.acad_registration sr

WHERE regno=reg AND acad_year=acad AND semester=sems LIMIT 1;





SELECT fin_TermlyItemBillingFN('Bill',reg,item_code,sems,prog,sess,SYSDATE(),usr,cyr,acad,'-',amt) FROM DUAL;



UPDATE fin_ledger SET journal_no=fin_transactionNo(accountcode,account_type,TID) WHERE journal_no='-';





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_SingleJournalCreator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_SingleJournalCreator`(TRaccountcode CHAR(25),TRaccountType CHAR(25),

transaction_amount BIGINT,JNo INT, teller CHAR(25), TRType CHAR(2))
BEGIN

DECLARE TDate DATE;

DECLARE TParticulars TEXT;

SELECT journalDate,journalParticulars INTO TDate,TParticulars FROM fin_journalnumbers WHERE journalNo=JNo;

INSERT IGNORE INTO fin_journal(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo,

transactionDate, teller)

VALUES(TRaccountcode,TRaccountType,TRType,transaction_amount,TParticulars,JNo,TDate,teller);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_SingleSubscriptionBilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_SingleSubscriptionBilling`(yr INT, mnth CHAR(25), TDate DATE,usr CHAR(25),

prodID BIGINT, memno CHAR(25))
BEGIN

DECLARE subscriptAccount,acctype,custLedger,prodType,prodName,amtSetting CHAR(150);

DECLARE vno INT;

DECLARE amt BIGINT;



SET vno=fin_NextVoucherNo();

SELECT min_periodicpayment, chartAccount, customerLedgerType,productType,productName,amountSetting

INTO amt, subscriptAccount,custLedger,

prodType,prodName,amtSetting FROM fin_products

WHERE productID=prodID;

SET accType=fin_GetChartAccountLegderType(subscriptAccount);



IF prodType='Subscription' THEN



IF amtSetting='Standard' THEN



INSERT INTO fin_subscription(memberID, sub_month, sub_year, sub_amount, comments,productID)

SELECT memberno,mnth,yr,amt,

fin_transactioncreatorFn

(subscriptAccount,acctype,CONCAT('Subscription for ',surname,' For ',mnth,', ',yr),

memberno,custLedger,CONCAT('Monthly Subscription for ',mnth,', ',yr),amt,vno,TDate,usr),prodID FROM mem_membership

WHERE status='Active' AND fin_SubscriptionCheck(memberno,mnth,yr,prodID)=0 AND memberno=memno;



ELSE



INSERT INTO fin_subscription(memberID, sub_month, sub_year, sub_amount, comments,productID)

SELECT memberID,mnth,yr,amount,

fin_transactioncreatorFn

(subscriptAccount,acctype,CONCAT(prodName,' deposit for ',mem_GetmemberNameByID(memberID),' For ',mnth,', ',yr),

memberID,custLedger,CONCAT('Monthly Deposit of ',prodName,' for ',mnth,', ',yr),amount,vno,TDate,usr),prodID

FROM fin_memberproducts m WHERE productID=prodID AND amount>0 AND fin_SubscriptionCheck(memberID,mnth,yr,prodID)=0

AND memberid=memno;



END IF;



ELSE



INSERT INTO fin_subscription(memberID, sub_month, sub_year, sub_amount, comments,productID)

SELECT memberID,mnth,yr,amount,

fin_transactioncreatorFn

(subscriptAccount,acctype,CONCAT(prodName,' deposit for ',mem_GetmemberNameByID(memberID),' For ',mnth,', ',yr),

memberID,custLedger,CONCAT('Monthly Deposit of ',prodName,' for ',mnth,', ',yr),amount,vno,TDate,usr),prodID

FROM fin_memberproducts m

WHERE productID=prodID AND amount>0 AND fin_SubscriptionCheck(memberID,mnth,yr,prodID)=0 AND memberid=memno;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_StudentClearance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_StudentClearance`(reg varchar(25),sems int,acads varchar(15),usr varchar(25))
BEGIN

DECLARE cur_bal,stat,regstat varchar(40);

DECLARE max_sem,max_yr INT;

DECLARE max_regn,periodregn BIGINT;



/*Get Student Current Maximum Study Period*/



SELECT MAX(studyyear) INTO max_yr FROM campus_dynamics.acad_registration WHERE regno = reg;

SELECT MAX(semester) INTO max_sem FROM campus_dynamics.acad_registration WHERE studyyear = max_yr AND regno=reg;

SELECT ID INTO max_regn FROM campus_dynamics.acad_registration WHERE regno = reg AND studyyear = max_yr

AND semester=max_sem ORDER BY acad_year DESC LIMIT 1;



SELECT ID,regstatus INTO periodregn, regstat FROM campus_dynamics.acad_registration WHERE regno=reg AND acad_year=acads AND

semester=sems ORDER BY studyyear DESC LIMIT 1;



IF periodregn = max_regn THEN



CALL fin_CorrectionBilling(reg,acads,sems,'REG',usr,'');



END IF;



SET cur_bal=fin_GetCurrentFeesBalance(reg);

SET stat= IF(cur_bal LIKE '%CREDIT' AND regstat='REGISTERED','CLEARED','UNCLEARED');



UPDATE campus_dynamics.acad_registration SET examClearance=stat

 WHERE regno=reg AND acad_year=acads AND

semester=sems AND regstatus NOT IN ('UNREGISTERED','DEAD YEAR');







IF stat = 'CLEARED' AND regstat NOT IN ('UNREGISTERED','DEAD YEAR') THEN



UPDATE campus_dynamics.acad_registration SET examClearanceDate=SYSDATE(),clearedBy=usr

 WHERE regno=reg AND acad_year=acads AND

semester=sems AND regstatus NOT IN ('UNREGISTERED','DEAD YEAR');



INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

  VALUES (usr,'Exam Clearance',CONCAT('REG NO: ',reg,', ACAD: ',acads,', SEM: ',sems),'Manual Exam Clearance',SYSDATE());



END IF;



SELECT stat FROM DUAL;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_StudentLedgerSearch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_StudentLedgerSearch`(reg CHAR(35))
BEGIN

IF(reg LIKE '%/%') THEN

SELECT regno INTO reg FROM campus_dynamics.acad_student WHERE entryno=reg;

END IF;

SET reg=CONCAT('%',reg,'%');



SELECT regno,entryno, CONCAT(othername, ' ', firstname) AS stud_names,fin_GetStudyDetails(regno) AS details FROM campus_dynamics.acad_student WHERE

regno LIKE reg OR CONCAT(othername, ' ', firstname) LIKE reg ORDER BY CONCAT(othername, ' ', firstname) LIMIT 10;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_studentsInClass` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_studentsInClass`(cls INTEGER, strm CHAR(25),trm INTEGER, yr INTEGER)
BEGIN

   SELECT stud_names, cm.* FROM schoolmis.student s, schoolmis.class_manager cm

   WHERE cm.adm_no=s.adm_no AND cm.stud_class=cls AND cm.stream=strm AND cm.term=trm AND cm.year=yr;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_SubscriptionBilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_SubscriptionBilling`(yr INT, mnth CHAR(25), TDate DATE,usr CHAR(25), prodID BIGINT)
BEGIN

DECLARE subscriptAccount,acctype,custLedger,prodType,prodName,amtSetting CHAR(150);

DECLARE vno INT;

DECLARE amt BIGINT;



SET vno=fin_NextVoucherNo();

SELECT min_periodicpayment, chartAccount, customerLedgerType,productType,productName,amountSetting

INTO amt, subscriptAccount,custLedger,

prodType,prodName,amtSetting FROM fin_products

WHERE productID=prodID;

SET accType=fin_GetChartAccountLegderType(subscriptAccount);



IF prodType='Subscription' THEN



IF amtSetting='Standard' THEN



INSERT INTO fin_subscription(memberID, sub_month, sub_year, sub_amount, comments,productID)

SELECT memberno,mnth,yr,amt,

fin_transactioncreatorFn

(subscriptAccount,acctype,CONCAT('Subscription for ',surname,' For ',mnth,', ',yr),

memberno,custLedger,CONCAT('Subscription for ',mnth,', ',yr),amt,vno,TDate,usr),prodID FROM mem_membership

WHERE status='Active' AND fin_SubscriptionCheck(memberno,mnth,yr,prodID)=0;



ELSE



INSERT INTO fin_subscription(memberID, sub_month, sub_year, sub_amount, comments,productID)

SELECT memberID,mnth,yr,amount,

fin_transactioncreatorFn

(subscriptAccount,acctype,CONCAT(prodName,' deposit for ',mem_GetmemberNameByID(memberID),' For ',mnth,', ',yr),

memberID,custLedger,CONCAT('Monthly Deposit of ',prodName,' for ',mnth,', ',yr),amount,vno,TDate,usr),prodID

FROM fin_memberproducts m WHERE productID=prodID AND amount>0 AND fin_SubscriptionCheck(memberID,mnth,yr,prodID)=0;



END IF;



ELSE



INSERT INTO fin_subscription(memberID, sub_month, sub_year, sub_amount, comments,productID)

SELECT memberID,mnth,yr,amount,

fin_transactioncreatorFn

(subscriptAccount,acctype,CONCAT(prodName,' deposit for ',mem_GetmemberNameByID(memberID),' For ',mnth,', ',yr),

memberID,custLedger,CONCAT('Monthly Deposit of ',prodName,' for ',mnth,', ',yr),amount,vno,TDate,usr),prodID FROM fin_memberproducts m

WHERE productID=prodID AND amount>0 AND fin_SubscriptionCheck(memberID,mnth,yr,prodID)=0;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_TermlyItemBillDelete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_TermlyItemBillDelete`(admno CHAR(25),ItemID INT, trm INT, yr INT,cls CHAR(25), usr CHAR(25))
BEGIN



START TRANSACTION;



DELETE FROM  fin_studentfeestracking WHERE itemCode=ItemID AND term_sem=trm AND acadyear=yr AND adm_no LIKE admno;

DELETE FROM fin_Ledger WHERE folio LIKE CONCAT(admno,',Item:',ItemID,',Term:',trm,',Year:',yr,',Class:',cls);



COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_TermlyItemBilling` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_TermlyItemBilling`(billType CHAR(15), admno CHAR(25),ItemID INT, trm INT,

yr INT, cls CHAR(25), strm CHAR(25), amt DOUBLE,T_Date DATE, usr CHAR(25))
BEGIN



DECLARE IncomeAccount,ItemNm CHAR(150);

SELECT AccountCode,ItemName INTO IncomeAccount,ItemNm FROM academicbillingitems WHERE ItemCode=ItemID;



IF billType='Group' THEN

SET admno='%';

END IF;



START TRANSACTION;



INSERT IGNORE INTO fin_studentfeestracking(adm_no, term_sem, acadyear,

T_Amount, class_course, stream, itemCode, T_Type, TNo)

SELECT adm_no,trm,yr,fin_GetFeesPayable(adm_no,yr,trm,amt),cls,strm,ItemID,'Bill',1 FROM schoolmis.class_manager

WHERE stud_class=cls AND stream=strm AND year=yr AND term=trm AND adm_no LIKE admno;



SELECT fin_TransactionCreatorFn(

IncomeAccount,'Chart Account',CONCAT(ItemNM,' Receivable from ',schoolmis.acc_GetNameByAdmno(adm_no),' for Term',trm,', ',yr),

adm_no,'Student',CONCAT(ItemNM,' for Term',trm,', ',yr),T_Amount,fin_NextVoucherNo(),T_Date,usr,

CONCAT(adm_no,',Item:',ItemID,',Term:',trm,',Year:',yr,',Class:',cls)) FROM fin_studentfeestracking

WHERE term_sem=trm AND acadyear=yr AND class_course=cls AND stream=strm AND itemCode=ItemID AND adm_no LIKE admno

AND postStatus!='Posted';



UPDATE fin_studentfeestracking SET postStatus='Posted'

WHERE term_sem=trm AND acadyear=yr AND class_course=cls AND stream=strm AND adm_no LIKE admno AND itemCode=ItemID;



COMMIT;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_TransactionCreator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_TransactionCreator`(CRaccountcode CHAR(25),CRaccountType CHAR(25), CRParticulars VARCHAR(350),

DRaccountcode CHAR(25), DRaccountType CHAR(25),DRParticulars VARCHAR(350), transaction_amount BIGINT,voucherNo INT, transactionDate DATE, teller CHAR(25),

curr CHAR(10),folio CHAR(150))
BEGIN



DECLARE vNo BIGINT;



SET vNo=fin_NextVoucherNo(teller);



INSERT INTO fin_ledger(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo,

transactionDate, teller,folio,TimeLog,trans_currency)

VALUES(DRaccountcode,DRaccountType,'DR',transaction_amount,DRParticulars,vNo,transactionDate,teller,folio,SYSDATE(),curr);



INSERT INTO fin_ledger(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo,

transactionDate, teller,folio,TimeLog,trans_currency)

VALUES(CRaccountcode,CRaccountType,'CR',transaction_amount,CRParticulars,vNo,transactionDate,teller,folio,SYSDATE(),curr);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_TransactionReversal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_TransactionReversal`(vno INT,

usr CHAR(25), reason VARCHAR(25))
BEGIN

DECLARE v_amount DOUBLE;

DECLARE newVNo INT;



SET newVNo=fin_NextVoucherNo(usr);



INSERT INTO fin_ledger(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller,

folio,TimeLog,trans_currency) SELECT accountcode, account_type, IF(transactionType='CR','DR','CR'), transaction_amount,

CONCAT('Reversal of ',particulars,' reason -',reason), newVNo, SYSDATE(),

usr,folio,SYSDATE(),

trans_currency FROM fin_ledger WHERE voucherno=vno;



/*INSERT INTO fin_deleted_ledger SELECT * FROM fin_ledger WHERE voucherno=vno;

DELETE FROM fin_ledger WHERE voucherno=vno;*/



CALL fin_UpdateAllLedgerBalances();

UPDATE fin_ledger SET journal_no=fin_transactionNo(accountcode,account_type,TID)

WHERE journal_no='-';





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_TrialBalance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`dbmanager`@`%` PROCEDURE `fin_TrialBalance`(sDate DATE, eDate DATE)
BEGIN

    DECLARE vDRTotal DECIMAL(20,2) DEFAULT 0;

    DECLARE vCRTotal DECIMAL(20,2) DEFAULT 0;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_tb_subaccounts;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_tb_balances;



    CREATE TEMPORARY TABLE tmp_mru_tb_subaccounts

    (

        AccountCode VARCHAR(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        accounttype VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        collectionLedgerType VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        PRIMARY KEY(AccountCode),

        KEY idx_collectionLedgerType(collectionLedgerType)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_tb_subaccounts

    SELECT

        CONVERT(s.AccountCode USING utf8),

        LEFT(CONVERT(s.AccountName USING utf8), 191),

        CONVERT(s.accounttype USING utf8),

        CONVERT(s.collectionLedgerType USING utf8),

        CONVERT(fin_GetTrialBalanceGroup(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountCategory(s.AccountCode) USING utf8),

        CONVERT(fin_GetAccountSubCategory(s.AccountCode) USING utf8)

    FROM fin_subaccounts s;



    CREATE TEMPORARY TABLE tmp_mru_tb_movements

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    /* A) Direct COA ledger rows by accountcode. */

    INSERT INTO tmp_mru_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,



        COALESCE(SUM(

            CASE

                WHEN UPPER(TRIM(f.transactionType)) = 'DR'

                    THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                ELSE 0

            END

        ), 0) AS DRTotal,



        COALESCE(SUM(

            CASE

                WHEN UPPER(TRIM(f.transactionType)) = 'CR'

                    THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                ELSE 0

            END

        ), 0) AS CRTotal,



        COALESCE(SUM(

            CASE

                WHEN UPPER(TRIM(f.transactionType)) = 'DR'

                    THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                WHEN UPPER(TRIM(f.transactionType)) = 'CR'

                    THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                ELSE 0

            END

        ), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_tb_subaccounts s

        ON s.AccountCode = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= sDate

      AND f.transactionDate < DATE_ADD(eDate, INTERVAL 1 DAY)

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName;



    /* B) Subledger rows mapped to COA control account by account_type. */

    INSERT INTO tmp_mru_tb_movements

    SELECT

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName,



        COALESCE(SUM(

            CASE

                WHEN UPPER(TRIM(f.transactionType)) = 'DR'

                    THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                ELSE 0

            END

        ), 0) AS DRTotal,



        COALESCE(SUM(

            CASE

                WHEN UPPER(TRIM(f.transactionType)) = 'CR'

                    THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                ELSE 0

            END

        ), 0) AS CRTotal,



        COALESCE(SUM(

            CASE

                WHEN UPPER(TRIM(f.transactionType)) = 'DR'

                    THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                WHEN UPPER(TRIM(f.transactionType)) = 'CR'

                    THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)

                ELSE 0

            END

        ), 0) AS balance

    FROM fin_ledger f

    INNER JOIN tmp_mru_tb_subaccounts s

        ON s.collectionLedgerType = CONVERT(f.account_type USING utf8)

    LEFT JOIN fin_subaccounts directcoa

        ON CONVERT(directcoa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)

    WHERE f.transactionDate >= sDate

      AND f.transactionDate < DATE_ADD(eDate, INTERVAL 1 DAY)

      AND directcoa.AccountCode IS NULL

      AND IFNULL(s.collectionLedgerType,'') <> ''

      AND IFNULL(s.accounttype,'') <> 'Basic Account'

      AND NOT

      (

          UPPER(IFNULL(f.source_system,'')) IN

          (

              'RSL_GL_SIDE',

              'RESTORED_STUDENT_LEDGER',

              'RESTORED_GL_SIDE',

              'RESTORED_STUDENT_LEDGER_GL_SIDE'

          )

          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'

          OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'

      )

    GROUP BY

        s.MAC,

        s.category,

        s.subcategory,

        s.AccountCode,

        s.AccountName;



    CREATE TEMPORARY TABLE tmp_mru_tb_balances

    (

        MAC VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        category VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,

        subcategory VARCHAR(120) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountCode VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,

        AccountName VARCHAR(191) CHARACTER SET utf8 COLLATE utf8_general_ci,

        DRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        CRTotal DECIMAL(20,2) NOT NULL DEFAULT 0,

        balance DECIMAL(20,2) NOT NULL DEFAULT 0,

        KEY idx_accountcode(AccountCode)

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



    INSERT INTO tmp_mru_tb_balances

    SELECT

        MAC,

        category,

        subcategory,

        AccountCode,

        AccountName,

        SUM(DRTotal) AS DRTotal,

        SUM(CRTotal) AS CRTotal,

        SUM(balance) AS balance

    FROM tmp_mru_tb_movements

    GROUP BY

        MAC,

        category,

        subcategory,

        AccountCode,

        AccountName

    HAVING ROUND(SUM(balance), 2) <> 0

        OR ROUND(SUM(DRTotal), 2) <> 0

        OR ROUND(SUM(CRTotal), 2) <> 0;



    /* Net TB totals, not gross turnover. */

    SELECT

        COALESCE(SUM(IF(balance > 0, balance, 0)), 0),

        COALESCE(SUM(IF(balance < 0, ABS(balance), 0)), 0)

    INTO vDRTotal, vCRTotal

    FROM tmp_mru_tb_balances;



    SELECT

        z.MAC,

        z.category,

        z.subcategory,

        z.startDate,

        z.endDate,

        z.accountcode,

        z.accountname,

        z.DRBalance,

        z.CRBalance

    FROM

    (

        SELECT

            b.MAC,

            b.category,

            b.subcategory,

            DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,

            DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

            b.AccountCode AS accountcode,

            b.AccountName AS accountname,

            IF(b.balance > 0, FORMAT(b.balance, 0), '0') AS DRBalance,

            IF(b.balance < 0, FORMAT(ABS(b.balance), 0), '0') AS CRBalance,

            1 AS sort_order

        FROM tmp_mru_tb_balances b



        UNION ALL



        SELECT

            'Z' AS MAC,

            '' AS category,

            '' AS subcategory,

            '' AS startDate,

            '' AS endDate,

            'TOTALS' AS accountcode,

            'TOTALS' AS accountname,

            FORMAT(vDRTotal, 0) AS DRBalance,

            FORMAT(vCRTotal, 0) AS CRBalance,

            2 AS sort_order

    ) z

    ORDER BY

        z.sort_order,

        z.MAC,

        z.category,

        z.subcategory,

        z.accountcode;



    DROP TEMPORARY TABLE IF EXISTS tmp_mru_tb_balances;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_tb_movements;

    DROP TEMPORARY TABLE IF EXISTS tmp_mru_tb_subaccounts;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_TrialBalance_legacy_before_mru_fast_fix` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_TrialBalance_legacy_before_mru_fast_fix`(sDate DATE, eDate DATE)
BEGIN

DECLARE surplus BIGINT;

SET surplus=fin_GetSurplusDeficit(sDate);



SELECT fin_GetTrialBalanceGroup(accountcode) AS MAC,fin_GetAccountCategory(accountcode) AS category,fin_GetAccountSubCategory(accountcode) AS subcategory,DATE_FORMAT(sDate,'%d-%m-%Y') AS startDate,DATE_FORMAT(eDate,'%d-%m-%Y') AS endDate,

accountcode,accountname,IF(balance>0,FORMAT(balance,0),'') AS DRBalance,IF(balance<0,FORMAT(ABS(balance),0),'') AS CRBalance

FROM (SELECT accountcode,accountname, fin_GetPeriodBalance(sDate,eDate,accountcode,'Period') AS balance

FROM fin_subaccounts) AS findata

UNION

SELECT 'Income','Income','-','','','',IF(surplus>0,'Loss','Retained Earnings'),IF(surplus>0,FORMAT(surplus,0),'') AS DRBalance,IF(surplus<0,FORMAT(ABS(surplus),0),'') AS CRBalance

UNION

SELECT 'Z','','','','','TOTALS','',fin_TrialbalanceTotals('DR',sDate,eDate) AS DRTotal,

fin_TrialbalanceTotals('CR',sDate,eDate) AS CRTotal FROM DUAL;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_UpdateAllLedgerBalances` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_UpdateAllLedgerBalances`()
BEGIN

UPDATE fin_ledger set curr_balance=fin_GetCurrentBalance(accountcode,TID,account_type) WHERE curr_balance='-';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_UpdateLedgerBalances` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_UpdateLedgerBalances`(acc CHAR(35))
BEGIN

UPDATE fin_ledger set curr_balance=fin_GetCurrentBalance(accountcode,TID,account_type) WHERE curr_balance='-' AND accountcode=acc;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_UpdateMainCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_UpdateMainCode`(oldcode CHAR(15),newcode CHAR(15))
BEGIN



UPDATE fin_mainaccounts SET AccountCode=newcode WHERE AccountCode=oldcode;



SELECT accountcode,

fin_UpdateSubAccountCode(accountcode,

concat('AC',SUBSTRING(newcode,3,4)+(SUBSTRING(accountcode,3,4)-SUBSTRING(mainaccountcode,3,4)))) AS num

from fin_old_subaccounts WHERE MainAccountCode=oldcode;

UPDATE fin_subaccounts SET MainAccountCode=newcode WHERE MainAccountCode=oldcode;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_UpdateMemberProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_UpdateMemberProduct`(pid INT, amt BIGINT, usr CHAR(25))
BEGIN



  UPDATE fin_memberproducts SET amount=amt WHERE pledgeID=pid;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_UpdatePayAmount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_UpdatePayAmount`(vno CHAR(25),usr CHAR(35),amt DOUBLE)
BEGIN



UPDATE fin_ledger SET transaction_amount=amt WHERE voucherno=vno;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_UpdateTransactionFaculties` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_UpdateTransactionFaculties`()
BEGIN



/*INSERT IGNORE INTO fin_ledgers_prog (TID, voucherno)

  SELECT

    TID,

    voucherno

  FROM fin_ledger;



/*DROP TABLE IF EXISTS temp_pendings;



CREATE TABLE temp_pendings as SELECT

  *

FROM fin_ledger

WHERE tid IN (SELECT

    tid

  FROM fin_ledgers_prog f

  WHERE faculty = '-'

  AND tid IN (SELECT

      tid

    FROM fin_ledger

    WHERE LENGTH(accountcode) > 8));



SELECT

  l.voucherno,

  accountcode,

  fin_GetTransactionProgFaculty(l.voucherno, accountcode) AS fax

FROM temp_pending l;*/



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_ValidateAndPostJournal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_ValidateAndPostJournal`(
    IN p_journal_no TEXT,
    IN p_user CHAR(25)
)
BEGIN
    DECLARE v_status VARCHAR(15);
    DECLARE v_line_count INT DEFAULT 0;
    DECLARE v_dr_total DOUBLE DEFAULT 0;
    DECLARE v_cr_total DOUBLE DEFAULT 0;
    DECLARE v_period_count INT DEFAULT 0;
    DECLARE v_period_start DATE;
    DECLARE v_period_end DATE;
    DECLARE v_result VARCHAR(250);

    
    SELECT PostStatus INTO v_status
    FROM fin_journalnumbers
    WHERE JournalNo = CAST(TRIM(p_journal_no) AS UNSIGNED)
    LIMIT 1;

    IF v_status IS NULL THEN
        SET v_result = 'Error! Journal does not exist';
    ELSEIF v_status = 'Posted' THEN
        SET v_result = 'Error! Journal has already been posted';
    ELSEIF v_status = 'Void' THEN
        SET v_result = 'Error! Cannot post a voided journal';
    ELSEIF v_status != 'Pending' THEN
        SET v_result = CONCAT('Error! Journal status is invalid: ', v_status);
    ELSE
        
        SELECT COUNT(*) INTO v_line_count
        FROM fin_journal_details
        WHERE TRIM(journal_no) = TRIM(p_journal_no)
           OR TRIM(journal_no) = CONCAT('JN-', TRIM(p_journal_no));

        IF v_line_count < 2 THEN
            SET v_result = CONCAT('Error! Journal must have at least 2 entries (DR + CR). Found: ', v_line_count);
        ELSE
            
            SELECT COALESCE(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0),
                   COALESCE(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0)
            INTO v_dr_total, v_cr_total
            FROM fin_journal_details
            WHERE TRIM(journal_no) = TRIM(p_journal_no)
               OR TRIM(journal_no) = CONCAT('JN-', TRIM(p_journal_no));

            IF v_dr_total != v_cr_total THEN
                SET v_result = CONCAT('Error! DR/CR imbalance. DR Total: ', FORMAT(v_dr_total, 0),
                                      ', CR Total: ', FORMAT(v_cr_total, 0),
                                      ', Difference: ', FORMAT(ABS(v_dr_total - v_cr_total), 0));
            ELSEIF v_dr_total = 0 AND v_cr_total = 0 THEN
                SET v_result = 'Error! Enter transactions before posting (all amounts are zero)';
            ELSE
                
                SELECT COUNT(*), MIN(start_date), MIN(end_date)
                INTO v_period_count, v_period_start, v_period_end
                FROM fin_financial_years
                WHERE status = 'Open';

                IF v_period_count = 0 THEN
                    SET v_result = 'Error! No financial year is currently Open';
                ELSEIF CURDATE() < v_period_start OR CURDATE() > v_period_end THEN
                    SET v_result = CONCAT('Error! Current date is outside the open financial period (',
                                          DATE_FORMAT(v_period_start, '%d/%m/%Y'), ' - ',
                                          DATE_FORMAT(v_period_end, '%d/%m/%Y'), ')');
                ELSE
                    SET v_result = 'OK';
                END IF;
            END IF;
        END IF;
    END IF;

    SELECT v_result AS result_message;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fin_VoucherCreator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fin_VoucherCreator`(vNo BIGINT, CRaccountcode CHAR(25),CRaccountType CHAR(25), CRParticulars VARCHAR(350),

DRaccountcode CHAR(25), DRaccountType CHAR(25),DRParticulars VARCHAR(350), transaction_amount BIGINT,voucherNo INT, transactionDate DATE, teller CHAR(25))
BEGIN



DECLARE chk INT;

SELECT COUNT(*) INTO chk FROM  fin_voucher WHERE voucherno=vNo;

IF chk=0 THEN



INSERT IGNORE INTO fin_voucher(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller)

VALUES(DRaccountcode,DRaccountType,'DR',transaction_amount,DRParticulars,vNo,transactionDate,teller);



INSERT IGNORE INTO fin_voucher(accountcode, account_type, transactionType, transaction_amount, particulars, voucherNo, transactionDate, teller)

VALUES(CRaccountcode,CRaccountType,'CR',transaction_amount,CRParticulars,vNo,transactionDate,teller);



END IF;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAcademicBills` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAcademicBills`()
BEGIN

 SELECT * FROM academicbillingitems ORDER BY itemname; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAccountByCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAccountByCategory`(MainACC CHAR(15))
BEGIN



SELECT sa.* FROM fin_subaccounts sa WHERE MainAccountCode=MainACC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAccountByType` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAccountByType`(cat CHAR(15))
BEGIN

SET cat=CONCAT('%',cat,'%');

SELECT sa.* FROM fin_subaccounts sa JOIN fin_mainaccounts ma ON ma.accountcode=sa.mainaccountcode

WHERE generalcategory LIKE cat;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetResultSheet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetResultSheet`(

  v_subcode CHAR(5), v_Ya CHAR(4),

  Tam CHAR(1), Strim CHAR(13), v_Paper CHAR(1), Klas CHAR(1))
BEGIN



  



  SELECT acc_GetNameByAdmno(adm_no) AS stud_names,acc_GetGenderByAdmno(adm_no) AS gender, acc_GetSubNameByID(sub_code) AS sub_name,

  e.*

  FROM (SELECT * FROM examination

  WHERE

    sub_code = v_subcode AND

    Year = v_Ya AND

    Term = Tam AND

    Stream = Strim AND

    Paper = v_Paper AND

    stud_Class = Klas) AS e ORDER BY acc_GetNameByAdmno(adm_no);





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_AddAllStaffOnDedAllowance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_AddAllStaffOnDedAllowance`(dedID INT)
BEGIN

DECLARE defAmount DOUBLE;



SELECT dedall_amount INTO defAmount FROM hrm_allowance_deductions WHERE ID=dedID LIMIT 1;



INSERT IGNORE INTO hrm_ded_allowance_stafflist(ded_allID, empID, custom_amount)

SELECT dedID,empID,defAmount FROM hrm_emp_contracts WHERE contractStatus='VALID';



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_DoubleEmp_Insertion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_DoubleEmp_Insertion`(epCode CHAR(25))
BEGIN



DECLARE STAFF  INT;

SELECT empID INTO STAFF FROM hrm_employee WHERE EMP_CODE = epCode;

INSERT INTO hrm_employee_other(empID, gender, designation, dateAppointed, pref_subjects,

earlier_responsibilities, special_course, village_info, next_of_kin, kin_relation, kin_address, other_info)

VALUES(STAFF,'-','-',CURDATE(),'-','-','-','-','-','-','-','-');



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_employeeCodeGen` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_employeeCodeGen`(branch CHAR(25))
BEGIN



DECLARE done BOOLEAN DEFAULT 0;

   DECLARE mrk DOUBLE;

   DECLARE posn,popn,clspopn,inc,empNo INT;



   

   

   DECLARE staffList CURSOR

   FOR SELECT empID FROM hrm_employee WHERE Entry_Satation=branch;







   DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;





   OPEN staffList;



   

   SET posn=1;

   REPEAT



      FETCH staffList INTO empNo;

      UPDATE  hrm_employee SET emp_code=

      CONCAT('SAK-',SUBSTRING(Entry_Year,3,2),'-',SUBSTRING(branch,1,3),'-',LPAD(posn,3,0)) WHERE empID=empNo AND

      EMP_CODE='-';

      SET posn=posn+1;

   

   UNTIL done END REPEAT;



   

CLOSE staffList;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_GenerateMonthlyDedAllowanceList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_GenerateMonthlyDedAllowanceList`(pid INT, dedAllID INT, dedtyp CHAR(25),act CHAR(25))
BEGIN



DECLARE dedCat CHAR(25);

SELECT dedall_type INTO dedCat FROM hrm_allowance_deductions WHERE ID=dedAllID;



IF act='Refresh' THEN



DELETE FROM hrm_monthly_ded_allowance WHERE payrollID=pid AND ded_allID=dedAllID;



IF dedCat IN ('MANDATORY') THEN



INSERT INTO hrm_monthly_ded_allowance(payrollID,empID,amount,typ,ded_allID)

SELECT pid,empID,hrm_GetDedAll_Amount(empid,dedAllID,pid),dedtyp,dedAllID FROM hrm_emp_contracts WHERE hrm_GetPayAmount(empid)>0;



ELSEIF dedCat IN ('OPTIONAL') THEN



INSERT INTO hrm_monthly_ded_allowance(payrollID,empID,amount,typ,ded_allID)

SELECT pid,empID,hrm_GetDedAll_Amount(empid,dedAllID,pid),dedtyp,dedAllID FROM hrm_ded_allowance_stafflist WHERE ded_allID=dedAllID AND hrm_GetPayAmount(empid)>0;



END IF;



END IF;



SELECT * FROM hrm_monthly_ded_allowance WHERE payrollID=pid AND ded_allID=dedAllID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_getEmployeeAccProfile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_getEmployeeAccProfile`(emp INT)
BEGIN





SELECT * FROM hrm_employee_accprofile WHERE empID = emp;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_getEmployee_empProfile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_getEmployee_empProfile`(emp INT)
BEGIN





SELECT * FROM hrm_employee_emp_profile WHERE empID = emp;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_GetPayrollBranchDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_GetPayrollBranchDetails`(pid INT,bname CHAR(25))
BEGIN

DECLARE pStat TINYINT;

DECLARE ptotal DOUBLE;

SELECT lockStatus INTO pStat FROM hrm_payroll WHERE ID=pid;



IF pStat = 0 THEN

DELETE FROM hrm_payroll_details WHERE payrollID=pid;

INSERT INTO hrm_payroll_details(payrollID, empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay)

SELECT

pid, empID, hrm_GetPayAmount(empid), hrm_paye(empid,hrm_GetGrossPay(empID,pid)), hrm_nssf('EMP',empID,hrm_GetGrossPay(empID,pid)),

hrm_ded_all_total(empid,pid,'Allowance'), hrm_ded_all_total(empid,pid,'Deduction'),

hrm_GetGrossPay(empID,pid), hrm_netwage(empID,pid) FROM hrm_emp_contracts WHERE hrm_GetPayAmount(empid)>0 ORDER BY  hrm_GetEmpNameByID(empid);



SELECT SUM(net_pay) INTO ptotal FROM hrm_payroll_details WHERE payrollID=pid;

UPDATE hrm_payroll SET total_amount=ptotal WHERE ID=pid;



END IF;



SELECT hrm_GetEmpNameByID(empid) AS emp_name,hrm_GetEmployeeStation(empid) AS station,

hrm_GetEmployeeCode(empid) AS empcodes,hrm_GetEmpBankData(empid,'Bank') AS bank_name,

hrm_GetEmpBankData(empid,'Account') AS account,pd.* FROM hrm_payroll_details pd WHERE payrollID=pid

AND  hrm_GetEmployeeStation(empID)=bname

ORDER BY  hrm_GetEmpNameByID(empid);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_GetPayrollDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_GetPayrollDetails`(pid INT)
BEGIN

DECLARE pStat TINYINT;

DECLARE ptotal DOUBLE;

SELECT lockStatus INTO pStat FROM hrm_payroll WHERE ID=pid;



IF pStat = 0 THEN

DELETE FROM hrm_payroll_details WHERE payrollID=pid;

INSERT INTO hrm_payroll_details(payrollID, empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay)

SELECT

pid, empID, hrm_GetPayAmount(empid), hrm_paye(empid,hrm_GetGrossPay(empID,pid)), hrm_nssf('EMP',empID,hrm_GetGrossPay(empID,pid)),

hrm_ded_all_total(empid,pid,'Allowance'), hrm_ded_all_total(empid,pid,'Deduction'),

hrm_GetGrossPay(empID,pid), hrm_netwage(empID,pid) FROM hrm_emp_contracts WHERE hrm_GetPayAmount(empid)>0;



SELECT SUM(net_pay) INTO ptotal FROM hrm_payroll_details WHERE payrollID=pid;

UPDATE hrm_payroll SET total_amount=ptotal WHERE ID=pid;



END IF;



SELECT hrm_GetEmpNameByID(empid) AS emp_name,pd.* FROM hrm_payroll_details pd WHERE payrollID=pid

ORDER BY  hrm_GetEmpNameByID(empid);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_GetPayrollDetailsFull` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_GetPayrollDetailsFull`(pid INT, brch CHAR(25))
BEGIN

DECLARE pStat TINYINT;

DECLARE ptotal DOUBLE;

DECLARE payrollnm VARCHAR(300);

SELECT lockStatus,CONCAT(payroll_title,' - ',brch) INTO pStat,payrollnm FROM hrm_payroll WHERE ID=pid;



IF pStat = 0 THEN

DELETE FROM hrm_payroll_details WHERE payrollID=pid;

INSERT INTO hrm_payroll_details(payrollID, empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay)

SELECT

pid, empID, hrm_GetPayAmount(empid), hrm_paye(empid,hrm_GetGrossPay(empID,pid)), hrm_nssf('EMP',empID,hrm_GetGrossPay(empID,pid)),

hrm_ded_all_total(empid,pid,'Allowance'), hrm_ded_all_total(empid,pid,'Deduction'),

hrm_GetGrossPay(empID,pid), hrm_netwage(empID,pid) FROM hrm_emp_contracts WHERE hrm_GetPayAmount(empid)>0

AND  hrm_GetEmployeeStation(empID)=brch

ORDER BY  hrm_GetEmpNameByID(empid);



SELECT SUM(net_pay) INTO ptotal FROM hrm_payroll_details WHERE payrollID=pid;

UPDATE hrm_payroll SET total_amount=ptotal WHERE ID=pid;



END IF;



SELECT payrollnm,empid,hrm_GetEmpNameByID(empid) AS emp_name,hrm_GetEmployeeStation(empid) AS station,

hrm_GetEmployeeCode(empid) AS empcodes,hrm_GetEmpBankData(empid,'Bank') AS bank_name,

hrm_GetEmpBankData(empid,'Account') AS account,' BASIC & ALLOWANCES' AS item_name,

'BASIC' AS typ,basic_pay AS amount FROM hrm_payroll_details pd WHERE pd.payrollID=pid



UNION



SELECT payrollnm,empid,hrm_GetEmpNameByID(empid) AS emp_name,hrm_GetEmployeeStation(empid) AS station,

hrm_GetEmployeeCode(empid) AS empcodes,hrm_GetEmpBankData(empid,'Bank') AS bank_name,

hrm_GetEmpBankData(empid,'Account') AS account,'DEDUCTIONS' AS item_name,

'PAYE' AS typ,paye AS amount FROM hrm_payroll_details pd WHERE pd.payrollID=pid

AND  hrm_GetEmployeeStation(empID)=brch



UNION



SELECT payrollnm,empid,hrm_GetEmpNameByID(empid) AS emp_name,hrm_GetEmployeeStation(empid) AS station,

hrm_GetEmployeeCode(empid) AS empcodes,hrm_GetEmpBankData(empid,'Bank') AS bank_name,

hrm_GetEmpBankData(empid,'Account') AS account,'DEDUCTIONS' AS item_name,

'NSSF' AS typ,nssf AS amount FROM hrm_payroll_details pd WHERE pd.payrollID=pid

AND  hrm_GetEmployeeStation(empID)=brch



UNION



SELECT payrollnm,empid,hrm_GetEmpNameByID(empid) AS emp_name,hrm_GetEmployeeStation(empid) AS station,

hrm_GetEmployeeCode(empid) AS empcodes,hrm_GetEmpBankData(empid,'Bank') AS bank_name,

hrm_GetEmpBankData(empid,'Account') AS account,'NET' AS item_name,

'NETPAY' AS typ,net_pay AS amount FROM hrm_payroll_details pd WHERE pd.payrollID=pid

AND  hrm_GetEmployeeStation(empID)=brch



UNION



SELECT payrollnm,h.empID,hrm_GetEmpNameByID(h.empid) AS emp_name,hrm_GetEmployeeStation(h.empid) AS station,

hrm_GetEmployeeCode(h.empid) AS empcodes,hrm_GetEmpBankData(h.empid,'Bank') AS bank_name,

hrm_GetEmpBankData(h.empid,'Account') AS account,' BASIC & ALLOWANCES' AS itemName,

hrm_GetDedAllNameByID(h.ded_AllID) AS DedAllName,h.amount FROM hrm_monthly_ded_allowance h

WHERE h.payrollID=pid AND typ='Allowance' AND  hrm_GetEmployeeStation(empID)=brch



UNION



SELECT payrollnm,h.empID,hrm_GetEmpNameByID(h.empid) AS emp_name,hrm_GetEmployeeStation(h.empid) AS station,

hrm_GetEmployeeCode(h.empid) AS empcodes,hrm_GetEmpBankData(h.empid,'Bank') AS bank_name,

hrm_GetEmpBankData(h.empid,'Account') AS account,'DEDUCTIONS' AS itemName,

hrm_GetDedAllNameByID(h.ded_AllID) AS DedAllName,h.amount FROM hrm_monthly_ded_allowance h

WHERE h.payrollID=pid AND typ='Deduction' AND  hrm_GetEmployeeStation(empID)=brch ORDER BY  hrm_GetEmpNameByID(empid);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_getRecordSheet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_getRecordSheet`(emp INT)
BEGIN



SELECT hrm_employee.*,hrm_fc_getEmpDesignation(hrm_employee.empID) AS 'Designation', hrm_employee_other.* FROM hrm_employee LEFT OUTER JOIN hrm_employee_other ON

   hrm_employee.empID = hrm_employee_other.empID WHERE hrm_employee.empID = emp;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_getStaffInventory_byGender` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_getStaffInventory_byGender`()
BEGIN



SELECT Entry_Satation, hrm_fc_CalculateStaffByGender('MALE', Entry_Satation) AS 'MALE',

hrm_fc_CalculateStaffByGender('FEMALE',Entry_Satation) AS 'FEMALE',

(hrm_fc_CalculateStaffByGender('MALE', Entry_Satation) +

hrm_fc_CalculateStaffByGender('FEMALE',Entry_Satation)) AS 'TOTAL'

FROM hrm_employee GROUP BY Entry_Satation;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_getStaffInventory_byQualification` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_getStaffInventory_byQualification`()
BEGIN



SELECT Entry_Satation, emp_qualifications,

hrm_fc_CalculateStaffByQualification(emp_qualifications, Entry_Satation) AS 'Qualification'





FROM hrm_employee ;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_SinglestaffPayroll` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_SinglestaffPayroll`(eid INT)
BEGIN

SELECT payrollid,payroll_title, payroll_month, payroll_year,

empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay

FROM hrm_payroll h, hrm_payroll_details pd WHERE pd.payrollid=h.id and empid=eid;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hrm_staff_serviceYears` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `hrm_staff_serviceYears`()
BEGIN

DECLARE YEARS  BIGINT;

SELECT YEAR(SYSDATE()) INTO YEARS FROM DUAL;

SELECT empID, emp_name, Entry_Satation, hrm_fc_getEmpDesignation(empID) AS 'PositionHeld', Entry_Year,

CONCAT((YEARS - Entry_Year), ' Years') AS 'PeriodServed', hrm_fc_getempDepartment(empID) AS 'Department' FROM hrm_employee;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `int_GeneralMarksheetData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `int_GeneralMarksheetData`(cat CHAR(10), yr INTEGER, cls INTEGER, trm INTEGER, strm CHAR(15))
BEGIN



TRUNCATE int_temp_summary;



          INSERT INTO int_temp_summary(adm_no, stud_name, term, year, studyclass, stream)

          SELECT admno,int_GetStudentNamesFromNo(admno),trm,yr,cls,strm FROM int_classmanager

          WHERE study_class=cls AND term=trm AND stream=strm AND study_year=yr ORDER BY

          int_GetStudentNamesFromNo(admno);



          SELECT DISTINCT 'END TERM GENERAL MARKSHEET' AS cat,yr AS studyYear,trm AS term,

          CAST(CONCAT(' [',ex.subcode,']',' ',SUBSTRING(subname,1,4)) AS CHAR)

          subname,ex.admno,stud_name,paper,

          CAST(CONCAT(markscored) AS CHAR) AS grade,

          cls,strm,sumID FROM int_examinations ex,int_subjects sb,int_temp_summary sm

          WHERE ex.admno=sm.adm_no AND ex.subcode=sb.subcode AND ex.study_year=yr

          AND ex.stream=strm AND ex.Term=trm AND sm.term=trm AND sm.year=yr





          

          ORDER BY sumID asc ;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_AddBudgetItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_AddBudgetItems`(bid INT, trm INT, yr INT)
BEGIN



INSERT IGNORE INTO  inv_budgetrequisitions (branchID, term, budget_year, item_code, budget_amount, total_requisition, balance)

SELECT bid,trm,yr,ItemCode,0,0,0 FROM inv_itemdetails;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_AddNewRequisitionDetail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_AddNewRequisitionDetail`(rid INT, itemID INT,unitID INT, locID INT)
BEGIN



DECLARE trm,yr,bid INT;

DECLARE bgt,tkn,bf,curr DOUBLE;



SELECT req_year,term,branchID INTO yr,trm,bid FROM inv_schoolrequisition WHERE ID=rid;

SELECT budget_amount,total_requisition INTO bgt,tkn

 FROM inv_budgetrequisitions WHERE branchID=bid AND term=trm AND budget_year=yr AND item_code=itemID;



INSERT INTO inv_schoolreqdetails(reqID, itemCode, qty, unit, details, budget_qty, curr_qty, actual_qty, bal_qty,

req_qty, taken_qty,locationCode) VALUES (rid,itemID,0,unitID,'-',bgt,(bgt-tkn),0,(bgt-tkn),0,tkn,locID);





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_ApproveRequisition` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_ApproveRequisition`(rid INT, stat CHAR(15),usr CHAR(25))
BEGIN

DECLARE noItems,bid,trm,yr INT;

SELECT COUNT(*) INTO noItems FROM inv_schoolreqdetails WHERE reqID=rid;

SELECT branchID,term,req_year INTO bid,trm,yr FROM inv_schoolrequisition WHERE ID=rid;



IF stat='Pending' THEN



IF noItems=0 THEN

SELECT 'No Items on Requisition' AS comm FROM DUAL;

ELSE

INSERT INTO inv_inventory(ItemCode, Qty, CostPrice, CreatedBy, DateCreated, LocationCode, SheetNo)

  SELECT dt.ItemCode, inv_fc_GetUnitQtyConversion(actual_qty,ItemCode,unit),

   (SELECT CostPrice FROM inv_itemdetails WHERE ItemCode = dt.ItemCode),

  usr, SYSDATE(), LocationCode, 0 FROM inv_schoolreqdetails dt WHERE reqID = rid

 ON DUPLICATE KEY UPDATE

 Qty = inv_inventory.Qty - inv_fc_GetUnitQtyConversion(dt.actual_qty,dt.ItemCode,dt.unit),

 DateCreated = SYSDATE(), LocationCode = dt.locationCode,

 CostPrice = (SELECT CostPrice FROM inv_itemdetails WHERE ItemCode = dt.ItemCode);



 INSERT INTO inv_budgetrequisitions(branchID,term,budget_year,item_code,total_requisition)

 (SELECT bid,trm,yr,itemCode,actual_qty FROM inv_schoolreqdetails WHERE reqID=rid) ON DUPLICATE KEY UPDATE

 total_requisition=total_requisition+actual_qty;



 UPDATE inv_schoolrequisition SET req_status = 'Approved' WHERE ID = rid;

 SELECT 'Approval Completed' AS comm FROM DUAL;





END IF;

ELSE



 SELECT 'Sheet Already Approved' AS comm FROM DUAL;





END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_CheckStockonCapturesheet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_CheckStockonCapturesheet`(Sht INT)
BEGIN



SELECT COUNT(*) AS 'ItemsNo'  FROM inv_stock_on_sheet WHERE SheetNo = Sht;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_DeleteItem_Routine` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_DeleteItem_Routine`(ICD INT)
BEGIN



DELETE FROM inv_itemdetails WHERE ItemCode = ICD;

DELETE FROM inv_itemunitdetails WHERE ItemCode = ICD;

DELETE FROM inv_supplierwithitems WHERE ItemCode = ICD;

DELETE FROM inv_stock_on_sheet WHERE ItemCode = ICD;

DELETE FROM inv_inventory WHERE ItemCode = ICD;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_DeleteSheetItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_DeleteSheetItem`(SN INT)
BEGIN

DELETE FROM inv_stock_on_sheet WHERE SNO = SN;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_DeleteunitItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_DeleteunitItems`(Icode INT, UCode INT)
BEGIN



DELETE FROM inv_itemunitdetails WHERE ItemCode = Icode AND UnitCode = UCode;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetActiveItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetActiveItems`()
BEGIN



SELECT COUNT(*) AS 'ActiveItems' FROM inv_itemdetails;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetCurrentStockList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetCurrentStockList`(
	IN `search` VARCHAR(45) CHARSET utf8
)
BEGIN

IF search = 'ALL' THEN

SELECT ItemCode, inv_fc_getItemName(ItemCode) AS 'ItemName',
CONCAT(inv_fc_GetCurrentItemQty(ItemCode),' (',inv_fc_getAdjustPrimaryUnit(ItemCode),')') AS 'Qty',
CostPrice, (Qty*CostPrice) AS 'StockValue', DateCreated, inv_fc_getStoreName(LocationCode) AS 'Store', CreatedBy FROM
inv_inventory;

ELSE

SELECT ItemCode, inv_fc_getItemName(ItemCode) AS 'ItemName',
CONCAT(inv_fc_GetCurrentItemQty(ItemCode),' (',inv_fc_getAdjustPrimaryUnit(ItemCode),')') AS 'Qty',
CostPrice, (Qty*CostPrice) AS 'StockValue', DateCreated, inv_fc_getStoreName(LocationCode) AS 'Store', CreatedBy FROM
inv_inventory  WHERE ItemCode LIKE CONCAT('%',search,'%') OR inv_fc_getItemName(ItemCode) LIKE CONCAT('%',search,'%');

END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetItemPrimaryUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetItemPrimaryUnit`(ICD INT)
BEGIN

DECLARE COUNTER INT;

SELECT COUNT(*) INTO COUNTER FROM inv_itemunitdetails WHERE ItemCode= ICD;



IF COUNTER > 0 THEN



SELECT UnitCode, inv_fc_getUnitShortname(UnitCode) AS 'Unit' FROM inv_itemdetails WHERE ItemCode= ICD

UNION

SELECT UnitCode, inv_fc_getUnitShortname(UnitCode) AS 'Unit' FROM inv_itemunitdetails WHERE ItemCode= ICD;



ELSE



SELECT UnitCode, inv_fc_getUnitShortname(UnitCode) AS 'Unit' FROM inv_itemdetails WHERE ItemCode= ICD;



END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetItemSupplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetItemSupplier`(ICODE INT)
BEGIN



SELECT inv_fc_getSupplierName(SupplierCode) AS 'Supplier', inv_fc_getItemName(ICODE) AS 'ItemName',

inv_fc_getUnitShortname(UnitCode) AS 'Unit', CostPrice FROM inv_supplierwithitems

WHERE ItemCode = ICODE;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetItemUnits` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetItemUnits`(Icode INT)
BEGIN





SELECT *, inv_fc_getUnitShortname(UnitCode) AS 'ShortName'FROM inv_itemunitdetails WHERE ItemCode = Icode;









END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetLastItemCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetLastItemCode`(gcode INT)
BEGIN



DECLARE maxNO INT;

SELECT MAX(ItemCode) INTO maxNo FROM inv_itemdetails WHERE ItemGroupCode = gcode;

SELECT IF(maxNo IS NULL, CONCAT(gcode,'001'), maxNo) AS 'LastItemCode';



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetOtherStockLitsUnits` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetOtherStockLitsUnits`(ICD INT)
BEGIN

DECLARE COUNTER INT;





SELECT COUNT(*) INTO COUNTER FROM inv_itemunitdetails WHERE ItemCode= ICD;



IF COUNTER > 0 THEN





SELECT UnitCode, inv_fc_getUnitShortname(UnitCode) AS 'Unit' FROM inv_itemunitdetails WHERE ItemCode= ICD;



ELSE



SELECT UnitCode, inv_fc_getUnitShortname(UnitCode) AS 'Unit' FROM inv_itemdetails WHERE ItemCode= ICD;



END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetPurchaseOrderItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetPurchaseOrderItems`(PO INT)
BEGIN



SELECT S_no, Po_No, ItemCode, inv_fc_getItemName(ItemCode) AS 'ItemName', QtyOrder, inv_fc_getUnitShortname(UnitCode) AS 'Unit',

UnitPrice, Amount, VAT_Amount FROM inv_purchaseorder_items WHERE Po_No = PO;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetPurchaseOrdersByDate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetPurchaseOrdersByDate`(dat DATE)
BEGIN

SELECT * FROM inv_purchaseorder WHERE DateCreated = dat;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetSchoolTermlyBudget` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetSchoolTermlyBudget`(

	IN `bid` INT,

	IN `trm` INT,

	IN `yr` CHAR(15)

)
BEGIN



SELECT ID, balance, branchID, budget_amount, budget_year, item_code, term, total_requisition,balance,

inv_fc_getItemName(item_code) AS ItemName

FROM inv_budgetrequisitions b WHERE (branchID = bid) AND (budget_year = yr) AND (term = trm);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetsecondaryItemUnits` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetsecondaryItemUnits`(Icode INT)
BEGIN



DECLARE primaryUnit     INT;

SELECT UnitCode INTO primaryUnit FROM inv_itemdetails WHERE ItemCode = Icode;

SELECT * FROM inv_itemunits WHERE UnitCode <> primaryUnit;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockCaptureSheetitems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockCaptureSheetitems`(Act INT, SHNO INT)
BEGIN



DECLARE SheetStat VARCHAR(45);

SELECT SheetStatus INTO SheetStat FROM inv_stockcapture WHERE SheetNo = SHNO;





SELECT SNO, SheetNo, inv_fc_getItemName(ItemCode) AS 'ItemName', inv_fc_getUnitShortname(UnitCode) AS 'Unit',

Qty, CostPrice, Total, inv_fc_getStoreName(LocationCode) AS 'Store' FROM inv_stock_on_sheet WHERE

SheetNo = SHNO;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockCaptureSheets` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockCaptureSheets`(usr VARCHAR(45))
BEGIN



DECLARE SheetNo INT;



SELECT inv_fc_NextCaptureSheetNo() INTO SheetNo FROM DUAL;



INSERT INTO inv_stockcapture(SheetNo, SheetStatus, CreatedBy, DateCreated, Comments)

VALUES(SheetNo, 'NEW', usr,SYSDATE(),'-');



SELECT SheetNo FROM DUAL;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetstockCaptureSheet_ByRunDate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetstockCaptureSheet_ByRunDate`(dat DATE)
BEGIN



SELECT * FROM inv_stockcapture WHERE DateCreated = dat;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockDeductions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockDeductions`(dat DATE)
BEGIN





SELECT sno, ItemCode, inv_fc_getItemName(ItemCode) AS 'ItemName', inv_fc_getUnitShortname(DeductionUnit) AS 'DeductionUnit',

DeductionQty, CostPrice, StockLoss, Reason, DeductionDate, CreatedBy FROM

inv_stockdeductions  WHERE DeductionDate = dat;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockItemsToAdjust` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockItemsToAdjust`(sht INT)
BEGIN



SELECT *, inv_fc_getUnitShortname(UnitCode) AS 'Unit', inv_fc_getItemName(ItemCode) AS 'ItemName',

CONCAT(inv_fc_GetCurrentItemQty(ItemCode),inv_fc_getAdjustPrimaryUnit(ItemCode)) AS 'SysQty' FROM inv_stock_on_sheet WHERE

SheetNo IN (SELECT SheetNo FROM inv_stockcapture WHERE SheetStatus = 'Verified') AND SheetNo = sht;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockItemUnits` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockItemUnits`(ICD INT)
BEGIN





SELECT UnitCode, inv_fc_getUnitShortname(UnitCode) AS 'Unit'FROM inv_itemunitdetails WHERE ItemCode = ICD;









END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockList_ByUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockList_ByUnit`(ICD INT, UCD INT)
BEGIN





SELECT ItemCode, inv_fc_getItemName(ItemCode) AS 'ItemName',

CONCAT(inv_fc_StockunitQtyConversion(ICD,UCD),' (',inv_fc_getUnitShortname(UCD),')') AS 'Qty',

inv_GetItemCostPrice(ICD,UCD) AS 'CostPrice',

(inv_fc_StockunitQtyConversion(ICD,UCD)*inv_GetItemCostPrice(ICD,UCD)) AS 'StockValue', DateCreated,

inv_fc_getStoreName(LocationCode) AS 'Store', CreatedBy FROM inv_inventory  WHERE ItemCode = ICD;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockSheetStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockSheetStatus`(S_no INT)
BEGIN



SELECT SheetStatus FROM inv_stockcapture WHERE SheetNo = S_no;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockVerificationSheet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockVerificationSheet`()
BEGIN

SELECT * FROM inv_stockcapture WHERE SheetStatus = 'Submitted' ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetStockWarnings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetStockWarnings`()
BEGIN







SELECT ItemCode, inv_fc_getItemName(ItemCode) AS 'ItemName',

inv_fc_getAdjustPrimaryUnit(ItemCode) AS 'Unit' , ReorderLevel, ReorderQty,

inv_fc_GetCurrentItemQty(ItemCode) AS 'CurrentQty'

FROM inv_itemdetails WHERE inv_fc_GetCurrentItemQty(ItemCode) < ReorderLevel;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetTermlyMaterialsReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetTermlyMaterialsReport`(trm INT, yr INT)
BEGIN



DECLARE sch_name VARCHAR(200);

SELECT companyname INTO sch_name FROM companyinfo LIMIT 1;



SELECT schoolmis.school_GetBranchNameByID(branchID) AS branchname,

inv_GetCategoryByItemCode(item_code) AS category,

inv_fc_getItemName(item_code) AS ItemName,

'BGTD' AS ListType,

budget_amount AS qty,trm,yr,sch_name

FROM  inv_budgetrequisitions r WHERE term=trm AND budget_year=yr



UNION



SELECT schoolmis.school_GetBranchNameByID(branchID) AS branchname,

inv_GetCategoryByItemCode(item_code) AS category,

inv_fc_getItemName(item_code) AS ItemName,

'BALBF' AS ListType,

inv_GetMaterialBF(branchID,item_code,trm,yr) AS qty,trm,yr,sch_name

FROM  inv_budgetrequisitions r WHERE term=trm AND budget_year=yr



UNION



SELECT schoolmis.school_GetBranchNameByID(branchID) AS branchname,

inv_GetCategoryByItemCode(item_code) AS category,

inv_fc_getItemName(item_code) AS ItemName,

'RCVD' AS ListType,

total_requisition AS qty,trm,yr,sch_name

FROM  inv_budgetrequisitions r WHERE term=trm AND budget_year=yr



UNION



SELECT schoolmis.school_GetBranchNameByID(branchID) AS branchname,

inv_GetCategoryByItemCode(item_code) AS category,

inv_fc_getItemName(item_code) AS ItemName,

'BAL' AS ListType,

balance AS qty,trm,yr,sch_name

FROM  inv_budgetrequisitions r WHERE term=trm AND budget_year=yr



UNION



SELECT 'TOT.BGT' AS branchname,

inv_GetCategoryByItemCode(item_code) AS category,

inv_fc_getItemName(item_code) AS ItemName,

'TOT.BGT' AS ListType,

inv_GetMaterialTotals(item_code,trm,yr,'B') AS qty,trm,yr,sch_name

FROM  inv_budgetrequisitions r WHERE term=trm AND budget_year=yr



UNION



SELECT 'TOT.BAL' AS branchname,

inv_GetCategoryByItemCode(item_code) AS category,

inv_fc_getItemName(item_code) AS ItemName,

'TOT.BAL' AS ListType,

inv_GetMaterialTotals(item_code,trm,yr,'BAL') AS qty,trm,yr,sch_name

FROM  inv_budgetrequisitions r WHERE term=trm AND budget_year=yr



UNION



SELECT 'TOT.REQ' AS branchname,

inv_GetCategoryByItemCode(item_code) AS category,

inv_fc_getItemName(item_code) AS ItemName,

'TOT.REQ' AS ListType,

inv_GetMaterialTotals(item_code,trm,yr,'R') AS qty,trm,yr,sch_name

FROM  inv_budgetrequisitions r WHERE term=trm AND budget_year=yr;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_GetVerifiedSheetNumbers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_GetVerifiedSheetNumbers`()
BEGIN



SELECT SheetNo FROM inv_stockcapture WHERE SheetStatus = 'Verified';



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_itemsDetailsEntry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_itemsDetailsEntry`(ICode INT, ItemName VARCHAR(45), ItemShortName VARCHAR(45),

UnitCode INT, ItemGroupCode INT, Qty INT, TaxCode INT, CostPrice DOUBLE, SellingPrice DOUBLE, ReorderLevel INT, ReorderQty INT,

Description VARCHAR(100), int_Barcode1 VARCHAR(45), int_Barcode2 VARCHAR(45), int_Barcode3 VARCHAR(45))
BEGIN



IF NOT EXISTS(SELECT * FROM inv_itemdetails WHERE ItemCode = ICode) THEN



INSERT INTO inv_itemdetails(ItemCode, ItemName, ItemShortName, UnitCode, ItemGroupCode, Qty, TaxCode, CostPrice, SellingPrice,

ReorderLevel, ReorderQty, Description, int_Barcode1, int_Barcode2, int_Barcode3)

VALUES(ICode, ItemName, ItemShortName, UnitCode, ItemGroupCode, Qty, TaxCode, CostPrice, SellingPrice, ReorderLevel,

ReorderQty, Description, int_Barcode1, int_Barcode2, int_Barcode3);



ELSE



SELECT 'Duplicate Entry';

END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_itemUnitsEntry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_itemUnitsEntry`(ICode INT, UCode INT, CostPrice DOUBLE, SellingPrice DOUBLE,

MainUnitQty INT, AlternateUnitQty INT, ConversionToMainQty INT, int_Barcode1 VARCHAR(45), int_Barcode2 VARCHAR(45),

int_Barcode3 VARCHAR(45))
BEGIN





INSERT INTO inv_itemunitdetails(ItemCode, UnitCode, CostPrice, SellingPrice, MainUnitQty, AlternateUnitQty,

ConversionToMainQty, int_Barcode1, int_Barcode2, int_Barcode3)

VALUES(ICode, UCode, CostPrice, SellingPrice, MainUnitQty, AlternateUnitQty, ConversionToMainQty,

int_Barcode1, int_Barcode2, int_Barcode3);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_poEntries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_poEntries`(PON INT, DateCreated DATE, RequestedBy VARCHAR(45),

RequisitionNo INT, RequisitionDate DATE, SupplierID INT, PreparedBy VARCHAR(45), TermsOfDelivery VARCHAR(100), DateOfDelivery DATE,

TermsOfPayment VARCHAR(45), MethodOfPayment VARCHAR(45))
BEGIN



DECLARE PO   INT;

DECLARE CHK  INT;

SET PO = inv_fc_NextPoNo();

SELECT COUNT(*) INTO CHK FROM inv_purchaseorder WHERE Po_No =  PON;



IF CHK  < 1 THEN



INSERT INTO inv_purchaseorder(Po_No, DateCreated, RequestedBy, RequisitionNo, RequisitionDate, SupplierID, PreparedBy,

TermsOfDelivery, DateOfDelivery, TermsOfPayment, MethodOfPayment)

  VALUES(PO, DateCreated, RequestedBy, RequisitionNo, RequisitionDate, SupplierID, PreparedBy,

TermsOfDelivery, DateOfDelivery, TermsOfPayment, MethodOfPayment);



ELSE



UPDATE inv_purchaseorder SET DateCreated = DateCreated, RequestedBy = RequestedBy, RequisitionNo = RequisitionNo,

RequisitionDate = RequisitionDate, SupplierID = SupplierID, PreparedBy = PreparedBy, TermsOfDelivery = TermsOfDelivery,

DateOfDelivery = DateOfDelivery, TermsOfPayment = TermsOfPayment, MethodOfPayment = MethodOfPayment WHERE

Po_No = PON;



END IF;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_poItemsEntries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_poItemsEntries`(Sno INT, PO INT, ItemCode INT, QtyOrder DOUBLE, UnitCode INT,

                                                       taxStatus INT, Act VARCHAR(45))
BEGIN



DECLARE SN      INT;

DECLARE UPRICE  DOUBLE(20,3);

DECLARE VAT     DOUBLE(20,3);



SET UPRICE = inv_GetItemCostPrice(ItemCode,UnitCode);

SET SN = inv_fc_NextPo_Serial(PO);

SET VAT = inv_fc_VATCalculator(ItemCode,UnitCode,'COST',QtyOrder);



IF Act = 'INSERT' THEN



    IF taxStatus = 1 THEN

      INSERT INTO inv_purchaseorder_items(S_no, Po_No, ItemCode, QtyOrder, UnitCode, UnitPrice, Amount, VAT_Amount)

        VALUES(SN, PO, ItemCode, QtyOrder, UnitCode, UPRICE, (QtyOrder*UPRICE), VAT);

    ELSE

      INSERT INTO inv_purchaseorder_items(S_no, Po_No, ItemCode, QtyOrder, UnitCode, UnitPrice, Amount, VAT_Amount)

        VALUES(SN, PO, ItemCode, QtyOrder, UnitCode, UPRICE, (QtyOrder*UPRICE), 0);

    END IF;

ELSEIF Act = 'DELETE' THEN



    DELETE FROM inv_purchaseorder_items WHERE Po_No = PO AND ItemCode = ItemCode AND S_no = Sno;



END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_PrintRequisition` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_PrintRequisition`(rid INT)
BEGIN



SELECT inv_fc_getItemName(itemCode) AS itemName,inv_GetBranchNameByID(branchID) AS school_name,

inv_GetItemShortName(unit) AS UnitName,

r.*,dt.* FROM inv_schoolrequisition r JOIN

inv_schoolreqDetails dt ON dt.reqID=r.ID WHERE r.ID=rid;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_StockAdjustment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_StockAdjustment`(shtNo INT, usr VARCHAR(45))
BEGIN





INSERT INTO inv_inventory(ItemCode, Qty, CostPrice, CreatedBy, DateCreated, LocationCode, SheetNo)

  SELECT inv_stock_on_sheet.ItemCode, inv_fc_unitQtyConversion(shtNo,ItemCode,UnitCode),

   (SELECT CostPrice FROM inv_itemdetails WHERE ItemCode = inv_stock_on_sheet.ItemCode),

  usr, SYSDATE(), LocationCode, SheetNo FROM inv_stock_on_sheet WHERE SheetNo = shtNo

 ON DUPLICATE KEY UPDATE

 Qty = inv_inventory.Qty + inv_fc_unitQtyConversion(shtNo,inv_stock_on_sheet.ItemCode,inv_stock_on_sheet.UnitCode),

 DateCreated = SYSDATE(), LocationCode = inv_stock_on_sheet.LocationCode,

 CostPrice = (SELECT CostPrice FROM inv_itemdetails WHERE ItemCode = inv_stock_on_sheet.ItemCode);







  UPDATE inv_stockcapture SET SheetStatus = 'Adjusted', Comments = 'Confirmed & Adjusted' WHERE SheetNo = shtNo;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_stockcaptureEntries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_stockcaptureEntries`(ItemCode INT, UnitCode INT, Qty INT, LocationCode INT, SheetNo INT)
BEGIN



DECLARE CP DOUBLE;

DECLARE TT DOUBLE;



SELECT inv_GetItemCostPrice(ItemCode,UnitCode) INTO CP FROM DUAL;

SELECT CP*Qty INTO TT FROM DUAL;



INSERT INTO inv_stock_on_sheet(SNO, ItemCode, UnitCode, Qty, CostPrice, Total, LocationCode, SheetNo)

  VALUES(NULL, ItemCode, UnitCode, Qty, CP, TT, LocationCode, SheetNo);



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_stockDeductionEntries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_stockDeductionEntries`(Act VARCHAR(45), ICD INT, DeductionUnit INT, DeductionQty BIGINT,

                                                              Reason VARCHAR(100), CreatedBy VARCHAR(45))
BEGIN



DECLARE ActualQty   BIGINT;

DECLARE deductQty   BIGINT;

DECLARE currentQty  BIGINT;

DECLARE UnitCostP   DOUBLE;



SELECT Qty INTO currentQty FROM inv_inventory WHERE ItemCode = ICD;

SELECT CostPrice INTO UnitCostP FROM inv_inventory WHERE ItemCode = ICD;

SET ActualQty = inv_fc_Deduct_unitQtyConversion(ICD, DeductionUnit) * DeductionQty;





IF Act = 'Deduct' THEN



SET deductQty = currentQty - ActualQty;

UPDATE inv_inventory SET Qty = deductQty WHERE ItemCode = ICD;



INSERT INTO inv_stockdeductions(sno, ItemCode, DeductionUnit, DeductionQty, CostPrice, StockLoss, Reason,

DeductionDate, CreatedBy) VALUES(NULL, ICD, DeductionUnit, DeductionQty, UnitCostP, (ActualQty*UnitCostP),

Reason, SYSDATE(), CreatedBy);



ELSE



SET deductQty = currentQty + ActualQty;

UPDATE inv_inventory SET Qty = deductQty WHERE ItemCode = ICD;



DELETE FROM inv_stockdeductions WHERE ItemCode = ICD AND DeductionUnit = DeductionUnit AND DeductionQty = DeductionQty AND

Reason = Reason AND CreatedBy = CreatedBy;



END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_SubmitStockcaptureSheet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_SubmitStockcaptureSheet`(s_no INT, s_status VARCHAR(45), c_by VARCHAR(45), comm VARCHAR(45))
BEGIN



UPDATE inv_stockcapture SET SheetStatus = s_status, CreatedBy = c_by, Comments = comm WHERE

SheetNo = s_no;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_supplierwithItemsEntries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_supplierwithItemsEntries`(SupplierCode INT, ItemCode INT, UnitCode INT, CostPrice DOUBLE)
BEGIN



INSERT IGNORE INTO inv_supplierwithitems(SupplierCode, ItemCode, UnitCode, CostPrice)

VALUES(SupplierCode, ItemCode, UnitCode, CostPrice);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `inv_UpdateRequisitionDetail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `inv_UpdateRequisitionDetail`(rid INT, itemID INT)
BEGIN



UPDATE inv_schoolreqdetails SET req_qty=qty,bal_qty=curr_qty-actual_qty  WHERE reqID=rid AND itemCode=itemID;





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `MainAccountEditor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `MainAccountEditor`(usr CHAR(25), AccCode CHAR(15), AccountName VARCHAR(45),

GeneralCategory CHAR(45), SubCategory CHAR(45))
BEGIN



   SELECT COUNT(*) INTO @chk FROM  fin_mainaccounts WHERE AccountCode=AccCode;



   INSERT INTO fin_mainaccounts(AccountCode, AccountName, GeneralCategory, SubCategory)

   VALUES (AccCode, AccountName, GeneralCategory, SubCategory)

   ON DUPLICATE KEY UPDATE AccountName=AccountName, GeneralCategory=GeneralCategory,

   SubCategory=SubCategory;



   



   INSERT INTO acc_activity_log(user_id,page_function,par,comments,access_date)

   VALUES (usr,'Category Management',CONCAT('AccCode=',AccCode,'AccName=',

   AccountName),IF(@chk=1,'Updated category','Created Category'),SYSDATE());



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_aspnet_AssignRole` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_aspnet_AssignRole`(uid INT,rid INT)
BEGIN

  INSERT IGNORE INTO my_aspnet_usersinroles VALUES (uid,rid);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_aspnet_EditApps` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_aspnet_EditApps`(cat INT,app_ID INT, app_name VARCHAR(45), app_description VARCHAR(250), app_icon VARCHAR(45), app_home VARCHAR(150))
BEGIN

IF cat=1 THEN

INSERT INTO my_aspnet_apps(app_name, app_description, app_icon, app_home) VALUES (app_name, app_description, app_icon, app_home);



ELSE



UPDATE my_aspnet_apps SET app_name= app_name, app_description=app_description, app_icon=app_icon, app_home=app_home WHERE

app_ID=app_ID;



END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_aspnet_GetMyApps` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_aspnet_GetMyApps`(username CHAR(25))
BEGIN

SELECT * FROM my_aspnet_apps m  WHERE app_id IN

(SELECT appid FROM my_aspnet_roles_in_apps WHERE roleID IN

(SELECT roleID FROM my_aspnet_usersinroles m JOIN my_aspnet_users u ON m.userid=u.id WHERE name=username))

ORDER BY app_name;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_aspnet_GetUserDept_Branch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_aspnet_GetUserDept_Branch`(unm CHAR(25), factor CHAR(12))
BEGIN



DECLARE userDept,uid INT;

DECLARE userBranch CHAR(10);



SELECT deptID,branchCode INTO userDept,userBranch FROM my_aspnet_userbranch_department WHERE userID=(SELECT id FROM my_aspnet_users WHERE name=unm);



IF factor='Dept' THEN

SELECT userDept AS userData FROM DUAL;

ELSE

SELECT userBranch AS userData FROM DUAL;

END IF;







END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_aspnet_GetUserRoles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_aspnet_GetUserRoles`(uid INT)
BEGIN



SELECT name AS rolename, ur.* FROM my_aspnet_usersinroles ur JOIN

my_aspnet_roles r ON ur.roleid=r.id WHERE userid=uid;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_aspnet_GetUsersList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_aspnet_GetUsersList`()
BEGIN

  SELECT * FROM my_aspnet_users m ORDER BY name;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `my_aspnet_ResetPassword` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `my_aspnet_ResetPassword`(usID INT)
BEGIN



UPDATE my_aspnet_membership SET Password='XdiDC5xPHsIAtl8URiEgMUMLiCMIWEK8Q0WEWh9txzo=',PasswordKey='FGyxDhogiUILE9K+xekuPA==',

IsLockedOut=0 WHERE userID=usID;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `school_CreateBudget` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `school_CreateBudget`(yr INT, cat CHAR(15),brid INT)
BEGIN



IF cat='EXPENDITURE' THEN

SET cat='Expense';

END IF;



INSERT IGNORE INTO school_budget(item_code, details, planned_amount, actual_amount, vote_status, item_category, budget_year,bid)

SELECT s.accountcode,'-',0,0,'Normal',cat,yr,brid

FROM fin_subaccounts s, fin_mainaccounts m WHERE m.accountcode=s.mainaccountcode

AND generalcategory=cat;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `school_GetBudget` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `school_GetBudget`(yr INT, cat CHAR(15),brid INT)
BEGIN



IF cat='ALL' THEN

SET cat='%';

ELSEIF cat='EXPENDITURE' THEN

SET cat='Expense';

END IF;



SELECT accountname,(planned_amount-actual_amount) AS var,IF((planned_amount-actual_amount)>=0,'Favourable','Unfavourable') AS comm,

b.* FROM school_budget b, fin_subaccounts s WHERE b.item_code=s.accountcode AND item_category LIKE cat AND

budget_year=yr AND bid=brid ORDER BY item_category DESC,item_code ASC;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_balance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_balance`(chk_id int ,Amt_paid_ double,dscout int,paydate date,rid int,reciBY char(45),part text)
BEGIN

declare nod int;



declare bf TINYINT(1);

declare rate, Amt_tP ,Bal double;



select DATEDIFF(DOD,DOA),breakfast  INTO nod,bf  from checking_in_out where chk_id =checkin_id;

select RRate  into rate from rooms where Room_ID=rid;



if bf =0 then

set Amt_tP = (nod * rate)-(nod*10000);

set Bal =(Amt_tP-Amt_paid_);

else

set Amt_tP = (nod * rate);

set Bal=Amt_tP-Amt_paid_;





end if;

















INSERT INTO payments (check_id, Amt_Paid, Discount, Balance, Amt_to_pay, PaymentDate, RecievedBy,particulars) VALUES (chk_id,Amt_paid_,dscout,Bal,Amt_tP,paydate,reciBY,part) ;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateStudentImage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateStudentImage`(RegNo CHAR(20), Meg LONGBLOB)
BEGIN



  IF NOT EXISTS(SELECT * FROM StudentImages WHERE stud_reg_no = RegNo) THEN

    INSERT INTO StudentImages(stud_Reg_no) VALUES (RegNo);

  END IF;



  UPDATE StudentImages SET Photo = Meg WHERE stud_reg_no = RegNo;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateStudentSignature` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateStudentSignature`(RegNo CHAR(20), Meg MEDIUMBLOB)
BEGIN

  IF NOT EXISTS(SELECT * FROM StudentImages WHERE stud_reg_no = RegNo) THEN
    INSERT INTO StudentImages(stud_Reg_no) VALUES (RegNo);
  END IF;

  UPDATE StudentImages SET sign = Meg WHERE stud_reg_no = RegNo;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-26 16:04:37
