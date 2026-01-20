<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SchoolPayDatal.ascx.cs" Inherits="UserControls_financials_SchoolPayDatal" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
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


    .ledger_style2
    {
        width: 52px;
    }
    .style4
    {
        width: 174px;
    }
    .auto-style3 {
        width: 64px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Student Legder Centre" Width="100%" ShowHeader="False">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table id="table1" cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_schoolpaydata.png" >
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style3">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style3">
                            From:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" Height="35px" Width="200px" DisplayFormatString="dd MMMM, yyyy">
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdCapture" runat="server" Height="35px" Text="Recapture Selected" Width="200px" OnClick="cmdCapture_Click">
                                <ClientSideEvents Click="function(s, e) {
	lp_processing.Show();
}" />
                                <Image IconID="content_checkbox_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style3">To:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" DisplayFormatString="dd MMMM, yyyy" Height="35px" Width="200px">
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdExportData" runat="server" Height="35px" OnClick="cmdExportData_Click" Text="Export to Excel" Width="200px">
                                <ClientSideEvents Click="function(s, e) {
	}" />
                                <Image IconID="export_exporttoxlsx_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style3">Status:</td>
                        <td class="style4">
                            <dx:ASPxComboBox ID="txtStatus" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="1" Width="200px">
                                <Items>
                                    <dx:ListEditItem Text="Captured" Value="Captured" />
                                    <dx:ListEditItem Selected="True" Text="Pending" Value="Pending" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdRefreshData" runat="server" Enabled="True" Height="35px" OnClick="cmdExportData_Click" Text="Reload Data" Width="200px">
                                <ClientSideEvents Click="function(s, e) {
	lp_processing.Show();
}" />
                                <Image IconID="actions_fill_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvSchoolPayList" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsSchoolPay" KeyFieldName="ReceiptNo" Width="100%" OnHtmlDataCellPrepared="gvStudentList_HtmlDataCellPrepared" ClientInstanceName="gvSchoolPayList">
                    <SettingsSearchPanel Visible="True" />
                    <Settings ShowFooter="True" />
                    <SettingsBehavior AllowFocusedRow="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ReceiptNo" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="150px">
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Registration No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Date Paid" FieldName="datePaid" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Payment Channel" FieldName="channelPaid" ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount_paid" ShowInCustomizationForm="True" VisibleIndex="6" Width="150px">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                            <HeaderStyle HorizontalAlign="Right" />
                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                            </FooterCellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_name" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Status" FieldName="captureStatus" ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <TotalSummary>
                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="amount_paid" ShowInColumn="Amount" ShowInGroupFooterColumn="Amount" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                    </TotalSummary>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsSchoolPay" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetTransactionsByDate" 
                    TypeName="StudentAccountingDataTableAdapters.fin_schoolpaydataTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ReceiptNo" Type="UInt64" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="ReceiptNo" Type="UInt64" />
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="datePaid" Type="DateTime" />
                        <asp:Parameter Name="channelPaid" Type="String" />
                        <asp:Parameter Name="amount_paid" Type="Double" />
                        <asp:Parameter Name="stud_name" Type="String" />
                        <asp:Parameter Name="captureStatus" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtStatus" Name="stat" PropertyName="Value" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="datePaid" Type="DateTime" />
                        <asp:Parameter Name="channelPaid" Type="String" />
                        <asp:Parameter Name="amount_paid" Type="Double" />
                        <asp:Parameter Name="stud_name" Type="String" />
                        <asp:Parameter Name="captureStatus" Type="String" />
                        <asp:Parameter Name="Original_ReceiptNo" Type="UInt64" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxGridViewExporter ID="GVE_SchoolPay" runat="server" ExportedRowType="All" GridViewID="gvSchoolPayList">
                </dx:ASPxGridViewExporter>
                <dx:ASPxLoadingPanel ID="lp_processing" runat="server" ClientInstanceName="lp_processing" Modal="True" Text="Processing...">
                    <LoadingDivStyle BackColor="#3399FF">
                    </LoadingDivStyle>
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" CloseAction="CloseButton" 
                    ContentUrl="~/COOPERP/financials/billitems.aspx" HeaderText="" Modal="True" 
                    PopupElementID="btn_billitems" PopupHorizontalAlign="WindowCenter" 
                    PopupVerticalAlign="WindowCenter">
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server" SupportsDisabledAttribute="True">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                            <table class="style1">
                                <tr>
                                    <td>
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" ForeColor="#0033CC" style="font-weight: 700;">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3">
                                        <br />
                                        <br />
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
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>