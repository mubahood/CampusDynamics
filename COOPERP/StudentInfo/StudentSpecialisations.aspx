<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/StudentInfo/MasterPage.master" AutoEventWireup="true" CodeFile="StudentSpecialisations.aspx.cs" Inherits="COOPERP_StudentInfo_StudentSpecialisations" %>

<%@ Register Src="~/UserControls/StudentInfo/StudentSpecialisationCentre.ascx" TagPrefix="uc1" TagName="StudentSpecialisationCentre" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:StudentSpecialisationCentre runat="server" id="StudentSpecialisationCentre" />
</asp:Content>

