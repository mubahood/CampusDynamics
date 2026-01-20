<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BankReconciliation.ascx.cs" Inherits="UserControls_Accounts_BankReconciliation" %>
<style type="text/css">



    
    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    }


    
    .style1_rec
    {
        width: 100%;
    }


    
    .style2_rec
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
    .auto-style_rec5 {
        height: 23px;
        width: 113px;
    }
    .auto-style_rec6 {
        width: 113px;
    }
    .auto-style_rec9 {
        height: 23px;
        width: 87px;
    }
    .auto-style_rec10 {
        width: 87px;
    }
    .auto-style_rec13 {
        height: 23px;
        width: 373px;
    }
    .auto-style_rec14 {
        width: 373px;
    }
    .auto-style_rec15 {
        height: 23px;
        width: 429px;
    }
    .auto-style_rec16 {
        width: 429px;
    }
    .auto-style1 {
        width: 146px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table1" class="style1_rec">
                <tr>
                    <td>
                        <table id="table2" cellpadding="0" cellspacing="0" class="style1_rec">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_bank_reconciliation.png" >
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
                        <table id="table3" class="style1_rec">
                            <tr>
                                <td class="auto-style_rec5"></td>
                                <td class="auto-style_rec15"></td>
                                <td class="auto-style_rec9"></td>
                                <td class="style4"></td>
                            </tr>
                            <tr>
                                <td class="auto-style_rec5">Bank Account:</td>
                                <td class="auto-style_rec15">
                                    <dx:ASPxComboBox ID="txtPayee" runat="server" AutoPostBack="True" DataSourceID="dsPayeeAccounts" Height="27px" SelectedIndex="0" TextField="accountName" TextFormatString="{1}" ValueField="accountCode" Width="400px" OnSelectedIndexChanged="txtPayee_SelectedIndexChanged">
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	lp_loading.Show();
}" />
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="accountCode" Width="60px" />
                                            <dx:ListBoxColumn Caption="Payee" FieldName="accountName" Width="250px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style_rec9">Start Date:</td>
                                <td class="style4">
                                    <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" DisplayFormatString="dd/MM/yyyy" Height="27px" Width="170px">
                                        <ClientSideEvents ValueChanged="function(s, e) {
	lp_loading.Show();
}" />
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxDateEdit>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style_rec6" valign="top">Statement No:</td>
                                <td class="auto-style_rec16">
                                    <dx:ASPxComboBox ID="txtStatement" runat="server" AutoPostBack="True" DataSourceID="dsReconciliations" Height="27px" SelectedIndex="0" TextField="title" TextFormatString="{1}" ValueField="ID" Width="400px" OnSelectedIndexChanged="txtStatement_SelectedIndexChanged" ValueType="System.Int32">
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	lp_loading.Show();
}" />
                                        <Columns>
                                            <dx:ListBoxColumn Caption="St. No" FieldName="ID" Width="50px" />
                                            <dx:ListBoxColumn Caption="Title" FieldName="title" Width="300px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style_rec10">End Date:</td>
                                <td>
                                    <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" DisplayFormatString="dd/MM/yyyy" Height="27px" Width="170px">
                                        <ClientSideEvents DateChanged="function(s, e) {
	lp_loading.Show();
}" />
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxDateEdit>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style_rec6">Display Status:</td>
                                <td class="auto-style_rec16">
                                    <table id="table6" cellpadding="0" cellspacing="0" class="style1_rec">
                                        <tr>
                                            <td class="auto-style1">
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" AutoPostBack="True" Height="27px" SelectedIndex="0" Width="200px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	lp_loading.Show();
}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="All Transactions" Value="ALL" />
                                                        <dx:ListEditItem Text="Pending Transactions" Value="Pending" />
                                                        <dx:ListEditItem Text="Reconciled Transactions" Value="Reconciled" />
                                                    </Items>
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>
                                                <dx:ASPxButton ID="cmdAddNew" runat="server" Height="27px" OnClick="cmdAddNew_Click" Text="New Statement" Width="200px">
                                                    <ClientSideEvents CheckedChanged="function(s, e) {
	e.processOnServer = confirm('Add New Statement?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }
}" />
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td class="auto-style_rec10">&nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="cmdPrint" runat="server" Height="27px" OnClick="cmdPrint_Click" Text="Print Statement" Width="170px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style_rec6">&nbsp;</td>
                                <td class="auto-style_rec16">&nbsp;</td>
                                <td class="auto-style_rec10">&nbsp;</td>
                                <td>&nbsp;</td>
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
                        <dx:ASPxGridView ID="gvCurrentReconciliationStatement" runat="server" AutoGenerateColumns="False" DataSourceID="dsSingleReconciliations" KeyFieldName="ID" Width="100%">
                            <SettingsContextMenu Enabled="True">
                            </SettingsContextMenu>
                            <SettingsPager Mode="ShowAllRecords">
                            </SettingsPager>
                            <SettingsEditing Mode="Batch">
                            </SettingsEditing>
                            <SettingsBehavior AllowFocusedRow="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Statement No" FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="25px">
                                    <EditFormSettings Visible="False" />
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Reconciliation Date" FieldName="rec_date" ShowInCustomizationForm="True" VisibleIndex="4">
                                    <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                                    </PropertiesDateEdit>
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Last Statement Balance" FieldName="last_rec_balance" ShowInCustomizationForm="True" VisibleIndex="6">
                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                    </PropertiesTextEdit>
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Statement Date" FieldName="statement_date" ShowInCustomizationForm="True" VisibleIndex="5">
                                    <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Ending Statement Balance" FieldName="statement_balance" ShowInCustomizationForm="True" VisibleIndex="7">
                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                    </PropertiesTextEdit>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Reconciliation Status" FieldName="rec_status" ShowInCustomizationForm="True" VisibleIndex="8">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Bank Code" FieldName="bank_code" ShowInCustomizationForm="True" VisibleIndex="3">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Title" FieldName="title" ShowInCustomizationForm="True" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPageControl ID="PageReconciliation" runat="server" ActiveTabIndex="0" Width="100%">
                            <TabPages>
                                <dx:TabPage Text="Transaction Matching">
                                    <ContentCollection>
                                        <dx:ContentControl runat="server">
                                            <table id="table4" class="style1_rec">
                                                <tr>
                                                    <td align="center" colspan="2" style="text-align: left">
                                                        <table id="table5" class="style1_rec">
                                                            <tr>
                                                                <td align="right" style="vertical-align: top; ">
                                                                    <dx:ASPxButton ID="cmdManageData" runat="server" Height="27px" Text="Data Management" Width="220px">
                                                                        <Image Url="~/COOPERP/images/document-excel-table.png">
                                                                        </Image>
                                                                    </dx:ASPxButton>
                                                                </td>
                                                                <td style="vertical-align: top;">
                                                                    <dx:ASPxButton ID="cmdReconcile" runat="server" Height="27px" Text="Reconciliation" Width="220px">
                                                                        <Image Url="~/COOPERP/images/tick-button.png">
                                                                        </Image>
                                                                    </dx:ASPxButton>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" style="vertical-align: top; text-align: left;">
                                                                    <dx:ASPxLabel ID="ASPxLabel1" runat="server" Font-Bold="True" ForeColor="Red" Text="BANK STATEMENT">
                                                                    </dx:ASPxLabel>
                                                                </td>
                                                                <td style="vertical-align: top; text-align: right;">
                                                                    <dx:ASPxLabel ID="ASPxLabel2" runat="server" Font-Bold="True" ForeColor="Red" Text="BANK LEDGER">
                                                                    </dx:ASPxLabel>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="vertical-align: top">
                                                                    <dx:ASPxGridView ID="gvBankStatementRecords" runat="server" AutoGenerateColumns="False" DataSourceID="dsBankTransactions" KeyFieldName="ID" Width="100%">
                                                                        <SettingsContextMenu Enabled="True">
                                                                        </SettingsContextMenu>
                                                                        <SettingsPager PageSize="500">
                                                                        </SettingsPager>
                                                                        <SettingsEditing Mode="Batch">
                                                                        </SettingsEditing>
                                                                        <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                                                        <SettingsBehavior AllowFocusedRow="True" />
                                                                        <SettingsSearchPanel Visible="True" />
                                                                        <Columns>
                                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Tracking No" FieldName="track_no" ShowInCustomizationForm="True" VisibleIndex="2" Visible="False">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataDateColumn Caption="Transaction Date" FieldName="trans_date" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                <PropertiesDateEdit DisplayFormatString="dd-MM-yyyy">
                                                                                </PropertiesDateEdit>
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataDateColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Particulars" FieldName="details" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="DR | CR" FieldName="trans_typ" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Balance" FieldName="Curr_Balance" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                                <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                                                </PropertiesTextEdit>
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Match TNO" FieldName="match_TID" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Reco SNo" FieldName="RecoID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                                <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                                                </PropertiesTextEdit>
                                                                                <EditFormSettings Visible="False" />
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" ShowClearFilterButton="True">
                                                                            </dx:GridViewCommandColumn>
                                                                        </Columns>
                                                                    </dx:ASPxGridView>
                                                                </td>
                                                                <td style="vertical-align: top;">
                                                                    <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" DataSourceID="dsJournalTransactions" KeyFieldName="TID" Width="100%">
                                                                        <SettingsPager PageSize="500">
                                                                        </SettingsPager>
                                                                        <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                                                        <SettingsBehavior AllowFocusedRow="True" />
                                                                        <SettingsSearchPanel Visible="True" />
                                                                        <Columns>
                                                                            <dx:GridViewDataTextColumn Caption="Date" FieldName="transactiondate" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="CR" FieldName="cramount" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="DR" FieldName="dramount" ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Balance" FieldName="curr_balance" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" VisibleIndex="9" Width="25px">
                                                                                <DataItemTemplate>
                                                                                    <asp:ImageButton ID="imgDetails1" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="imgDetails_Click" />
                                                                                </DataItemTemplate>
                                                                                <CellStyle HorizontalAlign="Center">
                                                                                </CellStyle>
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewDataTextColumn FieldName="voucherno" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                            </dx:GridViewDataTextColumn>
                                                                            <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" ShowClearFilterButton="True">
                                                                            </dx:GridViewCommandColumn>
                                                                            <dx:GridViewDataTextColumn Caption="Track No" FieldName="TID" ShowInCustomizationForm="True" VisibleIndex="1" Width="60px">
                                                                                <CellStyle HorizontalAlign="Left">
                                                                                </CellStyle>
                                                                            </dx:GridViewDataTextColumn>
                                                                        </Columns>
                                                                    </dx:ASPxGridView>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">
                                                        <dx:ASPxPopupControl ID="pop_managedata" runat="server" HeaderText="Manage Data" Modal="True" PopupElementID="cmdManageData" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                            <HeaderStyle HorizontalAlign="Center" />
                                                            <ContentCollection>
                                                                <dx:PopupControlContentControl runat="server">
                                                                    <table class="style1_rec">
                                                                        <tr>
                                                                            <td class="style2_rec"></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdImportStatement" runat="server" Height="27px" OnClick="cmdImportStatement_Click" Text="Import Bank Statement" Width="220px">
                                                                                    <Image Url="~/COOPERP/images/document-excel-table.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdClearBankData" runat="server" Height="27px" OnClick="cmdClearBankData_Click" Text="Clear Bank Data" Width="220px">
                                                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Delete Bank Statement Data?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                                                    <Image Url="~/COOPERP/images/minus-button.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdRefreshData" runat="server" Height="27px" OnClick="cmdRefreshData_Click" Text="Refresh Data" Width="220px">
                                                                                    <ClientSideEvents Click="function(s, e) {
	lp_loading.Show();

}" />
                                                                                    <Image Url="~/COOPERP/images/magnifier-zoom-fit.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="style3"></td>
                                                                        </tr>
                                                                    </table>
                                                                </dx:PopupControlContentControl>
                                                            </ContentCollection>
                                                        </dx:ASPxPopupControl>
                                                        <dx:ASPxPopupControl ID="pop_reconcile" runat="server" HeaderText="Reconciliation" Modal="True" PopupElementID="cmdReconcile" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                            <HeaderStyle HorizontalAlign="Center" />
                                                            <ContentCollection>
                                                                <dx:PopupControlContentControl runat="server">
                                                                    <table class="style1_rec">
                                                                        <tr>
                                                                            <td class="style2_rec"></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdMatch" runat="server" Height="27px" OnClick="cmdMatch_Click" Text="Auto-Reconcile" Width="220px">
                                                                                    <ClientSideEvents Click="function(s, e) {

