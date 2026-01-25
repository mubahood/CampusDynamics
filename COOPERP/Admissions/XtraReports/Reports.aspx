<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Reports.aspx.cs" Inherits="COOPERP_Admissions_XtraReports_Reports" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .style1
        {
            width: 100%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <table class="style1">
            <tr>
                <td>
                    <dx:ASPxDocumentViewer ID="rp_viewer" runat="server" Height = "500px">
                        <SettingsSplitter SidePaneVisible="False" />
                    </dx:ASPxDocumentViewer>
                </td>
            </tr>
            <tr>
                <td>
                    <dx:ASPxLabel ID="lbl_response" runat="server" ForeColor="Red">
                    </dx:ASPxLabel>
                </td>
            </tr>
        </table>
    
    </div>
    </form>
</body>
</html>
