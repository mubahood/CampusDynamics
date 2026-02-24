<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SupplierLedgers.ascx.cs" Inherits="UserControls_Inventory_SupplierLedgers" %>
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


    .ledger_style2
    {
        width: 52px;
    }
    .style4
    {
        width: 174px;
    }
    .auto-style2 {
        width: 106px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Student Legder Centre" Width="100%" ShowHeader="False">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table id="table1" cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_supplier_ledger.png" >
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style2">
                            Start Date:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" Height="27px" Width="170px" DisplayFormatString="dd MMMM, yyyy" AutoPostBack="True">
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style2">
                            End Date:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" Height="27px" Width="170px" DisplayFormatString="dd MMMM, yyyy" AutoPostBack="True">
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
                        <td align="right">
                            <dx:ASPxButton ID="cmdExport" runat="server" OnClick="cmdExport_Click" 
                                Text="Export to Excel" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/document-excel-table.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">&nbsp;</td>
                        <td class="style4">&nbsp;</td>
                        <td>&nbsp;</td>
                        <td align="right">
                            <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" 
                                Text="Print  Summary" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gv_supplier" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="ds_supplier" KeyFieldName="SupplierCode" Width="100%" OnHtmlDataCellPrepared="gv_supplier_HtmlDataCellPrepared" OnCustomUnboundColumnData="gv_supplier_CustomUnboundColumnData">
                    <SettingsCommandButton>
                        <UpdateButton RenderMode="Link">
                        </UpdateButton>
                        <CancelButton RenderMode="Link">
                        </CancelButton>
                        <EditButton>
                            <Image Url="~/COOPERP/images/clipboard--pencil.png">
                            </Image>
                        </EditButton>
                        <DeleteButton>
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </DeleteButton>
                    </SettingsCommandButton>
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="SupplierCode" 
                            ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="100px">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
<dx:GridViewDataTextColumn FieldName="SupplierName" ShowInCustomizationForm="True" VisibleIndex="1" Width="250px"></dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="BoxNo" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Visible="False" Width="170px">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn ShowInCustomizationForm="True" 
                            VisibleIndex="3" Width="170px" FieldName="Address">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="PhoneContact" ShowInCustomizationForm="True" VisibleIndex="4" Width="170px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Email" 
                            ShowInCustomizationForm="True" VisibleIndex="5" Visible="False">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Website" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="TIN" FieldName="TIN_No" ShowInCustomizationForm="True" VisibleIndex="7" Width="170px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="VAT No" FieldName="VAT_No" ShowInCustomizationForm="True" VisibleIndex="8" Width="170px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Running Balance" FieldName="FinalBalance" ShowInCustomizationForm="True" VisibleIndex="9" Width="150px" UnboundType="String">
                            <HeaderStyle HorizontalAlign="Right" />
                            <CellStyle HorizontalAlign="Right">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Ledger" ShowInCustomizationForm="True" VisibleIndex="10" Width="25px">
                            <DataItemTemplate>
                                <asp:ImageButton ID="imgButton" runat="server" ImageUrl="~/COOPERP/images/clipboard-invoice.png" OnClick="cmdLedger_Click" />
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <Settings ShowFilterRowMenu="True" />
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridViewExporter ID="Exporter" runat="server" GridViewID="gv_supplier" 
                    PaperKind="A4" Landscape="True">
                </dx:ASPxGridViewExporter>
                <dx:ASPxGridView ID="gv_allLedgers" runat="server" AutoGenerateColumns="False" 
                    Width="100%" Visible="False" KeyFieldName="RowID"
                    OnHtmlDataCellPrepared="gv_allLedgers_HtmlDataCellPrepared">
                    <SettingsPager Mode="ShowAllRecords" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="SupplierName" Caption="Supplier" VisibleIndex="0" Width="200px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="EntryDate" Caption="Entry Date" VisibleIndex="1" Width="120px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="InvoiceDate" Caption="Invoice Date" VisibleIndex="2" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Particulars" Caption="Particulars" VisibleIndex="3" Width="250px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="VoucherNo" Caption="Journal No" VisibleIndex="4" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="DR" Caption="DR" VisibleIndex="5" Width="100px">
                            <CellStyle HorizontalAlign="Right" />
                            <HeaderStyle HorizontalAlign="Right" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="CR" Caption="CR" VisibleIndex="6" Width="100px">
                            <CellStyle HorizontalAlign="Right" />
                            <HeaderStyle HorizontalAlign="Right" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Balance" Caption="Balance" VisibleIndex="7" Width="120px">
                            <CellStyle HorizontalAlign="Right" />
                            <HeaderStyle HorizontalAlign="Right" />
                        </dx:GridViewDataTextColumn>
                    </Columns>
                </dx:ASPxGridView>
                <dx:ASPxGridViewExporter ID="ExporterAll" runat="server" GridViewID="gv_allLedgers" 
                    PaperKind="A4" Landscape="True">
                </dx:ASPxGridViewExporter>
                <asp:ObjectDataSource ID="ds_supplier" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_supplierdetailsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_SupplierCode" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="SupplierName" Type="String" />
                        <asp:Parameter Name="BoxNo" Type="String" />
                        <asp:Parameter Name="Address" Type="String" />
                        <asp:Parameter Name="PhoneContact" Type="String" />
                        <asp:Parameter Name="Email" Type="String" />
                        <asp:Parameter Name="Website" Type="String" />
                        <asp:Parameter Name="TIN_No" Type="String" />
                        <asp:Parameter Name="VAT_No" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="SupplierName" Type="String" />
                        <asp:Parameter Name="BoxNo" Type="String" />
                        <asp:Parameter Name="Address" Type="String" />
                        <asp:Parameter Name="PhoneContact" Type="String" />
                        <asp:Parameter Name="Email" Type="String" />
                        <asp:Parameter Name="Website" Type="String" />
                        <asp:Parameter Name="TIN_No" Type="String" />
                        <asp:Parameter Name="VAT_No" Type="String" />
                        <asp:Parameter Name="Original_SupplierCode" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" CloseAction="CloseButton" 
                    ContentUrl="~/COOPERP/financials/billitems.aspx" HeaderText="" Modal="True" 
                    PopupElementID="btn_billitems" PopupHorizontalAlign="WindowCenter" 
                    PopupVerticalAlign="WindowCenter">
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server" SupportsDisabledAttribute="True">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

