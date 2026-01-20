<%@ Control Language="C#" AutoEventWireup="true" CodeFile="subjectcoverage.ascx.cs" Inherits="UserControls_HumanResource_TeachingCentre_subjectcoverage" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style4
    {
        width: 35px;
    }
    .style6
    {
        width: 180px;
    }
    .style7
    {
        width: 217px;
    }
    </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="style1">
        <tr>
            <td>
               <table class="style1">
                            <tr>
                                <td colspan="4">
                                    <table cellpadding="0" cellspacing="0" class="style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxImage ID="ASPxImage2" runat="server" 
                                                    ImageUrl="~/COOPERP/images/header_subjectcoverage.png" ShowLoadingImage="True">
                                                </dx:ASPxImage>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxImage ID="ASPxImage1" runat="server" Height="1px" 
                                                    ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="True" Width="100%">
                                                </dx:ASPxImage>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td class="style4">
                                    &nbsp;</td>
                                <td class="style7">
                                    &nbsp;</td>
                                <td class="style4">
                                    &nbsp;</td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td class="style4">
                                    <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Year">
                                    </dx:ASPxLabel>
                                </td>
                                <td class="style7">
                                    <dx:ASPxComboBox ID="txtyr" runat="server" AutoPostBack="True" 
                                        OnSelectedIndexChanged="txtClass_SelectedIndexChanged" 
                                        Width="200px">
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="style4">
                                    <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text="Term">
                                    </dx:ASPxLabel>
                                </td>
                                <td>
                                    <dx:ASPxComboBox ID="txtTerm" runat="server" AutoPostBack="True" 
                                        SelectedIndex="0" ValueType="System.Int32" Width="100px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="style4">
                                    &nbsp;</td>
                                <td class="style7">
                                    &nbsp;</td>
                                <td class="style4">
                                    &nbsp;</td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td  colspan="4">
                                    <dx:ASPxGridView ID="gvAllocations" runat="server" AutoGenerateColumns="False" 
                                        DataSourceID="dscoverage" KeyFieldName="ID" Width="100%">
                                        <Columns>
                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="CurrentYear" 
                                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="Term" ShowInCustomizationForm="True" 
                                                Visible="False" VisibleIndex="3" ReadOnly="True">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Subject Code" FieldName="subcode" 
                                                ShowInCustomizationForm="True" VisibleIndex="7" Width="100px" 
                                                ReadOnly="True">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="EmpCode" ShowInCustomizationForm="True" 
                                                Visible="False" VisibleIndex="9">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Paper" FieldName="paper" 
                                                ShowInCustomizationForm="True" VisibleIndex="10" Width="30px" 
                                                ReadOnly="True">
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Subject" FieldName="subcode" 
                                                ShowInCustomizationForm="True" VisibleIndex="8" 
                                                ReadOnly="True">
                                                <PropertiesComboBox DataSourceID="dsSubjects" TextField="subname" 
                                                    TextFormatString="{0}" ValueField="subcode" ValueType="System.String">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Subject" FieldName="subname" />
                                                    </Columns>
                                                    <Items>
                                                        <dx:ListEditItem Text="YEAR 7" Value="7" />
                                            <dx:ListEditItem Text="YEAR 8" Value="8" />
                                            <dx:ListEditItem Text="YEAR 9" Value="9" />
                                            <dx:ListEditItem Text="YEAR 10" Value="10" />
                                            <dx:ListEditItem Text="YEAR 11" Value="11" />
                                            <dx:ListEditItem Text="YEAR 12" Value="12" />
                                            <dx:ListEditItem Text="YEAR 13" Value="13" />
                                       
                                                    </Items>
                                                </PropertiesComboBox>
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewCommandColumn 
                                                ShowInCustomizationForm="True" VisibleIndex="16" Width="150px" 
                                                ShowEditButton="True">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Class" FieldName="SubjectClass" 
                                                ShowInCustomizationForm="True" VisibleIndex="6" Width="60px">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataTextColumn FieldName="Class" 
                                                ShowInCustomizationForm="True" VisibleIndex="5" ReadOnly="True" 
                                                Visible="False">
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataMemoColumn Caption="Mid Term Coverage" FieldName="workdone" 
                                                ShowInCustomizationForm="True" VisibleIndex="14">
                                                <PropertiesMemoEdit Rows="5">
                                                </PropertiesMemoEdit>
                                            </dx:GridViewDataMemoColumn>
                                            <dx:GridViewDataTextColumn Caption="Mid Weight" FieldName="weight" 
                                                ShowInCustomizationForm="True" VisibleIndex="12" Width="60px">
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataMemoColumn Caption="End Term Coverage" FieldName="workdone_end" ShowInCustomizationForm="True" VisibleIndex="15">
                                                <PropertiesMemoEdit Rows="5">
                                                </PropertiesMemoEdit>
                                            </dx:GridViewDataMemoColumn>
                                            <dx:GridViewDataTextColumn Caption="EOT Weight" FieldName="weight_end" ShowInCustomizationForm="True" VisibleIndex="13" Width="60px">
                                            </dx:GridViewDataTextColumn>
                                        </Columns>
                                        <SettingsBehavior AllowFocusedRow="True" />
                                        <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                        </SettingsEditing>
                                        <SettingsText CommandEdit="| Coverage & Weight |" 
                                            CommandCancel="| Cancel Changes |" CommandUpdate="| Save Changes |" 
                                            PopupEditFormCaption="Coverage" />
                                        <SettingsPopup>
                                            <EditForm Height="400px" HorizontalAlign="WindowCenter" Modal="True" 
                                                VerticalAlign="WindowCenter" Width="800px" />
                                        </SettingsPopup>
                                        <SettingsDataSecurity AllowInsert="False" AllowDelete="False" />
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td class="style4">
                                    &nbsp;</td>
                                <td class="style7">
                                    &nbsp;</td>
                                <td class="style4">
                                    &nbsp;</td>
                                <td>
                                    <asp:ObjectDataSource ID="dscoverage" runat="server" OldValuesParameterFormatString="original_{0}" 
                                        SelectMethod="GetDataBy_SubjectAllocation" 
                                        TypeName="HRMDataTableAdapters.int_subjectallocationTableAdapter" 
                                        UpdateMethod="Update" DeleteMethod="Delete" InsertMethod="Insert">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt64" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="CurrentYear" Type="String" />
                                            <asp:Parameter Name="Term" Type="UInt32" />
                                            <asp:Parameter Name="Class" Type="UInt32" />
                                            <asp:Parameter Name="subcode" Type="String" />
                                            <asp:Parameter Name="EmpCode" Type="String" />
                                            <asp:Parameter Name="paper" Type="UInt32" />
                                            <asp:Parameter Name="workdone" Type="String" />
                                            <asp:Parameter Name="weight" Type="Double" />
                                            <asp:Parameter Name="weight_end" Type="Double" />
                                            <asp:Parameter Name="workdone_end" Type="String" />
                                        </InsertParameters>
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txtyr" Name="CurrentYr" PropertyName="Value" 
                                                Type="String" />
                                            <asp:ControlParameter ControlID="txtTerm" Name="Trm" PropertyName="Value" 
                                                Type="Int32" />
                                            <asp:SessionParameter Name="EmpCod" SessionField="username" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="CurrentYear" Type="String" />
                                            <asp:Parameter Name="Term" Type="UInt32" />
                                            <asp:Parameter Name="Class" Type="UInt32" />
                                            <asp:Parameter Name="subcode" Type="String" />
                                            <asp:Parameter Name="EmpCode" Type="String" />
                                            <asp:Parameter Name="paper" Type="UInt32" />
                                            <asp:Parameter Name="workdone" Type="String" />
                                            <asp:Parameter Name="weight" Type="Double" />
                                            <asp:Parameter Name="weight_end" Type="Double" />
                                            <asp:Parameter Name="workdone_end" Type="String" />
                                            <asp:Parameter Name="Original_ID" Type="UInt64" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td class="style4">
                                    &nbsp;</td>
                                <td class="style7">
                                    <asp:ObjectDataSource ID="dsSubjects" runat="server" OldValuesParameterFormatString="original_{0}" 
                                        SelectMethod="GetData" 
                                        TypeName="InternationalDataTableAdapters.int_subjectsTableAdapter">
                                    </asp:ObjectDataSource>
                                </td>
                                <td class="style4">
                                    &nbsp;</td>
                                <td>
                                    <dx:ASPxPopupControl ID="popup_message" runat="server" HeaderText="" 
                                        Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" 
                                        PopupVerticalAlign="WindowCenter" style="text-align: center" Width="400px">
                                        <ContentCollection>
                                            <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td align="center">
                                                            <dx:ASPxLabel ID="lbl_message" runat="server" ForeColor="Red" 
                                                                style="text-align: center">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </dx:PopupControlContentControl>
                                        </ContentCollection>
                                    </dx:ASPxPopupControl>
                                </td>
                            </tr>
                        </table></td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
    </dx:ASPxRoundPanel>