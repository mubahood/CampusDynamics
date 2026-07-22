using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// ID Card management API (v2). Token-authenticated, rate-limited, action-routed.
/// One audited state machine: every write flows through the IDCardService.Transition
/// funnel (same as eadmin/eportal). Responses use the standard v2 envelope
/// ({success, message, data, error_code}).
///
/// AUTHORISATION
///   read   (queue/detail/stats/windows/meta/export)  -> staff | idcard_operator | admin
///                                                        (student: own detail only; my/finance/etc.)
///   write  (approve/halt/printed/ready/collected/cancel, batch, windows) -> idcard_operator | admin
///   self   (my/identity/finance/create/submit/cancel_own)                -> the token owner
///
/// ENDPOINTS (see API_DOCUMENTATION.md - ID Card)
///   GET  ?action=queue     filters: status(csv), type, card_type, q, date_from, date_to,
///                          window_id, finance(ok|below|flagged), has_replacement_fee(0|1)
///                          paging: page, page_size(<=200), sort, order
///   GET  ?action=detail&request_no=IDR-...
///   GET  ?action=stats[&date_from=&date_to=]
///   GET  ?action=windows | ?action=meta
///   GET  ?action=export   (CSV of the current filter set)
///   POST ?action=approve|halt|printed|ready|collected|cancel&request_no=...[&reason=&collection_point=]
///   POST ?action=batch&request_nos=IDR-1,IDR-2&batch_action=approve[&reason=&collection_point=]
///   POST ?action=window_create&title=&scope=&opens_at=&closes_at=[&notes=]
///   POST ?action=window_activate|window_close&id=NN
///   GET  ?action=my | identity | finance
///   POST ?action=create&card_type=NEW|REPLACEMENT&photo_confirmed=1&guidelines_ack=1
///   POST ?action=submit&request_no=...[&repl_ref=&repl_date=&repl_method=&repl_notes=]
///   POST ?action=cancel_own&request_no=...
/// </summary>
public partial class API_v2_idcard : System.Web.UI.Page
{
    private const int BATCH_CAP = 500;
    private const int EXPORT_CAP = 10000;
    private static readonly JavaScriptSerializer J = new JavaScriptSerializer();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;
        if (ApiHelper.IsRateLimited(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLowerInvariant();

        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string actor = !string.IsNullOrEmpty(auth.FullName) ? auth.FullName : auth.UserId;
        string role = (auth.UserType ?? "").ToLowerInvariant();

        try
        {
            string rn = ApiHelper.Param(Request, "request_no", "");
            switch (action)
            {
                // -- READ (staff / operator / admin) --
                case "queue":
                    if (!RequireRead(auth)) return;
                    Emit(IDCardService.ListJsonEx(BuildFilters(),
                        ApiHelper.ParamInt(Request, "page", 1), ApiHelper.ParamInt(Request, "page_size", 50),
                        ApiHelper.Param(Request, "sort", "created_at"), ApiHelper.Param(Request, "order", "desc")));
                    break;

                case "stats":
                    if (!RequireRead(auth)) return;
                    Emit(IDCardService.StatsJson(ApiHelper.Param(Request, "date_from", ""), ApiHelper.Param(Request, "date_to", "")));
                    break;

                case "windows":
                    if (!RequireRead(auth)) return;
                    Emit(IDCardService.WindowsJson());
                    break;

                case "meta":
                    Emit(IDCardService.MetaJson());
                    break;

                case "detail":
                    if (rn == "") { ApiHelper.Error(Response, "request_no is required", "MISSING_PARAM"); return; }
                    if (!CanRead(auth))
                    {
                        string t, r; int emp;
                        if (!ResolveRequester(auth, out t, out r, out emp)) { ApiHelper.Error(Response, "Not permitted.", "FORBIDDEN"); return; }
                        if (!OwnsRequest(rn, t, r, emp)) { ApiHelper.Error(Response, "You can only view your own request.", "FORBIDDEN"); return; }
                    }
                    Emit(IDCardService.DetailJson(rn));
                    break;

                case "export":
                    if (!RequireRead(auth)) return;
                    ExportCsv();
                    break;

                // -- WRITE single lifecycle (operator / admin) --
                case "approve":
                case "halt":
                case "printed":
                case "ready":
                case "collected":
                case "cancel":
                    if (!RequireOperator(auth)) return;
                    if (rn == "") { ApiHelper.Error(Response, "request_no is required", "MISSING_PARAM"); return; }
                    Emit(IDCardService.ActionJson(rn, action,
                        ApiHelper.Param(Request, "reason", ""), ApiHelper.Param(Request, "collection_point", ""),
                        actor, role, "api"));
                    break;

                // -- BATCH (operator / admin) --
                case "batch":
                    if (!RequireOperator(auth)) return;
                    Emit(IDCardService.BatchActionJson(
                        NormalizeRequestNos(ApiHelper.Param(Request, "request_nos", "")),
                        ApiHelper.Param(Request, "batch_action", ""),
                        ApiHelper.Param(Request, "reason", ""), ApiHelper.Param(Request, "collection_point", ""),
                        actor, role, "api", BATCH_CAP));
                    break;

                // -- WINDOWS management (operator / admin) --
                case "window_create":
                    if (!RequireOperator(auth)) return;
                    Emit(IDCardService.CreateWindowJson(
                        ApiHelper.Param(Request, "title", ""), ApiHelper.Param(Request, "scope", "BOTH"),
                        ApiHelper.Param(Request, "opens_at", ""), ApiHelper.Param(Request, "closes_at", ""),
                        ApiHelper.Param(Request, "notes", ""), actor));
                    break;

                case "window_activate":
                    if (!RequireOperator(auth)) return;
                    Emit(IDCardService.SetWindowActiveJson(ApiHelper.ParamInt(Request, "id", 0), true));
                    break;

                case "window_close":
                    if (!RequireOperator(auth)) return;
                    Emit(IDCardService.SetWindowActiveJson(ApiHelper.ParamInt(Request, "id", 0), false));
                    break;

                // -- SELF-SERVICE (token owner) --
                case "my":
                case "identity":
                case "finance":
                case "create":
                case "submit":
                case "cancel_own":
                    HandleSelfService(action, auth, actor, role);
                    break;

                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". See API_DOCUMENTATION.md (ID Card).", "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    // -- self-service dispatch --
    private void HandleSelfService(string action, TokenInfo auth, string actor, string role)
    {
        string type, regno; int empId;
        if (!ResolveRequester(auth, out type, out regno, out empId))
        {
            ApiHelper.Error(Response, "This endpoint is for the card owner (student/staff).", "FORBIDDEN");
            return;
        }
        string rn = ApiHelper.Param(Request, "request_no", "");
        switch (action)
        {
            case "my":
                Emit(IDCardService.MyRequestJson(type, regno, empId));
                break;
            case "identity":
                Emit(IDCardService.IdentityJson(type, regno, empId));
                break;
            case "finance":
                if (type != "STUDENT") { ApiHelper.Error(Response, "Finance check applies to students only.", "FORBIDDEN"); return; }
                Emit(IDCardService.FinanceJson(regno));
                break;
            case "create":
                Emit(IDCardService.CreateJson(type, regno, empId,
                    ApiHelper.Param(Request, "card_type", "NEW"), ApiHelper.Param(Request, "photo_ref", ""),
                    IsTrue(ApiHelper.Param(Request, "photo_confirmed", "")),
                    IsTrue(ApiHelper.Param(Request, "guidelines_ack", "")),
                    actor));
                break;
            case "submit":
                if (rn == "") { ApiHelper.Error(Response, "request_no is required", "MISSING_PARAM"); return; }
                if (!OwnsRequest(rn, type, regno, empId)) { ApiHelper.Error(Response, "You can only submit your own request.", "FORBIDDEN"); return; }
                Emit(IDCardService.SubmitJson(rn,
                    ApiHelper.Param(Request, "repl_ref", ""), ApiHelper.Param(Request, "repl_date", ""),
                    ApiHelper.Param(Request, "repl_method", ""), ApiHelper.Param(Request, "repl_notes", ""), actor));
                break;
            case "cancel_own":
                if (rn == "") { ApiHelper.Error(Response, "request_no is required", "MISSING_PARAM"); return; }
                if (!OwnsRequest(rn, type, regno, empId)) { ApiHelper.Error(Response, "You can only cancel your own request.", "FORBIDDEN"); return; }
                Emit(IDCardService.ActionJson(rn, "cancel", "", "", actor, role, "api"));
                break;
        }
    }

    // -- authorisation helpers --
    private static bool IsTrue(string v) { v = (v ?? "").Trim().ToLowerInvariant(); return v == "1" || v == "true" || v == "yes"; }

    /// <summary>The permanent 'xaxu' integration token is a superuser — always authorised for every ID card action.</summary>
    private static bool IsSuper(TokenInfo a)
    {
        return a != null && (
            string.Equals(a.Token, "xaxu", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(a.UserId, "xaxu", StringComparison.OrdinalIgnoreCase));
    }

    private static bool IsOperator(TokenInfo a)
    {
        if (IsSuper(a)) return true;
        string t = (a.UserType ?? "").ToLowerInvariant();
        return t == "idcard_operator" || t == "admin";
    }
    private static bool CanRead(TokenInfo a)
    {
        if (IsSuper(a)) return true;
        string t = (a.UserType ?? "").ToLowerInvariant();
        return t == "idcard_operator" || t == "admin" || t == "staff";
    }
    private bool RequireOperator(TokenInfo a)
    {
        if (IsOperator(a)) return true;
        ApiHelper.Error(Response, "ID card operator or admin access required.", "FORBIDDEN");
        return false;
    }
    private bool RequireRead(TokenInfo a)
    {
        if (CanRead(a)) return true;
        ApiHelper.Error(Response, "Staff, operator or admin access required. Students: use action=my.", "FORBIDDEN");
        return false;
    }

    // Resolve the requester identity from the token. Student: regno=UserId. Staff: look up empID.
    private bool ResolveRequester(TokenInfo a, out string type, out string regno, out int empId)
    {
        type = null; regno = null; empId = 0;
        string t = (a.UserType ?? "").ToLowerInvariant();
        if (t == "student")
        {
            type = "STUDENT"; regno = a.UserId; return !string.IsNullOrEmpty(regno);
        }
        if (t == "staff")
        {
            type = "STAFF";
            object v = ApiHelper.Scalar("SELECT empID FROM hrm_employee WHERE usernames=@u OR EMP_CODE=@u LIMIT 1",
                new MySqlParameter("@u", a.UserId ?? ""));
            if (v == null || v == DBNull.Value) return false;
            empId = Convert.ToInt32(v);
            return empId > 0;
        }
        return false;
    }

    private bool OwnsRequest(string requestNo, string type, string regno, int empId)
    {
        object v;
        if (type == "STAFF")
            v = ApiHelper.Scalar("SELECT 1 FROM idcard_requests WHERE request_no=@rn AND requester_type='STAFF' AND emp_id=@e LIMIT 1",
                new MySqlParameter("@rn", requestNo), new MySqlParameter("@e", empId));
        else
            v = ApiHelper.Scalar("SELECT 1 FROM idcard_requests WHERE request_no=@rn AND requester_type='STUDENT' AND TRIM(regno)=TRIM(@r) LIMIT 1",
                new MySqlParameter("@rn", requestNo), new MySqlParameter("@r", regno ?? ""));
        return v != null && v != DBNull.Value;
    }

    // -- filter builder --
    private Dictionary<string, string> BuildFilters()
    {
        var f = new Dictionary<string, string>();
        AddF(f, "status", ApiHelper.Param(Request, "status", ""));
        AddF(f, "type", ApiHelper.Param(Request, "type", ""));
        AddF(f, "card_type", ApiHelper.Param(Request, "card_type", ""));
        AddF(f, "q", ApiHelper.Param(Request, "q", ""));
        AddF(f, "date_from", ApiHelper.Param(Request, "date_from", ""));
        AddF(f, "date_to", ApiHelper.Param(Request, "date_to", ""));
        AddF(f, "window_id", ApiHelper.Param(Request, "window_id", ""));
        AddF(f, "finance", ApiHelper.Param(Request, "finance", ""));
        AddF(f, "has_replacement_fee", ApiHelper.Param(Request, "has_replacement_fee", ""));
        return f;
    }
    private static void AddF(Dictionary<string, string> f, string k, string v) { if (!string.IsNullOrEmpty(v)) f[k] = v; }

    // Accept CSV or JSON array for request_nos; return CSV for the service.
    private string NormalizeRequestNos(string raw)
    {
        raw = (raw ?? "").Trim();
        if (raw.StartsWith("["))
        {
            try
            {
                var arr = J.Deserialize<List<string>>(raw);
                if (arr != null) return string.Join(",", arr.ToArray());
            }
            catch { }
        }
        return raw;
    }

    // -- emit: unwrap service JSON into the standard v2 envelope --
    private void Emit(string serviceJson)
    {
        Dictionary<string, object> o;
        try { o = J.Deserialize<Dictionary<string, object>>(serviceJson); }
        catch { ApiHelper.Error(Response, "Malformed service response.", "SERVER_ERROR"); return; }
        if (o == null) { ApiHelper.Error(Response, "Empty service response.", "SERVER_ERROR"); return; }

        bool ok = o.ContainsKey("success") && o["success"] != null && Convert.ToBoolean(o["success"]);
        string msg = o.ContainsKey("message") && o["message"] != null ? o["message"].ToString() : "";
        string code = o.ContainsKey("error_code") && o["error_code"] != null ? o["error_code"].ToString() : "";

        if (!ok)
        {
            ApiHelper.Error(Response, string.IsNullOrEmpty(msg) ? "Request failed." : msg,
                string.IsNullOrEmpty(code) ? "REQUEST_FAILED" : code);
            return;
        }
        o.Remove("success"); o.Remove("message"); o.Remove("error_code"); o.Remove("timestamp");
        ApiHelper.Success(Response, o, string.IsNullOrEmpty(msg) ? "OK" : msg);
    }

    // -- CSV export of the current filter set (iterates pages up to EXPORT_CAP) --
    private void ExportCsv()
    {
        var f = BuildFilters();
        string sort = ApiHelper.Param(Request, "sort", "created_at");
        string order = ApiHelper.Param(Request, "order", "desc");
        var sb = new StringBuilder();
        sb.Append("request_no,requester_type,card_type,status,number,name,created_at,submitted_at,updated_at\r\n");

        int page = 1, pulled = 0; bool more = true;
        while (more && pulled < EXPORT_CAP)
        {
            string js = IDCardService.ListJsonEx(f, page, 200, sort, order);
            Dictionary<string, object> o;
            try { o = J.Deserialize<Dictionary<string, object>>(js); } catch { break; }
            if (o == null || !(o.ContainsKey("success") && Convert.ToBoolean(o["success"]))) break;
            object rowsObj = o.ContainsKey("rows") ? o["rows"] : null;
            var rows = rowsObj as System.Collections.IEnumerable;   // JavaScriptSerializer -> object[]
            if (rows == null) break;
            int before = pulled;
            foreach (object rowObj in rows)
            {
                var r = rowObj as Dictionary<string, object>;
                if (r == null) continue;
                sb.Append(Csv(RS(r, "requestNo"))).Append(',')
                  .Append(Csv(RS(r, "type"))).Append(',')
                  .Append(Csv(RS(r, "cardType"))).Append(',')
                  .Append(Csv(RS(r, "status"))).Append(',')
                  .Append(Csv(RS(r, "number"))).Append(',')
                  .Append(Csv(RS(r, "name"))).Append(',')
                  .Append(Csv(RS(r, "createdAt"))).Append(',')
                  .Append(Csv(RS(r, "submittedAt"))).Append(',')
                  .Append(Csv(RS(r, "updatedAt"))).Append("\r\n");
                pulled++;
            }
            if (pulled == before) break;   // page returned no usable rows
            bool hasNext = o.ContainsKey("has_next") && o["has_next"] != null && Convert.ToBoolean(o["has_next"]);
            more = hasNext;
            page++;
        }

        if (HttpContext.Current != null && HttpContext.Current.Items.Contains("_api_response_sent")) return;
        Response.Clear();
        Response.ContentType = "text/csv; charset=utf-8";
        Response.AppendHeader("Content-Disposition", "attachment; filename=idcard_export.csv");
        Response.Write(sb.ToString());
        if (HttpContext.Current != null) HttpContext.Current.Items["_api_response_sent"] = true;
        Response.Flush();
        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    private static string RS(Dictionary<string, object> r, string k) { return r.ContainsKey(k) && r[k] != null ? r[k].ToString() : ""; }
    private static string Csv(string v)
    {
        if (v == null) v = "";
        if (v.IndexOf(',') >= 0 || v.IndexOf('"') >= 0 || v.IndexOf('\n') >= 0 || v.IndexOf('\r') >= 0)
            return "\"" + v.Replace("\"", "\"\"") + "\"";
        return v;
    }
}
