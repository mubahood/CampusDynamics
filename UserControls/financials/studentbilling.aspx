<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="true" CodeFile="studentbilling.aspx.cs" Inherits="COOPERP_financials_studentbilling" %>

<%@ Register src="../../UserControls/financials/studentbilling.ascx" tagname="studentbilling" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <%--<asp:UpdatePanel ID="UpdatePanel1" runat="server">--%>
        <ContentTemplate>
            <uc1:studentbilling ID="studentbilling1" runat="server" />
        </ContentTemplate>
   <%-- </asp:UpdatePanel>--%>
</asp:Content>

