using System;
using System.Configuration;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Public verification page for the Masters Letter of Award.
/// Accepts GET parameter: reg_no
/// Queries acad_graduands + acad_student to verify award records.
/// Also loads university logo from acad_university for the page header.
/// No authentication required — this is a public-facing page.
/// </summary>
public partial class Verify : System.Web.UI.Page
{
    /// <summary>Reg number currently shown in the search box.</summary>
    public string RegNoInput { get; private set; }

    /// <summary>
    /// University logo as a Base64-encoded string, loaded from acad_university.logo.
    /// Rendered via data URI so no separate image endpoint is needed.
    /// Empty string when logo is unavailable — the markup falls back to text badge.
    /// </summary>
    public string LogoBase64 { get; private set; }

    /// <summary>
    /// MIME type detected from the logo bytes (image/jpeg or image/png).
    /// Defaults to image/jpeg which covers most university logos stored as BLOB.
    /// </summary>
    public string LogoMimeType { get; private set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        RegNoInput  = "";
        LogoBase64  = "";
        LogoMimeType = "image/jpeg";

        // ── 1. Load university logo for page header ────────────────────────
        LoadUniversityLogo();

        // ── 2. Run verification query if reg_no is in querystring ──────────
        string regNo = Request.QueryString["reg_no"];
        if (string.IsNullOrEmpty(regNo)) return;

        regNo      = regNo.Trim();
        RegNoInput = regNo;

        if (!IsValidRegNo(regNo))
        {
            litError.Text = "<div class=\"inline-error\">Invalid registration number format. "
                + "Please check and try again.</div>";
            return;
        }

        pnlResult.Visible = true;
        VerifyStudent(regNo);
    }

    // ── Private helpers ────────────────────────────────────────────────────

    private void LoadUniversityLogo()
    {
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (var conn = new MySql.Data.MySqlClient.MySqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new MySql.Data.MySqlClient.MySqlCommand(
                    "SELECT logo FROM acad_university LIMIT 1", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read() && !reader.IsDBNull(0))
                    {
                        byte[] bytes = (byte[])reader[0];
                        if (bytes != null && bytes.Length > 4)
                        {
                            LogoMimeType = DetectImageMime(bytes);
                            LogoBase64   = Convert.ToBase64String(bytes);
                        }
                    }
                }
            }
        }
        catch
        {
            // Logo load failure is non-fatal — page shows fallback text badge
        }
    }

    private void VerifyStudent(string regNo)
    {
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (var conn = new MySql.Data.MySqlClient.MySqlConnection(connStr))
            {
                conn.Open();

                const string sql = @"
                    SELECT
                        TRIM(IFNULL(
                            NULLIF(TRIM(CONCAT(IFNULL(s.firstname,''), ' ', IFNULL(s.othername,''))), ''),
                            IFNULL(g.stud_name, '')
                        ))                                                  AS stud_name,
                        TRIM(g.regno)                                       AS regno,
                        IFNULL(g.degclass, '')                              AS deg,
                        IFNULL((SELECT p.progname FROM acad_programme p
                                 WHERE p.progcode = g.progcode LIMIT 1), '') AS prog,
                        IFNULL(DATE_FORMAT(g.grad_date, '%d %M, %Y'), '')   AS grad_date,
                        IFNULL(DATE_FORMAT(g.comp_date, '%d %M, %Y'), '')   AS comp_date,
                        IFNULL(g.cgpa, 0)                                   AS cgpa
                    FROM acad_graduands g
                    LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(g.regno)
                    WHERE TRIM(g.regno) = @reg
                    LIMIT 1";

                using (var cmd = new MySql.Data.MySqlClient.MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@reg", regNo);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            pnlAuthentic.Visible = true;
                            pnlNotFound.Visible  = false;

                            string name = reader["stud_name"].ToString().Trim();
                            if (!string.IsNullOrEmpty(name))
                                name = new CultureInfo("en").TextInfo.ToTitleCase(name.ToLower());

                            litName.Text     = Encode(name);
                            litRegNo.Text    = Encode(reader["regno"].ToString().Trim());
                            litProg.Text     = Encode(reader["prog"].ToString().Trim());
                            litDeg.Text      = Encode(reader["deg"].ToString().Trim());
                            litGradDate.Text = Encode(reader["grad_date"].ToString().Trim());
                            litCompDate.Text = Encode(reader["comp_date"].ToString().Trim());

                            double cgpa;
                            litCgpa.Text = double.TryParse(reader["cgpa"].ToString(), out cgpa) && cgpa > 0
                                ? cgpa.ToString("0.00") : "N/A";
                        }
                        else
                        {
                            pnlAuthentic.Visible = false;
                            pnlNotFound.Visible  = true;
                            litNotFoundReg.Text  = Encode(regNo);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            pnlResult.Visible = false;
            litError.Text = "<div class=\"inline-error\">A database error occurred. "
                + "Please try again or contact the Registrar&rsquo;s Office.</div>";
            System.Diagnostics.Trace.TraceError(
                "Verify.aspx DB error for reg_no={0}: {1}", regNo, ex.Message);
        }
    }

    /// <summary>
    /// Detect MIME type from image magic bytes.
    ///   JPEG: FF D8 FF
    ///   PNG : 89 50 4E 47
    ///   GIF : 47 49 46 38
    ///   BMP : 42 4D
    /// Defaults to image/jpeg for unknown formats.
    /// </summary>
    private static string DetectImageMime(byte[] data)
    {
        if (data.Length >= 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF)
            return "image/jpeg";
        if (data.Length >= 4 && data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47)
            return "image/png";
        if (data.Length >= 4 && data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46)
            return "image/gif";
        if (data.Length >= 2 && data[0] == 0x42 && data[1] == 0x4D)
            return "image/bmp";
        return "image/jpeg";  // safe default for BLOBs that are usually JPEG
    }

    /// <summary>
    /// Allows letters, digits, forward-slash, hyphen, dot and space —
    /// the characters found in MRU registration numbers.
    /// Prevents obviously malformed input from reaching the parameterised query.
    /// </summary>
    private static bool IsValidRegNo(string regNo)
    {
        return regNo.Length <= 50 && Regex.IsMatch(regNo, @"^[A-Za-z0-9/\-\. ]+$");
    }

    private static string Encode(string s)
    {
        return HttpUtility.HtmlEncode(s ?? "");
    }
}
