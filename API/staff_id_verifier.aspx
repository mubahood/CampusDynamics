<%@ Page Language="C#" AutoEventWireup="true" CodeFile="staff_id_verifier.aspx.cs" Inherits="API_id_verifier" %>

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
                    <dx:ASPxCardView ID="cvCardData" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="dsIDData" KeyFieldName="ID">
                        <SettingsPager>
                            <SettingsTableLayout ColumnCount="1" RowsPerPage="1" />
                        </SettingsPager>
                        <SettingsBehavior AllowFocusedCard="True" />
                        <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                        <SettingsText EmptyCard="Invalid ID Card No" />
                        <Columns>
                            <dx:CardViewTextColumn Caption="Staff Name" FieldName="emp_name" VisibleIndex="2">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn Caption="Job Name" FieldName="jobName" VisibleIndex="3">
                            </dx:CardViewTextColumn>
                            <dx:CardViewTextColumn Caption="Department" FieldName="dept_name" VisibleIndex="4">
                            </dx:CardViewTextColumn>
                            <dx:CardViewImageColumn Caption="Photo" FieldName="empID" VisibleIndex="0">
                                <PropertiesImage ImageHeight="80px" ImageUrlFormatString="~/COOPERP/staffimages/{0}_photo.jpg">
                                </PropertiesImage>
                            </dx:CardViewImageColumn>
                            <dx:CardViewTextColumn Caption="Staff Code" FieldName="Staff_Code" VisibleIndex="1">
                            </dx:CardViewTextColumn>
                        </Columns>
                    </dx:ASPxCardView>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:ObjectDataSource ID="dsIDData" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="HRMDataTableAdapters.hrm_StaffIDPrintTableAdapter">
                        <SelectParameters>
                            <asp:QueryStringParameter DefaultValue="0" Name="_id" QueryStringField="id" Type="Int32" />
                        </SelectParameters>
                    </asp:ObjectDataSource>
                </td>
            </tr>
        </table>
    
    </div>
    </form>
</body>
</html>
