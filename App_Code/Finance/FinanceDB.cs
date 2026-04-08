using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// Centralised Data Access Layer for the Finance module.
/// Eliminates hardcoded connection strings and duplicated ADO.NET boilerplate
/// across all finance controllers.
///
/// Usage:
///   DataTable dt = FinanceDB.ExecuteDataTable(
///       "SELECT * FROM fin_ledger WHERE accountcode = @acc",
///       FinanceDB.P("@acc", "1001"));
///
///   int rows = FinanceDB.ExecuteNonQuery(
///       "UPDATE fin_ledger SET particulars = @p WHERE TID = @id",
///       FinanceDB.P("@p", "corrected"), FinanceDB.P("@id", 42));
///
///   object val = FinanceDB.ExecuteScalar(
///       "SELECT COUNT(*) FROM fin_subaccounts");
///
///   // Stored procedure:
///   DataTable dt = FinanceDB.ExecuteSP("fin_TrialBalance",
///       FinanceDB.P("@sDate", "2025-01-01"), FinanceDB.P("@eDate", "2025-12-31"));
/// </summary>
public static class FinanceDB
{
    // ───────────────────────── Connection Strings ─────────────────────────

    /// <summary>
    /// Accounts database connection string (campus_dynamics_accounts).
    /// Reads from web.config "accountsConnectionString". No hardcoded fallback.
    /// </summary>
    public static string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            if (cs == null || string.IsNullOrEmpty(cs.ConnectionString))
                throw new InvalidOperationException(
                    "Missing 'accountsConnectionString' in web.config connectionStrings section.");
            return cs.ConnectionString;
        }
    }

    /// <summary>
    /// Main campus dynamics database connection string (campus_dynamics).
    /// Reads from web.config "vacConnectionString". No hardcoded fallback.
    /// </summary>
    public static string MainConnStr
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

    // ───────────────────────── Connection Factory ─────────────────────────

    /// <summary>Opens and returns a new MySqlConnection to the accounts DB.</summary>
    public static MySqlConnection GetAcctConnection()
    {
        var conn = new MySqlConnection(AcctConnStr);
        conn.Open();
        return conn;
    }

    /// <summary>Opens and returns a new MySqlConnection to the main DB.</summary>
    public static MySqlConnection GetMainConnection()
    {
        var conn = new MySqlConnection(MainConnStr);
        conn.Open();
        return conn;
    }

    // ───────────────────────── Parameter Helper ───────────────────────────

    /// <summary>
    /// Creates a MySqlParameter. Shorthand to keep call-sites concise.
    /// Converts null values to DBNull.Value automatically.
    /// </summary>
    public static MySqlParameter P(string name, object value)
    {
        return new MySqlParameter(name, value ?? DBNull.Value);
    }

    // ───────────────────────── Core Query Methods ─────────────────────────

    /// <summary>
    /// Executes a SQL query and returns the result as a DataTable.
    /// Uses the accounts DB by default.
    /// </summary>
    public static DataTable ExecuteDataTable(string sql, params MySqlParameter[] parameters)
    {
        return ExecuteDataTableInternal(AcctConnStr, sql, CommandType.Text, parameters);
    }

    /// <summary>
    /// Executes a SQL query against the specified connection string.
    /// </summary>
    public static DataTable ExecuteDataTable(string connStr, string sql, params MySqlParameter[] parameters)
    {
        return ExecuteDataTableInternal(connStr, sql, CommandType.Text, parameters);
    }

    /// <summary>
    /// Executes a stored procedure and returns the result as a DataTable.
    /// Uses the accounts DB.
    /// </summary>
    public static DataTable ExecuteSP(string spName, params MySqlParameter[] parameters)
    {
        return ExecuteDataTableInternal(AcctConnStr, spName, CommandType.StoredProcedure, parameters);
    }

    /// <summary>
    /// Executes a stored procedure against the specified connection string.
    /// </summary>
    public static DataTable ExecuteSP(string connStr, string spName, params MySqlParameter[] parameters)
    {
        return ExecuteDataTableInternal(connStr, spName, CommandType.StoredProcedure, parameters);
    }

    /// <summary>
    /// Executes a query and returns the first column of the first row.
    /// Returns default(T) if no rows / DBNull.
    /// </summary>
    public static T ExecuteScalar<T>(string sql, params MySqlParameter[] parameters)
    {
        return ExecuteScalarInternal<T>(AcctConnStr, sql, CommandType.Text, parameters);
    }

    /// <summary>
    /// Executes a query against the specified connection string and returns scalar.
    /// </summary>
    public static T ExecuteScalar<T>(string connStr, string sql, params MySqlParameter[] parameters)
    {
        return ExecuteScalarInternal<T>(connStr, sql, CommandType.Text, parameters);
    }

    /// <summary>
    /// Executes a stored procedure and returns the scalar result.
    /// </summary>
    public static T ExecuteScalarSP<T>(string spName, params MySqlParameter[] parameters)
    {
        return ExecuteScalarInternal<T>(AcctConnStr, spName, CommandType.StoredProcedure, parameters);
    }

    /// <summary>
    /// Executes a non-query (INSERT, UPDATE, DELETE) and returns affected row count.
    /// </summary>
    public static int ExecuteNonQuery(string sql, params MySqlParameter[] parameters)
    {
        return ExecuteNonQueryInternal(AcctConnStr, sql, CommandType.Text, parameters);
    }

    /// <summary>
    /// Executes a non-query against the specified connection string.
    /// </summary>
    public static int ExecuteNonQuery(string connStr, string sql, params MySqlParameter[] parameters)
    {
        return ExecuteNonQueryInternal(connStr, sql, CommandType.Text, parameters);
    }

    /// <summary>
    /// Executes a non-query stored procedure and returns affected row count.
    /// </summary>
    public static int ExecuteNonQuerySP(string spName, params MySqlParameter[] parameters)
    {
        return ExecuteNonQueryInternal(AcctConnStr, spName, CommandType.StoredProcedure, parameters);
    }

    /// <summary>
    /// Executes a non-query stored procedure against the specified connection string.
    /// </summary>
    public static int ExecuteNonQuerySP(string connStr, string spName, params MySqlParameter[] parameters)
    {
        return ExecuteNonQueryInternal(connStr, spName, CommandType.StoredProcedure, parameters);
    }

    // ───────────────────────── Reader Method ──────────────────────────────

    /// <summary>
    /// Executes a query and passes an open MySqlDataReader to the supplied action.
    /// Connection and reader are disposed automatically.
    /// 
    /// Usage:
    ///   FinanceDB.ExecuteReader("SELECT id, name FROM fin_subaccounts", reader => {
    ///       while (reader.Read()) { /* process */ }
    ///   }, FinanceDB.P("@x", 1));
    /// </summary>
    public static void ExecuteReader(string sql, Action<MySqlDataReader> readerAction,
        params MySqlParameter[] parameters)
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandType = CommandType.Text;
                AddParams(cmd, parameters);
                using (var reader = cmd.ExecuteReader())
                {
                    readerAction(reader);
                }
            }
        }
    }

    // ───────────────────────── Transactional Execute ──────────────────────

    /// <summary>
    /// Executes multiple statements within a single database transaction.
    /// Automatically rolls back on failure and re-throws the exception.
    /// 
    /// Usage:
    ///   FinanceDB.ExecuteInTransaction(conn => {
    ///       using (var cmd = new MySqlCommand("INSERT ...", conn)) { cmd.ExecuteNonQuery(); }
    ///       using (var cmd = new MySqlCommand("UPDATE ...", conn)) { cmd.ExecuteNonQuery(); }
    ///   });
    /// </summary>
    public static void ExecuteInTransaction(Action<MySqlConnection, MySqlTransaction> work)
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var tx = conn.BeginTransaction())
            {
                try
                {
                    work(conn, tx);
                    tx.Commit();
                }
                catch
                {
                    try { tx.Rollback(); } catch { /* swallow rollback failure */ }
                    throw;
                }
            }
        }
    }

    // ───────────────────────── Paged Query ────────────────────────────────

    /// <summary>
    /// Executes a paged query returning both the data page and total row count.
    /// The countSql should return a single COUNT(*) value.
    /// The dataSql should include LIMIT @pgOffset, @pgSize placeholders.
    /// </summary>
    public static PagedResult ExecutePagedQuery(
        string countSql, string dataSql, int pageIndex, int pageSize,
        params MySqlParameter[] parameters)
    {
        var result = new PagedResult();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // 1. Get total count
            using (var cmd = new MySqlCommand(countSql, conn))
            {
                AddParams(cmd, parameters);
                result.TotalRows = Convert.ToInt64(cmd.ExecuteScalar() ?? 0);
            }

            // 2. Compute paging
            result.TotalPages = result.TotalRows > 0
                ? (int)Math.Ceiling((double)result.TotalRows / pageSize) : 1;
            if (pageIndex >= result.TotalPages)
                pageIndex = Math.Max(0, result.TotalPages - 1);
            result.PageIndex = pageIndex;
            result.PageSize = pageSize;
            int offset = pageIndex * pageSize;

            // 3. Get data page
            // Clone parameters for second command (parameters can only belong to one command)
            var dataParams = CloneParameters(parameters);
            using (var cmd = new MySqlCommand(dataSql, conn))
            {
                AddParams(cmd, dataParams);
                cmd.Parameters.AddWithValue("@pgOffset", offset);
                cmd.Parameters.AddWithValue("@pgSize", pageSize);
                using (var da = new MySqlDataAdapter(cmd))
                {
                    result.Data = new DataTable();
                    da.Fill(result.Data);
                }
            }
        }

        return result;
    }

    // ───────────────────────── Aggregate Helper ───────────────────────────

    /// <summary>
    /// Reads a single-row aggregate query (SUM, COUNT, etc.) and returns values
    /// as a Dictionary of column name → object.
    /// 
    /// Usage:
    ///   var stats = FinanceDB.ExecuteAggregateRow(
    ///       "SELECT COUNT(*) AS cnt, SUM(amount) AS total FROM fin_ledger WHERE ...",
    ///       FinanceDB.P("@sDate", start));
    ///   long count = Convert.ToInt64(stats["cnt"]);
    /// </summary>
    public static Dictionary<string, object> ExecuteAggregateRow(string sql,
        params MySqlParameter[] parameters)
    {
        var dict = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                AddParams(cmd, parameters);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            dict[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                        }
                    }
                }
            }
        }
        return dict;
    }

    // ───────────────────────── Internal Helpers ───────────────────────────

    private static DataTable ExecuteDataTableInternal(string connStr, string sql,
        CommandType cmdType, MySqlParameter[] parameters)
    {
        var dt = new DataTable();
        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandType = cmdType;
                AddParams(cmd, parameters);
                using (var da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        return dt;
    }

    private static T ExecuteScalarInternal<T>(string connStr, string sql,
        CommandType cmdType, MySqlParameter[] parameters)
    {
        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandType = cmdType;
                AddParams(cmd, parameters);
                object result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value)
                    return default(T);
                return (T)Convert.ChangeType(result, typeof(T));
            }
        }
    }

    private static int ExecuteNonQueryInternal(string connStr, string sql,
        CommandType cmdType, MySqlParameter[] parameters)
    {
        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandType = cmdType;
                AddParams(cmd, parameters);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private static void AddParams(MySqlCommand cmd, MySqlParameter[] parameters)
    {
        if (parameters == null) return;
        foreach (var p in parameters)
        {
            // Avoid duplicate parameter names (e.g. when reusing arrays)
            if (!cmd.Parameters.Contains(p.ParameterName))
                cmd.Parameters.Add(p);
        }
    }

    private static MySqlParameter[] CloneParameters(MySqlParameter[] source)
    {
        if (source == null) return null;
        var cloned = new MySqlParameter[source.Length];
        for (int i = 0; i < source.Length; i++)
        {
            cloned[i] = new MySqlParameter(source[i].ParameterName, source[i].Value);
        }
        return cloned;
    }
}

/// <summary>
/// Result container for paged queries.
/// </summary>
public class PagedResult
{
    public DataTable Data { get; set; }
    public long TotalRows { get; set; }
    public int TotalPages { get; set; }
    public int PageIndex { get; set; }
    public int PageSize { get; set; }

    public long ShowFrom { get { return TotalRows > 0 ? (long)(PageIndex * PageSize) + 1 : 0; } }
    public long ShowTo { get { return Math.Min((long)((PageIndex + 1) * PageSize), TotalRows); } }
}
