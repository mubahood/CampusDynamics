<%@ Control Language="C#" AutoEventWireup="true" CodeFile="lg.ascx.cs" Inherits="COOPERP_fonts_lg" %>
<style type="text/css">

        .style1
        {
            width: 500px;
            height: 400px;
        }
        .style5
        {
    }
    .auto-style1 {
        width: 100%;
    }
    </style>
    
                <link href="../css/loginstyle.css" rel="stylesheet" type="text/css" />
    
                <table class="auto-style1">
                    <tr>
                        <td>
    
                <dx:ASPxPopupControl runat="server" CloseAction="None" HeaderText="System Licence Lock" Width="400px" ID="pop_lock" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" ShowHeader="False" Modal="True">
                    <ModalBackgroundStyle BackColor="#3399FF">
                    </ModalBackgroundStyle>
                    <ContentCollection>
<dx:PopupControlContentControl runat="server">
                        <dx:ASPxRoundPanel ID="loginPop" runat="server" HeaderText="" ShowHeader="False" Width="100%">
                            <ContentPaddings Padding="14px" />
                            <PanelCollection>
                                <dx:PanelContent runat="server">
                                    <asp:Login ID="Login1" runat="server" DestinationPageUrl="~/MyApplications.aspx" OnLoggedIn="Login1_LoggedIn" OnLoggingIn="Login1_LoggingIn1" style="text-align: center" Width="361px">
                                        <LayoutTemplate>
                                            <table cellpadding="1" cellspacing="0" style="border-collapse: collapse;">
                                                <tr>
                                                    <td>
                                                        <table align="center" cellpadding="0" style="width: 350px;">
                                                            <tr>
                                                                <td align="center" colspan="2">
                                                                    &nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="style5" style="text-align: right" colspan="2">
                                                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/welcomelogo.png" ShowLoadingImage="true">
                                                                    </dx:ASPxImage>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="style5" style="text-align: right">&nbsp;</td>
                                                                <td style="text-align: center">&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="style5" style="text-align: right">&nbsp;</td>
                                                                <td style="text-align: center">
                                                                    <dx:ASPxTextBox ID="UserName" runat="server" HorizontalAlign="Center" Width="170px" NullText="User Name" Height="35px">
                                                                    </dx:ASPxTextBox>
                                                                    <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName" ErrorMessage="User Name is required." ToolTip="User Name is required." ValidationGroup="Login1">*</asp:RequiredFieldValidator>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="style5" style="text-align: right">&nbsp;</td>
                                                                <td style="text-align: center">
                                                                    <dx:ASPxTextBox ID="Password" runat="server" HorizontalAlign="Center" NullText="Password:" Password="True" Width="170px" Height="35px">
                                                                    </dx:ASPxTextBox>
                                                                    <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="Password" ErrorMessage="Password is required." ToolTip="Password is required." ValidationGroup="Login1">*</asp:RequiredFieldValidator>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="style5" style="text-align: left">&nbsp;</td>
                                                                <td style="text-align: left">
                                                                    <dx:ASPxButton ID="LoginButton" runat="server" CommandName="Login" Text="Login" ValidationGroup="login1" Width="170px" Height="35px">
                                                                        <Image Url="~/COOPERP/images/tick-shield.png">
                                                                        </Image>
                                                                    </dx:ASPxButton>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="style5" style="text-align: left">&nbsp;</td>
                                                                <td style="text-align: left">&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="style5" style="text-align: left">&nbsp;</td>
                                                                <td style="text-align: center">
                                                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="80px" ImageUrl="~/COOPERP/images/campus_dynamix_logo.png" ShowLoadingImage="true" Width="155px">
                                                                    </dx:ASPxImage>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="center" style="color: Red;">
                                                                    &nbsp;</td>
                                                                <td align="center" style="color:Red;">
                                                                    <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </LayoutTemplate>
                                    </asp:Login>
                                </dx:PanelContent>
                            </PanelCollection>
                        </dx:ASPxRoundPanel>
                        </dx:PopupControlContentControl>
</ContentCollection>
</dx:ASPxPopupControl>

                
    
    
                        </td>
                    </tr>
                    <tr>
                        <td>
    
                            &nbsp;</td>
                    </tr>
</table>


                
    
    
