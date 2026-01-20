<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SubscriptionProfile.ascx.cs" Inherits="UserControls_Accounts_SubscriptionProfile" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style2_subprofile
    {
        width: 43px;
    }



*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .style3
    {
        width: 172px;
    }
    .style4
    {
        width: 79px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="style4">
                            Subscription:</td>
                        <td class="style3">
                            <dx:ASPxComboBox ID="txtProducts" runat="server" AutoPostBack="True" 
                                DataSourceID="dsProducts" EnableIncrementalFiltering="True" 
                                IncrementalFilteringMode="StartsWith" TextField="productName" 
                                TextFormatString="{1}" ValueField="productID" ValueType="System.UInt32">
                                <Columns>
                                    <dx:ListBoxColumn Caption="SNo" FieldName="productID" Width="60px" />
                                    <dx:ListBoxColumn Caption="Item" FieldName="productName" Width="200px" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style2_subprofile">
                            Year:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtYear" runat="server" ValueType="System.String" 
                                AutoPostBack="True" EnableIncrementalFiltering="True" 
                                IncrementalFilteringMode="StartsWith">
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvSubscriptions" runat="server" 
                    AutoGenerateColumns="False" DataSourceID="dsSubscriptionProfile" 
                    KeyFieldName="SID" Width="100%">
                    <Columns>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" ShowClearFilterButton="True"/>
                        <dx:GridViewDataTextColumn Caption="Receipt No" FieldName="SID" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="60px">
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="memberID" ShowInCustomizationForm="True" 
                            Visible="False" VisibleIndex="2">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Month" FieldName="sub_month" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Year" FieldName="sub_year" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount Paid" FieldName="sub_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="5" Width="100px">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                            <HeaderStyle HorizontalAlign="Right" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Date Paid" FieldName="datePaid" 
                            ShowInCustomizationForm="True" VisibleIndex="6">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Comments" FieldName="comments" 
                            ShowInCustomizationForm="True" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="PayStatus" ShowInCustomizationForm="True" 
                            VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsSubscriptionProfile" runat="server" 
                    OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetAnnualSubscription" 
                    TypeName="CoopERPDataTableAdapters.fin_subscriptionTableAdapter" 
                    DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_SID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="memberID" Type="String" />
                        <asp:Parameter Name="sub_month" Type="String" />
                        <asp:Parameter Name="sub_year" Type="String" />
                        <asp:Parameter Name="sub_amount" Type="UInt64" />
                        <asp:Parameter Name="comments" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="memID" SessionField="memberID" Type="String" 
                            DefaultValue="0" />
                        <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" 
                            Type="Int32" />
                        <asp:ControlParameter ControlID="txtProducts" DefaultValue="0" Name="prodID" 
                            PropertyName="Value" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="memberID" Type="String" />
                        <asp:Parameter Name="sub_month" Type="String" />
                        <asp:Parameter Name="sub_year" Type="String" />
                        <asp:Parameter Name="sub_amount" Type="UInt64" />
                        <asp:Parameter Name="comments" Type="String" />
                        <asp:Parameter Name="Original_SID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsProducts" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_productsTableAdapter">
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

