<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/StudentInfo/MasterPage.master" AutoEventWireup="true" CodeFile="Promotions.aspx.cs" Inherits="COOPERP_StudentInfo_Promotions" %>

<%@ Register src="../../UserControls/StudentInfo/PromotionsCentre.ascx" tagname="PromotionsCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:PromotionsCentre ID="PromotionsCentre1" runat="server" />
</asp:Content>

