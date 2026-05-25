-- acad_RegisterApplicant stored procedure (no academic-year restriction)
-- Run with: mysql -u root -p campus_dynamics < update_register_applicant_sp.sql

DROP PROCEDURE IF EXISTS acad_RegisterApplicant;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `acad_RegisterApplicant`(eyr INT, eno CHAR(25), usr CHAR(35))
BEGIN
    DECLARE new_no, prog, sess, spec, campus, religion CHAR(35);

    SELECT prog_id, adm_session, sub_comb INTO prog, sess, spec
    FROM acad_applicant_choices
    WHERE stud_entry_no = eno AND choice = 1 LIMIT 1;

    SELECT stud_reg_no INTO new_no
    FROM acad_applications
    WHERE stud_entry_no = eno LIMIT 1;

    INSERT IGNORE INTO acad_student(
        entryno, regno, firstname, dob, gender, nationality, religion,
        entrymethod, progid, studPhone, email, entryyear, studsesion,
        home_dist, intake, gradSystemID, othername, duration, specialisation, studcampus
    )
    SELECT stud_reg_no, stud_entry_no,
        REPLACE(SUBSTRING_INDEX(stud_name, ' ', 3), SUBSTRING_INDEX(stud_name, ' ', 1), ''),
        stud_birthdate,
        IF(stud_sex='M','MALE',IF(stud_sex='F','FEMALE',stud_sex)),
        stud_nationality, stud_religion, stud_entry_method,
        prog, stud_phone, stud_email, stud_entry_year, sess, home_district,
        stud_intake, 1,
        UPPER(SUBSTRING_INDEX(stud_name, ' ', 1)),
        Acad_GetApplicantDetails(6, prog),
        spec, stud_campus
    FROM acad_applications
    WHERE stud_entry_no = eno;

    INSERT IGNORE INTO acad_registration(
        regno, acad_year, semester, regstatus, studyyear,
        id_cardStatus, residence_status, reg_CardStatus,
        examClearance, clearedBy, registeredBy
    )
    VALUES(
        eno, CONCAT(eyr, '/', eyr + 1), 1, 'UNREGISTERED', 1,
        '-', '-', '-', 'UNCLEARED', '-', usr
    );

    INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date)
    VALUES(usr, 'Applicant Registration', CONCAT('prog: ', prog, ' Reg No: ', new_no), 'Registered Applicant', NOW());

END$$

DELIMITER ;
