<%@ Control Language="C#" AutoEventWireup="true" CodeFile="GradindDetails.ascx.cs" Inherits="UserControls_Faculty_GradindDetails" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<style type="text/css">


*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}
    .style1 {
        width:100%;
    }


    .auto-style2 {
        width: 170px;
    }


    </style>

<dx:ASPxRoundPanel ID="rp_details" runat="server" HeaderText="DETAILS OF NCHE 2015 GRADING SYSTEM" ShowCollapseButton="true" Width="100%">
    <HeaderStyle ForeColor="Red" HorizontalAlign="Center" />
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <dx:ASPxCallbackPanel ID="CBP_Marks" runat="server" ClientInstanceName="CBP_Marks" OnCallback="CBP_Marks_Callback" Width="100%">
        <ClientSideEvents EndCallback="function(s, e) {
	gvMarksheet.Refresh();
	pop_DetailsMsg.Show();
}" />
        <PanelCollection>
            <dx:PanelContent ID="PanelContent2" runat="server">
                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                    <TabPages>
                        <dx:TabPage Text="Grading System">
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdApprove" runat="server" AutoPostBack="False" Text="Add New" Width="170px">
                                                    <ClientSideEvents Click="function(s, e) {
	CBP_Marks.PerformCallback();
}" />
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="gvMarksheet" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheet" DataSourceID="dsGradingDetails" KeyFieldName="ID" Width="100%">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="gsID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Grade Points" FieldName="gradep" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                                                            <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Lower Limit" FieldName="min_mark" ShowInCustomizationForm="True" VisibleIndex="3" Width="60px">
                                                            <CellStyle HorizontalAlign="Center">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Upper Limit" FieldName="max_mark" ShowInCustomizationForm="True" VisibleIndex="4" Width="60px">
                                                            <CellStyle HorizontalAlign="Center">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="7" Width="25px">
                                                        </dx:GridViewCommandColumn>
                                                    </Columns>
                                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                    <SettingsEditing Mode="Batch">
                                                        <BatchEditSettings StartEditAction="DblClick" />
                                                    </SettingsEditing>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="dsGradingDetails" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetGradingSysDetails" TypeName="ResultsDataTableAdapters.acad_gs_detailsTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="gsID" Type="UInt32" />
                                                        <asp:Parameter Name="grade" Type="String" />
                                                        <asp:Parameter Name="gradep" Type="Double" />
                                                        <asp:Parameter Name="min_mark" Type="UInt32" />
                                                        <asp:Parameter Name="max_mark" Type="UInt32" />
                                                    </InsertParameters>
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="0" Name="gid" SessionField="gsid" Type="Int32" />
                                                    </SelectParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="gsID" Type="UInt32" />
                                                        <asp:Parameter Name="grade" Type="String" />
                                                        <asp:Parameter Name="gradep" Type="Double" />
                                                        <asp:Parameter Name="min_mark" Type="UInt32" />
                                                        <asp:Parameter Name="max_mark" Type="UInt32" />
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxPopupControl ID="pop_DetailsMsg" runat="server" ClientInstanceName="pop_DetailsMsg" CloseAction="CloseButton" DisappearAfter="10" HeaderText="Academica ERP Version 3.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ContentCollection>
                                                        <dx:PopupControlContentControl runat="server">
                                                            <table align="center" class="style1">
                                                                <tr>
                                                                    <td align="center">
                                                                        <br />
                                                                        <br />
                                                                        <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                                                                        </dx:ASPxLabel>
                                                                        <br />
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
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text="Award Grading">
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <dx:ASPxCallbackPanel ID="CBP_Award" runat="server" ClientInstanceName="CBP_Award" OnCallback="CBP_Award_Callback" Width="100%">
                                        <ClientSideEvents EndCallback="function(s, e) {
	gvAwardList.Refresh();
	pop_AwardDetailsMsg.Show();
}" />
                                        <PanelCollection>
                                            <dx:PanelContent runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td>
                                                            <table class="style1">
                                                                <tr>
                                                                    <td>
                                                                        <dx:ASPxButton ID="cmdAddAward" runat="server" AutoPostBack="False" Text="Add New" Width="170px">
                                                                            <ClientSideEvents Click="function(s, e) {
	CBP_Award.PerformCallback(&quot;Award&quot;);
}" />
                                                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td class="auto-style2" style="text-align: right">
                                                                        <dx:ASPxComboBox ID="txtLevel" runat="server" Height="25px" SelectedIndex="2">
                                                                            <ClientSideEvents CloseUp="function(s, e) {
	gvAwardList.Refresh();
}" />
                                                                            <Items>
                                                                                <dx:ListEditItem Text="Certificate" Value="Certificate" />
                                                                                <dx:ListEditItem Text="Diploma" Value="Diploma" />
                                                                                <dx:ListEditItem Selected="True" Text="Bachelors" Value="Bachelors" />
                                                                                <dx:ListEditItem Text="Masters" Value="Masters" />
                                                                         <dx:ListEditItem Text="Post graduate" Value="Postgraduate" />
   </Items>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxGridView ID="gvAwardList" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvAwardList" DataSourceID="dsAwardGrading" KeyFieldName="ID" Width="100%">
                                                                <Columns>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="gsID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Lower Limit" FieldName="lowerlim" ShowInCustomizationForm="True" VisibleIndex="3" Width="80px">
                                                                        <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                                                        </PropertiesTextEdit>
                                                                        <CellStyle HorizontalAlign="Center">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Upper Limit" FieldName="upperlim" ShowInCustomizationForm="True" VisibleIndex="4" Width="80px">
                                                                        <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                                                        </PropertiesTextEdit>
                                                                        <CellStyle HorizontalAlign="Center">
                                                                        </CellStyle>
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Award" FieldName="award" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Level" FieldName="acad_level" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="7" Width="40px">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                                    </dx:GridViewCommandColumn>
                                                                </Columns>
                                                                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                                <SettingsEditing Mode="Batch">
                                                                    <BatchEditSettings StartEditAction="DblClick" />
                                                                </SettingsEditing>
                                                            </dx:ASPxGridView>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:ObjectDataSource ID="dsAwardGrading" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAwardDetails" TypeName="ResultsDataTableAdapters.acad_gs_awardTableAdapter" UpdateMethod="Update">
                                                                <DeleteParameters>
                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                </DeleteParameters>
                                                                <InsertParameters>
                                                                    <asp:Parameter Name="gsID" Type="UInt32" />
                                                                    <asp:Parameter Name="lowerlim" Type="Double" />
                                                                    <asp:Parameter Name="upperlim" Type="Double" />
                                                                    <asp:Parameter Name="award" Type="String" />
                                                                    <asp:Parameter Name="acad_level" Type="String" />
                                                                </InsertParameters>
                                                                <SelectParameters>
                                                                    <asp:SessionParameter DefaultValue="0" Name="gid" SessionField="gsid" Type="Int32" />
                                                                    <asp:ControlParameter ControlID="txtLevel" Name="lev" PropertyName="Value" Type="String" />
                                                                </SelectParameters>
                                                                <UpdateParameters>
                                                                    <asp:Parameter Name="gsID" Type="UInt32" />
                                                                    <asp:Parameter Name="lowerlim" Type="Double" />
                                                                    <asp:Parameter Name="upperlim" Type="Double" />
                                                                    <asp:Parameter Name="award" Type="String" />
                                                                    <asp:Parameter Name="acad_level" Type="String" />
                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                </UpdateParameters>
                                                            </asp:ObjectDataSource>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxPopupControl ID="pop_AwardDetailsMsg" runat="server" ClientInstanceName="pop_DetailsMsg" CloseAction="CloseButton" DisappearAfter="10" HeaderText="Academica ERP Version 3.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ContentCollection>
                                                                    <dx:PopupControlContentControl runat="server">
                                                                        <table align="center" class="style1">
                                                                            <tr>
                                                                                <td align="center">
                                                                                    <br />
                                                                                    <br />
                                                                                    <dx:ASPxLabel ID="lbl_AwardComment" runat="server" ForeColor="Red">
                                                                                    </dx:ASPxLabel>
                                                                                    <br />
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
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                    </TabPages>
                </dx:ASPxPageControl>
            </dx:PanelContent>
        </PanelCollection>
    </dx:ASPxCallbackPanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

