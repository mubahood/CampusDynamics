<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PhotoLoader.ascx.cs" Inherits="UserControls_StudentInfo_PhotoLoader" %>
<style type="text/css">
    .auto-style1 {
        width: 100%;
    }
    .auto-style2 {
        width: 81px;
    }
    .auto-style3 {
        width: 181px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Photo Loader Platform" ShowCollapseButton="true" Width="100%">
    <HeaderStyle HorizontalAlign="Center">
    <Paddings Padding="10px" />
    </HeaderStyle>
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <table class="auto-style1">
                    <tr>
                        <td class="auto-style2">Photo Type:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtDocType" runat="server" Height="35px" SelectedIndex="1">
                                <Items>
                                    <dx:ListEditItem Text="Signature" Value="B" />
                                    <dx:ListEditItem Selected="True" Text="Photo" Value="P" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdSavePhotos" runat="server" Height="35px" OnClick="cmdSavePhotos_Click" Text="Save Photos" Width="170px">
                                <Image IconID="mail_contact_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvStudentPhoto" runat="server" AutoGenerateColumns="False" DataSourceID="dsPhotoList" KeyFieldName="docbioid" OnHtmlDataCellPrepared="gvStudentPhoto_HtmlDataCellPrepared" Width="100%">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="docbioid" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="doccode" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="docfiletype" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="dochttpfiletype" ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="docdate" ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn FieldName="docuser" ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="docfilename" ShowInCustomizationForm="True" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="docvalidity" ShowInCustomizationForm="True" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataBinaryImageColumn Caption="Stud Photo" FieldName="docblob" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2" Width="50px">
                            <PropertiesBinaryImage ImageWidth="50px">
                                <EditingSettings Enabled="True">
                                </EditingSettings>
                            </PropertiesBinaryImage>
                        </dx:GridViewDataBinaryImageColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsPhotoList" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.stddocTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_docbioid" Type="String" />
                        <asp:Parameter Name="Original_doccode" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="docbioid" Type="String" />
                        <asp:Parameter Name="doccode" Type="String" />
                        <asp:Parameter Name="docfiletype" Type="String" />
                        <asp:Parameter Name="dochttpfiletype" Type="String" />
                        <asp:Parameter Name="docdate" Type="DateTime" />
                        <asp:Parameter Name="docuser" Type="String" />
                        <asp:Parameter Name="docblob" Type="Object" />
                        <asp:Parameter Name="docfilename" Type="String" />
                        <asp:Parameter Name="docblob2" Type="Object" />
                        <asp:Parameter Name="docblob3" Type="Object" />
                        <asp:Parameter Name="docvalidity" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtDocType" Name="code" PropertyName="Value" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="docfiletype" Type="String" />
                        <asp:Parameter Name="dochttpfiletype" Type="String" />
                        <asp:Parameter Name="docdate" Type="DateTime" />
                        <asp:Parameter Name="docuser" Type="String" />
                        <asp:Parameter Name="docblob" Type="Object" />
                        <asp:Parameter Name="docfilename" Type="String" />
                        <asp:Parameter Name="docblob2" Type="Object" />
                        <asp:Parameter Name="docblob3" Type="Object" />
                        <asp:Parameter Name="docvalidity" Type="String" />
                        <asp:Parameter Name="Original_docbioid" Type="String" />
                        <asp:Parameter Name="Original_doccode" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

