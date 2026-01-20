<%@ Page Language="C#" AutoEventWireup="true" CodeFile="secure_photo.aspx.cs" Inherits="COOPERP_financials_secure_photo" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
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


        </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <table class="style1">
            <tr>
                <td>
                    <br />
                </td>
            </tr>
            <tr>
                <td>
                    <dx:ASPxUploadControl runat="server" ID="txtFilePath" FileUploadMode="OnPageLoad" Height="35px" Width="100%">
                    </dx:ASPxUploadControl>
                </td>
            </tr>
            <tr>
                <td>
                    <dx:ASPxButton runat="server" Text="Attach Photo" Width="100%" ID="cmdAttach" OnClick="cmdAttach_Click" Height="35px">
                        <ClientSideEvents Click="function(s, e) {
	 e.processOnServer = confirm(&#39;Attach Photo?&#39;);
}">
                        </ClientSideEvents>
                        <Image Url="~/COOPERP/images/tick-button.png">
                        </Image>
                    </dx:ASPxButton>
                </td>
            </tr>
            <tr>
                <td style="text-align: center">
                    <dx:ASPxLabel runat="server" ForeColor="Red" ID="lbl_comment">
                    </dx:ASPxLabel>
                </td>
            </tr>
            <tr>
                <td style="text-align: center">
                    <br />
                    <br />
                </td>
            </tr>
        </table>
    
    </div>
    </form>
</body>
</html>
