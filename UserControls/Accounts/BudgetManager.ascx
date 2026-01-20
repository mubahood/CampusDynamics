<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BudgetManager.ascx.cs" Inherits="UserControls_Accounts_BudgetManager" %>
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


    .style12
    {
        height: 18px;
    }
    .style13
    {
        width: 65px;
    }
    .style16
    {
        width: 186px;
    }
    .style15
    {
        width: 63px;
    }
    .style17
    {
        width: 189px;
    }
    .style18
    {
        width: 88px;
    }
    .style30
    {
        width: 172px;
    }
    .auto-style5 {
        width: 61px;
    }
    .style8
    {
        height: 35px;
    }
    .style9
    {
        height: 41px;
    }
    .auto-style6 {
        width: 112px;
    }
    .auto-style7 {
        width: 107px;
    }
    .auto-style8 {
        width: 254px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table1" class="style1">
                <tr>
                    <td>
                        <table id="table2" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_budget.png" >
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  Width="100%">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="style12"></td>
                </tr>
                <tr>
                    <td>
                        <table id="table3" class="style1">
                            <tr>
                                <td class="auto-style7">Financial Year:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtYear" runat="server" AutoPostBack="True" DataSourceID="dsFinancialYears" Height="27px" SelectedIndex="0" TextField="title" TextFormatString="{1}" ValueField="ID" Width="250px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="80px" />
                                            <dx:ListBoxColumn Caption="Financial Year" FieldName="title" Width="200px" />
                                        </Columns>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style5">Category:</td>
                                <td>
                                    <dx:ASPxComboBox ID="txtCategory" runat="server" AutoPostBack="True" Height="27px" SelectedIndex="0">
                                        <Items>
                                            <dx:ListEditItem Text="ALL" Value="ALL" Selected="True" />
                                            <dx:ListEditItem Text="INCOME" Value="INCOME" />
                                            <dx:ListEditItem Text="EXPENDITURE" Value="EXPENDITURE" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style7">&nbsp;</td>
                                <td class="auto-style8">
                                    <dx:ASPxButton ID="cmdExport" runat="server" Height="27px" Text="Export To Excel" Width="250px" OnClick="cmdExport_Click">
                                        <Image Url="~/COOPERP/images/document-excel-table.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style5">&nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="cmdNew" runat="server" Height="27px" OnClick="cmdNew_Click" Text="Refresh Budget" Width="170px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style7">&nbsp;</td>
                                <td class="auto-style8">
                                    <dx:ASPxButton ID="cmdPrint" runat="server" Height="27px" Text="Print" Width="250px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style5">&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvBudget" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvJournals" DataSourceID="dsBudget" EnableCallBacks="False" KeyFieldName="ID" OnBatchUpdate="gvBudget_BatchUpdate" Width="100%">
                            <Templates>
                                <EditForm>
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <table class="style1">
                                                    <tr>
                                                        <td class="style23">&nbsp;</td>
                                                        <td class="style22">Journal No:</td>
                                                        <td class="style21">
                                                            <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" ReadOnly="True" Text='<%# Bind("JournalNo") %>' Width="170px">
                                                            </dx:ASPxTextBox>
                                                        </td>
                                                        <td class="style15">Date:</td>
                                                        <td class="style29">
                                                            <dx:ASPxDateEdit ID="ASPxDateEdit1" runat="server" Value='<%# Bind("journalDate") %>'>
                                                            </dx:ASPxDateEdit>
                                                        </td>
                                                        <td></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="style23">&nbsp;</td>
                                                        <td class="style22">Type:</td>
                                                        <td class="style21">
                                                            <dx:ASPxComboBox ID="ASPxComboBox1" runat="server" IncrementalFilteringMode="Contains" Value='<%# Bind("journalType") %>' ValueType="System.String">
                                                                <Items>
                                                                    <dx:ListEditItem Text="General Journal" Value="General" />
                                                                    <dx:ListEditItem Text="Payment Journal" Value="Payment" />
                                                                    <dx:ListEditItem Text="Member Journal" Value="Member" />
                                                                </Items>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                        <td class="style15">Status:</td>
                                                        <td class="style29">
                                                            <dx:ASPxComboBox ID="ASPxComboBox2" runat="server" Value='<%# Bind("PostStatus") %>' ValueType="System.String">
                                                                <Items>
                                                                    <dx:ListEditItem Text="Not Posted" Value="Not Posted" />
                                                                    <dx:ListEditItem Text="Posted" Value="Posted" />
                                                                    <dx:ListEditItem Text="Rejected" Value="Rejected" />
                                                                </Items>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td class="style23">&nbsp;</td>
                                                        <td class="style22" valign="top">Created By:</td>
                                                        <td class="style21" valign="top">
                                                            <dx:ASPxTextBox ID="ASPxTextBox1" runat="server" ReadOnly="True" Text='<%# Bind("Teller") %>' Width="170px">
                                                            </dx:ASPxTextBox>
                                                        </td>
                                                        <td class="style15" valign="top">Memo:</td>
                                                        <td class="style24" colspan="2">
                                                            <dx:ASPxMemo ID="txtMemo" runat="server" Height="50px" Text='<%# Bind("journalParticulars") %>' Width="170px">
                                                            </dx:ASPxMemo>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxImage ID="ASPxImage3" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                                                </dx:ASPxImage>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                </EditForm>
                            </Templates>
                            <SettingsPager PageSize="50">
                            </SettingsPager>
                            <SettingsEditing Mode="Batch">
                            </SettingsEditing>
                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowFooter="True" />
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Code" FieldName="item_code" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2" Width="80px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Details" FieldName="details" ShowInCustomizationForm="True" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Planned Amount" FieldName="planned_amount" ShowInCustomizationForm="True" VisibleIndex="6" Width="100px">
                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                    </PropertiesTextEdit>
                                    <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                    </FooterCellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Actual Amount" FieldName="actual_amount" ShowInCustomizationForm="True" VisibleIndex="7" Width="100px">
                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                    </PropertiesTextEdit>
                                    <EditFormSettings Visible="False" />
                                    <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                    </FooterCellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Vote Status" FieldName="vote_status" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="8" Width="60px">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Category" FieldName="item_category" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="4">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Year" FieldName="budget_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Item Name" FieldName="accountname" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="3">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="10" Width="20px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                            </Columns>
                            <TotalSummary>
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="actual_amount" ShowInColumn="Actual Amount" ShowInGroupFooterColumn="Actual Amount" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="planned_amount" ShowInColumn="Planned Amount" ShowInGroupFooterColumn="Planned Amount" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                            </TotalSummary>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" HeaderText="Campus Dynamics ERP" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td class="style8"></td>
                                        </tr>
                                        <tr>
                                            <td align="center">
                                                <dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style9"></td>
                                        </tr>
                                    </table>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsBudget" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAnnualBudget" TypeName="CoopERPDataTableAdapters.fin_budgetTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="item_code" Type="String" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="planned_amount" Type="Double" />
                                <asp:Parameter Name="actual_amount" Type="Double" />
                                <asp:Parameter Name="vote_status" Type="String" />
                                <asp:Parameter Name="item_category" Type="String" />
                                <asp:Parameter Name="budget_year" Type="UInt32" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtCategory" Name="cat" PropertyName="Value" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="item_code" Type="String" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="planned_amount" Type="Decimal" />
                                <asp:Parameter Name="vote_status" Type="String" />
                                <asp:Parameter Name="item_category" Type="String" />
                                <asp:Parameter Name="budget_year" Type="Int32" />
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFinancialYears" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_financial_periodsTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="title" Type="String" />
                                <asp:Parameter Name="start_date" Type="DateTime" />
                                <asp:Parameter Name="end_date" Type="DateTime" />
                                <asp:Parameter Name="external_audit" Type="String" />
                                <asp:Parameter Name="audit_date" Type="DateTime" />
                                <asp:Parameter Name="final_close_date" Type="DateTime" />
                                <asp:Parameter Name="active_status" Type="String" />
                            </InsertParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="title" Type="String" />
                                <asp:Parameter Name="start_date" Type="DateTime" />
                                <asp:Parameter Name="end_date" Type="DateTime" />
                                <asp:Parameter Name="external_audit" Type="String" />
                                <asp:Parameter Name="audit_date" Type="DateTime" />
                                <asp:Parameter Name="final_close_date" Type="DateTime" />
                                <asp:Parameter Name="active_status" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <dx:ASPxGridViewExporter ID="gve_budget" runat="server" ExportedRowType="All" GridViewID="gvBudget">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                </tr>
            </table>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="cmdExport" />
        </Triggers>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>





