<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Programme.ascx.cs" Inherits="UserControls_Faculty_Programme" %>
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
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_programme_info.png">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <!-- Filter Panel - Toggle to show/hide -->
                <dx:ASPxRoundPanel ID="pnlFilter" runat="server" HeaderText="Filter Options" Width="100%" 
                    Collapsible="true" Collapsed="true" EnableAnimation="true">
                    <HeaderStyle BackColor="#F5F5F5" Font-Bold="true" />
                    <PanelCollection>
                        <dx:PanelContent runat="server">
                            <table style="width: 100%; padding: 8px;">
                                <tr>
                                    <td style="width: 80px; vertical-align: middle;">
                                        <dx:ASPxLabel ID="lblFaculty" runat="server" Text="Faculty:" />
                                    </td>
                                    <td style="width: 300px;">
                                        <dx:ASPxComboBox ID="cboFacultyFilter" runat="server" 
                                            DataSourceID="dsFaculties" 
                                            TextField="faculty_name" 
                                            ValueField="faculty_code"
                                            IncrementalFilteringMode="Contains"
                                            Width="280px"
                                            NullText="-- All Faculties --"
                                            ClientInstanceName="cboFacultyFilter">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) { 
                                                var value = s.GetValue();
                                                if (value != null &amp;&amp; value != '') {
                                                    gvProgrammeInfo.AutoFilterByColumn('faculty_code', value);
                                                } else {
                                                    gvProgrammeInfo.ClearFilter();
                                                }
                                            }" />
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td style="width: 100px;">
                                        <dx:ASPxButton ID="cmdClearFilter" runat="server" Text="Clear" 
                                            AutoPostBack="false" UseSubmitBehavior="false">
                                            <ClientSideEvents Click="function(s, e) { 
                                                cboFacultyFilter.SetValue(null); 
                                                gvProgrammeInfo.ClearFilter(); 
                                            }" />
                                            <Image Url="~/COOPERP/images/cross-button.png" />
                                        </dx:ASPxButton>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                        </dx:PanelContent>
                    </PanelCollection>
                </dx:ASPxRoundPanel>
            </td>
        </tr>
        <tr>
            <td style="height: 5px;">&nbsp;</td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td>
                            <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Add New" Width="170px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td style="text-align: right" width="170px">
                            <dx:ASPxTextBox ID="txtSearch" runat="server" Height="27px" NullText="Enter Search Text" Width="170px" AutoCompleteType="Search" Visible="False">
                                <ClientSideEvents TextChanged="function(s, e) {
	gvProgrammeInfo.Refresh();
}" />
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxTextBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvProgrammeInfo" runat="server" AutoGenerateColumns="False" DataSourceID="dsProgrammeInfo" KeyFieldName="progcode" Width="100%" OnRowInserting="gvProgrammeInfo_RowInserting" ClientInstanceName="gvProgrammeInfo" OnRowUpdating="gvProgrammeInfo_RowUpdating">
                    <SettingsCommandButton>
                        <UpdateButton Text="| Save Changes |">
                        </UpdateButton>
                        <CancelButton Text="| Cancel Changes |">
                        </CancelButton>
                        <EditButton Text="| Edit |">
                        </EditButton>
                    </SettingsCommandButton>
                    <SettingsDataSecurity AllowDelete="False" />
                    <SettingsSearchPanel Visible="True" />
                    <Settings ShowHeaderFilterButton="True" ShowFilterRow="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="progcode" ShowInCustomizationForm="True" VisibleIndex="1" Caption="Code">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Programme Name" FieldName="progname" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Credit Units" FieldName="mincredit" ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Abbreviation" FieldName="abbrev" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Faculty" FieldName="faculty_code" ShowInCustomizationForm="True" VisibleIndex="8">
                            <PropertiesComboBox DataSourceID="dsFaculties" IncrementalFilteringMode="Contains" TextField="faculty_name" TextFormatString="{1}" ValueField="faculty_code">
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ButtonType="Link" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="11" Width="40px"/>
                        <dx:GridViewDataComboBoxColumn Caption="Level" FieldName="levelCode" ShowInCustomizationForm="True" VisibleIndex="9">
                            <PropertiesComboBox IncrementalFilteringMode="Contains">
                                <Items>
                                    <dx:ListEditItem Text="Certificate" Value="1" />
                                    <dx:ListEditItem Text="Diploma" Value="2" />
                                    <dx:ListEditItem Text="Bachelors Degree" Value="3" />
                                    <dx:ListEditItem Text="Post Grad. Diploma" Value="4" />
                                    <dx:ListEditItem Text="Masters Degree" Value="5" />
                                    <dx:ListEditItem Text="Doctorate" Value="6" />
				    <dx:ListEditItem Text="Elementary" Value="0" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Structure And Scores" ShowInCustomizationForm="True" VisibleIndex="10" Width="100px">
                            <EditFormSettings Visible="False" />
                            <DataItemTemplate>
                                <asp:ImageButton ID="cmdStructure" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="cmdStructure_Click" />
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Study System" FieldName="study_system" ShowInCustomizationForm="True" VisibleIndex="5" Width="150px">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="Semester" Value="Semester" />
                                    <dx:ListEditItem Text="Modular" Value="Modular" />
                                    <dx:ListEditItem Text="Trimester" Value="Trimester" />
                                    <dx:ListEditItem Text="Session" Value="Session" />
                                    <dx:ListEditItem Text="Quarter" Value="Quarter" />
                                    <dx:ListEditItem Text="Term" Value="Term" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Course Length" FieldName="couselength" ShowInCustomizationForm="True" VisibleIndex="4" Width="80px">
                            <PropertiesComboBox ValueType="System.Int32">
                                <Items>
                                    <dx:ListEditItem Text="1 Year" Value="1" />
                                    <dx:ListEditItem Text="2 Years" Value="2" />
                                    <dx:ListEditItem Text="3 Years" Value="3" />
                                    <dx:ListEditItem Text="4 Years" Value="4" />
                                    <dx:ListEditItem Text="5 Years" Value="5" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Study Sessions" FieldName="maxduration" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                    <dx:ListEditItem Text="4" Value="4" />
                                    <dx:ListEditItem Text="5" Value="5" />
                                    <dx:ListEditItem Text="6" Value="6" />
                                    <dx:ListEditItem Text="7" Value="7" />
                                    <dx:ListEditItem Text="8" Value="8" />
                                    <dx:ListEditItem Text="9" Value="9" />
                                    <dx:ListEditItem Text="10" Value="10" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsProgrammeInfo" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" 
                    DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update"
                    OnSelecting="dsProgrammeInfo_Selecting">
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
                        <asp:Parameter Name="study_system" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:Parameter DefaultValue="%" Name="txt" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="progname" Type="String" />
                        <asp:Parameter Name="mincredit" Type="Double" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="couselength" Type="Double" />
                        <asp:Parameter Name="maxduration" Type="Double" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="levelCode" Type="UInt32" />
                        <asp:Parameter Name="study_system" Type="String" />
                        <asp:Parameter Name="Original_progcode" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter"></asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <HeaderStyle ForeColor="Red" HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>