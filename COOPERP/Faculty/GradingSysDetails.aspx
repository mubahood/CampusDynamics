<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GradingSysDetails.aspx.cs" Inherits="COOPERP_Faculty_GradingSysDetails" %>

<%@ Register src="../../UserControls/Faculty/GradindDetails.ascx" tagname="GradindDetails" tagprefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:GradindDetails ID="GradindDetails1" runat="server" />
    
    </div>
    </form>
</body>
</html>
