<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PhotoUpload.aspx.cs" Inherits="COOPERP_Registry_PhotoUpload" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            width: 110px;
        }
        .auto-style2 {
            width: 208px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Upload Photo" ShowCollapseButton="true" Width="100%">
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td class="auto-style1">&nbsp;</td>
            <td class="auto-style2">&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td class="auto-style1">Image File:</td>
            <td class="auto-style2">
                <dx:ASPxUploadControl ID="txtFilePath" runat="server">
                </dx:ASPxUploadControl>
            </td>
            <td>
                <dx:ASPxButton ID="cmdAttach" runat="server" OnClick="cmdAttach_Click" Text="Attach Photo" Width="170px">
                    <ClientSideEvents Click="function(s, e) {
	 e.processOnServer = confirm('Attach Photo?');
}" />
                    <Image Url="~/COOPERP/images/tick-button.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td class="auto-style1">&nbsp;</td>
            <td class="auto-style2">
                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                </dx:ASPxLabel>
            </td>
            <td>&nbsp;</td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
        </div>
    </form>
</body>
</html>
