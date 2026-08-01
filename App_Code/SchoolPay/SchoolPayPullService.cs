using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// SchoolPay Transaction-Sync (PULL) service. Fetches payments SchoolPay holds, stages them,
/// and reconciles anything we are missing through the ONE hardened capture engine
/// (fin_AutoPayCapture) via fin_SchoolPayReconcilePulled — fully de-duplicated.
///
/// Config (web.config appSettings): SchoolPay.SchoolCode, SchoolPay.Password, SchoolPay.ApiBaseUrl.
/// Auth hash = MD5(SchoolCode + identifyingDate + Password) UPPER (identifyingDate = date for a
/// single day, fromDate for a range).
/// </summary>
public static class SchoolPayPullService
{
    // ---- config ----
    private static string SchoolCode { get { return (ConfigurationManager.AppSettings["SchoolPay.SchoolCode"] ?? "").Trim(); } }
    private static string Password   { get { return (ConfigurationManager.AppSettings["SchoolPay.Password"] ?? "").Trim(); } }
    private static string BaseUrl
    {
        get
        {
            string b = (ConfigurationManager.AppSettings["SchoolPay.ApiBaseUrl"] ?? "https://schoolpay.co.ug/paymentapi/AndroidRS").Trim();
            return b.TrimEnd('/');
        }
    }
    private static string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    // ---- result summary returned to the controller ----
    public class PullResult
    {
        public bool Ok;
        public string RunId;
        public int ReturnCode;
        public string ReturnMessage = "";
        public int Fetched, NewCount, Existed, Captured, Failed;
        public double SpTotal, LocalTotal;
        public string Error;
    }

    // ---- JSON DTOs (match the official response schema) ----
    private class SpTxn
    {
        public string schoolpayReceiptNumber { get; set; }
        public string studentRegistrationNumber { get; set; }
        public string studentPaymentCode { get; set; }
        public string amount { get; set; }
        public string sourcePaymentChannel { get; set; }
        public string settlementBankCode { get; set; }
        public string sourceChannelTransactionId { get; set; }
        public string paymentDateAndTime { get; set; }
        public string studentName { get; set; }
        public string transactionCompletionStatus { get; set; }
        public string studentClass { get; set; }
        public string supplementaryFeeDescription { get; set; }
    }
    private class SpResponse
    {
        public int returnCode { get; set; }
        public string returnMessage { get; set; }
        public List<SpTxn> transactions { get; set; }
        public List<SpTxn> supplementaryFeePayments { get; set; }
    }

    // ====================================================================
    // PUBLIC ENTRY POINTS
    // ====================================================================

    /// <summary>Pull a single day and reconcile.</summary>
    public static PullResult SyncDay(DateTime date, string triggerType, string actor)
    {
        string d = date.ToString("yyyy-MM-dd");
        string url = BaseUrl + "/SyncSchoolTransactions/" + SchoolCode + "/" + d + "/" + Hash(SchoolCode + d + Password);
        return Run(url, date.Date, date.Date, triggerType, actor);
    }

    /// <summary>Pull a date range (max 31 days) and reconcile.</summary>
    public static PullResult SyncRange(DateTime from, DateTime to, string triggerType, string actor)
    {
        string f = from.ToString("yyyy-MM-dd"), t = to.ToString("yyyy-MM-dd");
        // Range hash uses the fromDate.
        string url = BaseUrl + "/SchoolRangeTransactions/" + SchoolCode + "/" + f + "/" + t + "/" + Hash(SchoolCode + f + Password);
        return Run(url, from.Date, to.Date, triggerType, actor);
    }

    /// <summary>Read-only connectivity/credential test (today). Does NOT stage or reconcile.</summary>
    public static PullResult TestConnection()
    {
        var r = new PullResult { RunId = "" };
        try
        {
            string d = DateTime.Now.ToString("yyyy-MM-dd");
            string url = BaseUrl + "/SyncSchoolTransactions/" + SchoolCode + "/" + d + "/" + Hash(SchoolCode + d + Password);
            SpResponse resp = ParseResponse(HttpGet(url));
            r.ReturnCode = resp.returnCode;
            r.ReturnMessage = resp.returnMessage ?? "";
            r.Fetched = Count(resp.transactions) + Count(resp.supplementaryFeePayments);
            r.Ok = (resp.returnCode == 0);
            if (!r.Ok) r.Error = "SchoolPay returned code " + resp.returnCode + ": " + r.ReturnMessage;
        }
        catch (Exception ex) { r.Ok = false; r.Error = ex.Message; }
        return r;
    }

