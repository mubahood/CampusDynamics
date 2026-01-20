<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ResultsProblems.ascx.cs" Inherits="UserControls_Results_ResultsProblems" %>
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
    .bolder {
        font-weight:bold;
    }
    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
   
            <table class="style1_Bio">
                <tr>
                    <td style="text-align: center">
                        <dx:ASPxLabel ID="lbl_header" runat="server" Font-Bold="True" ForeColor="#FF3300">
                        </dx:ASPxLabel>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: center">
                        <dx:ASPxImage ID="ASPxImage1" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="True" Width="100%">
                        </dx:ASPxImage>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table class="style1_Bio">
                            <tr>
                                <td>
                                    <table class="style1_Bio">
                                        <tr>
                                            <td class="style1_Bio_Results">&nbsp;</td>
                                            <td class="style2_Results">
                                                &nbsp;</td>
                                            <td class="style3_Bio_Results">&nbsp;</td>
                                            <td>
                                                &nbsp;</td>
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
                        <dx:ASPxGridView ID="gvResultsInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvResultsInfo" DataSourceID="dsSemResultsInfo" KeyFieldName="ID" Width="100%" OnDataBound="gvResultsInfo_DataBound">
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
                        &nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsSemResultsInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetResultsProblems" TypeName="ResultsDataTableAdapters.acad_GetSemesterResultsTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="reg" SessionField="reg" Type="String" DefaultValue="-" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
            </table>
       
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>