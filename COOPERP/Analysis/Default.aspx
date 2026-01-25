<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Analysis/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_Analysis_Default" %>

<%@ Register src="../../UserControls/Admissions/AdmissionStatistics.ascx" tagname="AdmissionStatistics" tagprefix="uc1" %>

<%@ Register src="../../UserControls/StudentInfo/enrollmentAnalysis.ascx" tagname="enrollmentAnalysis" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="1" Width="100%">
        <TabPages>
            <dx:TabPage Text="Admission Analysis">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text="Enrollment Analysis">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <uc2:enrollmentAnalysis ID="enrollmentAnalysis1" runat="server" />
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text="Fees Collection Analysis">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text="Graduation Analysis">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
        </TabPages>
    </dx:ASPxPageControl>
</asp:Content>

