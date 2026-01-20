<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ComnicationCentre.ascx.cs" Inherits="UserControls_CommunicationCentre_ComnicationCentre" %>
<style type="text/css">
    .auto-style1 {
        width: 72px;
    }
    .auto-style2 {
        width: 302px;
    }
    .auto-style3 {
        width: 63px;
    }
    .auto-style4 {
        width: 294px;
    }
    .auto-style5 {
        height: 18px;
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
    .auto-style6 {
        width: 700px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table class="dx-justification">
                    <tr>
                        <td class="auto-style1">Faculty</td>
                        <td class="auto-style2">
                            <dx:ASPxComboBox ID="FacultyComboBox1" runat="server" AutoPostBack="True" DataSourceID="Faculty_ODS" Height="40px" TextField="faculty_name" TextFormatString="{0}::{1}" ValueField="faculty_code" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="faculty_code" Width="10px" />
                                    <dx:ListBoxColumn FieldName="faculty_name" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style3">&nbsp;</td>
                        <td class="auto-style4">
                            &nbsp;</td>
                        <td class="auto-style6">&nbsp;</td>
                        <td rowspan="3">
                            <dx:ASPxRoundPanel ID="panel_sms" runat="server" HeaderText="SMS Centre" Width="250px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <PanelCollection>
                                    <dx:PanelContent runat="server">
                                        <table cellpadding="0" cellspacing="0" class="style1">
                                            <tr>
                                                <td align="right" style="width: 248px">
                                                    <dx:ASPxButton ID="cmdSMS" runat="server" OnClick="cmdSMS_Click" Text="Send" Width="100px">
                                                        <Image Url="~/COOPERP/images/arrow-000-medium.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td align="right" style="width: 248px">
                                                    <dx:ASPxButton ID="cmdUpdateList" runat="server" OnClick="cmdUpdateList_Click" Text="Add" Width="100px">
                                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td align="right" style="width: 248px" width="250">
                                                    <dx:ASPxButton ID="cmdClearList" runat="server" OnClick="cmdClearList_Click" Text="Clear" Width="100px">
                                                        <Image Url="~/COOPERP/images/cross-shield.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td align="right">&nbsp;</td>
                                            </tr>
                                        </table>
                                        <dx:ASPxPopupControl ID="pop_sms" runat="server" ContentUrl="~/SMSSender.aspx" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="Middle">
                                            <ContentCollection>
                                                <dx:PopupControlContentControl runat="server">
                                                </dx:PopupControlContentControl>
                                            </ContentCollection>
                                        </dx:ASPxPopupControl>
                                    </dx:PanelContent>
                                </PanelCollection>
                            </dx:ASPxRoundPanel>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Program:</td>
                        <td class="auto-style2">
                            <dx:ASPxComboBox ID="ProgramComboBox1" runat="server" AutoPostBack="True" DataSourceID="Prog_ODS" Height="40px" TextField="progname" TextFormatString="{0}:{1}" ValueField="progcode" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="progcode" Width="10px" />
                                    <dx:ListBoxColumn FieldName="progname" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style3">Session:</td>
                        <td class="auto-style4">
                            <dx:ASPxComboBox ID="SessionComboBox2" runat="server" AutoPostBack="True" Height="40px" Width="300px">
                                <Items>
                                    <dx:ListEditItem Text="-" Value="-" />
                                    <dx:ListEditItem Text="DAY" Value="DAY" />
                                    <dx:ListEditItem Text="MORNING" Value="MORNING" />
                                    <dx:ListEditItem Text="AFTERNOON" Value="AFTERNOON" />
                                    <dx:ListEditItem Text="EVENING" Value="EVENING" />
                                    <dx:ListEditItem Text="WEEKEND" Value="WEEKEND" />
                                    <dx:ListEditItem Text="EXTERNAL" Value="EXTERNAL" />
                                    <dx:ListEditItem Text="IN-SERVICE" Value="IN-SERVICE" />
                                    <dx:ListEditItem Text="DISTANCE" Value="DISTANCE" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style6">&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Entry Year:</td>
                        <td class="auto-style2">
                            <dx:ASPxComboBox ID="EntrYrComboBox2" runat="server" AutoPostBack="True" DataSourceID="EntryYr_ODS" Height="40px" TextField="entryyear" TextFormatString="{0}" ValueField="entryyear" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="entryyear" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style3">Intake:</td>
                        <td class="auto-style4">
                            <dx:ASPxComboBox ID="IntakeComboBox3" runat="server" AutoPostBack="True" Height="40px" Width="300px">
                                <Items>
                                    <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                    <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                    <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                    <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                    <dx:ListEditItem Text="MAY" Value="MAY" />
                                    <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                    <dx:ListEditItem Text="JULY" Value="JULY" />
                                    <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                    <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                    <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                    <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                    <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style6">&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="auto-style5"></td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="SmsGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="Sms_ODS" KeyFieldName="regno" Width="100%">
                    <SettingsPager PageSize="100">
                    </SettingsPager>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <Columns>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="Student No" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Registration No" FieldName="regno" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="First Name" FieldName="firstname" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="dob" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Gender" FieldName="gender" ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="nationality" ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="progid" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Student Contact" FieldName="studPhone" ShowInCustomizationForm="True" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Email" FieldName="email" ShowInCustomizationForm="True" VisibleIndex="10">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="entryyear" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Session " FieldName="studsesion" ShowInCustomizationForm="True" VisibleIndex="12">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="intake" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Other Name " FieldName="othername" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="Sms_ODS" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SmsCentreTableAdapters.acad_GetStudents_SMSTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ProgramComboBox1" Name="pro" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="EntrYrComboBox2" Name="entrYr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="IntakeComboBox3" Name="intk" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="SessionComboBox2" Name="sess" PropertyName="Value" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="Prog_ODS" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SmsCentreTableAdapters.acad_GetProgramsByFCodeTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="FacultyComboBox1" Name="FCode" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="EntryYr_ODS" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SmsCentreTableAdapters.acad_Get_EntryYearsTableAdapter"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="Faculty_ODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_faculty_code" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="faculty_name" Type="String" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="faculty_dean" Type="String" />
                        <asp:Parameter Name="faculty_contacts" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="faculty_name" Type="String" />
                        <asp:Parameter Name="faculty_dean" Type="String" />
                        <asp:Parameter Name="faculty_contacts" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="Original_faculty_code" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <br />
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

