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
                                        <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/gradstud_header.png" ShowLoadingImage="True" style="margin-left: 0px">
                                        </dx:ASPxImage>
                                        <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  ShowLoadingImage="True" Width="100%">
                                        </dx:ASPxImage>
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
                                        <dx:ASPxGridView ID="gvStudentInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvStudentInfo" DataSourceID="dsgraduateStd" KeyFieldName="progcode" Width="100%">
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
                                                <dx:GridViewDataTextColumn FieldName="progcode" ShowInCustomizationForm="True" VisibleIndex="0" ReadOnly="True" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="progname" ShowInCustomizationForm="True" VisibleIndex="1" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="mincredit" ShowInCustomizationForm="True" VisibleIndex="2" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="abbrev" ShowInCustomizationForm="True" VisibleIndex="3" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="couselength" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="maxduration" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="faculty_code" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="levelCode" ShowInCustomizationForm="True" VisibleIndex="7" Visible="False">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Entry No" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="8" Width="10px">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Registration No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="9" ReadOnly="True">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="First Name" FieldName="firstname" ShowInCustomizationForm="True" VisibleIndex="10">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="dob" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn Caption="Gender" FieldName="gender" ShowInCustomizationForm="True" VisibleIndex="13">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" ShowInCustomizationForm="True" VisibleIndex="14">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="religion" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="entrymethod" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="progid" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Student Phone No" FieldName="studPhone" ShowInCustomizationForm="True" VisibleIndex="18">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Email" FieldName="email" ShowInCustomizationForm="True" VisibleIndex="19">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="entryyear" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="studsesion" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="home_dist" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="intake" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="gradSystemID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                                </dx:GridViewDataTextColumn>
                                                
                                                <dx:GridViewDataTextColumn Caption="Other Name" ShowInCustomizationForm="True" VisibleIndex="11" FieldName="othername">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="duration" ShowInCustomizationForm="True" Visible="False" VisibleIndex="25">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="photofile" ShowInCustomizationForm="True" Visible="False" VisibleIndex="26">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="specialisation" ShowInCustomizationForm="True" Visible="False" VisibleIndex="27">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Profile" ShowInCustomizationForm="True" VisibleIndex="28" Width="10px">
                                                    <DataItemTemplate>
                                                        <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/COOPERP/images/card-address.png" OnClick="ImageButton1_Click" />
                                                    </DataItemTemplate>
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
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
                                        <asp:ObjectDataSource ID="dsgraduateStd" runat="server" DataObjectTypeName="GraduateData+acad_GraduateListDataTable" DeleteMethod="Fill" InsertMethod="Fill" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_GraduateListTableAdapter" UpdateMethod="Update">
                                            <UpdateParameters>
                                                <asp:Parameter Name="reg" Type="String" />
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
                            </table>
                        </dx:PanelContent>
                    </PanelCollection>
                </dx:ASPxCallbackPanel>
            </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>