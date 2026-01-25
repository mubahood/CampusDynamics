<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Graduate/MasterPage.master" AutoEventWireup="true" CodeFile="ResearchProgress.aspx.cs" Inherits="COOPERP_Graduate_ResearchProgress" %>

<%@ Register src="../../UserControls/Graduate/ResearchProgress.ascx" tagname="ResearchProgress" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ResearchProgress ID="ResearchProgress1" runat="server" />
</asp:Content>

