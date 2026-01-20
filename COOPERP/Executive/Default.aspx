<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Executive/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_Campus_Default" %>

<%@ Register src="../../UserControls/Campus/CampusInfo.ascx" tagname="CampusInfo" tagprefix="uc1" %>

<%@ Register src="../../UserControls/Admissions/AdmissionStatistics.ascx" tagname="AdmissionStatistics" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc2:AdmissionStatistics ID="AdmissionStatistics1" runat="server" />
</asp:Content>

