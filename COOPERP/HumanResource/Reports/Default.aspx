<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_examinations_Reports_Default" %>

<%@ Register assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" namespace="CrystalDecisions.Web" tagprefix="CR" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Printing Form</title>
    <style type="text/css">
        .style1
        {
            width: 100%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <table class="style1">
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Reports" 
                    Width="100%">
                    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
   
                        <CR:CrystalReportViewer ID="myReportsViewer" runat="server" AutoDataBind="True" 
                            GroupTreeImagesFolderUrl="" ToolbarImagesFolderUrl="" 
                            ToolPanelWidth="200px" HasToggleGroupTreeButton="false" 
                            EnableDatabaseLogonPrompt="False" ToolPanelView="None" onunload="myReports_Unload" OnDisposed="myReports_Unload" />
   
                        </dx:PanelContent>
</PanelCollection>
                </dx:ASPxRoundPanel>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
    </table>
    <div>
    
    </div>
    </form>
</body>
</html>
