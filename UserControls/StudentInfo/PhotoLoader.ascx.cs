using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_PhotoLoader : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdSavePhotos_Click(object sender, EventArgs e)
    {
        int noRows = gvStudentPhoto.VisibleRowCount;
        StudentDataTableAdapters.stddocTableAdapter STUD = new StudentDataTableAdapters.stddocTableAdapter();
        DataTable dt = STUD.GetData(txtDocType.Value.ToString());
        dt.Columns.AddRange(new DataColumn[2] { 
        new DataColumn("RegNo", typeof(string)),
        new DataColumn("photo",typeof(byte[]))});
        
        for (int i = 0; i < noRows; i++)
        {
            if (gvStudentPhoto.Selection.IsRowSelected(i))
            {
                File.WriteAllBytes(Server.MapPath("~/COOPERP/StudentInfo/photos/" + gvStudentPhoto.GetRowValues(i, "docbioid") + ".jpg"), (byte[])gvStudentPhoto.GetRowValues(i, "docblob"));
            }
        }
    }
    protected void gvStudentPhoto_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}