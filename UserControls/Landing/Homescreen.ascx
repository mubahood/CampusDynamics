<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Homescreen.ascx.cs" Inherits="UserControls_FrontOffice_Homescreen" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style4
    {
        text-align: center;
    }
    .style5
    {
        text-align: center;
    }
</style>
<dx:ASPxRoundPanel ID="panel_header" runat="server" HeaderText="Accounting Centre"
    Style="text-align: left" Width="100%">
    <HeaderImage Url="~/COOPERP/images/calculate.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <table style="width: 100%;">
                <tr>
                    <td class="style4" colspan="3">
                        <dx:ASPxLabel ID="lbl_header" runat="server" Font-Bold="True" 
                            Font-Size="Medium"  
                            
                            style="text-align: center; font-size: medium; height: 27px; color: #0000FF" 
                            Text="HOTEL DYNAMICS : ACCOUNTING CENTRE">
                        </dx:ASPxLabel>
                    </td>
                </tr>
                <tr>
                    <td class="style4" colspan="3">
                        <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    </td>
                </tr>
                <tr>
                    <td class="style5" colspan="3">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5" colspan="3">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5" colspan="3">
                        &nbsp;
                        <dx:ASPxImage ID="imgHomeImage" runat="server" 
                            ImageUrl="~/COOPERP/images/homeImage_Accounts.png">
                        </dx:ASPxImage>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="style5" colspan="3">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5" colspan="3">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5" colspan="3">
                        <dx:ASPxLabel ID="lbl_functionalities" runat="server" 
                            
                            style="text-align: center; height: 60px; color: #000000; font-weight: bold">
                        </dx:ASPxLabel>
                    </td>
                </tr>
                <tr>
                    <td class="style5">
                        &nbsp;
                    </td>
                    <td class="style1">
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
            </table>
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
