<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BioData.ascx.cs" Inherits="UserControls_StudentInfo_BioData" %>
<style type="text/css">
    .style1_Bio {
        width: 100%;
    }
    .style2_Bio {
        height: 22px;
    }
    .style3_Bio {
        font-weight:bold;
        width:150px;
    }
    .style4_Bio {
        width:250px;
    }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    </style>

<table class="style1_Bio">
    <tr>
        <td>
            <dx:ASPxGridView ID="gvStudentBiodata" runat="server" DataSourceID="dsBioData" OnDataBound="gvStudentBiodata_DataBound" Width="100%" AutoGenerateColumns="False" KeyFieldName="regno">
                <Templates>
                    <DataRow>
                        <table class="style1_Bio">
                            <tr>
                                <td colspan="4" style="text-align: center">&nbsp;</td>
                                <td rowspan="13" style="text-align: center" valign="top">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" Height="100px" ShowLoadingImage="True" ImageUrl='<%# Eval("photofile", "~/COOPERP/StudentInfo/Photos/{0}") %>'>
                                    </dx:ASPxImage>
                                    <br />
                                    <br />
                                    <dx:ASPxImage ID="ASPxImage3" runat="server" Height="50px" ImageUrl='<%# Eval("signfile", "~/COOPERP/StudentInfo/signs/{0}") %>'  ShowLoadingImage="True" Width="100px">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" style="text-align: center">
                                    <asp:Label ID="othernameLabel" runat="server" ForeColor="Maroon" style="font-weight: 700; font-size: large;" Text='<%# Eval("othername") %>' />
                                    <asp:Label ID="firstnameLabel" runat="server" ForeColor="Maroon" style="font-weight: 700; font-size: large;" Text='<%# Eval("firstname") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="true" Width="100%">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: 700" class="style3_Bio">Registration No:</td>
                                <td>
                                    <asp:Label ID="regnoLabel" runat="server" Text='<%# Eval("regno") %>' />
                                </td>
                                <td class="style3_Bio">Nationality:</td>
                                <td>
                                    <asp:Label ID="nationalityLabel" runat="server" Text='<%# Eval("nationality") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">Entry No:</td>
                                <td>
                                    <asp:Label ID="entrynoLabel" runat="server" Text='<%# Eval("entryno") %>' />
                                </td>
                                <td class="style3_Bio">Religion:</td>
                                <td>
                                    <asp:Label ID="religionLabel" runat="server" Text='<%# Eval("religion") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">Birth Date:</td>
                                <td>
                                    <asp:Label ID="dobLabel" runat="server" Text='<%# Eval("dob", "{0:dd MMMM, yyyy}") %>' />
                                </td>
                                <td class="style3_Bio">Entry Method:</td>
                                <td>
                                    <asp:Label ID="entrymethodLabel" runat="server" Text='<%# Eval("entrymethod") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">Gender:</td>
                                <td>
                                    <asp:Label ID="genderLabel" runat="server" Text='<%# Eval("gender") %>' />
                                </td>
                                <td class="style3_Bio">Phone:</td>
                                <td>
                                    <asp:Label ID="studPhoneLabel" runat="server" Text='<%# Eval("studPhone") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">Programme:</td>
                                <td>
                                    <asp:Label ID="progidLabel" runat="server" Text='<%# Eval("progname") %>' />
                                </td>
                                <td class="style3_Bio">Email:</td>
                                <td>
                                    <asp:Label ID="emailLabel" runat="server" Text='<%# Eval("email") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">Entry Year:</td>
                                <td>
                                    <asp:Label ID="entryyearLabel" runat="server" Text='<%# Eval("entryyear") %>' />
                                </td>
                                <td class="style3_Bio">Session:</td>
                                <td>
                                    <asp:Label ID="studsesionLabel" runat="server" Text='<%# Eval("studsesion") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">Home District</td>
                                <td>
                                    <asp:Label ID="home_distLabel" runat="server" Text='<%# Eval("home_dist") %>' />
                                </td>
                                <td class="style3_Bio">Intake:</td>
                                <td>
                                    <asp:Label ID="intakeLabel" runat="server" Text='<%# Eval("intake") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">Grading System:</td>
                                <td>
                                    <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text='<%# Eval("gradSystem") %>'>
                                    </dx:ASPxLabel>
                                </td>
                                <td class="style3_Bio">Course Duration:</td>
                                <td>
                                    <asp:Label ID="durationLabel" runat="server" Text='<%# Eval("duration", "{0} Year[s]") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">&nbsp;</td>
                                <td>&nbsp;</td>
                                <td class="style3_Bio">&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="style3_Bio">&nbsp;</td>
                                <td>&nbsp;</td>
                                <td class="style3_Bio">&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </DataRow>
                </Templates>
                <SettingsPager NumericButtonCount="1" PageSize="1">
                </SettingsPager>
                <Settings ShowColumnHeaders="False" />
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="entryno" VisibleIndex="0">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="regno" ReadOnly="True" VisibleIndex="1">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="firstname" VisibleIndex="2">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataDateColumn FieldName="dob" VisibleIndex="3">
                    </dx:GridViewDataDateColumn>
                    <dx:GridViewDataTextColumn FieldName="gender" VisibleIndex="4">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="nationality" VisibleIndex="5">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="religion" VisibleIndex="6">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="entrymethod" VisibleIndex="7">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progid" VisibleIndex="8">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="studPhone" VisibleIndex="9">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="email" VisibleIndex="10">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="entryyear" VisibleIndex="11">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="studsesion" VisibleIndex="12">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="home_dist" VisibleIndex="13">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="intake" VisibleIndex="14">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="gradSystemID" VisibleIndex="15">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="othername" VisibleIndex="16">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="duration" VisibleIndex="17">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="photofile" VisibleIndex="18">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progname" VisibleIndex="19">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="gradSystem" VisibleIndex="20">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="specialisation" VisibleIndex="21">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="signfile" VisibleIndex="22">
                    </dx:GridViewDataTextColumn>
                </Columns>
            </dx:ASPxGridView>
        </td>
    </tr>
    <tr>
        <td>
            <asp:ObjectDataSource ID="dsBioData" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetBioData" TypeName="StudentDataTableAdapters.acad_studentTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_regno" Type="String" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="entryno" Type="String" />
                    <asp:Parameter Name="regno" Type="String" />
                    <asp:Parameter Name="firstname" Type="String" />
                    <asp:Parameter Name="dob" Type="DateTime" />
                    <asp:Parameter Name="gender" Type="String" />
                    <asp:Parameter Name="nationality" Type="String" />
                    <asp:Parameter Name="religion" Type="String" />
                    <asp:Parameter Name="entrymethod" Type="String" />
                    <asp:Parameter Name="progid" Type="String" />
                    <asp:Parameter Name="studPhone" Type="String" />
                    <asp:Parameter Name="email" Type="String" />
                    <asp:Parameter Name="entryyear" Type="Int32" />
                    <asp:Parameter Name="studsesion" Type="String" />
                    <asp:Parameter Name="home_dist" Type="String" />
                    <asp:Parameter Name="intake" Type="String" />
                    <asp:Parameter Name="gradSystemID" Type="Int32" />
                    <asp:Parameter Name="othername" Type="String" />
                    <asp:Parameter Name="duration" Type="UInt32" />
                    <asp:Parameter Name="photofile" Type="String" />
                    <asp:Parameter Name="specialisation" Type="String" />
                </InsertParameters>
                <SelectParameters>
                    <asp:SessionParameter DefaultValue="-" Name="reg" SessionField="regno" Type="String" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="entryno" Type="String" />
                    <asp:Parameter Name="firstname" Type="String" />
                    <asp:Parameter Name="dob" Type="DateTime" />
                    <asp:Parameter Name="gender" Type="String" />
                    <asp:Parameter Name="nationality" Type="String" />
                    <asp:Parameter Name="religion" Type="String" />
                    <asp:Parameter Name="entrymethod" Type="String" />
                    <asp:Parameter Name="progid" Type="String" />
                    <asp:Parameter Name="studPhone" Type="String" />
                    <asp:Parameter Name="email" Type="String" />
                    <asp:Parameter Name="entryyear" Type="Int32" />
                    <asp:Parameter Name="studsesion" Type="String" />
                    <asp:Parameter Name="home_dist" Type="String" />
                    <asp:Parameter Name="intake" Type="String" />
                    <asp:Parameter Name="gradSystemID" Type="Int32" />
                    <asp:Parameter Name="othername" Type="String" />
                    <asp:Parameter Name="duration" Type="Int32" />
                    <asp:Parameter Name="specialisation" Type="String" />
                    <asp:Parameter Name="Original_regno" Type="String" />
                </UpdateParameters>
            </asp:ObjectDataSource>
        </td>
    </tr>
</table>

