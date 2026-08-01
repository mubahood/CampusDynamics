<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DocumentCentre.ascx.cs" Inherits="UserControls_Accounts_DocumentCentre" %>
<style type="text/css">

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
}

.style1
{
    width: 100%;
}

.auto-style1
{
    width: 90px;
}

.auto-style3
{
    width: 220px;
}

.auto-style4
{
    width: 80px;
}

.filterInputCell
{
    width: 220px;
}

.filterSpacer
{
    width: 35px;
}
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" Width="100%">
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <table class="style1">
                <tr>
                    <td>
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                        ImageUrl="~/COOPERP/images/header_documents.png">
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
                        <table cellpadding="2" cellspacing="0">
                            <tr>
                                <td class="auto-style1">Document:</td>
                                <td class="auto-style3">
                                    <dx:ASPxComboBox ID="txtDocumentType" runat="server" AutoPostBack="True" 
                                        EnableIncrementalFiltering="True" IncrementalFilteringMode="StartsWith" 
                                        SelectedIndex="1" ValueType="System.String" Width="210px">
                                        <Items>
                                            <dx:ListEditItem Text="Trial Balance" Value="Trial Balance" />
                                            <dx:ListEditItem Selected="True" Text="Statement of Income and Expenditure" Value="Income Statement" />
                                            <dx:ListEditItem Text="Statement of Financial Position (Balance Sheet)" Value="Balance Sheet" />
                                            <dx:ListEditItem Text="Statement of Cash Flows" Value="Cash Flow Statement" />
                                            <dx:ListEditItem Text="Cashbook" Value="Cashbook" />
                                            <dx:ListEditItem Text="General Ledger" Value="General Ledger" />
                                            <dx:ListEditItem Text="Payments Report" Value="Payments" />
                                            <dx:ListEditItem Text="Receivables / Defaulters" Value="Defaulters" />
                                            <dx:ListEditItem Text="Payables" Value="Payables" />
                                            <dx:ListEditItem Text="Statement of Changes in Fund / Equity" Value="Statement of Changes in Fund" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="filterSpacer">&nbsp;</td>
                                <td class="auto-style4">Start Date:</td>
                                <td class="filterInputCell">
                                    <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" Width="210px">
                                    </dx:ASPxDateEdit>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style3">
                                    <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" 
                                        Text="Print" Width="210px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="filterSpacer">&nbsp;</td>
                                <td class="auto-style4">End Date:</td>
                                <td class="filterInputCell">
                                    <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" Width="210px">
                                    </dx:ASPxDateEdit>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style3">
                                    <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red">
                                    </dx:ASPxLabel>
                                </td>
                                <td class="filterSpacer">&nbsp;</td>
                                <td class="auto-style4">&nbsp;</td>
                                <td class="filterInputCell">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvDocumentPreview" runat="server" AutoGenerateColumns="False" 
                            Width="100%" EnableViewState="False">
                            <SettingsBehavior AllowFocusedRow="False" />
                            <SettingsPager PageSize="20" AlwaysShowPager="True" Position="Bottom">
                            </SettingsPager>
                            <Settings ShowFilterRow="True" ShowFooter="True" ShowGroupPanel="False" />
                            <SettingsText EmptyDataRow="No records found for the selected document and date range." />
                        </dx:ASPxGridView>
                        <dx:ASPxGridViewExporter ID="gvDocumentPreviewExporter" runat="server" 
                            ExportedRowType="All" GridViewID="gvDocumentPreview">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_receipts" runat="server" HeaderText="" 
                            PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                            ContentUrl="~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx">
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsProducts" runat="server" 
                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                            TypeName="CoopERPDataTableAdapters.fin_productsTableAdapter">
                        </asp:ObjectDataSource>
                    </td>
                </tr>
            </table>
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
