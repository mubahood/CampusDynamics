<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PurchaseOrders.ascx.cs" Inherits="UserControls_Inventory_PurchaseOrders" %>
<style type="text/css">
    .style11
    {
        width: 205px;
    }
    .style14
    {
        width: 212px;
    }
    .style15
    {
        width: 419px;
    }
</style>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Purchase Orders Center" Width="100%">
            <HeaderImage Url="~/COOPERP/images/newspapers.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" 
                        ImageUrl="~/COOPERP/images/header_purchaseOrder.png">
                    </dx:ASPxImage>
                    <br />
                    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    <table style="width:100%;">
                        <tr>
                            <td width="70">
                                &nbsp;</td>
                            <td width="170">
                                &nbsp;</td>
                            <td width="170">
                                &nbsp;</td>
                            <td width="170">
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td width="70">
                                LPO Date:</td>
                            <td width="170">
                                <dx:ASPxDateEdit ID="txtRunDate" runat="server" AutoPostBack="True">
                                </dx:ASPxDateEdit>
                            </td>
                            <td width="170">
                                &nbsp;</td>
                            <td width="170">
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;</td>
                            <td>
                                <dx:ASPxButton ID="cmdNew" runat="server" OnClick="cmdNew_Click" 
                                    Text="New Order" Width="170px">
                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td>
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                            <td align="right">
                                <dx:ASPxButton ID="cmdPrint" runat="server" Text="Print Order" Width="170px">
                                    <Image Url="~/COOPERP/images/printer.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                    </table>
                    <dx:ASPxGridView ID="gv_purchaseorders" runat="server" 
                        AutoGenerateColumns="False" DataSourceID="ds_purchaseOrders" 
                        KeyFieldName="Po_No" Width="100%" 
                        OnInitNewRow="gv_purchaseorders_InitNewRow">
                        <Columns>
                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                            </dx:GridViewCommandColumn>
                            <dx:GridViewDataTextColumn Caption="Order No" FieldName="Po_No" ReadOnly="True" 
                                ShowInCustomizationForm="True" VisibleIndex="1">
                                <EditFormSettings Visible="False" />
                                <CellStyle HorizontalAlign="Left">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataDateColumn FieldName="DateCreated" 
                                ShowInCustomizationForm="True" VisibleIndex="2">
                                <PropertiesDateEdit DisplayFormatString="dddd, dd MMMM, yyyy">
                                </PropertiesDateEdit>
                            </dx:GridViewDataDateColumn>
                            <dx:GridViewDataTextColumn FieldName="RequestedBy" 
                                ShowInCustomizationForm="True" VisibleIndex="3">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="RequisitionNo" 
                                ShowInCustomizationForm="True" VisibleIndex="4">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataDateColumn FieldName="RequisitionDate" 
                                ShowInCustomizationForm="True" VisibleIndex="5">
                                <PropertiesDateEdit DisplayFormatString="dddd, dd MMMM, yyyy">
                                </PropertiesDateEdit>
                            </dx:GridViewDataDateColumn>
                            <dx:GridViewDataTextColumn FieldName="SupplierID" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="PreparedBy" 
                                ShowInCustomizationForm="True" VisibleIndex="7">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="TermsOfDelivery" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataDateColumn FieldName="DateOfDelivery" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                            </dx:GridViewDataDateColumn>
                            <dx:GridViewDataTextColumn FieldName="TermsOfPayment" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="MethodOfPayment" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="9" Width="10px" ShowEditButton="True" ShowClearFilterButton="True"/>
                            <dx:GridViewDataTextColumn Caption="LPO Items" ShowInCustomizationForm="True" 
                                VisibleIndex="8" Width="30px">
                                <DataItemTemplate>
                                    <asp:ImageButton ID="cmdItems" runat="server" 
                                        ImageUrl="~/COOPERP/images/clipboard-invoice.png" onclick="cmdItems_Click" />
                                </DataItemTemplate>
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
                            AllowSelectSingleRowOnly="True" />
                        <Templates>
                            <EditForm>
                                <table style="width: 100%;">
                                    <tr>
                                        <td class="style14">
                                            Purchase Order No:</td>
                                        <td class="style15">
                                            <dx:ASPxTextBox ID="txtPON" runat="server" Enabled="False" TabIndex="1" 
                                                Text='<%# Bind("Po_No", "{0}") %>' Value='<%# Bind("Po_No") %>' Width="270px">
                                            </dx:ASPxTextBox>
                                        </td>
                                        <td class="style11">
                                            Terms of Delivery</td>
                                        <td>
                                            <dx:ASPxTextBox ID="txtTermsOfDelivery" runat="server" 
                                                Text='<%# Bind("TermsOfDelivery", "{0}") %>' 
                                                Value='<%# Bind("TermsOfDelivery") %>' Width="270px">
                                            </dx:ASPxTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="style14">
                                            Date Created</td>
                                        <td class="style15">
                                            <dx:ASPxDateEdit ID="txtDateCreated" runat="server" 
                                                DisplayFormatString="dd MMMM, yyyy" TabIndex="2" 
                                                Value='<%# Bind("DateCreated") %>' Width="270px">
                                            </dx:ASPxDateEdit>
                                        </td>
                                        <td class="style11">
                                            Date of Delivery</td>
                                        <td>
                                            <dx:ASPxDateEdit ID="txtDateOfDelivery" runat="server" 
                                                DisplayFormatString="dd MMMM, yyyy" Value='<%# Bind("DateOfDelivery") %>' 
                                                Width="270px">
                                            </dx:ASPxDateEdit>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="style14">
                                            Requested By</td>
                                        <td class="style15">
                                            <dx:ASPxTextBox ID="txtRequstedBy" runat="server" TabIndex="3" 
                                                Text='<%# Bind("RequestedBy", "{0}") %>' Value='<%# Bind("RequestedBy") %>' 
                                                Width="270px">
                                            </dx:ASPxTextBox>
                                        </td>
                                        <td class="style11">
                                            Terms of Payment</td>
                                        <td>
                                            <dx:ASPxTextBox ID="txtTermsOfPayment" runat="server" 
                                                Text='<%# Bind("TermsOfPayment", "{0}") %>' 
                                                Value='<%# Bind("TermsOfPayment") %>' Width="270px">
                                            </dx:ASPxTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="style14">
                                            Requistion No:</td>
                                        <td class="style15">
                                            <dx:ASPxTextBox ID="txtRequisitionNo" runat="server" TabIndex="4" 
                                                Text='<%# Bind("RequisitionNo", "{0}") %>' Value='<%# Bind("RequisitionNo") %>' 
                                                Width="270px">
                                            </dx:ASPxTextBox>
                                        </td>
                                        <td class="style11">
                                            Method of Payment</td>
                                        <td>
                                            <dx:ASPxTextBox ID="txtMethodOfPayment" runat="server" TabIndex="10" 
                                                Text='<%# Bind("MethodOfPayment", "{0}") %>' 
                                                Value='<%# Bind("MethodOfPayment") %>' Width="270px">
                                            </dx:ASPxTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="style14">
                                            Requisition Date</td>
                                        <td class="style15">
                                            <dx:ASPxDateEdit ID="txtRequisitionDate" runat="server" 
                                                DisplayFormatString="dd MMMM, yyyy" TabIndex="5" 
                                                Value='<%# Bind("RequisitionDate") %>' Width="270px">
                                            </dx:ASPxDateEdit>
                                        </td>
                                        <td class="style11">
                                            &nbsp;</td>
                                        <td>
                                            <dx:ASPxButton ID="cmdSave" runat="server" onclick="cmdSave_Click" 
                                                TabIndex="11" Text="Save Details" Width="270px">
                                                <Image Url="~/COOPERP/images/disk.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="style14">
                                            Supplier</td>
                                        <td class="style15">
                                            <dx:ASPxComboBox ID="txtSupplierID" runat="server" DataSourceID="ds_supplier" 
                                                TabIndex="6" Text='<%# Bind("SupplierID", "{0}") %>' TextField="SupplierName" 
                                                Value='<%# Bind("SupplierID") %>' ValueField="SupplierCode" 
                                                ValueType="System.UInt32" Width="270px">
                                            </dx:ASPxComboBox>
                                        </td>
                                        <td class="style11">
                                            &nbsp;</td>
                                        <td>
                                            <dx:ASPxButton ID="cmdCancel" runat="server" onclick="cmdCancel_Click" 
                                                TabIndex="12" Text="Cancel" Width="270px">
                                                <Image Url="~/COOPERP/images/clipboard--minus.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="style14">
                                            &nbsp;</td>
                                        <td class="style15">
                                            <asp:ObjectDataSource ID="ds_supplier" runat="server" DeleteMethod="Delete" 
                                                InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                                SelectMethod="GetData" 
                                                TypeName="InventoryDataTableAdapters.inv_supplierdetailsTableAdapter" 
                                                UpdateMethod="Update">
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
                                        <td class="style11">
                                            &nbsp;</td>
                                        <td>
                                            &nbsp;</td>
                                    </tr>
                                </table>
                            </EditForm>
                        </Templates>
                        <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                            <EditButton>
                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                </Image>
                            </EditButton>
                        </SettingsCommandButton>
                    </dx:ASPxGridView>
                    <dx:ASPxPopupControl ID="pop_mgs" runat="server" CloseAction="CloseButton" 
                        HeaderText=".::" Modal="True" PopupHorizontalAlign="WindowCenter" 
                        PopupVerticalAlign="WindowCenter">
                        <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
                        </HeaderImage>
                        <ContentCollection>
                            <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                                <table style="width: 100%;">
                                    <tr>
                                        <td>
                                            &nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: center">
                                            <dx:ASPxImage ID="img_pop" runat="server">
                                            </dx:ASPxImage>
                                            <dx:ASPxLabel ID="lbl_pop" runat="server">
                                            </dx:ASPxLabel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            &nbsp;</td>
                                    </tr>
                                </table>
                            </dx:PopupControlContentControl>
                        </ContentCollection>
                    </dx:ASPxPopupControl>
                    <asp:ObjectDataSource ID="ds_purchaseOrders" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetPurchaseOrdersByDateTableAdapter">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="txtRunDate" Name="dat" PropertyName="Value" 
                                Type="DateTime" />
                        </SelectParameters>
                    </asp:ObjectDataSource>
                    <br />
                </dx:PanelContent>
            </PanelCollection>
        </dx:ASPxRoundPanel>
    </ContentTemplate>
</asp:UpdatePanel>

