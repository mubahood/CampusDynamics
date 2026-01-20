<%@ Control Language="C#" AutoEventWireup="true" CodeFile="scholarshipsmanagement.ascx.cs" Inherits="UserControls_financials_scholarshipsmanagement" %>
<style type="text/css">
.style1
{
width:100%;
}



    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
        
    }


    .auto-style1 {
        width: 105px;
    }


    </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" 
        HeaderText="Scholarship &amp; Bursary Management Centre" Width="100%" ShowHeader="False">
        <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel3" runat="server">
        <ContentTemplate>
            <table class="style1">
                <tr>
                    <td>
                        <table class="style1" id="table1" cellpadding="0" cellspacing="0">
                            <tr>
                                <td style="text-align: center;">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_scholarship_mg.png" >
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  Width="100%">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <table class="style1">
                            <tr>
                                <td class="auto-style1">Scholarship:</td>
                                <td style="width: 202px">
                                    <dx:ASPxComboBox ID="txtScholarships" runat="server" AutoPostBack="True" DataSourceID="dsScholarships" Height="35px" TextField="scholarshipName" TextFormatString="{1}" ValueField="scholarshipID" ValueType="System.Int32" Width="300px" SelectedIndex="0">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="SNo" FieldName="scholarshipID" Width="25px" />
                                            <dx:ListBoxColumn Caption="Scholarship" FieldName="scholarshipName" Width="200px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td style="width: 37px">
                                    <dx:ASPxButton ID="cmdScholarships" runat="server" AutoPostBack="False" Height="35px" OnClick="cmdScholarships_Click" Text="..." Width="25px">
                                    </dx:ASPxButton>
                                </td>
                                <td style="width: 150px">
                                    <dx:ASPxTextBox ID="txtAccountSearch" runat="server" Height="35px" NullText="Eg 02512" OnTextChanged="txtAccountSearch_TextChanged" Width="200px">
                                    </dx:ASPxTextBox>
                                </td>
                                <td>
                                    <dx:ASPxButton ID="cmdSearch" runat="server" Height="35px" OnClick="txtAccountSearch_TextChanged" Text="Search" Width="120px">
                                        <Image Url="~/COOPERP/images/magnifier.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style1">Semester:</td>
                                <td style="width: 202px">
                                    <dx:ASPxComboBox ID="txtTerm" runat="server" AutoPostBack="True" Height="35px" onselectedindexchanged="txtClass_NumberChanged" SelectedIndex="0" ValueType="System.String" Width="300px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                            <dx:ListEditItem Text="5" Value="5" />
                                            <dx:ListEditItem Text="6" Value="6" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td style="width: 37px">&nbsp;</td>
                                <td style="width: 150px">
                                    <dx:ASPxComboBox ID="txtRegNo" runat="server" AutoPostBack="True" DataSourceID="dsStudentSearch" Height="35px" TextField="stud_names" TextFormatString="{1}" ValueField="regno" Width="200px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Reg Number" FieldName="stud_names" Width="150px" />
                                            <dx:ListBoxColumn Caption="Name" FieldName="stud_names" Width="200px" />
                                            <dx:ListBoxColumn Caption="Details" FieldName="details" Width="250px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">Academic Year:</td>
                                <td style="width: 202px">
                                    <dx:ASPxComboBox ID="txtAcadYear" runat="server" Height="35px" ValueType="System.String" Width="300px">
                                    </dx:ASPxComboBox>
                                </td>
                                <td style="width: 37px">&nbsp;</td>
                                <td style="width: 150px">
                                    <dx:ASPxButton ID="cmdAdd" runat="server" Height="35px" onclick="cmdAdd_Click" Text="Add Student" Width="200px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style1">&nbsp;</td>
                                <td style="width: 202px">&nbsp;</td>
                                <td style="width: 37px">&nbsp;</td>
                                <td style="width: 150px">
                                    <dx:ASPxButton ID="cmdPrint" runat="server" Height="35px" onclick="cmdPrint_Click" Text="Print List" Width="200px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvStudents" runat="server" AutoGenerateColumns="False" 
                            DataSourceID="dsScholarshipStudents" KeyFieldName="stid" Width="100%" OnHtmlDataCellPrepared="gvStudents_HtmlDataCellPrepared">
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" ShowClearFilterButton="True"/>
                                <dx:GridViewDataTextColumn FieldName="stid" ReadOnly="True" Visible="False" 
                                    VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Admission No" FieldName="adm_no" 
                                    VisibleIndex="2" Width="150px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Scholarship No" FieldName="scholarshipID" 
                                    Visible="False" VisibleIndex="4">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Term" FieldName="scholarhipTerm" 
                                    Visible="False" VisibleIndex="5">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Year" FieldName="scholarhipYear" 
                                    Visible="False" VisibleIndex="6">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Amount Due" FieldName="amountDue" 
                                    VisibleIndex="7" Width="100px">
                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                    </PropertiesTextEdit>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Name" FieldName="stud_name" 
                                    VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ButtonType="Image" VisibleIndex="8" Width="45px" ShowClearFilterButton="True" ShowEditButton="True" ShowDeleteButton="True"/>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                                <EditButton>
                                    <Image Url="~/COOPERP/images/clipboard--pencil.png" ToolTip="Edit">
                                    </Image>
                                </EditButton>
                                <DeleteButton>
                                    <Image Url="~/COOPERP/images/minus-button.png" ToolTip="Delete">
                                    </Image>
                                </DeleteButton>
                            </SettingsCommandButton>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsStudentSearch" runat="server" 
                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                            TypeName="StudentAccountingDataTableAdapters.fin_StudentLedgerSearchTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAccountSearch" DefaultValue="-" 
                                    Name="reg" PropertyName="Text" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsScholarships" runat="server" 
                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                            TypeName="StudentAccountingDataTableAdapters.scholarshipsTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_scholarshipID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="scholarshipName" Type="String" />
                                <asp:Parameter Name="scholarshipdetails" Type="String" />
                                <asp:Parameter Name="percentagePay" Type="Double" />
                            </InsertParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="scholarshipName" Type="String" />
                                <asp:Parameter Name="scholarshipdetails" Type="String" />
                                <asp:Parameter Name="percentagePay" Type="Double" />
                                <asp:Parameter Name="Original_scholarshipID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsScholarshipStudents" runat="server" 
                            DeleteMethod="Delete" InsertMethod="Insert" 
                            OldValuesParameterFormatString="original_{0}" 
                            SelectMethod="GetScholarshipStudent" 
                            TypeName="StudentAccountingDataTableAdapters.scholarshipstudentsTableAdapter" 
                            UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_stid" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="adm_no" Type="String" />
                                <asp:Parameter Name="scholarshipID" Type="UInt32" />
                                <asp:Parameter Name="scholarhipTerm" Type="UInt32" />
                                <asp:Parameter Name="scholarhipYear" Type="String" />
                                <asp:Parameter Name="amountDue" Type="UInt64" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtScholarships" DefaultValue="0" Name="sid" 
                                    PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtAcadYear" Name="yr" PropertyName="Value" 
                                    Type="String" DefaultValue="" />
                                <asp:ControlParameter ControlID="txtTerm" Name="trm" PropertyName="Value" 
                                    Type="Int32" DefaultValue="0" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="adm_no" Type="String" />
                                <asp:Parameter Name="scholarshipID" Type="UInt32" />
                                <asp:Parameter Name="scholarhipTerm" Type="UInt32" />
                                <asp:Parameter Name="scholarhipYear" Type="String" />
                                <asp:Parameter Name="amountDue" Type="UInt64" />
                                <asp:Parameter Name="Original_stid" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_scholarships" runat="server" HeaderText="" 
                            PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="Middle">
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl3" runat="server" SupportsDisabledAttribute="True">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <br />
                                                <br />
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" ForeColor="Red" style="font-weight: 700;">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style3">
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
        </ContentTemplate>
    </asp:UpdatePanel>
            </dx:PanelContent>
</PanelCollection>
    </dx:ASPxRoundPanel>
