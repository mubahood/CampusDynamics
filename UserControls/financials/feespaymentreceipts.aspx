<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="feespaymentreceipts.aspx.cs" Inherits="COOPERP_financials_feespaymenttracking" %>


<%@ Register src="../../UserControls/Accounts/ReceiptCentre.ascx" tagname="ReceiptCentre" tagprefix="uc1" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
    <uc1:ReceiptCentre ID="ReceiptCentre1" runat="server" />
    
    </asp:Content>

