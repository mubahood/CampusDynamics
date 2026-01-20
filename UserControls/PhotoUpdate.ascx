<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PhotoUpdate.ascx.cs" Inherits="UserControls_PhotoUpdate" %>
<%@ Register src="Accounts/SubscriptionProfile.ascx" tagname="subscriptionprofile" tagprefix="uc2" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style3_photoUpdate
    {
        width: 80px;
    }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Photo &amp; Signature Upload" Width="100%">
    <HeaderImage Url="~/COOPERP/images/user.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td valign="top">
                <dx:ASPxRoundPanel ID="rp_photoupdate" runat="server" ShowHeader="False" 
                    Visible="False" Width="100%">
                    <PanelCollection>
                        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td class="style3_photoUpdate">
                                        Item:</td>
                                    <td>
                                        <dx:ASPxRadioButtonList ID="rb_type" runat="server" AutoPostBack="True" 
                                            OnSelectedIndexChanged="rb_type_SelectedIndexChanged" 
                                            RepeatDirection="Horizontal" SelectedIndex="0" Width="250px">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="Menu Photo" Value="Photo" />
                                                <dx:ListEditItem Text="Menu Icon" Value="Icon" />
                                            </Items>
                                        </dx:ASPxRadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3_photoUpdate">
                                        Image File:
                                    </td>
                                    <td>
                                        <dx:ASPxUploadControl ID="txtFilePath" runat="server" Width="250px">
                                        </dx:ASPxUploadControl>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3_photoUpdate">
                                        &nbsp;</td>
                                    <td>
                                        <dx:ASPxButton ID="cmdPhotoSave" runat="server" OnClick="cmdPhotoSave_Click" 
                                            Text="Update Photo" Width="250px">
                                            <Image Url="~/COOPERP/images/user.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3_photoUpdate">
                                        &nbsp;</td>
                                    <td>
                                        <dx:ASPxImage ID="img_msg" runat="server">
                                        </dx:ASPxImage>
                                        <dx:ASPxLabel ID="lbl_mgsbox" runat="server">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3_photoUpdate">
                                        &nbsp;</td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                            </table>
                        </dx:PanelContent>
                    </PanelCollection>
                </dx:ASPxRoundPanel>
            </td>
            <td valign="top">
                <dx:ASPxGridView ID="gvMembers" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsMemberData" KeyFieldName="memberID" Width="100%">
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="memberID" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="0" Width="60px">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Member No" FieldName="memberno" 
                            ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Surname" FieldName="surname" 
                            ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Other Names" FieldName="othername" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Occupation" FieldName="occupation" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesComboBox DataSourceID="dsOccupations" 
                                IncrementalFilteringMode="Contains" TextField="occupation" 
                                TextFormatString="{1}" ValueField="occupation" ValueType="System.String">
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataDateColumn Caption="Birth Date" FieldName="birthdate" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                            <PropertiesDateEdit DisplayFormatString="">
                            </PropertiesDateEdit>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Post Address" FieldName="postal_address" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Residence" FieldName="residential_adderess" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Marital Status" 
                            FieldName="marital_status" ShowInCustomizationForm="True" VisibleIndex="8">
                            <PropertiesComboBox IncrementalFilteringMode="StartsWith" 
                                ValueType="System.String">
                                <Items>
                                    <dx:ListEditItem Text="MARRIED" Value="MARRIED" />
                                    <dx:ListEditItem Text="DIVORCED" Value="DIVORCED" />
                                    <dx:ListEditItem Text="WIDOWED" Value="WIDOWED" />
                                    <dx:ListEditItem Text="SINGLE" Value="SINGLE" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Mobile No" FieldName="phone_mobile" 
                            ShowInCustomizationForm="True" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Home Phone" FieldName="phone_home" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Work Phone" FieldName="phone_work" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Email" FieldName="email" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Fax" FieldName="fax" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Employer" FieldName="employerID" 
                            ShowInCustomizationForm="True" VisibleIndex="14">
                            <PropertiesComboBox DataSourceID="dsEmployers" 
                                IncrementalFilteringMode="Contains" TextField="employer_name" 
                                TextFormatString="{1}" ValueField="employerID" ValueType="System.Int32">
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Referee Info" FieldName="referee_info" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entered By" FieldName="registeredby" 
                            ReadOnly="True" ShowInCustomizationForm="True" Visible="False" 
                            VisibleIndex="18">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior ConfirmDelete="True" />
                    <SettingsPager PageSize="1">
                    </SettingsPager>
                    <Settings ShowColumnHeaders="False" />
                    <SettingsText CommandCancel="Cancel |" CommandDelete="Delete |" 
                        CommandEdit=" Edit |" CommandUpdate="Save Changes |" 
                        ConfirmDelete="Delete Member" />
                    <Templates>
                        <DataRow>
                            <table class="style1">
                                <tr>
                                    <td align="center">
                                        &nbsp;<dx:ASPxBinaryImage ID="ASPxBinaryImage1" runat="server" 
                                            ContentBytes='<%# Eval("photo") %>' Height="111px" Width="101px">
                                        </dx:ASPxBinaryImage>
                                    </td>
                                </tr>
                            
                                <tr>
                                    <td align="center">
                                        <dx:ASPxBinaryImage ID="ASPxBinaryImage2" runat="server" Height="30px" 
                                            Value='<%# Eval("sign") %>' Width="56px">
                                            <Border BorderStyle="Solid" />
                                        </dx:ASPxBinaryImage>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxLabel ID="ASPxLabel12" runat="server" ForeColor="Blue" 
                                            style="font-weight: 700" Text='<%# Eval("surname") %>'>
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                            </table>
                        </DataRow>
                    </Templates>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <asp:ObjectDataSource ID="dsMemberData" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetMemberSearch" 
                    TypeName="CoopERPDataTableAdapters.mem_membershipTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="" Name="memID" SessionField="memberID" 
                            Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
            <td align="center" valign="top">
                <dx:ASPxButton ID="cmdUpdatePhoto" runat="server" 
                    OnClick="cmdUpdatePhoto_Click" Text="Show Update Panel" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--pencil.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

