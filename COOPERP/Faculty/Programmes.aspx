<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Faculty/MasterPage.master" AutoEventWireup="true" CodeFile="Programmes.aspx.cs" Inherits="COOPERP_Faculty_Programmes" %>

<%@ Register src="../../UserControls/Faculty/Programme.ascx" tagname="Programme" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:Programme ID="Programme1" runat="server" />
</asp:Content>

