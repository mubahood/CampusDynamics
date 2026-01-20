<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="GraduationInfo.aspx.cs" Inherits="COOPERP_Results_GraduationInfo" %>

<%@ Register src="../../UserControls/Results/GraduationCentre.ascx" tagname="GraduationCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:GraduationCentre ID="GraduationCentre1" runat="server" />
</asp:Content>

