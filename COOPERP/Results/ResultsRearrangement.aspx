<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ResultsRearrangement.aspx.cs" Inherits="COOPERP_Results_Reports_ResultsRearrangement" %>

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


    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .style1
    {
        width: 100%;
    }
        .tdWidth {
            width:80px;
        }
       
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="rp_results" runat="server" HeaderText="RESULTS ALIGNMENT ..:: KADDU MUKASA [BABA/13/DU/J1551]" ShowCollapseButton="true" Width="100%">
            <HeaderStyle ForeColor="Red" HorizontalAlign="Center" />
            <PanelCollection>
<dx:PanelContent runat="server">
    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
        <TabPages>
            <dx:TabPage Text="Results Alignment">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <table class="style1">
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td class="tdWidth">New Reg. No:</td>
                                            <td class="tdWidth">
                                                <dx:ASPxTextBox ID="txtNewRegNo" runat="server" Width="200px" Height="35px">
                                                </dx:ASPxTextBox>
                                            </td>
                                            <td style="text-align: left">
                                                <dx:ASPxButton ID="cmdChangeRegNo" runat="server" OnClick="cmdChangeRegNo_Click" Text="Change Registration No" Width="200px" Height="35px">
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>New Code:</td>
                                            <td>
                                                <dx:ASPxTextBox ID="txtNewCode" runat="server" Width="200px" Height="35px">
                                                </dx:ASPxTextBox>
                                            </td>
                                            <td style="text-align: left">
                                                <dx:ASPxButton ID="cmdChangeCode" runat="server" OnClick="cmdChangeCode_Click" Text="Change Course Code" Width="200px" Height="35px">
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdSyncSingle" runat="server" OnClick="cmdSyncSingle_Click" Text="Single Sync Results" Width="200px" Height="35px">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Refresh Single Student Results?');
}" />
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td style="text-align: left">
                                                <dx:ASPxButton ID="cmdSyncYear" runat="server" OnClick="cmdSyncYear_Click" Text="Batch Sync Results" Width="200px" Height="35px">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Refresh Batch Student Results?');
}" />
                                                    <Image Url="~/COOPERP/images/arrow-retweet.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxGridView ID="gvResultsInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvResultsInfo" DataSourceID="dsSemResultsInfo" KeyFieldName="ID" OnRowUpdated="gvResultsInfo_RowUpdated" Width="100%" OnRowDeleted="gvResultsInfo_RowDeleted" OnRowDeleting="gvResultsInfo_RowDeleting" OnCustomErrorText="gvResultsInfo_CustomErrorText" OnHtmlRowCreated="gvResultsInfo_HtmlRowCreated">
                                        <SettingsEditing Mode="Batch">
                                        </SettingsEditing>
                                        <Settings ShowFilterRow="True" />
                                        <SettingsBehavior AllowFocusedRow="True" AllowSelectSingleRowOnly="True" ConfirmDelete="True" />
                                        <SettingsSearchPanel Visible="True" />
                                        <Columns>
                                            <dx:GridViewDataTextColumn Caption="Course Name" FieldName="coursename" ShowInCustomizationForm="True" VisibleIndex="2" Width="350px">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Code" FieldName="courseid" ShowInCustomizationForm="True" VisibleIndex="1" Width="80px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Academic Year" FieldName="acad" ShowInCustomizationForm="True" VisibleIndex="5">
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Mark" FieldName="score" ShowInCustomizationForm="True" VisibleIndex="9">
                                                <EditFormSettings Visible="False" />
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" ShowInCustomizationForm="True" VisibleIndex="10">
                                                <EditFormSettings Visible="False" />
                                                <CellStyle HorizontalAlign="Left">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="GradePt" FieldName="gradept" ShowInCustomizationForm="True" VisibleIndex="11">
                                                <PropertiesTextEdit DisplayFormatString="{0:0.0}">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="False" />
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="CreditUnits" ShowInCustomizationForm="True" VisibleIndex="3">
                                                <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="False" />
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowClearFilterButton="True" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataTextColumn Caption="Semester" FieldName="semester" ShowInCustomizationForm="True" VisibleIndex="8" Width="25px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Study Year" FieldName="studyyear" ShowInCustomizationForm="True" VisibleIndex="7" Width="25px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="12" Width="25px">
                                            </dx:GridViewCommandColumn>
                                        </Columns>
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                        <HeaderStyle HorizontalAlign="Center" />
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
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
                                    <asp:ObjectDataSource ID="dsSemResultsInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllResults" TypeName="ResultsDataTableAdapters.acad_GetSemesterResultsTableAdapter" UpdateMethod="UpdateResults" DeleteMethod="DeleteResults">
                                        <DeleteParameters>
                                            <asp:Parameter Name="original_ID" Type="Int32" />
                                        </DeleteParameters>
                                        <SelectParameters>
                                            <asp:SessionParameter DefaultValue="-" Name="reg" SessionField="reg" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="Original_ID" Type="Int32" />
                                            <asp:Parameter Name="studyyear" Type="Int32" />
                                            <asp:Parameter Name="semester" Type="Int32" />
                                            <asp:Parameter Name="acad" Type="String" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text="Bridging Course Info">
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <table class="style1">
                            <tr>
                                <td>
                                    <dx:ASPxButton ID="cmdAddBridgeCS" runat="server" OnClick="cmdAddBridgeCS_Click" Text="Add Qualification" Width="170px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxCardView ID="CV_BridgeInfo" runat="server" AutoGenerateColumns="False" DataSourceID="dsBrigeInfo" KeyFieldName="regno" Width="100%">
                                        <SettingsPager>
                                            <SettingsFlowLayout ItemsPerPage="1" />
                                            <SettingsTableLayout ColumnCount="1" RowsPerPage="1" />
                                        </SettingsPager>
                                        <SettingsEditing Mode="Batch">
                                            <BatchEditSettings EditMode="Card" />
                                        </SettingsEditing>
                                        <SettingsBehavior ConfirmDelete="True" />
                                        <Columns>
                                            <dx:CardViewTextColumn Caption="Reg No" FieldName="regno" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn Caption="Qualification" FieldName="qualification" ShowInCustomizationForm="True" VisibleIndex="1">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn Caption="Institution" FieldName="institution" ShowInCustomizationForm="True" VisibleIndex="2">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn Caption="Class of Award" FieldName="award_class" ShowInCustomizationForm="True" VisibleIndex="3">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn Caption="Comments" FieldName="comments" ShowInCustomizationForm="True" VisibleIndex="4">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn Caption="CGPA" FieldName="cgpa" ShowInCustomizationForm="True" VisibleIndex="5">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn Caption="Completion Date" FieldName="comp_date" ShowInCustomizationForm="True" VisibleIndex="6">
                                            </dx:CardViewTextColumn>
                                        </Columns>
                                        <CardLayoutProperties>
                                            <Items>
                                                <dx:CardViewColumnLayoutItem ClientVisible="False" ColumnName="regno">
                                                </dx:CardViewColumnLayoutItem>
                                                <dx:CardViewLayoutGroup Caption="Qualifications" ColCount="2">
                                                    <Items>
                                                        <dx:EmptyLayoutItem ColSpan="2">
                                                        </dx:EmptyLayoutItem>
                                                        <dx:CardViewColumnLayoutItem ColumnName="qualification">
                                                        </dx:CardViewColumnLayoutItem>
                                                        <dx:CardViewColumnLayoutItem ColumnName="institution">
                                                        </dx:CardViewColumnLayoutItem>
                                                        <dx:CardViewColumnLayoutItem ColumnName="award_class">
                                                        </dx:CardViewColumnLayoutItem>
                                                        <dx:CardViewColumnLayoutItem ColumnName="Completion Date">
                                                        </dx:CardViewColumnLayoutItem>
                                                        <dx:CardViewColumnLayoutItem ColumnName="CGPA">
                                                        </dx:CardViewColumnLayoutItem>
                                                        <dx:CardViewColumnLayoutItem Caption="Comments" ColumnName="comments">
                                                        </dx:CardViewColumnLayoutItem>
                                                        <dx:EmptyLayoutItem ColSpan="2">
                                                        </dx:EmptyLayoutItem>
                                                    </Items>
                                                </dx:CardViewLayoutGroup>
                                                <dx:CardViewCommandLayoutItem HorizontalAlign="Right" ShowDeleteButton="True">
                                                </dx:CardViewCommandLayoutItem>
                                                <dx:EditModeCommandLayoutItem HorizontalAlign="Right">
                                                </dx:EditModeCommandLayoutItem>
                                            </Items>
                                        </CardLayoutProperties>
                                    </dx:ASPxCardView>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ObjectDataSource ID="dsBrigeInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetQualificationByRegNo" TypeName="ResultsDataTableAdapters.acad_bridgequalificationTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_regno" Type="String" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="regno" Type="String" />
                                            <asp:Parameter Name="qualification" Type="String" />
                                            <asp:Parameter Name="institution" Type="String" />
                                            <asp:Parameter Name="award_class" Type="String" />
                                            <asp:Parameter Name="comments" Type="String" />
                                            <asp:Parameter Name="comp_date" Type="String" />
                                            <asp:Parameter Name="cgpa" Type="String" />
                                        </InsertParameters>
                                        <SelectParameters>
                                            <asp:SessionParameter Name="regno" SessionField="reg" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="qualification" Type="String" />
                                            <asp:Parameter Name="institution" Type="String" />
                                            <asp:Parameter Name="award_class" Type="String" />
                                            <asp:Parameter Name="comments" Type="String" />
                                            <asp:Parameter Name="comp_date" Type="String" />
                                            <asp:Parameter Name="cgpa" Type="String" />
                                            <asp:Parameter Name="Original_regno" Type="String" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <dx:ASPxPopupControl ID="pop_msgBoxBridge" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                        <HeaderStyle HorizontalAlign="Center" />
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                                <table align="center" class="style1">
                                                    <tr>
                                                        <td align="center">
                                                            <br />
                                                            <br />
                                                            <dx:ASPxLabel ID="lbl_msgBridge" runat="server" ForeColor="Red" style="font-weight: 700">
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
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
        </TabPages>
    </dx:ASPxPageControl>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
