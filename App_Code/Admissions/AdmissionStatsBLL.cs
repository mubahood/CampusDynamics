using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;

/// <summary>
/// BLL wrapper for admission statistics stored procedures that contain INT variables
/// assigned from campus-code columns (e.g. 'MAIN'). MySQL strict mode rejects these
/// implicit string-to-INT coercions. We open the connection ourselves, clear sql_mode
/// for the session, then call the SP — bypassing the typed adapter's connection
/// management which would open a fresh (strict-mode) connection for Fill().
/// </summary>
[System.ComponentModel.DataObject]
public class AdmissionStatsBLL
{
    private static DataTable CallProc(string sql, params MySqlParameter[] prms)
    {
        string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        var dt = new DataTable();
        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();
            // Clear strict mode for this session so SP INT variables accept string campus codes
            using (var m = new MySqlCommand("SET SESSION sql_mode = ''", conn))
                m.ExecuteNonQuery();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                if (prms != null)
                    foreach (var p in prms) cmd.Parameters.Add(p);
                using (var da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        return dt;
    }

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public DataTable GetConversionRate(string acad, string typ)
    {
        return CallProc("CALL `acad_GetConversionRate`(@acad, @typ)",
            new MySqlParameter("@acad", acad ?? ""),
            new MySqlParameter("@typ",  typ  ?? "All"));
    }

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public DataTable GetAdmissionStatistics(string camp, string acad_year, string analysisType, string statYear, string EndYear)
    {
        return CallProc("CALL `acad_AdmissionStatistics`(@camp, @acad_year, @analysisType, @statYear, @endYear)",
            new MySqlParameter("@camp",         camp         ?? ""),
            new MySqlParameter("@acad_year",    acad_year    ?? ""),
            new MySqlParameter("@analysisType", analysisType ?? ""),
            new MySqlParameter("@statYear",     statYear     ?? ""),
            new MySqlParameter("@endYear",      EndYear      ?? ""));
    }
}
