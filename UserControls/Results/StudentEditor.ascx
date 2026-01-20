<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentEditor.ascx.cs" Inherits="COOPERP_StudentInfo_StudentEditor" %>
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
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">

                <dx:ASPxCallbackPanel ID="CBP_Students" runat="server" ClientInstanceName="CBP_Students" OnCallback="CBP_Students_Callback" Width="100%">
                    <ClientSideEvents EndCallback="function(s, e) {
	pop_messagebox.Show();
}" />
                    <PanelCollection>
                        <dx:PanelContent runat="server">
                            <table class="style1">
                                <tr>
                                    <td>
                                        <table cellpadding="0" cellspacing="0" class="style1">
                                            <tr>
                                                <td style="text-align: center">
                                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_student_info.png">
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
                                                    <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click1" Text="Add New" Width="170px">
                                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                    <dx:ASPxButton ID="cmdSpecs" runat="server" OnClick="cmdSpecs_Click" Text="Specialisations" Width="170px">
                                                        <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td style="text-align: right" width="170px">
                                                    <dx:ASPxTextBox ID="txtSearch" runat="server" AutoCompleteType="Search" Height="27px" NullText="Enter Search Text" Width="170px">
                                                        <ClientSideEvents TextChanged="function(s, e) {
	gvStudentInfo.Refresh();
}" />
                                                        <Paddings PaddingLeft="5px" />
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td style="text-align: right" width="20px">
                                                    <dx:ASPxCallbackPanel ID="CPB_Export" runat="server" ClientInstanceName="CPB_Export" OnCallback="CPB_Export_Callback">
                                                        <PanelCollection>
                                                            <dx:PanelContent runat="server">
                                                                <dx:ASPxButton ID="cmdExport" runat="server" OnClick="cmdExport_Click">
                                                                    <Image Url="~/COOPERP/images/export_excel.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </dx:PanelContent>
                                                        </PanelCollection>
                                                    </dx:ASPxCallbackPanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvStudentInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvStudentInfo" DataSourceID="dsStudentInfo" KeyFieldName="regno" Width="100%">
                                           <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
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
                                                <dx:GridViewDataTextColumn Caption="Entry No" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="1">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Registration No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="First Name" FieldName="firstname" ShowInCustomizationForm="True" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn Caption="Birth Date" FieldName="dob" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" ShowInCustomizationForm="True" VisibleIndex="7">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Religion" FieldName="religion" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Entry Method" FieldName="entrymethod" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Student Phone" FieldName="studPhone" ShowInCustomizationForm="True" VisibleIndex="11">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Email" FieldName="email" ShowInCustomizationForm="True" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="entryyear" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Home District" FieldName="home_dist" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Surname" FieldName="othername" ShowInCustomizationForm="True" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Duration" FieldName="duration" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Photo File" FieldName="photofile" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                </dx:GridViewCommandColumn>
                                                
                                                <dx:GridViewDataTextColumn Caption="Profile" ShowInCustomizationForm="True" VisibleIndex="23" Width="50px">
                                                    <EditFormSettings Visible="False" />
                                                    <DataItemTemplate>
                                                        <asp:ImageButton ID="cmdDetails" runat="server" ImageUrl="~/COOPERP/images/card-address.png" OnClick="cmdDetails_Click" />
                                                    </DataItemTemplate>
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="progid" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                    <PropertiesComboBox DataSourceID="dsProgrammeInfo" IncrementalFilteringMode="Contains" TextField="progname" TextFormatString="{1}" ValueField="progcode">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                                            <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="350px" />
                                                            <dx:ListBoxColumn Caption="Abbrev" FieldName="abbrev" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Intake" FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="18">
                                                    <PropertiesComboBox IncrementalFilteringMode="StartsWith">
                                                        <Items>
                                                            <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                                            <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                                            <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                                            <dx:ListEditItem Text="MAY" Value="MAY" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Session" FieldName="studsesion" ShowInCustomizationForm="True" VisibleIndex="15">
                                                    <PropertiesComboBox IncrementalFilteringMode="StartsWith">
                                                        <Items>
                                                            <dx:ListEditItem Text="DAY" Value="DAY" />
                                                            <dx:ListEditItem Text="EVENING" Value="EVENING" />
                                                            <dx:ListEditItem Text="WEEKEND" Value="WEEKEND" />
                                                            <dx:ListEditItem Text="EXTERNAL" Value="EXTERNAL" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Gender" FieldName="gender" ShowInCustomizationForm="True" VisibleIndex="6">
                                                    <PropertiesComboBox IncrementalFilteringMode="StartsWith">
                                                        <Items>
                                                            <dx:ListEditItem Text="MALE" Value="MALE" />
                                                            <dx:ListEditItem Text="FEMALE" Value="FEMALE" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Grading System" FieldName="gradSystemID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                    <PropertiesComboBox DataSourceID="dsGradingSys" IncrementalFilteringMode="Contains" TextField="gs_name" TextFormatString="{1}" ValueField="ID">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="SNo" FieldName="ID" Width="50px" />
                                                            <dx:ListBoxColumn Caption="Grading System" FieldName="gs_name" Width="250px" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Specialisation" FieldName="specialisation" ShowInCustomizationForm="True" Visible="False" VisibleIndex="26">
                                                    <PropertiesComboBox DataSourceID="dsSpecialisations" IncrementalFilteringMode="Contains" TextField="specialisation" TextFormatString="{0}" ValueField="specialisation">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="Specialisation" FieldName="specialisation" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewCommandColumn ButtonRenderMode="Image" ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="27" Width="40px">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn Caption="Results Sync" ShowInCustomizationForm="True" VisibleIndex="25" Width="50px">
                                                    <DataItemTemplate>
                                                        <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/COOPERP/images/arrow-retweet.png" OnClick="ImageButton1_Click" />
                                                    </DataItemTemplate>
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                            <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                                            </SettingsPager>
                                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridViewExporter ID="GVE_Students" runat="server" GridViewID="gvStudentInfo">
                                        </dx:ASPxGridViewExporter>
                                        <asp:ObjectDataSource ID="dsSpecialisations" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_specialisationsTableAdapter"></asp:ObjectDataSource>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="dsStudentInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetStudentSearch" TypeName="StudentDataTableAdapters.acad_studentTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_regno" Type="String" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="entryno" Type="String" />
                                                <asp:Parameter Name="regno" Type="String" />
                                                <asp:Parameter Name="firstname" Type="String" />
                                                <asp:Parameter Name="dob" Type="DateTime" />
                                                <asp:Parameter Name="gender" Type="String" />
                                                <asp:Parameter Name="nationality" Type="String" />
                                                <asp:Parameter Name="religion" Type="String" />
                                                <asp:Parameter Name="entrymethod" Type="String" />
                                                <asp:Parameter Name="progid" Type="String" />
                                                <asp:Parameter Name="studPhone" Type="String" />
                                                <asp:Parameter Name="email" Type="String" />
                                                <asp:Parameter Name="entryyear" Type="Int32" />
                                                <asp:Parameter Name="studsesion" Type="String" />
                                                <asp:Parameter Name="home_dist" Type="String" />
                                                <asp:Parameter Name="intake" Type="String" />
                                                <asp:Parameter Name="gradSystemID" Type="Int32" />
                                                <asp:Parameter Name="othername" Type="String" />
                                                <asp:Parameter Name="duration" Type="UInt32" />
                                                <asp:Parameter Name="photofile" Type="String" />
                                                <asp:Parameter Name="specialisation" Type="String" />
                                            </InsertParameters>
                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="txtSearch" DefaultValue="%" Name="txt" PropertyName="Text" Type="String" />
                                            </SelectParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="entryno" Type="String" />
                                                <asp:Parameter Name="firstname" Type="String" />
                                                <asp:Parameter Name="dob" Type="DateTime" />
                                                <asp:Parameter Name="gender" Type="String" />
                                                <asp:Parameter Name="nationality" Type="String" />
                                                <asp:Parameter Name="religion" Type="String" />
                                                <asp:Parameter Name="entrymethod" Type="String" />
                                                <asp:Parameter Name="progid" Type="String" />
                                                <asp:Parameter Name="studPhone" Type="String" />
                                                <asp:Parameter Name="email" Type="String" />
                                                <asp:Parameter Name="entryyear" Type="Int32" />
                                                <asp:Parameter Name="studsesion" Type="String" />
                                                <asp:Parameter Name="home_dist" Type="String" />
                                                <asp:Parameter Name="intake" Type="String" />
                                                <asp:Parameter Name="gradSystemID" Type="Int32" />
                                                <asp:Parameter Name="othername" Type="String" />
                                                <asp:Parameter Name="duration" Type="Int32" />
                                                <asp:Parameter Name="specialisation" Type="String" />
                                                <asp:Parameter Name="Original_regno" Type="String" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsGradingSys" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllGradingSystems" TypeName="ResultsDataTableAdapters.acad_gradingsystemTableAdapter"></asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsProgrammeInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" UpdateMethod="Update">
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
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                            <HeaderStyle HorizontalAlign="Center" />
                                            <ContentCollection>
                                                <dx:PopupControlContentControl runat="server">
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
                                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
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
                </dx:ASPxCallbackPanel>
            </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>