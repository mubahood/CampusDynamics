<%@ WebHandler Language="C#" Class="NewScreens_SemsFile" %>

using System;
using System.IO;
using System.Text;
using System.Web;
using System.Web.SessionState;

// =====================================================================
//  SEMS file endpoint — the two things a PageMethod cannot do:
//  stream a CSV download, and receive an uploaded sheet.
//
//  GET  ?action=template                     blank Google template
//  GET  ?action=export&mode=create|update|all[&batchRef=&stage=&campus=&year=]
//  GET  ?action=credentials&batchRef=…       address + password sheet for the registry
//  POST  multipart, action=import            a Google export to parse (JSON back)
//
//  Session-guarded exactly like the page's WebMethods: this streams live
//  credentials, so an expired session must get nothing.
// =====================================================================
public class NewScreens_SemsFile : IHttpHandler, IRequiresSessionState
{
    public bool IsReusable { get { return false; } }

    public void ProcessRequest(HttpContext ctx)
    {
        ctx.Response.Cache.SetNoStore();

        if (ctx.Session == null || ctx.Session["username"] == null)
        {
            ctx.Response.StatusCode = 403;
            ctx.Response.ContentType = "application/json; charset=utf-8";
            ctx.Response.Write("{\"success\":false,\"message\":\"Your session has expired. Please sign in again.\"}");
            return;
        }

        string action = (ctx.Request["action"] ?? "").Trim().ToLowerInvariant();
        try
        {
            switch (action)
            {
                case "template": Template(ctx); break;
                case "export": Export(ctx); break;
                case "credentials": Credentials(ctx); break;
                case "import": Import(ctx); break;
                default:
                    ctx.Response.ContentType = "application/json; charset=utf-8";
                    ctx.Response.Write("{\"success\":false,\"message\":\"Unknown action.\"}");
                    break;
            }
        }
        catch (Exception ex)
        {
            ctx.Response.Clear();
            ctx.Response.ContentType = "application/json; charset=utf-8";
            ctx.Response.Write(new System.Web.Script.Serialization.JavaScriptSerializer()
                .Serialize(new { success = false, message = ex.Message }));
        }
    }

    private static void SendCsv(HttpContext ctx, string csv, string fileName)
    {
        ctx.Response.Clear();
        ctx.Response.ContentType = "text/csv; charset=utf-8";
        ctx.Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        // UTF-8 BOM: without it Excel mangles any non-ASCII name in the sheet.
        ctx.Response.BinaryWrite(new byte[] { 0xEF, 0xBB, 0xBF });
        ctx.Response.Write(csv);
        ctx.Response.End();
    }

    private static void Template(HttpContext ctx)
    {
        SendCsv(ctx, SemsBatch.ExportTemplateCsv(), "google-workspace-template.csv");
    }

    private static void Export(HttpContext ctx)
    {
        var sc = new SemsBatch.ExportScope();
        sc.Mode = (ctx.Request["mode"] ?? "create").Trim().ToLowerInvariant();
        sc.BatchRef = (ctx.Request["batchRef"] ?? "").Trim();
        sc.Stage = (ctx.Request["stage"] ?? "").Trim();
        sc.Campus = (ctx.Request["campus"] ?? "").Trim();
        sc.Programme = (ctx.Request["programme"] ?? "").Trim();
        sc.Year = (ctx.Request["year"] ?? "").Trim();
        sc.GoogleStatus = (ctx.Request["googleStatus"] ?? "").Trim();
        sc.ChangePwNext = (ctx.Request["changePwNext"] ?? "true").Trim().ToLowerInvariant() != "false";

        int rows; string batchRef;
        string csv = SemsBatch.BuildExportCsv(sc, out rows, out batchRef);
        if (rows == 0)
        {
            ctx.Response.ContentType = "application/json; charset=utf-8";
            ctx.Response.Write("{\"success\":false,\"message\":\"Nothing to export for that selection.\"}");
            return;
        }
        SendCsv(ctx, csv, "mru-google-" + sc.Mode + "-" + DateTime.Now.ToString("yyyyMMdd-HHmm") + "-" + rows + "users.csv");
    }

    private static void Credentials(HttpContext ctx)
    {
        string batchRef = (ctx.Request["batchRef"] ?? "").Trim();
        int rows;
        string csv = SemsBatch.BuildCredentialsCsv(batchRef, out rows);
        if (rows == 0)
        {
            ctx.Response.ContentType = "application/json; charset=utf-8";
            ctx.Response.Write("{\"success\":false,\"message\":\"That batch has no created rows.\"}");
            return;
        }
        SendCsv(ctx, csv, "mru-credentials-" + (batchRef == "" ? DateTime.Now.ToString("yyyyMMdd-HHmm") : batchRef) + ".csv");
    }

    private static void Import(HttpContext ctx)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        if (ctx.Request.Files == null || ctx.Request.Files.Count == 0)
        { ctx.Response.Write("{\"success\":false,\"message\":\"No file was uploaded.\"}"); return; }

        HttpPostedFile f = ctx.Request.Files[0];
        if (f == null || f.ContentLength == 0)
        { ctx.Response.Write("{\"success\":false,\"message\":\"The uploaded file is empty.\"}"); return; }
        if (f.ContentLength > 12 * 1024 * 1024)
        { ctx.Response.Write("{\"success\":false,\"message\":\"That file is larger than 12 MB — split it into smaller sheets.\"}"); return; }

        string name = Path.GetFileName(f.FileName ?? "upload.csv");
        string ext = (Path.GetExtension(name) ?? "").ToLowerInvariant();
        if (ext == ".xlsx" || ext == ".xls")
        {
            ctx.Response.Write("{\"success\":false,\"message\":\"Excel workbooks are not read directly. In Google Sheets or Excel choose File \\u2192 Download \\u2192 Comma-separated values (.csv), then upload that.\"}");
            return;
        }

        var buf = new byte[f.ContentLength];
        int read = 0, got;
        while (read < buf.Length && (got = f.InputStream.Read(buf, read, buf.Length - read)) > 0) read += got;

        // Google exports UTF-8 (usually with a BOM); a sheet re-saved by Excel may be ANSI.
        // StreamReader with detectEncodingFromByteOrderMarks handles both.
        string text;
        using (var ms = new MemoryStream(buf, 0, read))
        using (var sr = new StreamReader(ms, Encoding.UTF8, true))
            text = sr.ReadToEnd();

        ctx.Response.Write(SemsBatch.ImportParse(name, text));
    }
}
