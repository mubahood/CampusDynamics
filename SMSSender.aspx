<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SMSSender.aspx.cs" Inherits="SMSSender" %>

<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .style1
        {
            width: 100%;
        }
        .style3
        {
            width: 126px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="SMS Sender Plus" Width="100%">
            <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td class="style3">
                Sender:</td>
            <td>
                <dx:ASPxTextBox ID="txtSender" runat="server" Width="250px" Text="YCI">
                </dx:ASPxTextBox>
            </td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td class="style3">
                Message:</td>
            <td>
                <dx:ASPxMemo ID="txtMessage" runat="server" Height="71px" Width="250px">
                </dx:ASPxMemo>
            </td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td class="style3">
                Receipient Phone(s):</td>
            <td>
                <dx:ASPxMemo ID="txtPhones" runat="server" Height="71px" Width="250px">
                </dx:ASPxMemo>
            </td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td class="style3">
                &nbsp;</td>
            <td>
                <dx:ASPxButton ID="cmdSend" runat="server" OnClick="cmdSend_Click" 
                    Text="Send Message" Width="250px">
                    <ClientSideEvents Click="function(s, e) {
	lp_sms.Show();
}" />
                    <Image Url="~/COOPERP/images/arrow-000-medium.png">
                    </Image>
                </dx:ASPxButton>
            </td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td class="style3">
                &nbsp;</td>
            <td>
                <dx:ASPxButton ID="cmdClear" runat="server" OnClick="cmdClear_Click" 
                    Text="Clear Message" Width="250px">
                    <Image Url="~/COOPERP/images/cross-octagon.png">
                    </Image>
                </dx:ASPxButton>
            </td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td class="style3">
                &nbsp;</td>
            <td>
                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                </dx:ASPxLabel>
            </td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td class="style3">
                &nbsp;</td>
            <td>
                <dx:ASPxLoadingPanel ID="lp_sms" runat="server" ClientInstanceName="lp_sms" 
                    Modal="True" Text="Sending SMS&amp;hellip;">
                </dx:ASPxLoadingPanel>
            </td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
