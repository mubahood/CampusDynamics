<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PayrollSpecialRates.ascx.cs" Inherits="UserControls_HumanResource_PayrollSpecialRates" %>
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
<dx:PanelContent ID="PanelContent1" runat="server">
    <table width="100%">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_hrm_special_rates.png">
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
                                Text="Add New" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td align="right">
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvDedAllowances" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsSpecialRates" KeyFieldName="ID" Width="100%" 
                    ClientInstanceName="gvPayroll" OnHtmlRowPrepared="gvDedAllowances_HtmlRowPrepared">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Effective Date" FieldName="effect_date" ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesDateEdit DisplayFormatString="dd MMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Qualification" FieldName="qualification" 
                            ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Pay Rate" FieldName="pay_rate" 
                            ShowInCustomizationForm="True" VisibleIndex="7">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Staff Name" ShowInCustomizationForm="True" 
                            VisibleIndex="3" FieldName="emp_name" Visible="False">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Staff Name" FieldName="staff_code" ShowInCustomizationForm="True" VisibleIndex="2">
                            <PropertiesComboBox DataSourceID="dsStaffList" TextField="empID" TextFormatString=" {1}" ValueField="empID">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Staff No" FieldName="empID" />
                                    <dx:ListBoxColumn Caption="Staff Name" FieldName="emp_name" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Category" FieldName="pay_type" ShowInCustomizationForm="True" VisibleIndex="8">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="Parttime" Value="Parttime" />
                                    <dx:ListEditItem Text="Consultant" Value="Consultant" />
                                    <dx:ListEditItem Text="Special Payment" Value="Special Payment" />
                                    <dx:ListEditItem Text="HOD Facilitation" Value="HOD Facilitation" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="cur_status" ShowInCustomizationForm="True" VisibleIndex="5">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="Active" Value="Active" />
                                    <dx:ListEditItem Text="Suspended" Value="Suspended" />
                                    <dx:ListEditItem Text="InActive" Value="InActive" />
                                    <dx:ListEditItem Text="Terminated" Value="Terminated" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsContextMenu Enabled="True">
                    </SettingsContextMenu>
                    <SettingsEditing Mode="EditForm">
                        <BatchEditSettings StartEditAction="DblClick" />
                    </SettingsEditing>
                    <Settings ShowFilterRowMenu="True" />
                    <SettingsSearchPanel Visible="True" />
                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                        ConfirmDelete="Delete Payroll?" CommandNew="Add New" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsSpecialRates" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetPartTimeRatesList" TypeName="HRMDataTableAdapters.hrm_part_time_ratesTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="Int32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="staff_code" Type="Int32" />
                        <asp:Parameter Name="effect_date" Type="DateTime" />
                        <asp:Parameter Name="cur_status" Type="String" />
                        <asp:Parameter Name="qualification" Type="String" />
                        <asp:Parameter Name="pay_rate" Type="Double" />
                        <asp:Parameter Name="pay_type" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="staff_code" Type="Int32" />
                        <asp:Parameter Name="effect_date" Type="DateTime" />
                        <asp:Parameter Name="cur_status" Type="String" />
                        <asp:Parameter Name="qualification" Type="String" />
                        <asp:Parameter Name="pay_rate" Type="Double" />
                        <asp:Parameter Name="pay_type" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsStaffList" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter"></asp:ObjectDataSource>
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
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

