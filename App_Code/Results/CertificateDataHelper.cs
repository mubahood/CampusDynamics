using System;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// Helper class to ensure certificate/transcript data is populated correctly.
/// Provides a fallback mechanism when the stored procedure returns incomplete data
/// (0 rows due to JOIN failures, or rows with NULL student names).
/// </summary>
public static class CertificateDataHelper
{
    /// <summary>
    /// Ensures certificate/transcript data is populated for a single student.
    /// If the stored procedure returned 0 rows or returned rows with missing studnm,
    /// this method fills in the data from acad_graduands and acad_student directly.
    /// </summary>
    public static void EnsureSingleStudentData(ResultsData DS, string regno)
    {
        try
        {
            DataTable dt = DS.acad_GetBatchStudentTranscriptData;

            // Case 1: SP returned 0 rows — need to build a row from scratch
            if (dt.Rows.Count == 0)
            {
                string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    string sql = @"SELECT 
                        IFNULL(g.degclass, '') AS deg,
                        IFNULL((SELECT f.faculty_name FROM acad_faculty f JOIN acad_programme p ON p.faculty_code = f.faculty_code WHERE p.progcode = g.progcode LIMIT 1), '') AS fax,
                        IFNULL(DATE_FORMAT(s.Birth_date, '%d %M, %Y'), '') AS dobs,
                        IFNULL(s.nationality, '') AS nat,
                        IFNULL(g.gender, '') AS gen,
                        IFNULL(g.cgpa, 0) AS cgpa,
                        IFNULL((SELECT p.progname FROM acad_programme p WHERE p.progcode = g.progcode LIMIT 1), '') AS prog,
                        IFNULL(NULLIF(TRIM(CONCAT(IFNULL(s.firstname, ''), ' ', IFNULL(s.othername, ''))), ''), IFNULL(g.stud_name, '')) AS studnm,
                        IFNULL(s.photo, '') AS photo,
                        TRIM(g.regno) AS regno,
                        IFNULL(s.entryno, '') AS entryno,
                        IFNULL(DATE_FORMAT(g.grad_date, '%D %M, %Y'), '') AS formated_grad_date,
                        g.grad_date,
                        g.comp_date,
                        IFNULL(DATE_FORMAT(g.comp_date, '%D %M, %Y'), '') AS formated_comp_date,
                        IFNULL(g.convocation, '') AS convocation
                        FROM acad_graduands g
                        LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(g.regno)
                        WHERE TRIM(g.regno) = @reg
                        LIMIT 1";

                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@reg", regno);
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                DataRow row = dt.NewRow();
                                row["deg"] = reader["deg"];
                                row["fax"] = reader["fax"];
                                row["dobs"] = reader["dobs"];
                                row["nat"] = reader["nat"];
                                row["gen"] = reader["gen"];
                                row["cgpa"] = Convert.ToDouble(reader["cgpa"]);
                                row["prog"] = reader["prog"];
                                row["studnm"] = reader["studnm"];
                                row["photo"] = reader["photo"];
                                row["regno"] = reader["regno"];
                                row["entryno"] = reader["entryno"];
                                row["formated_grad_date"] = reader["formated_grad_date"];
                                row["formated_comp_date"] = reader["formated_comp_date"];
                                row["convocation"] = reader["convocation"];
                                if (reader["grad_date"] != DBNull.Value)
                                    row["grad_date"] = reader["grad_date"];
                                if (reader["comp_date"] != DBNull.Value)
                                    row["comp_date"] = reader["comp_date"];
                                dt.Rows.Add(row);
                            }
                        }
                    }
                }
            }
            // Case 2: SP returned rows but studnm is empty — patch it
            else
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    object studnmVal = dt.Rows[i]["studnm"];
                    if (studnmVal == null || studnmVal == DBNull.Value || string.IsNullOrEmpty(studnmVal.ToString().Trim()))
                    {
                        string regVal = dt.Rows[i]["regno"] != null && dt.Rows[i]["regno"] != DBNull.Value
                            ? dt.Rows[i]["regno"].ToString().Trim() : regno;
                        string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
                        using (MySqlConnection conn = new MySqlConnection(connStr))
                        {
                            conn.Open();
                            string sql = @"SELECT IFNULL(NULLIF(TRIM(CONCAT(IFNULL(s.firstname, ''), ' ', IFNULL(s.othername, ''))), ''), 
                                          IFNULL(g.stud_name, '')) AS studnm 
                                          FROM acad_graduands g LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(g.regno) 
                                          WHERE TRIM(g.regno) = @reg LIMIT 1";
                            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                            {
                                cmd.Parameters.AddWithValue("@reg", regVal);
                                object result = cmd.ExecuteScalar();
                                if (result != null && result != DBNull.Value && !string.IsNullOrEmpty(result.ToString().Trim()))
                                    dt.Rows[i]["studnm"] = result.ToString().Trim();
                            }
                        }
                    }
                }
            }
        }
        catch (Exception)
        {
            // Fallback silently fails — certificate will print with whatever data the SP returned
        }
    }
}
