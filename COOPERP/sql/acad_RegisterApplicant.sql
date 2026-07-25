DROP PROCEDURE IF EXISTS acad_RegisterApplicant;
DELIMITER $$
CREATE PROCEDURE acad_RegisterApplicant(eyr INT, eno CHAR(25), usr CHAR(35))
BEGIN
    DECLARE new_no, prog, sess, spec, campus, religion CHAR(35);
    DECLARE current_year CHAR(25);
    DECLARE requested_year CHAR(25);

    SET requested_year = CONCAT(eyr, '/', eyr + 1);

    SELECT acadyear INTO current_year
    FROM acad_acadyears
    WHERE is_current_year = 'Yes'
    LIMIT 1;

    IF current_year IS NOT NULL AND requested_year != current_year THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration is only allowed for the current academic year.';
    END IF;

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

    /* Semester registration is NO LONGER auto-created here. Students self-register
       per semester via the eportal wizard (sets regstatus='REGISTERED' and bills).
       The old 'UNREGISTERED' placeholder previously blocked self-registration. */

    INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date)
    VALUES(usr, 'Applicant Registration', CONCAT('prog: ', prog, ' Reg No: ', new_no), 'Registered Applicant', NOW());

END$$
DELIMITER ;