e.processOnServer = confirm('Run Auto Reconciliation?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }
	}" />
                                                                                    <Image Url="~/COOPERP/images/wand.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdMatchSelected" runat="server" Height="27px" OnClick="cmdMatchSelected_Click" Text="Manual Reconcile Selected" Width="220px">
                                                                                    <ClientSideEvents Click="function(s, e) {

e.processOnServer = confirm('Run Manual Reconciliation?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdUnmatchMatch" runat="server" Height="27px" OnClick="cmdUnmatchMatch_Click" Text="Un-Reconcile Selected" Width="220px">
                                                                                    <ClientSideEvents Click="function(s, e) {

e.processOnServer = confirm('Unreconcile Selected Entries?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }
	}" />
                                                                                    <Image Url="~/COOPERP/images/minus-button.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdAdd_Adjustment" runat="server" Height="27px" OnClick="cmdAdd_Adjustment_Click" Text="Add Adjustments" Width="220px">
                                                                                    <Image Url="~/COOPERP/images/calculator--pencil.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdAdjustmentsData" runat="server" Height="27px" OnClick="cmdAdjustmentsData_Click" Text="View Adjustments" Width="220px">
                                                                                    <Image Url="~/COOPERP/images/clipboard-list.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
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
                                                    <td valign="top">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">
                                                        <dx:ASPxPopupControl ID="pop_adjustments" runat="server" HeaderText="Manage Adjustments" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" TabIndex="3" Width="450px">
                                                            <HeaderStyle HorizontalAlign="Center" />
                                                            <ContentCollection>
                                                                <dx:PopupControlContentControl runat="server">
                                                                    <table class="style1_rec">
                                                                        <tr>
                                                                            <td class="style2_rec">
                                                                                <br />
                                                                                <br />
                                                                                <br />
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxLabel ID="lbl_adjustments" runat="server" Font-Bold="True" ForeColor="Red">
                                                                                </dx:ASPxLabel>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">&nbsp;</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxComboBox ID="txtAdjustmentCategory" runat="server" Width="220px">
                                                                                    <Items>
                                                                                        <dx:ListEditItem Text="Uncredited Deposits" Value="Uncredited Deposits" />
                                                                                        <dx:ListEditItem Text="Unpresented Cheques" Value="Unpresented Cheques" />
                                                                                        <dx:ListEditItem Text="Direct Debits" Value="Direct Debits" />
                                                                                        <dx:ListEditItem Text="Direct Credits" Value="Direct Credits" />
                                                                                    </Items>
                                                                                    <Paddings PaddingLeft="5px" />
                                                                                </dx:ASPxComboBox>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">
                                                                                <dx:ASPxButton ID="cmdAddNewAdjustments" runat="server" Height="27px" OnClick="cmdAddNewAdjustments_Click" Text="Add Adjustments" Width="220px">
                                                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Delete Bank Statement Data?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                                                    </Image>
                                                                                </dx:ASPxButton>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="center">&nbsp;</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="style3"></td>
                                                                        </tr>
                                                                    </table>
                                                                </dx:PopupControlContentControl>
                                                            </ContentCollection>
                                                        </dx:ASPxPopupControl>
                                                    </td>
                                                    <td valign="top">&nbsp;</td>
                                                </tr>
                                            </table>
                                        </dx:ContentControl>
                                    </ContentCollection>
                                </dx:TabPage>
                            </TabPages>
                        </dx:ASPxPageControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsPayeeAccounts" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetPayeeAccountsTableAdapter">
                            <SelectParameters>
                                <asp:Parameter DefaultValue="Bank" Name="typ" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetRecoLedgerTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtPayee" Name="accno" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                                <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                                <asp:Parameter DefaultValue="Chart Account" Name="typ" Type="String" />
                                <asp:ControlParameter ControlID="txtStatus" Name="cat" PropertyName="Value" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsReconciliations" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetBankReconciliations" TypeName="CoopERPDataTableAdapters.fin_reconciliationstatementTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="rec_date" Type="DateTime" />
                                <asp:Parameter Name="last_rec_balance" Type="Double" />
                                <asp:Parameter Name="statement_date" Type="DateTime" />
                                <asp:Parameter Name="statement_balance" Type="Double" />
                                <asp:Parameter Name="rec_status" Type="String" />
                                <asp:Parameter Name="bank_code" Type="String" />
                                <asp:Parameter Name="title" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtPayee" Name="bank_code" PropertyName="Value" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="rec_date" Type="DateTime" />
                                <asp:Parameter Name="last_rec_balance" Type="Double" />
                                <asp:Parameter Name="statement_date" Type="DateTime" />
                                <asp:Parameter Name="statement_balance" Type="Double" />
                                <asp:Parameter Name="rec_status" Type="String" />
                                <asp:Parameter Name="bank_code" Type="String" />
                                <asp:Parameter Name="title" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsSingleReconciliations" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSingleStatement" TypeName="CoopERPDataTableAdapters.fin_reconciliationstatementTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="rec_date" Type="DateTime" />
                                <asp:Parameter Name="last_rec_balance" Type="Double" />
                                <asp:Parameter Name="statement_date" Type="DateTime" />
                                <asp:Parameter Name="statement_balance" Type="Double" />
                                <asp:Parameter Name="rec_status" Type="String" />
                                <asp:Parameter Name="bank_code" Type="String" />
                                <asp:Parameter Name="title" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtStatement" Name="ID" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="rec_date" Type="DateTime" />
                                <asp:Parameter Name="last_rec_balance" Type="Double" />
                                <asp:Parameter Name="statement_date" Type="DateTime" />
                                <asp:Parameter Name="statement_balance" Type="Double" />
                                <asp:Parameter Name="rec_status" Type="String" />
                                <asp:Parameter Name="bank_code" Type="String" />
                                <asp:Parameter Name="title" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsBankTransactions" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetBankRecoStatementData" TypeName="CoopERPDataTableAdapters.fin_reco_bank_entriesTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="track_no" Type="String" />
                                <asp:Parameter Name="trans_date" Type="String" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="trans_typ" Type="String" />
                                <asp:Parameter Name="Curr_Balance" Type="String" />
                                <asp:Parameter Name="match_TID" Type="UInt32" />
                                <asp:Parameter Name="RecoID" Type="UInt32" />
                                <asp:Parameter Name="amount" Type="Double" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtStatus" Name="cat" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtStatement" Name="RID" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="track_no" Type="String" />
                                <asp:Parameter Name="trans_date" Type="String" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="trans_typ" Type="String" />
                                <asp:Parameter Name="Curr_Balance" Type="String" />
                                <asp:Parameter Name="match_TID" Type="UInt32" />
                                <asp:Parameter Name="RecoID" Type="UInt32" />
                                <asp:Parameter Name="amount" Type="Double" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table class="style1_rec">
                                        <tr>
                                            <td class="style2_rec"></td>
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
                        <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Modal="True" Text="Processing&amp;hellip;">
                        </dx:ASPxLoadingPanel>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>