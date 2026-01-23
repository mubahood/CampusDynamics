using System;
using System.Web.UI;
using System.Configuration;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_NewProgrammeCourses : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvMain.AddNewRow();
    }

    protected void gvMain_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["study_year"] = 1;
        e.NewValues["semester"] = 1;
    }

    protected void gvMain_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        string progCode = e.NewValues["progcode"] != null ? e.NewValues["progcode"].ToString() : "";
        string courseCode = e.NewValues["course_code"] != null ? e.NewValues["course_code"].ToString() : "";
        int curriculumId = e.NewValues["CurriculumID"] != null ? Convert.ToInt32(e.NewValues["CurriculumID"]) : 0;
        int year = e.NewValues["study_year"] != null ? Convert.ToInt32(e.NewValues["study_year"]) : 0;
        int semester = e.NewValues["semester"] != null ? Convert.ToInt32(e.NewValues["semester"]) : 0;
        
        if (IsDuplicate(progCode, courseCode, curriculumId, year, semester, 0))
        {
            e.Cancel = true;
            throw new Exception("This course already exists for this programme/curriculum/year/semester.");
        }
    }

    protected void gvMain_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        string progCode = e.NewValues["progcode"] != null ? e.NewValues["progcode"].ToString() : "";
        string courseCode = e.NewValues["course_code"] != null ? e.NewValues["course_code"].ToString() : "";
        int curriculumId = e.NewValues["CurriculumID"] != null ? Convert.ToInt32(e.NewValues["CurriculumID"]) : 0;
        int year = e.NewValues["study_year"] != null ? Convert.ToInt32(e.NewValues["study_year"]) : 0;
        int semester = e.NewValues["semester"] != null ? Convert.ToInt32(e.NewValues["semester"]) : 0;
        
        if (IsDuplicate(progCode, courseCode, curriculumId, year, semester, id))
        {
            e.Cancel = true;
            throw new Exception("This course already exists for this programme/curriculum/year/semester.");
        }
    }

    protected void gvMain_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
    }

    private bool IsDuplicate(string progCode, string courseCode, int curriculumId, int year, int semester, int excludeId)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT COUNT(*) FROM acad_programmecourses WHERE progcode = @progcode AND course_code = @course_code AND CurriculumID = @curriculumId AND study_year = @year AND semester = @semester";
            if (excludeId > 0)
            {
                sql += " AND ID != @excludeId";
            }
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@progcode", progCode);
                cmd.Parameters.AddWithValue("@course_code", courseCode);
                cmd.Parameters.AddWithValue("@curriculumId", curriculumId);
                cmd.Parameters.AddWithValue("@year", year);
                cmd.Parameters.AddWithValue("@semester", semester);
                if (excludeId > 0)
                {
                    cmd.Parameters.AddWithValue("@excludeId", excludeId);
                }
                
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                return count > 0;
            }
        }
    }

    protected void gvMain_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.Exception != null)
        {
            e.ErrorText = e.Exception.Message;
        }
    }
}
