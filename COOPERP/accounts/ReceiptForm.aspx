<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="ReceiptForm.aspx.cs" Inherits="COOPERP_accounts_ReceiptForm" %>

<%@ Register src="../../UserControls/Accounts/ReceiptForm.ascx" tagname="ReceiptForm" tagprefix="uc1" %>

<%@ Register src="../../UserControls/Accounts/ReceiptCentre.ascx" tagname="ReceiptCentre" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc2:ReceiptCentre ID="ReceiptCentre1" runat="server" />
</asp:Content>

