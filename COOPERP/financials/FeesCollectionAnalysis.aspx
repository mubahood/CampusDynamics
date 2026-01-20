<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="FeesCollectionAnalysis.aspx.cs" Inherits="COOPERP_financials_FeesCollectionAnalysis" %>

<%@ Register src="../../UserControls/financials/FeesCollectionAnalysis.ascx" tagname="FeesCollectionAnalysis" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:FeesCollectionAnalysis ID="FeesCollectionAnalysis1" runat="server" />
</asp:Content>

