<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/HumanResource/MasterPage.master" AutoEventWireup="true" CodeFile="ParttimePayRates.aspx.cs" Inherits="COOPERP_HumanResource_ParttimePayRates" %>

<%@ Register src="../../UserControls/HumanResource/PayrollSpecialRates.ascx" tagname="PayrollSpecialRates" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:PayrollSpecialRates ID="PayrollSpecialRates1" runat="server" />
</asp:Content>

