using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using MySql.Data.MySqlClient;

public partial class COOPERP_fonts_lg : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_lock.Width = 500;
        pop_lock.ShowOnPageLoad = true;
        Session["otp"] = null;

        // Hide the forgot-password panel on every page cycle; cmdForgot_Click re-shows it.
        pnlForgot.Style["display"] = "none";
    }

    // ── LOGIN ────────────────────────────────────────────────────────────────

    protected void Login1_LoggingIn1(object sender, LoginCancelEventArgs e)
    {
        // ASPxTextBox does not implement ITextControl, so Login1.UserName / Login1.Password
        // always return "" — read the actual posted form values by UniqueID instead.
        string prefix   = Login1.UniqueID + "$";
        string input    = (Request.Form[prefix + "UserName"] ?? "").Trim();
        string password = Request.Form[prefix + "Password"] ?? "";

        if (string.IsNullOrEmpty(input))
            return; // RequiredFieldValidator will show the "required" message

        // Resolve email / staff-number / EMP_CODE to the real membership username
        string resolved = ResolveToMembershipUsername(input);
        if (string.IsNullOrEmpty(resolved)) resolved = input;

        // Take full control of authentication — the Login control cannot read DX textbox values
        e.Cancel = true;

        if (Membership.ValidateUser(resolved, password))
        {
            MembershipUser mu = Membership.GetUser(resolved);
            if (mu != null && mu.IsLockedOut) mu.UnlockUser();

            FormsAuthentication.SetAuthCookie(resolved, true);
            Session["username"] = resolved;

            RoleAccessService.LoadUserAccess(resolved);

            string empName = LoadEmployeeDisplayName(resolved);
            if (!string.IsNullOrEmpty(empName)) Session["ScreenName"] = empName;

            string cacheKey = resolved + password;
            HttpContext.Current.Cache.Insert(cacheKey, Session.SessionID, null,
                DateTime.MaxValue, TimeSpan.FromDays(365),
                System.Web.Caching.CacheItemPriority.NotRemovable, null);
            Session["usernm"] = cacheKey;

            Response.Redirect("~/MyApplications.aspx");
        }
        else
        {
            // Show a specific reason so the user knows what to do next
            var lit = Login1.FindControl("FailureText") as Literal;
            if (lit != null)
                lit.Text = BuildLoginFailureMessage(resolved, input);
        }
    }

    private string BuildLoginFailureMessage(string resolved, string originalInput)
    {
        try
        {
            MembershipUser mu = Membership.GetUser(resolved);

            if (mu == null)
            {
                // Resolution found something in HR but no membership account exists
                if (!string.Equals(resolved, originalInput, StringComparison.OrdinalIgnoreCase))
                    return "Your identity was found but no login account exists. Contact ICT Support to activate your login.";

                return "No account found for &ldquo;" + HttpUtility.HtmlEncode(originalInput)
                     + "&rdquo;. Try your email address, staff number, or username.";
            }

            if (mu.IsLockedOut)
                return "This account is locked after too many failed attempts. "
                     + "Click &ldquo;Forgot Password?&rdquo; below to reset it, or contact ICT Support.";

            // Account exists but password is wrong
            return "Incorrect password. Please try again, "
                 + "or click &ldquo;Forgot Password?&rdquo; below to reset it.";
        }
        catch
        {
            return "Login failed. Please try again.";
        }
    }

    protected void Login1_LoggedIn(object sender, EventArgs e)
    {
        // Reached only when the Login control handled authentication itself
        // (rare with DX textboxes — Login1_LoggingIn1 normally handles everything).
        Session["username"] = Login1.UserName;
        FormsAuthentication.SetAuthCookie(Login1.UserName, true);
        RoleAccessService.LoadUserAccess(Login1.UserName);
        string empName = LoadEmployeeDisplayName(Login1.UserName);
        if (!string.IsNullOrEmpty(empName)) Session["ScreenName"] = empName;

        var senderLogin = sender as System.Web.UI.WebControls.Login;
        string key = senderLogin.UserName + senderLogin.Password;
        HttpContext.Current.Cache.Insert(key, Session.SessionID, null,
            DateTime.MaxValue, TimeSpan.FromDays(365),
            System.Web.Caching.CacheItemPriority.NotRemovable, null);
        Session["usernm"] = key;
    }

    // ── FORGOT PASSWORD ──────────────────────────────────────────────────────

    protected void cmdForgot_Click(object sender, EventArgs e)
    {
        // Keep the forgot-password panel visible after this postback
        pnlForgot.Style["display"] = "";
        pnlLogin.Style["display"]  = "none";

        // Read DX textbox value directly from form (same pattern as Login1_LoggingIn1)
        string input = (Request.Form[txtForgotInput.UniqueID] ?? txtForgotInput.Text ?? "").Trim();
        if (string.IsNullOrEmpty(input))
        {
            ShowForgotMessage("Please enter your email address, username, or staff number.", isError: true);
            return;
        }

        try
        {
            string resolved = ResolveToMembershipUsername(input);
            if (string.IsNullOrEmpty(resolved)) resolved = input;

            MembershipUser mu = Membership.GetUser(resolved);
            if (mu == null)
            {
                ShowForgotMessage(
                    "No account found for &ldquo;" + HttpUtility.HtmlEncode(input) + "&rdquo;. "
                  + "Contact ICT Support if you believe this is an error.",
                    isError: true);
                return;
            }

            // Find the employee's registered email (for sending the PIN)
            string email = GetEmployeeEmail(resolved, input);
            if (string.IsNullOrEmpty(email))
                email = mu.Email; // fall back to membership-stored email

            if (string.IsNullOrEmpty(email))
            {
                ShowForgotMessage(
                    "No email address is on record for this account. Contact ICT Support to reset your password.",
                    isError: true);
                return;
            }

            // Generate a 4-digit PIN and reset via Membership API (uses correct HMACSHA256 hash)
            string pin = new Random().Next(1000, 9999).ToString();
            if (mu.IsLockedOut) mu.UnlockUser();
            string temp    = mu.ResetPassword();
            bool   changed = mu.ChangePassword(temp, pin);

            if (!changed)
            {
                ShowForgotMessage("Password reset failed. Please contact ICT Support.", isError: true);
                return;
            }

            // Send PIN via erp.edusaterp.com (same API the student portal uses)
            string message = "Your MRU Admin System password has been reset to: " + pin
                           + ". Please log in and change it immediately.";
            string apiUrl  = string.Format(
                "https://erp.edusaterp.com/api/SecureOTP/sendotp?msg={0}&email={1}&sender=MRU+ERP",
                HttpUtility.UrlEncode(message),
                HttpUtility.UrlEncode(email));

            try
            {
                ServicePointManager.SecurityProtocol =
                    SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
                var req = (HttpWebRequest)WebRequest.Create(apiUrl);
                req.Method  = "GET";
                req.Timeout = 15000;
                using (var resp = (HttpWebResponse)req.GetResponse())
                using (var rdr  = new StreamReader(resp.GetResponseStream()))
                    rdr.ReadToEnd(); // consume

                ShowForgotMessage(
                    "Password reset. A new 4-digit PIN has been sent to the email address on your account.",
                    isError: false);
            }
            catch
            {
                // API failed — password is already reset, so show the PIN directly as fallback
                ShowForgotMessage(
                    "Password reset. Email delivery failed, so note your new PIN here: "
                  + "<strong style='font-size:16px;letter-spacing:3px'>" + pin + "</strong>",
                    isError: false);
            }
        }
        catch (Exception ex)
        {
            ShowForgotMessage("Error: " + HttpUtility.HtmlEncode(ex.Message), isError: true);
        }
    }

    private void ShowForgotMessage(string html, bool isError)
    {
        lbl_msg.Text = "<span style='color:" + (isError ? "#c0392b" : "#1a7a3a") + ";font-size:12px'>"
                     + html + "</span>";
    }

    // ── HELPERS ──────────────────────────────────────────────────────────────

    private string GetEmployeeEmail(string resolved, string originalInput)
    {
        try
        {
            string cs = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"SELECT emp_email FROM hrm_employee
                      WHERE UPPER(TRIM(usernames)) = UPPER(@u)
                         OR UPPER(TRIM(EMP_CODE))  = UPPER(@u)
                         OR LOWER(emp_email)        = LOWER(@e)
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@u", resolved);
                    cmd.Parameters.AddWithValue("@e",
                        originalInput.Contains("@") ? originalInput : "");
                    var r = cmd.ExecuteScalar();
                    return r != null && r != DBNull.Value ? r.ToString().Trim() : "";
                }
            }
        }
        catch { return ""; }
    }

    private string LoadEmployeeDisplayName(string username)
    {
        try
        {
            string cs = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"SELECT emp_name FROM hrm_employee
                      WHERE UPPER(TRIM(usernames)) = UPPER(@u)
                         OR UPPER(TRIM(EMP_CODE))  = UPPER(@u)
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@u", username);
                    var r = cmd.ExecuteScalar();
                    return r != null && r != DBNull.Value ? r.ToString().Trim() : "";
                }
            }
        }
        catch { return ""; }
    }

    private string ResolveToMembershipUsername(string input)
    {
        if (string.IsNullOrEmpty(input)) return input;

        // 1. Direct membership username — fast path, no DB hit
        if (Membership.GetUser(input) != null)
            return input;

        // 2. Email stored in membership
        string byEmail = Membership.GetUserNameByEmail(input);
        if (!string.IsNullOrEmpty(byEmail))
            return byEmail;

        // 3. EMP_CODE or employee email via hrm_employee
        try
        {
            string cs = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"SELECT usernames, emp_email FROM hrm_employee
                      WHERE EMP_CODE = @v OR LOWER(emp_email) = LOWER(@v)
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@v", input);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string uname    = dr["usernames"].ToString().Trim();
                            string empEmail = dr["emp_email"].ToString().Trim();

                            if (!string.IsNullOrEmpty(uname) && uname != "-")
                            {
                                if (Membership.GetUser(uname) != null) return uname;
                                string n = Membership.GetUserNameByEmail(uname);
                                if (!string.IsNullOrEmpty(n)) return n;
                            }

                            if (!string.IsNullOrEmpty(empEmail) && empEmail != "-")
                            {
                                string n = Membership.GetUserNameByEmail(empEmail);
                                if (!string.IsNullOrEmpty(n)) return n;
                                if (Membership.GetUser(empEmail) != null) return empEmail;
                            }
                        }
                    }
                }
            }
        }
        catch { }

        return input;
    }
}
