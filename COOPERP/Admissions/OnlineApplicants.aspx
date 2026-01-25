<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Admissions/MasterPage.master" AutoEventWireup="true" CodeFile="OnlineApplicants.aspx.cs" Inherits="COOPERP_Admissions_OnlineApplicants" %>

<%@ Register src="../../UserControls/Admissions/OnlineApplications.ascx" tagname="OnlineApplications" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:OnlineApplications ID="OnlineApplications1" runat="server" />
</asp:Content>

