<%@ Page Title="Error Page" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ErrorPage.aspx.cs" Inherits="ErrorPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Error Reporting Centre" Width="100%">
    <HeaderImage Url="~/COOPERP/images/exclamation-red.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td style="text-align: center; font-weight: 700; color: #FF0000; font-size: large">
                <br />
                <span style="font-size: xx-large; color: #FF0000;">AN ERROR OCCURED!</span><br />
                <dx:ASPxImage ID="ASPxImage3" runat="server" Height="1px" 
                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                </dx:ASPxImage>
                <br />
                <br />
                PLEASE CHECK YOUR DATA FOR:<br />
                <br />
                * BLANK ENTRIES<br /> * LETTERS IN PLACE OF NUMBERS<br />
                <br />
                CLICK THE &quot;BACK&quot; BUTTON
                <br />
                AND TRY AGAIN<br /> <br />
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
</asp:Content>

