<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="ResearchElectronicMarkSheets.aspx.cs" Inherits="COOPERP_Results_ResearchElectronicMarkSheets" %>

<%@ Register Src="~/UserControls/Results/ResearchElectronicSheets.ascx" TagPrefix="uc1" TagName="ResearchElectronicSheets" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ResearchElectronicSheets runat="server" ID="ResearchElectronicSheets" />
</asp:Content>

