<%@ Page Language="C#" AutoEventWireup="true" CodeFile="billitems.aspx.cs" Inherits="COOPERP_financials_billitems" %>

<%@ Register src="../../UserControls/financials/billitems.ascx" tagname="billitems" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:billitems ID="billitems1" runat="server" />
    
    </div>
    </form>
</body>
</html>
