<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="CourseRegistration.aspx.cs" Inherits="COOPERP_Results_CourseRegistration" %>

<%@ Register src="../../UserControls/Timetables/CourseRegistration.ascx" tagname="CourseRegistration" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:CourseRegistration ID="CourseRegistration1" runat="server" />
</asp:Content>

