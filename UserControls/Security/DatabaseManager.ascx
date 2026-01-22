<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DatabaseManager.ascx.cs" Inherits="UserControls_Security_DatabaseManager" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

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
        width: 243px;
    }
        

           

    .auto-style2 {
    }
    .auto-style3 {
        width: 263px;
    }
    .auto-style4 {
        width: 256px;
    }
        

           

</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%" Theme="Office2010Blue">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td>
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
                <dx:ASPxMemo ID="txtCommand" runat="server" Height="150px" Width="100%" 
                    Font-Size="Medium" HorizontalAlign="Left" NullText="Enter any SQL command (SELECT, INSERT, UPDATE, DELETE, DROP, CREATE, ALTER, TRUNCATE, etc.) and click &quot;Execute Command&quot;" Theme="Office2010Blue" style="text-align: left">
                    <RootStyle VerticalAlign="Top">
                    </RootStyle>
                </dx:ASPxMemo>
            </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style2">
                            &nbsp;</td>
                        <td class="auto-style4">
                            &nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td colspan="3" align="Center">
                            <dx:ASPxButton ID="cmdAddNew" runat="server" Height="35px" OnClick="cmdAddNew_Click" Text="Execute Command" Theme="Office2010Blue" Width="250px">
                                <image iconid="actions_apply_16x16">
                                </image>
                            </dx:ASPxButton>
                            <dx:ASPxButton ID="cmdClear" runat="server" Height="35px" OnClick="cmdClear_Click" Text="Clear Command" Theme="Office2010Blue" Width="250px">
                                <image iconid="actions_clear_16x16">
                                </image>
                            </dx:ASPxButton>
                            <dx:ASPxButton ID="cmdClear0" runat="server" Height="35px" Text="Command History" Theme="Office2010Blue" Width="250px" OnClick="cmdClear0_Click">
                                <image iconid="history_historyitem_16x16">
                                </image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">&nbsp;</td>
                        <td class="auto-style4">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvDataset" runat="server" 
                    Width="100%" ViewStateMode="Disabled" Theme="Office2010Blue" AutoGenerateColumns="True">
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" AllowSort="True" 
                        ColumnResizeMode="Control" />
                    <SettingsPager Mode="ShowAllRecords" PageSize="1000">
                    </SettingsPager>
                    <Settings ShowHorizontalScrollBar="True" ShowStatusBar="Visible" 
                        ShowVerticalScrollBar="True" UseFixedTableLayout="False" 
                        ShowGroupPanel="False" ShowFilterRow="False" />
                    <SettingsExport EnableClientSideExportAPI="True" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" 
                    HeaderText="Database Manager" Height="150px" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="400px" CloseAction="CloseButton" Modal="True" Theme="Office2010Blue" ClientInstanceName="pop_messagebox">
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
                                        <dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red" 
                                            >
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


