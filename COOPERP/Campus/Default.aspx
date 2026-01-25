<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Campus/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_Campus_Default" %>

<%@ Register src="../../UserControls/Campus/CampusInfo.ascx" tagname="CampusInfo" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:CampusInfo ID="CampusInfo1" runat="server" />
</asp:Content>

