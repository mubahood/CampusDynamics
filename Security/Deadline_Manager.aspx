<%@ Page Title="" Language="C#" MasterPageFile="~/Security/MasterPage.master" AutoEventWireup="true" CodeFile="Deadline_Manager.aspx.cs" Inherits="COOPERP_Results_Deadline_Manager" %>
 
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" Width="100%">
        <PanelCollection>
<dx:PanelContent runat="server">
    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
        <TabPages>
            <dx:TabPage Text="Deadlines">
                <TabImage IconID="businessobjects_boscheduler_16x16">
                </TabImage>
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <dx:ASPxRoundPanel ID="ASPxRoundPanel3" runat="server" ShowCollapseButton="True" ShowHeader="False" Width="100%">
                            <PanelCollection>
                                <dx:PanelContent runat="server">
                                    <table class="auto-style5">
                                        <tr>
                                            <td class="auto-style8">
                                                <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="Campus">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="cbx_campus" runat="server" AutoPostBack="True" DataSourceID="ds_Campus" DropDownWidth="500px" Height="30px" TextField="campus_name" TextFormatString="{1}" ValueField="ID" ValueType="System.Int32" Width="200px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="SNo" FieldName="ID" />
                                                        <dx:ListBoxColumn Caption="Name" FieldName="campus_name" Width="300px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">
                                                <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text="Academic Year">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtAcadyear" runat="server" AutoPostBack="True" Height="30px" Width="200px">
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style9">
                                                <dx:ASPxLabel ID="ASPxLabel4" runat="server" Text="Semester/Quarter">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td class="auto-style10">
                                                <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style9">
                                                <dx:ASPxLabel ID="ASPxLabel5" runat="server" Text="Study System:">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td class="auto-style10">
                                                <dx:ASPxComboBox ID="txtStudysystem" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="Quarter" Value="Quarter" />
                                                        <dx:ListEditItem Text="Semester" Value="Semester" />
                                                       
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="btn_add" runat="server" Height="30px" OnClick="btn_add_Click" Text="Add New Deadline" Width="200px">
                                                    <Image IconID="actions_add_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <dx:ASPxGridView ID="gv_deadlines" runat="server" AutoGenerateColumns="False" DataSourceID="ds_deadlines" KeyFieldName="ID" OnCustomErrorText="gv_deadlines_CustomErrorText" OnHtmlRowCreated="gv_deadlines_HtmlRowCreated" OnInitNewRow="gv_deadlines_InitNewRow" Width="100%" OnRowInserting="gv_deadlines_RowInserting">
                                                    <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                                    </SettingsEditing>
                                                    <SettingsBehavior AllowFocusedRow="True" />
                                                    <SettingsCommandButton>
                                                        <UpdateButton RenderMode="Button" Text="Save Changes">
                                                            <Image IconID="save_saveall_16x16">
                                                            </Image>
                                                        </UpdateButton>
                                                        <CancelButton RenderMode="Button" Text="Cancel Changes">
                                                            <Image IconID="save_saveandclose_16x16">
                                                            </Image>
                                                        </CancelButton>
                                                        <EditButton RenderMode="Image">
                                                            <Image IconID="edit_edit_16x16" ToolTip="Edit Deadline">
                                                            </Image>
                                                        </EditButton>
                                                    </SettingsCommandButton>
                                                    <SettingsPopup>
                                                        <EditForm Height="300px" HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" Width="500px" />
                                                    </SettingsPopup>
                                                    <SettingsText PopupEditFormCaption="Activity Deadline Editor" />
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Academic Year" FieldName="AcademicYear" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataSpinEditColumn Caption="Semester" FieldName="Semester" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            <PropertiesSpinEdit DisplayFormatString="g">
                                                            </PropertiesSpinEdit>
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataSpinEditColumn>
                                                        <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="9" Width="20px">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Activity" FieldName="ActivityName" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <PropertiesComboBox DataSourceID="ds_activityDetails" TextField="ItemName" TextFormatString="{0}" ValueField="ItemName">
                                                                <Columns>
                                                                    <dx:ListBoxColumn FieldName="ItemName" />
                                                                </Columns>
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataDateColumn Caption="End Date" FieldName="Deadline" ShowInCustomizationForm="True" VisibleIndex="6">
                                                            <PropertiesDateEdit DisplayFormatInEditMode="True" DisplayFormatString="dd-MMM-yyyy">
                                                            </PropertiesDateEdit>
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn FieldName="CampusID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2" ReadOnly="True">
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="StudySystem" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="EndTime" ShowInCustomizationForm="True" VisibleIndex="8">
                                                            <PropertiesComboBox DisplayFormatInEditMode="True">
                                <Items>
                                                         <dx:ListEditItem Text="07:00 AM" Value="07:00:00" />
                                                                                <dx:ListEditItem Text="07:30 AM" Value="07:30:00" />
                                                                                <dx:ListEditItem Text="8:00 AM" Value="08:00:00" />
                                                                                <dx:ListEditItem Text="8:30 AM" Value="08:30:00" />
                                                                                <dx:ListEditItem Text="9:00 AM" Value="09:00:00" />
                                                                                <dx:ListEditItem Text="9:30 AM" Value="09:30:00" />
                                                                                <dx:ListEditItem Text="10:00 AM" Value="10:00:00" />
                                                                                <dx:ListEditItem Text="10:30 AM" Value="10:30:00" />
                                                                                <dx:ListEditItem Text="11:00 AM" Value="11:00:00" />
                                                                                <dx:ListEditItem Text="11:30 AM" Value="11:30:00" />
                                                                                <dx:ListEditItem Text="12:00 PM" Value="12:00:00" />
                                                                                <dx:ListEditItem Text="12:30 PM" Value="12:30:00" />
                                                                                <dx:ListEditItem Text="1:00 PM" Value="13:00:00" />
                                                                                <dx:ListEditItem Text="2:00 PM" Value="14:00:00" />
                                                                                <dx:ListEditItem Text="2:30 PM" Value="14:30:00" />
                                                                                <dx:ListEditItem Text="3:00 PM" Value="15:00:00" />
                                                                                <dx:ListEditItem Text="3:30 PM" Value="15:30:00" />
                                                                                <dx:ListEditItem Text="4:00 PM" Value="16:00:00" />
                                                                                <dx:ListEditItem Text="4:30 PM" Value="16:30:00" />
                                                                                <dx:ListEditItem Text="5:00 PM" Value="17:00:00" />
                                                                                <dx:ListEditItem Text="5:30 PM" Value="17:30:00" />
                                                                                <dx:ListEditItem Text="6:00 PM" Value="18:00:00" />
                                                                                <dx:ListEditItem Text="6:30 PM" Value="18:30:00" />
                                                                                <dx:ListEditItem Text="7:00 PM" Value="19:00:00" />
                                                                                <dx:ListEditItem Text="7:30 PM" Value="19:30:00" />
                                                                                <dx:ListEditItem Text="8:00 PM" Value="20:00:00" />
                                                                                <dx:ListEditItem Text="8:30 PM" Value="20:30:00" />
                                                                                <dx:ListEditItem Text="9:00 PM" Value="21:00:00" />
                                                                                <dx:ListEditItem Text="9:30 PM" Value="21:30:00" />
                                                                                <dx:ListEditItem Text="10:00 PM" Value="22:00:00" />
                                                         <dx:ListEditItem Text="10:30 PM" Value="22:30:00" />
                                                         <dx:ListEditItem Text="11:00 PM" Value="23:00:00" />
                                                         <dx:ListEditItem Text="12:00 AM" Value="00:00:00" />
                                                    </Items>
                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">&nbsp;</td>
                                            <td>
                                                <asp:ObjectDataSource ID="ds_deadlines" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_CampusDeadlines" TypeName="ResultsecurityTableAdapters.acad_deadlinesTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="ActivityName" Type="String" />
                                                        <asp:Parameter Name="campusID" Type="UInt32" />
                                                        <asp:Parameter Name="Deadline" Type="DateTime" />
                                                        <asp:Parameter Name="AcademicYear" Type="String" />
                                                        <asp:Parameter Name="semester" Type="UInt32" />
                                                        <asp:Parameter Name="StudySystem" Type="String" />
                                                        <asp:Parameter Name="EndTime" Type="String" />
                                                    </InsertParameters>
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="cbx_campus" Name="CampusID" PropertyName="Value" Type="Int32" />
                                                        <asp:ControlParameter ControlID="txtAcadyear" Name="AcademicYear" PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtSemester" Name="Semester" PropertyName="Value" Type="Int32" />
                                                        <asp:ControlParameter ControlID="txtStudysystem" Name="StudySystem" PropertyName="Value" Type="String" />
                                                    </SelectParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="ActivityName" Type="String" />
                                                        <asp:Parameter Name="campusID" Type="UInt32" />
                                                        <asp:Parameter Name="Deadline" Type="DateTime" />
                                                        <asp:Parameter Name="AcademicYear" Type="String" />
                                                        <asp:Parameter Name="semester" Type="UInt32" />
                                                        <asp:Parameter Name="StudySystem" Type="String" />
                                                        <asp:Parameter Name="EndTime" Type="String" />
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="ds_Campus" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_Campus" TypeName="CampusDataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="campus_name" Type="String" />
                                                        <asp:Parameter Name="campus_phone" Type="String" />
                                                        <asp:Parameter Name="campus_email" Type="String" />
                                                        <asp:Parameter Name="campus_short_name" Type="String" />
                                                        <asp:Parameter Name="campus_head" Type="String" />
                                                        <asp:Parameter Name="campus_code" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="campus_name" Type="String" />
                                                        <asp:Parameter Name="campus_phone" Type="String" />
                                                        <asp:Parameter Name="campus_email" Type="String" />
                                                        <asp:Parameter Name="campus_short_name" Type="String" />
                                                        <asp:Parameter Name="campus_head" Type="String" />
                                                        <asp:Parameter Name="campus_code" Type="String" />
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="ds_activityDetails" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ResultsecurityTableAdapters.acad_deadlineitemsTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="ItemName" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="ItemName" Type="String" />
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:PanelContent>
                            </PanelCollection>
                        </dx:ASPxRoundPanel>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text="Deadline Activities">
                <TabImage IconID="actions_insert_16x16">
                </TabImage>
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <dx:ASPxRoundPanel ID="ASPxRoundPanel4" runat="server" ShowCollapseButton="True" ShowHeader="False" Width="100%">
                            <PanelCollection>
                                <dx:PanelContent runat="server">
                                    <table class="auto-style5">
                                        <tr>
                                            <td class="auto-style7" colspan="2">
                                                <dx:ASPxButton ID="btn_addActivity" runat="server" Height="30px" OnClick="btn_addActivity_Click" Text="Add New Activity" Width="200px">
                                                    <Image IconID="actions_add_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <dx:ASPxGridView ID="gv_Activity" runat="server" AutoGenerateColumns="False" DataSourceID="ds_activities" KeyFieldName="ID" OnCustomErrorText="gv_deadlines_CustomErrorText" OnHtmlRowCreated="gv_deadlines_HtmlRowCreated" Width="100%">
                                                    <SettingsEditing EditFormColumnCount="1">
                                                    </SettingsEditing>
                                                    <SettingsBehavior AllowFocusedRow="True" />
                                                    <SettingsCommandButton>
                                                        <EditButton RenderMode="Image">
                                                            <Image IconID="edit_edit_16x16" ToolTip="Edit Ratios">
                                                            </Image>
                                                        </EditButton>
                                                    </SettingsCommandButton>
                                                    <Columns>
                                                        <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="6" Width="20px">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Activity" FieldName="ItemName" ShowInCustomizationForm="True" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style7">&nbsp;</td>
                                            <td>
                                                <asp:ObjectDataSource ID="ds_activities" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ResultsecurityTableAdapters.acad_deadlineitemsTableAdapter" UpdateMethod="Update" DeleteMethod="Delete">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="ItemName" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="ItemName" Type="String" />
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:PanelContent>
                            </PanelCollection>
                        </dx:ASPxRoundPanel>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
        </TabPages>
        <TabStyle>
            <Paddings Padding="10px" />
        </TabStyle>
    </dx:ASPxPageControl>
            </dx:PanelContent>
</PanelCollection>
    </dx:ASPxRoundPanel>
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


        .auto-style5 {
            width: 100%;
        }


        .auto-style7 {
        }


        .auto-style8 {
            width: 113px;
        }
        .auto-style9 {
            width: 113px;
            height: 34px;
        }
        .auto-style10 {
            height: 34px;
        }


    </style>
    
</asp:Content>

