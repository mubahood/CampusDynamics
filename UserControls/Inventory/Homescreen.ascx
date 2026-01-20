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
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Inventory Management"
    Style="text-align: left" Width="100%">
    <HeaderImage Url="~/COOPERP/images/bank.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <table style="width: 100%;">
                <tr>
                    <td class="style4">
                        <dx:ASPxLabel ID="ASPxLabel1" runat="server" Font-Bold="True" 
                            Font-Size="Medium"  
                            
                            style="text-align: center; font-size: medium; height: 27px; color: #0000FF" 
                            Text="SCHOOL DYNAMICS : INVENTORY MANAGEMENT CENTER">
                        </dx:ASPxLabel>
                    </td>
                </tr>
                <tr>
                    <td class="style4">
                        <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    </td>
                </tr>
                <tr>
                    <td class="style5">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5">
                        &nbsp;
                        <dx:ASPxImage ID="ASPxImage1" runat="server" 
                            ImageUrl="~/COOPERP/images/images/inventory.jpg">
                        </dx:ASPxImage>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="style5">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5">
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style5">
                        <dx:ASPxLabel ID="ASPxLabel2" runat="server" 
                            style="text-align: center; height: 60px; color: #000000; font-weight: bold" 
                            
                            Text="| Supplier's Info | Stock Management | Products Info | TAX Settings | Inventory Documents |">
                        </dx:ASPxLabel>
                    </td>
                </tr>
            </table>
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
