<%@ Control Language="C#" AutoEventWireup="true" CodeFile="lnventoryBudgets.ascx.cs" Inherits="UserControls_schools_lnventoryBudgets" %>
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
    .style11
    {
        width: 67px;
    }
    .style16
    {
        height: 29px;
        width: 92px;
    }
    .style17
    {
        width: 177px;
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
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                        ImageUrl="~/COOPERP/images/header_inv_budget.png">
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
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td align="right">
                        <table class="style1">
                            <tr>
                                <td align="left" class="style11">
                                    Fin. Year:</td>
                                <td align="left" class="style17">
                                    <dx:ASPxComboBox ID="txtYear" runat="server" AutoPostBack="True" Width="170px" Height="35px">
                                    </dx:ASPxComboBox>
                                </td>
                                <td align="left" class="style16">
                                    Department:</td>
                                <td align="left" class="style10">
                                    <dx:ASPxComboBox ID="txtSchool" runat="server" AutoPostBack="True" 
                                        DataSourceID="dsSchools" SelectedIndex="0" TextField="branch_name" 
                                        TextFormatString="{1}" ValueField="ID" ValueType="System.Int32" 
                                        Width="250px" Height="35px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="SNo" FieldName="ID" Width="25px" />
                                            <dx:ListBoxColumn Caption="Department" FieldName="dept_name" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td align="right" class="style10">
                                    <dx:ASPxButton ID="cmdPostLedger0" runat="server" OnClick="cmdPostLedger_Click" 
                                        Text="Post Bills" Width="170px" Height="35px">
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" class="style11">
                                    Term:</td>
                                <td align="left" class="style17">
                                    <dx:ASPxComboBox ID="txtTerm" runat="server" AutoPostBack="True" 
                                        SelectedIndex="0" Width="170px" Height="35px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td align="left" class="style16">
                                    &nbsp;</td>
                                <td align="left">
                                    <dx:ASPxButton ID="cmdPostLedger" runat="server" OnClick="cmdPostLedger_Click" 
                                        Text="Add New Items" Width="250px" Height="35px">
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td align="right" class="style10">
                                    <dx:ASPxButton ID="cmdExport" runat="server" OnClick="cmdExport_Click" 
                                        Text="Export to Excel" Width="170px" Height="35px">
                                        <Image Url="~/COOPERP/images/document-excel-table.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" class="style11">
                                    &nbsp;</td>
                                <td align="left" class="style17">
                                    &nbsp;</td>
                                <td align="left" class="style16">
                                    &nbsp;</td>
                                <td align="left">
                                    &nbsp;</td>
                                <td align="right" class="style10">
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
                        <dx:ASPxGridView ID="gvBranchData" runat="server" AutoGenerateColumns="False" 
                            ClientInstanceName="gvBranchData" DataSourceID="dsTermlyBudgets" 
                            EnableCallBacks="False" KeyFieldName="ID" style="margin-right: 0px" 
                            Width="100%">
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
                                    VisibleIndex="1" Width="60px">
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="branchID" Visible="False" 
                                    VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="term" Visible="False" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="budget_year" Visible="False" 
                                    VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="item_code" Visible="False" 
                                    VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Budget Quantity" FieldName="budget_amount" 
                                    VisibleIndex="7" Width="80px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Received Qty" FieldName="total_requisition" 
                                    VisibleIndex="8" Width="80px">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Item Name" FieldName="ItemName" 
                                    VisibleIndex="2">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="0" 
                                    Width="20px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewCommandColumn ShowDeleteButton="True" VisibleIndex="10" 
                                    Width="60px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Balance" FieldName="balance" 
                                    ShowInCustomizationForm="True" VisibleIndex="9" Width="80px">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsEditing Mode="Batch">
                                <BatchEditSettings StartEditAction="DblClick" />
                            </SettingsEditing>
                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowFooter="True" />
                            <SettingsText CommandCancel="Cancel" CommandDelete="Delete" 
                                CommandEdit="Edit | " CommandUpdate="Save Changes | " />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsTermlyBudgets" runat="server" DeleteMethod="Delete" 
                            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                            SelectMethod="GetSchoolAnnualBudget" 
                            TypeName="SchoolInventoryTableAdapters.inv_budgetrequisitionsTableAdapter" 
                            UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="branchID" Type="UInt32" />
                                <asp:Parameter Name="term" Type="UInt32" />
                                <asp:Parameter Name="budget_year" Type="String" />
                                <asp:Parameter Name="item_code" Type="UInt32" />
                                <asp:Parameter Name="budget_amount" Type="Double" />
                                <asp:Parameter Name="total_requisition" Type="Double" />
                                <asp:Parameter Name="balance" Type="Double" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtSchool" Name="bid" PropertyName="Value" 
                                    Type="Int32" />
                                <asp:ControlParameter ControlID="txtTerm" Name="trm" PropertyName="Value" 
                                    Type="Int32" />
                                <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" 
                                    Type="String" DefaultValue="-" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="branchID" Type="UInt32" />
                                <asp:Parameter Name="term" Type="UInt32" />
                                <asp:Parameter Name="budget_year" Type="String" />
                                <asp:Parameter Name="item_code" Type="UInt32" />
                                <asp:Parameter Name="budget_amount" Type="Double" />
                                <asp:Parameter Name="total_requisition" Type="Double" />
                                <asp:Parameter Name="balance" Type="Double" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsLedgers" runat="server" DeleteMethod="Delete" 
                            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                            SelectMethod="GetGLDetailsByType" 
                            TypeName="school_groupTableAdapters.school_gldetailsTableAdapter" 
                            UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="branchID" Type="String" />
                                <asp:Parameter Name="GLAccountNo" Type="String" />
                                <asp:Parameter Name="ledgerType" Type="String" />
                                <asp:Parameter Name="ledgername" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtSchool" Name="BID" PropertyName="Value" 
                                    Type="String" />
                                <asp:Parameter DefaultValue="Bill" Name="type" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="branchID" Type="String" />
                                <asp:Parameter Name="GLAccountNo" Type="String" />
                                <asp:Parameter Name="ledgerType" Type="String" />
                                <asp:Parameter Name="ledgername" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsSchools" runat="server" 
                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                            TypeName="InventoryDataTableAdapters.fin_departmentTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="dept_name" Type="String" />
                                <asp:Parameter Name="dept_head" Type="Int32" />
                                <asp:Parameter Name="dept_notes" Type="String" />
                            </InsertParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="dept_name" Type="String" />
                                <asp:Parameter Name="dept_head" Type="Int32" />
                                <asp:Parameter Name="dept_notes" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <dx:ASPxGridViewExporter ID="Exporter" runat="server" GridViewID="gvBranchData" 
                            PaperKind="A4">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" 
                            HeaderText="Schol Dynamics" Modal="True" 
                            PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                            Width="300px">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvBranchData.Refresh();
}" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
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
                            HeaderText="Campus Dynamics" Modal="True" 
                            PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                            Width="400px">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvBranchData.Refresh();
}" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
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
                                                            &nbsp;</td>
                                                        <td>
                                                            <dx:ASPxCheckBox ID="txtSingleItem" runat="server" AutoPostBack="True" 
                                                                CheckState="Unchecked" OnCheckedChanged="txtSingleItem_CheckedChanged" 
                                                                Text="Add All Items">
                                                            </dx:ASPxCheckBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Item Category:</td>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtItemCategory" runat="server" AutoPostBack="True" 
                                                                DataSourceID="dsCategories" 
                                                                OnSelectedIndexChanged="txtItemCategory_SelectedIndexChanged" SelectedIndex="0" 
                                                                TextField="ItemGroupName" TextFormatString="{1}" ValueField="ItemGroupCode" 
                                                                Width="250px">
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
                                                            <dx:ASPxComboBox ID="txtItemName" runat="server" DataSourceID="dsItems" 
                                                                SelectedIndex="0" TextField="ItemName" TextFormatString="{1}" 
                                                                ValueField="ItemCode" Width="250px">
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
                                                            &nbsp;</td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdAddItem" runat="server" OnClick="cmdAddItem_Click" 
                                                                Text="Add Items" Width="250px">
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