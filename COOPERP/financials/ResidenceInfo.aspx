<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="ResidenceInfo.aspx.cs" Inherits="COOPERP_StudentInfo_ResidenceInfo" %>

<%@ Register src="../../UserControls/StudentInfo/ResidenceAllocation.ascx" tagname="StudentCardsCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:StudentCardsCentre ID="StudentCardsCentre1" runat="server" />
</asp:Content>


