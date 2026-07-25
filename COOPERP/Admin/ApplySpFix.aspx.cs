using System;
using System.Configuration;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_Admin_ApplySpFix : System.Web.UI.Page
{
    // Change this password before deploying, or delete the file after use.
    private const string AdminPassword = "mru@fix2026";

    private string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
            return cs != null ? cs.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) return;

        string pwd = Request.Form["pwd"] ?? "";
        if (pwd != AdminPassword)
        {
            litResult.Text = "<p class='err'>Wrong password.</p>";
            return;
        }

        // Two separate statements — MySqlCommand does not support DELIMITER syntax.
        const string dropSql = "DROP PROCEDURE IF EXISTS acad_RegisterApplicant";

        const string createSql = @"
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

    /* Semester registration is NO LONGER auto-created here. Students self-register
       per semester via the eportal wizard (sets regstatus='REGISTERED' and bills).
       The old 'UNREGISTERED' placeholder previously blocked self-registration. */

    INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date)
    VALUES(usr, 'Applicant Registration', CONCAT('prog: ', prog, ' Reg No: ', new_no), 'Registered Applicant', NOW());

END";

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(dropSql, conn))
                    cmd.ExecuteNonQuery();
                using (var cmd = new MySqlCommand(createSql, conn))
                    cmd.ExecuteNonQuery();
            }
            litResult.Text = "<p class='ok'>✓ Stored procedure updated successfully. The academic-year restriction has been removed. You may now delete this file.</p>";
        }
        catch (Exception ex)
        {
            litResult.Text = "<p class='err'>Error: " + HttpUtility.HtmlEncode(ex.Message) + "</p>";
        }
    }
}
