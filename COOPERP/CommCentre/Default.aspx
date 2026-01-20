<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/CommCentre/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_CommCentre_Default" %>

<%@ Register src="../../UserControls/CommunicationCentre/ComnicationCentre.ascx" tagname="ComnicationCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ComnicationCentre ID="ComnicationCentre1" runat="server" />
</asp:Content>

