<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/StudentInfo/MasterPage.master" AutoEventWireup="true" CodeFile="StudentCards.aspx.cs" Inherits="COOPERP_StudentInfo_StudentCards" %>

<%@ Register src="../../UserControls/StudentInfo/StudentCardsCentre.ascx" tagname="StudentCardsCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:StudentCardsCentre ID="StudentCardsCentre1" runat="server" />
</asp:Content>

