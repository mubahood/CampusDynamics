<%@ Control Language="C#" AutoEventWireup="true" CodeFile="UserRegister.ascx.cs" Inherits="UserControls_Security_UserRegister" %>
<style type="text/css">
    .style2_usr
    {
        text-align: left;
        width: 193px;
    }
    .style3
    {
        width: 232px;
    }
    .style4
    {
        width: 100%;
    }
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


</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="User Registration" Width="100%">
    <HeaderImage Url="~/COOPERP/images/user--plus.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style4">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_userreg.png">
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
    </table>
    <asp:CreateUserWizard ID="CreateUserWizard1" runat="server" Width="100%" 
        FinishDestinationPageUrl="~/Security/UserManagement.aspx" 
        LoginCreatedUser="False">
        <WizardSteps>
            <asp:CreateUserWizardStep runat="server">
                <ContentTemplate>
                    <table style="font-size:100%;width:100%;">
                        <tr>
                            <td align="center" class="style3">
                                &nbsp;</td>
                            <td align="center" colspan="2">
                                &nbsp;</td>
                            <td align="center">
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserName">User Name:</asp:Label>
                            </td>
                            <td width="200">
                                <dx:ASPxTextBox ID="UserName" runat="server" Width="200px">
                                </dx:ASPxTextBox>
                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" 
                                    ControlToValidate="UserName" ErrorMessage="User Name is required." 
                                    ToolTip="User Name is required." ValidationGroup="CreateUserWizard1">*</asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="Password">Password:</asp:Label>
                            </td>
                            <td>
                                <dx:ASPxTextBox ID="Password" runat="server" Password="True" Width="200px">
                                </dx:ASPxTextBox>
                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" 
                                    ControlToValidate="Password" ErrorMessage="Password is required." 
                                    ToolTip="Password is required." ValidationGroup="CreateUserWizard1">*</asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                <asp:Label ID="ConfirmPasswordLabel" runat="server" 
                                    AssociatedControlID="ConfirmPassword">Confirm Password:</asp:Label>
                            </td>
                            <td>
                                <dx:ASPxTextBox ID="ConfirmPassword" runat="server" Password="True" 
                                    Width="200px">
                                </dx:ASPxTextBox>
                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="ConfirmPasswordRequired" runat="server" 
                                    ControlToValidate="ConfirmPassword" 
                                    ErrorMessage="Confirm Password is required." 
                                    ToolTip="Confirm Password is required." ValidationGroup="CreateUserWizard1">*</asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                <asp:Label ID="EmailLabel" runat="server" AssociatedControlID="Email">E-mail:</asp:Label>
                            </td>
                            <td>
                                <dx:ASPxTextBox ID="Email" runat="server" Width="200px">
                                </dx:ASPxTextBox>
                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="EmailRequired" runat="server" 
                                    ControlToValidate="Email" ErrorMessage="E-mail is required." 
                                    ToolTip="E-mail is required." ValidationGroup="CreateUserWizard1">*</asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                <asp:Label ID="QuestionLabel" runat="server" AssociatedControlID="Question">Security Question:</asp:Label>
                            </td>
                            <td>
                                <dx:ASPxTextBox ID="Question" runat="server" Width="200px">
                                </dx:ASPxTextBox>
                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="QuestionRequired" runat="server" 
                                    ControlToValidate="Question" ErrorMessage="Security question is required." 
                                    ToolTip="Security question is required." ValidationGroup="CreateUserWizard1">*</asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                <asp:Label ID="AnswerLabel" runat="server" AssociatedControlID="Answer">Security Answer:</asp:Label>
                            </td>
                            <td>
                                <dx:ASPxTextBox ID="Answer" runat="server" Width="200px">
                                </dx:ASPxTextBox>
                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="AnswerRequired" runat="server" 
                                    ControlToValidate="Answer" ErrorMessage="Security answer is required." 
                                    ToolTip="Security answer is required." ValidationGroup="CreateUserWizard1">*</asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                &nbsp;</td>
                            <td>
                                <asp:CompareValidator ID="PasswordCompare" runat="server" 
                                    ControlToCompare="Password" ControlToValidate="ConfirmPassword" 
                                    Display="Dynamic" ErrorMessage="The Passwords must match." 
                                    ValidationGroup="CreateUserWizard1"></asp:CompareValidator>
                            </td>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td align="right" class="style3">
                                &nbsp;</td>
                            <td class="style2_usr">
                                &nbsp;</td>
                            <td>
                                <asp:Literal ID="ErrorMessage" runat="server" EnableViewState="False"></asp:Literal>
                            </td>
                            <td>
                                &nbsp;</td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:CreateUserWizardStep>
            <asp:CompleteWizardStep runat="server">
            </asp:CompleteWizardStep>
        </WizardSteps>
    </asp:CreateUserWizard>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

