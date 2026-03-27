<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="DocumentCentre.aspx.cs" Inherits="COOPERP_NewScreens_DocumentCentre" Title="Document Centre - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.8.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<style type="text/css">
/* ---- Page Header ---- */
.cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
.cd-page-header__left { display:flex; align-items:center; gap:12px; }
.cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
/* Document Centre Module Styles - dc- prefix */
.dc-container { padding: 8px; font-size: 11px; }
.dc-header { margin-bottom: 6px; }
.dc-title { font-size: 14px; font-weight: 600; color: #1a1a2e; margin: 0 0 4px 0; }

/* Compact Inline Stats Bar */
.dc-stats-bar { display: flex; align-items: center; gap: 4px; padding: 4px 8px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 4px; font-size: 10px; margin-bottom: 6px; flex-wrap: wrap; }
.dc-stat { display: flex; align-items: center; gap: 3px; padding: 2px 6px; background: #fff; border-radius: 3px; border: 1px solid #dee2e6; }
.dc-stat-label { color: #6c757d; }
.dc-stat-value { font-weight: 600; color: #495057; }
.dc-stat--primary .dc-stat-value { color: #0d6efd; }
.dc-stat--success .dc-stat-value { color: #198754; }
.dc-stat--warning .dc-stat-value { color: #fd7e14; }

/* Filter Toggle Button */
.dc-filter-toggle { margin-left: auto; padding: 3px 8px; font-size: 10px; background: #e7f1ff; border: 1px solid #b6d4fe; border-radius: 3px; color: #0d6efd; cursor: pointer; display: flex; align-items: center; gap: 4px; }
.dc-filter-toggle:hover { background: #cfe2ff; }
.dc-filter-toggle svg { width: 12px; height: 12px; }

/* Collapsible Filter Row */
.dc-filter-row { display: none; padding: 6px 8px; background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; }
.dc-filter-row.show { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.dc-filter-group { display: flex; align-items: center; gap: 3px; }
.dc-filter-group label { font-size: 10px; color: #6c757d; white-space: nowrap; }
.dc-filter-group select { font-size: 10px; padding: 2px 4px; border: 1px solid #ced4da; border-radius: 3px; min-width: 100px; }

/* Batch Actions Bar */
.dc-batch-bar { display: flex; gap: 4px; align-items: center; padding: 4px 8px; background: #fff; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; flex-wrap: wrap; }
.dc-btn { padding: 3px 10px; font-size: 10px; border: 1px solid #dee2e6; border-radius: 3px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; background: #fff; color: #495057; }
.dc-btn:hover { background: #f8f9fa; }
.dc-btn--primary { background: #0d6efd; border-color: #0d6efd; color: #fff; }
.dc-btn--primary:hover { background: #0b5ed7; }
.dc-btn--success { background: #198754; border-color: #198754; color: #fff; }
.dc-btn--success:hover { background: #157347; }
.dc-btn--warning { background: #fd7e14; border-color: #fd7e14; color: #fff; }
.dc-btn--warning:hover { background: #e96e0a; }
.dc-btn--danger { background: #dc3545; border-color: #dc3545; color: #fff; }
.dc-btn--danger:hover { background: #bb2d3b; }

/* Document Type Cards - Compact Grid */
.dc-doc-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 6px; }
.dc-doc-card { padding: 8px 10px; border: 1px solid #e9ecef; border-radius: 4px; cursor: pointer; transition: all 0.15s; display: flex; align-items: center; gap: 8px; background: #fff; }
.dc-doc-card:hover { border-color: #0d6efd; background: #f8f9fa; }
.dc-doc-card.selected { border-color: #0d6efd; background: #e7f1ff; box-shadow: 0 0 0 2px rgba(13, 110, 253, 0.15); }
.dc-doc-card__icon { width: 28px; height: 28px; background: #e9ecef; border-radius: 4px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.dc-doc-card__icon svg { width: 16px; height: 16px; color: #495057; }
.dc-doc-card.selected .dc-doc-card__icon { background: #0d6efd; }
.dc-doc-card.selected .dc-doc-card__icon svg { color: #fff; }
.dc-doc-card__info { flex: 1; min-width: 0; }
.dc-doc-card__title { font-weight: 600; font-size: 10px; color: #1a1a2e; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.dc-doc-card__desc { font-size: 9px; color: #6c757d; margin-top: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* Card */
.dc-card { background: #fff; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; }
.dc-card__header { padding: 6px 10px; background: #f8f9fa; border-bottom: 1px solid #e9ecef; font-weight: 600; font-size: 11px; display: flex; justify-content: space-between; align-items: center; }
.dc-card__body { padding: 8px; }

/* Message Panel */
.dc-message { padding: 6px 10px; border-radius: 4px; font-size: 10px; margin-bottom: 6px; display: none; }
.dc-message.show { display: block; }
.dc-message--success { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
.dc-message--warning { background: #fff3cd; color: #664d03; border: 1px solid #ffecb5; }
.dc-message--error { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }

/* Section Divider */
.dc-section-label { font-size: 9px; font-weight: 600; color: #6c757d; text-transform: uppercase; letter-spacing: 0.5px; margin: 8px 0 6px 0; }
</style>
<script type="text/javascript">
function toggleFilters() {
    var filterRow = document.querySelector('.dc-filter-row');
    if (filterRow) {
        filterRow.classList.toggle('show');
    }
}

function selectDocType(element, value) {
    // Remove selected from all
    var cards = document.querySelectorAll('.dc-doc-card');
    cards.forEach(function(card) {
        card.classList.remove('selected');
    });
    // Add selected to clicked
    element.classList.add('selected');
    // Update hidden field
    document.getElementById('<%= hdnDocumentType.ClientID %>').value = value;
    // Update display
    var displayEl = document.getElementById('selectedDocDisplay');
    if (displayEl) {
        displayEl.innerText = element.querySelector('.dc-doc-card__title').innerText;
    }
}
</script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div class="dc-container">
<!-- ======= PAGE HEADER =========================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
        </div>
        <div>
            <div class="cd-page-header__title">Document Centre</div>
            <div class="cd-page-header__sub">Generate and manage student academic documents</div>
        </div>
    </div>
</div>
    <!-- Stats Bar with Filter Toggle -->
    <div class="dc-stats-bar">
        <div class="dc-stat dc-stat--primary">
            <span class="dc-stat-label">Academic Year:</span>
            <span class="dc-stat-value"><asp:Literal ID="litAcadYearDisplay" runat="server" /></span>
        </div>
        <div class="dc-stat">
            <span class="dc-stat-label">Semester:</span>
            <span class="dc-stat-value"><asp:Literal ID="litSemesterDisplay" runat="server">1</asp:Literal></span>
        </div>
        <div class="dc-stat dc-stat--success">
            <span class="dc-stat-label">Document:</span>
            <span class="dc-stat-value" id="selectedDocDisplay">Marksheet</span>
        </div>
        <button type="button" class="dc-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" /></svg>
            Filters
        </button>
    </div>
    
    <!-- Collapsible Filter Row -->
    <div class="dc-filter-row show">
        <div class="dc-filter-group">
            <label>Programme:</label>
            <asp:DropDownList ID="ddlProgramme" runat="server">
                <asp:ListItem Text="-- Select Programme --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="dc-filter-group">
            <label>Acad Year:</label>
            <asp:DropDownList ID="ddlAcadYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
            </asp:DropDownList>
        </div>
        <div class="dc-filter-group">
            <label>Study Year:</label>
            <asp:DropDownList ID="ddlStudyYear" runat="server">
                <asp:ListItem Text="1" Value="1" Selected="True" />
                <asp:ListItem Text="2" Value="2" />
                <asp:ListItem Text="3" Value="3" />
                <asp:ListItem Text="4" Value="4" />
                <asp:ListItem Text="5" Value="5" />
            </asp:DropDownList>
        </div>
        <div class="dc-filter-group">
            <label>Semester:</label>
            <asp:DropDownList ID="ddlSemester" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                <asp:ListItem Text="1" Value="1" Selected="True" />
                <asp:ListItem Text="2" Value="2" />
            </asp:DropDownList>
        </div>
        <div class="dc-filter-group">
            <label>Entry Year:</label>
            <asp:DropDownList ID="ddlEntryYear" runat="server">
                <asp:ListItem Text="-- All --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="dc-filter-group">
            <label>Intake:</label>
            <asp:DropDownList ID="ddlIntake" runat="server">
                <asp:ListItem Text="-- All --" Value="-" Selected="True" />
                <asp:ListItem Text="JAN" Value="JANUARY" />
                <asp:ListItem Text="FEB" Value="FEBRUARY" />
                <asp:ListItem Text="MAR" Value="MARCH" />
                <asp:ListItem Text="APR" Value="APRIL" />
                <asp:ListItem Text="MAY" Value="MAY" />
                <asp:ListItem Text="JUN" Value="JUNE" />
                <asp:ListItem Text="JUL" Value="JULY" />
                <asp:ListItem Text="AUG" Value="AUGUST" />
                <asp:ListItem Text="SEP" Value="SEPTEMBER" />
                <asp:ListItem Text="OCT" Value="OCTOBER" />
                <asp:ListItem Text="NOV" Value="NOVEMBER" />
                <asp:ListItem Text="DEC" Value="DECEMBER" />
            </asp:DropDownList>
        </div>
    </div>
    
    <!-- Message Panel -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="dc-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>
    
    <!-- Batch Actions Bar -->
    <div class="dc-batch-bar">
        <asp:Button ID="btnPreview" runat="server" Text="Preview" CssClass="dc-btn dc-btn--primary" OnClick="btnPreview_Click" />
        <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="dc-btn dc-btn--success" OnClick="btnPrint_Click" />
        <asp:HiddenField ID="hdnDocumentType" runat="server" Value="Marksheet" />
    </div>
    
    <!-- Document Types Card -->
    <div class="dc-card">
        <div class="dc-card__header">
            <span>Select Document Type</span>
        </div>
        <div class="dc-card__body">
            <!-- Results Documents -->
            <div class="dc-section-label">Results Documents</div>
            <div class="dc-doc-grid">
                <div class="dc-doc-card selected" onclick="selectDocType(this, 'Marksheet')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Marksheet</div>
                        <div class="dc-doc-card__desc">Semester results</div>
                    </div>
                </div>
                <div class="dc-doc-card" onclick="selectDocType(this, 'Results Summary')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Results Summary</div>
                        <div class="dc-doc-card__desc">Overview of results</div>
                    </div>
                </div>
                <div class="dc-doc-card" onclick="selectDocType(this, 'Redo Marksheet')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Redo Marksheet</div>
                        <div class="dc-doc-card__desc">Supplementary results</div>
                    </div>
                </div>
                <div class="dc-doc-card" onclick="selectDocType(this, 'Redo Results Summary')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Redo Summary</div>
                        <div class="dc-doc-card__desc">Supp results overview</div>
                    </div>
                </div>
            </div>
            
            <!-- Graduation Documents -->
            <div class="dc-section-label">Graduation Documents</div>
            <div class="dc-doc-grid">
                <div class="dc-doc-card" onclick="selectDocType(this, 'GraduationLists')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14v7" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 9v7a7 7 0 0014 0V9" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Graduation List</div>
                        <div class="dc-doc-card__desc">Graduands by programme</div>
                    </div>
                </div>
                <div class="dc-doc-card" onclick="selectDocType(this, 'Transcript')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Transcript</div>
                        <div class="dc-doc-card__desc">Academic transcript</div>
                    </div>
                </div>
                <div class="dc-doc-card" onclick="selectDocType(this, 'ConvocationList')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Convocation List</div>
                        <div class="dc-doc-card__desc">Full convocation list</div>
                    </div>
                </div>
            </div>
            
            <!-- Other Documents -->
            <div class="dc-section-label">Other Documents</div>
            <div class="dc-doc-grid">
                <div class="dc-doc-card" onclick="selectDocType(this, 'RegistrationList')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Registration List</div>
                        <div class="dc-doc-card__desc">Registered students</div>
                    </div>
                </div>
                <div class="dc-doc-card" onclick="selectDocType(this, 'ExamList')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Exam List</div>
                        <div class="dc-doc-card__desc">Exam eligible students</div>
                    </div>
                </div>
                <div class="dc-doc-card" onclick="selectDocType(this, 'AttendanceSheet')">
                    <div class="dc-doc-card__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                    </div>
                    <div class="dc-doc-card__info">
                        <div class="dc-doc-card__title">Attendance Sheet</div>
                        <div class="dc-doc-card__desc">Blank attendance form</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Preview Popup -->
    <dx:ASPxPopupControl ID="popPreview" runat="server" Width="900px" Height="600px" 
        HeaderText="Document Preview" CloseAction="CloseButton" Modal="true" 
        PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
</div>
</asp:Content>
