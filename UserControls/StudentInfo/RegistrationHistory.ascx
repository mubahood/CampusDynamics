<%@ Control Language="C#" AutoEventWireup="true" CodeFile="RegistrationHistory.ascx.cs" Inherits="UserControls_StudentInfo_RegistrationHistory" %>

<style type="text/css">
    .tdWidth {
        width:150px;
    }
    
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

    .auto-style3 {
        width: 866px;
    }
    .auto-style4 {
        width: 340px;
    }

</style>



<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" Width="100%">
    <PanelCollection>
        <dx:PanelContent runat="server">
            <table style="width:100%">
                <tr>
                    <td>
                        <table style="width:100%">
                            <tr>
                                <td>
                                    <dx:ASPxButton ID="cmdAdd" runat="server" Height="35px" OnClick="cmdAdd_Click" Text="New Registration" Width="170px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td align="Right" style="width:150px">
                                    &nbsp;</td>
                                <td align="Right" class="auto-style4">
                                    <dx:ASPxComboBox ID="txtDocType" runat="server" Height="35px" SelectedIndex="0" Width="200px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="ID Card" Value="Identity Cards" />
                                            <dx:ListEditItem Text="Registration Card" Value="Registration Card" />
                                            <dx:ListEditItem Text="Exam Card" Value="Exam Card" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td align="Right" style="width:150px">
                                    <dx:ASPxButton ID="cmdPrint" runat="server" Height="35px" OnClick="cmdPrint_Click" Text="Print" Width="200px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td align="Right" style="width:150px">&nbsp;</td>
                                <td align="Right" class="auto-style4">
                                    <dx:ASPxComboBox ID="txtClearanceType" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="Examination Clearance" Value="Examination" />
                                            <dx:ListEditItem Text="Registration Clearance" Value="Registration" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td align="Right" style="width:150px">
                                    <dx:ASPxButton ID="cmdClearExam" runat="server" Height="35px" OnClick="cmdClearExam_Click" Text="Process | Cancel Clearance" Width="200px">
                                        <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm ('Process Clearance?'); 
}" />
                                        <Image IconID="actions_apply_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td align="Right" style="width:150px">&nbsp;</td>
                                <td align="Right" class="auto-style4">&nbsp;</td>
                                <td align="Right" style="width:150px">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvRegistrationHistory" runat="server" AutoGenerateColumns="False" DataSourceID="dsRegistrationHistory" EnableCallBacks="False" KeyFieldName="ID" OnCustomErrorText="gvRegistrationHistory_CustomErrorText" OnHtmlDataCellPrepared="gvRegistrationHistory_HtmlDataCellPrepared" OnInitNewRow="gvRegistrationHistory_InitNewRow" OnRowInserting="gvRegistrationHistory_RowInserting" OnRowUpdating="gvRegistrationHistory_RowUpdating" Width="100%">
                            <SettingsContextMenu Enabled="True">
                            </SettingsContextMenu>
                            <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                <BatchEditSettings StartEditAction="DblClick" />
                            </SettingsEditing>
                            <SettingsBehavior AllowFocusedRow="True" />
                            <SettingsCommandButton RenderMode="Button">
                            </SettingsCommandButton>
                            <SettingsPopup>
                                <EditForm HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" />
                            </SettingsPopup>
                            <EditFormLayoutProperties>
                                <Items>
                                    <dx:GridViewLayoutGroup Caption="Registration Info">
                                        <Items>
                                            <dx:EmptyLayoutItem>
                                            </dx:EmptyLayoutItem>
                                            <dx:GridViewColumnLayoutItem ColumnName="regno">
                                            </dx:GridViewColumnLayoutItem>
                                            <dx:GridViewColumnLayoutItem ColumnName="acad_year">
                                            </dx:GridViewColumnLayoutItem>
                                            <dx:GridViewColumnLayoutItem ColumnName="semester">
                                            </dx:GridViewColumnLayoutItem>
                                            <dx:GridViewColumnLayoutItem ColumnName="regstatus">
                                            </dx:GridViewColumnLayoutItem>
                                            <dx:GridViewColumnLayoutItem ColumnName="studyyear">
                                            </dx:GridViewColumnLayoutItem>
                                            <dx:EmptyLayoutItem>
                                            </dx:EmptyLayoutItem>
                                            <dx:EditModeCommandLayoutItem HorizontalAlign="Right">
                                            </dx:EditModeCommandLayoutItem>
                                        </Items>
                                    </dx:GridViewLayoutGroup>
                                </Items>
                            </EditFormLayoutProperties>
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Reg No" FieldName="regno" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                    <PropertiesTextEdit Height="35px">
                                    </PropertiesTextEdit>
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="ID Status" FieldName="id_cardStatus" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Residence" FieldName="residence_status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Reg Card" FieldName="reg_CardStatus" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Exam Clearance" FieldName="examClearance" ShowInCustomizationForm="True" VisibleIndex="15">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Date Cleared" FieldName="examClearanceDate" ShowInCustomizationForm="True" VisibleIndex="16">
                                    <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy">
                                    </PropertiesDateEdit>
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Cleared By" FieldName="clearedBy" ShowInCustomizationForm="True" VisibleIndex="17">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Registered By" FieldName="registeredBy" ShowInCustomizationForm="True" VisibleIndex="18">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Academic Year" FieldName="acad_year" ShowInCustomizationForm="True" VisibleIndex="5">
                                    <PropertiesComboBox DataSourceID="dsAcadYears" Height="35px" IncrementalFilteringMode="StartsWith" TextField="acadyear" TextFormatString="{0}" ValueField="acadyear">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Academic Year" FieldName="acadyear" />
                                        </Columns>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Semester" FieldName="semester" ShowInCustomizationForm="True" VisibleIndex="7">
                                    <PropertiesComboBox Height="35px" IncrementalFilteringMode="StartsWith">
                                        <Items>
                                            <dx:ListEditItem Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Study Year" FieldName="studyyear" ShowInCustomizationForm="True" VisibleIndex="11">
                                    <PropertiesComboBox Height="35px" IncrementalFilteringMode="StartsWith">
                                        <Items>
                                            <dx:ListEditItem Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                            <dx:ListEditItem Text="5" Value="5" />
                                            <dx:ListEditItem Text="6" Value="6" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="regstatus" ShowInCustomizationForm="True" VisibleIndex="10">
                                    <PropertiesComboBox Height="35px" IncrementalFilteringMode="StartsWith">
                                        <Items>
                                            <dx:ListEditItem Text="REGISTERED" Value="REGISTERED" />
                                            <dx:ListEditItem Text="LATE REGISTERED" Value="LATE REGISTERED" />
                                            <dx:ListEditItem Text="UNREGISTERED" Value="UNREGISTERED" />
                                            <dx:ListEditItem Text="DEAD YEAR" Value="DEAD YEAR" />
                                            <dx:ListEditItem Text="HALTED" Value="HALTED" />
                                            <dx:ListEditItem Text="TRANSFERED" Value="TRANSFERED" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsRegistrationHistory" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetRegistrationHistory" TypeName="StudentDataTableAdapters.acad_registrationTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="acad_year" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="regstatus" Type="String" />
                                <asp:Parameter Name="studyyear" Type="UInt32" />
                                <asp:Parameter Name="id_cardStatus" Type="String" />
                                <asp:Parameter Name="residence_status" Type="String" />
                                <asp:Parameter Name="reg_CardStatus" Type="String" />
                                <asp:Parameter Name="examClearance" Type="String" />
                                <asp:Parameter Name="examClearanceDate" Type="DateTime" />
                                <asp:Parameter Name="clearedBy" Type="String" />
                                <asp:Parameter Name="registeredBy" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:SessionParameter DefaultValue="0" Name="reg" SessionField="regno" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="acad_year" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="regstatus" Type="String" />
                                <asp:Parameter Name="studyyear" Type="UInt32" />
                                <asp:Parameter Name="id_cardStatus" Type="String" />
                                <asp:Parameter Name="residence_status" Type="String" />
                                <asp:Parameter Name="reg_CardStatus" Type="String" />
                                <asp:Parameter Name="examClearance" Type="String" />
                                <asp:Parameter Name="examClearanceDate" Type="DateTime" />
                                <asp:Parameter Name="clearedBy" Type="String" />
                                <asp:Parameter Name="registeredBy" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsAcadYears" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_acadyearsTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="acadyear" Type="String" />
                            </InsertParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="acadyear" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                        <br />
                                        <br />
                                                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red" style="font-weight: 700">
                                                </dx:ASPxLabel>
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
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>

