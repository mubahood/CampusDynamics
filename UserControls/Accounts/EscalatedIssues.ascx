<%@ Control Language="C#" AutoEventWireup="true" CodeFile="EscalatedIssues.ascx.cs" Inherits="UserControls_Accounts_EscaletedIssues" %>
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


    .style12
    {
        height: 18px;
    }
    .style21
    {
        width: 93px;
    }
    .style18
    {
        width: 88px;
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
                                ImageUrl="~/COOPERP/images/header_accountsEscalations.png">
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
            <td class="style12">
                </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="style21">
                            Log Start Date:</td>
                        <td class="style18">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style21">
                            Log End Date:</td>
                        <td class="style18">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td>
                            &nbsp;</td>
                        <td align="right">
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvVouchers" runat="server" AutoGenerateColumns="False" 
                    ClientInstanceName="gvVouchers" DataSourceID="dsLogs" 
                    KeyFieldName="logid" Width="100%" OnHtmlDataCellPrepared="gvVouchers_HtmlDataCellPrepared">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="user_id" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="50px" 
                            Caption="User">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="page_function" ShowInCustomizationForm="True" 
                            VisibleIndex="3" Caption="Category">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="par" 
                            ShowInCustomizationForm="True" VisibleIndex="5" Caption="Details" 
                            Width="500px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="comments" 
                            ShowInCustomizationForm="True" VisibleIndex="4" Caption="Transaction">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Date" FieldName="access_date" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="150px">
                            <PropertiesDateEdit DisplayFormatString="dd/MM/yyy H:mm:ss">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn FieldName="logid" ShowInCustomizationForm="True" 
                            VisibleIndex="0" Caption="SNo" ReadOnly="True" Width="40px">
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ClientSideEvents CloseUp="function(s, e) {
	gvVouchers.Refresh();
}" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsLogs" runat="server" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.acc_activity_logTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtStartDate" Name="startDate" 
                            PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtEndDate" Name="endDate" 
                            PropertyName="Value" Type="DateTime" />
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







