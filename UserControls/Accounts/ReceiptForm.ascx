<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ReceiptForm.ascx.cs" Inherits="UserControls_Accounts_ReceiptForm" %>
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


    .pad
    {
        width:50px;
    }
    .style7
    {
        width: 55px;
        font-weight: 700;
    }
    .style8
    {
        width: 350px;
    }
    
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_receipts.png">
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
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="pad">
                        </td>
                        <td class="pad">
                            Receipt No:</td>
                        <td class="style8">
                            <dx:ASPxLabel ID="txtReceiptNo" runat="server" Font-Bold="True" 
                                Font-Italic="True" ForeColor="Red" Text="1255">
                            </dx:ASPxLabel>
                        </td>
                        <td class="style14">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style29">
                            &nbsp;</td>
                        <td class="pad">
                            Date:</td>
                        <td class="style8">
                            <dx:ASPxDateEdit ID="txtReceiptDate" runat="server" Width="350px">
                            </dx:ASPxDateEdit>
                        </td>
                        <td class="style19">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style29">
                        </td>
                        <td class="style33">
                            Payment For:</td>
                        <td class="style18">
                            <dx:ASPxComboBox ID="txtPaidFor" runat="server" ValueType="System.String" 
                                Width="350px">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style19">
                        </td>
                    </tr>
                    <tr>
                        <td class="style21">
                        </td>
                        <td class="style27">
                            Paid By:</td>
                        <td class="style23">
                            <dx:ASPxComboBox ID="txtPaidBy" runat="server" ValueType="System.String" 
                                Width="350px">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style24">
                        </td>
                    </tr>
                    <tr>
                        <td class="style30">
                            &nbsp;</td>
                        <td class="style34" valign="top">
                            Particulars:</td>
                        <td class="style5">
                            <dx:ASPxMemo ID="txtParticulars" runat="server" Height="71px" Width="350px">
                            </dx:ASPxMemo>
                        </td>
                        <td class="style5">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style30">
                            &nbsp;</td>
                        <td class="style34">
                            &nbsp;</td>
                        <td class="style8">
                            <dx:ASPxButton ID="cmdCreateReceipt" runat="server" 
                                OnClick="cmdCreateReceipt_Click" Text="Preview Receipt" Width="350px">
                                <Image Url="~/COOPERP/images/receipt-invoice.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="style7">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style30">
                            &nbsp;</td>
                        <td class="style34">
                            &nbsp;</td>
                        <td class="style8">
                            &nbsp;</td>
                        <td class="style7">
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_receipts" runat="server" HeaderText="" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

