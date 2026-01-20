<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Locker.ascx.cs" Inherits="COOPERP_fonts_Locker" %>
<style type="text/css">

        .style1
        {
            width: 500px;
            height: 400px;
        }
        .style2
    {
        width: 100%;
    }
</style>
    
                <dx:ASPxPopupControl runat="server" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Modal="True" HeaderText="License Activator" Width="500px" ID="pop_newlicense" CloseAction="None">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
<dx:PopupControlContentControl runat="server">
                            <table class="style2">
                                <tr>
                                    <td align="center">
                                        <dx:ASPxLabel ID="lbl_lock" runat="server" style="font-weight: 700; color: #FF0000; font-size: 10pt">
                                        </dx:ASPxLabel>

                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxTextBox ID="txtLicenseCode" runat="server" Height="30px" Width="200px">
                                        </dx:ASPxTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxButton runat="server" Text="Enter License Code" Width="200px" Height="30px" ID="cmdActivate" OnClick="cmdActivate_Click"></dx:ASPxButton>

                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxLabel runat="server" ForeColor="Red" ID="lbl_comment"></dx:ASPxLabel>

                                    </td>
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

                
    
    
