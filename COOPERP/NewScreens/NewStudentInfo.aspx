<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewStudentInfo.aspx.cs" Inherits="COOPERP_NewScreens_NewStudentInfo" Title="Student Records - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Filter row */
        .cd-filter-row {
            display: flex;
            gap: 10px;
            padding: 8px 12px;
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
            flex-wrap: wrap;
            align-items: center;
        }
        .cd-filter-row__label {
            font-size: 11px;
            color: #666;
        }
        .cd-filter-select {
            border: 1px solid #ddd;
            padding: 4px 8px;
            font-size: 11px;
            min-width: 140px;
            background: #fff;
        }
        .cd-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        
        /* Student Preview Modal */
        .student-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        .student-modal-overlay.show {
            display: flex;
        }
        .student-modal {
            background: #fff;
            width: 700px;
            max-width: 95%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        .student-modal__header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            background: #174DA4;
            color: #fff;
        }
        .student-modal__title {
            font-size: 14px;
            font-weight: 600;
            margin: 0;
        }
        .student-modal__close {
            background: none;
            border: none;
            color: #fff;
            cursor: pointer;
            padding: 4px;
            font-size: 18px;
            line-height: 1;
        }
        .student-modal__close:hover {
            opacity: 0.8;
        }
        .student-modal__body {
            padding: 16px;
        }
        .student-modal__photo-section {
            display: flex;
            gap: 16px;
            margin-bottom: 16px;
            padding-bottom: 16px;
            border-bottom: 1px solid #e0e0e0;
        }
        .student-modal__photo {
            width: 100px;
            height: 120px;
            object-fit: cover;
            border: 2px solid #e0e0e0;
            background: #f5f5f5;
        }
        .student-modal__basic-info {
            flex: 1;
        }
        .student-modal__name {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin: 0 0 4px 0;
        }
        .student-modal__regno {
            font-size: 13px;
            color: #174DA4;
            font-weight: 500;
            margin-bottom: 8px;
        }
        .student-modal__programme {
            font-size: 12px;
            color: #666;
        }
        .student-modal__section {
            margin-bottom: 16px;
        }
        .student-modal__section-title {
            font-size: 12px;
            font-weight: 600;
            color: #174DA4;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
            padding-bottom: 4px;
            border-bottom: 2px solid #174DA4;
        }
        .student-modal__grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }
        .student-modal__field {
            display: flex;
            flex-direction: column;
        }
        .student-modal__field-label {
            font-size: 10px;
            color: #888;
            text-transform: uppercase;
            margin-bottom: 2px;
        }
        .student-modal__field-value {
            font-size: 12px;
            color: #333;
            font-weight: 500;
        }
        .student-modal__footer {
            display: flex;
            justify-content: flex-end;
            gap: 8px;
            padding: 12px 16px;
            background: #f5f5f5;
            border-top: 1px solid #e0e0e0;
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
        
        // Student Preview Modal Functions
        function showStudentPreview(regno, entryno, firstname, othername, gender, dob, nationality, religion, phone, email, district, programme, specialisation, entryyear, intake, session, campus, photofile) {
            closeAllPopovers();
            
            var modal = document.getElementById('studentPreviewModal');
            
            // Set photo
            var photoImg = document.getElementById('modalStudentPhoto');
            if (photofile && photofile !== '-' && photofile !== 'N/A') {
                photoImg.src = '<%= ResolveUrl("~/COOPERP/StudentInfo/photos/") %>' + photofile;
            } else {
                photoImg.src = '<%= ResolveUrl("~/COOPERP/StudentInfo/photos/default.png") %>';
            }
            
            // Set basic info
            document.getElementById('modalStudentName').innerText = (firstname || '') + ' ' + (othername || '');
            document.getElementById('modalStudentRegno').innerText = entryno || regno;
            document.getElementById('modalStudentProgramme').innerText = programme || '-';
            
            // Set personal details
            document.getElementById('modalGender').innerText = gender || '-';
            document.getElementById('modalDOB').innerText = dob || '-';
            document.getElementById('modalNationality').innerText = nationality || '-';
            document.getElementById('modalReligion').innerText = religion || '-';
            document.getElementById('modalPhone').innerText = phone || '-';
            document.getElementById('modalEmail').innerText = email || '-';
            document.getElementById('modalDistrict').innerText = district || '-';
            
            // Set academic details
            document.getElementById('modalEntryYear').innerText = entryyear || '-';
            document.getElementById('modalIntake').innerText = intake || '-';
            document.getElementById('modalSession').innerText = session || '-';
            document.getElementById('modalCampus').innerText = campus || '-';
            document.getElementById('modalSpecialisation').innerText = specialisation || '-';
            
            modal.classList.add('show');
        }
        
        function closeStudentPreview() {
            document.getElementById('studentPreviewModal').classList.remove('show');
        }
        
        // Close modal on overlay click
        document.addEventListener('DOMContentLoaded', function() {
            var modal = document.getElementById('studentPreviewModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === modal) {
                        closeStudentPreview();
                    }
                });
            }
        });
        
        // Close modal on Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeStudentPreview();
            }
        });
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    
    <div class="cd-card">
        <!-- Quick Filters -->
        <div class="cd-filter-row">
            <span class="cd-filter-row__label">Filter:</span>
            <asp:DropDownList ID="ddlFilterFaculty" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterFaculty_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Faculties --"></asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterEntryYear" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterEntryYear_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Entry Years --"></asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterSession" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged">
                <asp:ListItem Value="" Text="-- All Sessions --"></asp:ListItem>
            </asp:DropDownList>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvStudents" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="regno" Width="100%" ClientInstanceName="gvStudents"
                OnRowUpdating="gvStudents_RowUpdating" OnRowDeleting="gvStudents_RowDeleting"
                EnableTheming="True" Theme="Glass" EnableCallBacks="true">
                
                <SettingsPager PageSize="25" AlwaysShowPager="true" Position="Bottom">
                    <Summary Text="Page {0} of {1} ({2} students)" />
                </SettingsPager>
                
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="PopupEditForm" />
                <SettingsDataSecurity AllowDelete="False" />
                
                <SettingsPopup>
                    <EditForm Width="600px" Height="450px" HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" Modal="True" />
                </SettingsPopup>
                
                <EditFormLayoutProperties ColCount="2">
                    <Items>
                        <dx:GridViewLayoutGroup Caption="Personal Information" ColCount="2" ColSpan="2">
                            <Items>
                                <dx:GridViewColumnLayoutItem ColumnName="entryno"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="regno"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="firstname"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="othername"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="gender"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="dob"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="nationality"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="religion"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studPhone"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="email"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="home_dist"></dx:GridViewColumnLayoutItem>
                            </Items>
                        </dx:GridViewLayoutGroup>
                        <dx:GridViewLayoutGroup Caption="Academic Information" ColCount="2" ColSpan="2">
                            <Items>
                                <dx:GridViewColumnLayoutItem ColumnName="progid"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="specialisation"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="entryyear"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="intake"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studsesion"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studCampus"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="gradSystemID"></dx:GridViewColumnLayoutItem>
                            </Items>
                        </dx:GridViewLayoutGroup>
                        <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right"></dx:EditModeCommandLayoutItem>
                    </Items>
                </EditFormLayoutProperties>
                
                <Columns>
                    <dx:GridViewDataTextColumn Caption="Reg No" FieldName="entryno" VisibleIndex="0" Width="150px">
                        <CellStyle Font-Bold="True"></CellStyle>
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Entry No" FieldName="regno" VisibleIndex="1" Width="100px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="First Name" FieldName="firstname" VisibleIndex="2" Width="120px">
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Other Names" FieldName="othername" VisibleIndex="3" Width="150px">
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Gender" FieldName="gender" VisibleIndex="4" Width="70px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="MALE" Value="MALE" />
                                <dx:ListEditItem Text="FEMALE" Value="FEMALE" />
                            </Items>
                        </PropertiesComboBox>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataDateColumn Caption="DOB" FieldName="dob" VisibleIndex="5" Width="90px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataDateColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" VisibleIndex="6" Width="100px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Religion" FieldName="religion" VisibleIndex="7" Visible="False">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="MUSLIM" Value="MUSLIM" />
                                <dx:ListEditItem Text="CHRISTIAN" Value="CHRISTIAN" />
                                <dx:ListEditItem Text="CATHOLIC" Value="CATHOLIC" />
                                <dx:ListEditItem Text="PROTESTANT" Value="PROTESTANT" />
                                <dx:ListEditItem Text="ADVENTIST" Value="ADVENTIST" />
                                <dx:ListEditItem Text="ANGLICAN" Value="ANGLICAN" />
                                <dx:ListEditItem Text="ORTHODOX" Value="ORTHODOX" />
                                <dx:ListEditItem Text="PENTACOSTAL" Value="PENTACOSTAL" />
                                <dx:ListEditItem Text="SDA" Value="SDA" />
                                <dx:ListEditItem Text="OTHERS" Value="OTHERS" />
                            </Items>
                        </PropertiesComboBox>
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Phone" FieldName="studPhone" VisibleIndex="8" Width="100px">
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Email" FieldName="email" VisibleIndex="9" Width="150px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Home District" FieldName="home_dist" VisibleIndex="10" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Programme" FieldName="progname" VisibleIndex="11" Width="200px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="progid" VisibleIndex="12" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Specialisation" FieldName="specialisation" VisibleIndex="13" Width="100px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="entryyear" VisibleIndex="14" Width="70px">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Intake" FieldName="intake" VisibleIndex="15" Width="80px" Visible="False">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                <dx:ListEditItem Text="MAY" Value="MAY" />
                                <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                <dx:ListEditItem Text="JULY" Value="JULY" />
                                <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                            </Items>
                        </PropertiesComboBox>
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Session" FieldName="studsesion" VisibleIndex="16" Width="80px">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Campus" FieldName="studCampus" VisibleIndex="17" Width="80px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Grading System" FieldName="gradSystemID" VisibleIndex="18" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="photofile" Visible="False" VisibleIndex="19">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn VisibleIndex="20" Caption=" " Width="40px" 
                        Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item">
                                            <button type="button" class="cd-action-popover__btn cd-action-popover__btn--view" onclick="showStudentPreview('<%# Eval("regno") %>', '<%# Eval("entryno") %>', '<%# Eval("firstname") %>', '<%# Eval("othername") %>', '<%# Eval("gender") %>', '<%# Eval("dob", "{0:dd/MM/yyyy}") %>', '<%# Eval("nationality") %>', '<%# Eval("religion") %>', '<%# Eval("studPhone") %>', '<%# Eval("email") %>', '<%# Eval("home_dist") %>', '<%# Eval("progname") %>', '<%# Eval("specialisation") %>', '<%# Eval("entryyear") %>', '<%# Eval("intake") %>', '<%# Eval("studsesion") %>', '<%# Eval("studCampus") %>', '<%# Eval("photofile") %>')">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                                Preview
                                            </button>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <button type="button" class="cd-action-popover__btn cd-action-popover__btn--edit" onclick="gridEditRow('gvStudents', '<%# Container.KeyValue %>')">
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                                Edit
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
                
                <SettingsCommandButton>
                    <EditButton>
                        <Image IconID="edit_edit_16x16"></Image>
                    </EditButton>
                    <UpdateButton RenderMode="Link"></UpdateButton>
                    <CancelButton RenderMode="Link"></CancelButton>
                </SettingsCommandButton>
                
                <Styles>
                    <Header Font-Size="11px" />
                    <Cell Font-Size="11px" Paddings-Padding="4px" />
                    <FilterRow Font-Size="10px" />
                </Styles>
                
            </dx:ASPxGridView>
        </div>
    </div>
    
    <!-- Student Preview Modal -->
    <div id="studentPreviewModal" class="student-modal-overlay">
        <div class="student-modal">
            <div class="student-modal__header">
                <h3 class="student-modal__title">Student Details</h3>
                <button type="button" class="student-modal__close" onclick="closeStudentPreview()">&times;</button>
            </div>
            <div class="student-modal__body">
                <div class="student-modal__photo-section">
                    <img id="modalStudentPhoto" class="student-modal__photo" src="" alt="Student Photo" onerror="this.src='<%= ResolveUrl("~/COOPERP/StudentInfo/photos/default.png") %>'" />
                    <div class="student-modal__basic-info">
                        <h2 id="modalStudentName" class="student-modal__name">-</h2>
                        <div id="modalStudentRegno" class="student-modal__regno">-</div>
                        <div id="modalStudentProgramme" class="student-modal__programme">-</div>
                    </div>
                </div>
                
                <div class="student-modal__section">
                    <h4 class="student-modal__section-title">Personal Information</h4>
                    <div class="student-modal__grid">
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Gender</span>
                            <span id="modalGender" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Date of Birth</span>
                            <span id="modalDOB" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Nationality</span>
                            <span id="modalNationality" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Religion</span>
                            <span id="modalReligion" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Phone</span>
                            <span id="modalPhone" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Email</span>
                            <span id="modalEmail" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Home District</span>
                            <span id="modalDistrict" class="student-modal__field-value">-</span>
                        </div>
                    </div>
                </div>
                
                <div class="student-modal__section">
                    <h4 class="student-modal__section-title">Academic Information</h4>
                    <div class="student-modal__grid">
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Entry Year</span>
                            <span id="modalEntryYear" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Intake</span>
                            <span id="modalIntake" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Session</span>
                            <span id="modalSession" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Campus</span>
                            <span id="modalCampus" class="student-modal__field-value">-</span>
                        </div>
                        <div class="student-modal__field">
                            <span class="student-modal__field-label">Specialisation</span>
                            <span id="modalSpecialisation" class="student-modal__field-value">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="student-modal__footer">
                <button type="button" class="cd-btn" onclick="closeStudentPreview()">Close</button>
            </div>
        </div>
    </div>
    
</asp:Content>
