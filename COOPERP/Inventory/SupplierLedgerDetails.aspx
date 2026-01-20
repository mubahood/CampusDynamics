<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SupplierLedgerDetails.aspx.cs" Inherits="COOPERP_Inventory_SupplierLedgerDetails" %>

<%@ Register src="../../UserControls/Inventory/SupplierLedger.ascx" tagname="SupplierLedger" tagprefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:SupplierLedger ID="SupplierLedger1" runat="server" />
    
    </div>
    </form>
</body>
</html>
