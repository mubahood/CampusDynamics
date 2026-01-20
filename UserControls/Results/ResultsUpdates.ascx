<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ResultsUpdates.ascx.cs" Inherits="UserControls_Results_ResultsUpdates" %>
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
        width: 64px;
    }
    .auto-style3 {
        width: 103px;
    }
    .auto-style4 {
        width: 194px;
    }
    .auto-style5 {
        width: 167px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table class="style1">
                <tr>
                    <td>
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_resultsupdates.png">
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
                                <td>
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style1">Faculty:</td>
                                            <td class="auto-style5">
                                                <dx:ASPxComboBox ID="txtFaculty" runat="server" DataSourceID="dsFaculties" SelectedIndex="0" TextField="faculty_name" TextFormatString="{0} - {1}" ValueField="fax_code">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	gvMarksheetInfo.Refresh();
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="fax_code" />
                                                        <dx:ListBoxColumn Caption="Faculty" FieldName="faculty_name" Width="300px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style3">
                                                <dx:ASPxButton ID="cmdReject" runat="server" Text="Reject Changes" Width="170px" OnClick="cmdReject_Click">
                                                    <Image Url="~/COOPERP/images/minus-button.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style1">&nbsp;</td>
                                            <td class="auto-style5">
                                                <dx:ASPxButton ID="cmdAddChanges" runat="server" OnClick="cmdApprove_Click" Text="Add Change" Width="170px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td class="auto-style3">
                                                <dx:ASPxButton ID="cmdApprove" runat="server" OnClick="cmdApprove_Click1" Text="Approve Changes" Width="170px">
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">
                                    <dx:ASPxTextBox ID="txtSearch" runat="server" AutoCompleteType="Search" Height="27px" NullText="Enter Search Text" Width="170px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	gvMarksheetInfo.Refresh();
}" />
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxTextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsMarksheetInfo" KeyFieldName="ID" Width="100%" OnRowUpdated="gvMarksheetInfo_RowUpdated">
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="SNo" FieldName="ID" ReadOnly="True" VisibleIndex="1">
                                    <EditFormSettings Visible="False" />
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Reg No" FieldName="regno" VisibleIndex="2" Width="120px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Course Code" FieldName="courseid" VisibleIndex="4">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Semester" FieldName="semester" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Academic Year" FieldName="acad" VisibleIndex="7" Visible="False">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Study Year" FieldName="studyyear" VisibleIndex="8">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" VisibleIndex="9">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Grade PT" FieldName="gradept" VisibleIndex="10">
                                    <PropertiesTextEdit DisplayFormatString="{0:0.0}">
                                    </PropertiesTextEdit>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Comments" FieldName="result_comment" VisibleIndex="11" Visible="False">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="CreditUnits" Visible="False" VisibleIndex="12">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Old Score" FieldName="old_score" VisibleIndex="13" ReadOnly="True">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="New Score" FieldName="new_score" VisibleIndex="14">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Created By" FieldName="created_by" VisibleIndex="15">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Date Created" FieldName="date_created" Visible="False" VisibleIndex="16">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Approved By" FieldName="approved_by" VisibleIndex="17">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Date Approved" FieldName="date_approved" Visible="False" VisibleIndex="18">
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Student" FieldName="stud_name" VisibleIndex="3" Width="190px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Course Name" FieldName="coursename" VisibleIndex="5">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewCommandColumn ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" VisibleIndex="23" Width="40px"/>
                                <dx:GridViewDataMemoColumn Caption="Explanation" FieldName="explanation" Visible="False" VisibleIndex="20">
                                    <EditFormSettings ColumnSpan="2" Visible="True" />
                                </dx:GridViewDataMemoColumn>
                                <dx:GridViewDataTextColumn Caption="Profile" VisibleIndex="22" Width="25px">
                                     <EditFormSettings Visible="False" />
                                     <DataItemTemplate>
                                                        <asp:ImageButton ID="cmdDetails" runat="server" ImageUrl="~/COOPERP/images/card-address.png" OnClick="cmdDetails_Click" />
                                                    </DataItemTemplate>
                                     <CellStyle HorizontalAlign="Center">
                                     </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Action" FieldName="operation" ShowInCustomizationForm="True" VisibleIndex="21" Width="50px">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsPager PageSize="200" Position="TopAndBottom">
                            </SettingsPager>
                            <SettingsEditing Mode="EditForm">
                            </SettingsEditing>
                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                           <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
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
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetResultsChangesByFaculty" TypeName="ResultsDataTableAdapters.acad_resultsupdatesTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="courseid" Type="String" />
                                <asp:Parameter Name="semester" Type="Int32" />
                                <asp:Parameter Name="acad" Type="String" />
                                <asp:Parameter Name="studyyear" Type="Int32" />
                                <asp:Parameter Name="grade" Type="String" />
                                <asp:Parameter Name="gradept" Type="Double" />
                                <asp:Parameter Name="result_comment" Type="String" />
                                <asp:Parameter Name="CreditUnits" Type="Double" />
                                <asp:Parameter Name="old_score" Type="UInt32" />
                                <asp:Parameter Name="new_score" Type="UInt32" />
                                <asp:Parameter Name="created_by" Type="String" />
                                <asp:Parameter Name="date_created" Type="DateTime" />
                                <asp:Parameter Name="approved_by" Type="String" />
                                <asp:Parameter Name="date_approved" Type="DateTime" />
                                <asp:Parameter Name="explanation" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtFaculty" Name="fax" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtSearch" DefaultValue="%" Name="txt" PropertyName="Text" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="courseid" Type="String" />
                                <asp:Parameter Name="semester" Type="Int32" />
                                <asp:Parameter Name="acad" Type="String" />
                                <asp:Parameter Name="studyyear" Type="Int32" />
                                <asp:Parameter Name="grade" Type="String" />
                                <asp:Parameter Name="gradept" Type="Double" />
                                <asp:Parameter Name="result_comment" Type="String" />
                                <asp:Parameter Name="CreditUnits" Type="Double" />
                                <asp:Parameter Name="old_score" Type="UInt32" />
                                <asp:Parameter Name="new_score" Type="UInt32" />
                                <asp:Parameter Name="created_by" Type="String" />
                                <asp:Parameter Name="date_created" Type="DateTime" />
                                <asp:Parameter Name="approved_by" Type="String" />
                                <asp:Parameter Name="date_approved" Type="DateTime" />
                                <asp:Parameter Name="explanation" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetUserFaculties" TypeName="SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="unm" SessionField="username" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" CloseAction="CloseButton" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvMarksheetInfo.Refresh();
}" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
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
        </ContentTemplate>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>