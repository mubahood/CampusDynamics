<%@ Control Language="C#" AutoEventWireup="true" CodeFile="journalTypes.ascx.cs" Inherits="UserControls_Accounts_journalTypes" %>
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


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Voucher Types" Width="100%">
    <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <dx:ASPxButton ID="cmdAdd" runat="server" OnClick="cmdAdd_Click" 
                    Text="New Voucher Type" Width="170px" Enabled="False" Height="35px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvLedgerTypes" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsJournalTypes" KeyFieldName="journalTypeID" Width="100%" OnHtmlRowPrepared="gvLedgerTypes_HtmlRowPrepared">
                    <SettingsDataSecurity AllowDelete="False" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="journalTypeID" 
                            ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" 
                            Width="25px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Journal Type" FieldName="journaltypename" 
                            ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="3" Width="40px" ShowEditButton="True" ShowDeleteButton="True" ShowClearFilterButton="True"/>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                        <EditButton>
                            <Image Url="~/COOPERP/images/clipboard--pencil.png">
                            </Image>
                        </EditButton>
                        <DeleteButton>
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </DeleteButton>
                    </SettingsCommandButton>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsJournalTypes" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_journaltypesTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_journalTypeID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="journaltypename" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="journaltypename" Type="String" />
                        <asp:Parameter Name="Original_journalTypeID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>


