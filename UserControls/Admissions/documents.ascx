<%@ Control Language="C#" AutoEventWireup="true" CodeFile="documents.ascx.cs" Inherits="UserControls_Admissions_documents" %>
<%@ Register assembly="DevExpress.XtraCharts.v16.1.Web, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.XtraCharts.Web.Designer" tagprefix="dxchartdesigner" %>
<style type="text/css">

    .style2
    {
        width: 375px;
    }
    .style3
    {
        width: 52px;
    }
    .style4
    {
        width:100%;
    }
    .style5
    {
        width: 94px;
    }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .auto-style1 {
        height: 18px;
    }
    .auto-style2 {
        height: 18px;
        width: 93px;
    }
    .auto-style3 {
        height: 18px;
        width: 252px;
    }
    .auto-style4 {
        height: 18px;
        width: 68px;
    }


    .auto-style6 {
        width: 89px;
    }
    .auto-style7 {
        height: 18px;
        width: 269px;
    }
    .auto-style8 {
        width: 269px;
    }


    .auto-style9 {
        height: 18px;
        width: 89px;
    }


    .auto-style10 {
        height: 18px;
        width: 62px;
    }
    .auto-style11 {
        width: 311px;
    }


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    
        <table class="style4">
            <tr>
                <td> <table cellpadding="0" cellspacing="0" class="style4">
                                                                    <tr>
                                                                        <td style="text-align: center">
                                                                            <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/COOPERP/images/header_doc_centre.png" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <asp:ImageButton ID="ImageButton2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%" />
                                                                        </td>
                                                                    </tr>
                                                                </table></td>
            </tr>
            <tr>
                <td>
                    <asp:ObjectDataSource ID="ds_campus" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
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
            </tr>
            <tr>
                <td>
                    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                        <TabPages>
                            <dx:TabPage Text="Print Outs">
                                <TabImage IconID="print_print_16x16">
                                </TabImage>
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" ShowHeader="False" Width="100%">
                                            <PanelCollection>
                                                <dx:PanelContent runat="server">
                                                    <table class="style4">
                                                        <tr>
                                                            <td colspan="4">&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Entry Year">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="auto-style11">
                                                                <dx:ASPxComboBox ID="txtEntryYear" runat="server" AutoPostBack="True" Width="250px" Height="40px">
                                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style10">
                                                                <dx:ASPxLabel ID="ASPxLabel6" runat="server" Text="Intake">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td>
                                                                <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="7" Width="200px" Height="40px">
                                                                    <Items>
                                                                        <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                                                        <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                                                        <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                                                        <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                                                        <dx:ListEditItem Text="MAY" Value="MAY" />
                                                                        <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                                                        <dx:ListEditItem Text="JULY" Value="JULY" />
                                                                        <dx:ListEditItem Selected="True" Text="AUGUST" Value="AUGUST" />
                                                                        <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                                                        <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                                                        <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                                                        <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                                                    </Items>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                <dx:ASPxLabel ID="ASPxLabel5" runat="server" Text="Campus">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="auto-style11">
                                                                <dx:ASPxComboBox ID="txt_campus" runat="server" DataSourceID="ds_campus" TextField="campus_name" TextFormatString="{1}" ValueField="campus_code" Width="250px" Height="40px">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Code" FieldName="campus_code" Width="30px" />
                                                                        <dx:ListBoxColumn Caption="Campus" FieldName="campus_name" />
                                                                    </Columns>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style10">
                                                                <dx:ASPxLabel ID="ASPxLabel7" runat="server" Text="Session">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td>
                                                                <dx:ASPxComboBox ID="txt_session" runat="server" SelectedIndex="0" Width="200px" Height="40px" DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn FieldName="Session" />
                                                                    </Columns>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text="Programme">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="auto-style11">
                                                                <dx:ASPxComboBox ID="txtProg" runat="server" DataSourceID="dsProgrammes" DropDownWidth="600px" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="250px" Height="40px">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="100px" />
                                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="500px" />
                                                                    </Columns>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style10">
                                                                <dx:ASPxLabel ID="ASPxLabel8" runat="server" Text="Document">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td>
                                                                <dx:ASPxComboBox ID="txt_document" runat="server" DropDownWidth="400px" SelectedIndex="2" Width="200px" Height="40px">
                                                                    <Items>
                                                                        <dx:ListEditItem Text="Application Lists" Value="0" />
                                                                        <dx:ListEditItem Text="Admission Letters" Value="1" />
                                                                        <dx:ListEditItem Selected="True" Text="Admission Lists" Value="2" />
                                                                        <dx:ListEditItem Text="Pending Lists" Value="3" />
                                                                    </Items>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                <dx:ASPxLabel ID="ASPxLabel4" runat="server" Text="Letter Template">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="auto-style11">
                                                                <dx:ASPxComboBox ID="txt_letter" runat="server" DataSourceID="ds_lettertemplates" TextField="letter_ref" TextFormatString="{0}" ValueField="letter_ref" Width="250px" Height="40px">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Template" FieldName="letter_ref" />
                                                                    </Columns>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style10">&nbsp;</td>
                                                            <td>
                                                                <dx:ASPxButton ID="btn_print" runat="server" OnClick="btn_print_Click" Text="Print" Width="200px" Height="40px">
                                                                    <Image Url="~/COOPERP/images/printer.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">&nbsp;</td>
                                                            <td class="auto-style11">&nbsp;</td>
                                                            <td class="auto-style10">&nbsp;</td>
                                                            <td>&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">
                                                                <dx:ASPxPopupControl ID="pop_print" runat="server" AllowDragging="True" CloseAction="CloseButton" ContentUrl="~/COOPERP/Admissions/XtraReports/Reports.aspx" HeaderText="Document Printing ..." Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                                                                    <ContentCollection>
                                                                        <dx:PopupControlContentControl runat="server">
                                                                        </dx:PopupControlContentControl>
                                                                    </ContentCollection>
                                                                </dx:ASPxPopupControl>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">
                                                                <asp:ObjectDataSource ID="ds_lettertemplates" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAdmissionYearLetters" TypeName="admission_dataTableAdapters.acad_admissionlettersTableAdapter">
                                                                    <DeleteParameters>
                                                                        <asp:Parameter Name="Original_letter_ref" Type="String" />
                                                                    </DeleteParameters>
                                                                    <SelectParameters>
                                                                        <asp:ControlParameter ControlID="txtEntryYear" Name="acad" PropertyName="Value" Type="String" />
                                                                    </SelectParameters>
                                                                </asp:ObjectDataSource>
                                                                <asp:ObjectDataSource ID="dsstudysessions" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                                                                    <InsertParameters>
                                                                        <asp:Parameter Name="Session" Type="String" />
                                                                    </InsertParameters>
                                                                    <UpdateParameters>
                                                                        <asp:Parameter Name="Original_Session" Type="String" />
                                                                    </UpdateParameters>
                                                                </asp:ObjectDataSource>
                                                                <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </dx:PanelContent>
                                            </PanelCollection>
                                        </dx:ASPxRoundPanel>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="Admissions Analytics" Enabled = "False">
                                <TabImage IconID="mail_sendxlsx_16x16">
                                </TabImage>
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <dx:ASPxRoundPanel ID="ASPxRoundPanel3" runat="server" ShowHeader="False" Width="100%">
                                            <PanelCollection>
                                                <dx:PanelContent runat="server">
                                                    <table class="style4">
                                                        <tr>
                                                            <td class="auto-style2">
                                                                <dx:ASPxLabel ID="ASPxLabel10" runat="server" Text="Analysis Type:">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="auto-style3">
                                                                <dx:ASPxComboBox ID="txt_analysistype" runat="server" Height="40px" SelectedIndex="0" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="txt_analysistype_SelectedIndexChanged">
                                                                    <Items>
                                                                        <dx:ListEditItem Selected="True" Text="Single Year" Value="Single" />
                                                                        <dx:ListEditItem Text="Periodic" Value="Periodic" />
                                                                    </Items>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style4">
                                                                <dx:ASPxLabel ID="ASPxLabel11" runat="server" Text="Start Year:">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="auto-style7">
                                                                <dx:ASPxComboBox ID="txt_startyear" runat="server" Height="40px" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="txt_analysistype_SelectedIndexChanged">
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style9"><dx:ASPxLabel ID="ASPxLabel13" runat="server" Text="% Format:">
                                                                </dx:ASPxLabel></td>
                                                            <td class="auto-style1"><dx:ASPxComboBox ID="txt_format" runat="server" Height="40px" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="txt_format_SelectedIndexChanged" SelectedIndex="2">
                                                                <Items>
                                                                    <dx:ListEditItem Text="None" Value="numeric" />
                                                                    <dx:ListEditItem Text="Percentage Of Column" Value="colpercent" />
                                                                    <dx:ListEditItem Selected="True" Text="Percentage Of Row" Value="rowpercent" />
                                                                </Items>
                                                                </dx:ASPxComboBox></td>
                                                            <td class="auto-style1">&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style2">
                                                                <dx:ASPxLabel ID="ASPxLabel9" runat="server" Text="Analysis Year:">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="auto-style3">
                                                                <dx:ASPxComboBox ID="txt_currentyear" runat="server" Height="40px" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="txt_analysistype_SelectedIndexChanged">
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style4"><dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="End Year:">
                                                                </dx:ASPxLabel></td>
                                                            <td class="auto-style7">
                                                                <dx:ASPxComboBox ID="txt_EndYear" runat="server" Height="40px" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="txt_analysistype_SelectedIndexChanged">
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                            <td class="auto-style9"><dx:ASPxLabel ID="ASPxLabel14" runat="server" Text="Export Format:">
                                                                </dx:ASPxLabel></td>
                                                            <td class="auto-style1"><dx:ASPxComboBox ID="txt_export" runat="server" Height="40px" Width="200px" SelectedIndex="2">
                                                                <Items>
                                                                    <dx:ListEditItem Text="PDF" Value="PDF" />
                                                                    <dx:ListEditItem Text="Rich Text Format" Value="RTF" />
                                                                    <dx:ListEditItem Selected="True" Text="Excel" Value="Excel" />
                                                                </Items>
                                                                </dx:ASPxComboBox></td>
                                                            <td class="auto-style1">&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <%--<dx:ASPxLabel ID="ASPxLabel12" runat="server" Text="Campus:">
                                                                </dx:ASPxLabel></td>--%>
                                                            <td>
                                                                <%--<dx:ASPxComboBox ID="txtCampus" runat="server" DataSourceID="ds_campus" Height="40px" TextField="campus_name" TextFormatString="{1}" ValueField="campus_code" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="txt_analysistype_SelectedIndexChanged">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="SNo." FieldName="campus_code" Width="30px" />
                                                                        <dx:ListBoxColumn Caption="Campus" FieldName="campus_name" />
                                                                    </Columns>
                                                                </dx:ASPxComboBox>--%>
                                                            </td>
                                                            <td>&nbsp;</td>
                                                            <td class="auto-style8">&nbsp;</td>
                                                            <td class="auto-style6">&nbsp;</td>
                                                            <td>
                                                                <dx:ASPxButton ID="btn_export" runat="server" Height="40px" Text="Export" Width="200px" OnClick="btn_export_Click">
                                                                    <Image IconID="actions_converttorange_16x16">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                            <td>&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="7">&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="7">
                                                                <dx:ASPxPivotGrid ID="pvt_admissions" runat="server" ClientIDMode="AutoID" DataSourceID="ds_admissionsdata" Width="100%" OnEndRefresh="pvt_admissions_DataBinding">
                                                                    <Fields>
                                                                        <dx:PivotGridField ID="fieldstudents" Area="DataArea" AreaIndex="0" Caption="STUDENTS" FieldName="students">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldadmsession" Area="RowArea" AreaIndex="0" Caption="SESSION" FieldName="adm_session">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldstudsex" Area="ColumnArea" AreaIndex="0" Caption="GENDER" FieldName="stud_sex">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldadmstatus" AreaIndex="0" Caption="ADMISSION STATUS" FieldName="adm_status">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldFaculty" AreaIndex="1" Caption="FACULTY" FieldName="Faculty">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldprogname" AreaIndex="2" Caption="PROGRAMME" FieldName="progname">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldstudentryyear" AreaIndex="3" Caption="ENTRY YEAR" FieldName="stud_entry_year">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldstudintake" AreaIndex="4" Caption="INTAKE" FieldName="stud_intake">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldstudnationality" AreaIndex="5" Caption="NATIONALITY" FieldName="stud_nationality">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldstudreligion" AreaIndex="6" Caption="RELIGION" FieldName="stud_religion">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldstudents1" AreaIndex="7" Caption="%" FieldName="students" SummaryDisplayType="PercentOfColumn">
                                                                        </dx:PivotGridField>
                                                                        <dx:PivotGridField ID="fieldstudcampus1" AreaIndex="8" Caption="CAMPUS" FieldName="studcampus">
                                                                        </dx:PivotGridField>
                                                                    </Fields>
                                                                    <OptionsChartDataSource FieldValuesProvideMode="DisplayText" />
                                                                    <OptionsPager RowsPerPage="20">
                                                                    </OptionsPager>
                                                                </dx:ASPxPivotGrid>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="7">
                                                                <dxchartsui:WebChartControl ID="chart_admissions" runat="server" CrosshairEnabled="True" DataSourceID="pvt_admissions" Height="500px" SeriesDataMember="Series" Width="900px">
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
                                                                        <cc2:ChartTitle Text="CHART OF ADMISSIONS" />
                                                                    </Titles>
                                                                </dxchartsui:WebChartControl>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="7">
                                                                <asp:ObjectDataSource ID="ds_admissionsdata" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="AdmissionAnalyticsTableAdapters.acad_AdmissionStatisticsTableAdapter">
                                                                    <SelectParameters>
                                                                        <asp:Parameter DefaultValue="01" Name="camp" Type="String" />
                                                                        <asp:ControlParameter ControlID="txt_currentyear" Name="acad_year" PropertyName="Value" Type="String" />
                                                                        <asp:ControlParameter ControlID="txt_analysistype" DefaultValue="-" Name="analysistype" PropertyName="Value" Type="String" />
                                                                        <asp:ControlParameter ControlID="txt_startyear" DefaultValue="-" Name="statYear" PropertyName="Value" Type="String" />
                                                                        <asp:ControlParameter ControlID="txt_EndYear" DefaultValue="-" Name="EndYear" PropertyName="Value" Type="String" />
                                                                    </SelectParameters>
                                                                </asp:ObjectDataSource>
                                                                <br />
                                                                <dx:ASPxPivotGridExporter ID="exp_admissions" runat="server" ASPxPivotGridID="pvt_admissions">
                                                                </dx:ASPxPivotGridExporter>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </dx:PanelContent>
                                            </PanelCollection>
                                        </dx:ASPxRoundPanel>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                        <TabStyle Height="40px">
                            <Paddings Padding="10px" />
                        </TabStyle>
                    </dx:ASPxPageControl>
                </td>
            </tr>
        </table>
    
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

