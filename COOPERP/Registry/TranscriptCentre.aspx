<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Registry/MasterPage.master" AutoEventWireup="true" CodeFile="TranscriptCentre.aspx.cs" Inherits="COOPERP_Registry_TranscriptCentre" %>

<%@ Register src="../../UserControls/Registry/TranscriptDocumentCentre.ascx" tagname="TranscriptDocumentCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:TranscriptDocumentCentre ID="TranscriptDocumentCentre1" runat="server" />
</asp:Content>

