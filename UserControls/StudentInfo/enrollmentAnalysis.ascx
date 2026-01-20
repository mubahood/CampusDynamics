<%@ Control Language="C#" AutoEventWireup="true" CodeFile="enrollmentAnalysis.ascx.cs" Inherits="UserControls_StudentInfo_enrollmentAnalysis" %>
<style type="text/css">
    .auto-style1 {
        width: 100%;
    }
img
{
	border-width: 0;
}

    .auto-style2 {
        height: 8px;
    }
    .auto-style3 {
        width: 84px;
    }
    .auto-style4 {
        width: 244px;
    }
    .auto-style5 {
        height: 31px;
    }
</style>

<table class="auto-style1">
    <tr>
        <td class="auto-style5">
                            <dx:ASPxImage runat="server" ImageUrl="~/COOPERP/images/enrollmentAnalysis.fw.png"  ShowLoadingImage="True" ID="ASPxImage1"></dx:ASPxImage>


                            <dx:ASPxImage runat="server" ImageUrl="~/COOPERP/images/hor_line.png"  ShowLoadingImage="True" Width="100%" Height="1px" ID="ASPxImage2"></dx:ASPxImage>


                        </td>
    </tr>
    <tr>
        <td class="auto-style2"></td>
    </tr>
    <tr>
        <td>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style3">Acad Yr:</td>
                    <td class="auto-style4">
                        <dx:ASPxComboBox ID="AcadYrComboBox1" runat="server" Height="40px" Width="250px" AutoPostBack="True">
                            <Items>
                                <dx:ListEditItem Text="2010/2011" Value="2010/2011" />
                                <dx:ListEditItem Text="2011/2012" Value="2011/2012" />
                                <dx:ListEditItem Text="2012/2013" Value="2012/2013" />
                                <dx:ListEditItem Text="2013/2014" Value="2013/2014" />
                                <dx:ListEditItem Text="2014/2015" Value="2014/2015" />
                                <dx:ListEditItem Text="2015/2016" Value="2015/2016" />
                                <dx:ListEditItem Text="2016/2017" Value="2016/2017" />
                                <dx:ListEditItem Text="2017/2018" Value="2017/2018" />
                                <dx:ListEditItem Text="2018/2019" Value="2018/2019" />
                                <dx:ListEditItem Text="2019/2020" Value="2019/2020" />
                                <dx:ListEditItem Text="2020/2021" Value="2020/2021" />
                                <dx:ListEditItem Text="2021/2022" Value="2021/2022" />
                                <dx:ListEditItem Text="2022/2023" Value="2022/2023" />
                                <dx:ListEditItem Text="2023/2024" Value="2023/2024" />
                                <dx:ListEditItem Text="2024/2025" Value="2024/2025" />
                                <dx:ListEditItem Text="2025/2026" Value="2025/2026" />
                            </Items>
                        </dx:ASPxComboBox>
                    </td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style3">Semester:</td>
                    <td class="auto-style4">
                        <dx:ASPxComboBox ID="semComboBox1" runat="server" Height="40px" Width="250px" AutoPostBack="True">
                            <Items>
                                <dx:ListEditItem Text="1" Value="1" />
                                <dx:ListEditItem Text="2" Value="2" />
                                <dx:ListEditItem Text="3" Value="3" />
                            </Items>
                        </dx:ASPxComboBox>
                    </td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <dx:ASPxPivotGrid ID="ASPxPivotGrid1" runat="server" ClientIDMode="AutoID" DataSourceID="Enrollment_ODS" Width="100%">
                <Fields>
                    <dx:PivotGridField ID="fieldgender" AreaIndex="0" FieldName="gender">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldreligion" AreaIndex="1" FieldName="religion">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldnationality" AreaIndex="2" FieldName="nationality">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldstudent" Area="DataArea" AreaIndex="0" FieldName="student" SummaryType="Count">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldSchool" Area="ColumnArea" AreaIndex="0" FieldName="School">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldentrymethod" AreaIndex="3" FieldName="entrymethod">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldintake" AreaIndex="4" FieldName="intake">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldentryyear" AreaIndex="5" FieldName="entryyear">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldPrograms" AreaIndex="6" FieldName="Programs">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldregstatus" AreaIndex="7" FieldName="regstatus">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldspecialisation" AreaIndex="8" FieldName="specialisation">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldstudCampus" AreaIndex="9" FieldName="studCampus">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldStudentHall" AreaIndex="10" FieldName="StudentHall">
                    </dx:PivotGridField>
                    <dx:PivotGridField ID="fieldstudsesion" AreaIndex="11" FieldName="studsesion">
                    </dx:PivotGridField>
                </Fields>
            </dx:ASPxPivotGrid>
        </td>
    </tr>
    <tr>
        <td>
            <table class="auto-style1">
                <tr>
                    <td>
                        <dxchartsui:WebChartControl ID="WC_AdmnStats" runat="server" CrosshairEnabled="True" DataSourceID="ASPxPivotGrid1" Height="500px" SeriesDataMember="Series" Width="900px">
                            <DiagramSerializable>
                                <cc2:XYDiagram>
                                    <AxisX VisibleInPanesSerializable="-1">
                                    </AxisX>
                                    <AxisY Title-Text="student" VisibleInPanesSerializable="-1">
                                    </AxisY>
                                </cc2:XYDiagram>
                            </DiagramSerializable>
                            <Legend MaxHorizontalPercentage="30" Name="Default Legend" Visibility="True"></Legend>
                            <SeriesTemplate ArgumentDataMember="Arguments" ArgumentScaleType="Qualitative" LegendTextPattern="{A}" ValueDataMembersSerializable="Values">
                            </SeriesTemplate>
                            <Titles>
                                <cc2:ChartTitle Font="Tahoma, 20.25pt" Text="CHART OF ENROLLMENT" WordWrap="True" />
                            </Titles>
                        </dxchartsui:WebChartControl>
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <asp:ObjectDataSource ID="Enrollment_ODS" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="EnrollmentAnalysisTableAdapters.acad_Enrollment_AnalysisTableAdapter">
                <SelectParameters>
                    <asp:ControlParameter ControlID="AcadYrComboBox1" Name="acad" PropertyName="Value" Type="String" />
                    <asp:ControlParameter ControlID="semComboBox1" Name="sem" PropertyName="Value" Type="Int32" />
                </SelectParameters>
            </asp:ObjectDataSource>
        </td>
    </tr>
</table>

