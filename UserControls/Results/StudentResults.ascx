<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentResults.ascx.cs" Inherits="UserControls_Results_StudentResults" %>
<style type="text/css">
    .style1_Bio
    {
        width: 100%;
    }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .style2_apps
    {
        width: 80px;
    }
    .style3_Bio
    {
        width: 218px;
    }
    .style4
    {
        width:40px;
    }
    .style5
    {
        width: 1052px;
    }
    .style1_Bio_Results {
        width: 108px;
    }
    .style2_Results {
        width: 104px;
    }
    .style3_Bio_Results {
        width: 65px;
    }
    .auto-style1_Bio {
        width: 46px;
    }
    .auto-style2 {
        width: 82px;
    }
    .auto-style3_Bio {
        width: 63px;
    }
    .auto-style4 {
        width: 106px;
    }
    .auto-style5 {
        width: 113px;
    }
    .bolder {
        font-weight:bold;
    }
    .auto-style7 {
        width: 33px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
   
            <table class="style1_Bio">
                <tr>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <table class="style1_Bio">
                            <tr>
                                <td>
                                    <table class="style1_Bio">
                                        <tr>
                                            <td class="style1_Bio_Results">Year of Study:</td>
                                            <td class="style2_Results">
                                                <dx:ASPxComboBox ID="txtYear" runat="server" SelectedIndex="0" Width="80px">
                                                    <ClientSideEvents CloseUp="function(s, e) {
	gvResultsInfo.Refresh();
	gvSummary.Refresh();
}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                        <dx:ListEditItem Text="5" Value="5" />
                                                        <dx:ListEditItem Text="6" Value="6" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="style3_Bio_Results">Semester:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtSemester" runat="server" SelectedIndex="0" Width="80px">
                                                    <ClientSideEvents CloseUp="function(s, e) {
	gvResultsInfo.Refresh();
	gvSummary.Refresh();
}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" width="170px">
                                    <dx:ASPxTextBox ID="txtSearch" runat="server" AutoCompleteType="Search" Height="27px" NullText="Enter Search Text" Width="170px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	gvCourseInfo.Refresh();
}" />
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxTextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvResultsInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvResultsInfo" DataSourceID="dsSemResultsInfo" KeyFieldName="ID" Width="100%">
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Course Name" FieldName="coursename" VisibleIndex="3" Width="350px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="ID" VisibleIndex="5" ReadOnly="True" Visible="False">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Code" FieldName="courseid" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Academic Year" FieldName="acad" VisibleIndex="8">
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Mark" VisibleIndex="10" FieldName="score">
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" VisibleIndex="11">
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="GradePt" FieldName="gradept" VisibleIndex="12">
                                    <PropertiesTextEdit DisplayFormatString="{0:0.0}">
                                    </PropertiesTextEdit>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Comment" FieldName="result_comment" VisibleIndex="14">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="CreditUnits" VisibleIndex="4">
                                    <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                    </PropertiesTextEdit>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="1" Width="20px">
                                </dx:GridViewCommandColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvSummary" runat="server" AutoGenerateColumns="False" DataSourceID="dsSemesterSummary" Width="100%" ClientInstanceName="gvSummary">
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="gpa" ShowInCustomizationForm="True" VisibleIndex="0">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="cgpa" ShowInCustomizationForm="True" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="awardClass" ShowInCustomizationForm="True" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <Settings ShowColumnHeaders="False" />
                            <Templates>
                                <DataRow>
                                    <table class="style1_Bio">
                                        <tr>
                                            <td class="auto-style7">&nbsp;</td>
                                            <td class="auto-style1_Bio bolder">GPA:</td>
                                            <td class="auto-style2">
                                                <asp:Label ID="gpaLabel" runat="server" ForeColor="Maroon" Text='<%# Eval("gpa", "{0:0.00}") %>' />
                                            </td>
                                            <td class="auto-style3_Bio bolder">CGPA:</td>
                                            <td class="auto-style4">
                                                <asp:Label ID="cgpaLabel" runat="server" ForeColor="Maroon" Text='<%# Eval("cgpa", "{0:0.00}") %>' />
                                            </td>
                                            <td class="auto-style5 bolder">CURRENT CLASS:</td>
                                            <td>
                                                <asp:Label ID="awardClassLabel" runat="server" ForeColor="Maroon" Text='<%# Eval("awardClass") %>' />
                                            </td>
                                        </tr>
                                    </table>
                                </DataRow>
                            </Templates>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsSemResultsInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ResultsDataTableAdapters.acad_GetSemesterResultsTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="reg" SessionField="regno" Type="String" />
                                <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsSemesterSummary" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ResultsDataTableAdapters.acad_SemesterSummaryTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="reg" SessionField="regno" Type="String" />
                                <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
            </table>
       
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>