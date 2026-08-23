using System;
using System.Collections.Generic;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// API/v2/elections — student elections: what is running, who is standing, and casting a ballot.
///
/// The tables (elect_election / post / candidate / voter / vote / result) have been carrying real
/// ballots since before this module existed, with no API at all — an app could show a student
/// their marks and their fees but not let them vote in their own guild election.
///
/// THE RULES ARE THE PORTAL'S, RE-DERIVED HERE. The canonical implementation lives in the portal
/// application (ElectionsPortalHelper) which this application cannot call, so the contract is
/// reproduced exactly and, importantly, the whole of it: election must be Active, voter must be
/// on the register and eligible, the ballot token must match the one stored against that voter,
/// one vote per post, and the candidate must be Approved for that post in that election. Casting
/// is a single transaction with the voter row locked, so two devices racing cannot produce two
/// ballots for the same post.
///
/// ON SECRECY. elect_vote stores voter_id, so a ballot is traceable in the schema — that is the
/// existing design and this module does not pretend otherwise. What it will not do is publish it:
/// my_ballot reports WHICH POSTS a student has voted for, never which candidate they chose, and
/// results are served only for elections whose results are published.
/// </summary>
public partial class API_v2_elections : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;
        if (ApiHelper.IsRateLimited(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "list":       HandleList();       break;
                case "detail":     HandleDetail();     break;
                case "candidates": HandleCandidates(); break;
                case "ballot":     HandleBallot();     break;
                case "vote":       HandleVote();       break;
                case "my_ballot":  HandleMyBallot();   break;
                case "results":    HandleResults();    break;
                case "ping":
                    ApiHelper.Success(Response, new { service = "elections", time = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") }, "OK");
                    break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". Valid actions: list, detail, candidates, ballot, " +
                        "vote, my_ballot, results, ping",
                        "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private string Me(out TokenInfo auth)
    {
        auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return null;
        if (string.Equals(auth.UserType, "student", StringComparison.OrdinalIgnoreCase))
            return (auth.UserId ?? "").Trim();

        string regno = ApiHelper.Param(Request, "regno", "").Trim();
        if (regno == "") { ApiHelper.Error(Response, "Pass ?regno= to act for a student.", "MISSING_PARAM"); return null; }
        return regno;
    }

    private static string Str(object o) { return o == null || o == DBNull.Value ? "" : Convert.ToString(o).Trim(); }
    private static int I(object o) { return o == null || o == DBNull.Value ? 0 : Convert.ToInt32(o); }
    private static string Fmt(object o)
    {
        if (o == null || o == DBNull.Value) return "";
        try { return Convert.ToDateTime(o).ToString("yyyy-MM-dd HH:mm"); } catch { return Convert.ToString(o); }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  LIST — elections this student can see, with their own standing
    // ═══════════════════════════════════════════════════════════════════

    private void HandleList()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;

        // Draft elections are the Guild office's business, not the students'.
        DataTable dt = ApiHelper.Query(
            "SELECT e.id, e.election_name, IFNULL(e.description,'') AS description, IFNULL(e.acad_year,'') AS acad_year, " +
            "  e.start_date, e.end_date, e.status, IFNULL(e.results_public,0) AS results_public, " +
            "  IFNULL(e.show_live_results,0) AS show_live_results, " +
            "  IFNULL(v.is_eligible,0) AS is_eligible, IFNULL(v.has_voted,0) AS has_voted, " +
            "  (v.id IS NOT NULL) AS on_register " +
            "FROM elect_election e " +
            "LEFT JOIN elect_voter v ON v.election_id = e.id AND TRIM(v.regno) = @r " +
            "WHERE e.status <> 'Draft' ORDER BY e.start_date DESC, e.id DESC",
            new MySqlParameter("@r", regno));

        var items = new List<object>();
        foreach (DataRow r in dt.Rows)
        {
            string status = Str(r["status"]);
            bool onRegister = I(r["on_register"]) == 1;
            bool eligible = I(r["is_eligible"]) == 1;
            items.Add(new
            {
                id = I(r["id"]),
                name = Str(r["election_name"]),
                description = Str(r["description"]),
                acad_year = Str(r["acad_year"]),
                starts_at = Fmt(r["start_date"]),
                ends_at = Fmt(r["end_date"]),
                status = status,
                is_open = string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase),
                results_published = I(r["results_public"]) == 1,
                me = new
                {
                    on_register = onRegister,
                    eligible = eligible,
                    finished_voting = I(r["has_voted"]) == 1,
                    can_vote = eligible && string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase),
                    why_not = !onRegister ? "You are not on the voters' register for this election."
                            : !eligible ? "You are on the register but marked not eligible."
                            : !string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase)
                                ? "Voting is not open." : ""
                }
            });
        }

        ApiHelper.Success(Response, new { elections = items, count = items.Count }, "Elections");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DETAIL — the posts on the ballot, and how far this student has got
    // ═══════════════════════════════════════════════════════════════════

    private void HandleDetail()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        int eid = ApiHelper.ParamInt(Request, "election_id", 0);
        if (eid <= 0) { ApiHelper.Error(Response, "election_id is required.", "MISSING_PARAM"); return; }

        DataTable e = ApiHelper.Query(
            "SELECT id, election_name, IFNULL(description,'') AS description, IFNULL(acad_year,'') AS acad_year, " +
            "  start_date, end_date, status, IFNULL(results_public,0) AS results_public " +
            "FROM elect_election WHERE id=@e AND status <> 'Draft' LIMIT 1", new MySqlParameter("@e", eid));
        if (e.Rows.Count == 0) { ApiHelper.Error(Response, "That election was not found.", "NOT_FOUND"); return; }

        // Only posts that actually have someone standing — an empty post is not a ballot paper.
        DataTable posts = ApiHelper.Query(
            "SELECT p.id, p.post_name, IFNULL(p.post_code,'') AS post_code, IFNULL(p.description,'') AS description, " +
            "  IFNULL(p.max_winners,1) AS max_winners, IFNULL(p.display_order,0) AS display_order, " +
            "  (SELECT COUNT(*) FROM elect_candidate c WHERE c.election_id=@e AND c.post_id=p.id AND c.status='Approved') AS candidate_count, " +
            "  (SELECT COUNT(*) FROM elect_vote v INNER JOIN elect_voter vr ON vr.id=v.voter_id " +
            "     WHERE v.election_id=@e AND v.post_id=p.id AND TRIM(vr.regno)=@r) AS i_have_voted " +
            "FROM elect_post p " +
            "WHERE p.is_active=1 AND EXISTS (SELECT 1 FROM elect_candidate c2 WHERE c2.election_id=@e AND c2.post_id=p.id AND c2.status='Approved') " +
            "ORDER BY p.display_order, p.post_name",
            new MySqlParameter("@e", eid), new MySqlParameter("@r", regno));

        var list = new List<object>();
        int voted = 0;
        foreach (DataRow p in posts.Rows)
        {
            bool mine = I(p["i_have_voted"]) > 0;
            if (mine) voted++;
            list.Add(new
            {
                post_id = I(p["id"]),
                name = Str(p["post_name"]),
                code = Str(p["post_code"]),
                description = Str(p["description"]),
                max_winners = I(p["max_winners"]),
                candidate_count = I(p["candidate_count"]),
                i_have_voted = mine
            });
        }

        DataRow x = e.Rows[0];
        ApiHelper.Success(Response, new
        {
            id = I(x["id"]),
            name = Str(x["election_name"]),
            description = Str(x["description"]),
            acad_year = Str(x["acad_year"]),
            starts_at = Fmt(x["start_date"]),
            ends_at = Fmt(x["end_date"]),
            status = Str(x["status"]),
            is_open = string.Equals(Str(x["status"]), "Active", StringComparison.OrdinalIgnoreCase),
            results_published = I(x["results_public"]) == 1,
            posts = list,
            progress = new { total_posts = list.Count, voted_posts = voted, remaining = list.Count - voted }
        }, "Election");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CANDIDATES
    // ═══════════════════════════════════════════════════════════════════

    private void HandleCandidates()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        int eid = ApiHelper.ParamInt(Request, "election_id", 0);
        int pid = ApiHelper.ParamInt(Request, "post_id", 0);
        if (eid <= 0) { ApiHelper.Error(Response, "election_id is required.", "MISSING_PARAM"); return; }

        string where = "WHERE c.election_id=@e AND c.status='Approved'";
        var ps = new List<MySqlParameter> { new MySqlParameter("@e", eid) };
        if (pid > 0) { where += " AND c.post_id=@p"; ps.Add(new MySqlParameter("@p", pid)); }

        DataTable dt = ApiHelper.Query(
            "SELECT c.id, c.post_id, IFNULL(p.post_name,'') AS post_name, c.candidate_name, " +
            "  IFNULL(c.photo_url,'') AS photo_url, IFNULL(c.manifesto,'') AS manifesto, " +
            "  IFNULL(c.slogan,'') AS slogan, IFNULL(c.display_order,0) AS display_order " +
            "FROM elect_candidate c LEFT JOIN elect_post p ON p.id=c.post_id " + where +
            " ORDER BY p.display_order, c.display_order, c.candidate_name", ps.ToArray());

        var items = new List<object>();
        foreach (DataRow r in dt.Rows)
            items.Add(new
            {
                candidate_id = I(r["id"]),
                post_id = I(r["post_id"]),
                post_name = Str(r["post_name"]),
                name = Str(r["candidate_name"]),
                photo_url = Str(r["photo_url"]),
                slogan = Str(r["slogan"]),
                manifesto = Str(r["manifesto"])
            });

        // The candidate's own registration number is deliberately not returned: a voter needs the
        // name, the face and the manifesto, not a key to look them up by.
        ApiHelper.Success(Response, new { candidates = items, count = items.Count }, "Candidates");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  BALLOT — issue the token this student votes with
    // ═══════════════════════════════════════════════════════════════════

    private void HandleBallot()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        int eid = ApiHelper.ParamInt(Request, "election_id", 0);
        if (eid <= 0) { ApiHelper.Error(Response, "election_id is required.", "MISSING_PARAM"); return; }

        DataTable e = ApiHelper.Query("SELECT status FROM elect_election WHERE id=@e LIMIT 1", new MySqlParameter("@e", eid));
        if (e.Rows.Count == 0) { ApiHelper.Error(Response, "That election was not found.", "NOT_FOUND"); return; }
        if (!string.Equals(Str(e.Rows[0]["status"]), "Active", StringComparison.OrdinalIgnoreCase))
        { ApiHelper.Error(Response, "Voting is not open for this election.", "NOT_ACTIVE"); return; }

        DataTable v = ApiHelper.Query(
            "SELECT id, IFNULL(is_eligible,0) AS is_eligible, IFNULL(has_voted,0) AS has_voted " +
            "FROM elect_voter WHERE election_id=@e AND TRIM(regno)=@r LIMIT 1",
            new MySqlParameter("@e", eid), new MySqlParameter("@r", regno));
        if (v.Rows.Count == 0)
        { ApiHelper.Error(Response, "You are not on the voters' register for this election.", "NOT_ON_REGISTER"); return; }
        if (I(v.Rows[0]["is_eligible"]) != 1)
        { ApiHelper.Error(Response, "You are on the register but marked not eligible to vote.", "NOT_ELIGIBLE"); return; }

        // A fresh token each time the ballot is opened, stored against the voter — the same
        // scheme the web page uses, so a token issued here works and one issued there is replaced.
        string token = NewToken(eid, regno);
        ApiHelper.Execute("UPDATE elect_voter SET vote_token=@t WHERE election_id=@e AND TRIM(regno)=@r",
            new MySqlParameter("@t", token), new MySqlParameter("@e", eid), new MySqlParameter("@r", regno));

        ApiHelper.Success(Response, new
        {
            election_id = eid,
            ballot_token = token,
            finished_voting = I(v.Rows[0]["has_voted"]) == 1,
            note = "Send this token with every vote. Opening the ballot again issues a new one and " +
                   "retires this."
        }, "Ballot issued");
    }

    private static string NewToken(int electionId, string regno)
    {
        string raw = electionId + "|" + regno + "|" + DateTime.UtcNow.Ticks + "|" + Guid.NewGuid();
        using (SHA256 sha = SHA256.Create())
        {
            byte[] h = sha.ComputeHash(Encoding.UTF8.GetBytes(raw));
            var sb = new StringBuilder(64);
            foreach (byte b in h) sb.Append(b.ToString("x2"));
            return sb.ToString();
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  VOTE
    // ═══════════════════════════════════════════════════════════════════

    private void HandleVote()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        if (!string.Equals(auth.UserType, "student", StringComparison.OrdinalIgnoreCase)
            && !TokenManager.IsSpecialToken(auth))
        { ApiHelper.Error(Response, "Only a student may cast a vote.", "STUDENT_TOKEN_REQUIRED"); return; }

        int eid = ApiHelper.ParamInt(Request, "election_id", 0);
        int pid = ApiHelper.ParamInt(Request, "post_id", 0);
        int cid = ApiHelper.ParamInt(Request, "candidate_id", 0);
        string token = ApiHelper.Param(Request, "ballot_token", "").Trim();

        if (eid <= 0 || pid <= 0 || cid <= 0)
        { ApiHelper.Error(Response, "election_id, post_id and candidate_id are all required.", "MISSING_PARAM"); return; }
        if (token == "")
        { ApiHelper.Error(Response, "ballot_token is required — get one from action=ballot.", "MISSING_PARAM"); return; }

        // One transaction, voter row locked. Two devices racing on the same post cannot both win:
        // the second waits for the lock and then fails the already-voted check.
        using (MySqlConnection conn = ApiHelper.GetConnection())
        {
            conn.Open();
            using (MySqlTransaction tx = conn.BeginTransaction())
            {
                try
                {
                    using (var cmd = new MySqlCommand("SELECT status FROM elect_election WHERE id=@e FOR UPDATE", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@e", eid);
                        object st = cmd.ExecuteScalar();
                        if (st == null || !string.Equals(Convert.ToString(st), "Active", StringComparison.OrdinalIgnoreCase))
                        { tx.Rollback(); ApiHelper.Error(Response, "Voting is not open for this election.", "NOT_ACTIVE"); return; }
                    }

                    int voterId; string storedToken;
                    using (var cmd = new MySqlCommand(
                        "SELECT id, IFNULL(is_eligible,0) AS is_eligible, IFNULL(vote_token,'') AS vote_token " +
                        "FROM elect_voter WHERE election_id=@e AND TRIM(regno)=@r FOR UPDATE", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@e", eid);
                        cmd.Parameters.AddWithValue("@r", regno);
                        using (MySqlDataReader rd = cmd.ExecuteReader())
                        {
                            if (!rd.Read())
                            { rd.Close(); tx.Rollback(); ApiHelper.Error(Response, "You are not on the voters' register for this election.", "NOT_ON_REGISTER"); return; }
                            if (Convert.ToInt32(rd["is_eligible"]) != 1)
                            { rd.Close(); tx.Rollback(); ApiHelper.Error(Response, "You are not eligible to vote in this election.", "NOT_ELIGIBLE"); return; }
                            voterId = Convert.ToInt32(rd["id"]);
                            storedToken = Convert.ToString(rd["vote_token"]);
                        }
                    }

                    if (string.IsNullOrEmpty(storedToken) || !storedToken.Equals(token, StringComparison.OrdinalIgnoreCase))
                    { tx.Rollback(); ApiHelper.Error(Response, "That ballot token is not valid. Open the ballot again.", "INVALID_BALLOT_TOKEN"); return; }

                    using (var cmd = new MySqlCommand(
                        "SELECT COUNT(*) FROM elect_vote WHERE election_id=@e AND post_id=@p AND voter_id=@v", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@e", eid);
                        cmd.Parameters.AddWithValue("@p", pid);
                        cmd.Parameters.AddWithValue("@v", voterId);
                        if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                        { tx.Rollback(); ApiHelper.Error(Response, "You have already voted for this post.", "ALREADY_VOTED"); return; }
                    }

                    using (var cmd = new MySqlCommand(
                        "SELECT COUNT(*) FROM elect_candidate WHERE id=@c AND election_id=@e AND post_id=@p AND status='Approved'", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@c", cid);
                        cmd.Parameters.AddWithValue("@e", eid);
                        cmd.Parameters.AddWithValue("@p", pid);
                        if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                        { tx.Rollback(); ApiHelper.Error(Response, "That candidate is not standing for this post.", "INVALID_CANDIDATE"); return; }
                    }

                    using (var cmd = new MySqlCommand(
                        "INSERT INTO elect_vote (election_id, post_id, candidate_id, voter_id, vote_token, cast_at) " +
                        "VALUES (@e,@p,@c,@v,@t,NOW())", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@e", eid);
                        cmd.Parameters.AddWithValue("@p", pid);
                        cmd.Parameters.AddWithValue("@c", cid);
                        cmd.Parameters.AddWithValue("@v", voterId);
                        cmd.Parameters.AddWithValue("@t", token);
                        cmd.ExecuteNonQuery();
                    }

                    using (var cmd = new MySqlCommand(
                        "UPDATE elect_voter SET voted_at=NOW(), ip_address=@ip, user_agent=@ua WHERE id=@v", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@v", voterId);
                        cmd.Parameters.AddWithValue("@ip", (object)Ip() ?? DBNull.Value);
                        string ua = Request.UserAgent ?? "";
                        cmd.Parameters.AddWithValue("@ua", ua.Length > 500 ? ua.Substring(0, 500) : ua);
                        cmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
                catch (Exception ex)
                {
                    try { tx.Rollback(); } catch { }
                    ApiHelper.Error(Response, "The vote could not be recorded: " + ex.Message, "SERVER_ERROR");
                    return;
                }
            }
        }

        // How much of the ballot is left, so an app can move the student on.
        int totalPosts = 0, votedPosts = 0;
        try
        {
            object t = ApiHelper.Scalar(
                "SELECT COUNT(DISTINCT c.post_id) FROM elect_candidate c WHERE c.election_id=@e AND c.status='Approved'",
                new MySqlParameter("@e", eid));
            totalPosts = I(t);
            object v2 = ApiHelper.Scalar(
                "SELECT COUNT(DISTINCT v.post_id) FROM elect_vote v INNER JOIN elect_voter vr ON vr.id=v.voter_id " +
                "WHERE v.election_id=@e AND TRIM(vr.regno)=@r", new MySqlParameter("@e", eid), new MySqlParameter("@r", regno));
            votedPosts = I(v2);
        }
        catch { }

        bool complete = totalPosts > 0 && votedPosts >= totalPosts;
        if (complete)
        {
            try
            {
                ApiHelper.Execute("UPDATE elect_voter SET has_voted=1 WHERE election_id=@e AND TRIM(regno)=@r",
                    new MySqlParameter("@e", eid), new MySqlParameter("@r", regno));
            }
            catch { }
        }

        ApiHelper.Success(Response, new
        {
            recorded = true,
            election_id = eid,
            post_id = pid,
            progress = new { total_posts = totalPosts, voted_posts = votedPosts, remaining = Math.Max(0, totalPosts - votedPosts) },
            ballot_complete = complete
        }, complete ? "Vote recorded. Your ballot is complete." : "Vote recorded.");
    }

    private string Ip()
    {
        try
        {
            string f = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(f)) return f.Split(',')[0].Trim();
            return Request.ServerVariables["REMOTE_ADDR"] ?? Request.UserHostAddress;
        }
        catch { return null; }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  MY BALLOT — which posts are done, never which candidate
    // ═══════════════════════════════════════════════════════════════════

    private void HandleMyBallot()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        int eid = ApiHelper.ParamInt(Request, "election_id", 0);
        if (eid <= 0) { ApiHelper.Error(Response, "election_id is required.", "MISSING_PARAM"); return; }

        DataTable dt = ApiHelper.Query(
            "SELECT p.id AS post_id, p.post_name, " +
            "  (SELECT COUNT(*) FROM elect_vote v INNER JOIN elect_voter vr ON vr.id=v.voter_id " +
            "     WHERE v.election_id=@e AND v.post_id=p.id AND TRIM(vr.regno)=@r) AS voted, " +
            "  (SELECT IFNULL(DATE_FORMAT(MAX(v2.cast_at),'%Y-%m-%d %H:%i'),'') FROM elect_vote v2 " +
            "     INNER JOIN elect_voter vr2 ON vr2.id=v2.voter_id " +
            "     WHERE v2.election_id=@e AND v2.post_id=p.id AND TRIM(vr2.regno)=@r) AS cast_at " +
            "FROM elect_post p " +
            "WHERE p.is_active=1 AND EXISTS (SELECT 1 FROM elect_candidate c WHERE c.election_id=@e AND c.post_id=p.id AND c.status='Approved') " +
            "ORDER BY p.display_order, p.post_name",
            new MySqlParameter("@e", eid), new MySqlParameter("@r", regno));

        var items = new List<object>();
        int done = 0;
        foreach (DataRow r in dt.Rows)
        {
            bool v = I(r["voted"]) > 0;
            if (v) done++;
            items.Add(new { post_id = I(r["post_id"]), post_name = Str(r["post_name"]), voted = v, cast_at = Str(r["cast_at"]) });
        }

        ApiHelper.Success(Response, new
        {
            election_id = eid,
            posts = items,
            progress = new { total_posts = items.Count, voted_posts = done, remaining = items.Count - done },
            note = "Which posts you have voted for, and when. Who you voted for is not reported."
        }, "My ballot");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  RESULTS — published only
    // ═══════════════════════════════════════════════════════════════════

    private void HandleResults()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        int eid = ApiHelper.ParamInt(Request, "election_id", 0);
        if (eid <= 0) { ApiHelper.Error(Response, "election_id is required.", "MISSING_PARAM"); return; }

        DataTable e = ApiHelper.Query(
            "SELECT election_name, status, IFNULL(results_public,0) AS results_public, " +
            "  IFNULL(show_live_results,0) AS show_live_results, IFNULL(show_vote_counts,0) AS show_vote_counts " +
            "FROM elect_election WHERE id=@e LIMIT 1", new MySqlParameter("@e", eid));
        if (e.Rows.Count == 0) { ApiHelper.Error(Response, "That election was not found.", "NOT_FOUND"); return; }

        bool published = I(e.Rows[0]["results_public"]) == 1;
        bool live = I(e.Rows[0]["show_live_results"]) == 1;
        bool showCounts = I(e.Rows[0]["show_vote_counts"]) == 1;
        bool closed = string.Equals(Str(e.Rows[0]["status"]), "Closed", StringComparison.OrdinalIgnoreCase);

        if (!published && !(live && closed))
        {
            ApiHelper.Error(Response, "Results for this election have not been published.", "RESULTS_NOT_PUBLISHED");
            return;
        }

        DataTable dt = ApiHelper.Query(
            "SELECT r.post_id, IFNULL(p.post_name,'') AS post_name, r.candidate_id, " +
            "  IFNULL(c.candidate_name,'') AS candidate_name, IFNULL(c.photo_url,'') AS photo_url, " +
            "  IFNULL(r.vote_count,0) AS vote_count, IFNULL(r.percentage,0) AS percentage, " +
            "  IFNULL(r.rank_position,0) AS rank_position, IFNULL(r.is_winner,0) AS is_winner, " +
            "  IFNULL(r.is_tie,0) AS is_tie " +
            "FROM elect_result r " +
            "LEFT JOIN elect_post p ON p.id=r.post_id " +
            "LEFT JOIN elect_candidate c ON c.id=r.candidate_id " +
            "WHERE r.election_id=@e ORDER BY p.display_order, p.post_name, r.rank_position",
            new MySqlParameter("@e", eid));

        var byPost = new Dictionary<int, List<object>>();
        var postNames = new Dictionary<int, string>();
        var order = new List<int>();
        foreach (DataRow r in dt.Rows)
        {
            int pid = I(r["post_id"]);
            if (!byPost.ContainsKey(pid)) { byPost[pid] = new List<object>(); postNames[pid] = Str(r["post_name"]); order.Add(pid); }
            byPost[pid].Add(new
            {
                candidate_id = I(r["candidate_id"]),
                name = Str(r["candidate_name"]),
                photo_url = Str(r["photo_url"]),
                // The Guild office decides whether raw counts are shown; the ranking always is.
                votes = showCounts ? (object)I(r["vote_count"]) : null,
                percentage = Convert.ToDouble(r["percentage"]),
                rank = I(r["rank_position"]),
                is_winner = I(r["is_winner"]) == 1,
                is_tie = I(r["is_tie"]) == 1
            });
        }

        var posts = new List<object>();
        foreach (int pid in order)
            posts.Add(new { post_id = pid, post_name = postNames[pid], candidates = byPost[pid] });

        ApiHelper.Success(Response, new
        {
            election_id = eid,
            election_name = Str(e.Rows[0]["election_name"]),
            status = Str(e.Rows[0]["status"]),
            vote_counts_shown = showCounts,
            posts = posts
        }, "Results");
    }
}
