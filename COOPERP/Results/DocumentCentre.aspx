<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="DocumentCentre.aspx.cs" Inherits="COOPERP_Results_Reports_DocumentCentre" %>

<%@ Register src="../../UserControls/Results/ResultsDocCentre.ascx" tagname="ResultsDocCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ResultsDocCentre ID="ResultsDocCentre1" runat="server" />
</asp:Content>

