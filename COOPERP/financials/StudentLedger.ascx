<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentLedger.ascx.cs" Inherits="UserControls_financials_StudentLedger" %>
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

    .auto-style8 {
        width: 109px;
    }
    .auto-style9 {
        width: 87px;
    }

    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
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
                        <td class="auto-style1">
                            Account Code:</td>
                        <td class="auto-style3">
                            <dx:ASPxTextBox ID="txtAdmNo" runat="server" ReadOnly="True" Width="170px" Height="35px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxTextBox>
                        </td>
                        <td class="auto-style5">
                            Start Date:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" Width="170px" DisplayFormatString="dd MMMM, yyyy" Height="35px">
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2" valign="top">
                            &nbsp;</td>
                        <td class="auto-style4" valign="top">
                            <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" Text="Print Ledger" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style6" valign="top">
                            End Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" Width="170px" DisplayFormatString="dd MMMM, yyyy" Height="35px">
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">
                            &nbsp;</td>
                        <td class="auto-style4">
                            <dx:ASPxButton ID="cmdAdjustments" runat="server" AutoPostBack="False" Height="35px" Text="Adjustments" Width="170px">
                                <Image IconID="tasks_edittask_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
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
                    Width="100%">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="Date" FieldName="formated_date" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="150px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="CR" FieldName="cr_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="DR" FieldName="dr_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="curr_balance" ShowInCustomizationForm="True" VisibleIndex="8" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Journal No" FieldName="voucherNo" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn Caption="#" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn FieldName="realVoucherno" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="transactionDate" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                        </dx:GridViewDataDateColumn>
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
                    SelectMethod="GetLimitedStudentLedger" 
                    TypeName="StudentAccountingDataTableAdapters.fin_GetStudentLedgerTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="-" Name="reg" SessionField="regno" Type="String" />
                        <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <dx:ASPxLoadingPanel ID="panel_billling" runat="server" ClientInstanceName="panel_billling" Modal="True" Text="Processing...Please wait&amp;hellip;">
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" 
                    HeaderText="Campus Dynamics ERP" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
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
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_adjustments" runat="server" HeaderText="Campus Dynamics ERP :: Adjustment Settings" Modal="True" PopupElementID="cmdAdjustments" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="350px">
                    <HeaderImage IconID="tasks_edittask_16x16">
                    </HeaderImage>
                    <ContentStyle>
                        <Paddings Padding="10px" />
                    </ContentStyle>
                    <HeaderStyle HorizontalAlign="Center">
                    <Paddings Padding="15px" />
                    </HeaderStyle>
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td class="style2"></td>
                                </tr>
                                <tr>
                                    <td class="style3">
                                        <table class="style1">
                                            <tr>
                                                <td class="auto-style9">Adjustment:</td>
                                                <td>
                                                    <dx:ASPxComboBox ID="txtType" runat="server" Height="35px" Width="100%" SelectedIndex="0" AutoPostBack="True">
                                                        <Items>
                                                            <dx:ListEditItem Selected="True" Text="Billing Correction" Value="Billing Correction" />
                                                            <dx:ListEditItem Text="Cancel Payment" Value="Cancel Payment" />
                                                            <dx:ListEditItem Text="Clear Ledger" Value="Clear Ledger" />
                                                            <dx:ListEditItem Text="Reverse Transaction" Value="Reverse Transaction" />
                                                            <dx:ListEditItem Text="Correct Pay Amount" Value="Correct Pay Amount" />
                                                        </Items>
                                                        <Paddings PaddingLeft="10px" />
                                                    </dx:ASPxComboBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="auto-style9">New Amount:</td>
                                                <td>
                                                    <dx:ASPxTextBox ID="txtNewAmount" runat="server" Height="35px" Text="0" Width="100%" Enabled="False">
                                                        <Paddings PaddingLeft="10px" />
                                                    </dx:ASPxTextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="auto-style9">&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td class="auto-style9">&nbsp;</td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdProcess" runat="server" Height="35px" Text="Process Adjustment" Width="100%" OnClick="cmdProcess_Click">
                                                        <Image IconID="tasks_edittask_16x16">
                                                        </Image>
                                                        <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Process Adjustment?');
if(e.processOnServer==true)
{
panel_billling.Show();
}
  }" />
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3">&nbsp;</td>
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



