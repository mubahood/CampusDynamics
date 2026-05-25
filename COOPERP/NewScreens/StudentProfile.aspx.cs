using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_StudentProfile : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            LoadProfile();
    }

    private void LoadProfile()
    {
        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            ShowError("No registration number provided. Please specify ?regno= in the URL.");
            return;
        }

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // ── Student record ──────────────────────────────────────────
                // regno param may be a traditional reg no (stored in entryno)
                // or an entry number (stored in regno). Search both.
                const string sql = @"
                    SELECT s.regno, s.entryno,
                           s.firstname, s.othername,
                           s.gender, s.dob,
                           s.nationality, s.religion,
                           IFNULL(s.national_id, IFNULL(a.national_id,'')) AS national_id,
                           s.home_dist,
                           s.studPhone, s.email,
                           IFNULL(a.next_kin,'') AS next_of_kin,
                           IFNULL(a.kin_contacts,'') AS kin_phone,
                           IFNULL(a.kin_relationship,'') AS kin_relation,
                           s.progid,
                           IFNULL(p.progname,'') AS progname,
                           s.specialisation,
                           s.entrymethod, s.entryyear, s.intake,
                           s.studsesion, s.studcampus,
                           s.duration, s.gradSystemID,
                           IFNULL(a.stud_sponsor, '') AS sponsor,
                           IFNULL(a.sponsor_contact, '') AS sponsorContact,
                           IFNULL(s.new_status,'ACTIVE') AS stud_status
                    FROM acad_student s
                    LEFT JOIN acad_programme p ON p.progcode = s.progid
                    LEFT JOIN acad_applications a ON a.stud_entry_no = s.entryno
                    WHERE s.entryno = @r OR s.regno = @r
                    LIMIT 1";

                DataRow row = null;
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    var dt = new DataTable();
                    new MySqlDataAdapter(cmd).Fill(dt);
                    if (dt.Rows.Count > 0) row = dt.Rows[0];
                }

                if (row == null)
                {
                    ShowError("Student not found: <strong>" + HE(regno) + "</strong>. Please check the registration number.");
                    return;
                }

                // ── Populate bio ────────────────────────────────────────────
                string firstName  = Val(row, "firstname");
                string otherName  = Val(row, "othername");
                string fullName   = (firstName + " " + otherName).Trim();
                string status     = Val(row, "stud_status").ToUpper();
                string progCode   = Val(row, "progid");
                string progName   = Val(row, "progname");
                // entryno = traditional reg no (26/U/...), regno = entry no (MRU...)
                string regNoDisplay = Val(row, "entryno");  // registration number shown to user
                string entryNoKey   = Val(row, "regno");    // entry number used as DB key in acad_registration

                litHeaderSub.Text  = HE(fullName) + " &mdash; " + HE(regNoDisplay);
                litFullName.Text   = HE(fullName);
                litRegNo.Text      = HE(regNoDisplay);
                litStatusBadge.Text = FormatStatusBadge(status);

                // Initials for placeholder
                string initials = "";
                if (fullName.Length > 0) initials += fullName[0];
                int sp = fullName.IndexOf(' ');
                if (sp >= 0 && sp + 1 < fullName.Length) initials += fullName[sp + 1];
                photoPlaceholder.InnerText = initials.ToUpper();

                // Quick facts (left card)
                litProg.Text       = HE(string.IsNullOrEmpty(progName) ? progCode : progCode + " — " + progName);
                litEntryYear.Text  = HE(Val(row, "entryyear"));
                litSession.Text    = HE(Val(row, "studsesion"));
                litIntake.Text     = HE(Val(row, "intake"));
                litCampus.Text     = HE(Val(row, "studcampus"));

                // Quick links
                string encReg = HttpUtility.UrlEncode(regNoDisplay);
                aLedger.HRef   = "StudentLedgers.aspx?regno=" + encReg;
                aReceipts.HRef = "StudentReceipts.aspx?regno=" + encReg;
                aDocs.HRef     = "StudentDocuments.aspx?regno=" + encReg;

                // Bio tab
                litFirstName.Text   = HE(firstName);
                litOtherName.Text   = HE(otherName);
                litGender.Text      = HE(Val(row, "gender"));
                litDOB.Text         = FormatDate(Val(row, "dob"));
                litNationality.Text = HE(Val(row, "nationality"));
                litReligion.Text    = HE(Val(row, "religion"));
                litNationalID.Text  = HE(Val(row, "national_id"));
                litDistrict.Text    = HE(Val(row, "home_dist"));

                // Contact tab
                litPhone.Text       = HE(Val(row, "studPhone"));
                litEmail.Text       = HE(Val(row, "email"));
                litNOK.Text         = HE(Val(row, "next_of_kin"));
                litNOKPhone.Text    = HE(Val(row, "kin_phone"));
                litNOKRel.Text      = HE(Val(row, "kin_relation"));

                // Academic tab
                litProgFull.Text         = HE(progName);
                litProgCode.Text         = HE(progCode);
                litSpec.Text             = HE(Val(row, "specialisation"));
                litEntryMethod.Text      = HE(Val(row, "entrymethod"));
                litEntryYearFull.Text    = HE(Val(row, "entryyear"));
                litIntakeFull.Text       = HE(Val(row, "intake"));
                litSessionFull.Text      = HE(Val(row, "studsesion"));
                litDuration.Text         = HE(Val(row, "duration"));
                litGradSys.Text          = HE(Val(row, "gradSystemID"));
                litSponsor.Text          = HE(Val(row, "sponsor"));
                litSponsorContact.Text   = HE(Val(row, "sponsorContact"));

                // ── Registration history ────────────────────────────────────
                // acad_registration.regno stores the entry number (regno column of acad_student)
                const string regSql = @"
                    SELECT acad_year, semester, studyyear, regstatus,
                           registeredBy
                    FROM acad_registration
                    WHERE regno = @r
                    ORDER BY acad_year DESC, semester ASC";

                var sb = new StringBuilder();
                int regCount = 0;
                using (var cmd = new MySqlCommand(regSql, conn))
                {
                    cmd.Parameters.AddWithValue("@r", entryNoKey);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            regCount++;
                            string regStatus = rdr["regstatus"] != DBNull.Value ? rdr["regstatus"].ToString() : "";
                            sb.Append("<tr>");
                            sb.AppendFormat("<td>{0}</td>", HE(rdr["acad_year"].ToString()));
                            sb.AppendFormat("<td>{0}</td>", HE(rdr["semester"].ToString()));
                            sb.AppendFormat("<td>Year {0}</td>", HE(rdr["studyyear"].ToString()));
                            sb.AppendFormat("<td>{0}</td>", FormatRegStatus(regStatus));
                            sb.AppendFormat("<td>{0}</td>", HE(rdr["registeredBy"] != DBNull.Value ? rdr["registeredBy"].ToString() : "—"));
                            sb.Append("</tr>");
                        }
                    }
                }

                if (regCount == 0)
                {
                    pnlNoReg.Visible = true;
                }
                else
                {
                    litRegRows.Text = sb.ToString();
                    pnlRegTable.Visible = true;
                }

                pnlMain.Visible = true;
            }
        }
        catch (Exception ex)
        {
            ShowError("Error loading student profile: " + HE(ex.Message));
        }
    }

    private static string Val(DataRow row, string col)
    {
        if (!row.Table.Columns.Contains(col)) return "";
        return row[col] == DBNull.Value ? "" : row[col].ToString().Trim();
    }

    private static string HE(string s)
    {
        return HttpUtility.HtmlEncode(s ?? "");
    }

    private static string FormatDate(string s)
    {
        if (string.IsNullOrEmpty(s)) return "—";
        DateTime d;
        if (DateTime.TryParse(s, out d)) return d.ToString("dd/MM/yyyy");
        return HE(s);
    }

    private static string FormatStatusBadge(string status)
    {
        switch (status)
        {
            case "ACTIVE":    return "<span class='sp-badge sp-badge--active'>Active</span>";
            case "ALUMNI":    return "<span class='sp-badge sp-badge--alumni'>Alumni</span>";
            case "INACTIVE":  return "<span class='sp-badge sp-badge--inactive'>Inactive</span>";
            case "WITHDRAWN": return "<span class='sp-badge sp-badge--inactive'>Withdrawn</span>";
            default:          return "<span class='sp-badge sp-badge--pending'>" + HE(status) + "</span>";
        }
    }

    private static string FormatRegStatus(string s)
    {
        string upper = (s ?? "").ToUpper().Trim();
        string css = "sp-status-other";
        if (upper == "REGISTERED" || upper == "LATE REGISTERED" || upper == "LATE-REGISTERED")
            css = "sp-status-registered";
        else if (upper == "UNREGISTERED")
            css = "sp-status-unregistered";
        else if (upper == "CLEARED")
            css = "sp-status-cleared";
        return "<span class='sp-status-pill " + css + "'>" + HE(s) + "</span>";
    }

    private void ShowError(string html)
    {
        pnlError.Visible = true;
        litError.Text = html;
        litHeaderSub.Text = "Student not found";
    }
}
