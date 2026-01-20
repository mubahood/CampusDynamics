<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Admissions/MasterPage.master" AutoEventWireup="true" CodeFile="ApplicantInfo.aspx.cs" Inherits="COOPERP_Admissions_ApplicantInfo" %>

<%@ Register src="../../UserControls/Admissions/applications.ascx" tagname="applications" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:applications ID="applications1" runat="server" />
</asp:Content>

