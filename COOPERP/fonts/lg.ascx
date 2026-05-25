<%@ Control Language="C#" AutoEventWireup="true" CodeFile="lg.ascx.cs" Inherits="COOPERP_fonts_lg" %>
<style type="text/css">
    .style5  { }
    .auto-style1 { width: 100%; }

    /* Forgot-password panel */
    .lgf-box   { padding: 10px 14px; }
    .lgf-title { font-size: 13px; font-weight: 600; color: #05275C; text-align: center; margin-bottom: 10px; }
    .lgf-hint  { font-size: 11px; color: #555; text-align: center; line-height: 1.6; margin-bottom: 12px; }
    .lgf-row   { text-align: center; margin-bottom: 8px; }
    .lgf-input { width: 220px; height: 32px; font-size: 12px; border: 1px solid #c8cfe0;
                 padding: 0 8px; box-sizing: border-box; border-radius: 0; }
    .lgf-btn   { background: #174DA4; color: #fff; border: none; height: 32px; padding: 0 20px;
                 cursor: pointer; font-size: 12px; }
    .lgf-btn:hover { background: #05275C; }
    .lgf-link  { font-size: 11px; color: #174DA4; text-decoration: none; }
    .lgf-link:hover { text-decoration: underline; }
</style>

<link href="../css/loginstyle.css" rel="stylesheet" type="text/css" />

<table class="auto-style1">
    <tr>
        <td>
            <dx:ASPxPopupControl runat="server" CloseAction="None" HeaderText="System Login"
                Width="400px" ID="pop_lock"
                PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
                ShowHeader="False" Modal="True">
                <ModalBackgroundStyle BackColor="#3399FF">
                </ModalBackgroundStyle>
                <ContentCollection>
                    <dx:PopupControlContentControl runat="server">
                        <dx:ASPxRoundPanel ID="loginPop" runat="server" HeaderText="" ShowHeader="False" Width="100%">
                            <ContentPaddings Padding="14px" />
                            <PanelCollection>
                                <dx:PanelContent runat="server">

                                    <%-- ══════════════════════ LOGIN PANEL ══════════════════════ --%>
                                    <asp:Panel ID="pnlLogin" runat="server">
                                        <asp:Login ID="Login1" runat="server"
                                            DestinationPageUrl="~/MyApplications.aspx"
                                            OnLoggedIn="Login1_LoggedIn"
                                            OnLoggingIn="Login1_LoggingIn1"
                                            style="text-align: center" Width="361px">
                                            <LayoutTemplate>
                                                <table cellpadding="1" cellspacing="0" style="border-collapse: collapse;">
                                                    <tr>
                                                        <td>
                                                            <table align="center" cellpadding="0" style="width: 350px;">
                                                                <tr>
                                                                    <td align="center" colspan="2">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="right" class="style5" style="text-align: right" colspan="2">
                                                                        <dx:ASPxImage ID="ASPxImage1" runat="server"
                                                                            ImageUrl="~/COOPERP/images/welcomelogo.png"
                                                                            ShowLoadingImage="true">
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
                                                                        <dx:ASPxTextBox ID="UserName" runat="server"
                                                                            HorizontalAlign="Center"
                                                                            Width="170px" NullText="User Name" Height="35px">
                                                                        </dx:ASPxTextBox>
                                                                        <asp:RequiredFieldValidator ID="UserNameRequired" runat="server"
                                                                            ControlToValidate="UserName"
                                                                            ErrorMessage="User Name is required."
                                                                            ToolTip="User Name is required."
                                                                            ValidationGroup="Login1">*</asp:RequiredFieldValidator>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="right" class="style5" style="text-align: right">&nbsp;</td>
                                                                    <td style="text-align: center">
                                                                        <dx:ASPxTextBox ID="Password" runat="server"
                                                                            HorizontalAlign="Center"
                                                                            NullText="Password:" Password="True"
                                                                            Width="170px" Height="35px">
                                                                        </dx:ASPxTextBox>
                                                                        <asp:RequiredFieldValidator ID="PasswordRequired" runat="server"
                                                                            ControlToValidate="Password"
                                                                            ErrorMessage="Password is required."
                                                                            ToolTip="Password is required."
                                                                            ValidationGroup="Login1">*</asp:RequiredFieldValidator>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="right" class="style5" style="text-align: left">&nbsp;</td>
                                                                    <td style="text-align: left">
                                                                        <dx:ASPxButton ID="LoginButton" runat="server"
                                                                            CommandName="Login" Text="Login"
                                                                            ValidationGroup="login1"
                                                                            Width="170px" Height="35px">
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
                                                                        <dx:ASPxImage ID="ASPxImage2" runat="server"
                                                                            Height="80px"
                                                                            ImageUrl="~/COOPERP/images/campus_dynamix_logo.png"
                                                                            ShowLoadingImage="true" Width="155px">
                                                                        </dx:ASPxImage>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="color: Red;">&nbsp;</td>
                                                                    <td align="center" style="color: Red; font-size: 12px; line-height: 1.5;">
                                                                        <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2" style="text-align: center; padding-top: 8px; padding-bottom: 4px;">
                                                                        <a href="#" onclick="cdlShowForgot(); return false;" class="lgf-link">
                                                                            Forgot Password?
                                                                        </a>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </LayoutTemplate>
                                        </asp:Login>
                                    </asp:Panel>

                                    <%-- ══════════════════ FORGOT PASSWORD PANEL ══════════════════ --%>
                                    <asp:Panel ID="pnlForgot" runat="server" CssClass="lgf-box">
                                        <div class="lgf-title">Reset Password</div>
                                        <p class="lgf-hint">
                                            Enter your email address, username, or staff number.<br />
                                            A 4-digit PIN will be sent to your registered email.
                                        </p>
                                        <div class="lgf-row">
                                            <dx:ASPxTextBox ID="txtForgotInput" runat="server"
                                                Width="220px" Height="32px"
                                                NullText="Email / Username / Staff No">
                                            </dx:ASPxTextBox>
                                        </div>
                                        <div class="lgf-row">
                                            <dx:ASPxButton ID="cmdForgot" runat="server"
                                                Text="Send Reset PIN"
                                                AutoPostBack="true"
                                                CausesValidation="false"
                                                OnClick="cmdForgot_Click"
                                                Width="170px" Height="32px">
                                            </dx:ASPxButton>
                                        </div>
                                        <div class="lgf-row" style="min-height: 20px; line-height: 1.6;">
                                            <asp:Literal ID="lbl_msg" runat="server" />
                                        </div>
                                        <div class="lgf-row" style="margin-top: 6px;">
                                            <a href="#" onclick="cdlShowLogin(); return false;" class="lgf-link">
                                                &larr;&nbsp;Back to Login
                                            </a>
                                        </div>
                                    </asp:Panel>

                                </dx:PanelContent>
                            </PanelCollection>
                        </dx:ASPxRoundPanel>
                    </dx:PopupControlContentControl>
                </ContentCollection>
            </dx:ASPxPopupControl>
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>

<script type="text/javascript">
    var _lgLogin = null, _lgForgot = null;

    function _lgGetPanels() {
        if (!_lgLogin)  _lgLogin  = document.getElementById('<%= pnlLogin.ClientID  %>');
        if (!_lgForgot) _lgForgot = document.getElementById('<%= pnlForgot.ClientID %>');
    }
    function cdlShowForgot() {
        _lgGetPanels();
        if (_lgLogin)  _lgLogin.style.display  = 'none';
        if (_lgForgot) _lgForgot.style.display = '';
    }
    function cdlShowLogin() {
        _lgGetPanels();
        if (_lgForgot) _lgForgot.style.display = 'none';
        if (_lgLogin)  _lgLogin.style.display  = '';
    }
</script>
