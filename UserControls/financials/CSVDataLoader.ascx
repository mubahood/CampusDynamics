<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CSVDataLoader.ascx.cs" Inherits="UserControls_financials_CSVDataLoader" %>
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
    .auto-style2 {
        width: 106px;
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
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_csv_data.png" >
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
                        <td class="auto-style2">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style2">Load Data:</td>
                        <td class="style4">
                            <dx:ASPxButton ID="cmdPickFile" runat="server" Height="35px" OnClick="cmdPickFile_Click" Text="Upload Data File" Width="200px">
                                <Image IconID="navigation_up_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdClearData" runat="server" Height="35px" Text="Clear Data" Width="200px">
                                <Image IconID="actions_clear_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style2">
                            Cature Date:</td>
                        <td class="style4">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" Height="35px" Width="200px">
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdCapture" runat="server" Height="35px" Text="Capture Selected" Width="200px" OnClick="cmdCapture_Click">
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
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvStudentList" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsStudentList" KeyFieldName="regno" Width="100%" OnHtmlDataCellPrepared="gvStudentList_HtmlDataCellPrepared">
                    <SettingsSearchPanel Visible="True" />
                    <Settings ShowFilterRow="True" />
                    <SettingsBehavior AllowFocusedRow="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="Registration No" FieldName="regno" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_name" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="balance" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="AllPages" ShowClearFilterButton="True" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Capture Status" FieldName="capture_status" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="Pending" Value="Pending" />
                                    <dx:ListEditItem Text="Captured" Value="Captured" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsStudentList" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="StudentAccountingDataTableAdapters.fin_temp_balanceTableAdapter" DeleteMethod="Delete">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_regno" Type="String" />
                    </DeleteParameters>
                </asp:ObjectDataSource>
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
                        <dx:PopupControlContentControl runat="server">
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
                <dx:ASPxPopupControl ID="pop_uploader" runat="server" CloseAction="CloseButton" HeaderText="" Modal="True" PopupElementID="btn_billitems" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:FileUpload ID="FileUpload1" runat="server" Height="35px" Width="100%" CssClass="dxbButton" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxButton ID="cmdLoadData" runat="server" Height="35px" OnClick="cmdSearch_Click" Text="Upload Data File" Width="100%">
                                            <Image IconID="navigation_up_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="text-align: center">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align: center">
                                        <asp:Label ID="lbl_comment" runat="server" Font-Bold="True" ForeColor="#0033CC"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
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