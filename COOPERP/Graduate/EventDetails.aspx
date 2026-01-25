<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EventDetails.aspx.cs" Inherits="COOPERP_Graduate_EventDetails" %>

<%@ Register src="../../UserControls/StudentInfo/RegistrationHistory.ascx" tagname="registrationhistory" tagprefix="uc3" %>
<%@ Register src="../../UserControls/Results/StudentResults.ascx" tagname="studentresults" tagprefix="uc2" %>
<%@ Register src="../../UserControls/StudentInfo/BioData.ascx" tagname="biodata" tagprefix="uc1" %>

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


        .auto-style1 {
            width: 100%;
        }
        .auto-style2 {
            width: 27px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" Width="100%">
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                    <TabPages>
                        <dx:TabPage Text="Event Days">
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="auto-style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="btn_newDay" runat="server" OnClick="btn_newDay_Click" Text="Add New" Width="170px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus1.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="eventDayGV" runat="server" AutoGenerateColumns="False" DataSourceID="EventDayODS" KeyFieldName="Id" Width="100%">
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="Edit" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="5" Width="10px">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataDateColumn Caption="Date" FieldName="date" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataDateColumn>
                                                        <dx:GridViewDataTextColumn Caption="Day Comment" FieldName="dayComment" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Eid" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn Caption="Day No" FieldName="dayNo" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesComboBox>
                                                                <Items>
                                                                    <dx:ListEditItem Text="Day 1" Value="Day 1" />
                                                                    <dx:ListEditItem Text="Day 2" Value="Day 2" />
                                                                    <dx:ListEditItem Text="Day 3" Value="Day 3" />
                                                                </Items>
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="EventDayODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataByDay" TypeName="GraduateDataTableAdapters.acad_event_daysTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="dayNo" Type="String" />
                                                        <asp:Parameter Name="date" Type="DateTime" />
                                                        <asp:Parameter Name="dayComment" Type="String" />
                                                        <asp:Parameter Name="Eid" Type="UInt32" />
                                                    </InsertParameters>
                                                    <SelectParameters>
                                                        <asp:SessionParameter Name="eid" SessionField="Id" Type="Int32" />
                                                    </SelectParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="dayNo" Type="String" />
                                                        <asp:Parameter Name="date" Type="DateTime" />
                                                        <asp:Parameter Name="dayComment" Type="String" />
                                                        <asp:Parameter Name="Eid" Type="UInt32" />
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="EventODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_research_eventsTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="event_name" Type="String" />
                                                        <asp:Parameter Name="event_type" Type="String" />
                                                        <asp:Parameter Name="start_date" Type="DateTime" />
                                                        <asp:Parameter Name="end_date" Type="DateTime" />
                                                        <asp:Parameter Name="no_days" Type="UInt32" />
                                                        <asp:Parameter Name="campus" Type="String" />
                                                        <asp:Parameter Name="venue" Type="String" />
                                                        <asp:Parameter Name="regno" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="event_name" Type="String" />
                                                        <asp:Parameter Name="event_type" Type="String" />
                                                        <asp:Parameter Name="start_date" Type="DateTime" />
                                                        <asp:Parameter Name="end_date" Type="DateTime" />
                                                        <asp:Parameter Name="no_days" Type="UInt32" />
                                                        <asp:Parameter Name="campus" Type="String" />
                                                        <asp:Parameter Name="venue" Type="String" />
                                                        <asp:Parameter Name="regno" Type="String" />
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
                        <dx:TabPage Text="Students By Day">
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="auto-style1">
                                        <tr>
                                            <td class="auto-style2">Day:&nbsp;&nbsp; </td>
                                            <td>
                                                <dx:ASPxComboBox ID="day_combbox" runat="server" AutoPostBack="True" DataSourceID="days" TextField="dayNo" ValueField="Id">
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="new_stdbyDay" runat="server" OnClick="new_stdbyDay_Click" Text="Add New" Width="170px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus1.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <dx:ASPxGridView ID="stdbyDay_GV" runat="server" AutoGenerateColumns="False" DataSourceID="sdtbyDay_ODS" KeyFieldName="Id" Width="100%" OnInitNewRow="stdbyDay_GV_InitNewRow">
                                                    <Columns>
                                                        <dx:GridViewCommandColumn Caption="Edit" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="6">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Caption="SNo" Width="10px">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="1" Caption="Registration No">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="marks" ShowInCustomizationForm="True" VisibleIndex="5" Caption="Marks">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="studentname" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Student Name" ReadOnly="True">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="sid" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Supervior">
                                                            <PropertiesComboBox DataSourceID="superviorODS" TextField="supervior_name" ValueField="Id" TextFormatString=" {1}">
                                                                <Columns>
                                                                    <dx:ListBoxColumn FieldName="Id" />
                                                                    <dx:ListBoxColumn FieldName="supervior_name" />
                                                                </Columns>
                                                            </PropertiesComboBox>
                                                        </dx:GridViewDataComboBoxColumn>
                                                        <dx:GridViewDataComboBoxColumn FieldName="dayId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            <PropertiesComboBox DataSourceID="days" TextField="dayNo" TextFormatString="{0}" ValueField="Id">
                                                                <Columns>
                                                                    <dx:ListBoxColumn FieldName="dayNo" />
                                                                </Columns>
                                                            </PropertiesComboBox>
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataComboBoxColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:ObjectDataSource ID="sdtbyDay_ODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy" TypeName="GraduateDataTableAdapters.acad_studentby_dayTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="sid" Type="UInt32" />
                                                        <asp:Parameter Name="dayId" Type="UInt32" />
                                                        <asp:Parameter Name="regno" Type="String" />
                                                        <asp:Parameter Name="marks" Type="Double" />
                                                    </InsertParameters>
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="day_combbox" Name="dayno" PropertyName="Value" Type="Int32" />
                                                    </SelectParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="sid" Type="UInt32" />
                                                        <asp:Parameter Name="dayId" Type="UInt32" />
                                                        <asp:Parameter Name="regno" Type="String" />
                                                        <asp:Parameter Name="marks" Type="Double" />
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="superviorODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_superviorsTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="supervior_name" Type="String" />
                                                        <asp:Parameter Name="contact" Type="String" />
                                                        <asp:Parameter Name="status" Type="String" />
                                                        <asp:Parameter Name="category" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="supervior_name" Type="String" />
                                                        <asp:Parameter Name="contact" Type="String" />
                                                        <asp:Parameter Name="status" Type="String" />
                                                        <asp:Parameter Name="category" Type="String" />
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="days" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_event_daysTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="dayNo" Type="String" />
                                                        <asp:Parameter Name="date" Type="DateTime" />
                                                        <asp:Parameter Name="dayComment" Type="String" />
                                                        <asp:Parameter Name="Eid" Type="UInt32" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="dayNo" Type="String" />
                                                        <asp:Parameter Name="date" Type="DateTime" />
                                                        <asp:Parameter Name="dayComment" Type="String" />
                                                        <asp:Parameter Name="Eid" Type="UInt32" />
                                                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">&nbsp;</td>
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
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
