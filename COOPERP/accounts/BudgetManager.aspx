<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="BudgetManager.aspx.cs" Inherits="COOPERP_accounts_BudgetManager" %>

<%@ Register src="../../UserControls/Accounts/BudgetManager.ascx" tagname="BudgetManager" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
   
            <uc1:BudgetManager ID="BudgetManager1" runat="server" />
       
</asp:Content>

