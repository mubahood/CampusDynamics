<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentLedgerCentre.ascx.cs" Inherits="UserControls_financials_StudentLedgerCentre" %>
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
    .auto-style1 {
        width: 132px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Student Legder Centre" Width="100%" ShowHeader="False">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table id="table1" cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_studentledgers.png" >
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
                        <td class="auto-style1">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Search:</td>
                        <td class="style4">
                            <dx:ASPxTextBox ID="txtSearch" runat="server" AutoPostBack="True" Height="35px" NullText="Enter Name or Reg No" Width="200px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxTextBox>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdSearch" runat="server" OnClick="cmdSearch_Click" Text="Find" Width="80px" Height="35px">
                                <Image Url="~/COOPERP/images/magnifier.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">
                            Start Date:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" Height="35px" Width="200px" DisplayFormatString="dd MMMM, yyyy">
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">
                            End Date:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" Height="35px" Width="200px" DisplayFormatString="dd MMMM, yyyy">
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvStudentList" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsStudentList" KeyFieldName="regno" Width="100%" OnHtmlDataCellPrepared="gvStudentList_HtmlDataCellPrepared">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" ShowClearFilterButton="True"/>
                        <dx:GridViewDataTextColumn Caption="Student No" FieldName="regno" 
                            ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2" Width="150px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_names" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Study Details" FieldName="details" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Ledgers" ShowInCustomizationForm="True" 
                            VisibleIndex="5" Width="25px">
                            <DataItemTemplate>
                                <asp:ImageButton ID="cmdLedger" runat="server" 
                                    ImageUrl="~/COOPERP/images/clipboard-invoice.png" onclick="cmdLedger_Click" 
                                    onclientclick="lp_loading.Show();" />
                                <dx:ASPxLoadingPanel ID="lp_loading" runat="server" 
                                    ClientInstanceName="lp_loading" Modal="True">
                                </dx:ASPxLoadingPanel>
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Reg No" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="1" Width="150px">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsStudentList" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="StudentAccountingDataTableAdapters.fin_StudentLedgerSearchTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtSearch" DefaultValue="%" Name="reg" 
                            PropertyName="Text" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" CloseAction="CloseButton" 
                    ContentUrl="~/COOPERP/financials/billitems.aspx" HeaderText="" Modal="True" 
                    PopupElementID="btn_billitems" PopupHorizontalAlign="WindowCenter" 
                    PopupVerticalAlign="WindowCenter">
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

