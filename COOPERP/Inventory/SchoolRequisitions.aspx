<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Inventory/MasterPage.master" AutoEventWireup="true" CodeFile="SchoolRequisitions.aspx.cs" Inherits="COOPERP_Inventory_SchoolRequisitions" %>



<%@ Register src="../../UserControls/Inventory/SchoolRequisitions.ascx" tagname="SchoolRequisitions" tagprefix="uc1" %>



<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
    <uc1:SchoolRequisitions ID="SchoolRequisitions1" runat="server" />
    
</asp:Content>

