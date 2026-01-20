<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BestPerformersAnnual.ascx.cs" Inherits="UserControls_Results_BestPerformersAnnual" %>
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
    .auto-style7 {
        width: 312px;
    }
    .auto-style8 {
        width: 60px;
    }
    .auto-style9 {
        width: 94px;
    }
    .auto-style10 {
        width: 60px;
        height: 27px;
    }
    .auto-style11 {
        width: 312px;
        height: 27px;
    }
    .auto-style12 {
        width: 94px;
        height: 27px;
    }
    .auto-style13 {
        height: 27px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table class="style1">
                <tr>
                    <td>
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_bestperform.png">
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
                        <table class="style1">
                            <tr>
                                <td>
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style10">Faculty:</td>
                                            <td class="auto-style11">
                                                <dx:ASPxComboBox ID="txtFaculty" runat="server" DataSourceID="dsFaculty" SelectedIndex="0" TextField="faculty_name" TextFormatString="{1}" ValueField="faculty_code" Width="300px" AutoPostBack="True" OnSelectedIndexChanged="txtProgramme_SelectedIndexChanged" Height="27px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
lp_grads.Show();
	}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="faculty_code" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="faculty_name" Width="250px" />
                                                    </Columns>
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style12">Academic Year:</td>
                                            <td class="auto-style13">
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="27px" Width="170px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
lp_grads.Show();

	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">Gender:</td>
                                            <td class="auto-style7">
                                                <dx:ASPxComboBox ID="txtGender" runat="server" AutoPostBack="True" Height="27px" OnSelectedIndexChanged="txtStatus_SelectedIndexChanged" SelectedIndex="0" Width="300px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	lp_grads.Show();

}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="MALE" Value="MALE" />
                                                        <dx:ListEditItem Text="FEMALE" Value="FEMALE" />
                                                    </Items>
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style9">&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdExportExcel" runat="server" Height="27px" OnClick="cmdExportExcel_Click" Text="Export Excel" Width="170px">
                                                    <Image Url="~/COOPERP/images/export_excel.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">
                                    &nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsMarksheetInfo" KeyFieldName="regno" Width="100%" OnHtmlDataCellPrepared="gvMarksheetInfo_HtmlDataCellPrepared">
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Reg. Number" FieldName="regno" VisibleIndex="1" Width="200px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Student" FieldName="stud_name" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Completion Status" FieldName="comp" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="CGPA" FieldName="cgpa" VisibleIndex="6" Width="50px">
                                    <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                    </PropertiesTextEdit>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="AwardClass" VisibleIndex="7">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Profile" VisibleIndex="9" Width="25px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdProbs" runat="server" ImageUrl="~/COOPERP/images/card-address.png" OnClick="cmdProfile_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Gender" FieldName="gender" VisibleIndex="3" Width="80px">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsPager PageSize="5000" AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
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
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_Get_GraduationBestPerformersTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtFaculty" Name="fax" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtGender" Name="gender" PropertyName="Value" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFaculty" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter"></asp:ObjectDataSource>
                        <dx:ASPxLoadingPanel ID="lp_grads" runat="server" ClientInstanceName="lp_grads" Modal="True">
                        </dx:ASPxLoadingPanel>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
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
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="cmdExportExcel" />
        </Triggers>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>