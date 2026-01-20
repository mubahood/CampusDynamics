<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Deductions_Allowances.ascx.cs" Inherits="UserControls_HumanResource_Deductions_Allowances" %>
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

img
{
	border-width: 0;
}


</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table width="100%">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_ded_allowances.png">
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
            <td>
                <table cellpadding="1" cellspacing="1" width="100%">
                    <tr>
                        <td>
                            <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" 
                                Text="Add New" Width="170px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td align="right">
                            <dx:ASPxComboBox ID="txtType" runat="server" AutoPostBack="True" 
                                OnSelectedIndexChanged="txtType_SelectedIndexChanged" SelectedIndex="0">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Allowance" Value="Allowance" />
                                    <dx:ListEditItem Text="Deduction" Value="Deduction" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvDedAllowances" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsAllowancesDeductions" KeyFieldName="ID" Width="100%" 
                    ClientInstanceName="gvPayroll" OnInitNewRow="gvDedAllowances_InitNewRow">
                    <Columns>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                            ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" 
                            Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="dedall_name" 
                            ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="dedall_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Type" FieldName="ded_allowance" 
                            ShowInCustomizationForm="True" VisibleIndex="8" ReadOnly="True" 
                            Visible="False">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                            ShowInCustomizationForm="True" VisibleIndex="10" Width="100px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Category" FieldName="dedall_type" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesComboBox IncrementalFilteringMode="Contains">
                                <Items>
                                    <dx:ListEditItem Text="STATUTORY" Value="STATUTORY" />
                                    <dx:ListEditItem Text="MANDATORY" Value="MANDATORY" />
                                    <dx:ListEditItem Text="OPTIONAL" Value="OPTIONAL" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Computation By" 
                            FieldName="computation_by" ShowInCustomizationForm="True" VisibleIndex="7">
                            <PropertiesComboBox IncrementalFilteringMode="Contains">
                                <Items>
                                    <dx:ListEditItem Text="PERCENTAGE" Value="PERCENTAGE" />
                                    <dx:ListEditItem Text="PERCENT - TAX" Value="PERCENT - TAX" />
                                    <dx:ListEditItem Text="FIXED" Value="FIXED" />
                                    <dx:ListEditItem Text="DYNAMIC" Value="DYNAMIC" />
                                    <dx:ListEditItem Text="FORMULA" Value="FORMULA" />
                                    <dx:ListEditItem Text="ATTENDANCE" Value="ATTENDANCE" />

                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Staff List" ShowInCustomizationForm="True" 
                            VisibleIndex="9" Width="30px">
                            <EditFormSettings Visible="False" />
                            <DataItemTemplate>
                                <asp:ImageButton ID="cmdStaffList" runat="server" 
                                    ImageUrl="~/COOPERP/images/clipboard-list.png" onclick="cmdStaffList_Click" />
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsEditing Mode="EditForm">
                        <BatchEditSettings StartEditAction="DblClick" />
                    </SettingsEditing>
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                        ConfirmDelete="Delete Payroll?" CommandNew="Add New" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsAllowancesDeductions" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetDedAllowanceByType" TypeName="HRMDataTableAdapters.hrm_allowance_deductionsTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="dedall_name" Type="String" />
                        <asp:Parameter Name="dedall_type" Type="String" />
                        <asp:Parameter Name="dedall_amount" Type="Double" />
                        <asp:Parameter Name="computation_by" Type="String" />
                        <asp:Parameter Name="ded_allowance" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtType" Name="typ" PropertyName="Value" 
                            Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="dedall_name" Type="String" />
                        <asp:Parameter Name="dedall_type" Type="String" />
                        <asp:Parameter Name="dedall_amount" Type="Double" />
                        <asp:Parameter Name="computation_by" Type="String" />
                        <asp:Parameter Name="ded_allowance" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ClientSideEvents CloseUp="function(s, e) {
	gvPayroll.Refresh();
}" />
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>


