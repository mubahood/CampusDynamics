<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="ResultsUpdates.aspx.cs" Inherits="COOPERP_Results_ResultsUpdates" %>

<%@ Register src="../../UserControls/Results/ResultsUpdates.ascx" tagname="ResultsUpdates" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ResultsUpdates ID="ResultsUpdates1" runat="server" />
</asp:Content>

