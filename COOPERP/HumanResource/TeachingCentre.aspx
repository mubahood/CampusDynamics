<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/HumanResource/MasterPage.master" AutoEventWireup="true" CodeFile="TeachingCentre.aspx.cs" Inherits="COOPERP_HumanResource_TeachingCentre" %>

<%@ Register src="../../UserControls/schools/hr_teaching_allocation.ascx" tagname="hr_teaching_allocation" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:hr_teaching_allocation ID="hr_teaching_allocation1" runat="server" />
</asp:Content>

