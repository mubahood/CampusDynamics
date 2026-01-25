<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Timetables/MasterPage.master" AutoEventWireup="true" CodeFile="CourseRegistrationSelections.aspx.cs" Inherits="COOPERP_Timetables_CourseRegistrationSelections" %>

<%@ Register src="../../UserControls/Timetables/CourseRegistrationSelections.ascx" tagname="CourseRegistrationSelections" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:CourseRegistrationSelections ID="CourseRegistrationSelections1" runat="server" />
</asp:Content>

