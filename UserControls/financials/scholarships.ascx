<%@ Control Language="C#" AutoEventWireup="true" CodeFile="scholarships.ascx.cs" Inherits="UserControls_financials_scholarships" %>
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


    </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Bursaries &amp; Scholarships" Width="100%" ShowHeader="False">
            <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table id="table1" cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center;">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_sponsorInfo.png">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  Width="100%">
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
                <dx:ASPxButton ID="cmdNew" runat="server" Height="35px" OnClick="cmdNew_Click" Text="Add Sponsor" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvScholarships" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsScholarships" KeyFieldName="scholarshipID" Width="100%" OnHtmlDataCellPrepared="gvScholarships_HtmlDataCellPrepared">
                    <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                    </SettingsEditing>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsCommandButton><UpdateButton RenderMode="Button"></UpdateButton><CancelButton RenderMode="Button"></CancelButton>
                        <EditButton>
                            <Image Url="~/COOPERP/images/clipboard--pencil.png">
                            </Image>
                        </EditButton>
                        <DeleteButton>
                            <Image Url="~/icons/delete.png">
                            </Image>
                        </DeleteButton>
                    </SettingsCommandButton>
                    <SettingsPopup>
                        <EditForm HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" />
                    </SettingsPopup>
                    <SettingsSearchPanel Visible="True" />
                    <SettingsText CommandCancel="Cancel Changes" CommandUpdate="Update Changes" />
                    <EditFormLayoutProperties>
                        <Items>
                            <dx:GridViewLayoutGroup Caption="Sponsor Information">
                                <Items>
                                    <dx:EmptyLayoutItem>
                                    </dx:EmptyLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="scholarshipName" Height="35px">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="scholarshipdetails" Height="35px">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="percentagePay" Height="35px">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:EmptyLayoutItem>
                                    </dx:EmptyLayoutItem>
                                    <dx:EditModeCommandLayoutItem Height="35px" HorizontalAlign="Right">
                                    </dx:EditModeCommandLayoutItem>
                                </Items>
                            </dx:GridViewLayoutGroup>
                        </Items>
                    </EditFormLayoutProperties>
                    <Columns>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" ShowClearFilterButton="True"/>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="scholarshipID" 
                            ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="35px">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Sponsor Name" FieldName="scholarshipName" 
                            ShowInCustomizationForm="True" VisibleIndex="2">
                            <PropertiesTextEdit Height="35px">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Details" FieldName="scholarshipdetails" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                            <PropertiesTextEdit Height="35px">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="% Payable" FieldName="percentagePay" 
                            ShowInCustomizationForm="True" VisibleIndex="4" Width="150px">
                            <PropertiesTextEdit Height="35px">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="5" Width="25px" ShowEditButton="True" ShowClearFilterButton="True" ButtonRenderMode="Image"/>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsScholarships" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="StudentAccountingDataTableAdapters.scholarshipsTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_scholarshipID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="scholarshipName" Type="String" />
                        <asp:Parameter Name="scholarshipdetails" Type="String" />
                        <asp:Parameter Name="percentagePay" Type="Double" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="scholarshipName" Type="String" />
                        <asp:Parameter Name="scholarshipdetails" Type="String" />
                        <asp:Parameter Name="percentagePay" Type="Double" />
                        <asp:Parameter Name="Original_scholarshipID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
