<%@ Control Language="C#" AutoEventWireup="true" CodeFile="AcademicStaffDetails.ascx.cs" Inherits="UserControls_HumanResource_TeacherMgt_AcademicStaffDetails" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style3
    {
    }
    .style5
    {
        width: 240px;
    }
    .style8
    {
    }
    .style10
    {
        width: 108px;
    }
    .style11
    {
        width: 64px;
    }
    .style12
    {
        width: 62px;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <dx:ASPxPageControl ID="page_allocations" runat="server" ActiveTabIndex="1" 
        Width="100%">
        <TabPages>
            <dx:TabPage Text="Subject Allocation">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <table class="style1">
                            <tr>
                                <td colspan="4" style="text-align: center">
                                    <dx:ASPxLabel ID="lblheader" runat="server" Font-Size="15px" ForeColor="Red">
                                    </dx:ASPxLabel>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" valign="top">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" Height="1px" 
                                        ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="True" Width="100%">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td class="style11">
                                    &nbsp;</td>
                                <td class="style5">
                                    &nbsp;</td>
                                <td class="style12">
                                    &nbsp;</td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td class="style11">
                                    <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Year">
                                    </dx:ASPxLabel>
                                </td>
                                <td class="style5">
                                    <dx:ASPxComboBox ID="txtyr" runat="server" AutoPostBack="True" 
                                        OnSelectedIndexChanged="txtClass_SelectedIndexChanged" 
                                        Width="200px">
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="style12">
                                    <dx:ASPxLabel ID="ASPxLabel4" runat="server" Text="Subject">
                                    </dx:ASPxLabel>
                                </td>
                                <td>
                                    <dx:ASPxComboBox ID="txtsubject" runat="server" DataSourceID="dsSubjects" 
                                        DropDownWidth="500px" TextField="subname" TextFormatString="{1}" 
                                        ValueField="subcode" Width="200px" IncrementalFilteringMode="Contains">
                                        <Columns>
                                            <dx:ListBoxColumn FieldName="subcode" Width="25px" />
                                            <dx:ListBoxColumn FieldName="subname" Width="200px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="style11">
                                    <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="Class">
                                    </dx:ASPxLabel>
                                </td>
                                <td class="style5">
                                    <dx:ASPxComboBox ID="txtClass" runat="server" AutoPostBack="True" 
                                        OnSelectedIndexChanged="txtClass_SelectedIndexChanged" SelectedIndex="0" 
                                        ValueType="System.Int32" Width="200px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="YEAR 7" Value="7" />
                                            <dx:ListEditItem Text="YEAR 8" Value="8" />
                                            <dx:ListEditItem Text="YEAR 9" Value="9" />
                                            <dx:ListEditItem Text="YEAR 10" Value="10" />
                                            <dx:ListEditItem Text="YEAR 11" Value="11" />
                                            <dx:ListEditItem Text="YEAR 12" Value="12" />
                                            <dx:ListEditItem Text="YEAR 13" Value="13" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="style12">
                                    <dx:ASPxLabel ID="ASPxLabel" runat="server" Text="Paper">
                                    </dx:ASPxLabel>
                                </td>
                                <td>
                                    <dx:ASPxComboBox ID="txtpaper" runat="server" AutoPostBack="True" 
                                        OnSelectedIndexChanged="txtClass_SelectedIndexChanged" SelectedIndex="0" 
                                        ValueType="System.Int32" Width="200px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                            <dx:ListEditItem Text="5" Value="5" />
                                            <dx:ListEditItem Text="6" Value="6" />
                                            <dx:ListEditItem Text="7" Value="7" />
                                            <dx:ListEditItem Text="8" Value="8" />
                                            <dx:ListEditItem Text="9" Value="9" />
                                            <dx:ListEditItem Text="10" Value="10" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="style11">
                                    <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text="Term">
                                    </dx:ASPxLabel>
                                </td>
                                <td class="style5">
                                    <dx:ASPxComboBox ID="txtterm" runat="server" AutoPostBack="True" 
                                        OnSelectedIndexChanged="txtClass_SelectedIndexChanged" SelectedIndex="0" 
                                        ValueType="System.Int32" Width="200px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="style12">
                                    &nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="btnallocate" runat="server" OnClick="btnallocate_Click" 
                                        Text="Allocate Subject" Width="200px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="style11">
                                    &nbsp;</td>
                                <td class="style5">
                                    <asp:ObjectDataSource ID="dsSubjects" runat="server" OldValuesParameterFormatString="original_{0}" 
                                        SelectMethod="GetData" 
                                        TypeName="InternationalDataTableAdapters.int_subjectsTableAdapter">
                                    </asp:ObjectDataSource>
                                </td>
                                <td class="style12">
                                    &nbsp;</td>
                                <td>
                                    <asp:ObjectDataSource ID="dsAllSubjects" runat="server" OldValuesParameterFormatString="original_{0}" 
                                        SelectMethod="GetData" 
                                        TypeName="InternationalDataTableAdapters.int_subjectsTableAdapter">
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td class="style3" colspan="4">
                                    <dx:ASPxGridView ID="gvAllocations" runat="server" AutoGenerateColumns="False" 
                                        DataSourceID="dsallocations" KeyFieldName="ID" Width="100%" 
                                        OnRowDeleting="gvAllocations_RowDeleting">
                                        <Columns>
                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="CurrentYear" 
                                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="Term" ShowInCustomizationForm="True" 
                                                Visible="False" VisibleIndex="3">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Class" FieldName="SubjectClass" 
                                                ShowInCustomizationForm="True" VisibleIndex="4" Width="40px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Subject Code" FieldName="subcode" 
                                                ShowInCustomizationForm="True" VisibleIndex="5" Width="100px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="EmpCode" ShowInCustomizationForm="True" 
                                                Visible="False" VisibleIndex="7">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Paper" FieldName="paper" 
                                                ShowInCustomizationForm="True" VisibleIndex="8" Width="30px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Subject" FieldName="subcode" 
                                                ShowInCustomizationForm="True" VisibleIndex="6" Width="300px">
                                                <PropertiesComboBox DataSourceID="dsAllSubjects" TextField="subname" 
                                                    TextFormatString="{0}" ValueField="subcode">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Subject" FieldName="subname" />
                                                    </Columns>
                                                </PropertiesComboBox>
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewCommandColumn ShowDeleteButton="True" 
                                                ShowInCustomizationForm="True" VisibleIndex="9" Width="20px">
                                            </dx:GridViewCommandColumn>
                                        </Columns>
                                        <SettingsBehavior ConfirmDelete="True" AllowFocusedRow="True" />
                                        <SettingsText CommandDelete="| Delete |" ConfirmDelete="Delete Subject?" />
                                        <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td class="style11">
                                    &nbsp;</td>
                                <td class="style5">
                                    &nbsp;</td>
                                <td class="style12">
                                    &nbsp;</td>
                                <td>
                                    <asp:ObjectDataSource ID="dsallocations" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" 
                                        SelectMethod="GetDataBy_SubjectAllocation" 
                                        TypeName="HRMDataTableAdapters.int_subjectallocationTableAdapter" 
                                        InsertMethod="Insert" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt64" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="CurrentYear" Type="UInt32" />
                                            <asp:Parameter Name="Term" Type="UInt32" />
                                            <asp:Parameter Name="Class" Type="UInt32" />
                                            <asp:Parameter Name="subcode" Type="String" />
                                            <asp:Parameter Name="EmpCode" Type="String" />
                                            <asp:Parameter Name="paper" Type="UInt32" />
                                            <asp:Parameter Name="workdone" Type="String" />
                                            <asp:Parameter Name="weight" Type="Double" />
                                            <asp:Parameter Name="weight_end" Type="Double" />
                                            <asp:Parameter Name="workdone_end" Type="String" />
                                        </InsertParameters>
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txtyr" Name="CurrentYr" PropertyName="Value" 
                                                Type="String" />
                                            <asp:ControlParameter ControlID="txtterm" Name="Trm" PropertyName="Value" 
                                                Type="Int32" />
                                            <asp:SessionParameter Name="EmpCod" SessionField="EmpCode" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="CurrentYear" Type="UInt32" />
                                            <asp:Parameter Name="Term" Type="UInt32" />
                                            <asp:Parameter Name="Class" Type="UInt32" />
                                            <asp:Parameter Name="subcode" Type="String" />
                                            <asp:Parameter Name="EmpCode" Type="String" />
                                            <asp:Parameter Name="paper" Type="UInt32" />
                                            <asp:Parameter Name="workdone" Type="String" />
                                            <asp:Parameter Name="weight" Type="Double" />
                                            <asp:Parameter Name="weight_end" Type="Double" />
                                            <asp:Parameter Name="workdone_end" Type="String" />
                                            <asp:Parameter Name="Original_ID" Type="UInt64" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td class="style11">
                                    &nbsp;</td>
                                <td class="style5">
                                    &nbsp;</td>
                                <td class="style12">
                                    &nbsp;</td>
                                <td>
                                    <dx:ASPxPopupControl ID="popup_message" runat="server" HeaderText="" 
                                        Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" 
                                        PopupVerticalAlign="WindowCenter" style="text-align: center" Width="400px">
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td align="center">
                                                            <br />
                                                            <dx:ASPxLabel ID="lbl_message" runat="server" ForeColor="Red" 
                                                                style="text-align: center">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </dx:PopupControlContentControl>
                                        </ContentCollection>
                                    </dx:ASPxPopupControl>
                                </td>
                            </tr>
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text="Tutor Group Allocation">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                    <table class="style1">
                            <tr>
                                <td colspan="4" style="text-align: center">
                                    <dx:ASPxLabel ID="lbl_tutorgroupheader" runat="server" Font-Size="15px" 
                                        ForeColor="Red">
                                    </dx:ASPxLabel>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" valign="top">
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                        ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="True" Width="100%">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td class="style8">
                                    &nbsp;</td>
                                <td class="style5">
                                    &nbsp;</td>
                                <td class="style10">
                                    &nbsp;</td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td class="style8">
                                    <dx:ASPxLabel ID="ASPxLabel6" runat="server" Text="Year">
                                    </dx:ASPxLabel>
                                </td>
                                <td class="style5">
                                    <dx:ASPxComboBox ID="txt_tutoryear" runat="server" AutoPostBack="True" 
                                        OnSelectedIndexChanged="txt_tutoryear_SelectedIndexChanged" 
                                        Width="170px">
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="style10">
                                    <dx:ASPxLabel ID="ASPxLabel7" runat="server" Text="Student Admn No.">
                                    </dx:ASPxLabel>
                                </td>
                                <td>
                                    <dx:ASPxTextBox ID="txtAdmNo" runat="server" Width="200px">
                                    </dx:ASPxTextBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="style8">
                                    <dx:ASPxLabel ID="ASPxLabel10" runat="server" Text="Term">
                                    </dx:ASPxLabel>
                                </td>
                                <td class="style5">
                                    <dx:ASPxComboBox ID="txt_tutorterm" runat="server" AutoPostBack="True" 
                                        SelectedIndex="0">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="style10">
                                    &nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="btnAddStudent" runat="server" OnClick="btnAddStudent_Click" 
                                        Text="Add Student" Width="200px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="style3" colspan="4">
                                    <dx:ASPxGridView ID="gvtutorgroup" runat="server" AutoGenerateColumns="False" 
                                        DataSourceID="dsTutorGroup" KeyFieldName="ID" Width="100%">
                                        <Columns>
                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="CurrentYear" 
                                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="Term" ShowInCustomizationForm="True" 
                                                Visible="False" VisibleIndex="3">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Class" FieldName="studentClass" 
                                                ShowInCustomizationForm="True" VisibleIndex="7" Width="40px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Admission No" FieldName="admno" 
                                                ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="EmpCode" ShowInCustomizationForm="True" 
                                                Visible="False" VisibleIndex="8">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewCommandColumn ShowDeleteButton="True" 
                                                ShowInCustomizationForm="True" VisibleIndex="10" Width="20px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataTextColumn Caption="Name" FieldName="studName" 
                                                ShowInCustomizationForm="True" VisibleIndex="6" Width="300px">
                                            </dx:GridViewDataTextColumn>
                                        </Columns>
                                        <SettingsBehavior ConfirmDelete="True" AllowFocusedRow="True" />
                                        <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                        <SettingsText CommandDelete="| Delete |" ConfirmDelete="Delete Subject?" />
                                        <SettingsDataSecurity AllowEdit="False" AllowInsert="False" />
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td class="style8" colspan="4">
                                    <asp:ObjectDataSource ID="dsTutorGroup" runat="server" DeleteMethod="Delete" 
                                        InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                        SelectMethod="GetDataBy_TutorGroups" 
                                        TypeName="HRMDataTableAdapters.int_tutorgroupsTableAdapter" 
                                        UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt64" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="_class" Type="UInt32" />
                                            <asp:Parameter Name="studyyear" Type="String" />
                                            <asp:Parameter Name="term" Type="UInt32" />
                                            <asp:Parameter Name="admno" Type="String" />
                                            <asp:Parameter Name="EmpCode" Type="UInt32" />
                                            <asp:Parameter Name="comments" Type="String" />
                                            <asp:Parameter Name="comments_end" Type="String" />
                                        </InsertParameters>
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txt_tutoryear" Name="CurrentYr" 
                                                PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txt_tutorterm" Name="Trm" PropertyName="Value" 
                                                Type="Int32" />
                                            <asp:SessionParameter Name="EmpCod" SessionField="EmpCode" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="comments" Type="String" />
                                            <asp:Parameter Name="comments_end" Type="String" />
                                            <asp:Parameter Name="Original_ID" Type="Int64" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <dx:ASPxPopupControl ID="popup_tutorgroups" runat="server" HeaderText="" 
                                        Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" 
                                        PopupVerticalAlign="WindowCenter" style="text-align: center" Width="400px">
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td align="center">
                                                            <dx:ASPxLabel ID="lbl_tutormessage" runat="server" ForeColor="Red" 
                                                                style="text-align: center">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </dx:PopupControlContentControl>
                                        </ContentCollection>
                                    </dx:ASPxPopupControl>
                                </td>
                            </tr>
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
        </TabPages>
    </dx:ASPxPageControl>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

