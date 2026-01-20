<%@ Page Title="Hotel Dynamics: Night Audit" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="NightAudit.aspx.cs" Inherits="COOPERP_accounts_NightAudit" %>

<%@ Register src="../../UserControls/Accounts/AuditTodayBookings.ascx" tagname="AuditTodayBookings" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Night Audit" 
                Width="100%">
                <HeaderImage Url="~/COOPERP/images/alarm-clock.png">
                </HeaderImage>
                <PanelCollection>
                    <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                        <table class="style1">
                            <tr>
                                <td>
                                    <table cellpadding="0" cellspacing="0" class="style1">
                                        <tr>
                                            <td>
                                                <asp:ImageButton ID="ImageButton1" runat="server" 
                                                    ImageUrl="~/COOPERP/images/header_nightaudit.png" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ImageButton ID="ImageButton2" runat="server" Height="1px" 
                                                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%" />
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
                                            <td style="width: 228px" valign="top">
                                                <dx:ASPxRadioButtonList ID="rbl_nightaudit" runat="server" AutoPostBack="True" 
                                                    OnValueChanged="rbl_nightaudit_ValueChanged" ReadOnly="True" SelectedIndex="0" 
                                                    Width="100%" OnSelectedIndexChanged="rbl_nightaudit_ValueChanged">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="Start Audit" Value="0" />
                                                        <dx:ListEditItem Text="Bookings" Value="1" />
                                                        <dx:ListEditItem Text="Due Out Rooms" Value="2" />
                                                        <dx:ListEditItem Text="Billings" Value="3" />
                                                        <dx:ListEditItem Text="Payments" Value="4" />
                                                        <dx:ListEditItem Text="Complete Audit" Value="5" />
                                                    </Items>
                                                </dx:ASPxRadioButtonList>
                                            </td>
                                            <td valign="top">
                                                <table class="style1">
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxRoundPanel ID="rp_controls" runat="server" HeaderText="Bookings" 
                                                                Width="100%">
                                                                <PanelCollection>
                                                                    <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                                                                    </dx:PanelContent>
                                                                </PanelCollection>
                                                            </dx:ASPxRoundPanel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <table cellpadding="0" cellspacing="1" class="style1">
                                                                <tr>
                                                                    <td class="sidebar_item" style="width: 167px">
                                                                        <dx:ASPxButton ID="cmdPrevious" runat="server" OnClick="cmdPrevious_Click" 
                                                                            Text="Start Audit" Width="170px">
                                                                            <Image Url="~/COOPERP/images/tick-button.png">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td>
                                                                        <dx:ASPxButton ID="cmdNext" runat="server" OnClick="cmdNext_Click" 
                                                                            Text="Finish Audit" Width="170px">
                                                                            <Image Url="~/COOPERP/images/tick-button.png">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </dx:PanelContent>
                </PanelCollection>
            </dx:ASPxRoundPanel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

