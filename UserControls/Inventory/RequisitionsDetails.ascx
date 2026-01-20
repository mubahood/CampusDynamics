<%@ Control Language="C#" AutoEventWireup="true" CodeFile="RequisitionsDetails.ascx.cs" Inherits="UserControls_Inventory_InventoryRequisitions" %>
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


        .style10
    {
        height: 29px;
    }
    

        </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="School Branches" ShowCollapseButton="true" Width="100%" 
    ShowHeader="False">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <%--<asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>--%>
            <table class="style1">
                <tr>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td align="right">
                        <table class="style1">
                            <tr>
                                <td align="left" class="style10">
                                    <dx:ASPxButton ID="cmdPostLedger" runat="server" OnClick="cmdPostLedger_Click" 
                                        Text="Add New Items" Width="170px" Height="35px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td align="right" class="style10">
                                    &nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvBranchData" runat="server" AutoGenerateColumns="False" 
                            ClientInstanceName="gvBranchData" DataSourceID="dsTermlyRequisitions" 
                            EnableCallBacks="False" KeyFieldName="ID" style="margin-right: 0px" 
                            Width="100%" OnBatchUpdate="gvBranchData_BatchUpdate" 
                            OnRowUpdated="gvBranchData_RowUpdated" OnRowUpdating="gvBranchData_RowUpdating" OnHtmlRowPrepared="gvBranchData_HtmlRowPrepared">
                            <TotalSummary>
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="boarderfees" 
                                    ShowInColumn="Boarders Fees" ShowInGroupFooterColumn="Boarders Fees" 
                                    SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="commitment" 
                                    ShowInColumn="Commitment Fees" ShowInGroupFooterColumn="Commitment Fees" 
                                    SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="foreignfees" 
                                    ShowInColumn="Foreigner Fees" ShowInGroupFooterColumn="Foreigner Fees" 
                                    SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="islamfees" 
                                    ShowInColumn="Islam Fees" ShowInGroupFooterColumn="Islam Fees" 
                                    SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="sponsored" 
                                    ShowInColumn="Sponsored Fees" ShowInGroupFooterColumn="Sponsored Fees" 
                                    SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="totalfees" 
                                    ShowInColumn="Tuition Fees" ShowInGroupFooterColumn="Tuition Fees" 
                                    SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="grandTotal" 
                                    ShowInColumn="Total Expected Amount" 
                                    ShowInGroupFooterColumn="Total Expected Amount" SummaryType="Sum" 
                                    ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="totalfees" 
                                    ShowInColumn="Day Fees" ShowInGroupFooterColumn="Day Fees" SummaryType="Sum" 
                                    ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="dayCareFees" 
                                    ShowInColumn="Day Care Fees" ShowInGroupFooterColumn="Day Care Fees" 
                                    SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                            </TotalSummary>
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="SNo" FieldName="ID" ReadOnly="True" 
                                    VisibleIndex="0" Width="30px">
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="reqID" Visible="False" 
                                    VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="itemCode" Visible="False" 
                                    VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="qty" 
                                    VisibleIndex="9" Caption="Req. Qty" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="details" Visible="False" 
                                    VisibleIndex="13" Caption="Comments">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="ItemName" 
                                    VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Budgeted Qty" FieldName="budget_qty" 
                                    VisibleIndex="6" Width="50px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Qty Before" FieldName="curr_qty" 
                                    ShowInCustomizationForm="True" VisibleIndex="8" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Received" FieldName="actual_qty" 
                                    ShowInCustomizationForm="True" VisibleIndex="10" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Bal After" FieldName="bal_qty" 
                                    ShowInCustomizationForm="True" VisibleIndex="11" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="req_qty" ShowInCustomizationForm="True" 
                                    Visible="False" VisibleIndex="12">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Already Taken" FieldName="taken_qty" 
                                    ShowInCustomizationForm="True" VisibleIndex="7" Width="50px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn Name="comm" ShowDeleteButton="True" 
                                    ShowInCustomizationForm="True" VisibleIndex="14" Width="30px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Units" FieldName="unit" 
                                    ShowInCustomizationForm="True" VisibleIndex="5" Width="50px">
                                    <PropertiesComboBox DataSourceID="ds_AllUnits" TextField="UnitName" 
                                        TextFormatString="{1}" ValueField="UnitCode">
                                        <Columns>
                                            <dx:ListBoxColumn FieldName="UnitCode" />
                                            <dx:ListBoxColumn FieldName="UnitName" />
                                        </Columns>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsEditing Mode="Batch">
                                <BatchEditSettings StartEditAction="DblClick" />
                            </SettingsEditing>
                            <Settings ShowFilterRowMenu="True" ShowFooter="True" />
                            <SettingsSearchPanel Visible="True" />
                            <SettingsText CommandCancel="Cancel" CommandDelete="Delete" 
                                CommandEdit="Edit | " CommandUpdate="Save Changes | " />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsTermlyRequisitions" runat="server" DeleteMethod="Delete" 
                            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                            SelectMethod="GetRequisitionDetails" 
                            TypeName="SchoolInventoryTableAdapters.inv_schoolreqdetailsTableAdapter" 
                            UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="reqID" Type="UInt32" />
                                <asp:Parameter Name="itemCode" Type="UInt32" />
                                <asp:Parameter Name="qty" Type="Double" />
                                <asp:Parameter Name="unit" Type="UInt32" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="budget_qty" Type="Double" />
                                <asp:Parameter Name="curr_qty" Type="Double" />
                                <asp:Parameter Name="actual_qty" Type="Double" />
                                <asp:Parameter Name="bal_qty" Type="Double" />
                                <asp:Parameter Name="req_qty" Type="Double" />
                                <asp:Parameter Name="taken_qty" Type="Double" />
                                <asp:Parameter Name="locationCode" Type="UInt32" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:SessionParameter DefaultValue="0" Name="rid" SessionField="rid" 
                                    Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="reqID" Type="UInt32" />
                                <asp:Parameter Name="itemCode" Type="UInt32" />
                                <asp:Parameter Name="qty" Type="Double" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="budget_qty" Type="Double" />
                                <asp:Parameter Name="curr_qty" Type="Double" />
                                <asp:Parameter Name="actual_qty" Type="Double" />
                                <asp:Parameter Name="bal_qty" Type="Double" />
                                <asp:Parameter Name="req_qty" Type="Double" />
                                <asp:Parameter Name="taken_qty" Type="Double" />
                                <asp:Parameter Name="locationCode" Type="UInt32" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsSchools" runat="server" 
                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                            TypeName="school_groupTableAdapters.school_branchesTableAdapter">
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="ds_AllUnits" runat="server" 
                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                            TypeName="InventoryDataTableAdapters.inv_itemunitsTableAdapter">
                        </asp:ObjectDataSource>
                        <dx:ASPxGridViewExporter ID="Exporter" runat="server" GridViewID="gvBranchData" 
                            PaperKind="A4">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" 
                            HeaderText="School Dynamics Version 1.0" Modal="True" 
                            PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                            Width="300px">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvBranchData.Refresh();
}" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                &nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                                </dx:ASPxLabel>
                                                <br />
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <br />
                                            </td>
                                        </tr>
                                    </table>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_postLedger" runat="server" 
                            HeaderText="School Dynamics Version 1.0" Modal="True" 
                            PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                            Width="400px">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvBranchData.Refresh();
}" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                &nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <table class="style1">
                                                    <tr>
                                                        <td>
                                                            Item Category:</td>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtItemCategory" runat="server" Width="250px" 
                                                                AutoPostBack="True" DataSourceID="dsCategories" 
                                                                OnSelectedIndexChanged="txtItemCategory_SelectedIndexChanged" SelectedIndex="0" 
                                                                TextField="ItemGroupName" TextFormatString="{1}" ValueField="ItemGroupCode">
                                                                <Columns>
                                                                    <dx:ListBoxColumn Caption="Code" FieldName="ItemGroupCode" Width="50px" />
                                                                    <dx:ListBoxColumn Caption="Category" FieldName="ItemGroupName" Width="150px" />
                                                                </Columns>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Item Name:</td>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtItemName" runat="server" Width="250px" 
                                                                DataSourceID="dsItems" TextField="ItemName" 
                                                                TextFormatString="{1}" ValueField="ItemCode" 
                                                                OnSelectedIndexChanged="txtItemName_SelectedIndexChanged" AutoPostBack="True">
                                                                <Columns>
                                                                    <dx:ListBoxColumn FieldName="ItemCode" Width="60px" />
                                                                    <dx:ListBoxColumn FieldName="ItemName" Width="150px" />
                                                                    <dx:ListBoxColumn FieldName="ItemShortName" Width="60px" />
                                                                </Columns>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Units:</td>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtUnit" runat="server" AutoPostBack="True" 
                                                                DataSourceID="ds_Units" SelectedIndex="0" TabIndex="2" TextField="Unit" 
                                                                ValueField="UnitCode" ValueType="System.Int32" Width="250px">
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Store:</td>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtlocation" runat="server" DataSourceID="ds_location" 
                                                                SelectedIndex="0" TabIndex="4" TextField="ShortName" TextFormatString="{1}" 
                                                                ValueField="LocationCode" ValueType="System.Int32" Width="250px">
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            &nbsp;</td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdAddItem" runat="server" OnClick="cmdAddItem_Click" 
                                                                Text="Add Item" Width="250px">
                                                                <Image Url="~/COOPERP/images/tick-button.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <asp:ObjectDataSource ID="dsCategories" runat="server" 
                                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                                                    TypeName="SchoolInventoryTableAdapters.inv_itemgroupTableAdapter">
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="dsItems" runat="server" 
                                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetItemsByGroup" 
                                                    TypeName="SchoolInventoryTableAdapters.inv_itemdetailsTableAdapter">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtItemCategory" Name="Code" 
                                                            PropertyName="Value" Type="Int32" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="ds_Units" runat="server" 
                                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                                                    TypeName="InventoryDataTableAdapters.inv_GetItemPrimaryUnitTableAdapter">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtItemName" Name="ICD" PropertyName="Value" 
                                                            Type="Int32" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="ds_location" runat="server" 
                                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                                                    TypeName="InventoryDataTableAdapters.inv_storelocationTableAdapter">
                                                </asp:ObjectDataSource>
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center">
                                                <dx:ASPxLabel ID="lbl_msg_post" runat="server" Font-Bold="True" ForeColor="Red">
                                                </dx:ASPxLabel>
                                                <br />
                                            </td>
                                        </tr>
                                    </table>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
            </table>
        <%--</ContentTemplate>
    </asp:UpdatePanel>--%>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>