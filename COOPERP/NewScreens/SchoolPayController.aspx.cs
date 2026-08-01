using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_SchoolPayController : System.Web.UI.Page
{
    private string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    private string CurrentUser
    {
        get
        {
            if (Session["username"] != null && Session["username"].ToString().Trim() != "")
                return Session["username"].ToString().Trim();
            return "admin";
        }
    }

    // ===================================================================
    protected void Page_Load(object sender, EventArgs e)
    {
        string act = (Request["act"] ?? "").Trim().ToLowerInvariant();
        if (act == "") return; // normal page render

        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        try
        {
            switch (act)
            {
                case "stats":        WriteStats();        break;
                case "testconn":     WriteTestConn();     break;
                case "pull":         WritePull();         break;
                case "runrows":      WriteRunRows();      break;
                case "pending":      WritePending();      break;
                case "recapture":    WriteRecapture();    break;
                case "recaptureall": WriteRecaptureAll(); break;
                case "synclog":      WriteSyncLog();      break;
                case "recent":       WriteRecent();       break;
                case "transactions": WriteTransactions(); break;
                case "detail":       WriteDetail();       break;
                case "jobstatus":    WriteJobStatus();    break;
                case "jobrestart":   WriteJobRestart();   break;
                case "jobrun":       WriteJobRun();       break;
                case "jobtoggle":    WriteJobToggle();    break;
                default: Response.Write("{\"ok\":false,\"message\":\"Unknown action\"}"); break;
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"message\":" + JS(ex.Message) + "}");
        }
        Response.End();
    }

    // ===================================================================
    // OVERVIEW STATS
    // ===================================================================
    private void WriteStats()
    {
        var sb = new StringBuilder("{\"ok\":true");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"
                SELECT
                  (SELECT COUNT(*)               FROM fin_schoolpaydata WHERE DATE(datePaid)=CURDATE()) today_cnt,
                  (SELECT IFNULL(SUM(amount_paid),0) FROM fin_schoolpaydata WHERE DATE(datePaid)=CURDATE()) today_amt,
                  (SELECT COUNT(*)               FROM fin_schoolpaydata WHERE datePaid>=DATE_SUB(CURDATE(),INTERVAL 7 DAY)) week_cnt,
                  (SELECT IFNULL(SUM(amount_paid),0) FROM fin_schoolpaydata WHERE datePaid>=DATE_SUB(CURDATE(),INTERVAL 7 DAY)) week_amt,
                  (SELECT COUNT(*)               FROM fin_schoolpaydata) total_cnt,
                  (SELECT IFNULL(SUM(amount_paid),0) FROM fin_schoolpaydata) total_amt,
                  (SELECT COUNT(*)               FROM fin_schoolpaydata WHERE captureStatus='Pending') pending_cnt,
                  (SELECT IFNULL(SUM(amount_paid),0) FROM fin_schoolpaydata WHERE captureStatus='Pending') pending_amt", conn))
            using (var r = cmd.ExecuteReader())
            {
                if (r.Read())
                {
                    sb.Append(",\"today_cnt\":").Append(L(r["today_cnt"])).Append(",\"today_amt\":").Append(D(r["today_amt"]));
                    sb.Append(",\"week_cnt\":").Append(L(r["week_cnt"])).Append(",\"week_amt\":").Append(D(r["week_amt"]));
                    sb.Append(",\"total_cnt\":").Append(L(r["total_cnt"])).Append(",\"total_amt\":").Append(D(r["total_amt"]));
                    sb.Append(",\"pending_cnt\":").Append(L(r["pending_cnt"])).Append(",\"pending_amt\":").Append(D(r["pending_amt"]));
                }
            }
            sb.Append(",\"channels\":[");
            using (var cmd = new MySqlCommand(@"SELECT channelPaid, COUNT(*) n, IFNULL(SUM(amount_paid),0) amt
                FROM fin_schoolpaydata WHERE datePaid>=DATE_SUB(CURDATE(),INTERVAL 30 DAY)
                GROUP BY channelPaid ORDER BY n DESC LIMIT 10", conn))
            using (var r = cmd.ExecuteReader())
            {
                bool first = true;
                while (r.Read())
                {
                    if (!first) sb.Append(","); first = false;
                    sb.Append("{\"name\":").Append(JS(r["channelPaid"].ToString()))
                      .Append(",\"n\":").Append(L(r["n"])).Append(",\"amt\":").Append(D(r["amt"])).Append("}");
                }
            }
            sb.Append("]");
            using (var cmd = new MySqlCommand("SELECT MAX(run_started) FROM fin_schoolpay_synclog WHERE status='OK'", conn))
            {
                object o = cmd.ExecuteScalar();
                sb.Append(",\"last_sync\":").Append(JS(o == null || o == DBNull.Value ? "never" : Convert.ToDateTime(o).ToString("dd MMM yyyy HH:mm")));
            }
        }
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    // ===================================================================
    // TEST CONNECTION (read-only credential check)
    // ===================================================================
    private void WriteTestConn()
    {
        SchoolPayPullService.PullResult res = SchoolPayPullService.TestConnection();
        Response.Write("{\"ok\":" + (res.Ok ? "true" : "false")
            + ",\"returnCode\":" + res.ReturnCode
            + ",\"fetched\":" + res.Fetched
            + ",\"message\":" + JS(res.Ok ? ("Connected. SchoolPay reachable — " + res.Fetched + " transaction(s) for today.") : (res.Error ?? res.ReturnMessage))
            + "}");
    }

    // ===================================================================
    // PULL + RECONCILE (a date range, max 31 days)
    // ===================================================================
    private void WritePull()
    {
        DateTime from, to;
        string f = (Request["from"] ?? "").Trim(), t = (Request["to"] ?? "").Trim();
        if (!DateTime.TryParse(f, out from) || !DateTime.TryParse(t, out to))
        { Response.Write("{\"ok\":false,\"message\":" + JS("Please supply valid From and To dates.") + "}"); return; }
        if (to < from) { var tmp = from; from = to; to = tmp; }
        if ((to - from).TotalDays > 31)
        { Response.Write("{\"ok\":false,\"message\":" + JS("The range cannot exceed 31 days (SchoolPay limit). Pull in smaller chunks.") + "}"); return; }

        SchoolPayPullService.PullResult res = SchoolPayPullService.SyncRange(from, to, "MANUAL", CurrentUser);
        if (!res.Ok)
        { Response.Write("{\"ok\":false,\"message\":" + JS(res.Error ?? res.ReturnMessage) + "}"); return; }

        Response.Write("{\"ok\":true,\"run_id\":" + JS(res.RunId)
            + ",\"fetched\":" + res.Fetched + ",\"new\":" + res.NewCount + ",\"existed\":" + res.Existed
            + ",\"captured\":" + res.Captured + ",\"failed\":" + res.Failed
            + ",\"sp_total\":" + res.SpTotal.ToString(CultureInfo.InvariantCulture)
            + ",\"local_total\":" + res.LocalTotal.ToString(CultureInfo.InvariantCulture)
            + ",\"message\":" + JS(res.ReturnMessage) + "}");
    }

    // rows staged/reconciled for a run (results table)
    private void WriteRunRows()
    {
        string rid = (Request["run_id"] ?? "").Trim();
        var sb = new StringBuilder("{\"ok\":true,\"rows\":[");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"SELECT receipt_no, regno, amount, channel, pay_datetime, student_name, reconcile_status, fee_type
                FROM fin_schoolpay_pull_staging WHERE run_id=@rid ORDER BY (reconcile_status IN ('Captured','NoStudent','Failed')) DESC, pay_datetime", conn))
            {
                cmd.Parameters.AddWithValue("@rid", rid);
                using (var r = cmd.ExecuteReader())
                {
                    bool first = true;
                    while (r.Read())
                    {
                        if (!first) sb.Append(","); first = false;
                        sb.Append("{\"receipt\":").Append(JS(r["receipt_no"].ToString()))
                          .Append(",\"regno\":").Append(JS(r["regno"].ToString()))
                          .Append(",\"amount\":").Append(D(r["amount"]))
                          .Append(",\"channel\":").Append(JS(r["channel"].ToString()))
                          .Append(",\"date\":").Append(JS(DateStr(r["pay_datetime"])))
                          .Append(",\"name\":").Append(JS(r["student_name"].ToString()))
                          .Append(",\"status\":").Append(JS(r["reconcile_status"].ToString()))
                          .Append(",\"fee\":").Append(JS(r["fee_type"].ToString())).Append("}");
                    }
                }
            }
        }
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    // ===================================================================
    // PENDING + RECAPTURE
    // ===================================================================
    private void WritePending()
    {
        var sb = new StringBuilder("{\"ok\":true,\"rows\":[");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"SELECT ReceiptNo, regno, datePaid, channelPaid, amount_paid, stud_name
                FROM fin_schoolpaydata WHERE captureStatus='Pending' ORDER BY datePaid DESC LIMIT 1000", conn))
            using (var r = cmd.ExecuteReader())
            {
                bool first = true;
                while (r.Read())
                {
                    if (!first) sb.Append(","); first = false;
                    sb.Append("{\"receipt\":").Append(JS(r["ReceiptNo"].ToString()))
                      .Append(",\"regno\":").Append(JS(r["regno"].ToString()))
                      .Append(",\"date\":").Append(JS(DateStr(r["datePaid"])))
                      .Append(",\"channel\":").Append(JS(r["channelPaid"].ToString()))
                      .Append(",\"amount\":").Append(D(r["amount_paid"]))
                      .Append(",\"name\":").Append(JS(r["stud_name"].ToString())).Append("}");
                }
            }
        }
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    private void WriteRecaptureAll()
    {
        int before, after;
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            before = PendingCount(conn);
            using (var cmd = new MySqlCommand("CALL fin_SchoolPayRecaptureAllPending()", conn))
            { cmd.CommandTimeout = 300; cmd.ExecuteNonQuery(); }
            after = PendingCount(conn);
        }
        Response.Write("{\"ok\":true,\"posted\":" + (before - after) + ",\"remaining\":" + after
            + ",\"message\":" + JS((before - after) + " payment(s) posted; " + after + " still pending.") + "}");
    }

    // recapture a single pending receipt (drives the same hardened engine)
    private void WriteRecapture()
    {
        string receipt = (Request["receipt"] ?? "").Trim();
        if (receipt == "") { Response.Write("{\"ok\":false,\"message\":\"Receipt required.\"}"); return; }
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            string reg = "", ch = "", nm = ""; double amt = 0; DateTime dt = DateTime.Today; bool found = false;
            using (var cmd = new MySqlCommand("SELECT regno, channelPaid, amount_paid, stud_name, datePaid FROM fin_schoolpaydata WHERE ReceiptNo=@r AND captureStatus='Pending' LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", receipt);
                using (var r = cmd.ExecuteReader())
                    if (r.Read()) { found = true; reg = r["regno"].ToString(); ch = r["channelPaid"].ToString(); amt = Convert.ToDouble(r["amount_paid"]); nm = r["stud_name"].ToString(); dt = Convert.ToDateTime(r["datePaid"]); }
            }
            if (!found) { Response.Write("{\"ok\":false,\"message\":\"Not found or already captured.\"}"); return; }
            string bank = ch.ToLower().Contains("dfcu") || ch.ToLower().Contains("centenary") ? "AC1303" : (ch.ToLower().Contains("eco") ? "AC1308" : "AC1302");
            using (var cmd = new MySqlCommand("CALL fin_AutoPayCapture(@reg,@nm,@bank,@amt,@dt,'manual-recapture',@ch,@tid)", conn))
            {
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@reg", reg);
                cmd.Parameters.AddWithValue("@nm", nm + " [" + reg + "] - SCHOOLPAY");
                cmd.Parameters.AddWithValue("@bank", bank);
                cmd.Parameters.AddWithValue("@amt", amt);
                cmd.Parameters.AddWithValue("@dt", dt.Date);
                cmd.Parameters.AddWithValue("@ch", ch);
                cmd.Parameters.AddWithValue("@tid", receipt);
                cmd.ExecuteNonQuery();
            }
            string status;
            using (var cmd = new MySqlCommand("SELECT captureStatus FROM fin_schoolpaydata WHERE ReceiptNo=@r", conn))
            { cmd.Parameters.AddWithValue("@r", receipt); status = Convert.ToString(cmd.ExecuteScalar()); }
            bool ok = status == "Captured";
            Response.Write("{\"ok\":" + (ok ? "true" : "false") + ",\"message\":" + JS(ok ? "Payment posted." : "Could not post (check the student's ledger/registration).") + "}");
        }
    }

    private int PendingCount(MySqlConnection conn)
    {
        using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM fin_schoolpaydata WHERE captureStatus='Pending'", conn))
            return Convert.ToInt32(cmd.ExecuteScalar());
    }

    // ===================================================================
    // SYNC LOG
    // ===================================================================
    private void WriteSyncLog()
    {
        var sb = new StringBuilder("{\"ok\":true,\"rows\":[");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"SELECT run_id, txn_date_from, txn_date_to, trigger_type, triggered_by,
                run_started, return_code, fetched_count, new_count, existed_count, captured_count, failed_count,
                sp_total_amount, status FROM fin_schoolpay_synclog ORDER BY run_started DESC LIMIT 100", conn))
            using (var r = cmd.ExecuteReader())
            {
                bool first = true;
                while (r.Read())
                {
                    if (!first) sb.Append(","); first = false;
                    sb.Append("{\"run\":").Append(JS(r["run_id"].ToString()))
                      .Append(",\"from\":").Append(JS(DateStr(r["txn_date_from"])))
                      .Append(",\"to\":").Append(JS(DateStr(r["txn_date_to"])))
                      .Append(",\"trg\":").Append(JS(r["trigger_type"].ToString()))
                      .Append(",\"by\":").Append(JS(r["triggered_by"].ToString()))
                      .Append(",\"started\":").Append(JS(DateStr(r["run_started"])))
                      .Append(",\"rc\":").Append(L(r["return_code"]))
                      .Append(",\"fetched\":").Append(L(r["fetched_count"]))
                      .Append(",\"new\":").Append(L(r["new_count"]))
                      .Append(",\"existed\":").Append(L(r["existed_count"]))
                      .Append(",\"captured\":").Append(L(r["captured_count"]))
                      .Append(",\"failed\":").Append(L(r["failed_count"]))
                      .Append(",\"amt\":").Append(D(r["sp_total_amount"]))
                      .Append(",\"status\":").Append(JS(r["status"].ToString())).Append("}");
                }
            }
        }
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    // ===================================================================
    // RECENT captured
    // ===================================================================
    private void WriteRecent()
    {
        var sb = new StringBuilder("{\"ok\":true,\"rows\":[");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"SELECT ReceiptNo, regno, datePaid, channelPaid, amount_paid, stud_name, captureStatus
                FROM fin_schoolpaydata ORDER BY datePaid DESC LIMIT 25", conn))
            using (var r = cmd.ExecuteReader())
            {
                bool first = true;
                while (r.Read())
                {
                    if (!first) sb.Append(","); first = false;
                    sb.Append("{\"receipt\":").Append(JS(r["ReceiptNo"].ToString()))
                      .Append(",\"regno\":").Append(JS(r["regno"].ToString()))
                      .Append(",\"date\":").Append(JS(DateStr(r["datePaid"])))
                      .Append(",\"channel\":").Append(JS(r["channelPaid"].ToString()))
                      .Append(",\"amount\":").Append(D(r["amount_paid"]))
                      .Append(",\"name\":").Append(JS(r["stud_name"].ToString()))
                      .Append(",\"status\":").Append(JS(r["captureStatus"].ToString())).Append("}");
                }
            }
        }
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    // ===================================================================
    // TRANSACTIONS browser (search)
    // ===================================================================
    private void WriteTransactions()
    {
        string q = (Request["q"] ?? "").Trim();
        string status = (Request["status"] ?? "").Trim();
        string where = " WHERE 1=1 ";
        if (q != "") where += " AND (ReceiptNo LIKE @q OR regno LIKE @q OR stud_name LIKE @q) ";
        if (status == "Captured" || status == "Pending") where += " AND captureStatus=@st ";

        var sb = new StringBuilder("{\"ok\":true,\"rows\":[");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"SELECT ReceiptNo, regno, datePaid, channelPaid, amount_paid, stud_name, captureStatus
                FROM fin_schoolpaydata " + where + " ORDER BY datePaid DESC LIMIT 300", conn))
            {
                if (q != "") cmd.Parameters.AddWithValue("@q", "%" + q + "%");
                if (status == "Captured" || status == "Pending") cmd.Parameters.AddWithValue("@st", status);
                using (var r = cmd.ExecuteReader())
                {
                    bool first = true;
                    while (r.Read())
                    {
                        if (!first) sb.Append(","); first = false;
                        sb.Append("{\"receipt\":").Append(JS(r["ReceiptNo"].ToString()))
                          .Append(",\"regno\":").Append(JS(r["regno"].ToString()))
                          .Append(",\"date\":").Append(JS(DateStr(r["datePaid"])))
                          .Append(",\"channel\":").Append(JS(r["channelPaid"].ToString()))
                          .Append(",\"amount\":").Append(D(r["amount_paid"]))
                          .Append(",\"name\":").Append(JS(r["stud_name"].ToString()))
                          .Append(",\"status\":").Append(JS(r["captureStatus"].ToString())).Append("}");
                    }
                }
            }
        }
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    // ===================================================================
    // TRANSACTION DETAIL — payment + capture (GL) + student + account + links
    // ===================================================================
    private void WriteDetail()
    {
        string receipt = (Request["receipt"] ?? "").Trim();
        if (receipt == "") { Response.Write("{\"ok\":false,\"message\":\"Receipt required.\"}"); return; }

        var sb = new StringBuilder("{\"ok\":true");
        string regno = "";
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();

            // --- what came in (our captured record) ---
            bool havePay = false;
            using (var cmd = new MySqlCommand("SELECT ReceiptNo,regno,datePaid,channelPaid,amount_paid,stud_name,captureStatus FROM fin_schoolpaydata WHERE ReceiptNo=@r LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", receipt);
                using (var r = cmd.ExecuteReader())
                    if (r.Read())
                    {
                        havePay = true; regno = r["regno"].ToString();
                        sb.Append(",\"payment\":{\"receipt\":").Append(JS(r["ReceiptNo"].ToString()))
                          .Append(",\"regno\":").Append(JS(regno))
                          .Append(",\"date\":").Append(JS(DateStr(r["datePaid"])))
                          .Append(",\"channel\":").Append(JS(r["channelPaid"].ToString()))
                          .Append(",\"amount\":").Append(D(r["amount_paid"]))
                          .Append(",\"name\":").Append(JS(r["stud_name"].ToString()))
                          .Append(",\"status\":").Append(JS(r["captureStatus"].ToString())).Append("}");
                    }
            }
            if (!havePay) sb.Append(",\"payment\":null");

            // --- raw pull detail (settlement bank, source txn id, payment code) if we pulled it ---
            using (var cmd = new MySqlCommand("SELECT settlement_bank,source_txn_id,student_payment_code,fee_type,supp_fee_desc FROM fin_schoolpay_pull_staging WHERE receipt_no=@r ORDER BY id DESC LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", receipt);
                using (var r = cmd.ExecuteReader())
                {
                    sb.Append(",\"pull\":");
                    if (r.Read())
                        sb.Append("{\"bank\":").Append(JS(r["settlement_bank"].ToString()))
                          .Append(",\"src_txn\":").Append(JS(r["source_txn_id"].ToString()))
                          .Append(",\"pay_code\":").Append(JS(r["student_payment_code"].ToString()))
                          .Append(",\"fee_type\":").Append(JS(r["fee_type"].ToString()))
                          .Append(",\"supp\":").Append(JS(r["supp_fee_desc"] == DBNull.Value ? "" : r["supp_fee_desc"].ToString())).Append("}");
                    else sb.Append("null");
                }
            }

            // --- what was captured (GL double-entry for this receipt) ---
            sb.Append(",\"ledger\":[");
            using (var cmd = new MySqlCommand("SELECT accountcode,transactionType,transaction_amount,particulars,transactionDate,voucherNo,teller FROM fin_ledger WHERE folio=CONCAT('TransCode:',@r) ORDER BY transactionType", conn))
            {
                cmd.Parameters.AddWithValue("@r", receipt);
                using (var r = cmd.ExecuteReader())
                {
                    bool first = true;
                    while (r.Read())
                    {
                        if (!first) sb.Append(","); first = false;
                        sb.Append("{\"account\":").Append(JS(r["accountcode"].ToString()))
                          .Append(",\"type\":").Append(JS(r["transactionType"].ToString()))
                          .Append(",\"amount\":").Append(D(r["transaction_amount"]))
                          .Append(",\"particulars\":").Append(JS(r["particulars"].ToString()))
                          .Append(",\"date\":").Append(JS(DateStr(r["transactionDate"])))
                          .Append(",\"voucher\":").Append(JS(r["voucherNo"].ToString()))
                          .Append(",\"teller\":").Append(JS(r["teller"].ToString())).Append("}");
                    }
                }
            }
            sb.Append("]");

            // --- student + account (cross-DB) + clickable links ---
            if (regno != "" && regno != "-")
            {
                using (var cmd = new MySqlCommand(@"SELECT TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) nm, IFNULL(s.progid,'') progid,
                    IFNULL(p.progname,'') progname, IFNULL(f.faculty_name,'') faculty, IFNULL(s.new_status,'') status,
                    IFNULL(s.studPhone,'') phone, IFNULL(s.email,'') email, IFNULL(s.gender,'') gender, IFNULL(s.entryyear,'') entryyear
                    FROM campus_dynamics.acad_student s
                    LEFT JOIN campus_dynamics.acad_programme p ON p.progcode=s.progid
                    LEFT JOIN campus_dynamics.acad_faculty f ON f.faculty_code=p.faculty_code
                    WHERE TRIM(s.regno)=TRIM(@r) LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var r = cmd.ExecuteReader())
                    {
                        sb.Append(",\"student\":");
                        if (r.Read())
                            sb.Append("{\"name\":").Append(JS(r["nm"].ToString()))
                              .Append(",\"progid\":").Append(JS(r["progid"].ToString()))
                              .Append(",\"programme\":").Append(JS(r["progname"].ToString()))
                              .Append(",\"faculty\":").Append(JS(r["faculty"].ToString()))
                              .Append(",\"status\":").Append(JS(r["status"].ToString()))
                              .Append(",\"phone\":").Append(JS(r["phone"].ToString()))
                              .Append(",\"email\":").Append(JS(r["email"].ToString()))
                              .Append(",\"gender\":").Append(JS(r["gender"].ToString()))
                              .Append(",\"entryyear\":").Append(JS(r["entryyear"].ToString())).Append("}");
                        else sb.Append("null");
                    }
                }
                using (var cmd = new MySqlCommand("SELECT curr_balance FROM fin_ledger WHERE accountcode=@r ORDER BY TID DESC LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    object bal = cmd.ExecuteScalar();
                    sb.Append(",\"balance\":").Append(JS(bal == null || bal == DBNull.Value ? "-" : bal.ToString()));
                }
                string profile = ResolveUrl("~/COOPERP/NewScreens/StudentProfile.aspx?regno=" + Server.UrlEncode(regno));
                string ledger  = ResolveUrl("~/COOPERP/NewScreens/StudentLedgers.aspx?q=" + Server.UrlEncode(regno));
                sb.Append(",\"links\":{\"profile\":").Append(JS(profile)).Append(",\"ledger\":").Append(JS(ledger)).Append("}");
            }
            else { sb.Append(",\"student\":null,\"balance\":\"-\",\"links\":null"); }
        }
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    // ===================================================================
    // AUTO-SYNC ENGINE (job control)
    // ===================================================================
    private void WriteJobStatus()
    {
        var sb = new StringBuilder("{\"ok\":true");
        sb.Append(",\"engine_alive\":").Append(SchoolPaySyncJob.IsEngineAlive ? "true" : "false");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            // make sure the row is visible even before the engine's first tick
            using (var cmd = new MySqlCommand("INSERT IGNORE INTO fin_schoolpay_jobstate (job_name,enabled,interval_minutes,window_days,status) VALUES ('AUTO_SYNC',1,5,2,'IDLE')", conn))
            { try { cmd.ExecuteNonQuery(); } catch { } }

            using (var cmd = new MySqlCommand(
                "SELECT enabled, interval_minutes, window_days, status, " +
                " DATE_FORMAT(last_run,'%d %b %Y %H:%i:%s') last_run, TIMESTAMPDIFF(SECOND,last_run,NOW()) run_ago, " +
                " DATE_FORMAT(last_heartbeat,'%d %b %Y %H:%i:%s') last_hb, TIMESTAMPDIFF(SECOND,last_heartbeat,NOW()) hb_ago, " +
                " DATE_FORMAT(last_finished,'%d %b %Y %H:%i:%s') last_fin, " +
                " last_message, last_error, last_fetched, last_new, last_captured, last_existed, last_failed, " +
                " total_runs, total_captured, worker_id " +
                "FROM fin_schoolpay_jobstate WHERE job_name='AUTO_SYNC' LIMIT 1", conn))
            using (var rd = cmd.ExecuteReader())
            {
                if (rd.Read())
                {
                    sb.Append(",\"enabled\":").Append(L(rd["enabled"]) == "1" ? "true" : "false");
                    sb.Append(",\"interval\":").Append(L(rd["interval_minutes"]));
                    sb.Append(",\"window_days\":").Append(L(rd["window_days"]));
                    sb.Append(",\"status\":").Append(JS(rd["status"] as string));
                    sb.Append(",\"last_run\":").Append(JS(rd["last_run"] as string));
                    sb.Append(",\"run_ago\":").Append(NInt(rd["run_ago"]));
                    sb.Append(",\"last_hb\":").Append(JS(rd["last_hb"] as string));
                    sb.Append(",\"hb_ago\":").Append(NInt(rd["hb_ago"]));
                    sb.Append(",\"last_fin\":").Append(JS(rd["last_fin"] as string));
                    sb.Append(",\"last_message\":").Append(JS(rd["last_message"] as string));
                    sb.Append(",\"last_error\":").Append(JS(rd["last_error"] as string));
                    sb.Append(",\"fetched\":").Append(L(rd["last_fetched"]));
                    sb.Append(",\"new\":").Append(L(rd["last_new"]));
                    sb.Append(",\"captured\":").Append(L(rd["last_captured"]));
                    sb.Append(",\"existed\":").Append(L(rd["last_existed"]));
                    sb.Append(",\"failed\":").Append(L(rd["last_failed"]));
                    sb.Append(",\"total_runs\":").Append(L(rd["total_runs"]));
                    sb.Append(",\"total_captured\":").Append(L(rd["total_captured"]));
                    sb.Append(",\"worker\":").Append(JS(rd["worker_id"] as string));
                }
            }
        }
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    private void WriteJobRestart()
    {
        SchoolPaySyncJob.Restart();
        Response.Write("{\"ok\":true,\"message\":\"Auto-sync engine restarted.\"}");
    }

    private void WriteJobRun()
    {
        SchoolPayPullService.PullResult r = SchoolPaySyncJob.RunOnce(CurrentUser);
        var sb = new StringBuilder("{\"ok\":").Append(r.Ok ? "true" : "false").Append(",\"message\":");
        if (r.Ok)
            sb.Append(JS("Sync complete — fetched " + r.Fetched + ", posted " + r.Captured + ", already had " + r.Existed +
                         (r.Failed > 0 ? (", " + r.Failed + " need review") : "") + "."));
        else
            sb.Append(JS("Sync failed: " + (r.Error ?? "unknown error")));
        sb.Append(",\"captured\":").Append(r.Captured).Append(",\"fetched\":").Append(r.Fetched).Append("}");
        Response.Write(sb.ToString());
    }

    private void WriteJobToggle()
    {
        bool on = (Request["on"] ?? "").Trim() == "1";
        SchoolPaySyncJob.SetEnabled(on, CurrentUser);
        Response.Write("{\"ok\":true,\"enabled\":" + (on ? "true" : "false") + ",\"message\":" + JS(on ? "Auto-sync resumed." : "Auto-sync paused.") + "}");
    }

    // ===================================================================
    // helpers
    // ===================================================================
    private static string JS(string s) { return HttpUtility.JavaScriptStringEncode(s ?? "", true); }
    private static string NInt(object o) { return (o == null || o == DBNull.Value) ? "null" : Convert.ToInt64(o).ToString(CultureInfo.InvariantCulture); }
    private static string L(object o) { return (o == null || o == DBNull.Value) ? "0" : Convert.ToInt64(o).ToString(CultureInfo.InvariantCulture); }
    private static string D(object o) { return (o == null || o == DBNull.Value) ? "0" : Convert.ToDouble(o).ToString(CultureInfo.InvariantCulture); }
    private static string DateStr(object o)
    {
        if (o == null || o == DBNull.Value) return "";
        DateTime dt; return DateTime.TryParse(o.ToString(), out dt) ? dt.ToString("dd MMM yyyy HH:mm") : o.ToString();
    }
}
