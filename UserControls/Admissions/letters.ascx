<%@ Control Language="C#" AutoEventWireup="true" CodeFile="letters.ascx.cs" Inherits="UserControls_Admissions_letters" %>


<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>






<%@ Register assembly="DevExpress.Web.ASPxRichEdit.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web.ASPxRichEdit" tagprefix="dx" %>
<%@ Register assembly="DevExpress.Web.ASPxHtmlEditor.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web.ASPxHtmlEditor" tagprefix="dx" %>
<%@ Register assembly="DevExpress.Web.ASPxSpellChecker.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web.ASPxSpellChecker" tagprefix="dx" %>






<style type="text/css">
    .style2
    {
        width:100%;
    }
    
    .style3
    {
        width: 70px;
    }
    
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


    .auto-style2 {
        width: 72px;
    }


    .auto-style3 {
        width: 70px;
        height: 37px;
    }
    .auto-style4 {
        height: 37px;
    }


    </style>







<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="style2">
        <tr>
            <td colspan="3">
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_admission.png" >
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
            <td colspan="3">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="3">
                <table class="style2">
                    <tr>
                        <td class="auto-style2">
                            <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Entry Year:">
                            </dx:ASPxLabel>
                        </td>
                        <td>
                            <dx:ASPxComboBox ID="txt_entyr" runat="server" AutoPostBack="True" OnSelectedIndexChanged="txt_entyr_SelectedIndexChanged" Width="200px" Height="35px">
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">&nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="btn_newletter" runat="server" OnClick="btn_newletter_Click" Text="Add New" Width="200px" Height="35px" ToolTip="Click to add a new Letter Template">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">&nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="btn_adoptletter" runat="server" Height="35px" Text="Adopt Templates" ToolTip="Click to adopt Templates from the Previous Academic year." Width="200px" OnClick="btn_adoptletter_Click">
                                <Image IconID="actions_convert_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <dx:ASPxGridView ID="gv_letters" runat="server" AutoGenerateColumns="False" DataSourceID="ds_letters" KeyFieldName="letter_ref" OnInitNewRow="gv_letters_InitNewRow" Width="100%" OnHtmlDataCellPrepared="gv_letters_HtmlDataCellPrepared">
                    <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                    </SettingsPager>
                    <SettingsEditing EditFormColumnCount="1">
                    </SettingsEditing>
                    <Settings ShowFilterRow="True" />
                    <SettingsBehavior ConfirmDelete="True" AllowFocusedRow="True" />
                    <SettingsCommandButton>
                        <UpdateButton RenderMode="Link" Text="| Save Changes |">
                        </UpdateButton>
                        <CancelButton RenderMode="Link" Text=" | Cancel Changes |">
                        </CancelButton>
                        <EditButton RenderMode="Image">
                            <Image Url="~/COOPERP/images/clipboard--pencil.png">
                            </Image>
                        </EditButton>
                        <DeleteButton RenderMode="Image">
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </DeleteButton>
                    </SettingsCommandButton>
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="AllPages" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px" ShowClearFilterButton="True">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="Letter Reference" FieldName="letter_ref" ShowInCustomizationForm="True" VisibleIndex="1" Width="300px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Letter Date" FieldName="ldate" ShowInCustomizationForm="True" VisibleIndex="4" Width="200px">
                            <PropertiesDateEdit DisplayFormatInEditMode="True" DisplayFormatString="dd-MMM-yyyy">
                            </PropertiesDateEdit>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Academic Year" FieldName="acadyear" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Meeting Date" FieldName="meet_date" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                            <PropertiesDateEdit DisplayFormatInEditMode="True" DisplayFormatString="dd-MMM-yyyy">
                            </PropertiesDateEdit>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Programme" FieldName="prog_name" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11" Width="400px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Campus" FieldName="campus" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                            <PropertiesComboBox DataSourceID="ds_campus" TextField="campus_name" TextFormatString="{1}" ValueField="campus_code">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="campus_code" Width="20px" />
                                    <dx:ListBoxColumn Caption="Campus" FieldName="campus_name" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewCommandColumn ButtonRenderMode="Image" ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="12" Width="45px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="In-take" FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="10" Width="200px">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                    <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                    <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                    <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                    <dx:ListEditItem Text="MAY" Value="MAY" />
                                    <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                    <dx:ListEditItem Text="JULY" Value="JULY" />
                                    <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                    <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                    <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                    <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                    <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="prog_code" ShowInCustomizationForm="True" VisibleIndex="5" Width="400px">
                            <PropertiesComboBox DataSourceID="ds_programmes" DropDownWidth="600px" TextField="progname" TextFormatString="{1}" ValueField="progcode">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="40px" />
                                    <dx:ListBoxColumn Caption="Programme" FieldName="progname" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataMemoColumn Caption="Letter Content" FieldName="content" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                            <PropertiesMemoEdit Height="300px">
                            </PropertiesMemoEdit>
                            <EditFormSettings Visible="True" />
                            <EditItemTemplate>
                                <dx:ASPxHtmlEditor ID="ASPxHtmlEditor1" runat="server" Html='<%# Bind("content") %>' Width="100%">
                                </dx:ASPxHtmlEditor>
                            </EditItemTemplate>
                        </dx:GridViewDataMemoColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Session" FieldName="sess" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                            <PropertiesComboBox DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="Session" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Intro Text" FieldName="intro_text" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                            <EditFormSettings Visible="True" />
                            <EditItemTemplate>
                                <dx:ASPxHtmlEditor ID="ASPxHtmlEditor1" runat="server" Height="200px" Html='<%# Bind("intro_text") %>' Width="100%">
                                </dx:ASPxHtmlEditor>
                            </EditItemTemplate>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td class="auto-style3">
                </td>
            <td class="auto-style4">
                <asp:ObjectDataSource ID="ds_letters" runat="server" 
                    DeleteMethod="DeleteLetter" InsertMethod="AddLetter" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetLetters" 
                    TypeName="AdmissionLettersBLL" UpdateMethod="UpdateLetter">
                    <DeleteParameters>
                        <asp:Parameter Name="original_letter_ref" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="letter_ref" Type="String" />
                        <asp:Parameter Name="content" Type="String" />
                        <asp:Parameter Name="ldate" Type="DateTime" />
                        <asp:Parameter Name="prog_code" Type="String" />
                        <asp:Parameter Name="sess" Type="String" />
                        <asp:Parameter Name="campus" Type="Int32" />
                        <asp:Parameter Name="acadyear" Type="String" />
                        <asp:Parameter Name="meet_date" Type="DateTime" />
                        <asp:Parameter Name="intake" Type="String" />
                        <asp:Parameter Name="intro_text" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txt_entyr" Name="acadyear" 
                            PropertyName="Value" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="original_letter_ref" Type="String" />
                        <asp:Parameter Name="content" Type="String" />
                        <asp:Parameter Name="ldate" Type="DateTime" />
                        <asp:Parameter Name="prog_code" Type="String" />
                        <asp:Parameter Name="sess" Type="String" />
                        <asp:Parameter Name="campus" Type="Int32" />
                        <asp:Parameter Name="acadyear" Type="String" />
                        <asp:Parameter Name="meet_date" Type="DateTime" />
                        <asp:Parameter Name="intake" Type="String" />
                        <asp:Parameter Name="intro_text" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsstudysessions" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                    <InsertParameters>
                        <asp:Parameter Name="Session" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Original_Session" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
            <td class="auto-style4">
                <asp:ObjectDataSource ID="ds_campus" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="admission_dataTableAdapters.acad_campusesTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="campus_name" Type="String" />
                        <asp:Parameter Name="campus_phone" Type="String" />
                        <asp:Parameter Name="campus_email" Type="String" />
                        <asp:Parameter Name="campus_short_name" Type="String" />
                        <asp:Parameter Name="campus_head" Type="String" />
                        <asp:Parameter Name="campus_code" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="campus_name" Type="String" />
                        <asp:Parameter Name="campus_phone" Type="String" />
                        <asp:Parameter Name="campus_email" Type="String" />
                        <asp:Parameter Name="campus_short_name" Type="String" />
                        <asp:Parameter Name="campus_head" Type="String" />
                        <asp:Parameter Name="campus_code" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <asp:ObjectDataSource ID="ds_programmes" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="admission_dataTableAdapters.acad_programmeTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_progcode" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="progcode" Type="String" />
                        <asp:Parameter Name="progname" Type="String" />
                        <asp:Parameter Name="mincredit" Type="Double" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="couselength" Type="Double" />
                        <asp:Parameter Name="maxduration" Type="Double" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="levelCode" Type="UInt32" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="progname" Type="String" />
                        <asp:Parameter Name="mincredit" Type="Double" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="couselength" Type="Double" />
                        <asp:Parameter Name="maxduration" Type="Double" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="levelCode" Type="UInt32" />
                        <asp:Parameter Name="Original_progcode" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxPopupControl ID="pop_message" runat="server" HeaderText="Campus Dynamics :: Version 1.0" Height="100px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style2">
                                <tr>
                                    <td align="center">
                                        <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red" >
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td colspan="3">
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>







