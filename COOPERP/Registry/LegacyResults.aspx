<%@ Page Language="C#" AutoEventWireup="true" CodeFile="LegacyResults.aspx.cs" Inherits="COOPERP_Registry_LegacyResults" %>

<%--<%@ Register assembly="DevExpress.Xpo.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Xpo" tagprefix="dx" %>--%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Legacy Results Details" ShowCollapseButton="true" Width="100%">
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvLegacyResults" runat="server" AutoGenerateColumns="False" DataSourceID="dsLegacyResults" KeyFieldName="ID" OnInitNewRow="gvLegacyResults_InitNewRow" Width="100%">
                    <SettingsContextMenu Enabled="True">
                    </SettingsContextMenu>
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Reg No" FieldName="regno" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2" Width="250px">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Course Name" FieldName="courseid" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Semester" FieldName="semester" ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Academic Year" FieldName="acad" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Year" FieldName="studyyear" ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Score" FieldName="score" ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" ShowInCustomizationForm="True" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Grade PT" FieldName="gradept" ShowInCustomizationForm="True" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="GPA" FieldName="gpa" ShowInCustomizationForm="True" VisibleIndex="10">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Comment" FieldName="result_comment" ShowInCustomizationForm="True" VisibleIndex="11">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="CreditUnits" ShowInCustomizationForm="True" VisibleIndex="12">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Prog Code" FieldName="progid" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsLegacyResults" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSingleResults" TypeName="LegacyDataTableAdapters.acad_results_legacyTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="Int32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="courseid" Type="String" />
                        <asp:Parameter Name="semester" Type="Int32" />
                        <asp:Parameter Name="acad" Type="String" />
                        <asp:Parameter Name="studyyear" Type="Int32" />
                        <asp:Parameter Name="score" Type="Int32" />
                        <asp:Parameter Name="grade" Type="String" />
                        <asp:Parameter Name="gradept" Type="Double" />
                        <asp:Parameter Name="gpa" Type="Double" />
                        <asp:Parameter Name="result_comment" Type="String" />
                        <asp:Parameter Name="CreditUnits" Type="Double" />
                        <asp:Parameter Name="progid" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="-" Name="regno" SessionField="reg" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="courseid" Type="String" />
                        <asp:Parameter Name="semester" Type="Int32" />
                        <asp:Parameter Name="acad" Type="String" />
                        <asp:Parameter Name="studyyear" Type="Int32" />
                        <asp:Parameter Name="score" Type="Int32" />
                        <asp:Parameter Name="grade" Type="String" />
                        <asp:Parameter Name="gradept" Type="Double" />
                        <asp:Parameter Name="gpa" Type="Double" />
                        <asp:Parameter Name="result_comment" Type="String" />
                        <asp:Parameter Name="CreditUnits" Type="Double" />
                        <asp:Parameter Name="progid" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
