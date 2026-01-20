using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Security_FileManager : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void ASPxFileManager1_FileUploading(object source, DevExpress.Web.FileManagerFileUploadEventArgs e)
    {
        var existFile = fm_systemfiles.SelectedFolder.GetFiles().FirstOrDefault(f => f.Name.Equals(e.FileName, StringComparison.InvariantCultureIgnoreCase));
        if (existFile != null)
            File.Delete(Path.Combine(MapPath("~"), existFile.RelativeName)); // A path depends on the RootFolder in the file manager
       
    }
}