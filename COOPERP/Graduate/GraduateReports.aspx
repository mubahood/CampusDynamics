<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GraduateReports.aspx.cs" Inherits="COOPERP_Graduate_GraduateReports" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxDocumentViewer ID="gradReportDV" runat="server" ToolbarMode="Ribbon">
            <SettingsReportViewer EnableRequestParameters="False" PrintUsingAdobePlugIn="False" />
            <SettingsSplitter ParametersPanelCollapsed="True" />
        </dx:ASPxDocumentViewer>
    
    </div>
    </form>
</body>
</html>
