<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="CSVData.aspx.cs" Inherits="COOPERP_financials_CSVData" %>

<%@ Register src="../../UserControls/financials/CSVDataLoader.ascx" tagname="CSVDataLoader" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:CSVDataLoader ID="CSVDataLoader1" runat="server" />
</asp:Content>

