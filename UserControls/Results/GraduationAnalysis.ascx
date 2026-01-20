<%@ Control Language="C#" AutoEventWireup="true" CodeFile="GraduationAnalysis.ascx.cs" Inherits="COOPERP_Results_GraduationAnalysis" %>
<script runat="server">

    
 
</script>

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
        width: 91px;
    }
    .auto-style2 {
        width: 359px;
    }
    .auto-style4 {
        width: 104px;
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
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_grad_analysis.png">
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
                                <td class="auto-style1">Programme:</td>
                                <td class="auto-style2">
                                    <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="35px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="350px">
                                        <ClientSideEvents TextChanged="function(s, e) {
lp_grads.Show();
	}" />
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                            <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                            <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style4">Grad. Date:</td>
                                <td>
                                    <dx:ASPxDateEdit ID="txtPrintGradDate" runat="server" AutoPostBack="True" DisplayFormatString="dd MMMM, yyyy" Height="35px" Width="200px">
                                    </dx:ASPxDateEdit>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style2">&nbsp;</td>
                                <td class="auto-style4">Export Format:</td>
                                <td>
                                    <dx:ASPxComboBox ID="cbx_Exportformat" runat="server" Height="35px" SelectedIndex="0" Width="200px" AutoPostBack="True">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="pdf" Value="pdf" />
                                            <dx:ListEditItem Text="Excel" Value="Excel" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td class="auto-style2">
                                    <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                                </td>
                                <td class="auto-style4">&nbsp;</td>
                                <td>
                                    <dx:ASPxButton ID="cmdExport" runat="server" Height="35px" OnClick="cmdExportExcel_Click" Text="Export Excel" Width="200px">
                                        <Image IconID="export_export_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPivotGrid ID="PG_GradAnalysis" runat="server" ClientIDMode="AutoID" DataSourceID="dsMarksheetInfo" EnableCallBacks="False" Width="100%">
                            <Fields>
                                <dx:PivotGridField ID="fieldnat" AreaIndex="0" Caption="Nationality" FieldName="nat">
                                </dx:PivotGridField>
                                <dx:PivotGridField ID="fieldgen" Area="ColumnArea" AreaIndex="0" Caption="Gender" FieldName="gen">
                                </dx:PivotGridField>
                                <dx:PivotGridField ID="fieldregno" Area="DataArea" AreaIndex="0" Caption="Popn" FieldName="regno" SummaryType="Count">
                                </dx:PivotGridField>
                                <dx:PivotGridField ID="fieldprognm" AreaIndex="1" Caption="Programme" FieldName="prognm" Area="RowArea">
                                </dx:PivotGridField>
                                <dx:PivotGridField ID="fieldfaculty" Area="RowArea" AreaIndex="0" Caption="Faculty" FieldName="faculty">
                                </dx:PivotGridField>
                            </Fields>
                        </dx:ASPxPivotGrid>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td>
                        &nbsp;</td>
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
                        <dx:ASPxPivotGridExporter ID="GE_UsageStats" runat="server" ASPxPivotGridID="PG_GradAnalysis">
                            <OptionsPrint PrintColumnHeaders="False" PrintDataHeaders="False" PrintFilterHeaders="False" PrintHeadersOnEveryPage="True">
                                <PageSettings Landscape="True" Margins="50, 50, 50, 50" PaperKind="A4" />
                            </OptionsPrint>
                        </dx:ASPxPivotGridExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ResultsDataTableAdapters.acad_Get_GraduationCompletionDataTableAdapter">
                            <SelectParameters>
                                <asp:Parameter DefaultValue="-" Name="acad" Type="String" />
                                <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                                <asp:Parameter DefaultValue="0" Name="yr" Type="Int32" />
                                <asp:Parameter DefaultValue="STATS" Name="cat" Type="String" />
                                <asp:ControlParameter ControlID="txtPrintGradDate" Name="gdt" PropertyName="Value" Type="DateTime" />
                                <asp:Parameter DefaultValue="0" Name="sems" Type="String" />
                                <asp:Parameter DefaultValue="-" Name="intk" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
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
                        
                    </td>
                </tr>
            </table>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="cmdExport" />
        </Triggers>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>