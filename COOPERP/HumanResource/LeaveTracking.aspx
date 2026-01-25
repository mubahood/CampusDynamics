<%@ Page Language="C#" AutoEventWireup="true" CodeFile="LeaveTracking.aspx.cs" Inherits="COOPERP_HumanResource_LeaveTracking" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="rp_leaverecords" runat="server" HeaderText="Leave Tracking" ShowCollapseButton="true" Width="100%">
            <HeaderStyle Font-Bold="True" ForeColor="Blue" HorizontalAlign="Center" />
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Add New" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvLeaveRecords" runat="server" AutoGenerateColumns="False" DataSourceID="dsLeaveRecords" KeyFieldName="ID" Width="100%" OnRowUpdating="gvLeaveRecords_RowUpdating">
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <Settings ShowFooter="True" />
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="leaveID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Start Date" FieldName="startDate" ShowInCustomizationForm="True" VisibleIndex="3">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataDateColumn Caption="End Date" FieldName="endDate" ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="No Days" FieldName="no_days" ShowInCustomizationForm="True" VisibleIndex="5" Width="50px">
                            <FooterCellStyle BackColor="Red" Font-Bold="True" ForeColor="White">
                            </FooterCellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="2" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="6" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <TotalSummary>
                        <dx:ASPxSummaryItem DisplayFormat="Total={0:0,0}" FieldName="no_days" ShowInColumn="No Days" ShowInGroupFooterColumn="No Days" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                    </TotalSummary>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsLeaveRecords" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetLeaveTrackInfo" TypeName="HRMDataTableAdapters.hrm_leave_takenTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="leaveID" Type="UInt32" />
                        <asp:Parameter Name="startDate" Type="DateTime" />
                        <asp:Parameter Name="endDate" Type="DateTime" />
                        <asp:Parameter Name="no_days" Type="UInt32" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="lid" SessionField="lid" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="leaveID" Type="UInt32" />
                        <asp:Parameter Name="startDate" Type="DateTime" />
                        <asp:Parameter Name="endDate" Type="DateTime" />
                        <asp:Parameter Name="no_days" Type="UInt32" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td><dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                            <table class="dx-justification">
                                <tr>
                                    <td>
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="text-align: center">
                                        <dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Blue">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl></td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
