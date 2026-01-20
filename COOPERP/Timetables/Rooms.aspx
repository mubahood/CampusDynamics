<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Timetables/MasterPage.master" AutoEventWireup="true" CodeFile="Rooms.aspx.cs" Inherits="COOPERP_Timetables_Rooms" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
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
        width: 21px;
    }
    .auto-style3 {
        width: 325px;
    }
    .auto-style4 {
        width: 82px;
    }


    .auto-style5 {
        width: 21px;
        height: 40px;
    }
    .auto-style6 {
        width: 325px;
        height: 40px;
    }
    .auto-style7 {
        width: 82px;
        height: 40px;
    }
    .auto-style8 {
        height: 40px;
    }


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_rooms_mgt.png" >
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style5">Campus:</td>
                        <td class="auto-style6">
                            <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" SelectedIndex="0" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" Width="300px" Height="30px" ValueType="System.Int32">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                    <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style7"></td>
                        <td class="auto-style8">
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">&nbsp;</td>
                        <td class="auto-style3">
                            <dx:ASPxButton ID="cmdAddNew" runat="server" Height="30px" OnClick="cmdAddNew_Click" Text="Add New Room" Width="300px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style4">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvRooms" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="dsRooms" KeyFieldName="RoomID" OnInitNewRow="gvRooms_InitNewRow">
                    <SettingsEditing Mode="PopupEditForm" EditFormColumnCount="1">
                    </SettingsEditing>
                    <Settings ShowFilterRowMenu="True" />
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsCommandButton>
                        <UpdateButton Text="| Update |">
                        </UpdateButton>
                        <CancelButton Text="| Cancel |">
                        </CancelButton>
                        <EditButton Text="| Edit |">
                        </EditButton>
                    </SettingsCommandButton>
                    <SettingsPopup>
                        <EditForm Height="150px" HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" Width="500px" />
                        <CustomizationWindow HorizontalAlign="NotSet" VerticalAlign="NotSet" />
                    </SettingsPopup>
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="RoomID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="30px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Room Capacity" FieldName="Capacity" ShowInCustomizationForm="True" VisibleIndex="3" Width="60px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Room" FieldName="RoomName" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="17" Width="30px" ShowEditButton="True">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Campus" FieldName="campusId" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                            <PropertiesComboBox DataSourceID="dsCampus" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32">
                                <Columns>
                                    <dx:ListBoxColumn Caption="SNo" FieldName="ID" />
                                    <dx:ListBoxColumn Caption="Name" FieldName="campus_name" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsRooms" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_CampusLectureRooms" TypeName="TimetableDataTableAdapters.acad_lectureroomsTableAdapter" UpdateMethod="Update" InsertMethod="Insert">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_RoomID" Type="Int32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="RoomID" Type="Int32" />
                        <asp:Parameter Name="RoomName" Type="String" />
                        <asp:Parameter Name="Capacity" Type="Int32" />
                        <asp:Parameter Name="campusId" Type="Int32" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtCampus" Name="campusno" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="RoomName" Type="String" />
                        <asp:Parameter Name="Capacity" Type="Int32" />
                        <asp:Parameter Name="campusId" Type="Int32" />
                        <asp:Parameter Name="Original_RoomID" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <br />
                <asp:ObjectDataSource ID="dsCampus" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CampusDataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
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
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                            <table align="center" class="style1">
                                <tr>
                                    <td align="center">
                                        <br />
                                        <br />
                                        <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red" style="font-weight: 700">
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
</asp:Content>

