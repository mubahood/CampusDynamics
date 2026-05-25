using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Support Ticket API — all actions route through SupportTicketDB which connects to
/// campus_dynamics_portal (via campus_dynamics_portalConnectionString in this app's web.config).
/// Never use ApiHelper.Query/Scalar/Execute for support_tickets — those go to campus_dynamics.
/// </summary>
public partial class API_v2_support : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;

        try { SupportTicketDB.EnsureSchema(); } catch { }

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "list":          HandleList();         break;
                case "detail":        HandleDetail();       break;
                case "create":        HandleCreate();       break;
                case "reply":         HandleReply();        break;
                case "update_status": HandleUpdateStatus(); break;
                case "close":         HandleClose();        break;
                case "stats":         HandleStats();        break;
                case "attachment":    HandleAttachment();   break;
                case "issue_types":   HandleIssueTypes();   break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action +
                        ". Valid actions: list, detail, create, reply, update_status, close, stats, attachment, issue_types",
                        "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  LIST  — paginated ticket list
    //  Student: own tickets only; Staff: all tickets with filters
    // ═══════════════════════════════════════════════════════════════════

    private void HandleList()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff    = string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase);
        string statusFilter = ApiHelper.Param(Request, "status", "ALL").ToUpper();
        int page            = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size            = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 20)));
        int offset          = (page - 1) * size;

        if (!isStaff)
        {
            int total = SupportTicketDB.CountUserTickets(auth.UserId, statusFilter);
            DataTable dt = SupportTicketDB.GetUserTickets(auth.UserId, statusFilter, size, offset);

            var rows = ApiHelper.TableToList(dt);
            foreach (var row in rows) EnrichTicketRow(row);

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "total",   total },
                { "page",    page },
                { "size",    size },
                { "pages",   (int)Math.Ceiling(total / (double)size) },
                { "tickets", rows }
            });
        }
        else
        {
            string issueFilter = ApiHelper.Param(Request, "issue_type", "");
            string priority    = ApiHelper.Param(Request, "priority", "").ToUpper();
            string assignedTo  = ApiHelper.Param(Request, "assigned_to", "");
            string search      = ApiHelper.Param(Request, "q", "");

            int total = SupportTicketDB.CountAllTickets(statusFilter, issueFilter, search, priority, assignedTo);
            DataTable dt = SupportTicketDB.GetAllTickets(statusFilter, issueFilter, search, size, offset, priority, assignedTo);

            var rows = ApiHelper.TableToList(dt);
            foreach (var row in rows) EnrichTicketRow(row);

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "total",   total },
                { "page",    page },
                { "size",    size },
                { "pages",   (int)Math.Ceiling(total / (double)size) },
                { "tickets", rows }
            });
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DETAIL  — single ticket with full message thread + attachments
    // ═══════════════════════════════════════════════════════════════════

    private void HandleDetail()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        int ticketId = ApiHelper.ParamInt(Request, "ticket_id", 0);
        if (ticketId <= 0) { ApiHelper.Error(Response, "ticket_id is required.", "MISSING_PARAM"); return; }

        bool isStaff = string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase);

        DataRow ticketRow = SupportTicketDB.GetTicket(ticketId);
        if (ticketRow == null) { ApiHelper.Error(Response, "Ticket not found.", "NOT_FOUND"); return; }

        if (!isStaff && ticketRow["submitter_regno"].ToString() != auth.UserId)
        {
            ApiHelper.Error(Response, "Access denied.", "FORBIDDEN"); return;
        }

        var ticket = DataRowToDict(ticketRow);
        EnrichTicketRow(ticket);
        ticket["ref"] = SupportTicketDB.FormatRef(ticketId);

        // Messages — internal hidden from students
        DataTable msgDt = SupportTicketDB.GetMessages(ticketId, includeInternal: isStaff);
        var messages = ApiHelper.TableToList(msgDt);

        // Attachments with download URL
        DataTable attDt = SupportTicketDB.GetTicketAttachments(ticketId);
        var attachments = ApiHelper.TableToList(attDt);
        foreach (var att in attachments)
            att["download_url"] = "support.aspx?action=attachment&ticket_id=" + ticketId +
                                  "&attachment_id=" + att["attachment_id"];

        ticket["messages"]    = messages;
        ticket["attachments"] = attachments;

        ApiHelper.Success(Response, ticket);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CREATE  — submit a new ticket
    //  Rate-limited: max 5 tickets per hour per user
    // ═══════════════════════════════════════════════════════════════════

    private void HandleCreate()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff = string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase);

        string issueType = ApiHelper.RequireParam(Request, Response, "issue_type");
        if (issueType == null) return;
        string subject = ApiHelper.RequireParam(Request, Response, "subject");
        if (subject == null) return;
        string message = ApiHelper.RequireParam(Request, Response, "message");
        if (message == null) return;

        string priority      = ApiHelper.Param(Request, "priority", "NORMAL").ToUpper();
        string submitterType = isStaff ? "STAFF" : "STUDENT";

        string[] validPriorities = { "LOW", "NORMAL", "HIGH", "URGENT" };
        bool validPri = false;
        foreach (var p in validPriorities) if (p == priority) { validPri = true; break; }
        if (!validPri) priority = "NORMAL";

        // Rate-limit: max 5 tickets per 60 minutes
        if (!isStaff && SupportTicketDB.CountRecentTickets(auth.UserId, 60) >= 5)
        {
            ApiHelper.Error(Response, "Rate limit reached. You may submit at most 5 tickets per hour.", "RATE_LIMITED");
            return;
        }

        // Resolve display name from main DB (acad_student / hrm_employee)
        string submitterName = ResolveDisplayName(auth.UserId, isStaff);

        int ticketId = SupportTicketDB.CreateTicket(
            auth.UserId, submitterName, submitterType,
            issueType, subject, message, priority);

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "ticket_id", ticketId },
            { "ref",       SupportTicketDB.FormatRef(ticketId) },
            { "status",    "OPEN" },
            { "priority",  priority }
        }, "Ticket submitted successfully");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  REPLY  — add a message to an existing ticket
    // ═══════════════════════════════════════════════════════════════════

    private void HandleReply()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff = string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase);

        int ticketId = ApiHelper.ParamInt(Request, "ticket_id", 0);
        if (ticketId <= 0) { ApiHelper.Error(Response, "ticket_id is required.", "MISSING_PARAM"); return; }

        string message = ApiHelper.RequireParam(Request, Response, "message");
        if (message == null) return;

        bool isInternal = isStaff && ApiHelper.Param(Request, "is_internal", "0") == "1";

        DataRow ticketRow = SupportTicketDB.GetTicket(ticketId);
        if (ticketRow == null) { ApiHelper.Error(Response, "Ticket not found.", "NOT_FOUND"); return; }

        if (!isStaff && ticketRow["submitter_regno"].ToString() != auth.UserId)
        {
            ApiHelper.Error(Response, "Access denied.", "FORBIDDEN"); return;
        }

        string status = ticketRow["status"].ToString();
        if (status == "CLOSED" || status == "RESOLVED")
        {
            ApiHelper.Error(Response, "Cannot reply to a closed or resolved ticket. Please open a new ticket.", "TICKET_CLOSED");
            return;
        }

        string senderName = ResolveDisplayName(auth.UserId, isStaff);
        string role       = isStaff ? "ADMIN" : "SUBMITTER";

        int msgId = SupportTicketDB.AddMessage(ticketId, auth.UserId, senderName, role, message, isInternal);

        // Handle file attachments in the reply
        if (Request.Files != null && Request.Files.Count > 0)
        {
            try
            {
                string uploadFolder = SupportTicketDB.GetUploadFolder(Server);
                for (int i = 0; i < Request.Files.Count; i++)
                {
                    HttpPostedFile file = Request.Files[i];
                    if (file == null || file.ContentLength == 0) continue;
                    string origName = Path.GetFileName(file.FileName);
                    string ext      = Path.GetExtension(origName);
                    if (!SupportTicketDB.IsAllowedExtension(ext)) continue;
                    if (!SupportTicketDB.IsWithinSizeLimit(file.ContentLength)) continue;
                    string storedName = Guid.NewGuid().ToString("N") + ext.ToLower();
                    file.SaveAs(Path.Combine(uploadFolder, storedName));
                    SupportTicketDB.AddAttachment(ticketId, msgId, origName, storedName,
                        file.ContentLength, file.ContentType, auth.UserId);
                }
            }
            catch { /* attachment upload failure is non-fatal */ }
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "message_id",  msgId },
            { "ticket_id",   ticketId },
            { "is_internal", isInternal }
        }, "Reply added");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  UPDATE_STATUS  — change status, priority, or assignment (staff only)
    // ═══════════════════════════════════════════════════════════════════

    private void HandleUpdateStatus()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (!string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase))
        {
            ApiHelper.Error(Response, "Only staff can update ticket status.", "FORBIDDEN"); return;
        }

        int ticketId = ApiHelper.ParamInt(Request, "ticket_id", 0);
        if (ticketId <= 0) { ApiHelper.Error(Response, "ticket_id is required.", "MISSING_PARAM"); return; }

        string newStatus  = ApiHelper.Param(Request, "status", "").ToUpper();
        string assignedTo = ApiHelper.Param(Request, "assigned_to", "");
        string priority   = ApiHelper.Param(Request, "priority", "").ToUpper();

        if (string.IsNullOrEmpty(newStatus) && string.IsNullOrEmpty(assignedTo) && string.IsNullOrEmpty(priority))
        {
            ApiHelper.Error(Response, "Provide at least one of: status, assigned_to, priority.", "MISSING_PARAM");
            return;
        }

        string[] validStatuses  = { "OPEN", "IN_PROGRESS", "AWAITING_REPLY", "RESOLVED", "CLOSED" };
        string[] validPriorities = { "LOW", "NORMAL", "HIGH", "URGENT" };

        if (!string.IsNullOrEmpty(newStatus))
        {
            bool validSt = false;
            foreach (var s in validStatuses) if (s == newStatus) { validSt = true; break; }
            if (!validSt) { ApiHelper.Error(Response, "Invalid status. Valid: OPEN, IN_PROGRESS, AWAITING_REPLY, RESOLVED, CLOSED", "VALIDATION_ERROR"); return; }
        }

        DataRow ticketRow = SupportTicketDB.GetTicket(ticketId);
        if (ticketRow == null) { ApiHelper.Error(Response, "Ticket not found.", "NOT_FOUND"); return; }

        string staffName = ResolveDisplayName(auth.UserId, isStaff: true);

        if (!string.IsNullOrEmpty(newStatus))
            SupportTicketDB.UpdateStatus(ticketId, newStatus, auth.UserId, staffName);

        if (!string.IsNullOrEmpty(assignedTo))
            SupportTicketDB.AssignTicket(ticketId, assignedTo);

        if (!string.IsNullOrEmpty(priority))
        {
            bool validP = false;
            foreach (var p in validPriorities) if (p == priority) { validP = true; break; }
            if (validP) SupportTicketDB.UpdatePriority(ticketId, priority);
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "ticket_id",  ticketId },
            { "new_status", string.IsNullOrEmpty(newStatus) ? ticketRow["status"].ToString() : newStatus }
        }, "Ticket updated");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CLOSE  — close a ticket
    //  Student: own tickets only; Staff: any
    // ═══════════════════════════════════════════════════════════════════

    private void HandleClose()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff = string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase);
        int ticketId = ApiHelper.ParamInt(Request, "ticket_id", 0);
        if (ticketId <= 0) { ApiHelper.Error(Response, "ticket_id is required.", "MISSING_PARAM"); return; }

        DataRow ticketRow = SupportTicketDB.GetTicket(ticketId);
        if (ticketRow == null) { ApiHelper.Error(Response, "Ticket not found.", "NOT_FOUND"); return; }

        if (!isStaff && ticketRow["submitter_regno"].ToString() != auth.UserId)
        {
            ApiHelper.Error(Response, "Access denied.", "FORBIDDEN"); return;
        }

        if (ticketRow["status"].ToString() == "CLOSED")
        {
            ApiHelper.Error(Response, "Ticket is already closed.", "ALREADY_CLOSED"); return;
        }

        string closerName = ResolveDisplayName(auth.UserId, isStaff);
        SupportTicketDB.UpdateStatus(ticketId, "CLOSED", auth.UserId, closerName);

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "ticket_id", ticketId },
            { "status",    "CLOSED" }
        }, "Ticket closed");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  STATS  — count by status
    //  Student: own tickets; Staff: all tickets
    // ═══════════════════════════════════════════════════════════════════

    private void HandleStats()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff = string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase);

        if (isStaff)
        {
            DataRow s = SupportTicketDB.GetAdminStats();
            if (s == null) s = EmptyStatsRow();
            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "total",          Convert.ToInt32(s["total"])         },
                { "open",           Convert.ToInt32(s["cnt_open"])      },
                { "in_progress",    Convert.ToInt32(s["cnt_progress"])  },
                { "awaiting_reply", Convert.ToInt32(s["cnt_awaiting"])  },
                { "resolved",       Convert.ToInt32(s["cnt_resolved"])  },
                { "closed",         Convert.ToInt32(s["cnt_closed"])    },
                { "urgent_open",    Convert.ToInt32(s["cnt_urgent"])    }
            });
        }
        else
        {
            DataRow s = SupportTicketDB.GetUserStats(auth.UserId);
            if (s == null)
            {
                ApiHelper.Success(Response, new Dictionary<string, object>
                {
                    { "total", 0 }, { "open", 0 }, { "in_progress", 0 },
                    { "awaiting_reply", 0 }, { "resolved", 0 }, { "closed", 0 }
                });
                return;
            }
            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "total",          Convert.ToInt32(s["total"])         },
                { "open",           Convert.ToInt32(s["cnt_open"])      },
                { "in_progress",    Convert.ToInt32(s["cnt_progress"])  },
                { "awaiting_reply", Convert.ToInt32(s["cnt_awaiting"])  },
                { "resolved",       Convert.ToInt32(s["cnt_resolved"])  },
                { "closed",         Convert.ToInt32(s["cnt_closed"])    }
            });
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ATTACHMENT  — serve a ticket attachment file
    //  Student: own tickets only; Staff: any
    // ═══════════════════════════════════════════════════════════════════

    private void HandleAttachment()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        int ticketId     = ApiHelper.ParamInt(Request, "ticket_id", 0);
        int attachmentId = ApiHelper.ParamInt(Request, "attachment_id", 0);

        if (ticketId <= 0 || attachmentId <= 0)
        {
            ApiHelper.Error(Response, "ticket_id and attachment_id are required.", "MISSING_PARAM");
            return;
        }

        bool isStaff = string.Equals(auth.UserType, "staff", StringComparison.OrdinalIgnoreCase);

        // Ownership check for students
        if (!isStaff && !SupportTicketDB.IsTicketOwner(ticketId, auth.UserId))
        {
            ApiHelper.Error(Response, "Access denied.", "FORBIDDEN"); return;
        }

        DataRow att = SupportTicketDB.GetAttachment(attachmentId, ticketId);
        if (att == null) { ApiHelper.Error(Response, "Attachment not found.", "NOT_FOUND"); return; }

        string storedName  = att["stored_name"].ToString();
        string origName    = att["original_name"].ToString();
        string mimeType    = att["mime_type"] != DBNull.Value
            ? att["mime_type"].ToString() : "application/octet-stream";

        string folder   = SupportTicketDB.GetUploadFolder(Server);
        string filePath = Path.Combine(folder, storedName);

        if (!File.Exists(filePath))
        {
            ApiHelper.Error(Response, "File not found on server.", "NOT_FOUND"); return;
        }

        Response.Clear();
        Response.ContentType = mimeType;
        Response.AddHeader("Content-Disposition",
            "attachment; filename=\"" + origName.Replace("\"", "") + "\"");
        Response.AddHeader("Content-Length", new FileInfo(filePath).Length.ToString());
        Response.TransmitFile(filePath);
        Response.End();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ISSUE_TYPES  — public list of valid issue categories
    // ═══════════════════════════════════════════════════════════════════

    private void HandleIssueTypes()
    {
        var types = new List<Dictionary<string, object>>
        {
            new Dictionary<string, object> { { "category", "Academic" }, { "value", "Academic — Results & Marks" } },
            new Dictionary<string, object> { { "category", "Academic" }, { "value", "Academic — Transcripts & Certificates" } },
            new Dictionary<string, object> { { "category", "Academic" }, { "value", "Academic — Course Registration" } },
            new Dictionary<string, object> { { "category", "Academic" }, { "value", "Academic — Other" } },
            new Dictionary<string, object> { { "category", "Financial" }, { "value", "Financial — Fees & Payments" } },
            new Dictionary<string, object> { { "category", "Financial" }, { "value", "Financial — Receipt or Invoice" } },
            new Dictionary<string, object> { { "category", "Financial" }, { "value", "Financial — Financial Aid" } },
            new Dictionary<string, object> { { "category", "Financial" }, { "value", "Financial — Other" } },
            new Dictionary<string, object> { { "category", "Registration" }, { "value", "Registration — Semester Registration" } },
            new Dictionary<string, object> { { "category", "Registration" }, { "value", "Registration — Course Registration" } },
            new Dictionary<string, object> { { "category", "Registration" }, { "value", "Registration — Programme Change" } },
            new Dictionary<string, object> { { "category", "Registration" }, { "value", "Registration — Other" } },
            new Dictionary<string, object> { { "category", "Other" }, { "value", "Other — Portal Login Issue" } },
            new Dictionary<string, object> { { "category", "Other" }, { "value", "Other — System Error or Bug" } },
            new Dictionary<string, object> { { "category", "Other" }, { "value", "Other — General Inquiry" } },
            new Dictionary<string, object> { { "category", "Other" }, { "value", "Other — Complaint or Suggestion" } }
        };

        ApiHelper.Success(Response, new Dictionary<string, object> { { "issue_types", types } });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════

    private void EnrichTicketRow(Dictionary<string, object> row)
    {
        string status   = row.ContainsKey("status")    ? row["status"].ToString()    : "";
        string priority = row.ContainsKey("priority")  ? row["priority"].ToString()  : "";
        string issue    = row.ContainsKey("issue_type") ? row["issue_type"].ToString() : "";
        int    ticketId = row.ContainsKey("ticket_id")  ? Convert.ToInt32(row["ticket_id"]) : 0;

        row["status_label"]    = SupportTicketDB.GetStatusLabel(status);
        row["status_color"]    = SupportTicketDB.GetStatusColor(status);
        row["status_bg"]       = SupportTicketDB.GetStatusBg(status);
        row["priority_color"]  = SupportTicketDB.GetPriorityColor(priority);
        row["issue_short"]     = SupportTicketDB.GetIssueTypeShort(issue);
        row["issue_color"]     = SupportTicketDB.GetIssueTypeColor(issue);
        row["ref"]             = SupportTicketDB.FormatRef(ticketId);
    }

    /// <summary>Looks up the display name for a user in the main DB (acad_student or hrm_employee).</summary>
    private string ResolveDisplayName(string userId, bool isStaff)
    {
        string name = userId;
        try
        {
            if (isStaff)
            {
                DataTable dt = ApiHelper.Query(
                    "SELECT emp_name FROM hrm_employee WHERE usernames = @u LIMIT 1",
                    new MySqlParameter("@u", userId));
                if (dt.Rows.Count > 0 && dt.Rows[0]["emp_name"].ToString().Trim().Length > 0)
                    name = dt.Rows[0]["emp_name"].ToString().Trim();
            }
            else
            {
                DataTable dt = ApiHelper.Query(
                    "SELECT CONCAT(TRIM(COALESCE(firstname,'')), ' ', TRIM(COALESCE(othername,''))) AS fn " +
                    "FROM acad_student WHERE regno = @r LIMIT 1",
                    new MySqlParameter("@r", userId));
                if (dt.Rows.Count > 0 && dt.Rows[0]["fn"].ToString().Trim().Length > 1)
                    name = dt.Rows[0]["fn"].ToString().Trim();
            }
        }
        catch { }
        return name;
    }

    private Dictionary<string, object> DataRowToDict(DataRow row)
    {
        var dict = new Dictionary<string, object>();
        foreach (DataColumn col in row.Table.Columns)
            dict[col.ColumnName] = row[col] == DBNull.Value ? null : row[col];
        return dict;
    }

    private DataRow EmptyStatsRow()
    {
        var dt = new DataTable();
        dt.Columns.Add("total");   dt.Columns.Add("cnt_open");
        dt.Columns.Add("cnt_progress"); dt.Columns.Add("cnt_awaiting");
        dt.Columns.Add("cnt_resolved"); dt.Columns.Add("cnt_closed");
        dt.Columns.Add("cnt_urgent");
        var row = dt.NewRow();
        foreach (DataColumn col in dt.Columns) row[col] = 0;
        dt.Rows.Add(row);
        return dt.Rows[0];
    }
}
