<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentFeesPaySchedule.aspx.cs" Inherits="COOPERP_financials_FeesPaySchedule" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        .auto-style4 {
            width: 55px;
        }
        .auto-style5 {
            width: 189px;
        }
        .auto-style6 {
            width: 68px;
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
    width:100%;
}
    


    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Fees Schedule" Width="100%" ShowHeader="False">
            <HeaderStyle HorizontalAlign="Center">
            <Paddings Padding="10px" />
            </HeaderStyle>
            <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="dx-justification">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_billimgsys.png">
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
                <table class="dx-justification">
                    <tr>
                        <td class="auto-style4">&nbsp;</td>
                        <td class="auto-style5">&nbsp;</td>
                        <td class="auto-style6">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style4">Year:</td>
                        <td class="auto-style5">
                            <dx:ASPxComboBox ID="txtYear" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                    <dx:ListEditItem Text="4" Value="4" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style6">Semester:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style4">&nbsp;</td>
                        <td class="auto-style5">&nbsp;</td>
                        <td class="auto-style6">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style4">&nbsp;</td>
                        <td class="auto-style5">&nbsp;</td>
                        <td class="auto-style6">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvFeesSchedule" runat="server" AutoGenerateColumns="False" DataSourceID="dsFeesSchedule" KeyFieldName="ID" OnHtmlDataCellPrepared="gvFeesSchedule_HtmlDataCellPrepared" Width="100%">
                    <SettingsContextMenu Enabled="True">
                    </SettingsContextMenu>
                    <SettingsEditing Mode="Batch">
                        <BatchEditSettings StartEditAction="Click" />
                    </SettingsEditing>
                    <Settings ShowFooter="True" />
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="ItemID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="studyyear" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="semester" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" VisibleIndex="4">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount" ShowInCustomizationForm="True" VisibleIndex="6" Width="100px">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                            </FooterCellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="curr_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="progid" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Session" FieldName="stud_session" ShowInCustomizationForm="True" VisibleIndex="9" Width="80px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <TotalSummary>
                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="amount" ShowInColumn="Amount" ShowInGroupFooterColumn="Amount" SummaryType="Sum" />
                    </TotalSummary>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsFeesSchedule" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetProgrammeFeesPaySchedule" TypeName="StudentAccountingDataTableAdapters.fin_fees_pay_scheduleTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="ItemID" Type="UInt32" />
                        <asp:Parameter Name="studyyear" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="amount" Type="Double" />
                        <asp:Parameter Name="curr_year" Type="UInt32" />
                        <asp:Parameter Name="progid" Type="String" />
                        <asp:Parameter Name="stud_session" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="prog" SessionField="prog" Type="String" />
                        <asp:SessionParameter Name="eyr" SessionField="eyr" Type="Int32" />
                        <asp:ControlParameter ControlID="txtYear" Name="cyr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtSemester" Name="sems" PropertyName="Value" Type="Int32" />
                        <asp:SessionParameter Name="sess" SessionField="sess" Type="String" />
                        <asp:SessionParameter DefaultValue="0" Name="bid" SessionField="bid" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="ItemID" Type="UInt32" />
                        <asp:Parameter Name="studyyear" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="amount" Type="Double" />
                        <asp:Parameter Name="curr_year" Type="UInt32" />
                        <asp:Parameter Name="progid" Type="String" />
                        <asp:Parameter Name="stud_session" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsBillingItems" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentAccountingDataTableAdapters.academicbillingitemsTableAdapter"></asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
