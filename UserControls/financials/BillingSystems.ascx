<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BillingSystems.ascx.cs" Inherits="UserControls_financials_BillingSystems" %>
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


    .auto-style1 {
        height: 18px;
    }


    </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Bursaries &amp; Scholarships" Width="100%" ShowHeader="False">
            <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table id="table1" cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center;">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_billingsystems.png">
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
            <td class="auto-style1"></td>
        </tr>
        <tr>
            <td>
                <dx:ASPxButton ID="cmdNew" runat="server" Height="35px" OnClick="cmdNew_Click" Text="Add Billing System" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvScholarships" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsBillingSystem" KeyFieldName="ID" Width="100%" OnHtmlDataCellPrepared="gvScholarships_HtmlDataCellPrepared">
                    <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                    </SettingsEditing>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsCommandButton><UpdateButton RenderMode="Button"></UpdateButton><CancelButton RenderMode="Button"></CancelButton>
                                         </SettingsCommandButton>
                    <SettingsPopup>
                        <EditForm HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" />
                    </SettingsPopup>
                    <SettingsSearchPanel Visible="True" />
                    <SettingsText CommandCancel="Cancel Changes" CommandUpdate="Update Changes" />
                    <EditFormLayoutProperties>
                        <Items>
                            <dx:GridViewLayoutGroup Caption="Student Billing System">
                                <Items>
                                    <dx:EmptyLayoutItem>
                                    </dx:EmptyLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="bs_name">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="bs_description">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="bs_currency">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:EditModeCommandLayoutItem HorizontalAlign="Right">
                                    </dx:EditModeCommandLayoutItem>
                                    <dx:EmptyLayoutItem>
                                    </dx:EmptyLayoutItem>
                                </Items>
                            </dx:GridViewLayoutGroup>
                            <dx:GridViewColumnLayoutItem ClientVisible="False" ColumnName="ID">
                            </dx:GridViewColumnLayoutItem>
                        </Items>
                    </EditFormLayoutProperties>
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" 
                            ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="50px">
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Billing System Name" FieldName="bs_name" 
                            ShowInCustomizationForm="True" VisibleIndex="1">
                            <PropertiesTextEdit Height="35px">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Description" FieldName="bs_description" 
                            ShowInCustomizationForm="True" VisibleIndex="2">
                            <PropertiesTextEdit Height="35px">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ButtonRenderMode="Button" ButtonType="Button" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Currency" FieldName="bs_currency" ShowInCustomizationForm="True" VisibleIndex="3" Width="100px">
                            <PropertiesComboBox Height="35px">
                                <Items>
                                    <dx:ListEditItem Text="USD" Value="USD" />
                                    <dx:ListEditItem Text="UGX" Value="UGX" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsBillingSystem" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="StudentAccountingDataTableAdapters.fin_billing_systemsTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="bs_name" Type="String" />
                        <asp:Parameter Name="bs_description" Type="String" />
                        <asp:Parameter Name="bs_currency" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="bs_name" Type="String" />
                        <asp:Parameter Name="bs_description" Type="String" />
                        <asp:Parameter Name="bs_currency" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
