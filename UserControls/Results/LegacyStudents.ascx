<%@ Control Language="C#" AutoEventWireup="true" CodeFile="LegacyStudents.ascx.cs" Inherits="UserControls_Results_LegacyStudents" %>
<%@ Register src="ResultsProblems.ascx" tagname="ResultsProblems" tagprefix="uc1" %>

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


    .style2_apps
    {
        width: 80px;
    }
    .style3
    {
        width: 218px;
    }
    .style4
    {
        width:40px;
    }
    .style5
    {
        width: 1052px;
    }
    .auto-style3 {
        width: 103px;
    }
    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <%--<asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>--%>
            <table class="style1">
                <tr>
                    <td>
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_legacy_students.png">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
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
                        &nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <table class="style1">
                            <tr>
                                <td class="auto-style3">Academic Year:</td>
                                <td>
                                    <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True">
                                    </dx:ASPxComboBox>
                                </td>
                                <td style="text-align: right">
                                    <dx:ASPxButton ID="cmdAttachPhoto" runat="server" OnClick="cmdAttachPhoto_Click" Text="Attach Photo" Width="170px">
                                        <Image Url="~/COOPERP/images/user.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style3">&nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="cmdExportExcel" runat="server" OnClick="cmdExportExcel_Click" Text="Export Excel" Width="170px">
                                        <Image Url="~/COOPERP/images/export_excel.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td style="text-align: right">
                                    <dx:ASPxButton ID="cmdResults" runat="server" OnClick="cmdResults_Click" Text="Result Details" Width="170px">
                                        <Image Url="~/COOPERP/images/clipboard-list.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsLegacyStudents" KeyFieldName="regno" OnCustomErrorText="gvMarksheetInfo_CustomErrorText" OnRowUpdating="gvMarksheetInfo_RowUpdating" Width="100%">
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Reg. Number" FieldName="regno" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Other Name" FieldName="oname" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Gender" FieldName="gender" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Certificate" Name="pending" VisibleIndex="10" Width="25px">
                                    <EditFormSettings Visible="False" />
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdCertificate" runat="server" ImageUrl="~/COOPERP/images/printer.png" OnClick="cmdCertificate_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Transcript" VisibleIndex="9" Width="25px">
                                    <EditFormSettings Visible="False" />
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdTranscript" runat="server" ImageUrl="~/COOPERP/images/printer.png" OnClick="cmdTranscript_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="First Name" FieldName="sname" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Graduate Date" FieldName="gradate" VisibleIndex="8">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataImageColumn Caption="Photo" FieldName="image_name" VisibleIndex="1" Width="60px">
                                    <PropertiesImage ImageHeight="60px" ImageUrlFormatString="~/COOPERP/StudentInfo/Photos/{0}">
                                    </PropertiesImage>
                                </dx:GridViewDataImageColumn>
                                <dx:GridViewDataDateColumn Caption="Birth Date" FieldName="dob" VisibleIndex="7">
                                    <PropertiesDateEdit DisplayFormatInEditMode="True" DisplayFormatString="dd-MMM-yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsPager PageSize="30" AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
                            <SettingsEditing Mode="Batch">
                            </SettingsEditing>
                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridViewExporter ID="GVE_Marksheets" runat="server" GridViewID="gvMarksheetInfo">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsLegacyStudents" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetLegacyStudentsByCompYear" TypeName="LegacyDataTableAdapters.acad_student_legacyTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_regno" Type="String" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="sname" Type="String" />
                                <asp:Parameter Name="oname" Type="String" />
                                <asp:Parameter Name="dob" Type="String" />
                                <asp:Parameter Name="gender" Type="String" />
                                <asp:Parameter Name="nationality" Type="String" />
                                <asp:Parameter Name="phone" Type="String" />
                                <asp:Parameter Name="faculty" Type="String" />
                                <asp:Parameter Name="program" Type="String" />
                                <asp:Parameter Name="completiondt" Type="String" />
                                <asp:Parameter Name="image_name" Type="String" />
                                <asp:Parameter Name="image_path" Type="String" />
                                <asp:Parameter Name="gradate" Type="String" />
                                <asp:Parameter Name="prog_level" Type="String" />
                                <asp:Parameter Name="disclaimer" Type="String" />
                                <asp:Parameter Name="comp_year" Type="UInt32" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAcadYear" Name="yr" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="sname" Type="String" />
                                <asp:Parameter Name="oname" Type="String" />
                                <asp:Parameter Name="dob" Type="String" />
                                <asp:Parameter Name="gender" Type="String" />
                                <asp:Parameter Name="nationality" Type="String" />
                                <asp:Parameter Name="Original_regno" Type="String" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvMarksheetInfo.Refresh();
}" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red" style="font-weight: 700">
                                                </dx:ASPxLabel>
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
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <uc1:ResultsProblems ID="ResultsProblems1" runat="server" />
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
            </table>
       <%-- </ContentTemplate>
    </asp:UpdatePanel>--%>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>