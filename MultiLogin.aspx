<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MultiLogin.aspx.cs" Inherits="MultiLogin" Title="Campus Dynamics :: Higher Education ERP" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="shortcut icon" href="~/COOPERP/images/tinylogo.gif?img=1" />
    <link href="COOPERP/css/loginstyle.css" rel="stylesheet" type="text/css" />
    <title></title>
    <style type="text/css">

        .style2
    {
        width: 100%;
    }
        .auto-style1 {
            height: 20px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
                <dx:ASPxPopupControl runat="server" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Modal="True" HeaderText="Multi Login Detected" Width="500px" ID="pop_newlicense" CloseAction="None">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
<dx:PopupControlContentControl runat="server">
                            <table class="style2">
                                <tr>
                                    <td align="center">
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <br />
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" class="auto-style1">
                                        <dx:ASPxLabel ID="lbl_lock" runat="server" style="font-weight: 700; color: #FF0000; font-size: 10pt" Font-Size="Medium">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <br />
                                        <br />
                                        <dx:ASPxButton ID="cmdLogin" runat="server" Text="Back to Login" Width="170px" PostBackUrl="~/Default.aspx">
                                            <Image Url="~/COOPERP/images/key--arrow.png">
                                            </Image>
                                        </dx:ASPxButton>
                                        <br />

                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;</td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
</ContentCollection>
</dx:ASPxPopupControl>

                
    
    
    </div>
    </form>
</body>
</html>
