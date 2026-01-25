<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewCourses.aspx.cs" Inherits="COOPERP_NewScreens_NewCourses" Title="Courses - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .stats-row {
            display: flex;
            gap: 12px;
            margin-bottom: 12px;
        }
        .stat-box {
            background: #fff;
            border: 1px solid #e0e0e0;
            padding: 10px 14px;
            display: flex;
            align-items: center;
            gap: 10px;
            min-width: 140px;
        }
        .stat-box__icon {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #e8f0fa;
            color: #174DA4;
        }
        .stat-box__value {
            font-size: 18px;
            font-weight: 700;
            color: #333;
            line-height: 1;
        }
        .stat-box__label {
            font-size: 10px;
            color: #888;
            text-transform: uppercase;
        }
        .stat-box--active .stat-box__icon {
            background: #e8f5e9;
            color: #388e3c;
        }
        .stat-box--inactive .stat-box__icon {
            background: #ffebee;
            color: #d32f2f;
        }
    </style>
    <script type="text/javascript">
        function toggleActionPopover(btn, e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            var wrapper = btn.parentElement;
            var popover = wrapper.querySelector('.cd-action-popover');
            
            if (!popover) return;
            
            // Close all other popovers first
            document.querySelectorAll('.cd-action-popover.show').forEach(function(p) {
                if (p !== popover) p.classList.remove('show');
            });
            
            // Toggle this popover
            popover.classList.toggle('show');
            
            // Position check - flip if needed
            if (popover.classList.contains('show')) {
                var rect = popover.getBoundingClientRect();
                if (rect.bottom > window.innerHeight) {
                    popover.classList.add('cd-action-popover--top');
                } else {
                    popover.classList.remove('cd-action-popover--top');
                }
            }
        }
        
        function gridEditRow(gridName, keyValue) {
            var grid = ASPxClientControl.GetControlCollection().GetByName(gridName);
            if (grid) {
                grid.StartEditRowByKey(keyValue);
            }
            closeAllPopovers();
        }
        
        function gridDeleteRow(gridName, keyValue) {
            if (confirm('Are you sure you want to delete this record?')) {
                var grid = ASPxClientControl.GetControlCollection().GetByName(gridName);
                if (grid) {
                    grid.DeleteRowByKey(keyValue);
                }
            }
            closeAllPopovers();
        }
        
        function closeAllPopovers() {
            document.querySelectorAll('.cd-action-popover.show').forEach(function(p) {
                p.classList.remove('show');
            });
        }
        
        // Close popovers when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.cd-action-wrapper')) {
                closeAllPopovers();
            }
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <!-- Stats Row -->
    <div class="stats-row">
        <div class="stat-box">
            <div class="stat-box__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
            </div>
            <div>
                <div class="stat-box__value"><asp:Label ID="lblTotalCourses" runat="server" Text="0"></asp:Label></div>
                <div class="stat-box__label">Total Courses</div>
            </div>
        </div>
        <div class="stat-box stat-box--active">
            <div class="stat-box__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
            </div>
            <div>
                <div class="stat-box__value"><asp:Label ID="lblActiveCourses" runat="server" Text="0"></asp:Label></div>
                <div class="stat-box__label">Active</div>
            </div>
        </div>
        <div class="stat-box stat-box--inactive">
            <div class="stat-box__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
            </div>
            <div>
                <div class="stat-box__value"><asp:Label ID="lblInactiveCourses" runat="server" Text="0"></asp:Label></div>
                <div class="stat-box__label">Inactive</div>
            </div>
        </div>
    </div>

    <div class="cd-card">
        <div class="cd-card__header">
            <h3 class="cd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                Course Bank
            </h3>
            <div class="cd-card__actions">
                <asp:LinkButton ID="cmdAddNew" runat="server" CssClass="cd-btn cd-btn--primary cd-btn--sm" OnClick="cmdAddNew_Click">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Add Course
                </asp:LinkButton>
            </div>
        </div>
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvMain" runat="server" AutoGenerateColumns="False" DataSourceID="dsMain" 
                KeyFieldName="courseID" Width="100%" 
                ClientInstanceName="gvCourses"
                EnableTheming="True" Theme="Glass"
                OnRowUpdating="gvMain_RowUpdating"
                OnRowInserting="gvMain_RowInserting"
                EnableCallBacks="true">
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowGroupPanel="False" />
                <SettingsBehavior AllowSort="True" AllowGroup="False" AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="PopupEditForm" />
                <SettingsPager PageSize="25" Mode="ShowPager" />
                <SettingsPopup>
                    <EditForm Width="500px" Modal="True" HorizontalAlign="Center" VerticalAlign="Middle" />
                </SettingsPopup>
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="courseID" VisibleIndex="1" Caption="Code" Width="100px">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Course Code is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="courseName" VisibleIndex="2" Caption="Course Name">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Course Name is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="CreditUnit" VisibleIndex="3" Caption="Credits" Width="70px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="20" NumberType="Float" DecimalPlaces="1">
                        </PropertiesSpinEdit>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="ContactHr" VisibleIndex="4" Caption="Contact Hrs" Width="80px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="100" NumberType="Float" DecimalPlaces="1">
                        </PropertiesSpinEdit>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="LectureHr" VisibleIndex="5" Caption="Lecture Hrs" Width="80px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="100" NumberType="Float" DecimalPlaces="1">
                        </PropertiesSpinEdit>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataSpinEditColumn FieldName="PracticalHr" VisibleIndex="6" Caption="Practical Hrs" Width="85px">
                        <PropertiesSpinEdit MinValue="0" MaxValue="100" NumberType="Float" DecimalPlaces="1">
                        </PropertiesSpinEdit>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataSpinEditColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="CoreStatus" VisibleIndex="7" Caption="Type" Width="90px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="Core" Value="Core" />
                                <dx:ListEditItem Text="Optional" Value="Optional" />
                            </Items>
                        </PropertiesComboBox>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="stat" VisibleIndex="8" Caption="Status" Width="80px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="Active" Value="Active" />
                                <dx:ListEditItem Text="Inactive" Value="Inactive" />
                            </Items>
                        </PropertiesComboBox>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn VisibleIndex="9" Caption=" " Width="40px" 
                        Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item">
                                            <button type="button" class="cd-action-popover__btn cd-action-popover__btn--edit" onclick="gridEditRow('gvCourses', '<%# Container.KeyValue %>')">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                                Edit
                                            </button>
                                        </li>
                                        <li class="cd-action-popover__divider"></li>
                                        <li class="cd-action-popover__item">
                                            <button type="button" class="cd-action-popover__btn cd-action-popover__btn--delete" onclick="gridDeleteRow('gvCourses', '<%# Container.KeyValue %>')">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                                                Delete
                                            </button>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" CssClass="cd-action-cell" />
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Styles>
                    <Header Font-Size="11px" />
                    <Cell Font-Size="11px" Paddings-Padding="4px" />
                    <FilterRow Font-Size="10px" />
                    <CommandColumn Paddings-Padding="2px" />
                </Styles>
                <EditFormLayoutProperties>
                    <Items>
                        <dx:GridViewColumnLayoutItem ColumnName="courseID" Caption="Course Code" />
                        <dx:GridViewColumnLayoutItem ColumnName="courseName" Caption="Course Name" />
                        <dx:GridViewColumnLayoutItem ColumnName="CreditUnit" Caption="Credit Units" />
                        <dx:GridViewColumnLayoutItem ColumnName="ContactHr" Caption="Contact Hours" />
                        <dx:GridViewColumnLayoutItem ColumnName="LectureHr" Caption="Lecture Hours" />
                        <dx:GridViewColumnLayoutItem ColumnName="PracticalHr" Caption="Practical Hours" />
                        <dx:GridViewColumnLayoutItem ColumnName="CoreStatus" Caption="Course Type" />
                        <dx:GridViewColumnLayoutItem ColumnName="stat" Caption="Status" />
                        <dx:EditModeCommandLayoutItem HorizontalAlign="Right" />
                    </Items>
                </EditFormLayoutProperties>
            </dx:ASPxGridView>
        </div>
    </div>
    
    <asp:SqlDataSource ID="dsMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT courseID, courseName, CreditUnit, ContactHr, LectureHr, PracticalHr, CoreStatus, stat FROM acad_course WHERE courseID != '' ORDER BY courseName"
        InsertCommand="INSERT INTO acad_course (courseID, courseName, CreditUnit, ContactHr, LectureHr, PracticalHr, CoreStatus, stat) VALUES (@courseID, @courseName, @CreditUnit, @ContactHr, @LectureHr, @PracticalHr, @CoreStatus, @stat)"
        UpdateCommand="UPDATE acad_course SET courseName=@courseName, CreditUnit=@CreditUnit, ContactHr=@ContactHr, LectureHr=@LectureHr, PracticalHr=@PracticalHr, CoreStatus=@CoreStatus, stat=@stat WHERE courseID=@courseID"
        DeleteCommand="DELETE FROM acad_course WHERE courseID=@courseID">
        <InsertParameters>
            <asp:Parameter Name="courseID" Type="String" />
            <asp:Parameter Name="courseName" Type="String" />
            <asp:Parameter Name="CreditUnit" Type="Double" />
            <asp:Parameter Name="ContactHr" Type="Double" />
            <asp:Parameter Name="LectureHr" Type="Double" />
            <asp:Parameter Name="PracticalHr" Type="Double" />
            <asp:Parameter Name="CoreStatus" Type="String" />
            <asp:Parameter Name="stat" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="courseName" Type="String" />
            <asp:Parameter Name="CreditUnit" Type="Double" />
            <asp:Parameter Name="ContactHr" Type="Double" />
            <asp:Parameter Name="LectureHr" Type="Double" />
            <asp:Parameter Name="PracticalHr" Type="Double" />
            <asp:Parameter Name="CoreStatus" Type="String" />
            <asp:Parameter Name="stat" Type="String" />
            <asp:Parameter Name="courseID" Type="String" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="courseID" Type="String" />
        </DeleteParameters>
    </asp:SqlDataSource>
</asp:Content>
