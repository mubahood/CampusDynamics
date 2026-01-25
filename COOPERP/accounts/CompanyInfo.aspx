<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="CompanyInfo.aspx.cs" Inherits="COOPERP_accounts_CompanyInfo" %>

<%@ Register src="../../UserControls/Accounts/CompanyInfo.ascx" tagname="CompanyInformation" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:CompanyInformation ID="CompanyInformation1" runat="server" />
</asp:Content>

