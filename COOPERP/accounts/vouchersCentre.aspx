<%@ Page Title="Vouchers Centre" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="vouchersCentre.aspx.cs" Inherits="COOPERP_accounts_vouchersCentre" %>

<%@ Register src="../../UserControls/Accounts/voucherCentre.ascx" tagname="voucherCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:voucherCentre ID="voucherCentre1" runat="server" />
</asp:Content>

