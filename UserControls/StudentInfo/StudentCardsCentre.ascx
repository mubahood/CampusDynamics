<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentCardsCentre.ascx.cs" Inherits="UserControls_StudentInfo_StudentCardsCentre" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
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
    .auto-style1 {
        width: 122px;
    }
    .auto-style2 {
        width: 348px;
    }
    .auto-style4 {
        width: 140px;
    }
    .auto-style5 {
        width: 110px;
    }
    .auto-style7 {
        width: 56px;
    }
    .auto-style8 {
        width: 442px;
    }
</style>



                            <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" ShowHeader="False" Width="100%">
                                <PanelCollection>
<dx:PanelContent runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table5" class="style1">
                <tr>
                    <td>
                        <table id="table6" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_studcardscentre.png">
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
                        <table id="table7" class="style1">
                            <tr>
                                <td class="auto-style1">Faculty: </td>
                                <td class="auto-style2">
                                    <dx:ASPxComboBox ID="txtFaculty" runat="server" AutoPostBack="True" DataSourceID="dsFaculties" OnSelectedIndexChanged="txtFaculty_SelectedIndexChanged" SelectedIndex="0" TextField="faculty_name" TextFormatString="{2} - {0}" ValueField="faculty_code" Width="300px" Height="27px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="faculty_code" />
                                            <dx:ListBoxColumn Caption="Faculty" FieldName="faculty_name" Width="250px" />
                                            <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style5">Academic Year:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="27px" Width="340px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">Programme:</td>
                                <td class="auto-style2">
                                    <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgramme" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="300px" Height="27px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="50px" />
                                            <dx:ListBoxColumn Caption="Programme Name" FieldName="progname" Width="200px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style5">Semester:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" SelectedIndex="0" Height="27px" Width="340px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">Cart Type:</td>
                                <td class="auto-style2">
                                    <dx:ASPxComboBox ID="txtCartType" runat="server" AutoPostBack="True" SelectedIndex="0" Width="300px" Height="27px">
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="Identity Cards" Value="Identity Cards" />
                                            <dx:ListEditItem Text="Registration Cards" Value="Registration Cards" />
                                            <dx:ListEditItem Text="Fees Cards" Value="Fees Cards" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style5">Intake:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="8" Width="340px" Height="27px" AutoPostBack="True">
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                        <Items>
                                            <dx:ListEditItem Text="-" Value="-" />
                                            <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                            <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                            <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                            <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                            <dx:ListEditItem Text="MAY" Value="MAY" />
                                            <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                            <dx:ListEditItem Text="JULY" Value="JULY" />
                                            <dx:ListEditItem Selected="True" Text="AUGUST" Value="AUGUST" />
                                            <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                            <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                            <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                            <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">Document Type:</td>
                                <td class="auto-style2">
                                    <dx:ASPxComboBox ID="txtDocumentType" runat="server" AutoPostBack="True" SelectedIndex="0" Width="300px" Height="27px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="Cards" Value="Cards" />
                                            <dx:ListEditItem Text="Student List" Value="Student List" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style5">Status:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtStatus" runat="server" SelectedIndex="0" Width="340px" Height="27px" AutoPostBack="True">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="PENDING" Value="PENDING" />
                                            <dx:ListEditItem Text="READY" Value="READY" />
                                            <dx:ListEditItem Text="PRINTED" Value="PRINTED" />
                                            <dx:ListEditItem Text="TAKEN" Value="TAKEN" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style2">
                                    <dx:ASPxButton ID="cmdCreateList" runat="server" Height="35px" OnClick="cmdCreateList_Click" Text="Create | Refresh" Width="149px">
                                        <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Are you Sure?');
}" />
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                    <dx:ASPxButton ID="cmdPrintList" runat="server" OnClick="cmdPrintList_Click" Text="Print List" Width="149px" Height="35px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style5">&nbsp;</td>
                                <td class="auto-style8">
                                    <dx:ASPxButton ID="cmdChangeStatus" runat="server" OnClick="cmdChangeStatus_Click" Text="Update Card Status" Width="170px" Height="35px">
                                        <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Are you Sure?');
}" />
                                        <Image Url="~/COOPERP/images/tick-shield.png">
                                        </Image>
                                    </dx:ASPxButton>
                                    <dx:ASPxButton ID="cmdSetExpiry" runat="server" Height="35px" OnClick="cmdSetExpiry_Click" Text="Set Card Expiry" Width="170px">
                                        <ClientSideEvents Click="function(s, e) {
	}" />
                                        <Image IconID="scheduling_today_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvStudentInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvStudentInfo" DataSourceID="dsStudentInfo" Width="100%" KeyFieldName="ID" OnHtmlDataCellPrepared="gvStudentInfo_HtmlDataCellPrepared">
                            <SettingsCommandButton>
                                <UpdateButton RenderMode="Link">
                                </UpdateButton>
                                <CancelButton RenderMode="Link">
                                </CancelButton>
                                <UpdateButton RenderMode="Link">
                                </UpdateButton>
                                <CancelButton RenderMode="Link">
                                </CancelButton>
                                <EditButton>
                                    <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                    </Image>
                                </EditButton>
                                <DeleteButton>
                                    <Image Url="~/COOPERP/images/minus-button.png">
                                    </Image>
                                </DeleteButton>
                            </SettingsCommandButton>
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Student Names" FieldName="studnames" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="ID" Visible="False" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Registration No" FieldName="reg_no" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Created By" FieldName="created_by" VisibleIndex="10">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Residence" FieldName="residence_stat" VisibleIndex="8">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Registration" FieldName="reg_status" VisibleIndex="9">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Date Created" FieldName="date_created" VisibleIndex="11">
                                    <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Expiry Date" FieldName="expiry_date" VisibleIndex="12">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Profile" VisibleIndex="13" Width="30px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="imgProfile" runat="server" ImageUrl="~/COOPERP/images/card-address.png" OnClick="imgProfile_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="AllPages" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataImageColumn Caption="Photo" FieldName="photofile" VisibleIndex="1" Width="30px">
                                    <PropertiesImage ImageHeight="50px" ImageUrlFormatString="~/COOPERP/StudentInfo/photos/{0}">
                                    </PropertiesImage>
                                </dx:GridViewDataImageColumn>
                                <dx:GridViewDataTextColumn Caption="Stud No" FieldName="studregno" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsPager PageSize="100" AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridViewExporter ID="GVE_Students" runat="server" GridViewID="gvStudentInfo">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsStudentInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_GetStudentCardsByStatusTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtFaculty" Name="fax" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtCartType" Name="cardType" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtStatus" Name="stat" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtIntake" Name="intk" PropertyName="Value" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter"></asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgramme" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetProgrammesByFaculty" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtFaculty" Name="faculty_code" PropertyName="Value" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ClientSideEvents CloseUp="function(s, e) {
	gvStudentInfo.Refresh();
}" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red" style="font-weight: 700">
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
                        <dx:ASPxPopupControl ID="pop_expdate" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Expiry Date Setting" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <table class="style1">
                                                    <tr>
                                                        <td class="auto-style7" style="text-align: left">Month:</td>
                                                        <td style="text-align: left">
                                                            <dx:ASPxComboBox ID="txtMonth" runat="server" Height="35px" Width="100%">
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="auto-style7" style="text-align: left">Year:</td>
                                                        <td style="text-align: left">
                                                            <dx:ASPxComboBox ID="txtYear" runat="server" Height="35px" Width="100%">
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="auto-style7">&nbsp;</td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdSetExp" runat="server" Height="35px" OnClick="cmdSetExp_Click" Text="Set Expiry" Width="100%">
                                                                <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Set Expiry Date?');
	
}" />
                                                                <Image IconID="scheduling_today_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <br />
                                                <dx:ASPxLabel ID="lbl_set_date_comm" runat="server" ForeColor="Blue" style="font-weight: 700">
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
        </ContentTemplate>
    </asp:UpdatePanel>
                                    </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

                        