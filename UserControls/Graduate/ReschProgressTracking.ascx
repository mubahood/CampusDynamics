<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ReschProgressTracking.ascx.cs" Inherits="UserControls_Graduate_ReschProgressTracking" %>
<style type="text/css">



*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


        .auto-style1 {
            width: 100%;
        }
        .auto-style2 {
        width: 471px;
    }
    .auto-style3 {
        width: 110px;
    }
    .auto-style4 {
        width: 36px;
    }
        .auto-style5 {
        height: 18px;
    }
    .auto-style6 {
        height: 18px;
        width: 78px;
    }
    .auto-style7 {
        width: 78px;
    }
    .auto-style8 {
        height: 18px;
        width: 109px;
    }
    .auto-style9 {
        width: 109px;
    }
        </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                    <TabPages>
                        <dx:TabPage Text="Research Progress">
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="auto-style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="ASPxButton1" runat="server" OnClick="ASPxButton1_Click" Text="Add New" Width="170px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus1.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="ProgTrackingGV" runat="server" AutoGenerateColumns="False" DataSourceID="ProgressODS" KeyFieldName="Id" OnInitNewRow="ProgTrackingGV_InitNewRow" Width="100%">
                                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                    <SettingsSearchPanel Visible="True" />
                                                    <Columns>
                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="8" Width="30px">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn Caption="Date" FieldName="date" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn Caption="General Comment" FieldName="comment" ShowInCustomizationForm="True" VisibleIndex="7">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Research Id" FieldName="Rid" ShowInCustomizationForm="True" VisibleIndex="2" Width="30px" ReadOnly="True">
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Chapter 1 Comment" FieldName="chapter_one" ShowInCustomizationForm="True" VisibleIndex="4">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Chapter 2 Comment" FieldName="chapter_two" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Chapter 3 Comment" FieldName="chapter_three" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                        </dx:GridViewCommandColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="ProgressODS" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetProgessByResearch" TypeName="GraduateDataTableAdapters.acad_research_progressTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="date" Type="DateTime" />
                                                        <asp:Parameter Name="comment" Type="String" />
                                                        <asp:Parameter Name="Rid" Type="UInt32" />
                                                        <asp:Parameter Name="chapter_one" Type="String" />
                                                        <asp:Parameter Name="chapter_two" Type="String" />
                                                        <asp:Parameter Name="chapter_three" Type="String" />
                                                    </InsertParameters>
                                                    <SelectParameters>
                                                        <asp:SessionParameter Name="rsid" SessionField="ReschID" Type="Int32" />
                                                    </SelectParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="date" Type="DateTime" />
                                                        <asp:Parameter Name="comment" Type="String" />
                                                        <asp:Parameter Name="Rid" Type="UInt32" />
                                                        <asp:Parameter Name="chapter_one" Type="String" />
                                                        <asp:Parameter Name="chapter_two" Type="String" />
                                                        <asp:Parameter Name="chapter_three" Type="String" />
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text="Print Documents">
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="auto-style1">
                                        <tr>
                                            <td class="auto-style3">
                                                &nbsp;Document:</td>
                                            <td class="auto-style4">
                                                <dx:ASPxComboBox ID="ReportComboBox" runat="server" OnSelectedIndexChanged="ReportComboBox_SelectedIndexChanged" NullText="Select  Document">
                                                    <Items>
                                                        <dx:ListEditItem Text="Supervisor's Letter" Value="0" />
                                                        <dx:ListEditItem Text="Recommendation Letter" Value="1" />
                                                        <dx:ListEditItem Text="Field Letter" Value="2" />
                                                        <dx:ListEditItem Text="Appointment Reviewer" Value="3" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style2">
                                                <dx:ASPxButton ID="Btn_Print_doc" runat="server" OnClick="Btn_Print_doc_Click" Text="Print" Width="170px">
                                                    <Image Url="~/COOPERP/images/printer.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">&nbsp;</td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text="Results Approval">
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table id="table1" class="auto-style1">
                                        <tr>
                                            <td class="auto-style6">&nbsp;</td>
                                            <td class="auto-style8">&nbsp;</td>
                                            <td class="auto-style5">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style6">&nbsp;</td>
                                            <td class="auto-style8">Mark Scored:</td>
                                            <td class="auto-style5">
                                                <dx:ASPxTextBox ID="txtMark" runat="server" Height="27px" ReadOnly="True" Width="300px">
                                                    <Paddings PaddingLeft="10px" />
                                                </dx:ASPxTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style6">&nbsp;</td>
                                            <td class="auto-style8">Course Code:</td>
                                            <td class="auto-style5">
                                                <dx:ASPxComboBox ID="txtCourseCode" runat="server" DataSourceID="dsCourses" Height="27px" TextField="courseName" TextFormatString="{0} : {1}" ValueField="course_code" Width="300px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Course Code" FieldName="course_code" Width="80px" />
                                                        <dx:ListBoxColumn Caption="Course Name" FieldName="courseName" Width="220px" />
                                                    </Columns>
                                                    <Paddings PaddingLeft="10px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style7">&nbsp;</td>
                                            <td class="auto-style9">Academic Year:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtAcademicYear" runat="server" Height="27px" Width="300px">
                                                    <Paddings PaddingLeft="10px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style7">&nbsp;</td>
                                            <td class="auto-style9">Year of Study:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtStudyYear" runat="server" Height="27px" SelectedIndex="0" Width="300px">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                    <Paddings PaddingLeft="10px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style7">&nbsp;</td>
                                            <td class="auto-style9">&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdApprove" runat="server" Height="30px" OnClick="cmdApprove_Click" Text="Approve Results" Width="300px">
                                                    <Image IconID="actions_apply_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style7">&nbsp;</td>
                                            <td class="auto-style9">&nbsp;</td>
                                            <td>
                                                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" CloseAction="CloseButton" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="350px">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ContentCollection>
                                                        <dx:PopupControlContentControl runat="server">
                                                            <table style="width: 100%;">
                                                                <tr>
                                                                    <td>
                                                                        <br />
                                                                        <br />
                                                                        <br />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="text-align: center">
                                                                        <dx:ASPxLabel ID="lbl_pop" runat="server" Font-Bold="True" ForeColor="Red">
                                                                        </dx:ASPxLabel>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
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
                                        <tr>
                                            <td class="auto-style7">&nbsp;</td>
                                            <td class="auto-style9">&nbsp;</td>
                                            <td>
                                                <asp:ObjectDataSource ID="dsCourses" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_GetGraduateResearchCoursesTableAdapter">
                                                    <SelectParameters>
                                                        <asp:SessionParameter Name="reg" SessionField="regno" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                    </TabPages>
                </dx:ASPxPageControl>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

