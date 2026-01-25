<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AddResultChange.aspx.cs" Inherits="COOPERP_Results_AddResultChange" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
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


    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" Width="100%" ShowHeader="False">
            <HeaderStyle HorizontalAlign="Center" />
            <PanelCollection>
<dx:PanelContent runat="server">
    <table align="center" class="style1">
        <tr>
            <td align="center">
                <table class="style1">
                    <tr>
                        <td>
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxLabel ID="lbl_courseInfo" runat="server" ForeColor="Blue" Text="BIT 1101 - COMMUNICATION SKILLS">
                            </dx:ASPxLabel>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxTextBox ID="txtRegNo" runat="server" AutoPostBack="True" NullText="Registration No" OnTextChanged="txtRegNo_TextChanged" Width="100%">
                                <Paddings PaddingLeft="10px" />
                            </dx:ASPxTextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxComboBox ID="txtCourseCode" runat="server" DataSourceID="dsCourseList" IncrementalFilteringMode="Contains" SelectedIndex="1" TextField="course_name" TextFormatString="{0} - {1}" ValueField="course_code" Width="100%">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="course_code" />
                                    <dx:ListBoxColumn Caption="Course Name" FieldName="course_name" Width="250px" />
                                    <dx:ListBoxColumn Caption="Year" FieldName="study_year" />
                                    <dx:ListBoxColumn Caption="Semester" FieldName="semester" />
                                </Columns>
                                <Paddings PaddingLeft="10px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxComboBox ID="txtSemester" runat="server" SelectedIndex="0" Width="100%">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Select Semester" Value="0" />
                                    <dx:ListEditItem Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                </Items>
                                <Paddings PaddingLeft="10px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxComboBox ID="txtStudyYear" runat="server" SelectedIndex="0" Width="100%">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Select Year of Study" Value="0" />
                                    <dx:ListEditItem Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                    <dx:ListEditItem Text="4" Value="4" />
                                    <dx:ListEditItem Text="5" Value="5" />
                                </Items>
                                <Paddings PaddingLeft="10px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxComboBox ID="txtAcadYear" runat="server" Width="100%">
                                <Paddings PaddingLeft="10px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxComboBox ID="txtOperation" runat="server" SelectedIndex="0" Width="100%">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Select Action" Value="-" />
                                    <%--<dx:ListEditItem Text="Add New" Value="Add New" />--%>
                                    <dx:ListEditItem Text="Deletion" Value="Deletion" />
                                    <dx:ListEditItem Text="Updates" Value="Updates" />
                                </Items>
                                <Paddings PaddingLeft="10px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxButton ID="cmdAddPaper" runat="server" OnClick="cmdStatusChange_Click" Text="Add Change" Width="100%">
                                <Image Url="~/COOPERP/images/tick-button.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                </table>
                <br />
                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                </dx:ASPxLabel>
                <br />
                <asp:ObjectDataSource ID="dsCourseList" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetCoursesByRegNo" TypeName="FacultyDataTableAdapters.acad_programmecoursesTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_progcode" Type="String" />
                        <asp:Parameter Name="Original_course_code" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="progcode" Type="String" />
                        <asp:Parameter Name="course_code" Type="String" />
                        <asp:Parameter Name="study_year" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtRegNo" DefaultValue="-" Name="reg" PropertyName="Text" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="study_year" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="Original_progcode" Type="String" />
                        <asp:Parameter Name="Original_course_code" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <br />
                <br />
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
