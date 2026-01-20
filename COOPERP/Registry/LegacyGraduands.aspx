<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Registry/MasterPage.master" AutoEventWireup="true" CodeFile="LegacyGraduands.aspx.cs" Inherits="COOPERP_Results_LegacyGraduands" %>

<%@ Register src="../../UserControls/Results/LegacyStudents.ascx" tagname="LegacyStudents" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:LegacyStudents ID="LegacyStudents1" runat="server" />
</asp:Content>

