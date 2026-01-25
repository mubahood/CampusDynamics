<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SystemApplications.ascx.cs" Inherits="UserControls_Security_SystemApplications" %>
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
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td colspan="2">
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_controlpanel.png">
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
        
        <!-- FLOATING NEW DASHBOARD BUTTON -->
        <style>
            @keyframes floatPulse2 {
                0%, 100% { transform: translateY(0); }
                50% { transform: translateY(-5px); }
            }
            @keyframes badgePop2 {
                0%, 100% { transform: scale(1); }
                50% { transform: scale(1.1); }
            }
            .float-new-dash2 {
                position: fixed;
                bottom: 30px;
                right: 30px;
                z-index: 9999;
                display: flex;
                align-items: center;
                gap: 8px;
                background: #174DA4;
                color: #fff !important;
                padding: 14px 22px;
                border-radius: 50px;
                text-decoration: none;
                font-weight: 600;
                font-size: 14px;
                box-shadow: 0 4px 20px rgba(23, 77, 164, 0.5);
                animation: floatPulse2 2s ease-in-out infinite;
                transition: all 0.3s ease;
            }
            .float-new-dash2 span,
            .float-new-dash2 svg {
                color: #fff !important;
                fill: none;
                stroke: #fff !important;
            }
            .float-new-dash2:hover {
                background: #0f3a7d;
                color: #fff !important;
                transform: scale(1.08) translateY(-3px);
                box-shadow: 0 8px 30px rgba(23, 77, 164, 0.6);
            }
            .float-new-dash2 .new-dot2 {
                position: absolute;
                top: -5px;
                right: -5px;
                background: #ff4757;
                color: #fff;
                font-size: 9px;
                font-weight: 700;
                padding: 4px 8px;
                border-radius: 10px;
                animation: badgePop2 1.5s ease-in-out infinite;
            }
        </style>
        <a href="COOPERP/NewScreens/NewDashboard.aspx" target="_blank" class="float-new-dash2">
            <span class="new-dot2">NEW</span>
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
            <span>New Dashboard</span>
        </a>
        <!-- END FLOATING BUTTON -->
        
        <tr>
            <td colspan="2">
                &nbsp;</td>
        </tr>
        <tr>
            <td colspan="2">
                <table class="style1">
                    <tr>
                        <td class="style5">
                            <dx:ASPxTextBox ID="txtSearch" runat="server" Height="30px" 
                                NullText="Enter function name" Width="100%">
                                <Paddings PaddingLeft="10px" />
                            </dx:ASPxTextBox>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdSearch" runat="server" Height="30px" 
                                OnClick="cmdSearch_Click" Text="Search" Width="100%">
                                <Image Url="~/COOPERP/images/magnifier.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <dx:ASPxGridView ID="gvApplications" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsMyApps" KeyFieldName="app_ID" Width="100%" OnDataBound="gvApplications_DataBound">
                    <Columns>
                        <dx:GridViewDataImageColumn FieldName="app_icon" ShowInCustomizationForm="True" 
                            VisibleIndex="1" Width="60px">
                            <PropertiesImage ImageAlign="Left" ImageUrlFormatString="~/COOPERP/images/{0}">
                            </PropertiesImage>
                        </dx:GridViewDataImageColumn>
                        <dx:GridViewDataHyperLinkColumn FieldName="app_home" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="200px">
                            <PropertiesHyperLinkEdit TextField="app_name">
                            </PropertiesHyperLinkEdit>
                        </dx:GridViewDataHyperLinkColumn>
                        <dx:GridViewDataHyperLinkColumn FieldName="app_home" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                            <PropertiesHyperLinkEdit TextField="app_description">
                            </PropertiesHyperLinkEdit>
                        </dx:GridViewDataHyperLinkColumn>
                    </Columns>
                    <SettingsPager Mode="ShowAllRecords">
                    </SettingsPager>
                    <Settings GridLines="Horizontal" ShowColumnHeaders="False" />
                    <Paddings PaddingBottom="0px" PaddingLeft="0px" PaddingRight="0px" 
                        PaddingTop="0px" Padding="100px" />
                    <Styles>
                        <Row Font-Bold="False">
                        </Row>
                    </Styles>
                    <Templates>
                        <DataRow>
                            <table class="style1">
                                <tr>
                                    <td class="style4">
                                        &nbsp;</td>
                                    <td class="style2_apps">
                                        &nbsp;</td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="style4">
                                        &nbsp;</td>
                                    <td class="style2_apps">
                                        <asp:ImageButton ID="ImageButton1" runat="server" 
                                            ImageUrl='<%# Eval("app_icon", "~/COOPERP/images/{0}") %>' 
                                            PostBackUrl='<%# Eval("app_home", "{0}") %>' />
                                    </td>
                                    <td>
                                        <table class="style1">
                                            <tr>
                                                <td>
                                                    <dx:ASPxHyperLink ID="ASPxHyperLink1" runat="server" Font-Size="Medium" 
                                                        NavigateUrl='<%# Eval("app_home", "{0}") %>' Text='<%# Eval("app_name") %>' />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxLabel ID="ASPxLabel1" runat="server" 
                                                        Text='<%# Eval("app_description") %>'>
                                                    </dx:ASPxLabel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style4">
                                        &nbsp;</td>
                                    <td class="style2_apps">
                                        &nbsp;</td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <dx:ASPxImage ID="ASPxImage3" runat="server" Height="1px" 
                                            ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                                        </dx:ASPxImage>
                                    </td>
                                </tr>
                            </table>
                        </DataRow>
                    </Templates>
                </dx:ASPxGridView>
            </td>
            <td valign="top">
                <dx:ASPxGridView ID="gvApplicationsRight" runat="server" AutoGenerateColumns="False" DataSourceID="dsRightApps" KeyFieldName="app_ID" Width="100%" OnDataBound="gvApplicationsRight_DataBound">
                    <Columns>
                        <dx:GridViewDataImageColumn FieldName="app_icon" ShowInCustomizationForm="True" VisibleIndex="1" Width="60px">
                            <PropertiesImage ImageAlign="Left" ImageUrlFormatString="~/COOPERP/images/{0}">
                            </PropertiesImage>
                        </dx:GridViewDataImageColumn>
                        <dx:GridViewDataHyperLinkColumn FieldName="app_home" ShowInCustomizationForm="True" VisibleIndex="2" Width="200px">
                            <PropertiesHyperLinkEdit TextField="app_name">
                            </PropertiesHyperLinkEdit>
                        </dx:GridViewDataHyperLinkColumn>
                        <dx:GridViewDataHyperLinkColumn FieldName="app_home" ShowInCustomizationForm="True" VisibleIndex="3">
                            <PropertiesHyperLinkEdit TextField="app_description">
                            </PropertiesHyperLinkEdit>
                        </dx:GridViewDataHyperLinkColumn>
                    </Columns>
                    <SettingsPager Mode="ShowAllRecords">
                    </SettingsPager>
                    <Settings GridLines="Horizontal" ShowColumnHeaders="False" />
                    <Paddings Padding="100px" PaddingBottom="0px" PaddingLeft="0px" PaddingRight="0px" PaddingTop="0px" />
                    <Styles>
                        <Row Font-Bold="False">
                        </Row>
                    </Styles>
                    <Templates>
                        <DataRow>
                            <table class="style1">
                                <tr>
                                    <td class="style4">&nbsp;</td>
                                    <td class="style2_apps">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="style4">&nbsp;</td>
                                    <td class="style2_apps">
                                        <asp:ImageButton ID="ImageButton2" runat="server" ImageUrl='<%# Eval("app_icon", "~/COOPERP/images/{0}") %>' PostBackUrl='<%# Eval("app_home", "{0}") %>' />
                                    </td>
                                    <td>
                                        <table class="style1">
                                            <tr>
                                                <td>
                                                    <dx:ASPxHyperLink ID="ASPxHyperLink2" runat="server" Font-Size="Medium" NavigateUrl='<%# Eval("app_home", "{0}") %>' Text='<%# Eval("app_name") %>' />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text='<%# Eval("app_description") %>'>
                                                    </dx:ASPxLabel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style4">&nbsp;</td>
                                    <td class="style2_apps">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <dx:ASPxImage ID="ASPxImage4" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                                        </dx:ASPxImage>
                                    </td>
                                </tr>
                            </table>
                        </DataRow>
                    </Templates>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                &nbsp;</td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:ObjectDataSource ID="dsMyApps" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetMyApps" 
                    TypeName="SecurityTableAdapters.my_aspnet_appsTableAdapter" 
                    DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_app_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="app_name" Type="String" />
                        <asp:Parameter Name="app_description" Type="String" />
                        <asp:Parameter Name="app_icon" Type="String" />
                        <asp:Parameter Name="app_home" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="" Name="username" SessionField="username" 
                            Type="String" />
                        <asp:ControlParameter ControlID="txtSearch" DefaultValue="a" Name="searchText" 
                            PropertyName="Text" Type="String" />
                        <asp:Parameter DefaultValue="1" Name="typ" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="app_name" Type="String" />
                        <asp:Parameter Name="app_description" Type="String" />
                        <asp:Parameter Name="app_icon" Type="String" />
                        <asp:Parameter Name="app_home" Type="String" />
                        <asp:Parameter Name="Original_app_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsRightApps" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetMyApps" TypeName="SecurityTableAdapters.my_aspnet_appsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_app_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="app_name" Type="String" />
                        <asp:Parameter Name="app_description" Type="String" />
                        <asp:Parameter Name="app_icon" Type="String" />
                        <asp:Parameter Name="app_home" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="" Name="username" SessionField="username" Type="String" />
                        <asp:ControlParameter ControlID="txtSearch" DefaultValue="a" Name="searchText" PropertyName="Text" Type="String" />
                        <asp:Parameter DefaultValue="0" Name="typ" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="app_name" Type="String" />
                        <asp:Parameter Name="app_description" Type="String" />
                        <asp:Parameter Name="app_icon" Type="String" />
                        <asp:Parameter Name="app_home" Type="String" />
                        <asp:Parameter Name="Original_app_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <dx:ASPxPopupControl ID="pop_otp" runat="server" CloseAction="None" HeaderText="One-Time-Code" Height="400px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" ShowCloseButton="False" Width="350px">
                    <HeaderStyle HorizontalAlign="Center">
                    <Paddings Padding="10px" />
                    </HeaderStyle>
                    <ModalBackgroundStyle BackColor="Black">
                    </ModalBackgroundStyle>
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td>
                                        <br />
                                        <br />
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxRadioButtonList ID="rb_channel" runat="server" RepeatDirection="Horizontal" SelectedIndex="1" Width="100%">
                                            <Items>
                                                <dx:ListEditItem Text="Text Message" Value="Text Message" />
                                                <dx:ListEditItem Text="Email Message" Value="Email Message" Selected="True" />
                                            </Items>
                                        </dx:ASPxRadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxButton ID="cmdRequest" runat="server" Height="35px" OnClick="cmdRequest_Click" Text="Request Code" Width="100%">
                                            <ClientSideEvents Click="function(s, e) {
	lp_sendingmsg.Show();
}" />
                                            <Image IconID="mail_mail_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxLoadingPanel ID="lp_sendingmsg" runat="server" ClientInstanceName="lp_sendingmsg" Modal="True" Text="Sending OTP Code....">
                                            <LoadingDivStyle BackColor="Black">
                                            </LoadingDivStyle>
                                        </dx:ASPxLoadingPanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxTextBox ID="txtCode" runat="server" Height="35px" HorizontalAlign="Center" NullText="Enter Code from SMS | Email" Width="100%">
                                        </dx:ASPxTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxButton ID="cmdVerify" runat="server" Height="35px" OnClick="cmdVerify_Click" Text="Verify Code" Width="100%">
                                            <Image IconID="content_checkbox_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align: center">
                                        <dx:ASPxLabel ID="lbl_comment" runat="server" Font-Bold="True" ForeColor="Blue" Text="Please Request and Verify Code to Proceed">
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
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

