<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PasswordChanger.ascx.cs" Inherits="UserControls_PasswordChanger" %>
<style type="text/css">

        .style1
        {
            width: 100%;
        }
        .style12
        {
            width: 191px;
        }
        .style10
        {
            width: 323px;
        }
        .style9
        {
            width: 291px;
            text-align: left;
        }
        </style>
                    <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
                        HeaderText="My Password Change" style="text-align: center" 
                        Width="100%">
                        <HeaderImage Url="~/COOPERP/images/clipboard--pencil.png">
                        </HeaderImage>
                        <HeaderStyle HorizontalAlign="Left" />
                        <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td style="text-align: left; font-weight: 700">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td style="text-align: left; font-weight: 700">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:ChangePassword ID="ChangePassword1" runat="server" Width="600px">
                                <ChangePasswordTemplate>
                                    <table cellpadding="1" cellspacing="0" style="border-collapse:collapse;">
                                        <tr>
                                            <td>
                                                <table cellpadding="0">
                                                    <tr>
                                                        <td align="right" class="style10" style="text-align: left">
                                                            <asp:Label ID="CurrentPasswordLabel" runat="server" 
                                                                AssociatedControlID="CurrentPassword">Password:</asp:Label>
                                                        </td>
                                                        <td class="style9">
                                                            <dx:ASPxTextBox ID="CurrentPassword" runat="server" Password="True" 
                                                                Width="200px">
                                                            </dx:ASPxTextBox>
                                                        </td>
                                                        <td class="style9">
                                                            <asp:RequiredFieldValidator ID="CurrentPasswordRequired" runat="server" 
                                                                ControlToValidate="CurrentPassword" ErrorMessage="Password is required." 
                                                                ToolTip="Password is required." ValidationGroup="ChangePassword1">*</asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="right" class="style10" style="text-align: left">
                                                            <asp:Label ID="NewPasswordLabel" runat="server" 
                                                                AssociatedControlID="NewPassword">New Password:</asp:Label>
                                                        </td>
                                                        <td class="style9">
                                                            <dx:ASPxTextBox ID="NewPassword" runat="server" Password="True" Width="200px">
                                                            </dx:ASPxTextBox>
                                                        </td>
                                                        <td class="style9">
                                                            <asp:RequiredFieldValidator ID="NewPasswordRequired" runat="server" 
                                                                ControlToValidate="NewPassword" ErrorMessage="New Password is required." 
                                                                ToolTip="New Password is required." ValidationGroup="ChangePassword1">*</asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="right" class="style10" style="text-align: left">
                                                            <asp:Label ID="ConfirmNewPasswordLabel" runat="server" 
                                                                AssociatedControlID="ConfirmNewPassword">Confirm New Password:</asp:Label>
                                                        </td>
                                                        <td class="style9">
                                                            <dx:ASPxTextBox ID="ConfirmNewPassword" runat="server" Password="True" 
                                                                Width="200px">
                                                            </dx:ASPxTextBox>
                                                        </td>
                                                        <td class="style9">
                                                            <asp:RequiredFieldValidator ID="ConfirmNewPasswordRequired" runat="server" 
                                                                ControlToValidate="ConfirmNewPassword" 
                                                                ErrorMessage="Confirm New Password is required." 
                                                                ToolTip="Confirm New Password is required." ValidationGroup="ChangePassword1">*</asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="right" class="style10" style="text-align: left">
                                                            &nbsp;</td>
                                                        <td class="style9">
                                                            <dx:ASPxButton ID="cmdChangePass" runat="server" CommandName="ChangePassword" 
                                                                Text="Change Password" ValidationGroup="ChangePassword1" Width="200px">
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td class="style9">
                                                            &nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td align="right" class="style10" style="text-align: left">
                                                            &nbsp;</td>
                                                        <td class="style9">
                                                            <dx:ASPxButton ID="cmdCancel" runat="server" CausesValidation="False" 
                                                                CommandName="Cancel" Text="Cancel" Width="200px">
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td class="style9">
                                                            &nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" colspan="3">
                                                            <asp:CompareValidator ID="NewPasswordCompare" runat="server" 
                                                                ControlToCompare="NewPassword" ControlToValidate="ConfirmNewPassword" 
                                                                Display="Dynamic" 
                                                                ErrorMessage="The Confirm New Password must match the New Password entry." 
                                                                ValidationGroup="ChangePassword1"></asp:CompareValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" colspan="3" style="color:Red;">
                                                            <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </ChangePasswordTemplate>
                            </asp:ChangePassword>
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
                                    <td class="style12">
                                        &nbsp;</td>
                                    <td>
                                        &nbsp;</td>
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
                
