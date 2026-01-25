<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Registry/MasterPage.master" AutoEventWireup="true" CodeFile="GraduationAnalysis.aspx.cs" Inherits="COOPERP_Registry_GraduationAnalysis" %>

<%@ Register src="../../UserControls/Results/GraduationAnalysis.ascx" tagname="GraduationAnalysis" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:GraduationAnalysis ID="GraduationAnalysis1" runat="server" />
</asp:Content>

