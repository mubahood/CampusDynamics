<%@ Page Title="" Language="C#" MasterPageFile="MasterPage.master" AutoEventWireup="true" CodeFile="SystemSettings.aspx.cs" Inherits="COOPERP_SystemSettings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellspacing="0" class="style1" cellpadding="0">
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_systemsettings.png">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td style="width: 64px">
                            
                            Start Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txt_startDate" runat="server" Height="35px" Width="250px" AutoPostBack="True" DisplayFormatString="dd-MMM-yyyy">
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 64px">
                            End Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txt_endDate" runat="server" Height="35px" Width="250px" AutoPostBack="True" DisplayFormatString="dd-MMM-yyyy">
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <dx:ASPxGridView ID="gv_logs" runat="server" AutoGenerateColumns="False" DataSourceID="ds_logs" KeyFieldName="logid" Width="100%">
                                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowFilterRowMenuLikeItem="True" />
                                <SettingsBehavior AllowFocusedRow="True" />
                                <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                                <SettingsSearchPanel Visible="True" />
                                <Columns>
                                    <dx:GridViewDataTextColumn Caption="User" FieldName="user_id" ShowInCustomizationForm="True" VisibleIndex="2" Width="100px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Platform Visited" FieldName="page_function" ShowInCustomizationForm="True" VisibleIndex="3" Width="150px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Details" FieldName="par" ShowInCustomizationForm="True" VisibleIndex="4">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Activity" FieldName="comments" ShowInCustomizationForm="True" VisibleIndex="5" Width="150px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataDateColumn Caption="Access Date" FieldName="access_date" ShowInCustomizationForm="True" VisibleIndex="6" Width="200px">
                                        <PropertiesDateEdit DisplayFormatString="dd-MMM-yyyy hh:mm tt">
                                        </PropertiesDateEdit>
                                    </dx:GridViewDataDateColumn>
                                    <dx:GridViewDataTextColumn Caption="SNo." FieldName="logid" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="30px">
                                    </dx:GridViewDataTextColumn>
                                </Columns>
                            </dx:ASPxGridView>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:ObjectDataSource ID="ds_logs" runat="server" 
                                DeleteMethod="Delete" 
                                InsertMethod="Insert" 
                                OldValuesParameterFormatString="original_{0}" 
                                SelectMethod="GetDataBy_periodicAuditTrail" 
                                TypeName="SecurityTableAdapters.acad_activity_logTableAdapter" 
                                UpdateMethod="Update"
                                FilterExpression="user_id <> 'vicent'">
                                <DeleteParameters>
                                    <asp:Parameter Name="Original_logid" Type="UInt32" />
                                </DeleteParameters>
                                <InsertParameters>
                                    <asp:Parameter Name="user_id" Type="String" />
                                    <asp:Parameter Name="page_function" Type="String" />
                                    <asp:Parameter Name="par" Type="String" />
                                    <asp:Parameter Name="comments" Type="String" />
                                    <asp:Parameter Name="access_date" Type="DateTime" />
                                </InsertParameters>
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="txt_startDate" Name="startdate" PropertyName="Value" Type="DateTime" />
                                    <asp:ControlParameter ControlID="txt_endDate" Name="enddate" PropertyName="Value" Type="DateTime" />
                                </SelectParameters>
                                <UpdateParameters>
                                    <asp:Parameter Name="user_id" Type="String" />
                                    <asp:Parameter Name="page_function" Type="String" />
                                    <asp:Parameter Name="par" Type="String" />
                                    <asp:Parameter Name="comments" Type="String" />
                                    <asp:Parameter Name="access_date" Type="DateTime" />
                                    <asp:Parameter Name="Original_logid" Type="UInt32" />
                                </UpdateParameters>
                            </asp:ObjectDataSource>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
</asp:Content>