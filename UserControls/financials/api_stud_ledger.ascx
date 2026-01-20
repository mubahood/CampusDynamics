<%@ Control Language="C#" AutoEventWireup="true" CodeFile="api_stud_ledger.ascx.cs" Inherits="UserControls_financials_api_stud_ledger" %>
<style type="text/css">




    
*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    
    .style1
    {
        width: 100%;
    }


    
    .style4
    {
        height: 23px;
    }


    
    .style2
    {
        height: 38px;
    }
    .style3
    {
        height: 42px;
    }

    .auto-style1 {
        height: 23px;
        width: 107px;
    }
    .auto-style2 {
        width: 107px;
    }
    .auto-style3 {
        height: 23px;
        width: 292px;
    }
    .auto-style4 {
        width: 292px;
    }
    .auto-style5 {
        height: 23px;
        width: 81px;
    }
    .auto-style6 {
        width: 81px;
    }

    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td align="center" height="30">
                <dx:ASPxLabel ID="lbl_header" runat="server" Font-Bold="True" ForeColor="Red">
                </dx:ASPxLabel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxImage ID="ASPxImage1" runat="server" Height="1px" 
                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                </dx:ASPxImage>
            </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style2" valign="top">
                            <dx:ASPxButton ID="cmdPrint" runat="server" Height="35px" OnClick="cmdPrint_Click" Text="Print Ledger" Width="170px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style4" valign="top">
                            &nbsp;</td>
                        <td class="auto-style6" valign="top">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style2">
                            &nbsp;</td>
                        <td class="auto-style4">
                            &nbsp;</td>
                        <td class="auto-style6">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsJournalTransactions" KeyFieldName="TID" 
                    Width="100%" OnHtmlDataCellPrepared="gvLedger_HtmlDataCellPrepared">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="#" FieldName="accName" 
                            ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Date" FieldName="formated_date" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="150px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="CR" FieldName="cr_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="5" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="DR" FieldName="dr_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="curr_balance" ShowInCustomizationForm="True" VisibleIndex="7" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Journal No" FieldName="voucherNo" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <SettingsPager Mode="ShowAllRecords">
                    </SettingsPager>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="StudentAccountingDataTableAdapters.fin_GetStudentLedgerTableAdapter">
                    <SelectParameters>
                        <asp:QueryStringParameter DefaultValue="-" Name="reg" QueryStringField="reg" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" 
                    HeaderText="Academica ERP Version 3.0" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td class="style2">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        &nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" 
                                            style="font-weight: 700;" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3">
                                    </td>
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