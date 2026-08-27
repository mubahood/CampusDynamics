*************************** 1. row ***************************
fin_Autobilling
STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
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
END
utf8
utf8_general_ci
latin1_swedish_ci
