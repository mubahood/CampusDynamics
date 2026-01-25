<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ReschProgressTracking.aspx.cs" Inherits="COOPERP_Graduate_ReschProgressTracking" %>

<%@ Register src="../../UserControls/Graduate/ReschProgressTracking.ascx" tagname="ReschProgressTracking" tagprefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:ReschProgressTracking ID="ReschProgressTracking1" runat="server" />
    
    </div>
    </form>
</body>
</html>
