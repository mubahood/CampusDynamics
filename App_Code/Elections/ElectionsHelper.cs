using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using MySql.Data.MySqlClient;

/// <summary>
/// Centralised data-access helper for the Elections module.
/// Provides CRUD for posts, elections, candidates, voters, votes, and results.
///
/// Connection: vacConnectionString → campus_dynamics (main DB).
///
/// Usage:
///   DataTable dt = ElectionsHelper.GetAllPosts(true);
///   ElectionsHelper.SavePost(0, "Guild President", "PRES", ...);
///   DataTable results = ElectionsHelper.GetResults(electionId);
/// </summary>
public static class ElectionsHelper
{
    // ───────────────────────── Connection ──────────────────────────────────

    private static string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
            if (cs == null || string.IsNullOrEmpty(cs.ConnectionString))
                throw new InvalidOperationException(
                    "Missing 'vacConnectionString' in web.config connectionStrings section.");
            return cs.ConnectionString;
        }
    }

    private static MySqlConnection OpenConnection()
    {
        var conn = new MySqlConnection(ConnStr);
        conn.Open();
        return conn;
    }

    /// <summary>Creates a named MySql parameter (null-safe).</summary>
    public static MySqlParameter P(string name, object value)
    {
        return new MySqlParameter(name, value ?? DBNull.Value);
    }


    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  POSTS CRUD                                                          ║
    // ╚═══════════════════════════════════════════════════════════════════════╝

    /// <summary>
    /// Returns all election posts, optionally filtered to active only.
    /// Columns: id, post_name, post_code, description, eligibility,
    ///          responsibilities, max_winners, display_order, is_active,
    ///          created_at, updated_at, candidate_count
    /// </summary>
    public static DataTable GetAllPosts(bool activeOnly)
    {
        string sql = @"
            SELECT p.*,
                   IFNULL(cc.cnt, 0) AS candidate_count
            FROM elect_post p
            LEFT JOIN (
                SELECT post_id, COUNT(*) AS cnt
                FROM elect_candidate
                WHERE status IN ('Pending','Approved')
                GROUP BY post_id
            ) cc ON cc.post_id = p.id"
            + (activeOnly ? " WHERE p.is_active = 1" : "")
            + " ORDER BY p.display_order, p.post_name";

        return ExecuteDataTable(sql);
    }

    /// <summary>Returns a single post by ID.</summary>
    public static DataRow GetPost(int postId)
    {
        DataTable dt = ExecuteDataTable(
            "SELECT * FROM elect_post WHERE id = @id",
            P("@id", postId));
        return dt.Rows.Count > 0 ? dt.Rows[0] : null;
    }

    /// <summary>
    /// Creates or updates an election post. Pass id=0 to create new.
    /// Returns the post ID.
    /// </summary>
    public static int SavePost(int id, string name, string code, string description,
        string eligibility, string responsibilities, int maxWinners, int displayOrder, bool isActive)
    {
        if (id > 0)
        {
            ExecuteNonQuery(@"
                UPDATE elect_post SET
                    post_name = @name, post_code = @code, description = @desc,
                    eligibility = @elig, responsibilities = @resp,
                    max_winners = @maxw, display_order = @disp, is_active = @active
                WHERE id = @id",
                P("@id", id), P("@name", name), P("@code", code), P("@desc", description),
                P("@elig", eligibility), P("@resp", responsibilities),
                P("@maxw", maxWinners), P("@disp", displayOrder), P("@active", isActive ? 1 : 0));
            return id;
        }
        else
        {
            ExecuteNonQuery(@"
                INSERT INTO elect_post (post_name, post_code, description, eligibility,
                    responsibilities, max_winners, display_order, is_active)
                VALUES (@name, @code, @desc, @elig, @resp, @maxw, @disp, @active)",
                P("@name", name), P("@code", code), P("@desc", description),
                P("@elig", eligibility), P("@resp", responsibilities),
                P("@maxw", maxWinners), P("@disp", displayOrder), P("@active", isActive ? 1 : 0));

            object lastId = ExecuteScalar("SELECT LAST_INSERT_ID()");
            return Convert.ToInt32(lastId);
        }
    }

    /// <summary>Deletes a post. Fails if candidates are linked (FK constraint).</summary>
    public static bool DeletePost(int postId)
    {
        try
        {
            ExecuteNonQuery("DELETE FROM elect_post WHERE id = @id", P("@id", postId));
            return true;
        }
        catch (MySqlException)
        {
            return false; // FK violation — candidates linked
        }
    }


    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  ELECTIONS CRUD                                                       ║
    // ╚═══════════════════════════════════════════════════════════════════════╝

    /// <summary>
    /// Returns all elections with summary stats.
    /// Columns: id, election_name, description, acad_year, start_date, end_date,
    ///          status, ..., voter_count, voted_count, candidate_count, post_count
    /// </summary>
    public static DataTable GetAllElections(string statusFilter)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append(@"
            SELECT e.*,
                   IFNULL(vc.voter_count, 0) AS voter_count,
                   IFNULL(vc.voted_count, 0) AS voted_count,
                   IFNULL(cc.cand_count, 0) AS candidate_count,
                   IFNULL(pc.post_count, 0) AS post_count
            FROM elect_election e
            LEFT JOIN (
                SELECT election_id,
                       COUNT(*) AS voter_count,
                       SUM(CASE WHEN has_voted = 1 THEN 1 ELSE 0 END) AS voted_count
                FROM elect_voter
                GROUP BY election_id
            ) vc ON vc.election_id = e.id
            LEFT JOIN (
                SELECT election_id, COUNT(*) AS cand_count
                FROM elect_candidate
                WHERE status IN ('Pending','Approved')
                GROUP BY election_id
            ) cc ON cc.election_id = e.id
            LEFT JOIN (
                SELECT election_id, COUNT(DISTINCT post_id) AS post_count
                FROM elect_candidate
                WHERE status = 'Approved'
                GROUP BY election_id
            ) pc ON pc.election_id = e.id");

        List<MySqlParameter> parms = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL")
        {
            sb.Append(" WHERE e.status = @status");
            parms.Add(P("@status", statusFilter));
        }
        sb.Append(" ORDER BY e.start_date DESC");

        return ExecuteDataTable(sb.ToString(), parms.ToArray());
    }

    /// <summary>Returns a single election by ID.</summary>
    public static DataRow GetElection(int electionId)
    {
        DataTable dt = ExecuteDataTable(
            "SELECT * FROM elect_election WHERE id = @id",
            P("@id", electionId));
        return dt.Rows.Count > 0 ? dt.Rows[0] : null;
    }

    /// <summary>
    /// Creates or updates an election. Pass id=0 to create new.
    /// Returns the election ID.
    /// </summary>
    public static int SaveElection(int id, string name, string description, string acadYear,
        DateTime startDate, DateTime endDate, string status, bool requireRegistration,
        bool requireFeesCleared, string allowedProgrammes, string allowedEntryYears,
        bool showLiveResults, bool showVoteCounts, bool resultsPublic, string createdBy)
    {
        if (id > 0)
        {
            ExecuteNonQuery(@"
                UPDATE elect_election SET
                    election_name = @name, description = @desc, acad_year = @ay,
                    start_date = @sd, end_date = @ed, status = @st,
                    require_registration = @rr, require_fees_cleared = @rfc,
                    allowed_programmes = @ap, allowed_entry_years = @aey,
                    show_live_results = @slr, show_vote_counts = @svc, results_public = @rp
                WHERE id = @id",
                P("@id", id), P("@name", name), P("@desc", description), P("@ay", acadYear),
                P("@sd", startDate), P("@ed", endDate), P("@st", status),
                P("@rr", requireRegistration ? 1 : 0), P("@rfc", requireFeesCleared ? 1 : 0),
                P("@ap", allowedProgrammes), P("@aey", allowedEntryYears),
                P("@slr", showLiveResults ? 1 : 0), P("@svc", showVoteCounts ? 1 : 0),
                P("@rp", resultsPublic ? 1 : 0));
            return id;
        }
        else
        {
            ExecuteNonQuery(@"
                INSERT INTO elect_election (election_name, description, acad_year,
                    start_date, end_date, status, require_registration, require_fees_cleared,
                    allowed_programmes, allowed_entry_years, show_live_results, show_vote_counts,
                    results_public, created_by)
                VALUES (@name, @desc, @ay, @sd, @ed, @st, @rr, @rfc, @ap, @aey, @slr, @svc, @rp, @cb)",
                P("@name", name), P("@desc", description), P("@ay", acadYear),
                P("@sd", startDate), P("@ed", endDate), P("@st", status),
                P("@rr", requireRegistration ? 1 : 0), P("@rfc", requireFeesCleared ? 1 : 0),
                P("@ap", allowedProgrammes), P("@aey", allowedEntryYears),
                P("@slr", showLiveResults ? 1 : 0), P("@svc", showVoteCounts ? 1 : 0),
                P("@rp", resultsPublic ? 1 : 0), P("@cb", createdBy));

            object lastId = ExecuteScalar("SELECT LAST_INSERT_ID()");
            return Convert.ToInt32(lastId);
        }
    }

    /// <summary>Updates election status only.</summary>
    public static void UpdateElectionStatus(int electionId, string newStatus)
    {
        ExecuteNonQuery(
            "UPDATE elect_election SET status = @st WHERE id = @id",
            P("@id", electionId), P("@st", newStatus));
    }

    /// <summary>
    /// Deletes an election. Only allowed for Draft/Cancelled elections with no votes.
    /// </summary>
    public static bool DeleteElection(int electionId)
    {
        try
        {
            // Check for existing votes first
            object voteCount = ExecuteScalar(
                "SELECT COUNT(*) FROM elect_vote WHERE election_id = @id",
                P("@id", electionId));
            if (Convert.ToInt32(voteCount) > 0) return false;

            // Delete in dependency order
            ExecuteNonQuery("DELETE FROM elect_result WHERE election_id = @id", P("@id", electionId));
            ExecuteNonQuery("DELETE FROM elect_voter WHERE election_id = @id", P("@id", electionId));
            ExecuteNonQuery("DELETE FROM elect_candidate WHERE election_id = @id", P("@id", electionId));
            ExecuteNonQuery("DELETE FROM elect_election WHERE id = @id", P("@id", electionId));
            return true;
        }
        catch (MySqlException)
        {
            return false;
        }
    }

    /// <summary>
    /// Auto-transitions elections based on current time:
    ///   Upcoming → Active      when NOW() >= start_date
    ///   Nominations → Active   when NOW() >= start_date
    ///   Active → Closed        when NOW() > end_date (+ auto-compute results)
    /// Call this on dashboard page load and portal page loads.
    /// Returns count of elections that transitioned to Closed (for result computation).
    /// </summary>
    public static int AutoTransitionElections()
    {
        // Phase 1: Upcoming / Nominations → Active
        ExecuteNonQuery(@"
            UPDATE elect_election
            SET status = 'Active'
            WHERE status IN ('Upcoming','Nominations') AND NOW() >= start_date");

        // Phase 2: Active → Closed (find affected IDs first so we can compute results)
        DataTable closing = ExecuteDataTable(@"
            SELECT id FROM elect_election
            WHERE status = 'Active' AND NOW() > end_date");

        if (closing.Rows.Count > 0)
        {
            ExecuteNonQuery(@"
                UPDATE elect_election
                SET status = 'Closed'
                WHERE status = 'Active' AND NOW() > end_date");

            // Auto-compute final results for each newly closed election
            foreach (DataRow row in closing.Rows)
            {
                int eid = Convert.ToInt32(row["id"]);
                try { ComputeResults(eid); }
                catch { /* Silently continue — results can be recomputed manually */ }
            }
        }

        return closing.Rows.Count;
    }


    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  CANDIDATES CRUD                                                     ║
    // ╚═══════════════════════════════════════════════════════════════════════╝

    /// <summary>
    /// Returns candidates, optionally filtered by election, post, and status.
    /// Columns: id, election_id, post_id, regno, candidate_name, photo_url,
    ///          manifesto, slogan, status, rejection_reason, display_order,
    ///          election_name, post_name, post_code, vote_count
    /// </summary>
    public static DataTable GetCandidates(int electionId, int postId, string statusFilter)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append(@"
            SELECT c.*,
                   e.election_name,
                   p.post_name,
                   p.post_code,
                   IFNULL(v.vote_count, 0) AS vote_count
            FROM elect_candidate c
            INNER JOIN elect_election e ON e.id = c.election_id
            INNER JOIN elect_post p ON p.id = c.post_id
            LEFT JOIN (
                SELECT candidate_id, COUNT(*) AS vote_count
                FROM elect_vote
                GROUP BY candidate_id
            ) v ON v.candidate_id = c.id
            WHERE 1=1");

        List<MySqlParameter> parms = new List<MySqlParameter>();

        if (electionId > 0)
        {
            sb.Append(" AND c.election_id = @eid");
            parms.Add(P("@eid", electionId));
        }
        if (postId > 0)
        {
            sb.Append(" AND c.post_id = @pid");
            parms.Add(P("@pid", postId));
        }
        if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL")
        {
            sb.Append(" AND c.status = @st");
            parms.Add(P("@st", statusFilter));
        }

        sb.Append(" ORDER BY p.display_order, c.display_order, c.candidate_name");
        return ExecuteDataTable(sb.ToString(), parms.ToArray());
    }

    /// <summary>Returns a single candidate by ID.</summary>
    public static DataRow GetCandidate(int candidateId)
    {
        DataTable dt = ExecuteDataTable(@"
            SELECT c.*, e.election_name, p.post_name, p.post_code
            FROM elect_candidate c
            INNER JOIN elect_election e ON e.id = c.election_id
            INNER JOIN elect_post p ON p.id = c.post_id
            WHERE c.id = @id",
            P("@id", candidateId));
        return dt.Rows.Count > 0 ? dt.Rows[0] : null;
    }

    /// <summary>
    /// Creates or updates a candidate. Pass id=0 to create new.
    /// Returns the candidate ID.
    /// </summary>
    public static int SaveCandidate(int id, int electionId, int postId, string regno,
        string name, string photoUrl, string manifesto, string slogan, string status)
    {
        if (id > 0)
        {
            ExecuteNonQuery(@"
                UPDATE elect_candidate SET
                    election_id = @eid, post_id = @pid, regno = @reg,
                    candidate_name = @name, photo_url = @photo, manifesto = @man,
                    slogan = @slo, status = @st
                WHERE id = @id",
                P("@id", id), P("@eid", electionId), P("@pid", postId),
                P("@reg", regno), P("@name", name), P("@photo", photoUrl),
                P("@man", manifesto), P("@slo", slogan), P("@st", status));
            return id;
        }
        else
        {
            ExecuteNonQuery(@"
                INSERT INTO elect_candidate (election_id, post_id, regno, candidate_name,
                    photo_url, manifesto, slogan, status)
                VALUES (@eid, @pid, @reg, @name, @photo, @man, @slo, @st)",
                P("@eid", electionId), P("@pid", postId), P("@reg", regno),
                P("@name", name), P("@photo", photoUrl), P("@man", manifesto),
                P("@slo", slogan), P("@st", status));

            object lastId = ExecuteScalar("SELECT LAST_INSERT_ID()");
            return Convert.ToInt32(lastId);
        }
    }

    /// <summary>Updates candidate status (approve, reject, disqualify, etc.).</summary>
    public static void UpdateCandidateStatus(int candidateId, string status, string reason)
    {
        ExecuteNonQuery(@"
            UPDATE elect_candidate
            SET status = @st, rejection_reason = @reason
            WHERE id = @id",
            P("@id", candidateId), P("@st", status), P("@reason", reason));
    }

    /// <summary>
    /// Deletes a candidate. Returns false if candidate has votes (FK protection).
    /// </summary>
    public static bool DeleteCandidate(int candidateId)
    {
        try
        {
            ExecuteNonQuery("DELETE FROM elect_candidate WHERE id = @id",
                P("@id", candidateId));
            return true;
        }
        catch (MySql.Data.MySqlClient.MySqlException ex)
        {
            if (ex.Number == 1451) return false; // FK constraint — has votes
            throw;
        }
    }


    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  VOTERS                                                               ║
    // ╚═══════════════════════════════════════════════════════════════════════╝

    /// <summary>
    /// Returns voters for an election, optionally searched/filtered.
    /// Columns: id, election_id, regno, voter_name, email, programme,
    ///          has_voted, voted_at, ip_address, is_eligible
    /// </summary>
    public static DataTable GetVoters(int electionId, string searchTerm, string hasVotedFilter)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append(@"
            SELECT v.*
            FROM elect_voter v
            WHERE v.election_id = @eid");

        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(P("@eid", electionId));

        if (!string.IsNullOrEmpty(searchTerm))
        {
            sb.Append(" AND (v.voter_name LIKE @q OR v.regno LIKE @q OR v.programme LIKE @q)");
            parms.Add(P("@q", "%" + searchTerm + "%"));
        }
        if (hasVotedFilter == "YES")
        {
            sb.Append(" AND v.has_voted = 1");
        }
        else if (hasVotedFilter == "NO")
        {
            sb.Append(" AND v.has_voted = 0");
        }

        sb.Append(" ORDER BY v.voter_name, v.regno");
        return ExecuteDataTable(sb.ToString(), parms.ToArray());
    }

    /// <summary>
    /// Returns voter counts: [0] = total, [1] = voted, [2] = eligible.
    /// </summary>
    public static int[] GetVoterCounts(int electionId)
    {
        DataTable dt = ExecuteDataTable(@"
            SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN has_voted = 1 THEN 1 ELSE 0 END) AS voted,
                SUM(CASE WHEN is_eligible = 1 THEN 1 ELSE 0 END) AS eligible
            FROM elect_voter
            WHERE election_id = @eid",
            P("@eid", electionId));

        if (dt.Rows.Count == 0) return new int[] { 0, 0, 0 };
        DataRow r = dt.Rows[0];
        return new int[] {
            Convert.ToInt32(r["total"]),
            Convert.ToInt32(r["voted"]),
            Convert.ToInt32(r["eligible"])
        };
    }

    /// <summary>
    /// Imports all registered students as voters for the given election.
    /// Uses ON DUPLICATE KEY to avoid duplicates on re-import.
    /// Returns the number of new voters added.
    /// </summary>
    public static int ImportVotersFromRegistered(int electionId, string progFilter, string yearFilter)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append(@"
            INSERT INTO elect_voter (election_id, regno, voter_name, email, programme)
            SELECT @eid,
                   s.regno,
                   TRIM(CONCAT(IFNULL(s.firstname,''), ' ', IFNULL(s.othername,''))) AS voter_name,
                   s.email,
                   s.progid
            FROM acad_student s
            INNER JOIN acad_registration r ON r.regno = s.regno
            WHERE UPPER(COALESCE(s.new_status, '')) = 'ACTIVE'");

        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(P("@eid", electionId));

        if (!string.IsNullOrEmpty(progFilter))
        {
            sb.Append(" AND s.progid = @prog");
            parms.Add(P("@prog", progFilter));
        }
        if (!string.IsNullOrEmpty(yearFilter))
        {
            sb.Append(" AND r.acad_year = @yr");
            parms.Add(P("@yr", yearFilter));
        }

        sb.Append(@"
            GROUP BY s.regno
            ON DUPLICATE KEY UPDATE voter_name = VALUES(voter_name), email = VALUES(email)");

        return ExecuteNonQuery(sb.ToString(), parms.ToArray());
    }

    /// <summary>Toggles voter eligibility.</summary>
    public static void SetVoterEligibility(int voterId, bool eligible)
    {
        ExecuteNonQuery(
            "UPDATE elect_voter SET is_eligible = @e WHERE id = @id",
            P("@id", voterId), P("@e", eligible ? 1 : 0));
    }


    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  VOTES & RESULTS                                                     ║
    // ╚═══════════════════════════════════════════════════════════════════════╝

    /// <summary>
    /// Returns per-candidate vote counts grouped by post for an election.
    /// Columns: post_id, post_name, candidate_id, candidate_name, photo_url,
    ///          slogan, vote_count
    /// </summary>
    public static DataTable GetVoteSummary(int electionId)
    {
        return ExecuteDataTable(@"
            SELECT p.id AS post_id, p.post_name, p.display_order,
                   c.id AS candidate_id, c.candidate_name, c.photo_url, c.slogan,
                   COUNT(v.id) AS vote_count
            FROM elect_candidate c
            INNER JOIN elect_post p ON p.id = c.post_id
            LEFT JOIN elect_vote v ON v.candidate_id = c.id
            WHERE c.election_id = @eid
              AND c.status = 'Approved'
            GROUP BY p.id, p.post_name, p.display_order,
                     c.id, c.candidate_name, c.photo_url, c.slogan
            ORDER BY p.display_order, vote_count DESC",
            P("@eid", electionId));
    }

    /// <summary>
    /// Computes final results for an election: counts votes, ranks candidates,
    /// determines winners and ties. Populates elect_result table.
    /// </summary>
    public static void ComputeResults(int electionId)
    {
        // Clear existing results for this election
        ExecuteNonQuery(
            "DELETE FROM elect_result WHERE election_id = @eid",
            P("@eid", electionId));

        // Get all posts for this election
        DataTable posts = ExecuteDataTable(@"
            SELECT DISTINCT c.post_id, p.max_winners
            FROM elect_candidate c
            INNER JOIN elect_post p ON p.id = c.post_id
            WHERE c.election_id = @eid AND c.status = 'Approved'",
            P("@eid", electionId));

        foreach (DataRow postRow in posts.Rows)
        {
            int postId = Convert.ToInt32(postRow["post_id"]);
            int maxWinners = Convert.ToInt32(postRow["max_winners"]);

            // Count votes per candidate for this post
            DataTable counts = ExecuteDataTable(@"
                SELECT c.id AS candidate_id,
                       COUNT(v.id) AS vote_count
                FROM elect_candidate c
                LEFT JOIN elect_vote v ON v.candidate_id = c.id AND v.post_id = @pid
                WHERE c.election_id = @eid AND c.post_id = @pid AND c.status = 'Approved'
                GROUP BY c.id
                ORDER BY vote_count DESC",
                P("@eid", electionId), P("@pid", postId));

            // Compute total votes for this post
            int totalVotes = 0;
            foreach (DataRow cr in counts.Rows)
                totalVotes += Convert.ToInt32(cr["vote_count"]);

            int rank = 0;
            int prevCount = -1;
            int skipCount = 0;

            foreach (DataRow cr in counts.Rows)
            {
                int candidateId = Convert.ToInt32(cr["candidate_id"]);
                int voteCount = Convert.ToInt32(cr["vote_count"]);
                decimal pct = totalVotes > 0
                    ? Math.Round((decimal)voteCount / totalVotes * 100, 2)
                    : 0;

                // Dense ranking with tie detection
                if (voteCount != prevCount)
                {
                    rank += 1 + skipCount;
                    skipCount = 0;
                }
                else
                {
                    skipCount++;
                }

                bool isWinner = rank <= maxWinners;
                bool isTie = false;

                // Check if there's a tie at the winning boundary
                // (compare against prevCount BEFORE we update it)
                if (rank <= maxWinners && voteCount == prevCount && rank > 1)
                    isTie = true;

                prevCount = voteCount;

                ExecuteNonQuery(@"
                    INSERT INTO elect_result
                        (election_id, post_id, candidate_id, vote_count, percentage,
                         rank_position, is_winner, is_tie)
                    VALUES (@eid, @pid, @cid, @vc, @pct, @rk, @win, @tie)
                    ON DUPLICATE KEY UPDATE
                        vote_count = @vc, percentage = @pct, rank_position = @rk,
                        is_winner = @win, is_tie = @tie, computed_at = NOW()",
                    P("@eid", electionId), P("@pid", postId), P("@cid", candidateId),
                    P("@vc", voteCount), P("@pct", pct), P("@rk", rank),
                    P("@win", isWinner ? 1 : 0), P("@tie", isTie ? 1 : 0));
            }

            // Retroactively mark ties: if multiple candidates share the same count at a winning rank
            ExecuteNonQuery(@"
                UPDATE elect_result r
                INNER JOIN (
                    SELECT vote_count, COUNT(*) AS cnt
                    FROM elect_result
                    WHERE election_id = @eid AND post_id = @pid AND is_winner = 1
                    GROUP BY vote_count HAVING cnt > 1
                ) t ON r.vote_count = t.vote_count
                SET r.is_tie = 1
                WHERE r.election_id = @eid AND r.post_id = @pid AND r.is_winner = 1",
                P("@eid", electionId), P("@pid", postId));
        }
    }

    /// <summary>
    /// Returns computed results for an election.
    /// Columns: post_id, post_name, candidate_id, candidate_name, photo_url,
    ///          vote_count, percentage, rank_position, is_winner, is_tie
    /// </summary>
    public static DataTable GetResults(int electionId)
    {
        return ExecuteDataTable(@"
            SELECT r.*, p.post_name, p.display_order,
                   c.candidate_name, c.photo_url, c.slogan, c.regno
            FROM elect_result r
            INNER JOIN elect_post p ON p.id = r.post_id
            INNER JOIN elect_candidate c ON c.id = r.candidate_id
            WHERE r.election_id = @eid
            ORDER BY p.display_order, r.rank_position",
            P("@eid", electionId));
    }

    /// <summary>
    /// Returns live vote counts as a JSON string for AJAX polling.
    /// </summary>
    public static string GetLiveVoteCountsJson(int electionId)
    {
        DataRow election = GetElection(electionId);
        if (election == null) return "{\"ok\":false,\"msg\":\"Election not found\"}";

        int[] voterCounts = GetVoterCounts(electionId);
        decimal turnoutPct = voterCounts[0] > 0
            ? Math.Round((decimal)voterCounts[1] / voterCounts[0] * 100, 1)
            : 0;

        DataTable summary = GetVoteSummary(electionId);

        StringBuilder sb = new StringBuilder();
        sb.Append("{\"ok\":true");
        sb.AppendFormat(",\"election\":\"{0}\"", EscapeJson(election["election_name"].ToString()));
        sb.AppendFormat(",\"status\":\"{0}\"", election["status"]);
        sb.AppendFormat(",\"turnout\":{{\"total\":{0},\"voted\":{1},\"pct\":{2}}}",
            voterCounts[0], voterCounts[1], turnoutPct);

        // Group by post
        sb.Append(",\"posts\":[");
        int lastPostId = -1;
        bool firstPost = true;
        bool firstCandidate = true;

        foreach (DataRow row in summary.Rows)
        {
            int postId = Convert.ToInt32(row["post_id"]);

            if (postId != lastPostId)
            {
                if (!firstPost) sb.Append("]}"); // close previous post
                if (!firstPost) sb.Append(",");
                sb.AppendFormat("{{\"post_id\":{0},\"post_name\":\"{1}\",\"candidates\":[",
                    postId, EscapeJson(row["post_name"].ToString()));
                lastPostId = postId;
                firstPost = false;
                firstCandidate = true;
            }

            if (!firstCandidate) sb.Append(",");
            int vc = Convert.ToInt32(row["vote_count"]);
            sb.AppendFormat("{{\"id\":{0},\"name\":\"{1}\",\"photo\":\"{2}\",\"votes\":{3}}}",
                row["candidate_id"],
                EscapeJson(row["candidate_name"].ToString()),
                EscapeJson((row["photo_url"] ?? "").ToString()),
                vc);
            firstCandidate = false;
        }
        if (!firstPost) sb.Append("]}"); // close last post
        sb.Append("]}");

        return sb.ToString();
    }


    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  ELECTION STATISTICS                                                 ║
    // ╚═══════════════════════════════════════════════════════════════════════╝

    /// <summary>
    /// Returns dashboard stats: total elections, active, upcoming, total voters,
    /// total voted, total candidates.
    /// </summary>
    public static Dictionary<string, int> GetDashboardStats()
    {
        var stats = new Dictionary<string, int>();

        DataTable dt = ExecuteDataTable(@"
            SELECT
                COUNT(*) AS total_elections,
                SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_elections,
                SUM(CASE WHEN status = 'Upcoming' THEN 1 ELSE 0 END) AS upcoming_elections,
                SUM(CASE WHEN status = 'Nominations' THEN 1 ELSE 0 END) AS nominations_elections,
                SUM(CASE WHEN status = 'Draft' THEN 1 ELSE 0 END) AS draft_elections,
                SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) AS closed_elections
            FROM elect_election");

        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            stats["total_elections"] = Convert.ToInt32(r["total_elections"]);
            stats["active_elections"] = Convert.ToInt32(r["active_elections"]);
            stats["upcoming_elections"] = Convert.ToInt32(r["upcoming_elections"]);
            stats["nominations_elections"] = Convert.ToInt32(r["nominations_elections"]);
            stats["draft_elections"] = Convert.ToInt32(r["draft_elections"]);
            stats["closed_elections"] = Convert.ToInt32(r["closed_elections"]);
        }

        object voterCount = ExecuteScalar("SELECT COUNT(*) FROM elect_voter");
        stats["total_voters"] = Convert.ToInt32(voterCount);

        object votedCount = ExecuteScalar("SELECT COUNT(*) FROM elect_voter WHERE has_voted = 1");
        stats["total_voted"] = Convert.ToInt32(votedCount);

        object candCount = ExecuteScalar(
            "SELECT COUNT(*) FROM elect_candidate WHERE status IN ('Pending','Approved')");
        stats["total_candidates"] = Convert.ToInt32(candCount);

        object pendingApps = ExecuteScalar(
            "SELECT COUNT(*) FROM elect_candidate WHERE status = 'Pending'");
        stats["pending_applications"] = Convert.ToInt32(pendingApps);

        return stats;
    }

    /// <summary>
    /// Returns recent election activity derived from timestamps across tables.
    /// Used for the admin dashboard activity feed. Returns up to 15 items.
    /// Columns: event_type, description, timestamp, election_name, detail
    /// </summary>
    public static DataTable GetRecentActivity()
    {
        return ExecuteDataTable(@"
            (
                SELECT 'candidate_applied' AS event_type,
                       CONCAT(c.candidate_name, ' applied for ', p.post_name) AS description,
                       c.created_at AS timestamp,
                       e.election_name,
                       c.status AS detail
                FROM elect_candidate c
                INNER JOIN elect_election e ON e.id = c.election_id
                INNER JOIN elect_post p ON p.id = c.post_id
                WHERE c.created_at IS NOT NULL
                ORDER BY c.created_at DESC
                LIMIT 8
            )
            UNION ALL
            (
                SELECT 'vote_cast' AS event_type,
                       CONCAT('Vote recorded for ', p.post_name) AS description,
                       v.cast_at AS timestamp,
                       e.election_name,
                       '' AS detail
                FROM elect_vote v
                INNER JOIN elect_election e ON e.id = v.election_id
                INNER JOIN elect_post p ON p.id = v.post_id
                WHERE v.cast_at IS NOT NULL
                ORDER BY v.cast_at DESC
                LIMIT 8
            )
            UNION ALL
            (
                SELECT 'election_updated' AS event_type,
                       CONCAT('Election ""', e.election_name, '"" status: ', e.status) AS description,
                       IFNULL(e.updated_at, e.created_at) AS timestamp,
                       e.election_name,
                       e.status AS detail
                FROM elect_election e
                WHERE e.updated_at IS NOT NULL OR e.created_at IS NOT NULL
                ORDER BY IFNULL(e.updated_at, e.created_at) DESC
                LIMIT 5
            )
            ORDER BY timestamp DESC
            LIMIT 15");
    }

    /// <summary>
    /// Searches students from acad_student (for adding candidates).
    /// Returns: regno, firstname, othername, email, progid, progname
    /// </summary>
    public static DataTable SearchStudents(string query)
    {
        return ExecuteDataTable(@"
            SELECT s.regno, s.firstname, s.othername, s.email, s.progid,
                   IFNULL(p.progname, s.progid) AS progname
            FROM acad_student s
            LEFT JOIN acad_programme p ON p.progcode = s.progid
            WHERE s.regno LIKE @q
               OR s.firstname LIKE @q
               OR s.othername LIKE @q
            ORDER BY s.firstname, s.othername
            LIMIT 20",
            P("@q", "%" + query + "%"));
    }

    /// <summary>
    /// Returns list of academic years for dropdowns.
    /// </summary>
    public static DataTable GetAcademicYears()
    {
        return ExecuteDataTable(
            "SELECT acadyear FROM acad_acadyears WHERE status = 'Active' ORDER BY acadyear DESC");
    }

    /// <summary>
    /// Returns list of programmes for dropdowns.
    /// </summary>
    public static DataTable GetProgrammes()
    {
        return ExecuteDataTable(
            "SELECT progcode, progname FROM acad_programme ORDER BY progname");
    }


    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  LOW-LEVEL DB METHODS                                                ║
    // ╚═══════════════════════════════════════════════════════════════════════╝

    private static DataTable ExecuteDataTable(string sql, params MySqlParameter[] parameters)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = OpenConnection())
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parameters != null)
            {
                foreach (var p in parameters) cmd.Parameters.Add(p);
            }
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        return dt;
    }

    private static object ExecuteScalar(string sql, params MySqlParameter[] parameters)
    {
        using (MySqlConnection conn = OpenConnection())
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parameters != null)
            {
                foreach (var p in parameters) cmd.Parameters.Add(p);
            }
            return cmd.ExecuteScalar();
        }
    }

    private static int ExecuteNonQuery(string sql, params MySqlParameter[] parameters)
    {
        using (MySqlConnection conn = OpenConnection())
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parameters != null)
            {
                foreach (var p in parameters) cmd.Parameters.Add(p);
            }
            return cmd.ExecuteNonQuery();
        }
    }

    private static string EscapeJson(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        return val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }
}
