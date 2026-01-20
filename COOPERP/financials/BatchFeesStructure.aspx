<%@ Page Language="C#" AutoEventWireup="true" CodeFile="BatchFeesStructure.aspx.cs" Inherits="COOPERP_financials_BatchFeesStructure" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">


        *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-bottom: 0;
        
    }


        .auto-style1 {
            width: 100%;
        }
        .auto-style2 {
            width: 205px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="panel_batchfees" runat="server" HeaderText="Batch Fees Sture" ShowCollapseButton="true" Width="100%">
            <HeaderStyle Font-Bold="True" ForeColor="Red" HorizontalAlign="Center">
            <Paddings Padding="15px" />
            </HeaderStyle>
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table class="auto-style1">
                    <tr>
                        <td class="auto-style2">
                            <dx:ASPxButton ID="cmdNew" runat="server" Height="27px" OnClick="cmdNew_Click" Text="Create | Refresh" ToolTip="Bill Selected Students" Width="170px">
                                <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Refresh Billing Items List?');
if(e.processOnServer==true)
{
panel_billling.Show();
}
  }" />
                                <Image IconID="miscellaneous_wizard_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>
                            <dx:ASPxCheckBox ID="chk_apply_all" runat="server" AutoPostBack="True" CheckState="Unchecked" OnCheckedChanged="chk_apply_all_CheckedChanged" Text="Apply Current Amount to Selected">
                                <ClientSideEvents CheckedChanged="function(s, e) {
	e.processOnServer = confirm('Apply amount to selected?');
if(e.processOnServer==true)
{
panel_billling.Show();
}

}" />
                            </dx:ASPxCheckBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvClass" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvClass" DataSourceID="dsBatchFees" KeyFieldName="ID" Width="100%">
                    <SettingsContextMenu Enabled="True" EnableGroupPanelMenu="False">
                    </SettingsContextMenu>
                    <SettingsEditing Mode="Batch">
                        <BatchEditSettings StartEditAction="Click" />
                    </SettingsEditing>
                    <Settings ShowFilterRowMenu="True" ShowFooter="True" />
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsDataSecurity AllowInsert="False" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="ItemCode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2" Width="150px">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Programme" FieldName="progid" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Session" FieldName="studsession" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount" ShowInCustomizationForm="True" VisibleIndex="10" Width="100px">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                            <FooterCellStyle Font-Bold="True" ForeColor="#FF3300">
                            </FooterCellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Current Year" FieldName="curr_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Semester" FieldName="semester" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Year of Study" FieldName="study_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" SelectAllCheckboxMode="AllPages">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="Programme" FieldName="progname" ShowInCustomizationForm="True" VisibleIndex="6">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <TotalSummary>
                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="amount" ShowInColumn="Amount" ShowInGroupFooterColumn="Amount" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                    </TotalSummary>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsBatchFees" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetBatchStructurePerItem" TypeName="StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="ItemCode" Type="UInt32" />
                        <asp:Parameter Name="progid" Type="String" />
                        <asp:Parameter Name="studsession" Type="String" />
                        <asp:Parameter Name="amount" Type="Double" />
                        <asp:Parameter Name="curr_year" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="study_year" Type="UInt32" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="yr" SessionField="yr" Type="Int32" />
                        <asp:SessionParameter Name="cyr" SessionField="cyr" Type="Int32" />
                        <asp:SessionParameter Name="sem" SessionField="semester" Type="Int32" />
                        <asp:SessionParameter Name="sess" SessionField="sess" Type="String" />
                        <asp:SessionParameter Name="Item" SessionField="ItemCode" Type="Int32" />
                        <asp:SessionParameter DefaultValue="0" Name="bid" SessionField="bid" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="ItemCode" Type="UInt32" />
                        <asp:Parameter Name="progid" Type="String" />
                        <asp:Parameter Name="studsession" Type="String" />
                        <asp:Parameter Name="amount" Type="Double" />
                        <asp:Parameter Name="curr_year" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="study_year" Type="UInt32" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxLoadingPanel ID="panel_billling" runat="server" ClientInstanceName="panel_billling" Modal="True" Text="Processing...Please wait&amp;hellip;">
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" CloseAction="CloseButton" HeaderText="Campus Dynamics ERP" Height="150px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="dx-justification">
                                <tr>
                                    <td height="30">
                                        <br />
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
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
        </dx:ASPxRoundPanel>
    
    </div>
    </form>
</body>
</html>
