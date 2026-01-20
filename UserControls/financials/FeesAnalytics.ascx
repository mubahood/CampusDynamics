<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FeesAnalytics.ascx.cs" Inherits="UserControls_financials_FeesCollectionAnalysis" %>

<style type="text/css">



        .style1
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


        .auto-style1 {
        width: 86px;
    }
    .auto-style4 {
        width: 198px;
    }
    .auto-style5 {
        width: 71px;
    }
    .auto-style6 {
        width: 186px;
    }
    .auto-style7 {
        width: 67px;
    }


        .auto-style8 {
        width: 86px;
        height: 18px;
    }
    .auto-style9 {
        width: 198px;
        height: 18px;
    }
    .auto-style10 {
        width: 71px;
        height: 18px;
    }
    .auto-style11 {
        width: 186px;
        height: 18px;
    }
    .auto-style12 {
        width: 67px;
        height: 18px;
    }
    .auto-style13 {
        height: 18px;
    }


        </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_fees_analysis_centre.png">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style1">Start Date:</td>
                        <td class="auto-style4">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" DisplayFormatString="dd MMMM, yyyy" Height="35px">
                            </dx:ASPxDateEdit>
                        </td>
                        <td class="auto-style5">End Date:</td>
                        <td class="auto-style6">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" DisplayFormatString="dd MMMM, yyyy" Height="35px">
                            </dx:ASPxDateEdit>
                        </td>
                        <td class="auto-style7">
                            <dx:ASPxButton ID="cmdRefresh" runat="server" Height="35px" OnClick="cmdRefresh_Click" Text="Refresh" Width="170px">
                                <ClientSideEvents Click="function(s, e) {
	lp_fees.Show();
}" />
                                <Image Url="~/COOPERP/images/arrow-retweet.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">&nbsp;</td>
                        <td class="auto-style4">&nbsp;</td>
                        <td class="auto-style5">&nbsp;</td>
                        <td class="auto-style6">&nbsp;</td>
                        <td class="auto-style7">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                    <TabPages>
                        <dx:TabPage Text="Regular Fees Analysis">
                            <ContentCollection>
                                <dx:ContentControl ID="ContentControl1" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdExportExcel" runat="server" OnClick="cmdExportExcel_Click" Text="Export to Excel" Width="170px">
                                                    <Image Url="~/COOPERP/images/document-excel-table.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxPivotGrid ID="PG_FeesAnalysis" runat="server" ClientIDMode="AutoID" DataSourceID="dsFeesAnalysis" Width="100%">
                                                    <Fields>
                                                        <dx:PivotGridField ID="fieldtotalbills" Area="DataArea" AreaIndex="0" Caption="Total Bill" CellFormat-FormatString="{0:0,0}" CellFormat-FormatType="Numeric" FieldName="total_bills" TotalValueFormat-FormatString="{0:0,0}" TotalValueFormat-FormatType="Numeric" ValueFormat-FormatString="{0:0,0}" ValueFormat-FormatType="Numeric" AllowedAreas="DataArea">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldcampus1" Area="ColumnArea" AreaIndex="0" Caption="Campus" FieldName="campus">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldfaculty" Area="RowArea" AreaIndex="0" Caption="Faculty" FieldName="faculty">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldprogramme" AreaIndex="0" Caption="Programme" FieldName="programme">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldtotalpay" Area="DataArea" AreaIndex="1" Caption="Total Pay" CellFormat-FormatString="{0:0,0}" CellFormat-FormatType="Numeric" FieldName="total_pay" TotalCellFormat-FormatString="{0:0,0}" TotalCellFormat-FormatType="Numeric" ValueFormat-FormatString="{0:0,0}" ValueFormat-FormatType="Numeric">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldopening" AreaIndex="1" Caption="Opening Balance" CellFormat-FormatString="{0:0,0}" CellFormat-FormatType="Numeric" FieldName="opening" TotalCellFormat-FormatString="{0:0,0}" TotalCellFormat-FormatType="Numeric" TotalValueFormat-FormatString="{0:0,0}" TotalValueFormat-FormatType="Numeric">
                                                        </dx:PivotGridField>
                                                        <dx:PivotGridField ID="fieldtotalpending" AreaIndex="2" Caption="Total Outstanding" CellFormat-FormatString="{0:0,0}" CellFormat-FormatType="Numeric" FieldName="total_pending" TotalCellFormat-FormatString="{0:0,0}" TotalCellFormat-FormatType="Numeric" TotalValueFormat-FormatString="{0:0,0}" TotalValueFormat-FormatType="Numeric" ValueFormat-FormatString="{0:0,0}" ValueFormat-FormatType="Numeric">
                                                        </dx:PivotGridField>
                                                    </Fields>
                                                    <OptionsPager RowsPerPage="50">
                                                    </OptionsPager>
                                                </dx:ASPxPivotGrid>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                    </TabPages>
                </dx:ASPxPageControl>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsFeesAnalysis" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAnalyticsByUser" TypeName="FinancialAnalyticsTableAdapters.fin_fees_analysis_semesterTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="Int32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="programme" Type="String" />
                        <asp:Parameter Name="faculty" Type="String" />
                        <asp:Parameter Name="campus" Type="String" />
                        <asp:Parameter Name="s_date" Type="DateTime" />
                        <asp:Parameter Name="e_date" Type="DateTime" />
                        <asp:Parameter Name="opening" Type="Double" />
                        <asp:Parameter Name="total_bills" Type="Double" />
                        <asp:Parameter Name="total_pay" Type="Double" />
                        <asp:Parameter Name="created_by" Type="String" />
                        <asp:Parameter Name="total_pending" Type="Double" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="-" Name="usr" SessionField="username" Type="String" />
                        <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="programme" Type="String" />
                        <asp:Parameter Name="faculty" Type="String" />
                        <asp:Parameter Name="campus" Type="String" />
                        <asp:Parameter Name="s_date" Type="DateTime" />
                        <asp:Parameter Name="e_date" Type="DateTime" />
                        <asp:Parameter Name="opening" Type="Double" />
                        <asp:Parameter Name="total_bills" Type="Double" />
                        <asp:Parameter Name="total_pay" Type="Double" />
                        <asp:Parameter Name="created_by" Type="String" />
                        <asp:Parameter Name="total_pending" Type="Double" />
                        <asp:Parameter Name="Original_ID" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxPivotGridExporter ID="PE_FeesAnalysis" runat="server" ASPxPivotGridID="PG_FeesAnalysis">
                    <OptionsPrint>
                        <PageSettings Landscape="True" PaperKind="A4" />
                    </OptionsPrint>
                </dx:ASPxPivotGridExporter>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxLoadingPanel ID="lp_fees" runat="server" ClientInstanceName="lp_fees" Modal="True" Text="Processing. Please wait&amp;hellip;">
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
