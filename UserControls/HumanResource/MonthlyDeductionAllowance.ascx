<%@ Control Language="C#" AutoEventWireup="true" CodeFile="MonthlyDeductionAllowance.ascx.cs" Inherits="UserControls_HumanResource_MonthlyDeductionAllowance" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }

img
{
	border-width: 0;
}



*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .style2
    {
        width: 88px;
    }
    .style3
    {
        width: 266px;
    }
</style>

<table class="style1">
    <tr>
        <td>
            <table class="style1">
                <tr>
                    <td class="style2">
                        Type:</td>
                    <td class="style3">
                        <dx:ASPxComboBox ID="txtType" runat="server" AutoPostBack="True" 
                            onselectedindexchanged="txtType_SelectedIndexChanged" SelectedIndex="0" 
                            Width="250px" Height="35px">
                            <Items>
                                <dx:ListEditItem Selected="True" Text="Allowance" Value="Allowance" />
                                <dx:ListEditItem Text="Deduction" Value="Deduction" />
                            </Items>
                            <Paddings PaddingLeft="5px" />
                        </dx:ASPxComboBox>
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdRefreshList" runat="server" Text="Refresh List" 
                            Width="170px" onclick="cmdRefreshList_Click" Height="35px">
                            <Image Url="~/COOPERP/images/arrow-retweet.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style2">
                        <dx:ASPxLabel ID="lbl_ded_all" runat="server" Text="Allowance">
                        </dx:ASPxLabel>
                        :</td>
                    <td class="style3">
                        <dx:ASPxComboBox ID="txtDeductionAllowanceName" runat="server" 
                            ValueType="System.Int32" AutoPostBack="True" DataSourceID="dsDedAllowances" 
                            ondatabound="txtDeductionAllowanceName_DataBound" 
                            onselectedindexchanged="txtDeductionAllowanceName_SelectedIndexChanged" 
                            TextField="dedall_name" TextFormatString="{1}" ValueField="ID" 
                            Width="250px" Height="35px">
                            <Columns>
                                <dx:ListBoxColumn Caption="ID" FieldName="ID" Width="50px" />
                                <dx:ListBoxColumn Caption="Allowance | Deduction" FieldName="dedall_name" 
                                    Width="200px" />
                            </Columns>
                        </dx:ASPxComboBox>
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdDeleteSelected" runat="server" Text="Delete Selected" 
                            Width="170px" Height="35px">
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style2">
                        <dx:ASPxLabel ID="lbl_ded_all0" runat="server" Text="Branch:">
                        </dx:ASPxLabel>
                        </td>
                    <td class="style3">
                            <dx:ASPxComboBox runat="server" SelectedIndex="0" DataSourceID="dsSchools" 
                            TextField="station_name" ValueField="station_name" TextFormatString="{0}" 
                            Width="250px" AutoPostBack="True" ID="txtSchool" Height="35px"><Columns>