    // ====================================================================
    // CORE
    // ====================================================================
    private static PullResult Run(string url, DateTime from, DateTime to, string triggerType, string actor)
    {
        var r = new PullResult();
        r.RunId = "PULL" + DateTime.Now.ToString("yyyyMMddHHmmssfff");
        if (string.IsNullOrEmpty(SchoolCode) || string.IsNullOrEmpty(Password))
        { r.Ok = false; r.Error = "SchoolPay credentials are not configured (web.config appSettings)."; return r; }

        try
        {
            SpResponse resp = ParseResponse(HttpGet(url));
            r.ReturnCode = resp.returnCode;
            r.ReturnMessage = resp.returnMessage ?? "";

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // synclog row (RUNNING)
                using (var cmd = new MySqlCommand(@"INSERT INTO fin_schoolpay_synclog
                    (run_id, txn_date_from, txn_date_to, trigger_type, triggered_by, run_started, return_code, return_message, status)
                    VALUES (@rid,@f,@t,@trg,@by,NOW(),@rc,@rm,'RUNNING')", conn))
                {
                    cmd.Parameters.AddWithValue("@rid", r.RunId);
                    cmd.Parameters.AddWithValue("@f", from);
                    cmd.Parameters.AddWithValue("@t", to);
                    cmd.Parameters.AddWithValue("@trg", triggerType ?? "MANUAL");
                    cmd.Parameters.AddWithValue("@by", string.IsNullOrEmpty(actor) ? "system" : actor);
                    cmd.Parameters.AddWithValue("@rc", resp.returnCode);
                    cmd.Parameters.AddWithValue("@rm", Trunc(resp.returnMessage, 500));
                    cmd.ExecuteNonQuery();
                }

                if (resp.returnCode != 0)
                {
                    using (var cmd = new MySqlCommand("UPDATE fin_schoolpay_synclog SET status='FAILED', run_finished=NOW() WHERE run_id=@rid", conn))
                    { cmd.Parameters.AddWithValue("@rid", r.RunId); cmd.ExecuteNonQuery(); }
                    r.Ok = false; r.Error = "SchoolPay returned code " + resp.returnCode + ": " + r.ReturnMessage;
                    return r;
                }

                // stage all transactions (regular + supplementary)
                double spTotal = 0;
                r.Fetched = StageAll(conn, r.RunId, resp.transactions, "SCHOOL", ref spTotal)
                          + StageAll(conn, r.RunId, resp.supplementaryFeePayments, "SUPPLEMENTARY", ref spTotal);
                r.SpTotal = spTotal;

                using (var cmd = new MySqlCommand("UPDATE fin_schoolpay_synclog SET fetched_count=@n, sp_total_amount=@amt WHERE run_id=@rid", conn))
                {
                    cmd.Parameters.AddWithValue("@n", r.Fetched);
                    cmd.Parameters.AddWithValue("@amt", spTotal);
                    cmd.Parameters.AddWithValue("@rid", r.RunId);
                    cmd.ExecuteNonQuery();
                }

                // reconcile (post anything missing via the hardened engine)
                using (var cmd = new MySqlCommand("CALL fin_SchoolPayReconcilePulled(@rid,@by)", conn))
                {
                    cmd.CommandTimeout = 300;
                    cmd.Parameters.AddWithValue("@rid", r.RunId);
                    cmd.Parameters.AddWithValue("@by", string.IsNullOrEmpty(actor) ? "system" : actor);
                    cmd.ExecuteNonQuery();
                }

                // read back the counts the SP wrote
                using (var cmd = new MySqlCommand(@"SELECT new_count,existed_count,captured_count,failed_count,
                       (SELECT IFNULL(SUM(amount_paid),0) FROM fin_schoolpaydata WHERE ReceiptNo IN
                          (SELECT receipt_no FROM fin_schoolpay_pull_staging WHERE run_id=@rid)) AS local_total
                       FROM fin_schoolpay_synclog WHERE run_id=@rid LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@rid", r.RunId);
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            r.NewCount = SafeInt(rd["new_count"]);
                            r.Existed  = SafeInt(rd["existed_count"]);
                            r.Captured = SafeInt(rd["captured_count"]);
                            r.Failed   = SafeInt(rd["failed_count"]);
                            r.LocalTotal = SafeDbl(rd["local_total"]);
                        }
                    }
                }
                r.Ok = true;
            }
        }
        catch (Exception ex)
        {
            r.Ok = false; r.Error = ex.Message;
            try
            {
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand("UPDATE fin_schoolpay_synclog SET status='ERROR', return_message=@m, run_finished=NOW() WHERE run_id=@rid", conn))
                    { cmd.Parameters.AddWithValue("@m", Trunc(ex.Message, 500)); cmd.Parameters.AddWithValue("@rid", r.RunId); cmd.ExecuteNonQuery(); }
                }
            }
            catch { }
        }
        return r;
    }

    private static int StageAll(MySqlConnection conn, string runId, List<SpTxn> list, string feeType, ref double total)
    {
        if (list == null) return 0;
        int n = 0;
        foreach (SpTxn x in list)
        {
            if (x == null || string.IsNullOrEmpty(x.schoolpayReceiptNumber)) continue;
            double amt = ParseAmount(x.amount);
            total += amt;
            using (var cmd = new MySqlCommand(@"INSERT IGNORE INTO fin_schoolpay_pull_staging
                (run_id, receipt_no, regno, student_payment_code, amount, channel, settlement_bank,
                 source_txn_id, pay_datetime, student_name, txn_status, fee_type, supp_fee_desc, reconcile_status, pulled_at)
                VALUES (@rid,@rcpt,@reg,@spc,@amt,@ch,@bank,@stx,@dt,@nm,@st,@ft,@sfd,'New',NOW())", conn))
            {
                cmd.Parameters.AddWithValue("@rid", runId);
                cmd.Parameters.AddWithValue("@rcpt", Trunc(x.schoolpayReceiptNumber, 45));
                cmd.Parameters.AddWithValue("@reg", Trunc(x.studentRegistrationNumber, 45));
                cmd.Parameters.AddWithValue("@spc", Trunc(x.studentPaymentCode, 45));
                cmd.Parameters.AddWithValue("@amt", amt);
                cmd.Parameters.AddWithValue("@ch", Trunc(x.sourcePaymentChannel, 45));
                cmd.Parameters.AddWithValue("@bank", Trunc(x.settlementBankCode, 45));
                cmd.Parameters.AddWithValue("@stx", Trunc(x.sourceChannelTransactionId, 60));
                cmd.Parameters.AddWithValue("@dt", ParseDate(x.paymentDateAndTime));
                cmd.Parameters.AddWithValue("@nm", Trunc(x.studentName, 100));
                cmd.Parameters.AddWithValue("@st", Trunc(x.transactionCompletionStatus, 30));
                cmd.Parameters.AddWithValue("@ft", feeType);
                cmd.Parameters.AddWithValue("@sfd", Trunc(x.supplementaryFeeDescription, 100));
                cmd.ExecuteNonQuery();
            }
            n++;
        }
        return n;
    }

    // ====================================================================
    // HELPERS
    // ====================================================================
    private static string Hash(string input)
    {
        using (MD5 md5 = MD5.Create())
        {
            byte[] bytes = md5.ComputeHash(Encoding.ASCII.GetBytes(input));
            var sb = new StringBuilder();
            foreach (byte b in bytes) sb.Append(b.ToString("X2"));
            return sb.ToString();
        }
    }

    private static string HttpGet(string url)
    {
        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
        var req = (HttpWebRequest)WebRequest.Create(url);
        req.Method = "GET";
        req.Accept = "application/json";
        req.Timeout = 90000;
        req.ReadWriteTimeout = 90000;
        using (var resp = (HttpWebResponse)req.GetResponse())
        using (var reader = new StreamReader(resp.GetResponseStream()))
            return reader.ReadToEnd();
    }

    private static SpResponse ParseResponse(string json)
    {
        var ser = new JavaScriptSerializer();
        ser.MaxJsonLength = int.MaxValue;
        return ser.Deserialize<SpResponse>(json ?? "");
    }

    private static double ParseAmount(string s)
    {
        double v;
        if (string.IsNullOrEmpty(s)) return 0;
        if (double.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out v)) return v;
        return 0;
    }
    private static object ParseDate(string s)
    {
        DateTime dt;
        if (!string.IsNullOrEmpty(s) &&
            (DateTime.TryParseExact(s, "yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture, DateTimeStyles.None, out dt) ||
             DateTime.TryParse(s, out dt)))
            return dt;
        return DBNull.Value;
    }
    private static int Count<T>(List<T> l) { return l == null ? 0 : l.Count; }
    private static string Trunc(string s, int n) { s = s ?? ""; return s.Length > n ? s.Substring(0, n) : s; }
    private static int SafeInt(object o) { int v; return (o == null || o == DBNull.Value || !int.TryParse(o.ToString(), out v)) ? 0 : v; }
    private static double SafeDbl(object o) { double v; return (o == null || o == DBNull.Value || !double.TryParse(o.ToString(), out v)) ? 0 : v; }
}
