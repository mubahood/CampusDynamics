<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Admissions/MasterPage.master" AutoEventWireup="true" CodeFile="AdminssionAnalysis.aspx.cs" Inherits="COOPERP_Admissions_AdminssionAnalysis" %>

<%@ Register src="../../UserControls/Admissions/AdmissionStatistics.ascx" tagname="AdmissionStatistics" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:AdmissionStatistics ID="AdmissionStatistics1" runat="server" />
</asp:Content>