<dx:ListBoxColumn FieldName="station_name" Caption="Station"></dx:ListBoxColumn>
</Columns>
</dx:ASPxComboBox>

                        </td>
                    <td>
                        <dx:ASPxButton ID="cmdSaveChanges" runat="server" Text="Save Changes" 
                            Width="170px" OnClick="cmdSaveChanges_Click" Height="35px">
                            <Image Url="~/COOPERP/images/disk.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td>
                        &nbsp;</td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <dx:ASPxGridView ID="gvStaffList" runat="server" AutoGenerateColumns="False" 
                DataSourceID="dsMonthlyDedAllowanceList" KeyFieldName="ID" Width="100%" 
                EnableCallBacks="False">
                <Columns>
                    <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                        ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" Visible="False" 
                        VisibleIndex="1">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="SNo" FieldName="ded_allID" ReadOnly="True" 
                        Visible="False" VisibleIndex="2">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataComboBoxColumn Caption="Staff Name" FieldName="empID" 
                        VisibleIndex="3">
                        <PropertiesComboBox DataSourceID="dsEmployees" TextField="emp_name" 
                            TextFormatString="{1}" ValueField="empID">
                            <Columns>
                                <dx:ListBoxColumn Caption="SNo" FieldName="empID" Width="30px" />
                                <dx:ListBoxColumn Caption="Staff Name" FieldName="emp_name" Width="200px" />
                            </Columns>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewCommandColumn ShowDeleteButton="True" VisibleIndex="5" Width="50px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount" VisibleIndex="4" 
                        Width="150px">
                        <DataItemTemplate>
                            <dx:ASPxTextBox ID="txtAmount" runat="server" HorizontalAlign="Right" 
                                Text='<%# Eval("amount", "{0:0,0}") %>' Width="100%">
                            </dx:ASPxTextBox>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Right" />
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsPager PageSize="200">
                </SettingsPager>
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
            </dx:ASPxGridView>
        </td>
    </tr>
    <tr>
        <td>
            <asp:ObjectDataSource ID="dsMonthlyDedAllowanceList" runat="server" 
                DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" 
                SelectMethod="GetSingleMonthlyDedAllowancesList" 
                TypeName="HRMDataTableAdapters.hrm_monthly_ded_allowanceTableAdapter" 
                InsertMethod="Insert" UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="payrollID" Type="UInt32" />
                    <asp:Parameter Name="empID" Type="UInt32" />
                    <asp:Parameter Name="amount" Type="Double" />
                    <asp:Parameter Name="typ" Type="String" />
                    <asp:Parameter Name="ded_allID" Type="UInt32" />
                </InsertParameters>
                <SelectParameters>
                    <asp:SessionParameter Name="pid" SessionField="pid" Type="Int32" />
                    <asp:ControlParameter ControlID="txtDeductionAllowanceName" Name="dedAllID" 
                        PropertyName="Value" Type="Int32" />
                    <asp:ControlParameter ControlID="txtType" Name="dedtyp" PropertyName="Value" 
                        Type="String" />
                    <asp:Parameter DefaultValue="Display" Name="act" Type="String" />
                    <asp:ControlParameter ControlID="txtSchool" DefaultValue="0" Name="bid" 
                        PropertyName="Value" Type="String" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="payrollID" Type="UInt32" />
                    <asp:Parameter Name="empID" Type="UInt32" />
                    <asp:Parameter Name="amount" Type="Double" />
                    <asp:Parameter Name="typ" Type="String" />
                    <asp:Parameter Name="ded_allID" Type="UInt32" />
                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                </UpdateParameters>
            </asp:ObjectDataSource>
            <asp:ObjectDataSource ID="dsEmployees" runat="server" 
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter">
            </asp:ObjectDataSource>
            <asp:ObjectDataSource ID="dsDedAllowances" runat="server" 
                OldValuesParameterFormatString="original_{0}" 
                SelectMethod="GetDedAllowanceByType" 
                TypeName="HRMDataTableAdapters.hrm_allowance_deductionsTableAdapter">
                <SelectParameters>
                    <asp:ControlParameter ControlID="txtType" Name="typ" PropertyName="Value" 
                        Type="String" />
                </SelectParameters>
            </asp:ObjectDataSource>

                <asp:ObjectDataSource runat="server" 
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                TypeName="HRMDataTableAdapters.hrm_stationsTableAdapter" ID="dsSchools" 
                DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="station_name" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="station_name" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
            </asp:ObjectDataSource>

        </td>
    </tr>
    <tr>
        <td>
                                <dx:ASPxPopupControl runat="server" 
                PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                Modal="True" CloseAction="CloseButton" HeaderText="School Dynamics" 
                Width="300px" ID="pop_checks"><ContentCollection>
<dx:PopupControlContentControl runat="server">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td>
                                                        <br />
                                                        <br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <dx:ASPxImage runat="server" ID="img_pop"></dx:ASPxImage>

                                                        <dx:ASPxLabel runat="server" ID="lbl_pop"></dx:ASPxLabel>

                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <br />
                                                        <br />
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

