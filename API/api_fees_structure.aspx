<%@ Page Language="C#" AutoEventWireup="true" CodeFile="api_fees_structure.aspx.cs" Inherits="API_api_fees_structure" %>

<%@ Register src="../UserControls/financials/api_fees_structure.ascx" tagname="api_fees_structure" tagprefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <uc1:api_fees_structure ID="api_fees_structure1" runat="server" />
    
    </div>
    </form>
</body>
</html>
