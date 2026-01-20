<%@ Control Language="C#" AutoEventWireup="true" CodeFile="OnlineApplicantResults.ascx.cs" Inherits="UserControls_Admissions_ApplicantChoices" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<dx:ASPxCallbackPanel ID="cbk_choices" runat="server" Width="100%" 
    ClientInstanceName="callbackchoice" oncallback="cbk_choices_Callback">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table  width="100%">
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gv_choices" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="ds_applic_results" KeyFieldName="ID" 
                    OnInitNewRow="gv_choices_InitNewRow" Width="100%" 
                    OnCustomErrorText="gv_choices_CustomErrorText" OnHtmlDataCellPrepared="gv_choices_HtmlDataCellPrepared">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" 
                            ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="sub_name" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Caption="Subject Name">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="sub_level" 
                            ShowInCustomizationForm="True" VisibleIndex="3" Caption="Level">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="formNo" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                     <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                        <UpdateButton Text="| Save Changes |">
                        </UpdateButton>
                        <CancelButton Text="| Cancel Changes |">
                        </CancelButton>
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
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="ds_applic_results" runat="server" 
                    DeleteMethod="Delete" InsertMethod="Insert" 
                    OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetResultsByForm" TypeName="admission_dataTableAdapters.applic_resultsTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="sub_name" Type="String" />
                        <asp:Parameter Name="sub_level" Type="String" />
                        <asp:Parameter Name="grade" Type="String" />
                        <asp:Parameter Name="formNo" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="frmNo" SessionField="formNo" 
                            Type="String" DefaultValue="0" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="sub_name" Type="String" />
                        <asp:Parameter Name="sub_level" Type="String" />
                        <asp:Parameter Name="grade" Type="String" />
                        <asp:Parameter Name="formNo" Type="String" />
                        <asp:Parameter Name="original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxCallbackPanel>

