<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Inventory/MasterPage.master" AutoEventWireup="true" CodeFile="SchoolBudgets.aspx.cs" Inherits="COOPERP_schools_SchoolBudgets" %>

<%@ Register src="../../UserControls/Inventory/lnventoryBudgets.ascx" tagname="lnventoryBudgets" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:lnventoryBudgets ID="lnventoryBudgets1" runat="server" />
</asp:Content>

