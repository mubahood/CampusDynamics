<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ResearchEvents.ascx.cs" Inherits="UserControls_Graduate_ResearchEvents" %>
<style type="text/css">
    .auto-style1 {
        height: 34px;
    }
    .auto-style2 {
        width: 1129px;
        height: 32px;
    }
    .auto-style3 {
        height: 32px;
    }
    .auto-style4 {
        height: 18px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td class="auto-style1" colspan="2">
                <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/header_research_event.png"  ShowLoadingImage="True">
                </dx:ASPxImage>
                <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  ShowLoadingImage="True" Width="100%">
                </dx:ASPxImage>
            </td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td class="auto-style2">
                <dx:ASPxButton ID="addNewResEvent" runat="server" Text="Add New" Width="170px" OnClick="addNewResEvent_Click">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
            <td class="auto-style3">
                <dx:ASPxButton ID="ASPxButton1" runat="server" style="text-align: right" Text="Print Results" Width="170px">
                    <Image Url="~/COOPERP/images/printer.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <dx:ASPxGridView ID="res_eventGV" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="ObjectDataSource1" KeyFieldName="Id">
                    <SettingsBehavior AllowFocusedRow="True" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="11">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Event Name" FieldName="event_name" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Event Type" FieldName="event_type" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Start Date" FieldName="start_date" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataDateColumn Caption="End Date" FieldName="end_date" ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="No Days" FieldName="no_days" ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Campus" FieldName="campus" ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Venue" FieldName="venue" ShowInCustomizationForm="True" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="regno" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" VisibleIndex="10">
                            <DataItemTemplate>
                                <asp:ImageButton ID="btnEventDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="btnEventDetails_Click" />
                            </DataItemTemplate>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn Caption="#" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="5px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_research_eventsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="event_name" Type="String" />
                        <asp:Parameter Name="event_type" Type="String" />
                        <asp:Parameter Name="start_date" Type="DateTime" />
                        <asp:Parameter Name="end_date" Type="DateTime" />
                        <asp:Parameter Name="no_days" Type="UInt32" />
                        <asp:Parameter Name="campus" Type="String" />
                        <asp:Parameter Name="venue" Type="String" />
                        <asp:Parameter Name="regno" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="event_name" Type="String" />
                        <asp:Parameter Name="event_type" Type="String" />
                        <asp:Parameter Name="start_date" Type="DateTime" />
                        <asp:Parameter Name="end_date" Type="DateTime" />
                        <asp:Parameter Name="no_days" Type="UInt32" />
                        <asp:Parameter Name="campus" Type="String" />
                        <asp:Parameter Name="venue" Type="String" />
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxPopupControl ID="EventsDetails" runat="server" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="2" class="auto-style4"></td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

