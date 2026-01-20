<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ExcellDataLoader.aspx.cs" Inherits="COOPERP_accounts_ExcellDataLoader" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
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

    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <table id="table1" class="dx-justification">
            <tr>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td>
                    <dx:ASPxPageControl ID="PC_Data" runat="server" ActiveTabIndex="0" Width="100%">
                        <TabPages>
                            <dx:TabPage Text="Data Processing">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <table id="table2" class="dxeBinImgCPnlSys">
                                            <tr>
                                                <td>
                                                    <dx:ASPxButton ID="cmdLoadData" runat="server" Height="27px" OnClick="cmdLoadData_Click" Text="Upload Statement Data" Width="180px">
                                                        <ClientSideEvents Click="function(s, e) {
lp_dataloading.Show();	
}" />
                                                        <Image Url="~/COOPERP/images/fill-090.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                    <dx:ASPxLoadingPanel ID="lp_dataloading" runat="server" ClientInstanceName="lp_dataloading" Modal="True" Text="Loading Data&amp;hellip;">
                                                    </dx:ASPxLoadingPanel>
                                                </td>
                                            </tr>
                                        </table>
                                        <dx:ASPxSpreadsheet ID="ES_BankData" runat="server" Height="450px" RibbonMode="OneLineRibbon" Width="100%">
                                        </dx:ASPxSpreadsheet>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="Document Uploader">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <dx:ASPxFileManager ID="FMDocs" runat="server" Height="300px">
                                            <Settings RootFolder="~/App_Data/WorkDirectory" ThumbnailFolder="~/Thumb/" />
                                            <SettingsEditing AllowCopy="True" AllowCreate="True" AllowDelete="True" AllowDownload="True" AllowMove="True" AllowRename="True" />
                                            <SettingsUpload AutoStartUpload="True">
                                                <AdvancedModeSettings EnableMultiSelect="True">
                                                </AdvancedModeSettings>
                                            </SettingsUpload>
                                        </dx:ASPxFileManager>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                    </dx:ASPxPageControl>
                    <br />
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
        </table>
    
    </div>
    </form>
</body>
</html>
