<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ApplicantQualifications.ascx.cs" Inherits="UserControls_Admissions_ApplicantQualifications" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<dx:ASPxCallbackPanel ID="cbk_qualifications" runat="server" 
    ClientInstanceName="callbackqualifications" 
    oncallback="cbk_qualifications_Callback" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dxflInternalEditorTable">
        <tr>
            <td>
                <dx:ASPxButton ID="btn_qual" runat="server" AutoPostBack="False" 
                    Text="New Qualification" Width="200px">
                    <ClientSideEvents Click="function(s, e) {
	callbackqualifications.PerformCallback();
}" />
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvQualifications" runat="server" 
                    AutoGenerateColumns="False" DataSourceID="dsQualifications" KeyFieldName="ID" 
                    OnCustomErrorText="gvQualifications_CustomErrorText" 
                    OnInitNewRow="gvQualifications_InitNewRow" Width="100%">
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="Entry No" FieldName="stud_entry_no" 
                            ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Qualification" FieldName="q_qualif" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="300px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Institution" FieldName="q_inst" 
                            ShowInCustomizationForm="True" VisibleIndex="3" Width="200px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Year" FieldName="q_year" 
                            ShowInCustomizationForm="True" VisibleIndex="4" Width="50px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Classification" FieldName="q_class" 
                            ShowInCustomizationForm="True" VisibleIndex="5" Width="200px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                            ShowSelectCheckbox="True" VisibleIndex="1" Width="20px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowClearFilterButton="True" 
                            ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" 
                            VisibleIndex="7" Width="50px">
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
                <asp:ObjectDataSource ID="dsQualifications" runat="server" 
                    DeleteMethod="DeleteQualifications" InsertMethod="AddOtherQualifications" 
                    OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetApplicantOtherQualifications" TypeName="ApplicationsBLL" 
                    UpdateMethod="UpdateOtherQualifications">
                    <DeleteParameters>
                        <asp:Parameter Name="original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="stud_entry_no" Type="String" />
                        <asp:Parameter Name="q_qualif" Type="String" />
                        <asp:Parameter Name="q_inst" Type="String" />
                        <asp:Parameter Name="q_year" Type="String" />
                        <asp:Parameter Name="q_class" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="" Name="stud_entry_no" 
                            SessionField="stud_entry_no" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="stud_entry_no" Type="String" />
                        <asp:Parameter Name="q_qualif" Type="String" />
                        <asp:Parameter Name="q_inst" Type="String" />
                        <asp:Parameter Name="q_year" Type="String" />
                        <asp:Parameter Name="q_class" Type="String" />
                        <asp:Parameter Name="original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxCallbackPanel>

