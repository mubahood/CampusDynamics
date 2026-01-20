<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ApplicantResults.ascx.cs" Inherits="UserControls_Admissions_ApplicantResults" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<style type="text/css">
    .style5
    {
        width: 100%;
    }
    .style6
    {
        width: 186px;
    }
    .style7
    {
        width: 279px;
    }
    </style>

<dx:ASPxCallbackPanel ID="cbk_Results" runat="server" 
    ClientInstanceName="callbackResults" Width="100%" 
    oncallback="cbk_Results_Callback">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table width="100%">
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td>
                            <dx:ASPxButton ID="btn_AddResults" runat="server" Text="New Results" 
                                AutoPostBack="False" Width="150px">
                                <ClientSideEvents Click="function(s, e) {
	callbackResults.PerformCallback(&quot;NewResults&quot;);
}" />
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td align="left">
                            <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Subjects:">
                            </dx:ASPxLabel>
                        </td>
                        <td>
                            <dx:ASPxTextBox ID="txt_NoSubs" runat="server" Text="8" Width="50px">
                            </dx:ASPxTextBox>
                        </td>
                        <td>
                            <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="Level:">
                            </dx:ASPxLabel>
                        </td>
                        <td class="style6">
                            <dx:ASPxComboBox ID="txt_level" runat="server" Width="150px">
                                <Items>
                                    <dx:ListEditItem Text="O LEVEL" Value="O" />
                                    <dx:ListEditItem Text="A LEVEL" Value="A" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style7">
                            &nbsp;</td>
                        <td align="right">
                            <dx:ASPxButton ID="btn_subjectslist" runat="server" AutoPostBack="False" 
                                Text="Manage Subjects" Width="150px">
                                <ClientSideEvents Click="function(s, e) {
	popsubjects.Show();
}" />
                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gv_Results" runat="server" AutoGenerateColumns="False" 
                    ClientInstanceName="gvResults" DataSourceID="ds_applicantResults" 
                    KeyFieldName="ID" Width="100%" 
                    OnCustomErrorText="gv_Results_CustomErrorText">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="stud_entry_no" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Level" FieldName="sub_level" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="50px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" 
                            ShowInCustomizationForm="True" VisibleIndex="5" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="sub_count" ShowInCustomizationForm="True" 
                            Visible="False" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Subject" FieldName="sub_name" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesComboBox DataSourceID="ds_subjects" 
                                IncrementalFilteringMode="Contains" TextField="sub_name" TextFormatString="{1}" 
                                ValueField="sub_name">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Level" FieldName="sub_level" Width="70px" />
                                    <dx:ListBoxColumn Caption="Subject" FieldName="sub_name" Width="430px" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowDeleteButton="True" 
                            ShowInCustomizationForm="True" VisibleIndex="6" Width="50px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsPager PageSize="30">
                        <Summary Text="Page {0} of {1} ({2} Results)" />
                    </SettingsPager>
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <SettingsCommandButton>
                        <UpdateButton Text="| Save Changes |">
                        </UpdateButton>
                        <CancelButton Text="| Cancel Changes |">
                        </CancelButton>
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
                <dx:ASPxPopupControl ID="pop_response" runat="server" 
                    HeaderText="Campus Dynamics" Height="100px" PopupHorizontalAlign="WindowCenter" 
                    PopupVerticalAlign="WindowCenter" Width="300px">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style5">
                                <tr>
                                    <td align="center">
                                        <dx:ASPxLabel ID="lbl_response" runat="server" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
                <asp:ObjectDataSource ID="ds_applicantResults" runat="server" 
                    DeleteMethod="DeleteApplicantResult" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetApplicantPerformance" 
                    TypeName="ApplicationsBLL" 
                    UpdateMethod="EditApplicantResults">
                    <DeleteParameters>
                        <asp:Parameter Name="original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="stud_entry_no" SessionField="stud_entry_no" 
                            Type="String" DefaultValue="" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="original_ID" Type="Int32" />
                        <asp:Parameter Name="sub_name" Type="String" />
                        <asp:Parameter Name="grade" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="ds_subjects" runat="server" 
                    DeleteMethod="Delete" InsertMethod="Insert" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="admission_dataTableAdapters.acad_applicant_subjectsTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="sub_name" Type="String" />
                        <asp:Parameter Name="sub_level" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="sub_name" Type="String" />
                        <asp:Parameter Name="sub_level" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxPopupControl ID="pop_subjects" runat="server" 
                    ClientInstanceName="popsubjects" CloseAction="CloseButton" 
                    HeaderText="Campus Dynamics" Height="500px" PopupHorizontalAlign="WindowCenter" 
                    PopupVerticalAlign="WindowCenter" Width="600px">
                    <ClientSideEvents CloseUp="function(s, e) {
	gvResults.Refresh();
}" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
                                Width="100%">
                                <PanelCollection>
                                    <dx:PanelContent runat="server">
                                        <dx:ASPxCallbackPanel ID="cbk_subjects" runat="server" 
                                            ClientInstanceName="callbacksubjects" OnCallback="cbk_subjects_Callback" 
                                            Width="100%">
                                            <PanelCollection>
                                                <dx:PanelContent runat="server">
                                                    <table class="style5">
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxButton ID="btn_newsubject" runat="server" AutoPostBack="False" 
                                                                    Text="New Subject" Width="150px">
                                                                    <ClientSideEvents Click="function(s, e) {
	callbacksubjects.PerformCallback();
}" />
                                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxGridView ID="gvSubjects" runat="server" AutoGenerateColumns="False" 
                                                                    DataSourceID="ds_subjects" KeyFieldName="ID" Width="100%">
                                                                    <Columns>
                                                                        <dx:GridViewDataTextColumn Caption="Subject Name" FieldName="sub_name" 
                                                                            ShowInCustomizationForm="True" VisibleIndex="1" Width="300px">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                                                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                        </dx:GridViewDataTextColumn>
                                                                        <dx:GridViewCommandColumn ShowClearFilterButton="True" 
                                                                            ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" 
                                                                            VisibleIndex="5" ShowNewButtonInHeader="True" ShowCancelButton="True" ShowUpdateButton="True">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                                                            ShowSelectCheckbox="True" VisibleIndex="0" Width="20px">
                                                                        </dx:GridViewCommandColumn>
                                                                        <dx:GridViewDataComboBoxColumn Caption="Subject Level" FieldName="sub_level" 
                                                                            ShowInCustomizationForm="True" VisibleIndex="3" Width="100px">
                                                                            <PropertiesComboBox>
                                                                                <Items>
                                                                                    <dx:ListEditItem Text="O" Value="O" />
                                                                                    <dx:ListEditItem Text="A" Value="A" />
                                                                                </Items>
                                                                            </PropertiesComboBox>
                                                                        </dx:GridViewDataComboBoxColumn>
                                                                    </Columns>
                                                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                                                    <SettingsCommandButton>
                                                                        <UpdateButton Text="| Save Changes |">
                                                                        </UpdateButton>
                                                                        <CancelButton Text="| Cancel Changes |">
                                                                        </CancelButton>
                                                                        <EditButton RenderMode="Image">
                                                                            <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                                            </Image>
                                                                        </EditButton>
                                                                        <DeleteButton RenderMode="Image">
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
                                                    </table>
                                                </dx:PanelContent>
                                            </PanelCollection>
                                        </dx:ASPxCallbackPanel>
                                    </dx:PanelContent>
                                </PanelCollection>
                            </dx:ASPxRoundPanel>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
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

