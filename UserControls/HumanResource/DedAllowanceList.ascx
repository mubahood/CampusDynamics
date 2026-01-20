<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DedAllowanceList.ascx.cs" Inherits="UserControls_HumanResource_DedAllowanceList" %>
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


        .style2
    {
        width: 180px;
    }
</style>

<table class="style1">
    <tr>
        <td>
            <table class="dxflInternalEditorTable">
                <tr>
                    <td class="style2">
            <dx:ASPxButton ID="cmdAddNew" runat="server" onclick="cmdAddNew_Click" 
                Text="Add Staff" Width="170px">
                <Image Url="~/COOPERP/images/clipboard--plus.png">
                </Image>
            </dx:ASPxButton>
                    </td>
                    <td>
                        <dx:ASPxCheckBox ID="txtAllStaff" runat="server" Text="Add All Staff">
                        </dx:ASPxCheckBox>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <dx:ASPxGridView ID="gvStaffList" runat="server" AutoGenerateColumns="False" 
                DataSourceID="dsStaffList" KeyFieldName="ID" 
                oninitnewrow="gvStaffList_InitNewRow" Width="100%">
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
                    <dx:GridViewDataTextColumn Caption="Custom Amount" FieldName="custom_amount" 
                        VisibleIndex="4" Width="60px">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsPager PageSize="500">
                </SettingsPager>
                <SettingsEditing Mode="Batch">
                    <BatchEditSettings StartEditAction="DblClick" />
                </SettingsEditing>
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
            </dx:ASPxGridView>
        </td>
    </tr>
    <tr>
        <td>
            <asp:ObjectDataSource ID="dsStaffList" runat="server" DeleteMethod="Delete" 
                InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                SelectMethod="GetStaffByDedAllowance" 
                TypeName="HRMDataTableAdapters.hrm_ded_allowance_stafflistTableAdapter" 
                UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="ded_allID" Type="UInt32" />
                    <asp:Parameter Name="empID" Type="UInt32" />
                    <asp:Parameter Name="custom_amount" Type="Double" />
                </InsertParameters>
                <SelectParameters>
                    <asp:SessionParameter Name="dedAllID" SessionField="dedAllID" Type="Int32" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="ded_allID" Type="UInt32" />
                    <asp:Parameter Name="empID" Type="UInt32" />
                    <asp:Parameter Name="custom_amount" Type="Double" />
                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                </UpdateParameters>
            </asp:ObjectDataSource>
            <asp:ObjectDataSource ID="dsEmployees" runat="server" 
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter">
            </asp:ObjectDataSource>
        </td>
    </tr>
    <tr>
        <td>
                        <dx:ASPxPopupControl runat="server" 
                PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                Modal="True" HeaderText="School Dynamics Version 1.0" Width="300px" 
                ID="pop_details">
<ClientSideEvents CloseUp="function(s, e) {
	gvBranchData.Refresh();
}"></ClientSideEvents>

<HeaderStyle HorizontalAlign="Center"></HeaderStyle>
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
                                                <dx:ASPxLabel runat="server" Font-Bold="True" ForeColor="Red" ID="lbl_msg"></dx:ASPxLabel>

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
</table>

