<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Graduate/MasterPage.master" AutoEventWireup="true" CodeFile="ResearchActivities.aspx.cs" Inherits="COOPERP_Graduate_ResearchActivities" %>

<%@ Register src="../../UserControls/Graduate/ResearchEvents.ascx" tagname="ResearchEvents" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ResearchEvents ID="ResearchEvents1" runat="server" />
</asp:Content>

