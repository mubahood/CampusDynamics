<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Timetables/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_Timetables_Default" %>

<%@ Register src="../../UserControls/Timetables/TeachingAllocations.ascx" tagname="TeachingAllocations" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:TeachingAllocations ID="TeachingAllocations1" runat="server" />
</asp:Content>

