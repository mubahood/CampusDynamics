<%@ Page Language="C#" AutoEventWireup="true" CodeFile="JournalTypes.aspx.cs" Inherits="COOPERP_accounts_JournalTypes" %>

<%@ Register src="../../UserControls/Accounts/journalTypes.ascx" tagname="journalTypes" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <uc1:journalTypes ID="journalTypes1" runat="server" />
    
    </div>
    </form>
</body>
</html>
