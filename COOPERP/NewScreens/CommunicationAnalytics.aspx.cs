using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// CommunicationAnalytics.aspx.cs — Read tracking analytics for communications.
///
/// AJAX Endpoints (via ?ajax=...):
///   GET  ?ajax=commlist              — dropdown of all communications with read counts
///   GET  ?ajax=readdetails&amp;id=      — detailed reader list for a communication
///   GET  ?ajax=exportcsv&amp;id=        — CSV download of reader data
///
/// Tables: sys_communications, sys_communication_reads
///
/// Design Rules:
///   - C# 4.0 compatible: no ?. operator, no string interpolation ($""), no out var
///   - vacConnectionString only
///
/// Task: COMMUNICATIONS_MODULE_TASKS.md — Task T3
/// </summary>
public partial class COOPERP_NewScreens_CommunicationAnalytics : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        return dt;
    }

    private string RespondJson(object obj)
    {
        JavaScriptSerializer ser = new JavaScriptSerializer();
        ser.MaxJsonLength = int.MaxValue;
        string json = ser.Serialize(obj);
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Write(json);
        Response.End();
        return null;
    }

    private string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int result;
        if (int.TryParse(val.ToString(), out result)) return result;
        return 0;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        try
        {
            string action = ajax;
            int ampIdx = ajax.IndexOf('&');
            if (ampIdx > 0) action = ajax.Substring(0, ampIdx);

            switch (action)
            {
                case "commlist":     HandleCommList();     break;
                case "readdetails":  HandleReadDetails();  break;
                case "exportcsv":    HandleExportCsv();    break;
                default:
                    RespondJson(new { ok = false, error = "Unknown action: " + action });
                    break;
            }
        }
        catch (System.Threading.ThreadAbortException) { }
        catch (Exception ex)
        {
            RespondJson(new { ok = false, error = ex.Message });
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // COMM LIST — dropdown data
    // ═══════════════════════════════════════════════════════════════════════

    private void HandleCommList()
    {
        string sql = @"
            SELECT c.ID, c.title, c.status, c.target_audience, c.published_at,
                   COALESCE(rd.readCount, 0) AS readCount
            FROM sys_communications c
            LEFT JOIN (
                SELECT communication_id, COUNT(*) AS readCount
                FROM sys_communication_reads
                GROUP BY communication_id
            ) rd ON rd.communication_id = c.ID
            ORDER BY c.created_at DESC";

        DataTable dt = ExecuteQuery(sql);
        List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
        foreach (DataRow row in dt.Rows)
        {
            Dictionary<string, object> d = new Dictionary<string, object>();
            d["ID"]        = SafeInt(row["ID"]);
            d["title"]     = SafeStr(row["title"]);
            d["status"]    = SafeStr(row["status"]);
            d["readCount"] = SafeInt(row["readCount"]);
            rows.Add(d);
        }

        RespondJson(new { ok = true, rows = rows });
    }

    // ═══════════════════════════════════════════════════════════════════════
    // READ DETAILS — detailed reader list for a communication
    // ═══════════════════════════════════════════════════════════════════════

    private void HandleReadDetails()
    {
        int id = 0;
        string idStr = Request.QueryString["id"] ?? "";
        int.TryParse(idStr, out id);
        if (id <= 0) { RespondJson(new { ok = false, error = "Invalid ID" }); return; }

        DataTable dt = ExecuteQuery(
            "SELECT * FROM sys_communication_reads WHERE communication_id = @id ORDER BY read_at DESC",
            new MySqlParameter("@id", id));

        int readCount = dt.Rows.Count;
        int confirmedCount = 0;
        int studentCount = 0;
        int staffCount = 0;
        List<Dictionary<string, object>> readers = new List<Dictionary<string, object>>();

        foreach (DataRow row in dt.Rows)
        {
            Dictionary<string, object> r = new Dictionary<string, object>();
            r["user_id"]           = SafeStr(row["user_id"]);
            r["user_type"]         = SafeStr(row["user_type"]);
            r["user_name"]         = SafeStr(row["user_name"]);
            r["read_at"]           = SafeStr(row["read_at"]);
            r["confirmed_at"]      = SafeStr(row["confirmed_at"]);
            r["confirmation_text"] = SafeStr(row["confirmation_text"]);
            readers.Add(r);

            if (!string.IsNullOrEmpty(SafeStr(row["confirmed_at"]))) confirmedCount++;
            if (SafeStr(row["user_type"]) == "STUDENT") studentCount++;
            else staffCount++;
        }

        RespondJson(new { ok = true, readCount = readCount, confirmedCount = confirmedCount, studentCount = studentCount, staffCount = staffCount, readers = readers });
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EXPORT CSV
    // ═══════════════════════════════════════════════════════════════════════

    private void HandleExportCsv()
    {
        int id = 0;
        string idStr = Request.QueryString["id"] ?? "";
        int.TryParse(idStr, out id);
        if (id <= 0) return;

        // Get communication title
        DataTable commDt = ExecuteQuery("SELECT title FROM sys_communications WHERE ID = @id",
            new MySqlParameter("@id", id));
        string title = commDt.Rows.Count > 0 ? SafeStr(commDt.Rows[0]["title"]) : "Communication";

        DataTable dt = ExecuteQuery(
            "SELECT * FROM sys_communication_reads WHERE communication_id = @id ORDER BY read_at DESC",
            new MySqlParameter("@id", id));

        StringBuilder sb = new StringBuilder();
        sb.AppendLine("User ID,User Name,User Type,Read At,Confirmed At,Confirmation Text");

        foreach (DataRow row in dt.Rows)
        {
            sb.AppendLine(string.Format("\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\"",
                SafeStr(row["user_id"]).Replace("\"", "\"\""),
                SafeStr(row["user_name"]).Replace("\"", "\"\""),
                SafeStr(row["user_type"]),
                SafeStr(row["read_at"]),
                SafeStr(row["confirmed_at"]),
                SafeStr(row["confirmation_text"]).Replace("\"", "\"\"")));
        }

        string safeTitle = title.Length > 30 ? title.Substring(0, 30) : title;
        safeTitle = System.Text.RegularExpressions.Regex.Replace(safeTitle, @"[^\w\s-]", "").Trim();

        Response.Clear();
        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=ReadStats_" + safeTitle + ".csv");
        Response.Write(sb.ToString());
        Response.End();
    }
}
