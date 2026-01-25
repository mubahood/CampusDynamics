<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Accounting_Reports_Default" %>

<%@ Register assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" namespace="CrystalDecisions.Web" tagprefix="CR" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Printing Centre:</title>
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
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Printing Centre:" ShowHeader="False" Width="100%">
            <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <CR:CrystalReportViewer ID="financeReportViewer" runat="server" 
                    AutoDataBind="True" GroupTreeImagesFolderUrl="" OnUnload="myReports_Unload" 
                    ToolbarImagesFolderUrl="" ToolPanelView="None" ToolPanelWidth="200px" />
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxLabel ID="lbl_comments" runat="server" ForeColor="Red">
                </dx:ASPxLabel>
            </td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
