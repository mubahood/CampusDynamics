<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/HumanResource/MasterPage.master" AutoEventWireup="true" CodeFile="LeaveManagementCentre.aspx.cs" Inherits="COOPERP_HumanResource_LeaveManagementCentre" %>

<%@ Register src="../../UserControls/HumanResource/AnnualLeavel.ascx" tagname="AnnualLeavel" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:AnnualLeavel ID="AnnualLeavel1" runat="server" />
</asp:Content>

