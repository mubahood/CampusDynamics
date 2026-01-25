<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Admissions/MasterPage.master" AutoEventWireup="true" CodeFile="MarketingAdmissions.aspx.cs" Inherits="COOPERP_Admissions_MarketingAdmissions" %>

<%@ Register src="../../UserControls/Admissions/MarketingApplications.ascx" tagname="MarketingApplications" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:MarketingApplications ID="MarketingApplications1" runat="server" />
</asp:Content>

