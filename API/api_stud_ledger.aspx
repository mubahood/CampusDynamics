<%@ Page Language="C#" AutoEventWireup="true" CodeFile="api_stud_ledger.aspx.cs" Inherits="API_api_stud_ledger" %>

<%@ Register src="../UserControls/financials/api_stud_ledger.ascx" tagname="api_stud_ledger" tagprefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:api_stud_ledger ID="api_stud_ledger1" runat="server" />
    
    </div>
    </form>
</body>
</html>
