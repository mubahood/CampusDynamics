using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using MySql.Data.MySqlClient;

/// <summary>
/// DoubleBillingController — Dedicated admin tool for detecting and fixing
/// duplicate billing entries in campus_dynamics_accounts.fin_ledger.
///
/// Uses the same 4-method detection as FeesTransactions.aspx.cs:
///   M1: tracking_ref duplicates (same tracking_ref on one account)
///   M2: folio/BillNo duplicates (same 'BillNo:X' folio on one account)
///   M3: GLSync remnants (teller=GLSync entries that have a matching non-GLSync entry)
///   M4: BATCH billing duplicates (BATCH-tagged DR entries that duplicate a non-BATCH entry)
///
/// All deletes are automatically archived via trg_fin_ledger_before_delete → fin_deleted_ledger.
///
/// AJAX endpoints (?ajax=):
///   summary           — lightweight stats  (affected count, dup count, dup amount, index active)
///   scan              — full system-wide scan; returns per-account affected list
///   scan_one&regno=X  — single-account scan; returns detection detail
///   fix_one&regno=X   — fix one account: detect + batch delete + balance before/after
///   details&regno=X   — return full duplicate transaction list for account (for drilldown modal)
/// </summary>
public partial class COOPERP_NewScreens_DoubleBillingController : System.Web.UI.Page
{
    // ── Literal controls declared for server-side grid rendering ──
    protected System.Web.UI.WebControls.Literal litRows;
    protected System.Web.UI.WebControls.Literal litMeta;
    protected System.Web.UI.WebControls.Literal litPager;
    protected System.Web.UI.WebControls.Literal litTotal2;
    protected System.Web.UI.WebControls.Literal litPager2;

