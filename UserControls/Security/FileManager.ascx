<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FileManager.ascx.cs" Inherits="UserControls_Security_FileManager" %>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="System File Management Platform" ShowHeader="False" Width="100%">
    <HeaderImage IconID="actions_open_16x16">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server">
    <dx:ASPxFileManager ID="fm_systemfiles" runat="server" OnFileUploading="ASPxFileManager1_FileUploading">
        <Settings RootFolder="~/" ThumbnailFolder="~/Thumb/" EnableMultiSelect="True" />
        <SettingsFileList ShowFolders="True" ShowParentFolder="True">
        </SettingsFileList>
        <SettingsEditing AllowCopy="True" AllowCreate="True" AllowDelete="True" AllowDownload="True" AllowMove="True" AllowRename="True" />
        <SettingsFolders HideAspNetFolders="False" />
        <SettingsUpload>
            <AdvancedModeSettings EnableMultiSelect="True">
            </AdvancedModeSettings>
        </SettingsUpload>
    </dx:ASPxFileManager>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

