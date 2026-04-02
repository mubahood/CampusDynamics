<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsHoldList.aspx.cs" Inherits="COOPERP_NewScreens_ResultsHoldList" Title="Results Hold List - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== RESULTS HOLD LIST — em-/mat- design system ================ */

/* ── Shared Exam Module Nav ── */
.em-hdr{display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:#fff;padding:12px 20px}
.em-hdr__title{font-size:15px;font-weight:700}
.em-hdr__sub{font-size:10px;opacity:.7;margin-top:1px}
.em-hdr__actions{display:flex;gap:6px;align-items:center}
.em-tabs{display:flex;gap:0;background:#fff;border-bottom:2px solid #e0e5ed;padding:0 16px;overflow-x:auto;margin-bottom:12px}
.em-tab{padding:9px 14px;font-size:11px;font-weight:500;color:#555;text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;white-space:nowrap;transition:color .15s,border-color .15s}
.em-tab:hover{color:#1a237e}
.em-tab--active{color:#1a237e;border-bottom-color:#1a237e;font-weight:600}

/* ── Stats Row ── */
.mat-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:12px}
.mat-stat{background:#fff;border:1px solid #e0e5ed;padding:10px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.mat-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--c,#ccc)}
.mat-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.mat-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.mat-stat--held{--c:#dc3545}.mat-stat--held .mat-stat__val{color:#dc3545}
.mat-stat--students{--c:#e65100}.mat-stat--students .mat-stat__val{color:#e65100}
.mat-stat--courses{--c:#6a1b9a}.mat-stat--courses .mat-stat__val{color:#6a1b9a}
.mat-stat--long{--c:#d97706}.mat-stat--long .mat-stat__val{color:#d97706}

/* ── Card System ── */
.mat-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:12px}
.mat-card__hdr{padding:8px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.mat-card__title{font-size:12px;font-weight:700;color:#1a237e;display:flex;align-items:center;gap:6px}
.mat-card__meta{font-size:10px;color:#1a237e;font-weight:600;background:rgba(26,35,126,.07);padding:2px 8px;border:1px solid rgba(26,35,126,.15)}

/* ── Filters (collapsible) ── */
.mat-filtbar{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px;display:none}
.mat-filtbar.show{display:block}
.mat-filtbar__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.mat-fg{display:flex;flex-direction:column;gap:3px}
.mat-fg__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.mat-fg select{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;min-width:120px;font-family:inherit}
.mat-fg select:focus{border-color:#1a237e;outline:none}

/* ── Buttons ── */
.mat-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;font-family:inherit}
.mat-btn--primary{background:#1a237e;color:#fff}.mat-btn--primary:hover{background:#283593}
.mat-btn--success{background:#16a34a;color:#fff}.mat-btn--success:hover{background:#15803d}
.mat-btn--danger{background:#dc3545;color:#fff}.mat-btn--danger:hover{background:#c82333}
.mat-btn--ghost{background:transparent;color:#555;border:1px solid #e0e5ed}.mat-btn--ghost:hover{background:#f5f7fa}
.mat-btn--sm{padding:4px 10px;font-size:10px}
.mat-btn--filter{padding:4px 10px;font-size:10px;background:#e8eaf6;border:1px solid #c5cae9;color:#1a237e;cursor:pointer}
.mat-btn--filter:hover{background:#c5cae9}
.mat-btn--filter.active{background:#1a237e;color:#fff;border-color:#1a237e}

/* ── Grid overrides ── */
.mat-grid .dxgvHeader td{background:#f5f7fa!important;font-size:10px!important;font-weight:600!important;text-transform:uppercase!important;letter-spacing:.3px;padding:9px 8px!important;color:#555!important;border-bottom:2px solid #1a237e!important;white-space:nowrap}
.mat-grid .dxgvDataRow td{font-size:11px!important;padding:7px 8px!important;border-bottom:1px solid #f0f2f5!important;vertical-align:middle!important;color:#1a1a2e}
.mat-grid .dxgvDataRow:hover td{background:#eef2fc!important}
.mat-grid .dxgvDataRow:nth-child(even) td{background:#f9fafb!important}
.mat-grid .dxgvDataRow:nth-child(even):hover td{background:#eef2fc!important}
.mat-grid .dxgvSelectedRow td{background:#e8eaf6!important}
.mat-grid .dxgvFocusedRow td{background:#c5cae9!important}

/* ── Badges ── */
.mat-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px}
.mat-badge--financial{background:#e6f4ea;color:#155724;border:1px solid #c3e6cb}
.mat-badge--academic{background:#e8f0fc;color:#0d47a1;border:1px solid #90caf9}
.mat-badge--disciplinary{background:#fef5f5;color:#991b1b;border:1px solid #f5c6cb}
.mat-badge--admin{background:#f3e5f5;color:#4a148c;border:1px solid #ce93d8}
.mat-badge--other{background:#f5f7fa;color:#555;border:1px solid #e0e5ed}

/* ── Duration cell ── */
.mat-duration{font-weight:700;font-variant-numeric:tabular-nums}
.mat-duration--warn{color:#dc3545}
.mat-duration--ok{color:#555}

/* ── User highlight ── */
.mat-user{font-weight:700;color:#1a237e}

/* ── Row actions ── */
.mat-row-act{display:inline-flex;gap:3px}
.mat-row-btn{width:22px;height:22px;border:none;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;transition:background .15s}
.mat-row-btn svg{width:12px;height:12px}
.mat-row-btn--ok{background:#e6f4ea;color:#388e3c}.mat-row-btn--ok:hover{background:#c8e6c9}
.mat-row-btn--view{background:#e8f0fc;color:#1976d2}.mat-row-btn--view:hover{background:#bbdefb}
.mat-row-btn--hist{background:#fff8e1;color:#f57c00}.mat-row-btn--hist:hover{background:#ffe0b2}

/* ── Selection bar ── */
.mat-selbar{display:flex;align-items:center;gap:8px;padding:6px 14px;background:#263238;font-size:11px}
.mat-selbar__count{color:#fff}.mat-selbar__count strong{color:#ffd600}
.mat-selbar__spacer{flex:1}

/* ── Alert ── */
.mat-alert{padding:8px 14px;margin-bottom:10px;font-size:11px;border-left:3px solid;display:flex;align-items:center;gap:6px}
.mat-alert--error{border-color:#dc3545;background:#fef5f5;color:#991b1b}
.mat-alert--success{border-color:#16a34a;background:#e6f4ea;color:#155724}
.mat-alert--warn{border-color:#d97706;background:#fffbeb;color:#92400e}

/* ── Modal (for Add Note) ── */
.mat-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:9998;align-items:center;justify-content:center}
.mat-modal-bg.show{display:flex}
.mat-modal{background:#fff;width:440px;max-width:96vw;max-height:92vh;overflow-y:auto;box-shadow:0 12px 40px rgba(0,0,0,.18)}
.mat-modal__hdr{background:#1a237e;padding:10px 16px;display:flex;align-items:center;justify-content:space-between}
.mat-modal__title{font-size:13px;font-weight:700;color:#fff}
.mat-modal__close{border:none;background:rgba(255,255,255,.15);color:#fff;font-size:16px;cursor:pointer;width:24px;height:24px;display:flex;align-items:center;justify-content:center}
.mat-modal__body{padding:16px}
.mat-modal__footer{padding:10px 16px;border-top:1px solid #e0e5ed;display:flex;gap:8px;justify-content:flex-end;background:#f8f9fb}

/* ── Responsive ── */
@media(max-width:1200px){.mat-stats{grid-template-columns:repeat(2,1fr)}}
@media(max-width:768px){.mat-stats{grid-template-columns:1fr}}
@media print{.em-hdr,.em-tabs,.mat-selbar{display:none!important}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ── Header + Tabs ── -->
<div class="em-hdr">
    <div><div class="em-hdr__title">Results Hold List</div><div class="em-hdr__sub">Records on hold preventing results release</div></div>
    <div class="em-hdr__actions">
        <asp:Button ID="btnExport" runat="server" Text="Export" CssClass="mat-btn mat-btn--success mat-btn--sm" OnClick="btnExport_Click" />
    </div>
</div>
<div class="em-tabs">
    <a href="ExamResultsInfo.aspx" class="em-tab">Exam Results</a>
    <a href="ResultsRelease.aspx" class="em-tab">Results Release</a>
    <a href="ResultsUpdates.aspx" class="em-tab">Updates</a>
    <a href="ResultsHoldList.aspx" class="em-tab em-tab--active">Hold List</a>
    <a href="ResultsAuditLog.aspx" class="em-tab">Audit Log</a>
    <a href="MarksAuditTrail.aspx" class="em-tab">Marks Trail</a>
    <a href="ResultsAnalytics.aspx" class="em-tab">Analytics</a>
</div>

<!-- ── Stats ── -->
<div class="mat-stats">
    <div class="mat-stat mat-stat--held"><div><div class="mat-stat__val"><asp:Literal ID="litTotalHeld" runat="server">0</asp:Literal></div><div class="mat-stat__label">Total Held</div></div></div>
    <div class="mat-stat mat-stat--students"><div><div class="mat-stat__val"><asp:Literal ID="litAffectedStudents" runat="server">0</asp:Literal></div><div class="mat-stat__label">Students Affected</div></div></div>
    <div class="mat-stat mat-stat--courses"><div><div class="mat-stat__val"><asp:Literal ID="litAffectedCourses" runat="server">0</asp:Literal></div><div class="mat-stat__label">Courses Affected</div></div></div>
    <div class="mat-stat mat-stat--long"><div><div class="mat-stat__val"><asp:Literal ID="litLongHeld" runat="server">0</asp:Literal></div><div class="mat-stat__label">Held &gt;30 Days</div></div></div>
</div>

<!-- ── Alert ── -->
<asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="mat-alert mat-alert--error">
    <asp:Literal ID="litMessage" runat="server" />
</asp:Panel>

<!-- ── Reason filter pills (hidden controls to keep code-behind happy) ── -->
<asp:LinkButton ID="btnReasonFinancial" runat="server" OnClick="FilterByReason_Click" CommandArgument="FINANCIAL" style="display:none" />
<asp:LinkButton ID="btnReasonAcademic" runat="server" OnClick="FilterByReason_Click" CommandArgument="ACADEMIC" style="display:none" />
<asp:LinkButton ID="btnReasonDisciplinary" runat="server" OnClick="FilterByReason_Click" CommandArgument="DISCIPLINARY" style="display:none" />
<asp:LinkButton ID="btnReasonAdmin" runat="server" OnClick="FilterByReason_Click" CommandArgument="ADMIN" style="display:none" />
<asp:LinkButton ID="btnReasonOther" runat="server" OnClick="FilterByReason_Click" CommandArgument="" style="display:none" />
<asp:Literal ID="litFinancialCount" runat="server" Visible="false">0</asp:Literal>
<asp:Literal ID="litAcademicCount" runat="server" Visible="false">0</asp:Literal>
<asp:Literal ID="litDisciplinaryCount" runat="server" Visible="false">0</asp:Literal>
<asp:Literal ID="litAdminCount" runat="server" Visible="false">0</asp:Literal>
<asp:Literal ID="litOtherCount" runat="server" Visible="false">0</asp:Literal>
<asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/COOPERP/NewScreens/ResultsRelease.aspx" style="display:none" />

<!-- ── Main Card ── -->
<div class="mat-card">
    <div class="mat-card__hdr">
        <span class="mat-card__title">Held Records</span>
        <div style="display:flex;gap:6px;align-items:center">
            <span class="mat-card__meta"><asp:Literal ID="litGridCount" runat="server">0</asp:Literal> records</span>
            <button type="button" class="mat-btn--filter" id="btnToggleFilter" onclick="toggleFilters()">Filters</button>
        </div>
    </div>
    <!-- Collapsible Filters -->
    <div class="mat-filtbar" id="matFilterBar">
        <div class="mat-filtbar__row">
            <div class="mat-fg">
                <span class="mat-fg__label">Academic Year</span>
                <asp:DropDownList ID="ddlAcadYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
            </div>
            <div class="mat-fg">
                <span class="mat-fg__label">Semester</span>
                <asp:DropDownList ID="ddlSemester" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="1" Text="Sem 1" />
                    <asp:ListItem Value="2" Text="Sem 2" />
                </asp:DropDownList>
            </div>
            <div class="mat-fg">
                <span class="mat-fg__label">Programme</span>
                <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
            </div>
            <div class="mat-fg">
                <span class="mat-fg__label">Duration</span>
                <asp:DropDownList ID="ddlDuration" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                    <asp:ListItem Value="" Text="Any" />
                    <asp:ListItem Value="7" Text="&lt; 7d" />
                    <asp:ListItem Value="30" Text="&lt; 30d" />
                    <asp:ListItem Value="30+" Text="&gt; 30d" />
                </asp:DropDownList>
            </div>
            <asp:Button ID="btnClearFilters" runat="server" Text="Reset" CssClass="mat-btn mat-btn--ghost mat-btn--sm" OnClick="btnClearFilters_Click" />
        </div>
    </div>
    <!-- Selection / Batch Actions Bar -->
    <div class="mat-selbar">
        <span class="mat-selbar__count">Selected: <strong><span id="selectedCount">0</span></strong></span>
        <asp:Button ID="btnUnholdSelected" runat="server" Text="Unhold" CssClass="mat-btn mat-btn--success mat-btn--sm" OnClick="btnUnholdSelected_Click" OnClientClick="return confirm('Remove hold from selected records?');" />
        <asp:Button ID="btnAddNote" runat="server" Text="Add Note" CssClass="mat-btn mat-btn--ghost mat-btn--sm" style="color:#fff;border-color:rgba(255,255,255,.25)" OnClick="btnAddNote_Click" />
        <span class="mat-selbar__spacer"></span>
        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="mat-btn mat-btn--ghost mat-btn--sm" style="color:#fff;border-color:rgba(255,255,255,.25)" OnClick="btnRefresh_Click" />
    </div>
    <!-- Grid -->
    <dx:ASPxGridView ID="gvHeldResults" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="ID" CssClass="mat-grid" ClientInstanceName="gvHeldResults">
        <ClientSideEvents SelectionChanged="function(s,e){updateSel();}" />
        <SettingsPager PageSize="50" AlwaysShowPager="true">
            <Summary Visible="true" Text="Page {0} of {1} ({2} records)" />
            <PageSizeItemSettings Visible="true" Items="25, 50, 100" />
        </SettingsPager>
        <SettingsBehavior AllowFocusedRow="true" AllowSelectByRowClick="true" />
        <Settings ShowFilterRow="true" />
        <Columns>
            <dx:GridViewCommandColumn ShowSelectCheckbox="true" SelectAllCheckboxMode="Page" VisibleIndex="0" Width="32px" />
            <dx:GridViewDataTextColumn FieldName="regno" Caption="Student" VisibleIndex="1" Width="120px">
                <DataItemTemplate><span class="mat-user"><%# Eval("regno") %></span></DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Name" VisibleIndex="2" Width="140px" />
            <dx:GridViewDataTextColumn FieldName="course_id" Caption="Course" VisibleIndex="3" Width="85px">
                <CellStyle Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="prog_name" Caption="Programme" VisibleIndex="4" Width="140px" />
            <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Year" VisibleIndex="5" Width="75px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" VisibleIndex="6" Width="40px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="hold_reason" Caption="Reason" VisibleIndex="7" Width="90px">
                <DataItemTemplate><%# GetReasonBadge(Eval("hold_reason")) %></DataItemTemplate>
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="hold_notes" Caption="Notes" VisibleIndex="8">
                <CellStyle Wrap="True" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataDateColumn FieldName="hold_date" Caption="Date" VisibleIndex="9" Width="80px">
                <PropertiesDateEdit DisplayFormatString="dd-MMM-yy" />
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataDateColumn>
            <dx:GridViewDataTextColumn FieldName="days_held" Caption="Days" VisibleIndex="10" Width="45px">
                <DataItemTemplate><span class='mat-duration <%# Convert.ToInt32(Eval("days_held")) > 30 ? "mat-duration--warn" : "mat-duration--ok" %>'><%# Eval("days_held") %></span></DataItemTemplate>
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="held_by" Caption="By" VisibleIndex="11" Width="80px" />
            <dx:GridViewDataTextColumn FieldName="ID" Caption="" VisibleIndex="12" Width="68px">
                <DataItemTemplate>
                    <div class="mat-row-act">
                        <button type="button" class="mat-row-btn mat-row-btn--ok" title="Unhold" onclick="unholdSingle('<%# Eval("ID") %>')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></button>
                        <button type="button" class="mat-row-btn mat-row-btn--view" title="View" onclick="viewStudent('<%# Eval("regno") %>')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
                        <button type="button" class="mat-row-btn mat-row-btn--hist" title="History" onclick="viewHistory('<%# Eval("ID") %>')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></button>
                    </div>
                </DataItemTemplate>
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
        </Columns>
    </dx:ASPxGridView>
    <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvHeldResults" />
</div>

<!-- ── Add Note Modal ── -->
<div class="mat-modal-bg" id="noteModal">
<div class="mat-modal">
    <div class="mat-modal__hdr">
        <span class="mat-modal__title">Add Hold Note</span>
        <button type="button" class="mat-modal__close" onclick="closeNoteModal()">&times;</button>
    </div>
    <div class="mat-modal__body">
        <div class="mat-fg" style="margin-bottom:12px">
            <span class="mat-fg__label">Hold Reason</span>
            <asp:DropDownList ID="ddlHoldReason" runat="server" style="width:100%;border:1px solid #e0e5ed;padding:6px 10px;font-size:11px">
                <asp:ListItem Value="FINANCIAL" Text="Financial" />
                <asp:ListItem Value="ACADEMIC" Text="Academic" />
                <asp:ListItem Value="DISCIPLINARY" Text="Disciplinary" />
                <asp:ListItem Value="ADMIN" Text="Administrative" />
                <asp:ListItem Value="OTHER" Text="Other" />
            </asp:DropDownList>
        </div>
        <div class="mat-fg">
            <span class="mat-fg__label">Note</span>
            <asp:TextBox ID="txtHoldNote" runat="server" TextMode="MultiLine" Rows="3" style="width:100%;border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;font-family:inherit;resize:vertical" />
        </div>
    </div>
    <div class="mat-modal__footer">
        <button type="button" class="mat-btn mat-btn--ghost mat-btn--sm" onclick="closeNoteModal()">Cancel</button>
        <asp:Button ID="btnSaveNote" runat="server" Text="Save Note" CssClass="mat-btn mat-btn--primary mat-btn--sm" OnClick="btnSaveNote_Click" />
    </div>
</div>
</div>
<!-- hidden DevExpress popup kept for code-behind compatibility -->
<dx:ASPxPopupControl ID="popAddNote" runat="server" Width="1" Height="1" ClientInstanceName="popAddNote" ShowOnPageLoad="false" style="display:none">
    <ContentCollection><dx:PopupControlContentControl runat="server"></dx:PopupControlContentControl></ContentCollection>
</dx:ASPxPopupControl>

<script>
function toggleFilters(){var b=document.getElementById('matFilterBar'),t=document.getElementById('btnToggleFilter');if(b.classList.contains('show')){b.classList.remove('show');t.classList.remove('active');}else{b.classList.add('show');t.classList.add('active');}}
function updateSel(){var c=gvHeldResults.GetSelectedRowCount();document.getElementById('selectedCount').textContent=c;}
function unholdSingle(id){if(confirm('Remove hold from this record?'))__doPostBack('UnholdSingle',id);}
function viewStudent(r){window.open('StudentResultsView.aspx?regno='+encodeURIComponent(r),'_blank');}
function viewHistory(id){window.open('MarksAuditTrail.aspx?recordId='+encodeURIComponent(id),'_blank');}
function openNoteModal(){document.getElementById('noteModal').classList.add('show');}
function closeNoteModal(){document.getElementById('noteModal').classList.remove('show');}
document.addEventListener('DOMContentLoaded',function(){updateSel();});
</script>

</asp:Content>
