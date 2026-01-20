<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DocumentCentre.ascx.cs" Inherits="UserControls_Accounts_DocumentCentre" %>
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


    .style9
    {
    }
    .style10
    {
        width: 81px;
    }
    .style11
    {
        width: 225px;
    }
    .style12
    {
        width: 95px;
    }
    .auto-style1 {
        width: 90px;
    }
    .auto-style3 {
        width: 200px;
    }
    .auto-style4 {
        width: 71px;
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
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_documents.png">
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
                        <td class="auto-style1">
                            Document:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtDocumentType" runat="server" AutoPostBack="True" 
                                EnableIncrementalFiltering="True" IncrementalFilteringMode="StartsWith" 
                                SelectedIndex="1" ValueType="System.String">
                                <Items>
                                    <dx:ListEditItem Text="Trial Balance" Value="Trial Balance" />
                                    <dx:ListEditItem Selected="True" Text="Income Statement" 
                                        Value="Income Statement" />
                                    <dx:ListEditItem Text="Balance Sheet" Value="Balance Sheet" />
                                    <dx:ListEditItem Text="Payments" Value="Payments" />
                                    <dx:ListEditItem Text="Defaulters" Value="Defaulters" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style4">
                            Start Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server">
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">
                            Month:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtMonth" runat="server" AutoPostBack="True" 
                                EnableIncrementalFiltering="True" IncrementalFilteringMode="StartsWith" 
                                ValueType="System.String">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style4">
                            End Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server">
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">
                            Year:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtYear" runat="server" AutoPostBack="True" 
                                EnableIncrementalFiltering="True" IncrementalFilteringMode="StartsWith" 
                                ValueType="System.String">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style4">
                            &nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" 
                                Text="Print" Width="170px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">
                            &nbsp;</td>
                        <td class="auto-style3">
                            <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red">
                            </dx:ASPxLabel>
                        </td>
                        <td class="auto-style4">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">
                            &nbsp;</td>
                        <td class="style9" colspan="3">
                            &nbsp;</td>
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
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_receipts" runat="server" HeaderText="" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    ContentUrl="~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsProducts" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_productsTableAdapter">
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>



