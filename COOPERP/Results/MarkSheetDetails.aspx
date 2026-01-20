<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MarkSheetDetails.aspx.cs" Inherits="COOPERP_Results_MarkSheetDetails" %>

<%@ Register src="../../UserControls/Results/MarksheetDetails.ascx" tagname="MarksheetDetails" tagprefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:MarksheetDetails ID="MarksheetDetails1" runat="server" />
    
    </div>
    </form>
</body>
</html>
