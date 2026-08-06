-- =====================================================================
-- sp_EnsureStudentAccount — the canonical "fix a student account" routine.
-- Given a student number (MRU number OR slash-form academic number), if it
-- exists anywhere in the system it: ensures the applicant is ADMITTED, ensures a
-- real registration number, creates the acad_student record if missing, and
-- provisions the portal login (default password "123"). Idempotent + no
-- academic-year guard, so it works for any intake. Returns one row:
--   found (0/1), regno, student_no, had_login (0/1 before), action.
-- =====================================================================
DROP PROCEDURE IF EXISTS campus_dynamics.sp_EnsureStudentAccount;
DELIMITER //
CREATE PROCEDURE campus_dynamics.sp_EnsureStudentAccount(IN p_in CHAR(50))
BEGIN
    DECLARE v_eno CHAR(50);
    DECLARE v_student, v_applicant, v_had_login INT DEFAULT 0;
    DECLARE v_regno CHAR(50) DEFAULT '';
    DECLARE v_prog, v_sess, v_spec CHAR(50) DEFAULT '';
    DECLARE v_action VARCHAR(40) DEFAULT 'none';

    SET p_in = TRIM(p_in);

    -- Resolve to the canonical MRU number (stud_entry_no). Accept the slash-form too.
    SET v_eno = NULL;
    IF EXISTS (SELECT 1 FROM campus_dynamics.acad_applications WHERE stud_entry_no = p_in)
       OR EXISTS (SELECT 1 FROM campus_dynamics.acad_student WHERE regno = p_in) THEN
        SET v_eno = p_in;
    ELSE
        SELECT stud_entry_no INTO v_eno FROM campus_dynamics.acad_applications WHERE stud_reg_no = p_in LIMIT 1;
        IF v_eno IS NULL THEN
            SELECT regno INTO v_eno FROM campus_dynamics.acad_student WHERE entryno = p_in LIMIT 1;
        END IF;
    END IF;

    IF v_eno IS NULL THEN
        SELECT 0 AS found, '' AS regno, p_in AS student_no, 0 AS had_login, 'not_found' AS action;
    ELSE
        SELECT COUNT(*) INTO v_student   FROM campus_dynamics.acad_student      WHERE regno = v_eno;
        SELECT COUNT(*) INTO v_applicant FROM campus_dynamics.acad_applications WHERE stud_entry_no = v_eno;
        SELECT COUNT(*) INTO v_had_login FROM campus_dynamics_portal.my_aspnet_users u
               JOIN campus_dynamics_portal.my_aspnet_membership m ON m.userId = u.id WHERE u.name = v_eno;

        -- CASE A: known applicant but no student record yet -> admit + register.
        IF v_student = 0 AND v_applicant > 0 THEN
            UPDATE campus_dynamics.acad_applicant_choices
               SET adm_status = 1 WHERE stud_entry_no = v_eno AND Choice = 1 AND adm_status = 0;

            SELECT COALESCE(stud_reg_no, '') INTO v_regno FROM campus_dynamics.acad_applications WHERE stud_entry_no = v_eno LIMIT 1;
            IF v_regno = '' OR v_regno = '-' OR v_regno = '26/U/BAED/0055/K/DAY' THEN
                SET v_regno = campus_dynamics.acad_RegNoCreator(v_eno);   -- also provisions the login
                UPDATE campus_dynamics.acad_applications SET stud_reg_no = v_regno WHERE stud_entry_no = v_eno;
            END IF;

            SELECT prog_id, adm_session, sub_comb INTO v_prog, v_sess, v_spec
              FROM campus_dynamics.acad_applicant_choices WHERE stud_entry_no = v_eno AND Choice = 1 LIMIT 1;

            INSERT IGNORE INTO campus_dynamics.acad_student(
                entryno, regno, firstname, dob, gender, nationality, religion,
                entrymethod, progid, studPhone, email, entryyear, studsesion,
                home_dist, intake, gradSystemID, othername, duration, specialisation, studcampus, new_status)
            SELECT stud_reg_no, stud_entry_no,
                TRIM(IF(LOCATE(' ', stud_name) > 0, SUBSTRING(stud_name, LOCATE(' ', stud_name) + 1), '')),
                stud_birthdate,
                IF(stud_sex = 'M', 'MALE', IF(stud_sex = 'F', 'FEMALE', stud_sex)),
                stud_nationality, stud_religion, stud_entry_method,
                v_prog, stud_phone, stud_email, stud_entry_year, v_sess, home_district,
                stud_intake, 1,
                TRIM(SUBSTRING_INDEX(stud_name, ' ', 1)),
                Acad_GetApplicantDetails(6, v_prog),
                v_spec, stud_campus, 'ACTIVE'
            FROM campus_dynamics.acad_applications WHERE stud_entry_no = v_eno;

            UPDATE campus_dynamics.acad_applications SET app_status = 'REGISTERED' WHERE stud_entry_no = v_eno;
            SET v_action = IF(v_had_login > 0, 'registered', 'registered_new_login');
        ELSE
            SELECT COALESCE(entryno, '') INTO v_regno FROM campus_dynamics.acad_student WHERE regno = v_eno LIMIT 1;
            SET v_action = IF(v_had_login > 0, 'already_ok', 'login_provisioned');
        END IF;

        -- Ensure the portal login exists (idempotent) for ALL cases — default password "123".
        INSERT IGNORE INTO campus_dynamics_portal.my_aspnet_users(id, applicationId, name, isAnonymous, lastActivityDate, user_type)
            SELECT NULL, 1, v_eno, 0, NOW(), 'STUDENT' FROM dual;
        INSERT IGNORE INTO campus_dynamics_portal.my_aspnet_usersinroles(userId, roleId)
            SELECT id, 16 FROM campus_dynamics_portal.my_aspnet_users WHERE name = v_eno;
        INSERT INTO campus_dynamics_portal.my_aspnet_membership(
            userId, Email, Comment, Password, PasswordKey, PasswordFormat,
            PasswordQuestion, PasswordAnswer, IsApproved, LastActivityDate, LastLoginDate,
            LastPasswordChangedDate, CreationDate, IsLockedOut, LastLockedOutDate,
            FailedPasswordAttemptCount, FailedPasswordAttemptWindowStart,
            FailedPasswordAnswerAttemptCount, FailedPasswordAnswerAttemptWindowStart)
        SELECT u.id, '-', '-', 'XdiDC5xPHsIAtl8URiEgMUMLiCMIWEK8Q0WEWh9txzo=',
            'FGyxDhogiUILE9K+xekuPA==', 1, '-', 'hqU9IFrPDlHRzuufBgR52YUEH6Ke2sxxzedJxB5eC60=',
            1, NOW(), NOW(), NOW(), NOW(), 0, NOW(), 0, 0, 0, 0
        FROM campus_dynamics_portal.my_aspnet_users u
        WHERE u.name = v_eno
          AND NOT EXISTS (SELECT 1 FROM campus_dynamics_portal.my_aspnet_membership m WHERE m.userId = u.id);

        SELECT 1 AS found, v_regno AS regno, v_eno AS student_no, v_had_login AS had_login, v_action AS action;
    END IF;
END//
DELIMITER ;
