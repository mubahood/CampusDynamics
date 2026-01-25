<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Faculty/MasterPage.master" AutoEventWireup="true" CodeFile="GradingSystem.aspx.cs" Inherits="COOPERP_Faculty_GradingSystem" %>

<%@ Register src="../../UserControls/Faculty/GradingSystem.ascx" tagname="GradingSystem" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:GradingSystem ID="GradingSystem1" runat="server" />
</asp:Content>

