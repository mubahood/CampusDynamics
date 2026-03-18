using System;
using System.Configuration;
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
    }

    protected void Login1_LoggingIn1(object sender, LoginCancelEventArgs e)
    {
        string input    = Login1.UserName.Trim();
        string password = Login1.Password;

        // Resolve email / staff-number to the real membership username
        string resolved = ResolveToMembershipUsername(input);

        if (!string.IsNullOrEmpty(resolved) && resolved != input)
        {
            // The user typed something other than their actual username (e.g. email, staff no.)
            // Validate manually so the Login control's textbox-based lookup doesn't interfere
            if (Membership.ValidateUser(resolved, password))
            {
                e.Cancel = true; // stop Login control from running its own (failing) validation

                // Unlock if locked out
                MembershipUser mu = Membership.GetUser(resolved);
                if (mu != null && mu.IsLockedOut) mu.UnlockUser();

                // Replicate exactly what Login1_LoggedIn does
                FormsAuthentication.SetAuthCookie(resolved, false);
                Session["username"] = resolved;
                string key = resolved + password;
                HttpContext.Current.Cache.Insert(key, Session.SessionID, null,
                    DateTime.MaxValue, TimeSpan.FromDays(30),
                    System.Web.Caching.CacheItemPriority.NotRemovable, null);
                Session["usernm"] = key;

                Response.Redirect("~/MyApplications.aspx");
            }
            // else: wrong password — fall through, Login control will show its own error
        }
        else
        {
            // Direct username typed (or nothing resolved) — let Login control proceed normally
            Session["username"] = input;
        }
    }

    protected void Login1_LoggedIn(object sender, EventArgs e)
    {
        // Reached only when the user typed their actual membership username directly
        Session["username"] = Login1.UserName;
        System.Web.UI.WebControls.Login senderLogin = sender as System.Web.UI.WebControls.Login;
        string key = senderLogin.UserName + senderLogin.Password;
        HttpContext.Current.Cache.Insert(key, Session.SessionID, null,
            DateTime.MaxValue, TimeSpan.FromDays(30),
            System.Web.Caching.CacheItemPriority.NotRemovable, null);
        Session["usernm"] = key;
    }

    /// <summary>
    /// Resolves whatever the user typed (username / email / staff number)
    /// to the actual membership username. Returns the original input unchanged
    /// if nothing matches, so the Login control shows its normal error.
    /// </summary>
    private string ResolveToMembershipUsername(string input)
    {
        if (string.IsNullOrEmpty(input)) return input;

        // 1. Direct membership username — fast path, no DB
        if (Membership.GetUser(input) != null)
            return input;

        // 2. Email field in membership
        string byEmail = Membership.GetUserNameByEmail(input);
        if (!string.IsNullOrEmpty(byEmail))
            return byEmail;

        // 3. Staff number (EMP_CODE) or email via hrm_employee table
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            using (var conn = new MySqlConnection(connStr))
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

                            // Try the username stored on the employee record
                            if (!string.IsNullOrEmpty(uname) && uname != "-")
                            {
                                if (Membership.GetUser(uname) != null) return uname;
                                string n = Membership.GetUserNameByEmail(uname);
                                if (!string.IsNullOrEmpty(n)) return n;
                            }

                            // Try the employee's email against membership
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
        catch { /* DB failure — fall through */ }

        return input; // nothing found — return original
    }
}
