using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AdmissionLetterConfig : System.Web.UI.Page
{
    protected string SaveMessage { get; private set; }

    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // All editable config keys and their TextBox control IDs
    private static readonly string[][] ConfigMap = {
        // { cfg_key, TextBox_ID }
        new[]{ "provisional_title",          "txt_provisional_title" },
        new[]{ "official_title",             "txt_official_title" },
        new[]{ "registrar_name",             "txt_registrar_name" },
        new[]{ "registrar_title",            "txt_registrar_title" },
        new[]{ "registrar_sig_path",         "txt_registrar_sig_path" },
        new[]{ "university_name",            "txt_university_name" },
        new[]{ "admissions_email",           "txt_admissions_email" },
        new[]{ "logo_path",                  "txt_logo_path" },
        new[]{ "univ_tagline",               "txt_univ_tagline" },
        new[]{ "acad_year",                  "txt_acad_year" },
        new[]{ "reg_deadline_date",          "txt_reg_deadline_date" },
        new[]{ "reg_deadline_weeks",         "txt_reg_deadline_weeks" },
        new[]{ "sponsor_type",               "txt_sponsor_type" },
        new[]{ "default_tuition_fees",       "txt_default_tuition" },
        new[]{ "default_functional_fees",    "txt_default_functional" },
        new[]{ "nche_fee_amount",            "txt_nche_fee" },
        new[]{ "kabaka_fund_amount",         "txt_kabaka_fund" },
        new[]{ "intro_paragraph",            "txt_intro_paragraph" },
        new[]{ "body_paragraph",             "txt_body_paragraph" },
        new[]{ "requirements_html",          "txt_requirements_html" },
        new[]{ "disclaimer_html",            "txt_disclaimer_html" },
        new[]{ "closing_html",               "txt_closing_html" },
        new[]{ "fees_section_intro",         "txt_fees_section_intro" },
        new[]{ "payment_instructions_html",  "txt_payment_instructions_html" },
        new[]{ "additional_charges_html",    "txt_additional_charges_html" },
        new[]{ "orientation_html",           "txt_orientation_html" },
        new[]{ "change_prog_html",           "txt_change_prog_html" },
        new[]{ "registration_html",          "txt_registration_html" },
    };

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["username"] == null || string.IsNullOrWhiteSpace(Session["username"].ToString()))
        { Response.Redirect(ResolveUrl("~/Default.aspx")); return; }

        // AJAX
        string ajax = Request.QueryString["ajax"] ?? "";
        if (!string.IsNullOrEmpty(ajax))
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.TrySkipIisCustomErrors = true;
            try
            {
                switch (ajax)
                {
                    case "pf_list": HandlePfList(); break;
                    case "pf_save": HandlePfSave(); break;
                    case "pf_del":  HandlePfDel();  break;
                    default: Response.Write("{\"ok\":false,\"error\":\"Unknown action.\"}"); break;
                }
            }
            catch (Exception ex) { Response.Write("{\"ok\":false,\"error\":" + JsonStr(ex.Message) + "}"); }
            Response.End();
            return;
        }

        if (!IsPostBack)
        {
            using (var conn = Open()) { AdmissionLetterHelper.EnsureTablesExist(conn); PopulateForm(conn); }
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            using (var conn = Open())
            {
                foreach (var pair in ConfigMap)
                {
                    string key    = pair[0];
                    var    ctrl   = FindControl(pair[1]) as System.Web.UI.WebControls.TextBox;
                    string val    = ctrl != null ? (ctrl.Text ?? "").Trim() : "";
                    UpsertConfig(conn, key, val);
                }
            }
            SaveMessage = "✓ Configuration saved successfully.";
            ShowAlert(SaveMessage, true);
        }
        catch (Exception ex)
        {
            ShowAlert("Error saving: " + ex.Message, false);
        }
    }

    // ── Programme Fees AJAX ─────────────────────────────────────────────
    private void HandlePfList()
    {
        using (var conn = Open())
        {
            var sb = new StringBuilder("[");
            int n = 0;
            using (var cmd = new MySqlCommand(
                "SELECT prog_code, tuition_fees, functional_fees FROM admission_letter_prog_fees ORDER BY prog_code", conn))
            using (var r = cmd.ExecuteReader())
            {
                while (r.Read())
                {
                    if (n++ > 0) sb.Append(',');
                    sb.AppendFormat("{{\"code\":{0},\"tuition\":{1},\"functional\":{2}}}",
                        JsonStr(r["prog_code"].ToString()),
                        r["tuition_fees"],
                        r["functional_fees"]);
                }
            }
            sb.Append("]");
            Response.Write("{\"ok\":true,\"rows\":" + sb + "}");
        }
    }

    private void HandlePfSave()
    {
        var data = ReadJson();
        string code = GetStr(data, "code").ToUpper();
        int tuition    = GetInt(data, "tuition");
        int functional = GetInt(data, "functional");
        if (string.IsNullOrEmpty(code)) throw new Exception("Programme code required.");
        using (var conn = Open())
        using (var cmd = new MySqlCommand(@"
            INSERT INTO admission_letter_prog_fees (prog_code, tuition_fees, functional_fees, updated_at)
            VALUES (@c,@t,@f,NOW())
            ON DUPLICATE KEY UPDATE tuition_fees=VALUES(tuition_fees), functional_fees=VALUES(functional_fees), updated_at=NOW()", conn))
        {
            cmd.Parameters.AddWithValue("@c", code);
            cmd.Parameters.AddWithValue("@t", tuition);
            cmd.Parameters.AddWithValue("@f", functional);
            cmd.ExecuteNonQuery();
        }
        Response.Write("{\"ok\":true}");
    }

    private void HandlePfDel()
    {
        var data = ReadJson();
        string code = GetStr(data, "code").ToUpper();
        if (string.IsNullOrEmpty(code)) throw new Exception("Programme code required.");
        using (var conn = Open())
        using (var cmd = new MySqlCommand("DELETE FROM admission_letter_prog_fees WHERE prog_code=@c", conn))
        {
            cmd.Parameters.AddWithValue("@c", code);
            cmd.ExecuteNonQuery();
        }
        Response.Write("{\"ok\":true}");
    }

    // ── DB Helpers ──────────────────────────────────────────────────────
    private void PopulateForm(MySqlConnection conn)
    {
        var cfg = AdmissionLetterHelper.LoadConfig(conn);
        foreach (var pair in ConfigMap)
        {
            var ctrl = FindControl(pair[1]) as System.Web.UI.WebControls.TextBox;
            if (ctrl != null && cfg.ContainsKey(pair[0]))
                ctrl.Text = cfg[pair[0]];
        }
    }

    private void UpsertConfig(MySqlConnection conn, string key, string value)
    {
        using (var cmd = new MySqlCommand(@"
            INSERT INTO admission_letter_config (cfg_key, cfg_value, updated_at, updated_by)
            VALUES (@k,@v,NOW(),@u)
            ON DUPLICATE KEY UPDATE cfg_value=VALUES(cfg_value), updated_at=NOW(), updated_by=VALUES(updated_by)", conn))
        {
            cmd.Parameters.AddWithValue("@k", key);
            cmd.Parameters.AddWithValue("@v", value);
            cmd.Parameters.AddWithValue("@u", Session["username"] != null ? Session["username"].ToString() : "admin");
            cmd.ExecuteNonQuery();
        }
    }

    // ── UI Helpers ──────────────────────────────────────────────────────
    private void ShowAlert(string msg, bool ok)
    {
        pnlAlert.Visible = true;
        alertBox.Attributes["class"] = "alc-alert " + (ok ? "alc-alert--ok" : "alc-alert--err");
        alertBox.InnerHtml = Server.HtmlEncode(msg);
    }

    private MySqlConnection Open()
    {
        var conn = new MySqlConnection(ConnStr);
        conn.Open();
        return conn;
    }

    // ── JSON Helpers ────────────────────────────────────────────────────
    private Dictionary<string, object> ReadJson()
    {
        string body = "";
        using (var sr = new System.IO.StreamReader(Request.InputStream))
            body = sr.ReadToEnd();
        if (string.IsNullOrWhiteSpace(body)) return new Dictionary<string, object>();
        return new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(body)
               ?? new Dictionary<string, object>();
    }
    private static string GetStr(Dictionary<string, object> d, string k)
    {
        return d.ContainsKey(k) ? Convert.ToString(d[k] ?? "") : "";
    }
    private static int GetInt(Dictionary<string, object> d, string k)
    {
        int n; int.TryParse(GetStr(d, k), out n); return n;
    }
    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                       .Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
    }
}
