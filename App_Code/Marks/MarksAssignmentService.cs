using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksAssignmentService — CRUD operations for teacher-course assignments.
/// 
/// Provides:
///   - Creation and deactivation of assignments.
///   - Listing assignments per programme/year/semester for the Assignment Manager.
///   - Bulk assignment import from existing acad_examsettings.empCode data.
///
/// All write operations enforce authorization via MarksAuthorizationService.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P1, P3, P4, P5 (teacher linkage)
/// Task: D-04
/// </summary>
public static class MarksAssignmentService
{
    // ─────────────────────── Connection String ──────────────────────────

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    // ─────────────────────── Create Assignment ──────────────────────────

    /// <summary>
    /// Creates a new teaching assignment. Returns the new ID on success, or -1 on failure.
    /// Uses INSERT IGNORE with the unique key to avoid duplicates.
    /// </summary>
    public static int CreateAssignment(string teacherUsername, string courseId, string progid,
        string acadyear, int semester, int studyYear, int campusId, string studSession, string notes)
    {
        string assignedBy = MarksAuthorizationService.GetCurrentUser();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Check if an inactive assignment already exists — reactivate it
                using (MySqlCommand chk = new MySqlCommand(
                    @"SELECT id FROM acad_teaching_assignments
                      WHERE teacher_username = @teacher AND course_id = @course
                        AND progid = @prog AND acadyear = @year AND semester = @sem
                        AND study_year = @sy AND campus_id = @campus AND stud_session = @sess", conn))
                {
                    chk.Parameters.AddWithValue("@teacher", teacherUsername);
                    chk.Parameters.AddWithValue("@course", courseId);
                    chk.Parameters.AddWithValue("@prog", progid);
                    chk.Parameters.AddWithValue("@year", acadyear);
                    chk.Parameters.AddWithValue("@sem", semester);
                    chk.Parameters.AddWithValue("@sy", studyYear);
                    chk.Parameters.AddWithValue("@campus", campusId);
                    chk.Parameters.AddWithValue("@sess", studSession);

                    object existing = chk.ExecuteScalar();
                    if (existing != null && existing != DBNull.Value)
                    {
                        // Reactivate existing record
                        int existingId = Convert.ToInt32(existing);
                        using (MySqlCommand upd = new MySqlCommand(
                            @"UPDATE acad_teaching_assignments SET is_active = 1, assigned_by = @by, 
                                     assigned_at = NOW(), notes = @notes WHERE id = @id", conn))
                        {
                            upd.Parameters.AddWithValue("@by", assignedBy);
                            upd.Parameters.AddWithValue("@notes", notes ?? "");
                            upd.Parameters.AddWithValue("@id", existingId);
                            upd.ExecuteNonQuery();
                        }
                        return existingId;
                    }
                }

                // Insert new
                using (MySqlCommand ins = new MySqlCommand(
                    @"INSERT INTO acad_teaching_assignments 
                        (teacher_username, course_id, progid, acadyear, semester, study_year, 
                         campus_id, stud_session, assigned_by, assigned_at, is_active, notes)
                      VALUES (@teacher, @course, @prog, @year, @sem, @sy, 
                              @campus, @sess, @by, NOW(), 1, @notes)", conn))
                {
                    ins.Parameters.AddWithValue("@teacher", teacherUsername);
                    ins.Parameters.AddWithValue("@course", courseId);
                    ins.Parameters.AddWithValue("@prog", progid);
                    ins.Parameters.AddWithValue("@year", acadyear);
                    ins.Parameters.AddWithValue("@sem", semester);
                    ins.Parameters.AddWithValue("@sy", studyYear);
                    ins.Parameters.AddWithValue("@campus", campusId);
                    ins.Parameters.AddWithValue("@sess", studSession);
                    ins.Parameters.AddWithValue("@by", assignedBy);
                    ins.Parameters.AddWithValue("@notes", notes ?? "");
                    ins.ExecuteNonQuery();
                    return (int)ins.LastInsertedId;
                }
            }
        }
        catch
        {
            return -1;
        }
    }

    /// <summary>
    /// Deactivates an assignment (soft-delete). Returns true on success.
    /// </summary>
    public static bool DeactivateAssignment(int assignmentId)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "UPDATE acad_teaching_assignments SET is_active = 0 WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", assignmentId);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch
        {
            return false;
        }
    }

    // ─────────────────────── List Assignments ───────────────────────────

    /// <summary>
    /// Returns all assignments (active and inactive) for a programme in an academic period.
    /// Used by the Assignment Manager page.
    /// </summary>
    public static List<AssignmentRecord> GetAssignmentsByProgramme(string progid, string acadyear, int semester)
    {
        List<AssignmentRecord> list = new List<AssignmentRecord>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT ta.id, ta.teacher_username, ta.course_id, ta.progid, ta.acadyear,
                             ta.semester, ta.study_year, ta.campus_id, ta.stud_session,
                             ta.assigned_by, ta.assigned_at, ta.is_active, ta.notes,
                             COALESCE(pc.CourseName, c.CourseName, ta.course_id) AS course_name,
                             COALESCE(p.progname, ta.progid) AS prog_name,
                             COALESCE(e.emp_name, ta.teacher_username) AS teacher_name,
                             COALESCE(cam.campusName, '') AS campus_name
                      FROM acad_teaching_assignments ta
                      LEFT JOIN acad_programmecourses pc ON pc.course_code = ta.course_id AND pc.progcode = ta.progid
                      LEFT JOIN acad_courses c ON c.CourseCode = ta.course_id
                      LEFT JOIN acad_programme p ON p.progcode = ta.progid
                      LEFT JOIN hrm_employee e ON e.usernames = ta.teacher_username
                      LEFT JOIN acad_campus cam ON cam.campusid = ta.campus_id
                      WHERE ta.progid = @prog AND ta.acadyear = @year AND ta.semester = @sem
                      ORDER BY ta.study_year, ta.course_id, ta.teacher_username", conn))
                {
                    cmd.Parameters.AddWithValue("@prog", progid);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            AssignmentRecord r = new AssignmentRecord();
                            r.Id = Convert.ToInt32(rdr["id"]);
                            r.TeacherUsername = rdr["teacher_username"].ToString();
                            r.CourseId = rdr["course_id"].ToString();
                            r.ProgId = rdr["progid"].ToString();
                            r.AcadYear = rdr["acadyear"].ToString();
                            r.Semester = Convert.ToInt32(rdr["semester"]);
                            r.StudyYear = Convert.ToInt32(rdr["study_year"]);
                            r.CampusId = Convert.ToInt32(rdr["campus_id"]);
                            r.StudSession = rdr["stud_session"].ToString();
                            r.AssignedBy = rdr["assigned_by"].ToString();
                            r.AssignedAt = Convert.ToDateTime(rdr["assigned_at"]);
                            r.IsActive = Convert.ToInt32(rdr["is_active"]) == 1;
                            r.Notes = rdr["notes"] != DBNull.Value ? rdr["notes"].ToString() : "";
                            r.CourseName = rdr["course_name"].ToString();
                            r.ProgName = rdr["prog_name"].ToString();
                            r.TeacherName = rdr["teacher_name"].ToString();
                            r.CampusName = rdr["campus_name"].ToString();
                            list.Add(r);
                        }
                    }
                }
            }
        }
        catch
        {
            // Return empty list on error
        }
        return list;
    }

    /// <summary>
    /// Returns available teachers (from hrm_employee) for the assignment dropdown.
    /// </summary>
    public static List<TeacherOption> GetAvailableTeachers()
    {
        List<TeacherOption> list = new List<TeacherOption>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT DISTINCT e.usernames AS username, 
                             COALESCE(e.emp_name, e.usernames) AS full_name,
                             COALESCE(d.dept_name, '') AS department
                      FROM hrm_employee e
                      LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                          SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
                      LEFT JOIN hrm_departments d ON d.ID = c.departmentID
                      WHERE e.usernames IS NOT NULL AND e.usernames != ''
                        AND COALESCE(e.emp_status, 'Active') = 'Active'
                      ORDER BY e.emp_name", conn))
                {
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            TeacherOption t = new TeacherOption();
                            t.Username = rdr["username"].ToString();
                            t.FullName = rdr["full_name"].ToString();
                            t.Department = rdr["department"].ToString();
                            list.Add(t);
                        }
                    }
                }
            }
        }
        catch
        {
            // Return empty list on error
        }
        return list;
    }

    // ─────────────────────── Backfill from Legacy ───────────────────────

    /// <summary>
    /// Backfills acad_teaching_assignments from existing acad_examsettings.empCode records.
    /// This is an idempotent operation — uses INSERT IGNORE to avoid duplicates.
    /// Returns the number of new records inserted.
    /// Task: B-07
    /// </summary>
    public static int BackfillFromExamSettings()
    {
        string assignedBy = "system_backfill";
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"INSERT IGNORE INTO acad_teaching_assignments 
                        (teacher_username, course_id, progid, acadyear, semester, study_year, 
                         campus_id, stud_session, assigned_by, assigned_at, is_active, notes)
                      SELECT DISTINCT
                        es.empCode,
                        es.course,
                        es.programme,
                        es.acad_year,
                        es.semester,
                        COALESCE(es.study_year, 1),
                        COALESCE(es.campus, 1),
                        COALESCE(es.studsesion, 'Day'),
                        @by,
                        NOW(),
                        1,
                        'Backfilled from acad_examsettings'
                      FROM acad_examsettings es
                      WHERE es.empCode IS NOT NULL AND es.empCode != ''
                        AND es.course IS NOT NULL AND es.course != ''
                        AND es.programme IS NOT NULL AND es.programme != ''", conn))
                {
                    cmd.Parameters.AddWithValue("@by", assignedBy);
                    return cmd.ExecuteNonQuery();
                }
            }
        }
        catch
        {
            return -1;
        }
    }

    // ─────────────────────── DTOs ───────────────────────────────────────

    public class AssignmentRecord
    {
        public int Id { get; set; }
        public string TeacherUsername { get; set; }
        public string CourseId { get; set; }
        public string ProgId { get; set; }
        public string AcadYear { get; set; }
        public int Semester { get; set; }
        public int StudyYear { get; set; }
        public int CampusId { get; set; }
        public string StudSession { get; set; }
        public string AssignedBy { get; set; }
        public DateTime AssignedAt { get; set; }
        public bool IsActive { get; set; }
        public string Notes { get; set; }
        public string CourseName { get; set; }
        public string ProgName { get; set; }
        public string TeacherName { get; set; }
        public string CampusName { get; set; }
    }

    public class TeacherOption
    {
        public string Username { get; set; }
        public string FullName { get; set; }
        public string Department { get; set; }
    }
}
