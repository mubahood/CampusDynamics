<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Financials/MasterPage.master" AutoEventWireup="true" CodeFile="StudentInfo.aspx.cs" Inherits="COOPERP_StudentInfo_StudentInfo" %>

<%@ Register src="../../UserControls/StudentInfo/StudentEditor.ascx" tagname="StudentEditor" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
        <uc1:StudentEditor ID="StudentEditor1" runat="server" />
    
</asp:Content>