    // ── Connection strings ─────────────────────────────────────────────
    private string AcctConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }
    private string MainConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ══════════════════════════════════════════════════════════════════
    //  PAGE LOAD
    // ══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjax(ajax);
            return;
        }

        // On first page view: ensure schema, then bind table.
        EnsureSchema();
        BindGrid();
    }

    // ══════════════════════════════════════════════════════════════════
    //  SCHEMA INIT
    // ══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Creates fin_double_billing_cases on campus_dynamics_accounts if absent.
    /// This table acts as a persistent case log: it records every account ever
    /// detected with duplicates, the detection methods that fired, and the
    /// resolution status. Safe to call on every page load — uses IF NOT EXISTS.
    /// </summary>
    private void EnsureSchema()
    {
        try
        {
            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                const string ddl =
                    "CREATE TABLE IF NOT EXISTS fin_double_billing_cases (" +
                    "  id               INT UNSIGNED NOT NULL AUTO_INCREMENT, " +
                    "  regno            VARCHAR(30)  NOT NULL, " +
                    "  detected_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                    "  last_scanned_at  DATETIME         NULL, " +
                    "  dup_count        INT UNSIGNED NOT NULL DEFAULT 0, " +
                    "  dup_dr_amount    BIGINT       NOT NULL DEFAULT 0, " +
                    "  m1_count         INT UNSIGNED NOT NULL DEFAULT 0, " +
                    "  m2_count         INT UNSIGNED NOT NULL DEFAULT 0, " +
                    "  m3_count         INT UNSIGNED NOT NULL DEFAULT 0, " +
                    "  m4_count         INT UNSIGNED NOT NULL DEFAULT 0, " +
                    "  status           VARCHAR(20)  NOT NULL DEFAULT 'Detected', " +
                    "  fixed_at         DATETIME         NULL, " +
                    "  entries_deleted  INT UNSIGNED NOT NULL DEFAULT 0, " +
                    "  balance_before   BIGINT           NULL, " +
                    "  balance_after    BIGINT           NULL, " +
                    "  notes            TEXT             NULL, " +
                    "  PRIMARY KEY (id), " +
                    "  UNIQUE KEY uq_case_regno (regno), " +
                    "  KEY idx_status (status) " +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

                using (var cmd = new MySqlCommand(ddl, conn))
                {
                    cmd.CommandTimeout = 30;
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch
        {
            // Non-fatal — page still renders even if DDL fails (e.g. no CREATE privilege)
        }
    }

    // ══════════════════════════════════════════════════════════════════
    //  GRID BINDING (server-side GET-based pagination)
    // ══════════════════════════════════════════════════════════════════
    private void BindGrid()
    {
        string q      = (Request.QueryString["q"]      ?? "").Trim();
        string status = (Request.QueryString["status"] ?? "").Trim();
        int    ps     = 50;
        int    pg     = 1;
        int.TryParse(Request.QueryString["ps"], out ps);
        int.TryParse(Request.QueryString["pg"], out pg);
        if (ps < 1)  ps = 50;
        if (ps > 500) ps = 500;
        if (pg < 1)  pg = 1;

        var rowsHtml  = new StringBuilder();
        var metaHtml  = new StringBuilder();
        var pagerHtml = new StringBuilder();

        try
        {
            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // ── Count ──
                string countSql =
                    "SELECT COUNT(*) FROM fin_double_billing_cases WHERE 1=1" +
                    (string.IsNullOrEmpty(q)      ? "" : " AND regno LIKE @q") +
                    (string.IsNullOrEmpty(status) ? "" : " AND status = @st");
                long total = 0;
                using (var cmd = new MySqlCommand(countSql, conn))
                {
                    cmd.CommandTimeout = 20;
                    if (!string.IsNullOrEmpty(q))      cmd.Parameters.AddWithValue("@q",  "%" + q + "%");
                    if (!string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@st", status);
                    total = Convert.ToInt64(cmd.ExecuteScalar() ?? 0L);
                }

                int pageCount = (int)Math.Max(1, Math.Ceiling((double)total / ps));
                if (pg > pageCount) pg = pageCount;
                int offset = (pg - 1) * ps;
                long from  = total == 0 ? 0 : offset + 1;
                long to    = Math.Min(offset + ps, total);

                // ── Rows ──
                string rowsSql =
                    "SELECT regno, dup_count, dup_dr_amount, m1_count, m2_count, m3_count, m4_count, " +
                    "       status, last_scanned_at, fixed_at, entries_deleted " +
                    "FROM fin_double_billing_cases WHERE 1=1" +
                    (string.IsNullOrEmpty(q)      ? "" : " AND regno LIKE @q") +
                    (string.IsNullOrEmpty(status) ? "" : " AND status = @st") +
                    " ORDER BY FIELD(status,'Detected','Fixed','Clean'), last_scanned_at DESC" +
                    " LIMIT @lim OFFSET @off";

                using (var cmd = new MySqlCommand(rowsSql, conn))
                {
                    cmd.CommandTimeout = 30;
                    if (!string.IsNullOrEmpty(q))      cmd.Parameters.AddWithValue("@q",  "%" + q + "%");
                    if (!string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@st", status);
                    cmd.Parameters.AddWithValue("@lim", ps);
                    cmd.Parameters.AddWithValue("@off", offset);

                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string regno    = rdr.GetString("regno");
                            int    dups     = rdr.IsDBNull(rdr.GetOrdinal("dup_count"))    ? 0 : rdr.GetInt32("dup_count");
                            long   drAmt    = rdr.IsDBNull(rdr.GetOrdinal("dup_dr_amount")) ? 0L : rdr.GetInt64("dup_dr_amount");
                            string st       = rdr.IsDBNull(rdr.GetOrdinal("status"))       ? "" : rdr.GetString("status");
                            string scanned  = rdr.IsDBNull(rdr.GetOrdinal("last_scanned_at")) ? "—" : rdr.GetDateTime("last_scanned_at").ToString("d MMM yyyy HH:mm");
                            int    m1 = rdr.IsDBNull(rdr.GetOrdinal("m1_count")) ? 0 : rdr.GetInt32("m1_count");
                            int    m2 = rdr.IsDBNull(rdr.GetOrdinal("m2_count")) ? 0 : rdr.GetInt32("m2_count");
                            int    m3 = rdr.IsDBNull(rdr.GetOrdinal("m3_count")) ? 0 : rdr.GetInt32("m3_count");
                            int    m4 = rdr.IsDBNull(rdr.GetOrdinal("m4_count")) ? 0 : rdr.GetInt32("m4_count");

                            string pillCls  = st == "Fixed"    ? "dbc-pill--fixed"
                                            : st == "Clean"    ? "dbc-pill--clean"
                                            : st == "Detected" ? "dbc-pill--detected"
                                            :                    "dbc-pill--error";

                            var meths = new StringBuilder();
                            if (m1 > 0) meths.Append("<span class=\"dbc-meth\">M1</span>");
                            if (m2 > 0) meths.Append("<span class=\"dbc-meth\">M2</span>");
                            if (m3 > 0) meths.Append("<span class=\"dbc-meth\">M3</span>");
                            if (m4 > 0) meths.Append("<span class=\"dbc-meth\">M4</span>");
                            if (meths.Length == 0) meths.Append("<span style=\"color:#aaa;\">—</span>");

                            string fixBtn = st != "Fixed"
                                ? string.Format("<button class=\"dbc-row-btn dbc-row-btn--fix\" onclick=\"fixOne('{0}')\">&#x2714; Fix</button>",
                                    JsEsc(regno))
                                : "<span style=\"color:#2e7d32;font-size:10px;font-weight:700;\">&#x2714; Fixed</span>";

                            rowsHtml.AppendFormat(
                                "<tr>" +
                                "<td><span class=\"dbc-code\">{0}</span></td>" +
                                "<td class=\"r\" style=\"font-weight:800;color:#c62828;\">{1}</td>" +
                                "<td class=\"r\">UGX {2}</td>" +
                                "<td><div class=\"dbc-meth-pills\">{3}</div></td>" +
                                "<td class=\"c\"><span class=\"dbc-pill {4}\">{5}</span></td>" +
                                "<td style=\"font-size:10px;color:#6b7280;white-space:nowrap;\">{6}</td>" +
                                "<td class=\"c\" style=\"white-space:nowrap;\">" +
                                "<button class=\"dbc-row-btn dbc-row-btn--details\" onclick=\"showDetails('{7}','')\" style=\"margin-right:4px;\">&#128269; Details</button>" +
                                "{8}</td>" +
                                "</tr>",
                                Server.HtmlEncode(regno),
                                dups.ToString("N0"),
                                drAmt.ToString("N0"),
                                meths,
                                pillCls, Server.HtmlEncode(st),
                                Server.HtmlEncode(scanned),
                                JsEsc(regno),
                                fixBtn);
                        }
                    }
                }

                if (rowsHtml.Length == 0)
                {
                    rowsHtml.Append(
                        "<tr><td colspan=\"7\" class=\"dbc-empty\">" +
                        "<div class=\"dbc-empty__icon\">&#128269;</div>" +
                        "<div class=\"dbc-empty__text\">No cases found. Run a scan to detect double billing.</div>" +
                        "</td></tr>");
                }

                // ── Meta ──
                metaHtml.AppendFormat("Showing <strong>{0}</strong>–<strong>{1}</strong> of <strong>{2}</strong> record{3}",
                    from, to, total, total == 1 ? "" : "s");

                // ── Pager ──
                string baseUrl = "DoubleBillingController.aspx?pg={0}" +
                    (string.IsNullOrEmpty(q)      ? "" : "&q=" + Uri.EscapeDataString(q)) +
                    (string.IsNullOrEmpty(status) ? "" : "&status=" + Uri.EscapeDataString(status)) +
                    "&ps=" + ps;

                if (pg > 1)   pagerHtml.AppendFormat("<a href=\"{0}\">&laquo;</a>", string.Format(baseUrl, 1));
                if (pg > 1)   pagerHtml.AppendFormat("<a href=\"{0}\">&#8249;</a>", string.Format(baseUrl, pg - 1));

                int lo = Math.Max(1,         pg - 3);
                int hi = Math.Min(pageCount, pg + 3);
                for (int i = lo; i <= hi; i++)
                {
                    if (i == pg)
                        pagerHtml.AppendFormat("<span class=\"active\">{0}</span>", i);
                    else
                        pagerHtml.AppendFormat("<a href=\"{0}\">{1}</a>", string.Format(baseUrl, i), i);
                }

                if (pg < pageCount) pagerHtml.AppendFormat("<a href=\"{0}\">&#8250;</a>",  string.Format(baseUrl, pg + 1));
                if (pg < pageCount) pagerHtml.AppendFormat("<a href=\"{0}\">&raquo;</a>",  string.Format(baseUrl, pageCount));
            }
        }
        catch (Exception ex)
        {
            rowsHtml.Append("<tr><td colspan=\"7\" style=\"color:#c62828;padding:12px;\">Error loading cases: " + Server.HtmlEncode(ex.Message) + "</td></tr>");
        }

        litRows.Text   = rowsHtml.ToString();
        litMeta.Text   = metaHtml.ToString();
        litTotal2.Text = metaHtml.ToString();
        litPager.Text  = pagerHtml.ToString();
        litPager2.Text = pagerHtml.ToString();
    }

    // ══════════════════════════════════════════════════════════════════
    //  AJAX DISPATCHER
    // ══════════════════════════════════════════════════════════════════
    private void HandleAjax(string ajax)
    {
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));

        try
        {
            if (ajax == "summary")
                AjaxSummary();
            else if (ajax == "scan")
                AjaxScan();
            else if (ajax == "scan_init")
                AjaxScanInit();
            else if (ajax == "scan_batch")
                AjaxScanBatch();
            else if (ajax == "load_cases")
                AjaxLoadCases();
            else if (ajax == "scan_one")
                AjaxScanOne();
            else if (ajax == "fix_one")
                AjaxFixOne();
            else if (ajax == "details")
                AjaxDetails();
            else
                Response.Write("{\"ok\":false,\"error\":\"Unknown action.\"}");
        }
        catch (System.Threading.ThreadAbortException) { /* Response.End */ }
        catch (Exception ex)
        {
            string msg = ex.Message;
            if (ex.InnerException != null && !string.IsNullOrEmpty(ex.InnerException.Message))
                msg = msg + " | " + ex.InnerException.Message;
            try { Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(msg) + "\"}"); }
            catch { }
        }

        try { Response.End(); }
        catch (System.Threading.ThreadAbortException) { }
    }

    // ══════════════════════════════════════════════════════════════════
    //  AJAX HANDLERS
    // ══════════════════════════════════════════════════════════════════

    // ─── Summary: quick stats for header cards ──────────────────────
    private void AjaxSummary()
    {
        long affectedCount = 0, grandDups = 0, grandAmt = 0;
        long totalStudents = 0, totalLedger = 0;
        bool hasIndex = false;
        int fixedCount = 0;

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            using (var cmd = new MySqlCommand(
                "SELECT COUNT(DISTINCT accountcode) FROM fin_ledger WHERE account_type='Student'", conn))
            {
                cmd.CommandTimeout = 60;
                totalStudents = Convert.ToInt64(cmd.ExecuteScalar());
            }
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM fin_ledger WHERE account_type='Student'", conn))
            {
                cmd.CommandTimeout = 60;
                totalLedger = Convert.ToInt64(cmd.ExecuteScalar());
            }

            // Check UNIQUE index
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM information_schema.STATISTICS " +
                "WHERE TABLE_SCHEMA='campus_dynamics_accounts' AND TABLE_NAME='fin_ledger' " +
                "AND INDEX_NAME='uq_billing_entry'", conn))
            {
                cmd.CommandTimeout = 10;
                hasIndex = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }

            // Read persisted case stats
            bool tableExists = false;
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM information_schema.TABLES " +
                "WHERE TABLE_SCHEMA='campus_dynamics_accounts' AND TABLE_NAME='fin_double_billing_cases'", conn))
            {
                cmd.CommandTimeout = 10;
                tableExists = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }

            if (tableExists)
            {
                using (var cmd = new MySqlCommand(
                    "SELECT " +
                    "  SUM(CASE WHEN status = 'Detected' THEN 1 ELSE 0 END) AS aff, " +
                    "  SUM(dup_count) AS dups, " +
                    "  SUM(dup_dr_amount) AS amt, " +
                    "  SUM(CASE WHEN status = 'Fixed' THEN 1 ELSE 0 END) AS fixes " +
                    "FROM fin_double_billing_cases", conn))
                {
                    cmd.CommandTimeout = 10;
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            affectedCount = rdr["aff"] != DBNull.Value ? Convert.ToInt64(rdr["aff"]) : 0;
                            grandDups = rdr["dups"] != DBNull.Value ? Convert.ToInt64(rdr["dups"]) : 0;
                            grandAmt = rdr["amt"] != DBNull.Value ? Convert.ToInt64(rdr["amt"]) : 0;
                            fixedCount = rdr["fixes"] != DBNull.Value ? Convert.ToInt32(rdr["fixes"]) : 0;
                        }
                    }
                }
            }
        }

        Response.Write(string.Format(
            "{{\"ok\":true," +
            "\"totalStudents\":{0},\"totalLedger\":{1}," +
            "\"affectedCount\":{2},\"fixedCount\":{3}," +
            "\"grandTotalDups\":{4},\"grandTotalAmount\":{5}," +
            "\"uniqueIndexActive\":{6}}}",
            totalStudents, totalLedger,
            affectedCount, fixedCount,
            grandDups, grandAmt,
            hasIndex ? "true" : "false"));
    }

    // ─── Scan: full system-wide duplicate detection ──────────────────
    private void AjaxScan()
    {
        var affectedMap = new Dictionary<string, long[]>(); // regno => [dupCount, dupDrAmt, m1, m2, m3, m4]

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // ── Method 1: tracking_ref duplicates ──
            const string m1Sql =
                "SELECT l.accountcode AS regno, COUNT(*) AS cnt, SUM(l.transaction_amount) AS amt " +
                "FROM fin_ledger l " +
                "INNER JOIN ( " +
                "  SELECT tracking_ref, transactionType, accountcode, MIN(TID) AS keep_tid " +
                "  FROM fin_ledger " +
                "  WHERE account_type='Student' AND tracking_ref IS NOT NULL " +
                "  GROUP BY tracking_ref, transactionType, accountcode " +
                "  HAVING COUNT(*) > 1 " +
                ") dup ON l.tracking_ref=dup.tracking_ref AND l.transactionType=dup.transactionType " +
                "       AND l.accountcode=dup.accountcode AND l.TID > dup.keep_tid " +
                "WHERE l.account_type='Student' GROUP BY l.accountcode";

            GatherSystemWideMethod(conn, m1Sql, affectedMap, 0);

            // ── Method 2: folio/BillNo duplicates ──
            const string m2Sql =
                "SELECT l.accountcode AS regno, COUNT(*) AS cnt, SUM(l.transaction_amount) AS amt " +
                "FROM fin_ledger l " +
                "INNER JOIN ( " +
                "  SELECT folio, transactionType, accountcode, MIN(TID) AS keep_tid " +
                "  FROM fin_ledger " +
                "  WHERE account_type='Student' AND folio LIKE 'BillNo:%' " +
                "  GROUP BY folio, transactionType, accountcode " +
                "  HAVING COUNT(*) > 1 " +
                ") dup ON l.folio=dup.folio AND l.transactionType=dup.transactionType " +
                "       AND l.accountcode=dup.accountcode AND l.TID > dup.keep_tid " +
                "WHERE l.account_type='Student' GROUP BY l.accountcode";

            GatherSystemWideMethod(conn, m2Sql, affectedMap, 1);

            // ── Method 3: GLSync remnants ──
            const string m3Sql =
                "SELECT g.accountcode AS regno, COUNT(*) AS cnt, SUM(g.transaction_amount) AS amt " +
                "FROM fin_ledger g " +
                "WHERE g.account_type='Student' AND g.teller='GLSync' " +
                "  AND EXISTS ( " +
                "    SELECT 1 FROM fin_ledger o " +
                "    WHERE o.accountcode=g.accountcode AND o.account_type='Student' " +
                "      AND o.transactionType=g.transactionType " +
                "      AND o.teller<>'GLSync' AND o.TID<>g.TID " +
                "      AND (o.folio=CONCAT('BillNo:',g.voucherNo) " +
                "        OR (o.tracking_ref IS NOT NULL AND g.tracking_ref IS NOT NULL " +
                "            AND o.tracking_ref=g.tracking_ref) " +
                "        OR (o.transaction_amount=g.transaction_amount " +
                "            AND o.transactionDate=g.transactionDate " +
                "            AND o.folio LIKE 'BillNo:%')) " +
                "  ) " +
                "GROUP BY g.accountcode";

            GatherSystemWideMethod(conn, m3Sql, affectedMap, 2);

            // ── Method 4: BATCH billing duplicates ──
            const string m4Sql =
                "SELECT b.accountcode AS regno, COUNT(*) AS cnt, SUM(b.transaction_amount) AS amt " +
                "FROM fin_ledger b " +
                "WHERE b.account_type='Student' AND b.transactionType='DR' " +
                "  AND b.particulars LIKE '%BATCH%' " +
                "  AND EXISTS ( " +
                "    SELECT 1 FROM fin_ledger o " +
                "    WHERE o.accountcode=b.accountcode AND o.account_type='Student' " +
                "      AND o.transactionType='DR' AND o.TID<>b.TID " +
                "      AND o.particulars NOT LIKE '%BATCH%' " +
                "      AND LEFT(REPLACE(b.particulars,' BATCH',''),30)=LEFT(o.particulars,30) " +
                "  ) " +
                "GROUP BY b.accountcode";

            GatherSystemWideMethod(conn, m4Sql, affectedMap, 3);

            // UNIQUE index check
            bool hasIdx = false;
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM information_schema.STATISTICS " +
                "WHERE TABLE_SCHEMA='campus_dynamics_accounts' AND TABLE_NAME='fin_ledger' " +
                "AND INDEX_NAME='uq_billing_entry'", conn))
            {
                cmd.CommandTimeout = 10;
                hasIdx = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }

            // Fetch student names
            var nameMap = new Dictionary<string, string>();
            if (affectedMap.Count > 0)
            {
                var quoted = new List<string>();
                foreach (var k in affectedMap.Keys)
                    quoted.Add("'" + k.Replace("'", "''") + "'");

                string nameSql =
                    "SELECT regno, TRIM(CONCAT(COALESCE(firstname,''),' ',COALESCE(othername,''))) AS fullname " +
                    "FROM campus_dynamics.acad_student WHERE regno IN (" + string.Join(",", quoted.ToArray()) + ")";

                using (var conn2 = new MySqlConnection(MainConnStr))
                {
                    conn2.Open();
                    using (var cmd = new MySqlCommand(nameSql, conn2))
                    {
                        cmd.CommandTimeout = 30;
                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                                nameMap[rdr["regno"].ToString()] = rdr["fullname"].ToString();
                        }
                    }
                }
            }

            // Persist case records so they survive past this scan request
            PersistCases(conn, affectedMap, nameMap);

            // Build response JSON
            long grandTotalDups = 0, grandTotalAmt = 0;
            var accJson = new List<string>();
            foreach (var kv in affectedMap)
            {
                string name = nameMap.ContainsKey(kv.Key) ? nameMap[kv.Key] : "";
                grandTotalDups += kv.Value[0];
                grandTotalAmt += kv.Value[1];
                accJson.Add(string.Format(
                    "{{\"regno\":\"{0}\",\"name\":\"{1}\"," +
                    "\"dupCount\":{2},\"dupAmount\":{3}," +
                    "\"m1\":{4},\"m2\":{5},\"m3\":{6},\"m4\":{7}}}",
                    JsEsc(kv.Key), JsEsc(name),
                    kv.Value[0], kv.Value[1],
                    kv.Value[2], kv.Value[3], kv.Value[4], kv.Value[5]));
            }

            Response.Write(string.Format(
                "{{\"ok\":true," +
                "\"affectedCount\":{0}," +
                "\"grandTotalDups\":{1},\"grandTotalAmount\":{2}," +
                "\"uniqueIndexActive\":{3}," +
                "\"accounts\":[{4}]}}",
                affectedMap.Count,
                grandTotalDups, grandTotalAmt,
                hasIdx ? "true" : "false",
                string.Join(",", accJson.ToArray())));
        }
    }

    // ─── ScanInit: returns total count of student accounts to scan ───
    private void AjaxScanInit()
    {
        long total = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(DISTINCT accountcode) FROM fin_ledger WHERE account_type='Student'", conn))
            {
                cmd.CommandTimeout = 60;
                total = Convert.ToInt64(cmd.ExecuteScalar());
            }
        }
        Response.Write("{\"ok\":true,\"total\":" + total + "}");
    }

    // ─── ScanBatch: detect duplicates for a batch of student accounts ─
    // ?ajax=scan_batch&offset=N&size=M
    // Returns: { ok, scanned, done, affected:[{regno,name,dupCount,...}] }
    private void AjaxScanBatch()
    {
        int offset = 0, size = 50;
        int.TryParse(Request.QueryString["offset"] ?? "0", out offset);
        int.TryParse(Request.QueryString["size"]   ?? "50", out size);
        if (size < 1 || size > 200) size = 50;

        // Fetch the batch of student account codes
        var regnos = new List<string>();
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string listSql =
                "SELECT DISTINCT accountcode FROM fin_ledger " +
                "WHERE account_type='Student' " +
                "ORDER BY accountcode " +
                "LIMIT " + size + " OFFSET " + offset;
            using (var cmd = new MySqlCommand(listSql, conn))
            {
                cmd.CommandTimeout = 60;
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        regnos.Add(rdr["accountcode"].ToString());
            }
        }

        int scanned = regnos.Count;
        var affected = new List<string>();
        long grandDups = 0, grandAmt = 0;

        // Fetch student names for all regnos in this batch (single query)
        var nameMap = new Dictionary<string, string>();
        if (regnos.Count > 0)
        {
            var quoted = new List<string>();
            foreach (var r in regnos) quoted.Add("'" + r.Replace("'", "''") + "'");
            try
            {
                using (var conn2 = new MySqlConnection(MainConnStr))
                {
                    conn2.Open();
                    string nSql =
                        "SELECT regno, TRIM(CONCAT(COALESCE(firstname,''),' ',COALESCE(othername,''))) AS nm " +
                        "FROM campus_dynamics.acad_student WHERE regno IN (" +
                        string.Join(",", quoted.ToArray()) + ")";
                    using (var cmd = new MySqlCommand(nSql, conn2))
                    {
                        cmd.CommandTimeout = 30;
                        using (var rdr = cmd.ExecuteReader())
                            while (rdr.Read())
                                nameMap[rdr["regno"].ToString()] = rdr["nm"].ToString();
                    }
                }
            }
            catch { /* name lookup non-fatal */ }
        }

        // For each regno in the batch, detect duplicates
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            foreach (var regno in regnos)
            {
                var dupTids = new HashSet<long>();
                long dupDrAmt = 0;
                int m1, m2, m3, m4;
                DB_DetectDuplicates(conn, regno, dupTids, ref dupDrAmt, out m1, out m2, out m3, out m4);

                if (dupTids.Count > 0)
                {
                    grandDups += dupTids.Count;
                    grandAmt  += dupDrAmt;
                    string name = nameMap.ContainsKey(regno) ? nameMap[regno] : "";
                    affected.Add(string.Format(
                        "{{\"regno\":\"{0}\",\"name\":\"{1}\"," +
                        "\"dupCount\":{2},\"dupAmount\":{3}," +
                        "\"m1\":{4},\"m2\":{5},\"m3\":{6},\"m4\":{7}}}",
                        JsEsc(regno), JsEsc(name),
                        dupTids.Count, dupDrAmt, m1, m2, m3, m4));

                    // Persist case record
                    try { UpsertCase(conn, regno, dupTids.Count, dupDrAmt, m1, m2, m3, m4, "Detected", 0, 0, 0, null); }
                    catch { }
                }
            }
        }

        bool done = scanned < size; // fewer returned than requested = last batch
        Response.Write(string.Format(
            "{{\"ok\":true,\"scanned\":{0},\"done\":{1}," +
            "\"affectedCount\":{2},\"grandTotalDups\":{3},\"grandTotalAmount\":{4}," +
            "\"affected\":[{5}]}}",
            scanned,
            done ? "true" : "false",
            affected.Count,
            grandDups, grandAmt,
            string.Join(",", affected.ToArray())));
    }

    // ─── LoadCases: return persisted case log from DB ────────────────
    private void AjaxLoadCases()
    {
        bool tableOk = false;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var chk = new MySqlCommand(
                "SELECT COUNT(*) FROM information_schema.TABLES " +
                "WHERE TABLE_SCHEMA='campus_dynamics_accounts' AND TABLE_NAME='fin_double_billing_cases'", conn))
            {
                chk.CommandTimeout = 10;
                tableOk = Convert.ToInt32(chk.ExecuteScalar()) > 0;
            }
            if (!tableOk)
            {
                Response.Write("{\"ok\":true,\"cases\":[]}");
                return;
            }
        }

        var caseRows = new List<string>();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            const string sql =
                "SELECT regno, dup_count, dup_dr_amount, " +
                "  m1_count, m2_count, m3_count, m4_count, " +
                "  status, last_scanned_at " +
                "FROM fin_double_billing_cases " +
                "ORDER BY FIELD(status,'Detected','Error','Fixed','Clean'), dup_dr_amount DESC " +
                "LIMIT 2000";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 30;
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string scannedAt = rdr["last_scanned_at"] != DBNull.Value
                            ? Convert.ToDateTime(rdr["last_scanned_at"]).ToString("yyyy-MM-dd HH:mm") : "";
                        caseRows.Add(string.Format(
                            "{{\"regno\":\"{0}\",\"name\":\"\"," +
                            "\"dupCount\":{1},\"dupAmount\":{2}," +
                            "\"m1\":{3},\"m2\":{4},\"m3\":{5},\"m4\":{6}," +
                            "\"status\":\"{7}\",\"lastScanned\":\"{8}\"}}",
                            JsEsc(rdr["regno"].ToString()),
                            rdr["dup_count"],
                            rdr["dup_dr_amount"],
                            rdr["m1_count"], rdr["m2_count"],
                            rdr["m3_count"], rdr["m4_count"],
                            JsEsc(rdr["status"].ToString()),
                            JsEsc(scannedAt)));
                    }
                }
            }
        }

        // Enrich with names from acad_student
        try
        {
            if (caseRows.Count > 0)
            {
                // names can be loaded on client from scan, not critical here
            }
        }
        catch { }

        Response.Write("{\"ok\":true,\"cases\":[" + string.Join(",", caseRows.ToArray()) + "]}");
    }

    // ─── ScanOne: scan a single account and return per-method detail ─
    private void AjaxScanOne()
    {
        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"ok\":false,\"error\":\"Missing regno.\"}");
            return;
        }

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            var dupTids = new HashSet<long>();
            long dupDrAmt = 0;
            int m1, m2, m3, m4;
            DB_DetectDuplicates(conn, regno, dupTids, ref dupDrAmt, out m1, out m2, out m3, out m4);

            decimal bal = DB_ComputeBalance(conn, regno);

            // Upsert case record
            if (dupTids.Count > 0)
            {
                UpsertCase(conn, regno, dupTids.Count, dupDrAmt, m1, m2, m3, m4, "Detected",
                    0, 0, 0, null);
            }
            else
            {
                // If previously detected but now clean, mark it clean
                MarkCaseClean(conn, regno);
            }

            Response.Write(string.Format(
                "{{\"ok\":true,\"regno\":\"{0}\"," +
                "\"dupCount\":{1},\"dupDrAmount\":{2}," +
                "\"m1\":{3},\"m2\":{4},\"m3\":{5},\"m4\":{6}," +
                "\"balance\":\"{7}\"}}",
                JsEsc(regno),
                dupTids.Count, dupDrAmt,
                m1, m2, m3, m4,
                JsEsc(DB_FormatBalance(bal))));
        }
    }

    // ─── FixOne: fix duplicates for a single account ─────────────────
    private void AjaxFixOne()
    {
        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"ok\":false,\"error\":\"Missing regno.\"}");
            return;
        }

        int deleted = 0;
        decimal balBefore = 0, balAfter = 0;

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            balBefore = DB_ComputeBalance(conn, regno);

            var dupTids = new HashSet<long>();
            long dupDrAmt = 0;
            int m1, m2, m3, m4;
            DB_DetectDuplicates(conn, regno, dupTids, ref dupDrAmt, out m1, out m2, out m3, out m4);

            if (dupTids.Count > 0)
            {
                var tidList = new List<long>(dupTids);
                // Delete in batches of 500 to avoid lock pressure on MyISAM tables.
                // trg_fin_ledger_before_delete automatically archives each deleted row.
                for (int i = 0; i < tidList.Count; i += 500)
                {
                    int end = Math.Min(i + 500, tidList.Count);
                    var batch = tidList.GetRange(i, end - i);
                    var ids = new List<string>();
                    foreach (long t in batch) ids.Add(t.ToString());
                    string delSql = "DELETE FROM fin_ledger WHERE TID IN (" +
                        string.Join(",", ids.ToArray()) + ")";
                    using (var cmd = new MySqlCommand(delSql, conn))
                    {
                        cmd.CommandTimeout = 120;
                        deleted += cmd.ExecuteNonQuery();
                    }
                }
            }

            balAfter = DB_ComputeBalance(conn, regno);

            // Update case record
            UpsertCase(conn, regno, dupTids.Count, dupDrAmt, m1, m2, m3, m4, "Fixed",
                deleted,
                (long)Math.Round(balBefore),
                (long)Math.Round(balAfter),
                null);
        }

        Response.Write(string.Format(
            "{{\"ok\":true,\"regno\":\"{0}\"," +
            "\"deleted\":{1}," +
            "\"m1\":{2},\"m2\":{3},\"m3\":{4},\"m4\":{5}," +
            "\"balBefore\":\"{6}\",\"balAfter\":\"{7}\"," +
            "\"archived\":true}}",
            JsEsc(regno),
            deleted,
            0, 0, 0, 0,          // m1-m4 are pre-fix; included as 0 since already deleted
            JsEsc(DB_FormatBalance(balBefore)),
            JsEsc(DB_FormatBalance(balAfter))));
    }

    // ─── Details: return the actual duplicate TIDs + transaction rows ─
    private void AjaxDetails()
    {
        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"ok\":false,\"error\":\"Missing regno.\"}");
            return;
        }

        var rows = new List<string>();
        var dupTids = new HashSet<long>();
        long dupDrAmt = 0;

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            int m1, m2, m3, m4;
            DB_DetectDuplicates(conn, regno, dupTids, ref dupDrAmt, out m1, out m2, out m3, out m4);

            if (dupTids.Count > 0)
            {
                var ids = new List<string>();
                foreach (long t in dupTids) ids.Add(t.ToString());

                string detailSql =
                    "SELECT TID, transactionType, transaction_amount, particulars, " +
                    "  folio, tracking_ref, teller, transactionDate, source_system " +
                    "FROM fin_ledger " +
                    "WHERE TID IN (" + string.Join(",", ids.ToArray()) + ") " +
                    "ORDER BY transactionDate DESC, TID DESC";

                using (var cmd = new MySqlCommand(detailSql, conn))
                {
                    cmd.CommandTimeout = 30;
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string tid = rdr["TID"].ToString();
                            string txtype = rdr["transactionType"].ToString();
                            string amount = rdr["transaction_amount"].ToString();
                            string particulars = rdr["particulars"].ToString();
                            string folio = rdr["folio"] != DBNull.Value ? rdr["folio"].ToString() : "";
                            string tref = rdr["tracking_ref"] != DBNull.Value ? rdr["tracking_ref"].ToString() : "";
                            string teller = rdr["teller"].ToString();
                            string txdate = rdr["transactionDate"] != DBNull.Value
                                ? Convert.ToDateTime(rdr["transactionDate"]).ToString("yyyy-MM-dd") : "";
                            string src = rdr["source_system"] != DBNull.Value ? rdr["source_system"].ToString() : "";

                            rows.Add(string.Format(
                                "{{\"tid\":{0},\"type\":\"{1}\",\"amount\":{2}," +
                                "\"particulars\":\"{3}\",\"folio\":\"{4}\"," +
                                "\"trackingRef\":\"{5}\",\"teller\":\"{6}\"," +
                                "\"date\":\"{7}\",\"source\":\"{8}\"}}",
                                tid, JsEsc(txtype), amount,
                                JsEsc(particulars), JsEsc(folio),
                                JsEsc(tref), JsEsc(teller), txdate, JsEsc(src)));
                        }
                    }
                }
            }

            decimal bal = DB_ComputeBalance(conn, regno);

            Response.Write(string.Format(
                "{{\"ok\":true,\"regno\":\"{0}\"," +
                "\"dupCount\":{1},\"dupDrAmount\":{2}," +
                "\"balance\":\"{3}\"," +
                "\"transactions\":[{4}]}}",
                JsEsc(regno),
                dupTids.Count, dupDrAmt,
                JsEsc(DB_FormatBalance(bal)),
                string.Join(",", rows.ToArray())));
        }
    }

    // ══════════════════════════════════════════════════════════════════
    //  DETECTION ENGINE  (same logic as FeesTransactions.aspx.cs BD_*)
    // ══════════════════════════════════════════════════════════════════

    private void DB_DetectDuplicates(MySqlConnection conn, string regno,
        HashSet<long> dupTids, ref long dupDrAmount,
        out int m1, out int m2, out int m3, out int m4)
    {
        // Method 1: tracking_ref duplicates
        const string sql1 =
            "SELECT l.TID, l.transaction_amount AS amt, l.transactionType " +
            "FROM fin_ledger l " +
            "INNER JOIN ( " +
            "  SELECT tracking_ref, transactionType, MIN(TID) AS keep_tid " +
            "  FROM fin_ledger " +
            "  WHERE accountcode=@reg AND account_type='Student' AND tracking_ref IS NOT NULL " +
            "  GROUP BY tracking_ref, transactionType " +
            "  HAVING COUNT(*) > 1 " +
            ") dup ON l.tracking_ref=dup.tracking_ref AND l.transactionType=dup.transactionType " +
            "     AND l.TID > dup.keep_tid " +
            "WHERE l.accountcode=@reg AND l.account_type='Student'";

        m1 = DB_RunDetection(conn, sql1, regno, dupTids, ref dupDrAmount);

        // Method 2: folio/BillNo duplicates (excluding already-found M1 TIDs)
        string excl = DB_TidExcl(dupTids);
        string sql2 =
            "SELECT l.TID, l.transaction_amount AS amt, l.transactionType " +
            "FROM fin_ledger l " +
            "INNER JOIN ( " +
            "  SELECT folio, transactionType, MIN(TID) AS keep_tid " +
            "  FROM fin_ledger " +
            "  WHERE accountcode=@reg AND account_type='Student' AND folio LIKE 'BillNo:%' " +
            "  GROUP BY folio, transactionType " +
            "  HAVING COUNT(*) > 1 " +
            ") dup ON l.folio=dup.folio AND l.transactionType=dup.transactionType " +
            "     AND l.TID > dup.keep_tid " +
            "WHERE l.accountcode=@reg AND l.account_type='Student' " +
            "  AND l.TID NOT IN (" + excl + ")";

        m2 = DB_RunDetection(conn, sql2, regno, dupTids, ref dupDrAmount);

        // Method 3: GLSync remnants
        excl = DB_TidExcl(dupTids);
        string sql3 =
            "SELECT g.TID, g.transaction_amount AS amt, g.transactionType " +
            "FROM fin_ledger g " +
            "WHERE g.accountcode=@reg AND g.account_type='Student' " +
            "  AND g.teller='GLSync' " +
            "  AND g.TID NOT IN (" + excl + ") " +
            "  AND EXISTS ( " +
            "    SELECT 1 FROM fin_ledger o " +
            "    WHERE o.accountcode=g.accountcode AND o.account_type='Student' " +
            "      AND o.transactionType=g.transactionType " +
            "      AND o.teller<>'GLSync' AND o.TID<>g.TID " +
            "      AND (o.folio=CONCAT('BillNo:',g.voucherNo) " +
            "        OR (o.tracking_ref IS NOT NULL AND g.tracking_ref IS NOT NULL " +
            "            AND o.tracking_ref=g.tracking_ref) " +
            "        OR (o.transaction_amount=g.transaction_amount " +
            "            AND o.transactionDate=g.transactionDate " +
            "            AND o.folio LIKE 'BillNo:%')) " +
            "  )";

        m3 = DB_RunDetection(conn, sql3, regno, dupTids, ref dupDrAmount);

        // Method 4: BATCH billing duplicates
        excl = DB_TidExcl(dupTids);
        string sql4 =
            "SELECT b.TID, b.transaction_amount AS amt, b.transactionType " +
            "FROM fin_ledger b " +
            "WHERE b.accountcode=@reg AND b.account_type='Student' " +
            "  AND b.transactionType='DR' " +
            "  AND b.particulars LIKE '%BATCH%' " +
            "  AND b.TID NOT IN (" + excl + ") " +
            "  AND EXISTS ( " +
            "    SELECT 1 FROM fin_ledger o " +
            "    WHERE o.accountcode=b.accountcode AND o.account_type='Student' " +
            "      AND o.transactionType='DR' AND o.TID<>b.TID " +
            "      AND o.particulars NOT LIKE '%BATCH%' " +
            "      AND LEFT(REPLACE(b.particulars,' BATCH',''),30)=LEFT(o.particulars,30) " +
            "  )";

        m4 = DB_RunDetection(conn, sql4, regno, dupTids, ref dupDrAmount);
    }

    private int DB_RunDetection(MySqlConnection conn, string sql, string regno,
        HashSet<long> dupTids, ref long dupDrAmount)
    {
        int count = 0;
        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 60;
            cmd.Parameters.AddWithValue("@reg", regno);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    long tid = Convert.ToInt64(rdr["TID"]);
                    if (!dupTids.Add(tid)) continue;
                    count++;
                    if (rdr["transactionType"].ToString() == "DR")
                        dupDrAmount += Convert.ToInt64(rdr["amt"]);
                }
            }
        }
        return count;
    }

    // Balance using the same UNION ALL 3-condition NOT EXISTS as the portal display
    private decimal DB_ComputeBalance(MySqlConnection conn, string regno)
    {
        const string sql =
            "SELECT " +
            "  IFNULL(SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END),0) - " +
            "  IFNULL(SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END),0) AS bal " +
            "FROM ( " +
            "  SELECT transactionType, transaction_amount FROM fin_ledger " +
            "  WHERE accountcode=@reg AND account_type='Student' AND transaction_amount > 0 " +
            "  UNION ALL " +
            "  SELECT 'DR' AS transactionType, t.amount AS transaction_amount " +
            "  FROM fin_studentfeestracking t " +
            "  WHERE t.regno=@reg AND t.trans_type='Bill' AND t.post_status='Posted' " +
            "    AND NOT EXISTS ( " +
            "      SELECT 1 FROM fin_ledger l WHERE l.accountcode=t.regno " +
            "        AND l.account_type='Student' AND l.transactionType='DR' " +
            "        AND l.voucherNo=CAST(t.TID AS CHAR)) " +
            "    AND NOT EXISTS ( " +
            "      SELECT 1 FROM fin_ledger l WHERE l.accountcode=t.regno " +
            "        AND l.account_type='Student' AND l.transactionType='DR' " +
            "        AND l.folio=CONCAT('BillNo:',t.TID)) " +
            "    AND NOT EXISTS ( " +
            "      SELECT 1 FROM fin_ledger l WHERE l.accountcode=t.regno " +
            "        AND l.account_type='Student' AND l.transactionType='DR' " +
            "        AND l.transaction_amount=t.amount " +
            "        AND DATE(l.transactionDate)=DATE(t.trans_date) " +
            "        AND (l.particulars=t.detail OR t.detail IS NULL OR t.detail='')) " +
            ") combined";

        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 30;
            cmd.Parameters.AddWithValue("@reg", regno);
            object val = cmd.ExecuteScalar();
            return (val != null && val != DBNull.Value) ? Convert.ToDecimal(val) : 0;
        }
    }

    // ══════════════════════════════════════════════════════════════════
    //  CASE-LOG HELPERS
    // ══════════════════════════════════════════════════════════════════

    private void GatherSystemWideMethod(MySqlConnection conn, string sql,
        Dictionary<string, long[]> map, int methodIndex)
    {
        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 120;
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    string reg = rdr["regno"].ToString();
                    long cnt = Convert.ToInt64(rdr["cnt"]);
                    long amt = rdr["amt"] != DBNull.Value ? Convert.ToInt64(rdr["amt"]) : 0;
                    if (!map.ContainsKey(reg))
                        map[reg] = new long[] { 0L, 0L, 0L, 0L, 0L, 0L }; // [dupTotal, amtTotal, m1, m2, m3, m4]
                    map[reg][0] += cnt;
                    map[reg][1] += amt;
                    map[reg][2 + methodIndex] += cnt;
                }
            }
        }
    }

    private void PersistCases(MySqlConnection conn,
        Dictionary<string, long[]> affectedMap,
        Dictionary<string, string> nameMap)
    {
        // Only try if the table exists
        try
        {
            int tableCheck;
            using (var chk = new MySqlCommand(
                "SELECT COUNT(*) FROM information_schema.TABLES " +
                "WHERE TABLE_SCHEMA='campus_dynamics_accounts' " +
                "AND TABLE_NAME='fin_double_billing_cases'", conn))
            {
                chk.CommandTimeout = 10;
                tableCheck = Convert.ToInt32(chk.ExecuteScalar());
            }
            if (tableCheck == 0) return;

            foreach (var kv in affectedMap)
            {
                UpsertCase(conn, kv.Key,
                    (int)kv.Value[0], kv.Value[1],
                    (int)kv.Value[2], (int)kv.Value[3], (int)kv.Value[4], (int)kv.Value[5],
                    "Detected", 0, 0, 0, null);
            }
        }
        catch
        {
            // Non-fatal — scan result still returned even if persist fails
        }
    }

    private void UpsertCase(MySqlConnection conn, string regno,
        int dupCount, long dupDrAmt,
        int m1, int m2, int m3, int m4,
        string status,
        int entriesDeleted, long balBefore, long balAfter,
        string notes)
    {
        try
        {
            string fixedAt = status == "Fixed" ? "NOW()" : "NULL";
            string notesSql = notes != null ? ("'" + notes.Replace("'", "''") + "'") : "NULL";

            string upsert = string.Format(
                "INSERT INTO fin_double_billing_cases " +
                "(regno, detected_at, last_scanned_at, dup_count, dup_dr_amount, " +
                " m1_count, m2_count, m3_count, m4_count, status, " +
                " fixed_at, entries_deleted, balance_before, balance_after, notes) " +
                "VALUES ('{0}', NOW(), NOW(), {1}, {2}, {3}, {4}, {5}, {6}, '{7}', " +
                "  {8}, {9}, {10}, {11}, {12}) " +
                "ON DUPLICATE KEY UPDATE " +
                "  last_scanned_at = NOW(), " +
                "  dup_count = VALUES(dup_count), " +
                "  dup_dr_amount = VALUES(dup_dr_amount), " +
                "  m1_count = VALUES(m1_count), m2_count = VALUES(m2_count), " +
                "  m3_count = VALUES(m3_count), m4_count = VALUES(m4_count), " +
                "  status = VALUES(status), " +
                "  fixed_at = VALUES(fixed_at), " +
                "  entries_deleted = VALUES(entries_deleted), " +
                "  balance_before = VALUES(balance_before), " +
                "  balance_after = VALUES(balance_after)",
                regno.Replace("'", "''"),
                dupCount, dupDrAmt,
                m1, m2, m3, m4,
                status.Replace("'", "''"),
                fixedAt,
                entriesDeleted,
                balBefore == 0 ? "NULL" : balBefore.ToString(),
                balAfter == 0 ? "NULL" : balAfter.ToString(),
                notesSql);

            using (var cmd = new MySqlCommand(upsert, conn))
            {
                cmd.CommandTimeout = 10;
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
            // Non-fatal
        }
    }

    private void MarkCaseClean(MySqlConnection conn, string regno)
    {
        try
        {
            string sql =
                "UPDATE fin_double_billing_cases " +
                "SET status='Clean', last_scanned_at=NOW(), dup_count=0 " +
                "WHERE regno=@reg";
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                cmd.Parameters.AddWithValue("@reg", regno);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    // ══════════════════════════════════════════════════════════════════
    //  UTILITY HELPERS
    // ══════════════════════════════════════════════════════════════════

    private static string DB_FormatBalance(decimal balance)
    {
        if (balance > 0) return "UGX " + balance.ToString("N0");
        if (balance < 0) return "UGX " + Math.Abs(balance).ToString("N0") + " CR";
        return "UGX 0";
    }

    private static string DB_TidExcl(HashSet<long> tids)
    {
        if (tids.Count == 0) return "0";
        var parts = new List<string>();
        foreach (long t in tids) parts.Add(t.ToString());
        return string.Join(",", parts.ToArray());
    }

    private static string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n")
                .Replace("\t", "\\t");
    }
}
