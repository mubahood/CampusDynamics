<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Registry/MasterPage.master" AutoEventWireup="true" CodeFile="BestPerformers.aspx.cs" Inherits="COOPERP_Registry_BestPerformers" %>

<%@ Register src="../../UserControls/Results/BestPerformersAnnual.ascx" tagname="BestPerformersAnnual" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:BestPerformersAnnual ID="BestPerformersAnnual1" runat="server" />
</asp:Content>

