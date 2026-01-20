<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="StudentLedgerCentre.aspx.cs" Inherits="COOPERP_financials_StudentLedgerCentre" %>

<%@ Register src="../../UserControls/financials/StudentLedgerCentre.ascx" tagname="StudentLedgerCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:StudentLedgerCentre ID="StudentLedgerCentre1" runat="server" />
</asp:Content>

