<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ResearchMarkSheetDetails.ascx.cs" Inherits="UserControls_Results_WebUserControl" %>


<style type="text/css">



*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}
    .style1 {
        width:100%;
    }


    .auto-style1 {
        width: 109px;
    }
    .auto-style2 {
        width: 165px;
    }


    </style>

<dx:ASPxRoundPanel ID="rp_details" runat="server" HeaderText="MARKSHEET FOR BIT 1101 - INTRODUCTION TO COMPUTING" ShowCollapseButton="true" Width="100%">
    <HeaderStyle ForeColor="Red" HorizontalAlign="Center" Font-Bold="True" VerticalAlign="Middle" />
    <PanelCollection>
<dx:PanelContent runat="server">
    <dx:ASPxCallbackPanel ID="CBP_Marks" runat="server" ClientInstanceName="CBP_Marks" Width="100%">
        <ClientSideEvents EndCallback="function(s, e) {
	pop_DetailsMsg.Show();
}" />
        <PanelCollection>
            <dx:PanelContent runat="server">
                <table class="style1">
                    <tr>
                        <td>
                            <table class="style1">
                                <tr>
                                    <td class="auto-style1">Alternative Code:</td>
                                    <td class="auto-style2">
                                        <dx:ASPxTextBox ID="txtAltCourseID" runat="server" Height="25px" Text="-" Width="170px">
                                            <Paddings PaddingLeft="10px" />
                                        </dx:ASPxTextBox>
                                    </td>
                                    <td>
                                        <dx:ASPxButton ID="cmdApprove" runat="server" AutoPostBack="False" OnClick="cmdApprove_Click1" Text="Approve Selected" Width="170px">
                                            <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Capture Selected Results?');
}" />
                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                    <td align="Right">
                                        <dx:ASPxButton ID="cmdApprove0" runat="server" Height="30px" OnClick="cmdApprove_Click" Text="Approvals" Width="170px">
                                            <Image Url="~/COOPERP/images/tick-button.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            
                            <dx:ASPxGridView ID="gvResearchResultsList" runat="server" AutoGenerateColumns="False" DataSourceID="dsMarksheetDetails" KeyFieldName="ID" Width="100%">
                                <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                                </SettingsPager>
                                <SettingsEditing Mode="Batch">
                                </SettingsEditing>
                                <SettingsBehavior AllowFocusedRow="True" />
                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                <SettingsSearchPanel Visible="True" />
                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Reg No" FieldName="reg_no" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2" Width="130px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="settingID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="InternalExaminer" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="ExternalExaminer" ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Internal Total" FieldName="InternalExaminer_score" ShowInCustomizationForm="True" VisibleIndex="13" Width="60px">
                                        <EditFormSettings Visible="False" />
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="External Total" FieldName="ExternalExaminer_score" ShowInCustomizationForm="True" VisibleIndex="14" Width="60px">
                                        <EditFormSettings Visible="False" />
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Final Score" FieldName="final_score" ShowInCustomizationForm="True" VisibleIndex="17" Width="50px">
                                        <EditFormSettings Visible="False" />
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Status" FieldName="stat" ShowInCustomizationForm="True" VisibleIndex="18" Width="70px">
                                        <EditFormSettings Visible="False" />
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Attempt" FieldName="attempt" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19" Width="30px">
                                        <EditFormSettings Visible="False" />
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Student Name" FieldName="StudentName" ShowInCustomizationForm="True" VisibleIndex="4" Width="360px">
                                        <EditFormSettings Visible="False" />
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                    </dx:GridViewCommandColumn>
                                    <dx:GridViewDataTextColumn Caption="Reg No." FieldName="Entryno" ShowInCustomizationForm="True" VisibleIndex="3" Width="320px">
                                        <EditFormSettings Visible="False" />
                                    </dx:GridViewDataTextColumn>
                                </Columns>
                            </dx:ASPxGridView>
                            
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:ObjectDataSource ID="dsMarksheetDetails" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetResearchMarkSheet" TypeName="ResultsDataTableAdapters.acad_researchresultsTableAdapter">
                                <DeleteParameters>
                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                </DeleteParameters>
                                <SelectParameters>
                                    <asp:SessionParameter Name="_ID" SessionField="mid" Type="Int64" />
                                </SelectParameters>
                            </asp:ObjectDataSource>
                            <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Text="Processing. Please wait&amp;hellip;">
                            </dx:ASPxLoadingPanel>
                            <br />
                            <dx:ASPxPopupControl ID="pop_messagebox" runat="server" CloseAction="CloseButton" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" ShowPageScrollbarWhenModal="True" Width="300px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <ContentCollection>
                                    <dx:PopupControlContentControl runat="server">
                                        <table align="center" class="style1">
                                            <tr>
                                                <td align="center">
                                                    <table class="style1">
                                                        <tr>
                                                            <td>
                                                                <br />
                                                                <table class="style1">
                                                                    <tr>
                                                                        <td align="center">
                                                                            <dx:ASPxLabel ID="lbl_courseInfo" runat="server" ForeColor="Blue" Text="BIT 1101 - COMMUNICATION SKILLS">
                                                                            </dx:ASPxLabel>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="center">&nbsp;</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="center">New Status</td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxComboBox ID="txtNewStatus" runat="server" SelectedIndex="1" Width="90%">
                                                                    <ClientSideEvents TextChanged="function(s, e) {
	gvMarksheetInfo.Refresh();
}" />
                                                                    <Items>
                                                                        <dx:ListEditItem Text="PENDING" Value="NEW" />
                                                                        <dx:ListEditItem Selected="True" Text="SUBMITTED" Value="SUBMITTED" />
                                                                        <dx:ListEditItem Text="APPROVED" Value="APPROVED" />
                                                                        <dx:ListEditItem Text="CAPTURED" Value="CAPTURED" />
                                                                    </Items>
                                                                    <Paddings PaddingLeft="10px" />
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxButton ID="cmdStatusChange" runat="server" OnClick="cmdStatusChange_Click" Text="Update Status" Width="90%">
                                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Change Approval Status for Selected Results?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <br />
                                                    <dx:ASPxLabel ID="lbl_comment0" runat="server" ForeColor="Red">
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
                            <dx:ASPxPopupControl ID="pop_DetailsMsg" runat="server" ClientInstanceName="pop_DetailsMsg" CloseAction="CloseButton" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <ContentCollection>
                                    <dx:PopupControlContentControl runat="server">
                                        <table align="center" class="style1">
                                            <tr>
                                                <td align="center">
                                                    <br />
                                                    <br />
                                                    <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
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
                </table>
            </dx:PanelContent>
        </PanelCollection>
    </dx:ASPxCallbackPanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>




