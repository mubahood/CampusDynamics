<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ApplicantChoices.ascx.cs" Inherits="UserControls_Admissions_ApplicantChoices" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<dx:ASPxCallbackPanel ID="cbk_choices" runat="server" Width="100%" 
    ClientInstanceName="callbackchoice" oncallback="cbk_choices_Callback">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table  width="100%">
        <tr>
            <td>
                <dx:ASPxButton ID="btn_new" runat="server" Text="New Choice" 
                    AutoPostBack="False" Width="200px" Height="35px">
                    <ClientSideEvents Click="function(s, e) {
	callbackchoice.PerformCallback(&quot;NewChoice&quot;);
}" />
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gv_choices" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="ds_applicantchoices" KeyFieldName="ID" 
                    OnInitNewRow="gv_choices_InitNewRow" Width="100%" 
                    OnCustomErrorText="gv_choices_CustomErrorText" OnHtmlRowPrepared="gv_choices_HtmlRowPrepared">
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="Entry No" FieldName="stud_entry_no" 
                            ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="adm_status" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Status" FieldName="statusName" 
                            ShowInCustomizationForm="True" VisibleIndex="8" Width="150px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Programme" FieldName="progname" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                            ShowSelectCheckbox="True" VisibleIndex="0" Width="20px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" Caption="Manage" 
                            ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" 
                            VisibleIndex="15" Width="50px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="prog_id" 
                            ShowInCustomizationForm="True" VisibleIndex="4" Width="500px">
                            <PropertiesComboBox DataSourceID="ds_program" DropDownWidth="600px" 
                                IncrementalFilteringMode="Contains" TextField="progname" TextFormatString="{1}" 
                                ValueField="progcode">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="100px" />
                                    <dx:ListBoxColumn Caption="Programme" FieldName="progname" Name="500px" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Subjects" FieldName="sub_comb" 
                            ShowInCustomizationForm="True" VisibleIndex="12" Width="200px">
                            <PropertiesComboBox DataSourceID="ds_specialisation" DropDownWidth="600px" 
                                IncrementalFilteringMode="Contains" TextField="abbrev" TextFormatString="{0}" 
                                ValueField="spec_id">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" Name="100px" />
                                    <dx:ListBoxColumn Caption="Subjects" FieldName="spec" Name="500px" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Choice" FieldName="choice" 
                            ShowInCustomizationForm="True" VisibleIndex="3" Width="40px">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Session" FieldName="adm_session" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Width="150px">
                            <PropertiesComboBox DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="Session" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
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
                <asp:ObjectDataSource ID="ds_applicantchoices" runat="server" 
                    DeleteMethod="DeleteApplicantChoice" InsertMethod="AddApplicantChoice" 
                    OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetApplicantChoices" TypeName="ApplicationsBLL" 
                    UpdateMethod="EditApplicantChoice">
                    <DeleteParameters>
                        <asp:Parameter Name="original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="stud_entry_no" Type="String" />
                        <asp:Parameter Name="choice" Type="UInt32" />
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="adm_status" Type="UInt32" />
                        <asp:Parameter Name="adm_session" Type="String" />
                        <asp:Parameter Name="sub_comb" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="stud_entry_no" SessionField="stud_entry_no" 
                            Type="String" DefaultValue="" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="stud_entry_no" Type="String" />
                        <asp:Parameter Name="choice" Type="UInt32" />
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="adm_status" Type="UInt32" />
                        <asp:Parameter Name="adm_session" Type="String" />
                        <asp:Parameter Name="sub_comb" Type="String" />
                        <asp:Parameter Name="original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsstudysessions" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                    <InsertParameters>
                        <asp:Parameter Name="Session" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Original_Session" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="ds_program" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetAllProgrammes" 
                    TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_progcode" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="progcode" Type="String" />
                        <asp:Parameter Name="progname" Type="String" />
                        <asp:Parameter Name="mincredit" Type="Double" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="couselength" Type="Double" />
                        <asp:Parameter Name="maxduration" Type="Double" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="levelCode" Type="UInt32" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="progname" Type="String" />
                        <asp:Parameter Name="mincredit" Type="Double" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="couselength" Type="Double" />
                        <asp:Parameter Name="maxduration" Type="Double" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="levelCode" Type="UInt32" />
                        <asp:Parameter Name="Original_progcode" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="ds_specialisation" runat="server" 
                    DeleteMethod="Delete" InsertMethod="Insert" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="admission_dataTableAdapters.acad_specialisationTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="spec" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="spec" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxCallbackPanel>

