<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="StudentAccess.aspx.cs" Inherits="COOPERP_financials_StudentAccess" %>

<%@ Register src="../../UserControls/financials/StudentLockCentre.ascx" tagname="StudentLockCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:StudentLockCentre ID="StudentLockCentre1" runat="server" />
</asp:Content>

