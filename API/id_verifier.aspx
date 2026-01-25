<%@ Page Language="C#" AutoEventWireup="true" CodeFile="id_verifier.aspx.cs" Inherits="API_id_verifier" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <table class="auto-style1">
            <tr>
                <td>
                    <dx:ASPxCardView ID="cvCardData" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="dsIDData">
                        <SettingsPager>
                            <SettingsTableLayout ColumnCount="1" RowsPerPage="1" />
                        </SettingsPager>
                        <SettingsBehavior AllowFocusedCard="True" />
                        <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                        <SettingsText EmptyCard="Invalid ID Card No" />
                        <Columns>
                            <dx:CardViewTextColumn Caption="Student Name" FieldName="studnames" VisibleIndex="0">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn Caption="Programme" FieldName="programme" VisibleIndex="1">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn Caption="Faculty" FieldName="faxname" VisibleIndex="2">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn FieldName="ID" VisibleIndex="5">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn Caption="Registration No" FieldName="reg_no" VisibleIndex="6">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn Caption="Academic Year" FieldName="acadyear" VisibleIndex="7">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn Caption="Semester" FieldName="semester" VisibleIndex="8">
                            </dx:CardViewTextColumn>
                            <dx:CardViewDateColumn Caption="Date Created" FieldName="date_created" VisibleIndex="14">
                                <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                                </PropertiesDateEdit>
                            </dx:CardViewDateColumn>
                            <dx:CardViewTextColumn Caption="Expiry" FieldName="expiry_date" VisibleIndex="15">
                            </dx:CardViewTextColumn>
                            <dx:CardViewImageColumn Caption="Photo" FieldName="photofile" VisibleIndex="4">
                                <PropertiesImage ImageHeight="80px" ImageUrlFormatString="~/COOPERP/StudentInfo/photos/{0}">
                                </PropertiesImage>
                            </dx:CardViewImageColumn>
                        </Columns>
                        <CardLayoutProperties>
                            <Items>
                                <dx:CardViewCommandLayoutItem HorizontalAlign="Right">
                                </dx:CardViewCommandLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="photofile">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="studnames">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="programme">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="faxname">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="ID">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="reg_no">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="acadyear">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="semester">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="date_created">
                                </dx:CardViewColumnLayoutItem>
                                <dx:CardViewColumnLayoutItem ColumnName="expiry_date">
                                </dx:CardViewColumnLayoutItem>
                                <dx:EditModeCommandLayoutItem HorizontalAlign="Right">
                                </dx:EditModeCommandLayoutItem>
                            </Items>
                        </CardLayoutProperties>
                    </dx:ASPxCardView>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:ObjectDataSource ID="dsIDData" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_IDVerificationTableAdapter">
                        <SelectParameters>
                            <asp:QueryStringParameter DefaultValue="0" Name="idno" QueryStringField="id" Type="Int32" />
                        </SelectParameters>
                    </asp:ObjectDataSource>
                </td>
            </tr>
        </table>
    
    </div>
    </form>
</body>
</html>
