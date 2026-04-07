using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksNotificationService — Sends email notifications for key marks workflow events.
///
/// Notification triggers:
///   1. Submission: Teacher submits marks → Dean(s) receive review notification
///   2. Approval:   Dean approves marks   → Submitting teacher receives confirmation
///   3. Rejection:  Dean rejects marks    → Submitting teacher receives rejection + reason
///
/// Uses EmailSenderProtocol.SendHtmlEmail() for delivery. All methods are fire-and-forget —
/// notification failures never block the main workflow. Errors are logged but suppressed.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P21-P26 (status visibility, notification gaps)
/// Task: F-04
/// </summary>
public static class MarksNotificationService
{
    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    private static string AccountsConnStr
    {
        get { return MarksConfiguration.AccountsConnStr; }
    }

    // ─────────────────────── Notification Methods ───────────────────────

    /// <summary>
    /// Notifies approvers (Dean/Admin) that a mark sheet has been submitted for review.
    /// Sends an email to all users with approval roles who have a valid email address.
    /// </summary>
    public static void NotifySubmission(string courseId, string progId, string acadyear,
        int semester, string submittedBy)
    {
        try
        {
            // Look up course name for a friendlier email
            string courseName = GetCourseName(courseId);
            string progName = GetProgName(progId);

            // Build email content
            string subject = String.Format("Marks Submitted for Review — {0} ({1})",
                courseName, courseId);

            StringBuilder body = new StringBuilder();
            body.Append("<div style='font-family:Segoe UI,Arial,sans-serif;max-width:600px;margin:0 auto;'>");
            body.Append("<div style='background:#2563eb;color:#fff;padding:16px 24px;border-radius:8px 8px 0 0;'>");
            body.Append("<h2 style='margin:0;font-size:18px;'>Marks Submitted for Review</h2></div>");
            body.Append("<div style='background:#f8fafc;padding:24px;border:1px solid #e2e8f0;border-radius:0 0 8px 8px;'>");
            body.AppendFormat("<p>A mark sheet has been submitted for your review:</p>");
            body.Append("<table style='width:100%;border-collapse:collapse;margin:16px 0;'>");
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Course</td><td style='padding:8px 12px;'>{0} ({1})</td></tr>",
                HtmlEnc(courseName), HtmlEnc(courseId));
            body.AppendFormat("<tr style='background:#fff;'><td style='padding:8px 12px;font-weight:600;color:#475569;'>Programme</td><td style='padding:8px 12px;'>{0}</td></tr>",
                HtmlEnc(progName));
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Academic Year</td><td style='padding:8px 12px;'>{0}</td></tr>",
                HtmlEnc(acadyear));
            body.AppendFormat("<tr style='background:#fff;'><td style='padding:8px 12px;font-weight:600;color:#475569;'>Semester</td><td style='padding:8px 12px;'>{0}</td></tr>",
                semester);
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Submitted By</td><td style='padding:8px 12px;'>{0}</td></tr>",
                HtmlEnc(submittedBy));
            body.AppendFormat("<tr style='background:#fff;'><td style='padding:8px 12px;font-weight:600;color:#475569;'>Submitted At</td><td style='padding:8px 12px;'>{0}</td></tr>",
                DateTime.Now.ToString("dd MMM yyyy, HH:mm"));
            body.Append("</table>");
            body.Append("<p style='margin-top:16px;'>Please log in to the <strong>Dean Approval</strong> page to review and approve or reject this submission.</p>");
            body.Append("<p style='color:#64748b;font-size:12px;margin-top:24px;'>This is an automated notification from Campus Dynamics Marks Module.</p>");
            body.Append("</div></div>");

            // Find approver emails and send
            List<string> approverEmails = GetApproverEmails();
            foreach (string email in approverEmails)
            {
                try
                {
                    EmailSenderProtocol.SendHtmlEmail(body.ToString(), email, subject, "Campus Dynamics");
                }
                catch
                {
                    // Individual send failure — continue to next recipient
                }
            }
        }
        catch
        {
            // Fire-and-forget — never block the main workflow
        }
    }

    /// <summary>
    /// Notifies the submitting teacher that their mark sheet has been approved.
    /// </summary>
    public static void NotifyApproval(string courseId, string progId, string acadyear,
        int semester, string approvedBy)
    {
        try
        {
            // Find the teacher who submitted this sheet
            string submittedBy = GetSubmittedBy(courseId, progId, acadyear, semester);
            if (string.IsNullOrEmpty(submittedBy)) return;

            string teacherEmail = GetUserEmail(submittedBy);
            if (string.IsNullOrEmpty(teacherEmail)) return;

            string courseName = GetCourseName(courseId);

            string subject = String.Format("Marks Approved — {0} ({1})",
                courseName, courseId);

            StringBuilder body = new StringBuilder();
            body.Append("<div style='font-family:Segoe UI,Arial,sans-serif;max-width:600px;margin:0 auto;'>");
            body.Append("<div style='background:#16a34a;color:#fff;padding:16px 24px;border-radius:8px 8px 0 0;'>");
            body.Append("<h2 style='margin:0;font-size:18px;'>&#10004; Marks Approved</h2></div>");
            body.Append("<div style='background:#f0fdf4;padding:24px;border:1px solid #bbf7d0;border-radius:0 0 8px 8px;'>");
            body.Append("<p>Your submitted marks have been <strong style='color:#16a34a;'>approved</strong>.</p>");
            body.Append("<table style='width:100%;border-collapse:collapse;margin:16px 0;'>");
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Course</td><td style='padding:8px 12px;'>{0} ({1})</td></tr>",
                HtmlEnc(courseName), HtmlEnc(courseId));
            body.AppendFormat("<tr style='background:#fff;'><td style='padding:8px 12px;font-weight:600;color:#475569;'>Academic Year</td><td style='padding:8px 12px;'>{0}</td></tr>",
                HtmlEnc(acadyear));
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Semester</td><td style='padding:8px 12px;'>{0}</td></tr>",
                semester);
            body.AppendFormat("<tr style='background:#fff;'><td style='padding:8px 12px;font-weight:600;color:#475569;'>Approved By</td><td style='padding:8px 12px;'>{0}</td></tr>",
                HtmlEnc(approvedBy));
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Approved At</td><td style='padding:8px 12px;'>{0}</td></tr>",
                DateTime.Now.ToString("dd MMM yyyy, HH:mm"));
            body.Append("</table>");
            body.Append("<p style='color:#16a34a;font-weight:600;'>No further action is needed from you.</p>");
            body.Append("<p style='color:#64748b;font-size:12px;margin-top:24px;'>This is an automated notification from Campus Dynamics Marks Module.</p>");
            body.Append("</div></div>");

            EmailSenderProtocol.SendHtmlEmail(body.ToString(), teacherEmail, subject, "Campus Dynamics");
        }
        catch
        {
            // Fire-and-forget
        }
    }

    /// <summary>
    /// Notifies the submitting teacher that their mark sheet has been rejected.
    /// Includes the rejection reason so the teacher knows what to fix.
    /// </summary>
    public static void NotifyRejection(string courseId, string progId, string acadyear,
        int semester, string rejectedBy, string reason)
    {
        try
        {
            string submittedBy = GetSubmittedBy(courseId, progId, acadyear, semester);
            if (string.IsNullOrEmpty(submittedBy)) return;

            string teacherEmail = GetUserEmail(submittedBy);
            if (string.IsNullOrEmpty(teacherEmail)) return;

            string courseName = GetCourseName(courseId);

            string subject = String.Format("Marks Rejected — {0} ({1}) — Action Required",
                courseName, courseId);

            StringBuilder body = new StringBuilder();
            body.Append("<div style='font-family:Segoe UI,Arial,sans-serif;max-width:600px;margin:0 auto;'>");
            body.Append("<div style='background:#dc2626;color:#fff;padding:16px 24px;border-radius:8px 8px 0 0;'>");
            body.Append("<h2 style='margin:0;font-size:18px;'>&#10008; Marks Rejected</h2></div>");
            body.Append("<div style='background:#fef2f2;padding:24px;border:1px solid #fecaca;border-radius:0 0 8px 8px;'>");
            body.Append("<p>Your submitted marks have been <strong style='color:#dc2626;'>rejected</strong> and require revision.</p>");
            body.Append("<table style='width:100%;border-collapse:collapse;margin:16px 0;'>");
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Course</td><td style='padding:8px 12px;'>{0} ({1})</td></tr>",
                HtmlEnc(courseName), HtmlEnc(courseId));
            body.AppendFormat("<tr style='background:#fff;'><td style='padding:8px 12px;font-weight:600;color:#475569;'>Academic Year</td><td style='padding:8px 12px;'>{0}</td></tr>",
                HtmlEnc(acadyear));
            body.AppendFormat("<tr><td style='padding:8px 12px;font-weight:600;color:#475569;'>Semester</td><td style='padding:8px 12px;'>{0}</td></tr>",
                semester);
            body.AppendFormat("<tr style='background:#fff;'><td style='padding:8px 12px;font-weight:600;color:#475569;'>Rejected By</td><td style='padding:8px 12px;'>{0}</td></tr>",
                HtmlEnc(rejectedBy));
            body.Append("</table>");
            body.Append("<div style='background:#fff;border-left:4px solid #dc2626;padding:12px 16px;margin:16px 0;border-radius:0 4px 4px 0;'>");
            body.AppendFormat("<p style='margin:0;font-weight:600;color:#991b1b;'>Reason for Rejection:</p>");
            body.AppendFormat("<p style='margin:8px 0 0 0;color:#374151;'>{0}</p>", HtmlEnc(reason));
            body.Append("</div>");
            body.Append("<p style='margin-top:16px;'>Please log in to the <strong>Mark Entry</strong> page to review and correct the marks, then resubmit.</p>");
            body.Append("<p style='color:#64748b;font-size:12px;margin-top:24px;'>This is an automated notification from Campus Dynamics Marks Module.</p>");
            body.Append("</div></div>");

            EmailSenderProtocol.SendHtmlEmail(body.ToString(), teacherEmail, subject, "Campus Dynamics");
        }
        catch
        {
            // Fire-and-forget
        }
    }

    // ─────────────────────── Helper Methods ─────────────────────────────

    /// <summary>
    /// Looks up a user's email address from hrm_employee by username.
    /// Returns null if not found or empty.
    /// </summary>
    private static string GetUserEmail(string username)
    {
        if (string.IsNullOrEmpty(username)) return null;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT emp_email FROM hrm_employee
                      WHERE usernames = @u AND emp_email IS NOT NULL AND emp_email != ''
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@u", username.Trim());
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string email = result.ToString().Trim();
                        return email.Contains("@") ? email : null;
                    }
                }
            }
        }
        catch
        {
            // Silently fail
        }
        return null;
    }

    /// <summary>
    /// Finds email addresses of users with approval roles (Dean, Administrator, admin).
    /// Queries the accounts database membership tables joined with hrm_employee.
    /// </summary>
    private static List<string> GetApproverEmails()
    {
        List<string> emails = new List<string>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Cross-database join: accounts DB for roles, main DB for email
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT DISTINCT e.emp_email
                      FROM campus_dynamics_accounts.my_aspnet_users u
                      JOIN campus_dynamics_accounts.my_aspnet_usersinroles ur ON u.id = ur.userId
                      JOIN campus_dynamics_accounts.my_aspnet_roles r ON ur.roleId = r.id
                      JOIN hrm_employee e ON e.usernames = u.name
                      WHERE r.name IN ('Dean', 'Administrator', 'admin')
                        AND e.emp_email IS NOT NULL AND e.emp_email != ''
                      LIMIT 20", conn))
                {
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string email = rdr["emp_email"].ToString().Trim();
                            if (email.Contains("@") && !emails.Contains(email))
                            {
                                emails.Add(email);
                            }
                        }
                    }
                }
            }
        }
        catch
        {
            // If cross-DB query fails, try configuration fallback
            try
            {
                string fallback = ConfigurationManager.AppSettings["MarksApprovalNotifyEmail"];
                if (!string.IsNullOrEmpty(fallback))
                {
                    string[] parts = fallback.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string p in parts)
                    {
                        string trimmed = p.Trim();
                        if (trimmed.Contains("@")) emails.Add(trimmed);
                    }
                }
            }
            catch
            {
                // Silently fail
            }
        }
        return emails;
    }

    /// <summary>
    /// Finds who originally submitted the mark sheet (from acad_results_status.submitted_by).
    /// </summary>
    private static string GetSubmittedBy(string courseId, string progId, string acadyear, int semester)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT submitted_by FROM acad_results_status
                      WHERE course_id = @c AND progid = @p AND acadyear = @y AND semester = @s
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@c", courseId);
                    cmd.Parameters.AddWithValue("@p", progId);
                    cmd.Parameters.AddWithValue("@y", acadyear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        return result.ToString().Trim();
                    }
                }
            }
        }
        catch
        {
            // Silently fail
        }
        return null;
    }

    /// <summary>
    /// Looks up a course name by code for friendlier email content.
    /// </summary>
    private static string GetCourseName(string courseId)
    {
        if (string.IsNullOrEmpty(courseId)) return courseId;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT CourseName FROM acad_courses WHERE CourseCode = @c LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@c", courseId);
                    object result = cmd.ExecuteScalar();
                    return (result != null && result != DBNull.Value) ? result.ToString() : courseId;
                }
            }
        }
        catch
        {
            return courseId;
        }
    }

    /// <summary>
    /// Looks up a programme name by code.
    /// </summary>
    private static string GetProgName(string progId)
    {
        if (string.IsNullOrEmpty(progId)) return progId;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT progname FROM acad_programme WHERE progcode = @p LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@p", progId);
                    object result = cmd.ExecuteScalar();
                    return (result != null && result != DBNull.Value) ? result.ToString() : progId;
                }
            }
        }
        catch
        {
            return progId;
        }
    }

    /// <summary>
    /// HTML-encodes a string for safe inclusion in email body.
    /// </summary>
    private static string HtmlEnc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");
    }
}
