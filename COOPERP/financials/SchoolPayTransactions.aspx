<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="SchoolPayTransactions.aspx.cs" Inherits="COOPERP_financials_SchoolPayTransactions" %>

<%@ Register src="../../UserControls/financials/SchoolPayDatal.ascx" tagname="SchoolPayDatal" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:SchoolPayDatal ID="SchoolPayDatal1" runat="server" />
</asp:Content>

