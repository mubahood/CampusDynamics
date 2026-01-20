<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="BranchInfo.aspx.cs" Inherits="COOPERP_accounts_BranchInfo" %>

<%@ Register src="../../UserControls/schools/School_Branches.ascx" tagname="School_Branches" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:School_Branches ID="School_Branches1" runat="server" />
</asp:Content>

