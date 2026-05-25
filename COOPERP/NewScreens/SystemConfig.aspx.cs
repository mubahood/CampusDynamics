using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

/// <summary>
/// SystemConfig - manages the system_config table with school identity,
/// application settings, and live support meeting configuration.
/// All fields are optional with sensible default values.
/// </summary>
public partial class COOPERP_NewScreens_SystemConfig : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // -- Default values -------------------------------------------------------
    private const string D_SCHOOL_NAME = "Makerere University";
    private const string D_SCHOOL_LOGO = "";
    private const string D_SCHOOL_ADDRESS = "Kampala, Uganda";
    private const string D_SCHOOL_PHONE = "";
    private const string D_SCHOOL_EMAIL = "";
    private const string D_APP_STATUS = "Open";
    private const string D_APP_START_DATE = "";
    private const string D_APP_END_DATE = "";
    private const string D_LIVE_SUPPORT_ENABLED = "false";
    private const string D_LIVE_SUPPORT_START = "09:00";
    private const string D_LIVE_SUPPORT_END = "17:00";
    private const string D_LIVE_SUPPORT_LINK = "";

    // -------------------------------------------------------------------------

    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureTableExists();
        if (!IsPostBack)
            LoadConfig();
    }

    // -- Auto-create system_config if it doesn't exist yet --------------------
    private void EnsureTableExists()
    {
        try
        {
            ExecuteNonQuery(@"
                CREATE TABLE IF NOT EXISTS system_config (
                    id                              INT           NOT NULL DEFAULT 1,
                    school_name                     VARCHAR(255)  NULL,
                    school_logo                     VARCHAR(500)  NULL,
                    school_address                  TEXT          NULL,
                    school_phone                    VARCHAR(20)   NULL,
                    school_email                    VARCHAR(100)  NULL,
                    app_status                      VARCHAR(50)   NULL,
                    app_start_date                  DATE          NULL,
                    app_end_date                    DATE          NULL,
                    live_support_enabled            ENUM('true','false') NOT NULL DEFAULT 'false',
                    live_support_start_time         VARCHAR(5)    NULL,
                    live_support_end_time           VARCHAR(5)    NULL,
                    live_support_link               VARCHAR(500)  NULL,
                    live_support_admin_message      TEXT          NULL,
                    last_updated                    DATETIME      NULL,
                    updated_by                      VARCHAR(100)  NULL,
                    PRIMARY KEY (id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            // Seed the single config row if it doesn't exist
            ExecuteNonQuery("INSERT IGNORE INTO system_config (id) VALUES (1)");

            // Migration: Add live_support_admin_message column if it doesn't exist (MySQL 5.7 compatible)
            try
            {
                // Check if column exists
                DataTable dtCheck = ExecuteQuery(
                    "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'system_config' " +
                    "AND COLUMN_NAME = 'live_support_admin_message'");
                
                if (dtCheck == null || dtCheck.Rows.Count == 0)
                {
                    // Column doesn't exist, add it
                    ExecuteNonQuery("ALTER TABLE system_config ADD COLUMN live_support_admin_message TEXT NULL");
                }
            }
            catch { /* Column exists or cannot be added, will handle on save */ }
        }
        catch { /* LoadConfig will surface the real error */ }
    }

    // -- Load config from DB into form controls --------------------------------
    private void LoadConfig()
    {
        DataTable dt;
        try
        {
            dt = ExecuteQuery("SELECT * FROM system_config WHERE id = 1");
        }
        catch (Exception ex)
        {
            ShowBanner("Database error: " + ex.Message, false);
            btnSave.Enabled = false;
            return;
        }

        if (dt.Rows.Count == 0) return; // DB defaults are good

        DataRow r = dt.Rows[0];

        // School Identity
        txtSchoolName.Text = SafeString(r["school_name"], D_SCHOOL_NAME);
        txtSchoolLogo.Text = SafeString(r["school_logo"], D_SCHOOL_LOGO);
        txtSchoolAddress.Text = SafeString(r["school_address"], D_SCHOOL_ADDRESS);
        txtSchoolPhone.Text = SafeString(r["school_phone"], D_SCHOOL_PHONE);
        txtSchoolEmail.Text = SafeString(r["school_email"], D_SCHOOL_EMAIL);

        // Application Settings
        string appStatus = SafeString(r["app_status"], D_APP_STATUS);
        if (!string.IsNullOrEmpty(appStatus))
            ddlAppStatus.SelectedValue = appStatus;

        string appStart = r["app_start_date"] != DBNull.Value ? Convert.ToDateTime(r["app_start_date"]).ToString("yyyy-MM-dd") : "";
        string appEnd = r["app_end_date"] != DBNull.Value ? Convert.ToDateTime(r["app_end_date"]).ToString("yyyy-MM-dd") : "";
        txtAppStartDate.Text = appStart;
        txtAppEndDate.Text = appEnd;

        // Live Support Meeting
        string lsEnabled = SafeString(r["live_support_enabled"], D_LIVE_SUPPORT_ENABLED);
        hfLiveSupportEnabled.Value = lsEnabled;
        txtMeetingStartTime.Text = SafeString(r["live_support_start_time"], D_LIVE_SUPPORT_START);
        txtMeetingEndTime.Text = SafeString(r["live_support_end_time"], D_LIVE_SUPPORT_END);
        txtMeetingLink.Text = SafeString(r["live_support_link"], D_LIVE_SUPPORT_LINK);
        
        // Get admin message if column exists
        try
        {
            if (dt.Columns.Contains("live_support_admin_message"))
                txtLiveSupportAdminMessage.Text = SafeString(r["live_support_admin_message"], "");
        }
        catch { }

        // Audit banner
        if (r["last_updated"] != DBNull.Value && r["updated_by"] != DBNull.Value
            && !string.IsNullOrEmpty(r["updated_by"].ToString()))
        {
            DateTime updAt = Convert.ToDateTime(r["last_updated"]);
            string updBy = r["updated_by"].ToString();
            litLastUpdated.Text = string.Format(
                "Configuration last saved on <strong>{0}</strong> by <strong>{1}</strong>.",
                updAt.ToString("dd MMM yyyy, hh:mm tt"),
                HttpUtility.HtmlEncode(updBy));
            pnlLastUpdated.Visible = true;
        }
    }

    // -- Save ------------------------------------------------------------------
    protected void btnSave_Click(object sender, EventArgs e)
    {
        // Ensure migration has run before attempting save
        EnsureTableExists();
        
        var errors = new List<string>();

        // Parse input values
        string schoolName = txtSchoolName.Text.Trim();
        string schoolLogo = txtSchoolLogo.Text.Trim();
        string schoolAddress = txtSchoolAddress.Text.Trim();
        string schoolPhone = txtSchoolPhone.Text.Trim();
        string schoolEmail = txtSchoolEmail.Text.Trim();
        string appStatus = ddlAppStatus.SelectedValue;
        string appStartDate = txtAppStartDate.Text.Trim();
        string appEndDate = txtAppEndDate.Text.Trim();
        string lsEnabled = hfLiveSupportEnabled.Value;
        string lsStartTime = txtMeetingStartTime.Text.Trim();
        string lsEndTime = txtMeetingEndTime.Text.Trim();
        string lsLink = txtMeetingLink.Text.Trim();
        string lsAdminMessage = txtLiveSupportAdminMessage.Text.Trim();

        // Validate email if provided
        if (!string.IsNullOrEmpty(schoolEmail) && !IsValidEmail(schoolEmail))
            errors.Add("Invalid school email format.");

        // Validate dates if provided
        DateTime tmpDate;
        if (!string.IsNullOrEmpty(appStartDate) && !DateTime.TryParse(appStartDate, out tmpDate))
            errors.Add("Invalid application start date.");
        if (!string.IsNullOrEmpty(appEndDate) && !DateTime.TryParse(appEndDate, out tmpDate))
            errors.Add("Invalid application end date.");

        // Validate date order if both provided
        if (!string.IsNullOrEmpty(appStartDate) && !string.IsNullOrEmpty(appEndDate))
        {
            DateTime start = DateTime.Parse(appStartDate);
            DateTime end = DateTime.Parse(appEndDate);
            if (start > end)
                errors.Add("Application start date must be before end date.");
        }

        // Validate time format if live support enabled
        if (lsEnabled == "true")
        {
            if (!string.IsNullOrEmpty(lsStartTime) && !IsValidTimeFormat(lsStartTime))
                errors.Add("Invalid meeting start time format (use HH:MM).");
            if (!string.IsNullOrEmpty(lsEndTime) && !IsValidTimeFormat(lsEndTime))
                errors.Add("Invalid meeting end time format (use HH:MM).");

            // Validate time order
            if (!string.IsNullOrEmpty(lsStartTime) && !string.IsNullOrEmpty(lsEndTime))
            {
                TimeSpan start = TimeSpan.Parse(lsStartTime);
                TimeSpan end = TimeSpan.Parse(lsEndTime);
                if (start >= end)
                    errors.Add("Meeting start time must be before end time.");
            }

            // Validate meeting link if provided
            if (!string.IsNullOrEmpty(lsLink) && !IsValidUrl(lsLink))
                errors.Add("Invalid meeting link URL.");
        }

        if (errors.Count > 0)
        {
            ShowBanner(string.Join(" ", errors), false);
            return;
        }

        // Build and execute UPDATE
        try
        {
            string query = @"
                UPDATE system_config SET
                    school_name = @schoolName,
                    school_logo = @schoolLogo,
                    school_address = @schoolAddress,
                    school_phone = @schoolPhone,
                    school_email = @schoolEmail,
                    app_status = @appStatus,
                    app_start_date = @appStartDate,
                    app_end_date = @appEndDate,
                    live_support_enabled = @lsEnabled,
                    live_support_start_time = @lsStartTime,
                    live_support_end_time = @lsEndTime,
                    live_support_link = @lsLink,
                    live_support_admin_message = @lsAdminMessage,
                    last_updated = NOW(),
                    updated_by = @userName
                WHERE id = 1";

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@schoolName", string.IsNullOrEmpty(schoolName) ? (object)DBNull.Value : schoolName);
                    cmd.Parameters.AddWithValue("@schoolLogo", string.IsNullOrEmpty(schoolLogo) ? (object)DBNull.Value : schoolLogo);
                    cmd.Parameters.AddWithValue("@schoolAddress", string.IsNullOrEmpty(schoolAddress) ? (object)DBNull.Value : schoolAddress);
                    cmd.Parameters.AddWithValue("@schoolPhone", string.IsNullOrEmpty(schoolPhone) ? (object)DBNull.Value : schoolPhone);
                    cmd.Parameters.AddWithValue("@schoolEmail", string.IsNullOrEmpty(schoolEmail) ? (object)DBNull.Value : schoolEmail);
                    cmd.Parameters.AddWithValue("@appStatus", string.IsNullOrEmpty(appStatus) ? (object)DBNull.Value : appStatus);
                    cmd.Parameters.AddWithValue("@appStartDate", string.IsNullOrEmpty(appStartDate) ? (object)DBNull.Value : appStartDate);
                    cmd.Parameters.AddWithValue("@appEndDate", string.IsNullOrEmpty(appEndDate) ? (object)DBNull.Value : appEndDate);
                    cmd.Parameters.AddWithValue("@lsEnabled", lsEnabled);
                    cmd.Parameters.AddWithValue("@lsStartTime", string.IsNullOrEmpty(lsStartTime) ? (object)DBNull.Value : lsStartTime);
                    cmd.Parameters.AddWithValue("@lsEndTime", string.IsNullOrEmpty(lsEndTime) ? (object)DBNull.Value : lsEndTime);
                    cmd.Parameters.AddWithValue("@lsLink", string.IsNullOrEmpty(lsLink) ? (object)DBNull.Value : lsLink);
                    cmd.Parameters.AddWithValue("@lsAdminMessage", string.IsNullOrEmpty(lsAdminMessage) ? (object)DBNull.Value : lsAdminMessage);
                    cmd.Parameters.AddWithValue("@userName", HttpContext.Current.User.Identity.Name ?? "admin");

                    cmd.ExecuteNonQuery();
                }
            }

            ShowBanner("✓ Configuration saved successfully.", true);
            System.Threading.Thread.Sleep(1500);
            LoadConfig(); // Reload to show updated timestamp
        }
        catch (Exception ex)
        {
            ShowBanner("Error saving configuration: " + ex.Message, false);
        }
    }

    // -- Reset to defaults ---------------------------------------------------
    protected void btnReset_Click(object sender, EventArgs e)
    {
        try
        {
            ExecuteNonQuery(@"
                UPDATE system_config SET
                    school_name = NULL,
                    school_logo = NULL,
                    school_address = NULL,
                    school_phone = NULL,
                    school_email = NULL,
                    app_status = NULL,
                    app_start_date = NULL,
                    app_end_date = NULL,
                    live_support_enabled = 'false',
                    live_support_start_time = NULL,
                    live_support_end_time = NULL,
                    live_support_link = NULL,
                    live_support_admin_message = NULL,
                    last_updated = NOW(),
                    updated_by = @userName
                WHERE id = 1");

            foreach (var ctrl in new[] {
                txtSchoolName, txtSchoolLogo, txtSchoolAddress, txtSchoolPhone, txtSchoolEmail,
                txtAppStartDate, txtAppEndDate, txtMeetingStartTime, txtMeetingEndTime, txtMeetingLink,
                txtLiveSupportAdminMessage
            })
                ctrl.Text = "";

            hfLiveSupportEnabled.Value = "false";
            ddlAppStatus.SelectedIndex = 0;

            ShowBanner("✓ Configuration reset to factory defaults.", true);
            System.Threading.Thread.Sleep(1500);
            LoadConfig();
        }
        catch (Exception ex)
        {
            ShowBanner("Error resetting configuration: " + ex.Message, false);
        }
    }

    // -- Database helpers ----------------------------------------------------
    private DataTable ExecuteQuery(string query)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                adapter.Fill(dt);
                return dt;
            }
        }
    }

    private void ExecuteNonQuery(string query)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }
    }

    // -- Validation helpers --------------------------------------------------
    private bool IsValidEmail(string email)
    {
        try
        {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch { return false; }
    }

    private bool IsValidTimeFormat(string time)
    {
        // Format: HH:MM in 24-hour
        if (string.IsNullOrEmpty(time)) return false;
        if (!time.Contains(":")) return false;
        
        var parts = time.Split(':');
        if (parts.Length != 2) return false;
        
        int hours, minutes;
        if (!int.TryParse(parts[0], out hours) || hours < 0 || hours > 23) return false;
        if (!int.TryParse(parts[1], out minutes) || minutes < 0 || minutes > 59) return false;
        
        return true;
    }

    private bool IsValidUrl(string url)
    {
        try
        {
            new Uri(url);
            return true;
        }
        catch { return false; }
    }

    private string SafeString(object value, string defaultValue)
    {
        if (value == null || value == DBNull.Value)
            return defaultValue;
        string s = value.ToString().Trim();
        return string.IsNullOrEmpty(s) ? defaultValue : s;
    }

    private void ShowBanner(string message, bool isSuccess)
    {
        litResult.Text = message;
        divResult.Attributes["class"] = isSuccess ? "sys-result sys-result--ok" : "sys-result sys-result--err";
        divResult.Style["display"] = "flex";
    }
}
