<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Admissions/MasterPage.master" AutoEventWireup="true" CodeFile="Letters.aspx.cs" Inherits="COOPERP_Admissions_Letters" %>

<%@ Register src="../../UserControls/Admissions/letters.ascx" tagname="letters" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:letters ID="letters1" runat="server" />
</asp:Content>

