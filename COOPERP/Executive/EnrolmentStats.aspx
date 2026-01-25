<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Executive/MasterPage.master" AutoEventWireup="true" CodeFile="EnrolmentStats.aspx.cs" Inherits="COOPERP_Executive_EnrolmentStats" %>

<%@ Register src="../../UserControls/Admissions/StudentStatistics.ascx" tagname="StudentStatistics" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:StudentStatistics ID="StudentStatistics1" runat="server" />
</asp:Content>

