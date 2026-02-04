<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsUpdates.aspx.cs" Inherits="COOPERP_NewScreens_ResultsUpdates" Title="Results Updates - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.8.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<style type="text/css">
/* Results Updates Module Styles - ru- prefix */
.ru-container { padding: 8px; font-size: 11px; }
.ru-header { margin-bottom: 6px; }
.ru-title { font-size: 14px; font-weight: 600; color: #1a1a2e; margin: 0 0 4px 0; }

/* Compact Inline Stats Bar */
.ru-stats-bar { display: flex; align-items: center; gap: 4px; padding: 4px 8px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 4px; font-size: 10px; margin-bottom: 6px; flex-wrap: wrap; }
.ru-stat { display: flex; align-items: center; gap: 3px; padding: 2px 6px; background: #fff; border-radius: 3px; border: 1px solid #dee2e6; }
.ru-stat-label { color: #6c757d; }
.ru-stat-value { font-weight: 600; color: #495057; }
.ru-stat--primary .ru-stat-value { color: #0d6efd; }
.ru-stat--warning .ru-stat-value { color: #fd7e14; }
.ru-stat--success .ru-stat-value { color: #198754; }

/* Filter Toggle Button */
.ru-filter-toggle { margin-left: auto; padding: 3px 8px; font-size: 10px; background: #e7f1ff; border: 1px solid #b6d4fe; border-radius: 3px; color: #0d6efd; cursor: pointer; display: flex; align-items: center; gap: 4px; }
.ru-filter-toggle:hover { background: #cfe2ff; }
.ru-filter-toggle svg { width: 12px; height: 12px; }

/* Collapsible Filter Row */
.ru-filter-row { display: none; padding: 6px 8px; background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; }
.ru-filter-row.show { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.ru-filter-group { display: flex; align-items: center; gap: 3px; }
.ru-filter-group label { font-size: 10px; color: #6c757d; white-space: nowrap; }
.ru-filter-group select { font-size: 10px; padding: 2px 4px; border: 1px solid #ced4da; border-radius: 3px; min-width: 80px; }

/* Search Controls */
.ru-search-bar { display: flex; gap: 6px; align-items: center; margin-bottom: 6px; padding: 4px 8px; background: #fff; border: 1px solid #e9ecef; border-radius: 4px; }
.ru-search-input { flex: 1; font-size: 11px; padding: 4px 8px; border: 1px solid #ced4da; border-radius: 3px; max-width: 300px; }
.ru-search-btn { padding: 4px 12px; font-size: 10px; background: #0d6efd; color: #fff; border: none; border-radius: 3px; cursor: pointer; }
.ru-search-btn:hover { background: #0b5ed7; }

/* Batch Actions Bar */
.ru-batch-bar { display: flex; gap: 4px; align-items: center; padding: 4px 8px; background: #fff; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; }
.ru-btn { padding: 3px 10px; font-size: 10px; border: 1px solid #dee2e6; border-radius: 3px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; background: #fff; color: #495057; }
.ru-btn:hover { background: #f8f9fa; }
.ru-btn--primary { background: #0d6efd; border-color: #0d6efd; color: #fff; }
.ru-btn--primary:hover { background: #0b5ed7; }
.ru-btn--success { background: #198754; border-color: #198754; color: #fff; }
.ru-btn--success:hover { background: #157347; }
.ru-btn--warning { background: #fd7e14; border-color: #fd7e14; color: #fff; }
.ru-btn--warning:hover { background: #e96e0a; }
.ru-btn--danger { background: #dc3545; border-color: #dc3545; color: #fff; }
.ru-btn--danger:hover { background: #bb2d3b; }

/* Grid Styles */
.ru-grid { font-size: 10px; }
.ru-grid .dxgvHeader { background: linear-gradient(180deg, #f8f9fa 0%, #e9ecef 100%); padding: 4px 6px !important; font-weight: 600; }
.ru-grid .dxgvDataRow td { padding: 3px 6px !important; }
.ru-grid .dxgvDataRow:hover { background-color: #e8f4fc !important; }
.ru-grid .dxgvSelectedRow { background-color: #cce5ff !important; }

/* Status Badge */
.ru-status-badge { display: inline-block; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: 600; text-transform: uppercase; }
.ru-status-badge--approved { background: #d1e7dd; color: #0f5132; }
.ru-status-badge--pending { background: #fff3cd; color: #664d03; }
.ru-status-badge--updated { background: #cff4fc; color: #055160; }

/* Message Panel */
.ru-message { padding: 6px 10px; border-radius: 4px; font-size: 10px; margin-bottom: 6px; display: none; }
.ru-message.show { display: block; }
.ru-message--success { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
.ru-message--warning { background: #fff3cd; color: #664d03; border: 1px solid #ffecb5; }
.ru-message--error { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }

/* Edit Panel */
.ru-edit-panel { padding: 10px; background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 4px; margin-bottom: 6px; display: none; }
.ru-edit-panel.show { display: block; }
.ru-edit-panel-title { font-size: 12px; font-weight: 600; margin-bottom: 8px; color: #1a1a2e; }
.ru-edit-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 8px; margin-bottom: 10px; }
.ru-edit-field { display: flex; flex-direction: column; gap: 2px; }
.ru-edit-field label { font-size: 9px; color: #6c757d; text-transform: uppercase; }
.ru-edit-field input, .ru-edit-field select { font-size: 11px; padding: 4px 6px; border: 1px solid #ced4da; border-radius: 3px; }
.ru-edit-actions { display: flex; gap: 6px; padding-top: 8px; border-top: 1px solid #dee2e6; }
</style>
<script type="text/javascript">
function toggleFilters() {
    var filterRow = document.querySelector('.ru-filter-row');
    if (filterRow) {
        filterRow.classList.toggle('show');
    }
}
function showEditPanel() {
    var panel = document.querySelector('.ru-edit-panel');
    if (panel) panel.classList.add('show');
}
function hideEditPanel() {
    var panel = document.querySelector('.ru-edit-panel');
    if (panel) panel.classList.remove('show');
}

// Summary Report Modal Functions
function openSummaryReportModal() {
    resetSummaryReportForm();
    document.getElementById('summaryReportModal').style.display = 'flex';
    loadReportProgrammes();
    loadReportAcademicYears();
}

function closeSummaryReportModal() {
    document.getElementById('summaryReportModal').style.display = 'none';
    resetSummaryReportForm();
}

function resetSummaryReportForm() {
    document.getElementById('ddlReportProgramme').value = '';
    document.getElementById('ddlReportAcadYear').value = '';
    document.getElementById('ddlReportSemester').value = '';
    document.getElementById('ddlReportStudyYear').value = '';
    document.getElementById('summaryPreviewSection').style.display = 'none';
    document.getElementById('btnExportSummaryReport').disabled = true;
}

function loadReportProgrammes() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'ResultsUpdates.aspx?action=GetProgrammes', true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                var ddl = document.getElementById('ddlReportProgramme');
                ddl.innerHTML = '<option value="">-- Select Programme --</option>';
                for (var i = 0; i < data.length; i++) {
                    var opt = document.createElement('option');
                    opt.value = data[i].code;
                    opt.text = data[i].name;
                    ddl.appendChild(opt);
                }
            } catch(e) { console.error('Error loading programmes:', e); }
        }
    };
    xhr.send();
}

function loadReportAcademicYears() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'ResultsUpdates.aspx?action=GetAcademicYears', true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                var ddl = document.getElementById('ddlReportAcadYear');
                ddl.innerHTML = '<option value="">-- Select Academic Year --</option>';
                for (var i = 0; i < data.length; i++) {
                    var opt = document.createElement('option');
                    opt.value = data[i];
                    opt.text = data[i];
                    ddl.appendChild(opt);
                }
            } catch(e) { console.error('Error loading academic years:', e); }
        }
    };
    xhr.send();
}

function previewSummaryReportStudents() {
    var programme = document.getElementById('ddlReportProgramme').value;
    var acadYear = document.getElementById('ddlReportAcadYear').value;
    var semester = document.getElementById('ddlReportSemester').value;
    var studyYear = document.getElementById('ddlReportStudyYear').value;
    
    if (!programme || !acadYear || !semester) {
        alert('Please select Programme, Academic Year, and Semester');
        return;
    }
    
    document.getElementById('summaryPreviewSection').style.display = 'block';
    document.getElementById('summaryPreviewContent').innerHTML = '<div style="text-align:center;color:#666;">Loading preview...</div>';
    
    var params = 'action=PreviewSummaryReportStudents&programme=' + encodeURIComponent(programme) + 
                 '&acadYear=' + encodeURIComponent(acadYear) + 
                 '&semester=' + encodeURIComponent(semester);
    if (studyYear) params += '&studyYear=' + encodeURIComponent(studyYear);
    
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'ResultsUpdates.aspx?' + params, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                var html = '<div style="display:grid;grid-template-columns:repeat(2,1fr);gap:8px;">';
                html += '<div class="ru-preview-stat"><span class="ru-preview-stat__value" style="color:#1a5490;">' + data.vcList + '</span><span class="ru-preview-stat__label">VC\'s List (First Class)</span></div>';
                html += '<div class="ru-preview-stat"><span class="ru-preview-stat__value" style="color:#2e7d32;">' + data.deansList + '</span><span class="ru-preview-stat__label">Dean\'s List (2nd Upper)</span></div>';
                html += '<div class="ru-preview-stat"><span class="ru-preview-stat__value" style="color:#f57c00;">' + data.secondLower + '</span><span class="ru-preview-stat__label">Second Class Lower</span></div>';
                html += '<div class="ru-preview-stat"><span class="ru-preview-stat__value" style="color:#c62828;">' + data.pass + '</span><span class="ru-preview-stat__label">Pass</span></div>';
                html += '</div>';
                html += '<div style="margin-top:12px;padding-top:12px;border-top:1px solid #eee;text-align:center;"><strong style="font-size:14px;color:#333;">' + data.total + '</strong> <span style="color:#666;font-size:11px;">total students</span></div>';
                document.getElementById('summaryPreviewContent').innerHTML = html;
                document.getElementById('btnExportSummaryReport').disabled = (data.total === 0);
            } catch(e) {
                document.getElementById('summaryPreviewContent').innerHTML = '<div style="color:#c62828;">Error loading preview</div>';
            }
        }
    };
    xhr.send();
}

function exportSummaryReportPdf() {
    var programme = document.getElementById('ddlReportProgramme').value;
    var acadYear = document.getElementById('ddlReportAcadYear').value;
    var semester = document.getElementById('ddlReportSemester').value;
    var studyYear = document.getElementById('ddlReportStudyYear').value;
    
    if (!programme || !acadYear || !semester) {
        alert('Please select Programme, Academic Year, and Semester');
        return;
    }
    
    var params = 'action=ExportSummaryReport&programme=' + encodeURIComponent(programme) + 
                 '&acadYear=' + encodeURIComponent(acadYear) + 
                 '&semester=' + encodeURIComponent(semester);
    if (studyYear) params += '&studyYear=' + encodeURIComponent(studyYear);
    
    window.open('ResultsUpdates.aspx?' + params, '_blank');
}
</script>

<style>
/* Summary Report Modal Styles */
.ru-modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 10000;
    justify-content: center;
    align-items: center;
}

.ru-modal {
    background: #fff;
    border-radius: 6px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.2);
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.ru-modal__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    background: linear-gradient(135deg, #174DA4 0%, #1a5490 100%);
    color: #fff;
}

.ru-modal__title {
    font-size: 14px;
    font-weight: 600;
    margin: 0;
    display: flex;
    align-items: center;
}

.ru-modal__close {
    background: none;
    border: none;
    color: #fff;
    font-size: 20px;
    cursor: pointer;
    padding: 0;
    line-height: 1;
    opacity: 0.8;
}

.ru-modal__close:hover {
    opacity: 1;
}

.ru-modal__body {
    padding: 16px;
    overflow-y: auto;
    flex: 1;
}

.ru-modal__footer {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    padding: 12px 16px;
    border-top: 1px solid #e9ecef;
    background: #f8f9fa;
}

.ru-form-group {
    margin-bottom: 12px;
}

.ru-form-label {
    display: block;
    font-size: 11px;
    font-weight: 600;
    color: #333;
    margin-bottom: 4px;
}

.ru-form-select {
    width: 100%;
    padding: 6px 10px;
    font-size: 11px;
    border: 1px solid #ced4da;
    border-radius: 4px;
    background: #fff;
}

.ru-preview-box {
    margin-top: 16px;
    padding: 12px;
    background: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 4px;
}

.ru-preview-stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 8px;
    background: #fff;
    border: 1px solid #e9ecef;
    border-radius: 4px;
}

.ru-preview-stat__value {
    font-size: 20px;
    font-weight: 700;
}

.ru-preview-stat__label {
    font-size: 9px;
    color: #666;
    text-transform: uppercase;
    margin-top: 2px;
    text-align: center;
}

.ru-btn--outline {
    background: #fff;
    border: 1px solid #ced4da;
    color: #495057;
}

.ru-btn--outline:hover {
    background: #f8f9fa;
}

/* Modal footer button styles */
.ru-modal__footer .ru-btn {
    padding: 8px 16px;
    font-size: 12px;
    border-radius: 4px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 100px;
}

.ru-modal__footer .ru-btn--outline {
    background: #fff;
    border: 1px solid #ced4da;
    color: #495057;
}

.ru-modal__footer .ru-btn--outline:hover {
    background: #e9ecef;
}

.ru-modal__footer .ru-btn--success {
    background: #198754;
    border: 1px solid #198754;
    color: #fff;
}

.ru-modal__footer .ru-btn--success:hover {
    background: #157347;
}

.ru-modal__footer .ru-btn--success:disabled {
    background: #6c757d;
    border-color: #6c757d;
    cursor: not-allowed;
    opacity: 0.65;
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div class="ru-container">
    <div class="ru-header">
        <h1 class="ru-title">Results Updates</h1>
    </div>
    
    <!-- Stats Bar with Filter Toggle -->
    <div class="ru-stats-bar">
        <div class="ru-stat ru-stat--primary">
            <span class="ru-stat-label">Academic Year:</span>
            <span class="ru-stat-value"><asp:Literal ID="litAcadYearDisplay" runat="server" /></span>
        </div>
        <div class="ru-stat">
            <span class="ru-stat-label">Semester:</span>
            <span class="ru-stat-value"><asp:Literal ID="litSemesterDisplay" runat="server" /></span>
        </div>
        <div class="ru-stat ru-stat--primary">
            <span class="ru-stat-label">Total Records:</span>
            <span class="ru-stat-value"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="ru-stat ru-stat--warning">
            <span class="ru-stat-label">Pending Approval:</span>
            <span class="ru-stat-value"><asp:Literal ID="litPendingCount" runat="server">0</asp:Literal></span>
        </div>
        <div class="ru-stat ru-stat--success">
            <span class="ru-stat-label">Approved:</span>
            <span class="ru-stat-value"><asp:Literal ID="litApprovedCount" runat="server">0</asp:Literal></span>
        </div>
        <button type="button" class="ru-filter-toggle" onclick="toggleFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" /></svg>
            Filters
        </button>
    </div>
    
    <!-- Collapsible Filter Row -->
    <div class="ru-filter-row">
        <div class="ru-filter-group">
            <label>Faculty:</label>
            <asp:DropDownList ID="ddlFaculty" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFaculty_SelectedIndexChanged">
                <asp:ListItem Text="-- All Faculties --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="ru-filter-group">
            <label>Programme:</label>
            <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged">
                <asp:ListItem Text="-- All Programmes --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="ru-filter-group">
            <label>Academic Year:</label>
            <asp:DropDownList ID="ddlAcadYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
                <asp:ListItem Text="-- All --" Value="" />
            </asp:DropDownList>
        </div>
        <div class="ru-filter-group">
            <label>Semester:</label>
            <asp:DropDownList ID="ddlSemester" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                <asp:ListItem Text="-- All --" Value="" />
                <asp:ListItem Text="1" Value="1" />
                <asp:ListItem Text="2" Value="2" />
            </asp:DropDownList>
        </div>
        <div class="ru-filter-group">
            <label>Course:</label>
            <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged">
                <asp:ListItem Text="-- All Courses --" Value="" />
            </asp:DropDownList>
        </div>
    </div>
    
    <!-- Search Bar -->
    <div class="ru-search-bar">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="ru-search-input" placeholder="Search by Student Reg No or Name..." />
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="ru-search-btn" OnClick="btnSearch_Click" />
        <asp:Label ID="lblMessage" runat="server" ForeColor="Gray" Font-Size="10px" />
    </div>
    
    <!-- Message Panel -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="ru-message" Visible="false">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>
    
    <!-- Edit Panel for Selected Record -->
    <asp:Panel ID="pnlEdit" runat="server" CssClass="ru-edit-panel" Visible="false">
        <div class="ru-edit-panel-title">Update Result - <asp:Literal ID="litStudentName" runat="server" /></div>
        <asp:HiddenField ID="hfResultID" runat="server" />
        <div class="ru-edit-grid">
            <div class="ru-edit-field">
                <label>Registration No</label>
                <asp:TextBox ID="txtRegNo" runat="server" ReadOnly="true" />
            </div>
            <div class="ru-edit-field">
                <label>Course</label>
                <asp:TextBox ID="txtCourse" runat="server" ReadOnly="true" />
            </div>
            <div class="ru-edit-field">
                <label>Coursework (CA)</label>
                <asp:TextBox ID="txtCoursework" runat="server" />
            </div>
            <div class="ru-edit-field">
                <label>Exam Score</label>
                <asp:TextBox ID="txtExam" runat="server" />
            </div>
            <div class="ru-edit-field">
                <label>Total Mark</label>
                <asp:TextBox ID="txtTotal" runat="server" ReadOnly="true" />
            </div>
            <div class="ru-edit-field">
                <label>Grade</label>
                <asp:TextBox ID="txtGrade" runat="server" ReadOnly="true" />
            </div>
            <div class="ru-edit-field">
                <label>Remark</label>
                <asp:DropDownList ID="ddlRemark" runat="server">
                    <asp:ListItem Text="Normal" Value="" />
                    <asp:ListItem Text="Retake" Value="RETAKE" />
                    <asp:ListItem Text="Supplementary" Value="SUPP" />
                    <asp:ListItem Text="Special" Value="SPECIAL" />
                </asp:DropDownList>
            </div>
            <div class="ru-edit-field">
                <label>Update Reason</label>
                <asp:TextBox ID="txtReason" runat="server" />
            </div>
        </div>
        <div class="ru-edit-actions">
            <asp:Button ID="btnSaveUpdate" runat="server" Text="Save Changes" CssClass="ru-btn ru-btn--success" OnClick="btnSaveUpdate_Click" />
            <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="ru-btn" OnClick="btnCancelEdit_Click" />
        </div>
    </asp:Panel>
    
    <!-- Batch Actions Bar -->
    <div class="ru-batch-bar">
        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="ru-btn" OnClick="btnRefresh_Click" />
        <asp:Button ID="btnEditSelected" runat="server" Text="Edit Selected" CssClass="ru-btn ru-btn--primary" OnClick="btnEditSelected_Click" />
        <asp:Button ID="btnApproveSelected" runat="server" Text="Approve Selected" CssClass="ru-btn ru-btn--success" OnClick="btnApproveSelected_Click" />
        <asp:Button ID="btnRevertSelected" runat="server" Text="Revert Selected" CssClass="ru-btn ru-btn--warning" OnClick="btnRevertSelected_Click" />
        <asp:Button ID="btnExportExcel" runat="server" Text="Export Results" CssClass="ru-btn" OnClick="btnExportExcel_Click" />
        <button type="button" class="ru-btn ru-btn--primary" onclick="openSummaryReportModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:4px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
            Summary Report
        </button>
    </div>
    
    <!-- Results Grid -->
    <dx:ASPxGridView ID="gvResults" runat="server" Width="100%" CssClass="ru-grid" 
        KeyFieldName="ID"
        AutoGenerateColumns="False"
        EnableCallBacks="true"
        OnCustomColumnDisplayText="gvResults_CustomColumnDisplayText">
        <SettingsBehavior AllowSelectByRowClick="true" AllowSelectSingleRowOnly="false" />
        <SettingsPager PageSize="50">
            <PageSizeItemSettings Visible="true" Items="20,50,100,200" />
        </SettingsPager>
        <Settings ShowFilterRow="true" ShowFilterRowMenu="true" />
        <SettingsSearchPanel Visible="true" ShowApplyButton="true" />
        <Columns>
            <dx:GridViewCommandColumn ShowSelectCheckbox="true" Width="30px" />
            <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="60px" Visible="false" />
            <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" Width="100px">
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student Name" Width="180px">
                <Settings AutoFilterCondition="Contains" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="course_id" Caption="Course ID" Width="80px" />
            <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course Name" Width="150px" />
            <dx:GridViewDataTextColumn FieldName="prog_name" Caption="Programme" Width="120px" />
            <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Acad Year" Width="80px" />
            <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" Width="40px" />
            <dx:GridViewDataTextColumn FieldName="ca_mark" Caption="CA" Width="50px" />
            <dx:GridViewDataTextColumn FieldName="exam_mark" Caption="Exam" Width="50px" />
            <dx:GridViewDataTextColumn FieldName="total_mark" Caption="Total" Width="50px" />
            <dx:GridViewDataTextColumn FieldName="grade" Caption="Grade" Width="50px" />
            <dx:GridViewDataTextColumn FieldName="gpa" Caption="GPA" Width="40px" />
            <dx:GridViewDataTextColumn FieldName="approved_by" Caption="Status" Width="80px">
                <DataItemTemplate>
                    <%# GetStatusBadge(Eval("approved_by")) %>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataDateColumn FieldName="date_modified" Caption="Last Modified" Width="100px">
                <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy HH:mm" />
            </dx:GridViewDataDateColumn>
        </Columns>
        <Styles>
            <Header BackColor="#f8f9fa" Font-Bold="true" Font-Size="10px" />
            <Row Font-Size="10px" />
            <AlternatingRow BackColor="#fafbfc" />
        </Styles>
    </dx:ASPxGridView>
    
    <!-- Excel Exporter -->
    <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvResults" />
</div>

<!-- Summary Report Modal -->
<div id="summaryReportModal" class="ru-modal-overlay">
    <div class="ru-modal">
        <div class="ru-modal__header">
            <h3 class="ru-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:6px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                Student Performance Summary Report
            </h3>
            <button type="button" class="ru-modal__close" onclick="closeSummaryReportModal()">&times;</button>
        </div>
        <div class="ru-modal__body">
            <p style="margin-bottom:12px;color:#666;font-size:11px;">
                Generate a PDF report showing student performance categorized by CGPA classification
                (VC's List, Dean's List, Second Class Lower, Pass).
            </p>
            
            <!-- Programme -->
            <div class="ru-form-group">
                <label class="ru-form-label">Programme <span style="color:#c0392b;">*</span></label>
                <select id="ddlReportProgramme" class="ru-form-select">
                    <option value="">-- Select Programme --</option>
                </select>
            </div>
            
            <!-- Academic Year -->
            <div class="ru-form-group">
                <label class="ru-form-label">Academic Year <span style="color:#c0392b;">*</span></label>
                <select id="ddlReportAcadYear" class="ru-form-select">
                    <option value="">-- Select Academic Year --</option>
                </select>
            </div>
            
            <!-- Semester -->
            <div class="ru-form-group">
                <label class="ru-form-label">Semester <span style="color:#c0392b;">*</span></label>
                <select id="ddlReportSemester" class="ru-form-select">
                    <option value="">-- Select Semester --</option>
                    <option value="1">Semester 1</option>
                    <option value="2">Semester 2</option>
                </select>
            </div>
            
            <!-- Year of Study -->
            <div class="ru-form-group">
                <label class="ru-form-label">Year of Study (Optional)</label>
                <select id="ddlReportStudyYear" class="ru-form-select">
                    <option value="">-- All Years --</option>
                    <option value="1">Year 1</option>
                    <option value="2">Year 2</option>
                    <option value="3">Year 3</option>
                    <option value="4">Year 4</option>
                    <option value="5">Year 5</option>
                </select>
            </div>
            
            <!-- Preview Button -->
            <div class="ru-form-group" style="margin-top:16px;">
                <button type="button" class="ru-btn ru-btn--primary" onclick="previewSummaryReportStudents()" style="width:100%;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    Preview Students
                </button>
            </div>
            
            <!-- Preview Section -->
            <div id="summaryPreviewSection" class="ru-preview-box" style="display:none;">
                <h4 style="margin:0 0 12px 0;font-size:12px;color:#333;">Performance Distribution Preview</h4>
                <div id="summaryPreviewContent"></div>
            </div>
        </div>
        <div class="ru-modal__footer" style="display:flex !important; justify-content:flex-end !important; gap:10px !important; padding:12px 16px !important; border-top:1px solid #e9ecef !important; background:#f8f9fa !important;">
            <button type="button" style="padding:8px 16px; font-size:12px; background:#fff; border:1px solid #ced4da; color:#495057; border-radius:4px; cursor:pointer; min-width:80px;" onclick="closeSummaryReportModal()">Cancel</button>
            <button type="button" id="btnExportSummaryReport" style="padding:8px 16px; font-size:12px; background:#198754; border:1px solid #198754; color:#fff; border-radius:4px; cursor:pointer; min-width:100px; display:inline-flex; align-items:center; justify-content:center;" onclick="exportSummaryReportPdf()" disabled>
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:4px;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                Export PDF
            </button>
        </div>
    </div>
</div>
</asp:Content>
