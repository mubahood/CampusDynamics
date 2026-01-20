<%@ Control Language="C#" AutoEventWireup="true" CodeFile="tutorcomments.ascx.cs" Inherits="COOPERP_Teaching_Centre_tutorcomments" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    
    .style4
    {
        width: 210px;
    }
    .style6
    {
        width: 27px;
    }
    
    .style7
    {
    }
    

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    }


        </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    ShowCollapseButton="true" ShowHeader="False" Width="100%">
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
                                        <dx:ASPxImage ID="ASPxImage3" runat="server" ShowLoadingImage="True" 
                                            ImageUrl="~/COOPERP/images/header_tutorcomments.png">
                                        </dx:ASPxImage>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                            ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="True" Width="100%">
                                        </dx:ASPxImage>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td class="style7">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                        <td class="style6">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style7">
                            <dx:ASPxLabel ID="ASPxLabel6" runat="server" Text="Year">
                            </dx:ASPxLabel>
                        </td>
                        <td class="style4">
                            <dx:ASPxComboBox ID="txt_tutoryear" runat="server" AutoPostBack="True" 
                                OnSelectedIndexChanged="txt_tutoryear_SelectedIndexChanged" Width="200px">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style6">
                            <dx:ASPxLabel ID="ASPxLabel10" runat="server" Text="Term">
                            </dx:ASPxLabel>
                        </td>
                        <td>
                            <dx:ASPxComboBox ID="txtTerm" runat="server" AutoPostBack="True" 
                                SelectedIndex="0" ValueType="System.Int32" Width="200px">
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
                        <td class="style7">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                        <td class="style6">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td  colspan="4">
                            <dx:ASPxGridView ID="gvtutorgroup" runat="server" AutoGenerateColumns="False" 
                                DataSourceID="dsTutorGrp" KeyFieldName="ID" Width="100%">
                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                        ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="CurrentYear" 
                                        ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="Term" ShowInCustomizationForm="True" 
                                        Visible="False" VisibleIndex="3">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Class" FieldName="studentClass" 
                                        ShowInCustomizationForm="True" VisibleIndex="4" Width="50px" 
                                        ReadOnly="True">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Admission No" FieldName="admno" 
                                        ShowInCustomizationForm="True" VisibleIndex="5" Width="100px" 
                                        ReadOnly="True">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="EmpCode" ShowInCustomizationForm="True" 
                                        Visible="False" VisibleIndex="12">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                        ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                                    </dx:GridViewCommandColumn>
                                    <dx:GridViewCommandColumn 
                                        ShowInCustomizationForm="True" VisibleIndex="14" Width="80px" 
                                        ShowEditButton="True">
                                    </dx:GridViewCommandColumn>
                                    <dx:GridViewDataTextColumn Caption="Name" FieldName="studName" 
                                        ShowInCustomizationForm="True" VisibleIndex="7">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataMemoColumn Caption="Mid Term Comment" FieldName="comments" 
                                        ShowInCustomizationForm="True" VisibleIndex="8" Width="300px">
                                        <PropertiesMemoEdit Rows="8">
                                        </PropertiesMemoEdit>
                                    </dx:GridViewDataMemoColumn>
                                    <dx:GridViewDataTextColumn Caption="Results" ShowInCustomizationForm="True" 
                                        VisibleIndex="11" Width="30px">
                                        <EditFormSettings Visible="False" />
                                        <DataItemTemplate>
                                            <asp:ImageButton ID="cmdResults" runat="server" 
                                                ImageUrl="~/COOPERP/images/clipboard-list.png" onclick="cmdResults_Click" />
                                        </DataItemTemplate>
                                        <CellStyle HorizontalAlign="Center">
                                        </CellStyle>
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataMemoColumn Caption="End Term Comments" FieldName="comments_end" ShowInCustomizationForm="True" VisibleIndex="10" Width="300px">
                                        <PropertiesMemoEdit Rows="5">
                                        </PropertiesMemoEdit>
                                    </dx:GridViewDataMemoColumn>
                                </Columns>
                                <SettingsBehavior AllowFocusedRow="True" />
                                <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                </SettingsEditing>
                                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                <SettingsText CommandEdit="| Comments |" CommandCancel="| Cancel Changes |" 
                                    CommandUpdate="| Save Changes |" PopupEditFormCaption="Tutor Comments" />
                                <SettingsPopup>
                                    <EditForm Height="400px" HorizontalAlign="WindowCenter" 
                                        VerticalAlign="WindowCenter" Width="700px" />
                                </SettingsPopup>
                                <SettingsDataSecurity AllowInsert="False" AllowDelete="False" />
                            </dx:ASPxGridView>
                        </td>
                    </tr>
                    <tr>
                        <td class="style7" colspan="4">
                            <asp:ObjectDataSource ID="dsTutorGrp" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_TutorGroups" TypeName="HRMDataTableAdapters.int_tutorgroupsTableAdapter" UpdateMethod="Update">
                                <DeleteParameters>
                                    <asp:Parameter Name="Original_ID" Type="UInt64" />
                                </DeleteParameters>
                                <InsertParameters>
                                    <asp:Parameter Name="_class" Type="UInt32" />
                                    <asp:Parameter Name="studyyear" Type="String" />
                                    <asp:Parameter Name="term" Type="UInt32" />
                                    <asp:Parameter Name="admno" Type="String" />
                                    <asp:Parameter Name="EmpCode" Type="UInt32" />
                                    <asp:Parameter Name="comments" Type="String" />
                                    <asp:Parameter Name="comments_end" Type="String" />
                                </InsertParameters>
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="txt_tutoryear" Name="CurrentYr" PropertyName="Value" Type="String" />
                                    <asp:ControlParameter ControlID="txtTerm" Name="Trm" PropertyName="Value" Type="Int32" />
                                    <asp:SessionParameter Name="EmpCod" SessionField="username" Type="String" />
                                </SelectParameters>
                                <UpdateParameters>
                                    <asp:Parameter Name="comments" Type="String" />
                                    <asp:Parameter Name="comments_end" Type="String" />
                                    <asp:Parameter Name="Original_ID" Type="Int64" />
                                </UpdateParameters>
                            </asp:ObjectDataSource>
                            <dx:ASPxPopupControl ID="pop_details" runat="server" 
                                HeaderText="School Dynamics Version 1.0" Modal="True" 
                                PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                                Width="300px">
                                <ClientSideEvents CloseUp="function(s, e) {
	gvStudentSearch.Refresh();
}" />
                                <HeaderStyle HorizontalAlign="Center" />
                                <ContentCollection>
                                    <dx:PopupControlContentControl runat="server">
                                        <table class="style1">
                                            <tr>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td align="center">
                                                    <br />
                                                    <dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                                    </dx:ASPxLabel>
                                                    <br />
                                                    <br />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <br />
                                                </td>
                                            </tr>
                                        </table>
                                    </dx:PopupControlContentControl>
                                </ContentCollection>
                            </dx:ASPxPopupControl>
                        </td>
                    </tr>
                    <tr>
                        <td class="style7">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                        <td class="style6">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

