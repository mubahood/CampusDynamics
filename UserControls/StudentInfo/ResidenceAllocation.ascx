<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ResidenceAllocation.ascx.cs" Inherits="UserControls_StudentInfo_ResidenceAllocation" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
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


    .style2_apps
    {
        width: 80px;
    }
    .style3
    {
        width: 218px;
    }
    .style4
    {
        width:40px;
    }
    .style5
    {
        width: 1052px;
    }
    .auto-style1 {
        width: 122px;
    }
    .auto-style2 {
        width: 348px;
    }
    .auto-style5 {
        width: 110px;
    }
    .auto-style7 {
        width: 56px;
    }
    .auto-style8 {
        width: 442px;
    }
</style>



                            <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" ShowHeader="False" Width="100%">
                                <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table5" class="style1">
                <tr>
                    <td>
                        <table id="table6" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_residence_centre.png">
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
                        <table id="table7" class="style1">
                            <tr>
                                <td class="auto-style1">Residence:</td>
                                <td class="auto-style2">
                                    <dx:ASPxComboBox ID="txtResidence" runat="server" AutoPostBack="True" DataSourceID="dsHalls" Height="35px" SelectedIndex="0" TextField="hall_capacity" TextFormatString="{1}" ValueField="ID" ValueType="System.Int32" Width="300px">
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="40px" />
                                            <dx:ListBoxColumn Caption="Residence" FieldName="hall_name" Width="250px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style5">Academic Year:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="35px" Width="340px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">Campus:</td>
                                <td class="auto-style2">
                                    <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" Height="35px" SelectedIndex="0" TextField="campus_name" TextFormatString="{1}" ValueField="ID" ValueType="System.Int32" Width="300px">
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="40px" />
                                            <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" Width="250px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style5">Semester:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" SelectedIndex="0" Height="35px" Width="340px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style2">
                                    <dx:ASPxButton ID="cmdCreateList" runat="server" Height="35px" OnClick="cmdCreateList_Click" Text="Create | Refresh" Width="149px">
                                        <ClientSideEvents Click="function(s, e) {
	if(e.processOnServer = confirm('Are you Sure?')==true)
{
lp_loading.Show();
}
}" />
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                    <dx:ASPxButton ID="cmdPrintList" runat="server" Height="35px" OnClick="cmdPrintList_Click" Text="Print List" Width="149px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style5">Year of Study:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtStudyYear" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="340px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style2">
                                    <dx:ASPxButton ID="cmdNonResidence0" runat="server" Height="35px" Text="Extend Residence" Width="303px">
                                        <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Are you Sure?');
}" />
                                        <Image IconID="navigation_forward_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style5">&nbsp;</td>
                                <td class="auto-style8">
                                    <dx:ASPxButton ID="cmdNonResidence" runat="server" Height="35px" OnClick="cmdNonResidence_Click" Text="Halls Info" Width="170px">
                                        <ClientSideEvents Click="function(s, e) {
	}" />
                                        <Image IconID="navigation_home_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                    <dx:ASPxButton ID="cmdAllocateHall" runat="server" Height="35px" OnClick="cmdAllocateHall_Click" Text="Allocate Residence" Width="170px">
                                        <ClientSideEvents Click="function(s, e) {
	}" />
                                        <Image IconID="actions_apply_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style2">
                                    <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Modal="True">
                                        <LoadingDivStyle BackColor="#3399FF">
                                        </LoadingDivStyle>
                                    </dx:ASPxLoadingPanel>
                                </td>
                                <td class="auto-style5">&nbsp;</td>
                                <td class="auto-style8">
                                    &nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvStudentInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvStudentInfo" DataSourceID="dsStudentInfo" Width="100%" KeyFieldName="ID" OnHtmlDataCellPrepared="gvStudentInfo_HtmlDataCellPrepared">
                            <SettingsCommandButton>
                                <UpdateButton RenderMode="Link">
                                </UpdateButton>
                                <CancelButton RenderMode="Link">
                                </CancelButton>
                                <UpdateButton RenderMode="Link">
                                </UpdateButton>
                                <CancelButton RenderMode="Link">
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
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" VisibleIndex="0" ReadOnly="True" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="regno" VisibleIndex="3" Caption="Stud Number" Width="150px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="acadyear" VisibleIndex="5" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="semester" VisibleIndex="6" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Room No" FieldName="room_id" VisibleIndex="8">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_name" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="1" Width="25px" SelectAllCheckboxMode="Page">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Residence" FieldName="hall_id" VisibleIndex="7">
                                    <PropertiesComboBox DataSourceID="dsHalls" TextField="hall_name" TextFormatString="{1}" ValueField="ID">
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataTextColumn Caption="Reg Number" FieldName="entryno" VisibleIndex="2" Width="150px">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsPager PageSize="100">
                            </SettingsPager>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridViewExporter ID="GVE_Students" runat="server" GridViewID="gvStudentInfo">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsStudentInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetHallList" TypeName="ReidenceDataTableAdapters.acad_residenceTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="acadyear" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="hall_id" Type="UInt32" />
                                <asp:Parameter Name="room_id" Type="String" />
                                <asp:Parameter Name="study_year" Type="UInt32" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="String" DefaultValue="" />
                                <asp:ControlParameter ControlID="txtResidence" Name="hid" PropertyName="Value" Type="String" DefaultValue="0" />
                                <asp:ControlParameter ControlID="txtStudyYear" Name="yr" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtCampus" Name="cid" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="acadyear" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="hall_id" Type="UInt32" />
                                <asp:Parameter Name="room_id" Type="String" />
                                <asp:Parameter Name="study_year" Type="UInt32" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsHalls" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ReidenceDataTableAdapters.acad_hallsTableAdapter"></asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsCampus" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CampusDataTableAdapters.acad_campusesTableAdapter"></asp:ObjectDataSource>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvStudentInfo.Refresh();
}" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red" style="font-weight: 700">
                                                </dx:ASPxLabel>
                                                <br />
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_assignHall" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Hall Allocation" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" >
                            <Paddings Padding="10px" />
                            </HeaderStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl3" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <table class="style1">
                                                    <tr>
                                                        <td class="auto-style7" style="text-align: left">Residence:</td>
                                                        <td style="text-align: left">
                                                            <dx:ASPxComboBox ID="txtNewHall" runat="server" Height="35px" Width="100%" DataSourceID="dsHalls" SelectedIndex="0" TextField="hall_name" TextFormatString="{1}" ValueField="ID" ValueType="System.Int32">
                                                                <Columns>
                                                                    <dx:ListBoxColumn FieldName="ID" Width="25px" />
                                                                    <dx:ListBoxColumn Caption="Hall Name" FieldName="hall_name" Width="200px" />
                                                                </Columns>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="auto-style7">&nbsp;</td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdSetResidence" runat="server" Height="35px" Text="Set Residence" Width="100%" OnClick="cmdSetResidence_Click">
                                                                <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Set Expiry Date?');
	
}" />
                                                                <Image IconID="actions_apply_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <br />
                                                <dx:ASPxLabel ID="lbl_set_hall_comm" runat="server" ForeColor="Blue" style="font-weight: 700">
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_hall_info" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Hall Information" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="500px">
                            <HeaderStyle HorizontalAlign="Center">
                            <Paddings Padding="10px" />
                            </HeaderStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl4" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <table class="style1">
                                                    <tr>
                                                        <td style="text-align: left">
                                                            <dx:ASPxGridView ID="gvHallInfo" runat="server" AutoGenerateColumns="False" DataSourceID="dsHallInfo" KeyFieldName="ID" OnHtmlDataCellPrepared="gvHallInfo_HtmlDataCellPrepared" Width="100%">
                                                                <SettingsContextMenu Enabled="True">
                                                                </SettingsContextMenu>
                                                                <SettingsEditing EditFormColumnCount="1">
                                                                </SettingsEditing>
                                                                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                                <SettingsCommandButton RenderMode="Button">
                                                                </SettingsCommandButton>
                                                                <SettingsSearchPanel Visible="True" />
                                                                <Columns>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="25px">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Hall" FieldName="hall_name" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Capacity" FieldName="hall_capacity" ShowInCustomizationForm="True" VisibleIndex="3" Width="60px">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Hall Fee" FieldName="price" ShowInCustomizationForm="True" VisibleIndex="4" Width="80px">
                                                                        <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                                        </PropertiesTextEdit>
                                                                    </dx:GridViewDataTextColumn>
                                                                </Columns>
                                                            </dx:ASPxGridView>
                                                        </td>
                                                     
                                                    </tr>
                                                    <tr>
                                                        <td class="auto-style7">
                                                            <asp:ObjectDataSource ID="dsHallInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ReidenceDataTableAdapters.acad_hallsTableAdapter" UpdateMethod="Update">
                                                                <DeleteParameters>
                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                </DeleteParameters>
                                                                <InsertParameters>
                                                                    <asp:Parameter Name="hall_name" Type="String" />
                                                                    <asp:Parameter Name="hall_capacity" Type="UInt32" />
                                                                    <asp:Parameter Name="price" Type="Double" />
                                                                </InsertParameters>
                                                                <UpdateParameters>
                                                                    <asp:Parameter Name="hall_name" Type="String" />
                                                                    <asp:Parameter Name="hall_capacity" Type="UInt32" />
                                                                    <asp:Parameter Name="price" Type="Double" />
                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                </UpdateParameters>
                                                            </asp:ObjectDataSource>
                                                        </td>
                                                       
                                                    </tr>
                                                </table>
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
        </ContentTemplate>
    </asp:UpdatePanel>
                                    </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
