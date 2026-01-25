<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentReceiptDetails.aspx.cs" Inherits="COOPERP_accounts_ReceiptDetails" %>

<%@ Register src="../../UserControls/Accounts/StudentReceiptDetails.ascx" tagname="ReceiptDetails" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:ReceiptDetails ID="ReceiptDetails1" runat="server" />
    
    </div>
    </form>
</body>
</html>
