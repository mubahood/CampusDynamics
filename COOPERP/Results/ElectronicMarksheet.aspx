<%@ Page Title="Electronic Marksheets" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="ElectronicMarksheet.aspx.cs" Inherits="COOPERP_Results_ElectronicMarksheet" %>

<%@ Register src="../../UserControls/Results/ElectronicSheets.ascx" tagname="ElectronicSheets" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ElectronicSheets ID="ElectronicSheets1" runat="server" />
</asp:Content>

