<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ResearchMarkSheetDetails.aspx.cs" Inherits="COOPERP_Results_ResearchMarkSheetDetails" %>

<%@ Register Src="~/UserControls/Results/ResearchMarkSheetDetails.ascx" TagPrefix="uc1" TagName="ResearchMarkSheetDetails" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <uc1:ResearchMarkSheetDetails runat="server" id="ResearchMarkSheetDetails" />
    </div>
    </form>
</body>
</html>
