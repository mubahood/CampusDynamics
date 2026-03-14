using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;

/// <summary>
/// API v2 Helper — Standard response formatting, token auth, and database utilities.
/// Place this file in App_Code so it's auto-compiled.
/// </summary>
public static class ApiHelper
{
    private static readonly JavaScriptSerializer _serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

    #region Response Helpers

    /// <summary>Sends a standard JSON success response and ends the request.</summary>
    public static void Success(HttpResponse response, object data, string message = "OK")
    {
        // Prevent duplicate responses (e.g. if a previous Error/Success already completed the request)
        if (HttpContext.Current != null && HttpContext.Current.Items.Contains("_api_response_sent")) return;

        WriteJson(response, new Dictionary<string, object>
        {
            { "success", true },
            { "message", message },
            { "data", data },
            { "timestamp", DateTime.UtcNow.ToString("o") }
        });
    }

    /// <summary>Sends a standard JSON error response and ends the request.</summary>
    public static void Error(HttpResponse response, string message, string errorCode = "SERVER_ERROR", int httpStatus = 200)
    {
        // Prevent duplicate responses (e.g. if a previous Error/Success already completed the request)
        if (HttpContext.Current != null && HttpContext.Current.Items.Contains("_api_response_sent")) return;

        WriteJson(response, new Dictionary<string, object>
        {
            { "success", false },
            { "message", message },
            { "error_code", errorCode },
            { "data", null },
            { "timestamp", DateTime.UtcNow.ToString("o") }
        });
    }

    private static void WriteJson(HttpResponse response, object obj)
    {
        response.Clear();
        response.ContentType = "application/json";
        response.Charset = "utf-8";
        // Allow cross-origin requests for mobile apps
        response.AddHeader("Access-Control-Allow-Origin", "*");
        response.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        response.AddHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.Write(_serializer.Serialize(obj));

        // Mark response as sent so duplicate Error/Success calls are suppressed
        if (HttpContext.Current != null)
            HttpContext.Current.Items["_api_response_sent"] = true;

        // Use Flush + CompleteRequest instead of Response.End() to avoid ThreadAbortException
        response.Flush();
        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    #endregion

    #region DataTable to Object Conversion

    /// <summary>Converts a DataTable to a List of Dictionaries for JSON serialization.</summary>
    public static List<Dictionary<string, object>> TableToList(DataTable dt)
    {
        var rows = new List<Dictionary<string, object>>();
        if (dt == null) return rows;
        foreach (DataRow dr in dt.Rows)
        {
            var row = new Dictionary<string, object>();
            foreach (DataColumn col in dt.Columns)
            {
                object val = dr[col];
                if (val is DBNull) val = null;
                row[col.ColumnName] = val;
            }
            rows.Add(row);
        }
        return rows;
    }

    /// <summary>Converts first row of DataTable to a Dictionary. Returns null if empty.</summary>
    public static Dictionary<string, object> FirstRowToDict(DataTable dt)
    {
        if (dt == null || dt.Rows.Count == 0) return null;
        var row = new Dictionary<string, object>();
        DataRow dr = dt.Rows[0];
        foreach (DataColumn col in dt.Columns)
        {
            object val = dr[col];
            if (val is DBNull) val = null;
            row[col.ColumnName] = val;
        }
        return row;
    }

    #endregion

    #region Database Helpers

    /// <summary>Gets a MySQL connection using the vacConnectionString.</summary>
    public static MySqlConnection GetConnection()
    {
        string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        return new MySqlConnection(connStr);
    }

    /// <summary>Gets a MySQL connection for the portal database.</summary>
    public static MySqlConnection GetPortalConnection()
    {
        string connStr = ConfigurationManager.ConnectionStrings["campus_dynamics_portalConnectionString"].ConnectionString;
        return new MySqlConnection(connStr);
    }

    /// <summary>Gets a MySQL connection for the accounts database.</summary>
    public static MySqlConnection GetAccountsConnection()
    {
        string connStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString;
        return new MySqlConnection(connStr);
    }

    /// <summary>Executes a query and returns a DataTable.</summary>
    public static DataTable Query(string sql, params MySqlParameter[] parameters)
    {
        using (var conn = GetConnection())
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                if (parameters != null)
                {
                    foreach (var p in parameters)
                        cmd.Parameters.Add(p);
                }
                using (var adapter = new MySqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }
    }

    /// <summary>Executes a query against the accounts database and returns a DataTable.</summary>
    public static DataTable QueryAccounts(string sql, params MySqlParameter[] parameters)
    {
        using (var conn = GetAccountsConnection())
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                if (parameters != null)
                {
                    foreach (var p in parameters)
                        cmd.Parameters.Add(p);
                }
                using (var adapter = new MySqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }
    }

    /// <summary>Executes a stored procedure and returns a DataTable.</summary>
    public static DataTable QueryProc(string procName, params MySqlParameter[] parameters)
    {
        using (var conn = GetConnection())
        {
            conn.Open();
            using (var cmd = new MySqlCommand(procName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 60;
                if (parameters != null)
                {
                    foreach (var p in parameters)
                        cmd.Parameters.Add(p);
                }
                using (var adapter = new MySqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }
    }

    /// <summary>Executes a non-query command (INSERT, UPDATE, DELETE).</summary>
    public static int Execute(string sql, params MySqlParameter[] parameters)
    {
        using (var conn = GetConnection())
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                if (parameters != null)
                {
                    foreach (var p in parameters)
                        cmd.Parameters.Add(p);
                }
                return cmd.ExecuteNonQuery();
            }
        }
    }

    /// <summary>Executes a scalar query and returns the result.</summary>
    public static object Scalar(string sql, params MySqlParameter[] parameters)
    {
        using (var conn = GetConnection())
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                if (parameters != null)
                {
                    foreach (var p in parameters)
                        cmd.Parameters.Add(p);
                }
                return cmd.ExecuteScalar();
            }
        }
    }

