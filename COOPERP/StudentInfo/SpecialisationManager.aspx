<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SpecialisationManager.aspx.cs" Inherits="COOPERP_StudentInfo_SpecialisationManager" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
    .style1
    {
        width: 100%;
    }
     </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Specialisations" ShowCollapseButton="true" Width="100%">
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="style1">
        <tr>
            <td>
                <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Add New" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvSpecialisations" runat="server" AutoGenerateColumns="False" DataSourceID="dsSpecialisations" KeyFieldName="ID" Width="100%">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Specialisation" FieldName="specialisation" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="3" Width="45px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="1" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsSpecialisations" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_specialisationsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="specialisation" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="specialisation" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
