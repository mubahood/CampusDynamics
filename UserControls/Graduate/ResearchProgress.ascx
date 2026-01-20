<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ResearchProgress.ascx.cs" Inherits="UserControls_Graduate_ResearchProgress" %>
<style type="text/css">
    .auto-style1 {
        height: 27px;
    }
    .auto-style2 {
        height: 27px;
        text-align: right;
    }
    .auto-style3 {
        height: 27px;
        width: 1098px;
    }
    .auto-style4 {
        height: 35px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td colspan="2" class="auto-style4">
                <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/header_research_prog.png"  ShowLoadingImage="True">
                </dx:ASPxImage>
                <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  ShowLoadingImage="True" Width="100%">
                </dx:ASPxImage>
            </td>
        </tr>
        <tr>
            <td class="auto-style1" colspan="2">
                &nbsp;</td>
        </tr>
        <tr>
            <td class="auto-style3">
                <dx:ASPxButton ID="ASPxButton1" runat="server" OnClick="ASPxButton1_Click" Text="Add New" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
            <td class="auto-style2">
                <dx:ASPxButton ID="ASPxButton2" runat="server" OnClick="ASPxButton2_Click" style="margin-left: 0px" Text="Tracking &amp; Results Approval" Width="250px">
                    <Image Url="~/COOPERP/images/clipboard-task.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <dx:ASPxGridView ID="res_progessGV" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="grad_researchODS" KeyFieldName="id">
                    <SettingsBehavior AllowFocusedRow="True" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="8" Width="10px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn FieldName="id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Caption="SNo">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="res_topic" ShowInCustomizationForm="True" VisibleIndex="4" Caption="Research Topic">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="marks" ShowInCustomizationForm="True" VisibleIndex="7" Caption="Marks">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="studentname" ShowInCustomizationForm="True" VisibleIndex="3" ReadOnly="True" Caption="Student Name">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn FieldName="supervior_id" ShowInCustomizationForm="True" VisibleIndex="6" Caption="Supervisor Name">
                            <PropertiesComboBox DataSourceID="supervior" TextField="supervior_name" TextFormatString="{1}" ValueField="Id">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="Id" />
                                    <dx:ListBoxColumn FieldName="supervior_name" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn FieldName="res_status" ShowInCustomizationForm="True" VisibleIndex="5" Caption="Status">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="DONE VIVA" Value="DONE VIVA" />
                                    <dx:ListEditItem Text="PENDING" Value="PENDING" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewCommandColumn Caption="#" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="5px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Registration No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="2">
                            <PropertiesComboBox DataSourceID="RegNoName" TextField="regno" TextFormatString="{0}" ValueField="regno">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="regno" />
                                    <dx:ListBoxColumn FieldName="firstname" />
                                    <dx:ListBoxColumn FieldName="othername" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:ObjectDataSource ID="grad_researchODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetResearch" TypeName="GraduateDataTableAdapters.acad_graduate_researchTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_id" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="res_topic" Type="String" />
                        <asp:Parameter Name="res_status" Type="String" />
                        <asp:Parameter Name="marks" Type="String" />
                        <asp:Parameter Name="supervior_id" Type="UInt32" />
                        <asp:Parameter Name="regno" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="res_topic" Type="String" />
                        <asp:Parameter Name="res_status" Type="String" />
                        <asp:Parameter Name="marks" Type="String" />
                        <asp:Parameter Name="supervior_id" Type="UInt32" />
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="Original_id" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="supervior" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_superviorsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="supervior_name" Type="String" />
                        <asp:Parameter Name="contact" Type="String" />
                        <asp:Parameter Name="status" Type="String" />
                        <asp:Parameter Name="category" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="supervior_name" Type="String" />
                        <asp:Parameter Name="contact" Type="String" />
                        <asp:Parameter Name="status" Type="String" />
                        <asp:Parameter Name="category" Type="String" />
                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="RegNoName" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_GraduateListTableAdapter"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="Students" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_NamebyregNoTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="reg" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="reg" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:QueryStringParameter Name="reg" QueryStringField="regno" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="reg" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxPopupControl ID="ResProgressPopup" runat="server" HeaderText="Research Progress" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
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
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

