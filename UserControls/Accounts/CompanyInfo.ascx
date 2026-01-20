<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CompanyInfo.ascx.cs" Inherits="UserControls_Accounts_CompanyInfo" %>
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


    
    .style2
    {
        height: 38px;
    }
    .style3
    {
        height: 42px;
    }

    .style4
    {
        height: 23px;
    }
    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_companyinfo.png">
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
                <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" HeaderText="Company Information" ShowCollapseButton="True" Width="100%">
                    <PanelCollection>
                        <dx:PanelContent ID="PanelContent2" runat="server">
                            <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" DataSourceID="dsCompanyInfo" KeyFieldName="ID" Width="100%">
                                <SettingsPager NumericButtonCount="1" PageSize="1">
                                </SettingsPager>
                                <SettingsEditing Mode="Inline">
                                </SettingsEditing>
                                <SettingsBehavior AllowFocusedRow="True" />
                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Company Name" FieldName="companyname" ShowInCustomizationForm="True" VisibleIndex="1">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Company Contact Info" FieldName="companycontacts" ShowInCustomizationForm="True" VisibleIndex="2">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Logo" ShowInCustomizationForm="True" VisibleIndex="3" Width="60px">
                                        <DataItemTemplate>
                                            <dx:ASPxBinaryImage ID="ASPxBinaryImage1" runat="server" Height="60px" Value='<%# Eval("logo") %>'>
                                            </dx:ASPxBinaryImage>
                                        </DataItemTemplate>
                                    </dx:GridViewDataTextColumn>
                                </Columns>
                            </dx:ASPxGridView>
                        </dx:PanelContent>
                    </PanelCollection>
                </dx:ASPxRoundPanel>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxRoundPanel ID="ASPxRoundPanel3" runat="server" HeaderText="Financial Years" ShowCollapseButton="True" Width="100%">
                    <PanelCollection>
                        <dx:PanelContent ID="PanelContent3" runat="server">
                            <table id="table1" class="style1">
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvFinancialYears" runat="server" AutoGenerateColumns="False" DataSourceID="dsFinancialYears" KeyFieldName="ID" Width="100%" OnHtmlDataCellPrepared="gvFinancialYears_HtmlDataCellPrepared">
                                            <SettingsContextMenu Enabled="True">
                                            </SettingsContextMenu>
                                            <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                            </SettingsEditing>
                                            <SettingsBehavior AllowFocusedRow="True" />
                                            <SettingsDataSecurity AllowDelete="False" />
                                            <SettingsPopup>
                                                <EditForm HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" />
                                            </SettingsPopup>
                                            <SettingsSearchPanel Visible="True" />
                                            <EditFormLayoutProperties>
                                                <Items>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:GridViewColumnLayoutItem ColumnName="title" Height="27px">
                                                    </dx:GridViewColumnLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:GridViewColumnLayoutItem ColumnName="start_date" Height="27px">
                                                    </dx:GridViewColumnLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:GridViewColumnLayoutItem ColumnName="end_date" Height="27px">
                                                    </dx:GridViewColumnLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:GridViewColumnLayoutItem ColumnName="external_audit" Height="27px">
                                                    </dx:GridViewColumnLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:GridViewColumnLayoutItem ColumnName="audit_date" Height="27px">
                                                    </dx:GridViewColumnLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:GridViewColumnLayoutItem ColumnName="final_close_date" Height="27px">
                                                    </dx:GridViewColumnLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:GridViewColumnLayoutItem ColumnName="active_status" Height="27px">
                                                    </dx:GridViewColumnLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                    <dx:EditModeCommandLayoutItem HorizontalAlign="Right" Height="27px">
                                                    </dx:EditModeCommandLayoutItem>
                                                    <dx:EmptyLayoutItem>
                                                    </dx:EmptyLayoutItem>
                                                </Items>
                                            </EditFormLayoutProperties>
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Title" FieldName="title" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn Caption="Start Date" FieldName="start_date" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                                                    </PropertiesDateEdit>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataDateColumn Caption="End Date" FieldName="end_date" ShowInCustomizationForm="True" VisibleIndex="4">
                                                    <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                                                    </PropertiesDateEdit>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataDateColumn Caption="Audit Date" FieldName="audit_date" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                                                    </PropertiesDateEdit>
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataDateColumn Caption="Actual Close Date" FieldName="final_close_date" ShowInCustomizationForm="True" VisibleIndex="7">
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="active_status" ShowInCustomizationForm="True" VisibleIndex="8">
                                                    <PropertiesComboBox EnableFocusedStyle="False">
                                                        <Items>
                                                            <dx:ListEditItem Text="Active" Value="Active" />
                                                            <dx:ListEditItem Text="Archived" Value="Archived" />
                                                            <dx:ListEditItem Text="Pending" Value="Pending" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewCommandColumn ButtonRenderMode="Button" ButtonType="Button" SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Audit Status" FieldName="external_audit" ShowInCustomizationForm="True" VisibleIndex="5">
                                                    <PropertiesComboBox>
                                                        <Items>
                                                            <dx:ListEditItem Text="Pending" Value="Pending" />
                                                            <dx:ListEditItem Text="On-Going" Value="On-Going" />
                                                            <dx:ListEditItem Text="Completed" Value="Completed" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
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
                                    </td>
                                </tr>
                            </table>
                        </dx:PanelContent>
                    </PanelCollection>
                </dx:ASPxRoundPanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsCompanyInfo" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.companyinfoTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="companyname" Type="String" />
                        <asp:Parameter Name="companycontacts" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" 
                    HeaderText="Campus Dynamics ERP" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td class="style2">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        &nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" 
                                            style="font-weight: 700;" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3">
                                    </td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
