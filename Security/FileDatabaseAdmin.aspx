<%@ Page Title="" Language="C#" MasterPageFile="~/Security/MasterPage.master" AutoEventWireup="true" CodeFile="FileDatabaseAdmin.aspx.cs" Inherits="Security_FileDatabaseAdmin" %>

<%@ Register src="../UserControls/Security/FileManager.ascx" tagname="FileManager" tagprefix="uc1" %>
<%@ Register src="../UserControls/Security/DatabaseManager.ascx" tagname="DatabaseManager" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <table class="style1">
                <tr>
                    <td>
                        <table cellspacing="0" class="style1" cellpadding="0">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_file_db_centre.png">
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
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <table class="style1">
                            <tr>
                                <td>
                                    <table class="style1">
                                        <tr>
                                            <td width="50%" valign="top">&nbsp;</td>
                                            <td valign="top">&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                                        <TabPages>
                                            <dx:TabPage Text=" File Administration">
                                                <TabImage IconID="actions_open_16x16">
                                                </TabImage>
                                                <ContentCollection>
                                                    <dx:ContentControl runat="server">
                                                        <uc1:FileManager ID="FileManager1" runat="server" />
                                                    </dx:ContentControl>
                                                </ContentCollection>
                                            </dx:TabPage>
                                            <dx:TabPage Text=" Database Administration">
                                                <TabImage IconID="data_database_16x16">
                                                </TabImage>
                                                <ContentCollection>
                                                    <dx:ContentControl runat="server">
                                                        <uc2:DatabaseManager ID="DatabaseManager1" runat="server" />
                                                    </dx:ContentControl>
                                                </ContentCollection>
                                            </dx:TabPage>
                                        </TabPages>
                                    </dx:ASPxPageControl>
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
</asp:Content>

