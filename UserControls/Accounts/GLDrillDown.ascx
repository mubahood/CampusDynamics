<%@ Control Language="C#" AutoEventWireup="true" CodeFile="GLDrillDown.ascx.cs" Inherits="UserControls_Accounts_GLDrillDown" %>
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


    
    .style2
    {
        height: 38px;
    }
    .style3
    {
        height: 42px;
    }

    .style4
    {
        height: 23px;
    }
    .auto-style17 {
        height: 23px;
        width: 185px;
    }
    .auto-style19 {
        height: 23px;
        width: 73px;
    }
    .auto-style21 {
        height: 23px;
        width: 184px;
    }
    .auto-style22 {
        height: 23px;
        width: 74px;
    }
    .auto-style23 {
        height: 18px;
    }
    .auto-style24 {
        height: 149px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table1" class="style1">
                <tr>
                    <td>
                        <table id="table2" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_gl_balances.png" >
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  Width="100%">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table id="table3" class="style1">
                            <tr>
                                <td class="auto-style22">&nbsp;</td>
                                <td class="auto-style17">&nbsp;</td>
                                <td class="auto-style19">&nbsp;</td>
                                <td class="auto-style21">&nbsp;</td>
                                <td class="auto-style17">&nbsp;</td>
                                <td class="style4">&nbsp;</td>
                                <td class="style4">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style22">Start Date:</td>
                                <td class="auto-style17">
                                    <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" DisplayFormatString="dd/MM/yyyy" Height="27px" Width="170px">
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxDateEdit>
                                </td>
                                <td class="auto-style19">End Date:</td>
                                <td class="auto-style21">
                                    <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" DisplayFormatString="dd/MM/yyyy" Height="27px" Width="170px">
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxDateEdit>
                                </td>
                                <td class="auto-style17">
                                    <dx:ASPxButton ID="cmdPrint" runat="server" Height="27px" OnClick="cmdPrint_Click" Text="Export Excel" Width="170px">
                                        <Image Url="~/COOPERP/images/document-excel-table.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="style4">
                                    <dx:ASPxButton ID="cmdViewGL" runat="server" Height="27px" OnClick="cmdViewGL_Click" Text="View GL Listing" Width="170px">
                                        <Image IconID="filterelements_listbox_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="style4">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style22">&nbsp;</td>
                                <td class="auto-style17">&nbsp;</td>
                                <td class="auto-style19">&nbsp;</td>
                                <td class="auto-style21">&nbsp;</td>
                                <td class="auto-style17">&nbsp;</td>
                                <td class="style4">&nbsp;</td>
                                <td class="style4">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvGeneralLedger" runat="server" AutoGenerateColumns="False" DataSourceID="dsJournalTransactions" KeyFieldName="accountcode" OnHtmlDataCellPrepared="gvGeneralLedger_HtmlDataCellPrepared" Width="100%" EnableCallBacks="False">
                            <SettingsDetail ExportMode="Expanded" ShowDetailRow="True" />
                            <Templates>
                                <DetailRow>
                                    <table id="table4" class="style1">
                                        <tr>
                                            <td class="auto-style23">
                                                <dx:ASPxGridView ID="gvDetails" runat="server" AutoGenerateColumns="False" DataSourceID="dsDrillDownDetails" KeyFieldName="accountcode" OnBeforePerformDataSelect="gvDetails_BeforePerformDataSelect" OnHtmlDataCellPrepared="gvDetails_HtmlDataCellPrepared" Width="100%">
                                                    <SettingsDetail ExportMode="Expanded" ShowDetailRow="True" />
                                                    <Templates>
                                                        <DetailRow>
                                                            <table id="table5" class="style1">
                                                                <tr>
                                                                    <td class="auto-style23">
                                                                        <dx:ASPxGridView ID="gvDetails" runat="server" AutoGenerateColumns="False" DataSourceID="dsDrillDownDetails" KeyFieldName="TID" OnBeforePerformDataSelect="gvDetails_BeforePerformDataSelect1" OnHtmlDataCellPrepared="gvDetails_HtmlDataCellPrepared" Width="100%">
                                                                            <SettingsPager PageSize="200">
                                                                            </SettingsPager>
                                                                            <SettingsBehavior AllowFocusedRow="True" />
                                                                            <SettingsSearchPanel Visible="True" />
                                                                            <Columns>
                        
                        <dx:GridViewDataTextColumn Caption="Date" FieldName="transactionDate" 
                            ShowInCustomizationForm="True" VisibleIndex="3" PropertiesTextEdit-DisplayFormatString ="dd/MM/yyyy">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="DR/CR" FieldName="transactionType" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                        </dx:GridViewDataTextColumn>
                        
                   
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                       
                        <dx:GridViewDataTextColumn FieldName="voucherNo" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                           
                         
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                                                                                <dx:GridViewDataTextColumn Caption="Amount" FieldName="transaction_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Currency" FieldName="trans_currency" ShowInCustomizationForm="True" VisibleIndex="6" Width="50px">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                                                                        </dx:ASPxGridView>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:ObjectDataSource ID="dsDrillDownDetails" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetDrillDownDetailsTableAdapter">
                                                                            <SelectParameters>
                                                                                <asp:SessionParameter Name="acc" SessionField="acc_code" Type="String" />
                                                                                <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                                                                                <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                                                                            </SelectParameters>
                                                                        </asp:ObjectDataSource>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </DetailRow>
                                                    </Templates>
                                                    <SettingsPager PageSize="200">
                                                    </SettingsPager>
                                                    <SettingsBehavior AllowFocusedRow="True" />
                                                    <SettingsSearchPanel Visible="True" />
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Account Code" FieldName="accountcode" VisibleIndex="0">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Account Name" FieldName="acc_name" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="balance" VisibleIndex="2">
                                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                            </PropertiesTextEdit>
                                                            <HeaderStyle HorizontalAlign="Right" />
                                                            <CellStyle HorizontalAlign="Right">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="dsDrillDownDetails" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetGeneralDrillDownDetailsTableAdapter">
                                                    <SelectParameters>
                                                        <asp:SessionParameter Name="acc" SessionField="subacc_code" Type="String" />
                                                        <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                                                        <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </DetailRow>
                            </Templates>
                            <SettingsPager PageSize="1000">
                            </SettingsPager>
                            <SettingsBehavior AllowFocusedRow="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Category" FieldName="category" Visible="False" VisibleIndex="1" Width="80px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Category" FieldName="subcategory" VisibleIndex="2" Width="150px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="GL Account" FieldName="accountcode" VisibleIndex="5" Width="150px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Account Name" FieldName="accountname" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="DRBalance" VisibleIndex="7" Width="100px">
                                    <BatchEditModifiedCellStyle HorizontalAlign="Right">
                                    </BatchEditModifiedCellStyle>
                                    <HeaderStyle HorizontalAlign="Right" />
                                    <CellStyle HorizontalAlign="Right">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="CRBalance" VisibleIndex="8" Width="100px">
                                    <BatchEditModifiedCellStyle HorizontalAlign="Right">
                                    </BatchEditModifiedCellStyle>
                                    <HeaderStyle HorizontalAlign="Right" />
                                    <CellStyle HorizontalAlign="Right">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_TrialBalanceTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                                <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <dx:ASPxGridViewExporter ID="gve_budget" runat="server" ExportedRowType="All" GridViewID="gvGeneralLedger">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td class="auto-style24">
                        <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td class="style2"></td>
                                        </tr>
                                        <tr>
                                            <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" ForeColor="Red" style="font-weight: 700;">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style3"></td>
                                        </tr>
                                    </table>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_gl_listing" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td class="style2"></td>
                                        </tr>
                                        <tr>
                                            <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msgbox0" runat="server" ForeColor="Red" style="font-weight: 700;">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style3"></td>
                                        </tr>
                                    </table>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="cmdPrint" />
        </Triggers>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>