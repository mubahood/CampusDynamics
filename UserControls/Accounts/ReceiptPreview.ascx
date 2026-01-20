<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ReceiptPreview.ascx.cs" Inherits="UserControls_Accounts_ReceiptPreview" %>
<style type="text/css">

    .style1
    {
        width: 100%;
    }
    .style15
    {
        width: 60%;
    }
    .style16
    {
        width: 20%x;
        text-align: right;
        font-weight: 700;
    }
    .style3
    {
        width: 40px;
        height: 31px;
    }
    .style4
    {
        height: 31px;
    }
    
    .style5
    {
        width: 40px;
        height: 80px;
    }
    .style6
    {
        height: 80px;
    }
    .style2
    {
        width: 40px;
        height: 24px;
    }
    .style7
    {
        height: 24px;
    }
    .style17
    {
        width: 246px;
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
    HeaderText="Voucher Approval" Width="100%" ShowHeader="False">
    <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvSingleVoucher" runat="server" 
                    AutoGenerateColumns="False" DataSourceID="dsSingleVoucher" KeyFieldName="TID" 
                    Width="100%">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="accountname" 
                            ShowInCustomizationForm="True" VisibleIndex="0">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="bankName" ShowInCustomizationForm="True" 
                            VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="TID" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="accountcode" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="account_type" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="transactionType" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="transaction_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="particulars" 
                            ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="voucherNo" ShowInCustomizationForm="True" 
                            VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="transactionDate" 
                            ShowInCustomizationForm="True" VisibleIndex="9">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn FieldName="teller" ShowInCustomizationForm="True" 
                            VisibleIndex="10">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="timeLog" ShowInCustomizationForm="True" 
                            VisibleIndex="11">
                        </dx:GridViewDataDateColumn>
                    </Columns>
                    <SettingsPager PageSize="1">
                    </SettingsPager>
                    <Settings ShowColumnHeaders="False" />
                    <Templates>
                        <DataRow>
                            <table class="style1">
                                <tr>
                                    <td style="text-align: center; font-weight: 700; font-size: medium">
                                        RECEIPT</td>
                                </tr>
                                <tr>
                                    <td>
                                        <table class="style1">
                                            <tr>
                                                <td class="style15">
                                                    <strong>Received with thanks from:</strong></td>
                                                <td class="style16">
                                                    Date:&nbsp;</td>
                                                <td style="text-align: right">
                                                    <dx:ASPxLabel ID="ASPxLabel4" runat="server" 
                                                        Text='<%# Eval("transactionDate", "{0:dd MMMM, yyyy}") %>'>
                                                    </dx:ASPxLabel>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style15">
                                                    <dx:ASPxLabel ID="ASPxLabel5" runat="server" style="font-style: italic" 
                                                        Text='<%# Eval("accountname") %>'>
                                                    </dx:ASPxLabel>
                                                </td>
                                                <td class="style16">
                                                    &nbsp;</td>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td class="style15">
                                                    &nbsp;</td>
                                                <td class="style16">
                                                    &nbsp;</td>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table border="1" cellpadding="0" cellspacing="0" class="style1">
                                            <tr>
                                                <td class="style3" style="font-weight: 700">
                                                    &nbsp; SNo</td>
                                                <td class="style4" style="font-weight: 700">
                                                    &nbsp; Description</td>
                                                <td class="style4" style="font-weight: 700">
                                                    &nbsp; Amount</td>
                                            </tr>
                                            <tr>
                                                <td class="style5" valign="top">
                                                    &nbsp; 1</td>
                                                <td class="style6" valign="top">
                                                    &nbsp;
                                                    <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text='<%# Eval("particulars") %>' 
                                                        style="font-style: italic">
                                                    </dx:ASPxLabel>
                                                </td>
                                                <td class="style6" valign="top">
                                                    &nbsp;
                                                    <dx:ASPxLabel ID="ASPxLabel2" runat="server" 
                                                        Text='<%# Eval("transaction_amount", "{0:0,0}") %>'>
                                                    </dx:ASPxLabel>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style2">
                                                    </td>
                                                <td style="font-weight: 700" class="style7">
                                                    &nbsp; TOTAL AMOUNT</td>
                                                <td class="style7">
                                                    &nbsp;
                                                    <dx:ASPxLabel ID="ASPxLabel3" runat="server" style="font-weight: 700" 
                                                        Text='<%# Eval("transaction_amount", "{0:0,0}") %>'>
                                                    </dx:ASPxLabel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table class="style1">
                                            <tr>
                                                <td class="style17">
                                                    &nbsp;</td>
                                                <td align="right">
                                                    <br />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style17">
                                                    <dx:ASPxCheckBox ID="cb_PrintReceipt" runat="server" AutoPostBack="True" 
                                                        Checked="True" CheckState="Checked" 
                                                        oncheckedchanged="cb_PrintReceipt_CheckedChanged" Text="Print Receipt">
                                                    </dx:ASPxCheckBox>
                                                </td>
                                                <td align="right">
                                                    &nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td class="style17">
                                                    <dx:ASPxButton ID="cmdApprove" runat="server" onclick="cmdApprove_Click" 
                                                        Text="Approve &amp; Print Receipt" Width="250px">
                                                        <Image Url="~/COOPERP/images/printer.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td align="right">
                                                    <dx:ASPxButton ID="cmdCancel" runat="server" onclick="cmdCancel_Click" 
                                                        Text="Cancel Receipt" Width="250px">
                                                        <Image Url="~/COOPERP/images/minus-button.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style17">
                                                    &nbsp;</td>
                                                <td align="right">
                                                    <br />
                                                    <br />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </DataRow>
                    </Templates>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsSingleVoucher" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetSingleReceipt" 
                    TypeName="CoopERPDataTableAdapters.fin_GetSingleVoucherTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="0" Name="VNO" SessionField="VNO" 
                            Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" 
                    HeaderText="School Dymanics Version 1.0" Height="150px" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td height="30">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxImage ID="img_msg" runat="server" ImageAlign="AbsBottom">
                                        </dx:ASPxImage>
                                        &nbsp;<dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>


