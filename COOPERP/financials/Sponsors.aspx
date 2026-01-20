<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="Sponsors.aspx.cs" Inherits="COOPERP_financials_Sponsors" %>

<%@ Register src="../../UserControls/financials/scholarships.ascx" tagname="scholarships" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:scholarships ID="scholarships1" runat="server" />
</asp:Content>

