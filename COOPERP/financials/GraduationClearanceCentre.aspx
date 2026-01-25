<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="GraduationClearanceCentre.aspx.cs" Inherits="COOPERP_financials_ClearanceCentre" %>

<%@ Register src="../../UserControls/financials/GraduationCentre.ascx" tagname="ClearanceCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ClearanceCentre ID="ClearanceCentre1" runat="server" />
</asp:Content>

