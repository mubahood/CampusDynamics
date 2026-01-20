<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PrintCentre.aspx.cs" Inherits="COOPERP_Results_Reports_PrintCentre" %>

<%@ Register assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" namespace="CrystalDecisions.Web" tagprefix="CR" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <CR:CrystalReportViewer ID="CRV_Results" runat="server" AutoDataBind="true" EnableDatabaseLogonPrompt="False" EnableParameterPrompt="False" ToolPanelView="None" OnDisposed="CRV_Results_Disposed" OnUnload="CRV_Results_Unload" />
    
    </div>
    </form>
</body>
</html>
