<%@ Control Language="C#" AutoEventWireup="true" CodeFile="AdmissionStatistics.ascx.cs" Inherits="UserControls_Admissions_AdmissionStatistics" %>
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
    .auto-style1 {
        width: 90px;
        height: 43px;
    }
    .auto-style2 {
        width: 203px;
        height: 43px;
    }
    .auto-style3 {
        width: 85px;
        height: 43px;
    }
    .auto-style4 {
        width: 179px;
        height: 43px;
    }
    .auto-style5 {
        height: 43px;
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
                                ImageUrl="~/COOPERP/images/header_AdmissionAnalysis.png" 
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
                            </dx:ASPxComboBox>
                        </td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">
                            <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Campus">
                            </dx:ASPxLabel>
                        </td>
                        <td class="auto-style2">
                            <dx:ASPxComboBox ID="txtCampus" runat="server" Width="200px" 
                                DataSourceID="ds_Campus" TextField="campus_name" TextFormatString="{1}" 
                                ValueField="campus_code" AutoPostBack="True" Height="35px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="campus_code" Name="50px" />
                                    <dx:ListBoxColumn Caption="Name" FieldName="campus_name" Name="300px" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style3">
                            <dx:ASPxLabel ID="ASPxLabel4" runat="server" Text="% Format">
                            </dx:ASPxLabel>
                        </td>
                        <td class="auto-style4">
                            <dx:ASPxComboBox ID="txtPercentage" runat="server" Width="200px" AutoPostBack="True" Height="35px">
                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_AdmStats.PerfromCallback('PercentageType');
}" />
                            <Items>
                                                <dx:ListEditItem Selected="True" Text="Percentage Of Column" 
                                                    Value="colpercent" />
                                                <dx:ListEditItem Text="Percentage Of Row" Value="rowpercent" />
                                            </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">
                            </td>
                        <td class="auto-style5">
                            </td>
                    </tr>
                    <tr>
                        <td class="style2">Start Year</td>
                        <td class="style4">
                            <dx:ASPxComboBox ID="txtStartYear" runat="server" AutoPostBack="True" Height="35px" Width="200px">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">End Year</td>
                        <td class="style6">
                            <dx:ASPxComboBox ID="txtEndYear" runat="server" AutoPostBack="True" Height="35px" Width="200px">
                            </dx:ASPxComboBox>
                        </td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
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
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="4">
                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="1" Width="100%">
                    <TabPages>
                        <dx:TabPage Text=" Conversion Rate">
                            <TabImage IconID="chart_fullstackedbar_16x16">
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
                                                            <dx:ASPxButton ID="btnExport0" runat="server" AutoPostBack="False" Height="35px" OnClick="btnExport_Click" Text="Export" Width="200px">
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
                                                <dx:ASPxGridView ID="gvCRRate" runat="server" AutoGenerateColumns="False" DataSourceID="dsCRData" KeyFieldName="progname" OnHtmlRowPrepared="gvCRRate_HtmlRowPrepared" Width="100%">
                                                    <Settings ShowFooter="True" />
                                                    <SettingsBehavior AllowFocusedRow="True" />
                                                    <SettingsSearchPanel Visible="True" />
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Total Applicants" FieldName="total_applics" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                                                            <FooterCellStyle Font-Bold="True">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Conversion Rate" FieldName="conv_rate" ShowInCustomizationForm="True" VisibleIndex="5" Width="100px">
                                                            <PropertiesTextEdit DisplayFormatString="{0}%">
                                                            </PropertiesTextEdit>
                                                            <CellStyle HorizontalAlign="Right">
                                                            </CellStyle>
                                                            <FooterCellStyle Font-Bold="False">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Admitted" FieldName="admitted" ShowInCustomizationForm="True" VisibleIndex="2" Width="100px">
                                                            <FooterCellStyle Font-Bold="True">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Not Admitted" FieldName="not_admitted" ShowInCustomizationForm="True" VisibleIndex="3" Width="100px">
                                                            <FooterCellStyle Font-Bold="True">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Programm | Faculty" FieldName="progname" ShowInCustomizationForm="True" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                        </dx:GridViewCommandColumn>
                                                    </Columns>
                                                    <TotalSummary>
                                                        <dx:ASPxSummaryItem DisplayFormat="{0}" FieldName="admitted" ShowInColumn="Admitted" ShowInGroupFooterColumn="Admitted" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                        <dx:ASPxSummaryItem DisplayFormat="{0}" FieldName="not_admitted" ShowInColumn="Not Admitted" ShowInGroupFooterColumn="Not Admitted" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                        <dx:ASPxSummaryItem DisplayFormat="{0}" FieldName="total_applics" ShowInColumn="Total Applicants" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                    </TotalSummary>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="dsCRData" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_GetConversionRateTableAdapter">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtCRType" Name="typ" PropertyName="Value" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text=" Admissions Analysis">
                            <TabImage IconID="chart_stackedbar_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style6">
                                                <table class="style1">
                                                    <tr>
                                                        <td class="auto-style7">Analysis Type:</td>
                                                        <td class="auto-style8">
                                                            <dx:ASPxComboBox ID="txtAnalysisType" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                                                <Items>
                                                                    <dx:ListEditItem Selected="True" Text="Single Year" Value="Single" />
                                                                    <dx:ListEditItem Text="Period" Value="Period" />
                                                                </Items>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                        <td class="auto-style6">
                                                            <dx:ASPxButton ID="btnExport" runat="server" AutoPostBack="False" Height="35px" OnClick="btnExport_Click" Text="Export" Width="200px">
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
                                                <dx:ASPxPivotGrid ID="pvt_AdmnStatistics" runat="server" ClientIDMode="AutoID" DataSourceID="ds_AdmnStats" Width="100%">
                                                    <Fields>
                                                        <dx:PivotGridField ID="fieldprogname" AreaIndex="0" Caption="PROGRAMME" FieldName="progname">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudents" Area="DataArea" AreaIndex="0" Caption="STUDENTS" FieldName="students" SummaryType="Count">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudreligion" AreaIndex="1" Caption="RELIGION" FieldName="stud_religion">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudsex" AreaIndex="0" Caption="GENDER" FieldName="stud_sex" Area="ColumnArea">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudnationality" AreaIndex="2" Caption="NATIONALITY" FieldName="stud_nationality">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudintake" AreaIndex="3" Caption="INTAKE" FieldName="stud_intake">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldadmsession" Area="RowArea" AreaIndex="0" Caption="SESSION" FieldName="adm_session">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudents1" AreaIndex="4" Caption="%" FieldName="students" SummaryDisplayType="PercentOfColumn" SummaryType="Count">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldadmstatus" AreaIndex="7" Caption="STATUS" FieldName="adm_status">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldFaculty" AreaIndex="5" Caption="FACULTY" FieldName="Faculty">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldstudcampus1" AreaIndex="6" Caption="CAMPUS" FieldName="studcampus">
                                                        </dx:PivotGridField>
                                                    </Fields>
                                                </dx:ASPxPivotGrid>
                                            </td>
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
                                                        <cc2:ChartTitle Font="Tahoma, 20.25pt" Text="CHART OF ADMISSIONS" WordWrap="True" />
                                                    </Titles>
                                                </dxchartsui:WebChartControl>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="ds_AdmnStats" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_AdmissionStatisticsTableAdapter">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtCampus" Name="camp" PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtAcadYear" Name="acad_year" PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtAnalysisType" DefaultValue="" Name="analysisType" PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtStartYear" Name="statYear" PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtEndYear" Name="EndYear" PropertyName="Value" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
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
                <dx:ASPxPivotGridExporter ID="GE_AdmnStats" runat="server" 
                    ASPxPivotGridID="pvt_AdmnStatistics">
                </dx:ASPxPivotGridExporter>
            </td>
            <td>
                &nbsp;</td>
        </tr>
    </table>
</dx:PanelContent>
</PanelCollection>
<%--</dx:ASPxCallbackPanel>
</dx:PanelContent>
</PanelCollection>--%>
</dx:ASPxRoundPanel>


