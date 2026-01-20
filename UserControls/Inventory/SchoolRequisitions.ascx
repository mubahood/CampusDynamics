<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SchoolRequisitions.ascx.cs" Inherits="UserControls_Inventory_SchoolRequisitions" %>
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


        .auto-style1 {
        height: 29px;
        width: 74px;
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
                                        ImageUrl="~/COOPERP/images/header_inv_requisitions.png">
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
                                <td align="left" class="auto-style1">
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
                                    <dx:ASPxButton ID="cmdApprove" runat="server" OnClick="cmdApprove_Click" 
                                        Text="Approve Requisition" Width="170px" Height="35px">
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" class="style11">
                                    Semester:</td>
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
                                <td align="left" class="auto-style1">
                                    &nbsp;</td>
                                <td align="left">
                                    <dx:ASPxButton ID="cmdCreateNew" runat="server" OnClick="cmdPostLedger_Click" 
                                        Text="Add Requisition" Width="250px" Height="35px">
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td align="right" class="style10">
                                    <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" 
                                        Text="Print Requisition" Width="170px" Height="35px">
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
                            ClientInstanceName="gvBranchData" DataSourceID="dsTermlyRequisitions" 
                            EnableCallBacks="False" KeyFieldName="ID" style="margin-right: 0px" 
                            Width="100%" OnHtmlRowPrepared="gvBranchData_HtmlRowPrepared">
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
                                    VisibleIndex="1" Width="40px">
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="branchID" Visible="False" 
                                    VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Date" FieldName="req_date" 
                                    ShowInCustomizationForm="True" VisibleIndex="3">
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn FieldName="req_by" VisibleIndex="4" 
                                    Caption="Prepared By">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="checked_by" 
                                    VisibleIndex="5" Caption="Checked By">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="approved_by" 
                                    VisibleIndex="6" Caption="Endorsed By">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Total Amount" FieldName="total_amount" 
                                    VisibleIndex="7" Width="100px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="term" 
                                    VisibleIndex="12" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="req_year" 
                                    VisibleIndex="13" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowDeleteButton="True" 
                                    ShowInCustomizationForm="True" VisibleIndex="14" Width="50px">
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewCommandColumn>
                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" 
                                    Width="30px" SelectAllCheckboxMode="Page" ShowSelectCheckbox="True">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" 
                                    VisibleIndex="11" Width="30px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdDetails" runat="server" 
                                            ImageUrl="~/COOPERP/images/clipboard-list.png" onclick="cmdDetails_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Status" FieldName="req_status" 
                                    ShowInCustomizationForm="True" VisibleIndex="10" Width="80px">
                                </dx:GridViewDataTextColumn>
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
                        <asp:ObjectDataSource ID="dsTermlyRequisitions" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" 
                            SelectMethod="GetSchoolTermlyRequisitions" 
                            TypeName="SchoolInventoryTableAdapters.inv_schoolrequisitionTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="branchID" Type="UInt32" />
                                <asp:Parameter Name="req_date" Type="DateTime" />
                                <asp:Parameter Name="req_by" Type="String" />
                                <asp:Parameter Name="checked_by" Type="String" />
                                <asp:Parameter Name="approved_by" Type="String" />
                                <asp:Parameter Name="total_amount" Type="Double" />
                                <asp:Parameter Name="term" Type="UInt32" />
                                <asp:Parameter Name="req_year" Type="String" />
                                <asp:Parameter Name="req_status" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtSchool" Name="bid" PropertyName="Value" 
                                    Type="Int32" />
                                <asp:ControlParameter ControlID="txtTerm" Name="trm" PropertyName="Value" 
                                    Type="Int32" />
                                <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" 
                                    Type="String" DefaultValue="" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="branchID" Type="UInt32" />
                                <asp:Parameter Name="req_date" Type="DateTime" />
                                <asp:Parameter Name="req_by" Type="String" />
                                <asp:Parameter Name="checked_by" Type="String" />
                                <asp:Parameter Name="approved_by" Type="String" />
                                <asp:Parameter Name="total_amount" Type="Double" />
                                <asp:Parameter Name="term" Type="UInt32" />
                                <asp:Parameter Name="req_year" Type="String" />
                                <asp:Parameter Name="req_status" Type="String" />
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
                            TypeName="InventoryDataTableAdapters.fin_departmentTableAdapter">
                        </asp:ObjectDataSource>
                        <dx:ASPxGridViewExporter ID="Exporter" runat="server" GridViewID="gvBranchData" 
                            PaperKind="A4">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" 
                            HeaderText="Campus Dynamics Version 1.0" Modal="True" 
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
                        &nbsp;</td>
                </tr>
            </table>
        <%--</ContentTemplate>
    </asp:UpdatePanel>--%>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>