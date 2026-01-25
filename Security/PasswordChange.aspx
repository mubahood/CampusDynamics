<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PasswordChange.aspx.cs" Inherits="Security_PasswordChange" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Password Change" ShowCollapseButton="true" Width="100%">
            <PanelCollection>
<dx:PanelContent runat="server">
    <asp:ChangePassword ID="ChangePassword1" runat="server" Width="500px">
        <ChangePasswordTemplate>
            <table cellpadding="1" cellspacing="0" style="border-collapse:collapse;">
                <tr>
                    <td>
                        <table cellpadding="0" style="width:500px;">
                            <tr>
                                <td align="center" colspan="3">
                                    <br />
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="CurrentPasswordLabel" runat="server" 
                                        AssociatedControlID="CurrentPassword">Password:</asp:Label>
                                </td>
                                <td>
                                    <dx:ASPxTextBox ID="CurrentPassword" runat="server" Width="170px">
                                    </dx:ASPxTextBox>
                                </td>
                                <td>
                                    <asp:RequiredFieldValidator ID="CurrentPasswordRequired" runat="server" 
                                        ControlToValidate="CurrentPassword" ErrorMessage="Password is required." 
                                        ToolTip="Password is required." ValidationGroup="ChangePassword1">*</asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="NewPasswordLabel" runat="server" 
                                        AssociatedControlID="NewPassword">New Password:</asp:Label>
                                </td>
                                <td>
                                    <dx:ASPxTextBox ID="NewPassword" runat="server" Width="170px">
                                    </dx:ASPxTextBox>
                                </td>
                                <td>
                                    <asp:RequiredFieldValidator ID="NewPasswordRequired" runat="server" 
                                        ControlToValidate="NewPassword" ErrorMessage="New Password is required." 
                                        ToolTip="New Password is required." ValidationGroup="ChangePassword1">*</asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="ConfirmNewPasswordLabel" runat="server" 
                                        AssociatedControlID="ConfirmNewPassword">Confirm New Password:</asp:Label>
                                </td>
                                <td>
                                    <dx:ASPxTextBox ID="ConfirmNewPassword" runat="server" Width="170px">
                                    </dx:ASPxTextBox>
                                </td>
                                <td>
                                    <asp:RequiredFieldValidator ID="ConfirmNewPasswordRequired" runat="server" 
                                        ControlToValidate="ConfirmNewPassword" 
                                        ErrorMessage="Confirm New Password is required." 
                                        ToolTip="Confirm New Password is required." ValidationGroup="ChangePassword1">*</asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" colspan="2">
                                    <asp:CompareValidator ID="NewPasswordCompare" runat="server" 
                                        ControlToCompare="NewPassword" ControlToValidate="ConfirmNewPassword" 
                                        Display="Dynamic" 
                                        ErrorMessage="The Confirm New Password must match the New Password entry." 
                                        ValidationGroup="ChangePassword1"></asp:CompareValidator>
                                </td>
                                <td align="center">
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td align="center" colspan="2" style="color:Red;">
                                    <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                                </td>
                                <td align="center" style="color:Red;">
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td align="right">
                                    &nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="ChangePasswordPushButton" runat="server" 
                                        Text="Change Password" Width="170px">
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td align="right">
                                    &nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="CancelPushButton" runat="server" Text="Cancel" Width="170px">
                                        <Image Url="~/COOPERP/images/minus-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ChangePasswordTemplate>
    </asp:ChangePassword>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
