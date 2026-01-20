<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentStatistics.ascx.cs" Inherits="UserControls_Admissions_AdmissionStatistics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style2
    {
        width: 90px;
    }
    .style4
    {
        width: 203px;
    }
    .style5
    {
        width: 85px;
    }
    .style6
    {
        width: 179px;
    }
    .auto-style6 {
        height: 18px;
    }
    .auto-style7 {
        height: 18px;
        width: 99px;
    }
    .auto-style8 {
        height: 18px;
        width: 216px;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true"
    Width="100%" HeaderText="" ShowHeader="False">
    <PanelCollection>
<%--<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <dx:ASPxCallbackPanel ID="cbk_admstats" runat="server" 
    ClientInstanceName="callback_AdmStats" Width="100%" 
        OnCallback="cbk_admstats_Callback">
    <PanelCollection>--%>
<dx:PanelContent ID="PanelContent2" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td colspan="4">
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage1" runat="server" 
                                ImageUrl="~/COOPERP/images/header_stud_statistics.png" 
                                ShowLoadingImage="True">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="True" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="4">
                <table class="style1">
                    <tr>
                        <td class="style2">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                        <td class="style5">
                            &nbsp;</td>
                        <td class="style6">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style2">
                            <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="Current Year">
                            </dx:ASPxLabel>
                        </td>
                        <td class="style4">
                            <dx:ASPxComboBox ID="txtAcadYear" runat="server" Width="200px" AutoPostBack="True" Height="35px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">
                            <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text="Export Format">
                            </dx:ASPxLabel>
                        </td>
                        <td class="style6">
                            <dx:ASPxComboBox ID="txtExportFormat" runat="server" Width="200px" AutoPostBack="True" Height="35px">
                             <Items>
                                                <dx:ListEditItem Selected="True" Text="PDF" Value="PDF" />
                                                <dx:ListEditItem Text="Rich Text Format" Value="RTF" />
                                                <dx:ListEditItem Text="Excel" Value="XLS" />
                                            </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style2">
                            Semester:</td>
                        <td class="style4">
                            <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">
                            Analyse By:</td>
                        <td class="style6">
                            <dx:ASPxComboBox ID="txtListBy" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Semester" Value="Semester" />
                                    <dx:ListEditItem Text="Academic Year" Value="Acad Year" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style2">&nbsp;</td>
                        <td class="style4">&nbsp;</td>
                        <td class="style5">&nbsp;</td>
                        <td class="style6">&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="4">
                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                    <TabPages>
                        <dx:TabPage Text=" Enrolment Analysis">
                            <TabImage IconID="chart_stackedbar_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <table class="style1">
                                                    <tr>
                                                        <td class="auto-style7">
                                                            <dx:ASPxButton ID="btnExport" runat="server" AutoPostBack="False" Height="35px" OnClick="btnExport_Click1" Text="Export" Width="200px">
                                                                <ClientSideEvents Click="function(s, e) {
}" />
                                                                <Image Url="~/COOPERP/images/fill-090.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td class="auto-style8">&nbsp;</td>
                                                        <td class="auto-style6">&nbsp;</td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxPivotGrid ID="pvt_AdmnStatistics" runat="server" ClientIDMode="AutoID" DataSourceID="ds_AdmnStats" Width="100%">
                                                    <Fields>
                                                        <dx:PivotGridField ID="fieldabbrev" AreaIndex="5" Caption="PROGRAMME" FieldName="abbrev">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldpopn" Area="DataArea" AreaIndex="0" Caption="STUDENTS" FieldName="popn" SummaryType="Count">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldgender" AreaIndex="2" Caption="GENDER" FieldName="gender">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldnationality" AreaIndex="0" Caption="NATIONALITY" FieldName="nationality">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldintake" AreaIndex="1" Caption="INTAKE" FieldName="intake">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudsesion" AreaIndex="4" Caption="SESSION" FieldName="studsesion">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldregstatus" AreaIndex="6" Caption="STATUS" FieldName="regstatus">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldexamClearance" AreaIndex="3" Caption="EXAM CLEARANCE" FieldName="examClearance">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldfacultyname" Area="RowArea" AreaIndex="1" Caption="SCHOOL" FieldName="faculty_name">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldcampusname" Area="RowArea" AreaIndex="0" Caption="CAMPUS" FieldName="campus_name">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudyyear" Area="ColumnArea" AreaIndex="0" Caption="STUDY YEAR" FieldName="studyyear">
                                                        </dx:PivotGridField>
                                                    </Fields>
                                                </dx:ASPxPivotGrid>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style6">
                                                &nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dxchartsui:WebChartControl ID="WC_AdmnStats" runat="server" CrosshairEnabled="True" DataSourceID="pvt_AdmnStatistics" Height="500px" SeriesDataMember="Series" Width="900px">
                                                    <DiagramSerializable>
                                                        <cc2:XYDiagram>
                                                            <AxisX Title-Text="SESSION" VisibleInPanesSerializable="-1">
                                                            </AxisX>
                                                            <AxisY Title-Text="STUDENTS" VisibleInPanesSerializable="-1">
                                                            </AxisY>
                                                        </cc2:XYDiagram>
                                                    </DiagramSerializable>
                                                    <Legend MaxHorizontalPercentage="30" Name="Default Legend"></Legend>
                                                    <SeriesTemplate ArgumentDataMember="Arguments" ArgumentScaleType="Qualitative" ValueDataMembersSerializable="Values">
                                                    </SeriesTemplate>
                                                    <Titles>
                                                        <cc2:ChartTitle Font="Tahoma, 20.25pt" Text="CHART OF STUDENT ENROLMENT" WordWrap="True" />
                                                    </Titles>
                                                </dxchartsui:WebChartControl>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="ds_AdmnStats" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_student_statsTableAdapter">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtSemester" Name="sems" PropertyName="Value" Type="Int32" />
                                                        <asp:ControlParameter ControlID="txtListBy" DefaultValue="Semester" Name="typ" PropertyName="Value" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <dx:ASPxPivotGridExporter ID="GE_AdmnStats" runat="server" ASPxPivotGridID="pvt_AdmnStatistics">
                                                </dx:ASPxPivotGridExporter>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text=" Student Listing">
                            <TabImage IconID="filterelements_listbox_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <table class="style1">
                                                    <tr>
                                                        <td class="auto-style7">Analyse By:</td>
                                                        <td class="auto-style8">
                                                            <dx:ASPxComboBox ID="txtCRType" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                                                <Items>
                                                                    <dx:ListEditItem Selected="True" Text="All" Value="All" />
                                                                    <dx:ListEditItem Text="Faculty" Value="Faculty" />
                                                                    <dx:ListEditItem Text="Programme" Value="Prog" />
                                                                </Items>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                        <td class="auto-style6">
                                                            <dx:ASPxButton ID="btnExportList" runat="server" AutoPostBack="False" Height="35px" OnClick="btnExportList_Click" Text="Export" Width="200px">
                                                                <ClientSideEvents Click="function(s, e) {
}" />
                                                                <Image Url="~/COOPERP/images/fill-090.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="gvCRRate" runat="server" AutoGenerateColumns="False" DataSourceID="dsCRData" KeyFieldName="regno" OnHtmlRowPrepared="gvCRRate_HtmlRowPrepared" Width="100%">
                                                    <Settings ShowFooter="True" ShowFilterRow="True" ShowFilterRowMenu="True" />
                                                    <SettingsBehavior AllowFocusedRow="True" />
                                                    <SettingsSearchPanel Visible="True" />
                                                    <Columns>
                                                        <dx:GridViewCommandColumn ShowClearFilterButton="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Reg No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Session" FieldName="studsesion" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Campus" FieldName="campus_name" ShowInCustomizationForm="True" VisibleIndex="12">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Intake" FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Course" FieldName="abbrev" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Gender" FieldName="gender" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="School" FieldName="faculty_name" ShowInCustomizationForm="True" VisibleIndex="8">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Status" FieldName="regstatus" ShowInCustomizationForm="True" VisibleIndex="9">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Stud Name" FieldName="stud_name" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Clearance" FieldName="examClearance" ShowInCustomizationForm="True" VisibleIndex="10">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" ShowInCustomizationForm="True" VisibleIndex="11">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Study Year" FieldName="studyyear" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <TotalSummary>
                                                        <dx:ASPxSummaryItem DisplayFormat="{0}" FieldName="admitted" ShowInColumn="Admitted" ShowInGroupFooterColumn="Admitted" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                        <dx:ASPxSummaryItem DisplayFormat="{0}" FieldName="not_admitted" ShowInColumn="Not Admitted" ShowInGroupFooterColumn="Not Admitted" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                        <dx:ASPxSummaryItem DisplayFormat="{0}" FieldName="total_applics" ShowInColumn="Total Applicants" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                    </TotalSummary>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                    </TabPages>
                    <TabStyle>
                        <Paddings Padding="10px" />
                    </TabStyle>
                </dx:ASPxPageControl>
            </td>
        </tr>
        <tr>
            <td colspan="4">
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
            <td>
                <asp:ObjectDataSource ID="ds_Campus" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="admission_dataTableAdapters.acad_campusesTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="campus_name" Type="String" />
                        <asp:Parameter Name="campus_phone" Type="String" />
                        <asp:Parameter Name="campus_email" Type="String" />
                        <asp:Parameter Name="campus_short_name" Type="String" />
                        <asp:Parameter Name="campus_head" Type="String" />
                        <asp:Parameter Name="campus_code" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="campus_name" Type="String" />
                        <asp:Parameter Name="campus_phone" Type="String" />
                        <asp:Parameter Name="campus_email" Type="String" />
                        <asp:Parameter Name="campus_short_name" Type="String" />
                        <asp:Parameter Name="campus_head" Type="String" />
                        <asp:Parameter Name="campus_code" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
            <td>
                <dx:ASPxGridViewExporter ID="gve_studlist" runat="server" ExportedRowType="All" GridViewID="gvCRRate">
                </dx:ASPxGridViewExporter>
            </td>
            <td>
                <asp:ObjectDataSource ID="dsCRData" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_student_statsTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtSemester" Name="sems" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtListBy" DefaultValue="-" Name="typ" PropertyName="Value" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
</dx:PanelContent>
</PanelCollection>
<%--</dx:ASPxCallbackPanel>
</dx:PanelContent>
</PanelCollection>--%>
</dx:ASPxRoundPanel>


