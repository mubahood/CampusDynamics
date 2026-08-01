using System;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AdmissionLetter : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Auth — allow preview without student for template testing
        bool isStaff = Session["username"] != null &&
                       !string.IsNullOrWhiteSpace(Session["username"].ToString());
        if (!isStaff)
        { Response.Redirect(ResolveUrl("~/Default.aspx")); return; }

        string eno      = (Request.QueryString["eno"]  ?? "").Trim();
        string typeQs   = (Request.QueryString["type"] ?? "provisional").ToLower().Trim();
        bool   isProvis = typeQs != "official";
        bool   preview  = Request.QueryString["preview"] == "1";

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                AdmissionLetterHelper.EnsureTablesExist(conn);

                var cfg = AdmissionLetterHelper.LoadConfig(conn);

                // Preview mode — show a sample letter without real student data
                AdmissionLetterHelper.StudentLetterData student;
                int tuition, functional;

                if (preview || string.IsNullOrEmpty(eno))
                {
                    student = SampleStudent(cfg);
                    tuition = SafeInt(AdmissionLetterHelper.GetCfg(cfg, "default_tuition_fees", "780000"));
                    functional = SafeInt(AdmissionLetterHelper.GetCfg(cfg, "default_functional_fees", "867000"));
                }
                else
                {
                    student = AdmissionLetterHelper.LoadStudentData(conn, eno);
                    if (!student.Found)
                    {
                        litBody.Text = "<p style='color:#c62828;font-family:sans-serif;'>Applicant not found: "
                            + Server.HtmlEncode(eno) + "</p>";
                        return;
                    }
                    var fees = AdmissionLetterHelper.GetProgrammeFees(conn, student.ProgrammeCode, cfg);
                    tuition    = fees.Tuition;
                    functional = fees.Functional;
                }

                string title = isProvis
                    ? AdmissionLetterHelper.GetCfg(cfg, "provisional_title", "PROVISIONAL ADMISSION LETTER")
                    : AdmissionLetterHelper.GetCfg(cfg, "official_title", "ADMISSION LETTER");

                litPageTitle.Text = "<title>" + HE(title) + " — " + HE(student.StudentName) + "</title>";
                litToolbarTitle.Text = HE(title) + (preview ? " (PREVIEW)" : "") +
                    (student.Found ? " — " + HE(student.StudentName) : "");

                litBody.Text = AdmissionLetterHelper.BuildLetterHtml(
                    student, tuition, functional, cfg, isProvis);
            }
        }
        catch (Exception ex)
        {
            litBody.Text = "<p style='color:#c62828;font-family:sans-serif;padding:20px;'>" +
                "Error loading letter: " + Server.HtmlEncode(ex.Message) + "</p>";
        }
    }

    // ── Sample data for preview mode ─────────────────────────────────────
    private static AdmissionLetterHelper.StudentLetterData SampleStudent(
        System.Collections.Generic.Dictionary<string, string> cfg)
    {
        return new AdmissionLetterHelper.StudentLetterData
        {
            Found          = true,
            StudentName    = "SAMPLE STUDENT NAME",
            EntryNo        = "MRU" + DateTime.Now.Year + "000000",
            RegNo          = "-",
            Title          = "MR.",
            ProgrammeName  = "BACHELOR OF INFORMATION TECHNOLOGY",
            ProgrammeCode  = "BIT",
            FacultyName    = "Faculty of Science, Information Technology, Engineering, Art and Design",
            DepartmentName = "Department of Information Technology",
            CampusName     = "Kakeeka",
            StudySession   = "Day",
            EntryYear      = DateTime.Now.Year.ToString(),
        };
    }

    private static string HE(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
    private static int SafeInt(string s) { int n; int.TryParse((s ?? "").Trim(), out n); return n; }
}
