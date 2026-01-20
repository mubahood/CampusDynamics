<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ExamPaperDetail.aspx.cs" Inherits="COOPERP_Timetables_ExamPaperDetail" %>

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
    margin-bottom: 0;
    
}
    .style1 {
        width:100%;
    }


    .auto-style1 {
        width: 109px;
    }
    .auto-style2 {
        width: 165px;
    }


    </style>
</head>
<body>
    <form id="form1" runat="server">
    <dx:ASPxRoundPanel ID="rp_details" runat="server" HeaderText="EXAM DETAILS FOR BIT 1101 - INTRODUCTION TO COMPUTING" Width="100%">
    <HeaderStyle ForeColor="Red" HorizontalAlign="Center" Font-Bold="True" VerticalAlign="Middle" />
    
    
        <PanelCollection>
            <dx:PanelContent ID="PanelContent2" runat="server">
                <table class="style1">
                    <tr>
                        <td>
                            <table class="style1">
                                <tr>
                                    <td class="auto-style1">
                                        <dx:ASPxButton ID="cmdComment" runat="server" Text="Add Comment" Width="200px" Visible="True" Height="30px" ToolTip="Click to add an Approval Comment for the Paper" OnClick="cmdComment_Click">
                                            <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('You\'re about to generate an Approval Comment for this Exam, Are you Sure?');
}" />
                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                    <td class="auto-style2">
                                        &nbsp;</td>
                                    <td>
                                        &nbsp;</td>
                                    <td align="right">
                                        <dx:ASPxButton ID="cmdprint" runat="server" Height="30px" Text="Print Preview" Width="200px" OnClick="cmdprint_Click">
                                            <Image IconID="print_printarea_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxGridView ID="gvExam" runat="server" AutoGenerateColumns="False" DataSourceID="dsMarksheetDetails" KeyFieldName="ID" Width="100%" OnCustomErrorText="gvExam_CustomErrorText" OnHtmlRowCreated="gvExam_HtmlRowCreated" OnRowUpdating="gvExam_RowUpdating" OnRowInserted="gvExam_RowInserted" OnRowInserting="gvExam_RowInserting" OnRowUpdated="gvExam_RowUpdated">
                                <SettingsCommandButton>
                                    <UpdateButton RenderMode="Button" Text="Send Changes">
                                        <Image IconID="save_saveto_16x16">
                                        </Image>
                                    </UpdateButton>
                                    <CancelButton RenderMode="Button" Text="Cancel Changes">
                                        <Image IconID="actions_trash_16x16">
                                        </Image>
                                    </CancelButton>
                                    <EditButton RenderMode="Image">
                                        <Image IconID="actions_addfile_16x16" ToolTip="Click to Comment/Approve Exam">
                                        </Image>
                                    </EditButton>
                                </SettingsCommandButton>
                                <SettingsDataSecurity AllowDelete="False" />
                                <SettingsPopup>
                                    <EditForm HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" Width="500px" Height="400px" />
                                </SettingsPopup>
                                <SettingsText PopupEditFormCaption="Exam Approval" EmptyDataRow="No Approval Comments Generated" />
                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="10px" SelectAllCheckboxMode="AllPages">
                                    </dx:GridViewCommandColumn>
                                    <dx:GridViewDataMemoColumn Caption="Comment" FieldName="ApprovalComment" ShowInCustomizationForm="True" VisibleIndex="3" Width="300px">
                                        <PropertiesMemoEdit Height="200px">
                                        </PropertiesMemoEdit>
                                        <EditFormSettings CaptionLocation="Top" />
                                    </dx:GridViewDataMemoColumn>
                                    <dx:GridViewDataComboBoxColumn Caption="Approval Status" FieldName="sheet_status" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                                        <PropertiesComboBox>
                                            <Items>
                                                <dx:ListEditItem Text="APPROVED" Value="APPROVED" />
                                                <dx:ListEditItem Text="FOR REVIEW" Value="FOR REVIEW" />
                                            </Items>
                                        </PropertiesComboBox>
                                        <EditFormSettings CaptionLocation="Top" />
                                    </dx:GridViewDataComboBoxColumn>
                                    <dx:GridViewCommandColumn Caption="Edit" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="7" Width="30px" Name="Edit">
                                        <HeaderStyle HorizontalAlign="Center" />
                                        <CellStyle HorizontalAlign="Center">
                                        </CellStyle>
                                    </dx:GridViewCommandColumn>
                                    <dx:GridViewDataTextColumn FieldName="approved_by" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataDateColumn FieldName="ApprovalDate" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                    </dx:GridViewDataDateColumn>
                                    <dx:GridViewDataTextColumn FieldName="ExamID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                    </dx:GridViewDataTextColumn>
                                </Columns>
                                <SettingsPager PageSize="5" Position="TopAndBottom" Visible="False">
                                </SettingsPager>
                                <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                </SettingsEditing>
                                <SettingsBehavior AllowFocusedRow="True" />
                            </dx:ASPxGridView>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:ObjectDataSource ID="dsMarksheetDetails" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_PaperComments" TypeName="ExamSettingTableAdapters.acad_examination_papers_approvalcommentsTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                                <DeleteParameters>
                                    <asp:Parameter Name="Original_ID" Type="UInt64" />
                                </DeleteParameters>
                                <InsertParameters>
                                    <asp:Parameter Name="ExamID" Type="UInt64" />
                                    <asp:Parameter Name="ApprovalComment" Type="String" />
                                    <asp:Parameter Name="sheet_status" Type="String" />
                                    <asp:Parameter Name="approved_by" Type="String" />
                                    <asp:Parameter Name="ApprovalDate" Type="DateTime" />
                                </InsertParameters>
                                <SelectParameters>
                                    <asp:SessionParameter Name="ExamID" SessionField="mid" Type="Int64" />
                                </SelectParameters>
                                <UpdateParameters>
                                    <asp:Parameter Name="ExamID" Type="UInt64" />
                                    <asp:Parameter Name="ApprovalComment" Type="String" />
                                    <asp:Parameter Name="sheet_status" Type="String" />
                                    <asp:Parameter Name="approved_by" Type="String" />
                                    <asp:Parameter Name="ApprovalDate" Type="DateTime" />
                                    <asp:Parameter Name="Original_ID" Type="UInt64" />
                                </UpdateParameters>
                            </asp:ObjectDataSource>
                            <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Text="Processing. Please wait&amp;hellip;">
                            </dx:ASPxLoadingPanel>
                            <dx:ASPxPopupControl ID="pop_print" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                                <ContentCollection>
                                    <dx:PopupControlContentControl runat="server">
                                    </dx:PopupControlContentControl>
                                </ContentCollection>
                            </dx:ASPxPopupControl>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxPopupControl ID="pop_DetailsMsg" runat="server" ClientInstanceName="pop_DetailsMsg" CloseAction="CloseButton" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <ContentCollection>
                                    <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                        <table align="center" class="style1">
                                            <tr>
                                                <td align="center">
                                                    <br />
                                                    <br />
                                                    <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                                                    </dx:ASPxLabel>
                                                    <br />
                                                    <br />
                                                    <br />
                                                    <br />
                                                </td>
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
    </form>
</body>
</html>