    #endregion

    #region Request Helpers

    /// <summary>Gets a required parameter from the request. Sends error if missing.</summary>
    public static string RequireParam(HttpRequest request, HttpResponse response, string name)
    {
        string val = request[name];
        if (string.IsNullOrEmpty(val))
        {
            Error(response, "Missing required parameter: " + name, "MISSING_PARAM");
            return null; // will never reach here because Error calls Response.End()
        }
        return val;
    }

    /// <summary>Gets an optional parameter from the request with a default value.</summary>
    public static string Param(HttpRequest request, string name, string defaultValue = "")
    {
        string val = request[name];
        return string.IsNullOrEmpty(val) ? defaultValue : val;
    }

    /// <summary>Gets an optional integer parameter.</summary>
    public static int ParamInt(HttpRequest request, string name, int defaultValue = 0)
    {
        string val = request[name];
        int result;
        return int.TryParse(val, out result) ? result : defaultValue;
    }

    #endregion

    #region Security Helpers

    /// <summary>Generates a secure random token string.</summary>
    public static string GenerateToken()
    {
        byte[] tokenBytes = new byte[32];
        using (var rng = new RNGCryptoServiceProvider())
        {
            rng.GetBytes(tokenBytes);
        }
        return Convert.ToBase64String(tokenBytes).Replace("+", "").Replace("/", "").Replace("=", "");
    }

    /// <summary>Hashes a password using SHA256 (matches the portal's approach).</summary>
    public static string HashPassword(string password)
    {
        using (var sha = SHA256.Create())
        {
            byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
            var sb = new StringBuilder();
            foreach (byte b in bytes)
                sb.Append(b.ToString("x2"));
            return sb.ToString();
        }
    }

    /// <summary>Handles CORS preflight OPTIONS requests.</summary>
    public static bool HandleCors(HttpRequest request, HttpResponse response)
    {
        response.AddHeader("Access-Control-Allow-Origin", "*");
        response.AddHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS");
        response.AddHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        if (request.HttpMethod == "OPTIONS")
        {
            response.StatusCode = 200;
            CompleteResponse(response);
            return true;
        }
        return false;
    }

    /// <summary>
    /// Ends the response safely without throwing ThreadAbortException.
    /// Use this instead of Response.End() for binary or non-JSON responses.
    /// </summary>
    public static void CompleteResponse(HttpResponse response)
    {
        if (HttpContext.Current != null)
            HttpContext.Current.Items["_api_response_sent"] = true;
        response.Flush();
        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    #endregion
}
