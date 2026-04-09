<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="GraduateStudents.aspx.cs" Inherits="COOPERP_NewScreens_GraduateStudents" Title="Masters Certificate Management - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
/* ===== GRADUATE / MASTERS CERTIFICATE MANAGEMENT — ft- design system ===== */
.ft-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--total{--stat-c:#05275C}.ft-stat--total .ft-stat__icon{background:#e8f0fc}.ft-stat--total .ft-stat__val{color:#05275C}
.ft-stat--thesis{--stat-c:#2e7d32}.ft-stat--thesis .ft-stat__icon{background:#e6f4ea}.ft-stat--thesis .ft-stat__val{color:#2e7d32}
.ft-stat--supervisor{--stat-c:#e65100}.ft-stat--supervisor .ft-stat__icon{background:#fff3e0}.ft-stat--supervisor .ft-stat__val{color:#e65100}
.ft-stat--progress{--stat-c:#6a1b9a}.ft-stat--progress .ft-stat__icon{background:#f3e5f5}.ft-stat--progress .ft-stat__val{color:#6a1b9a}

.ft-card{background:#fff;border:1px solid #e0e5ed;overflow:hidden;margin-bottom:14px}
.ft-card__header{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px}
.ft-card__title{font-size:12px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-card__meta{font-size:10px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:2px 8px;border:1px solid rgba(23,77,164,.15)}
.ft-filters{background:#f8f9fb;border-bottom:1px solid #e0e5ed;padding:10px 14px}
.ft-filters__row{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end}
.ft-filter-grp{display:flex;flex-direction:column;gap:3px}
.ft-filter-grp__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.ft-filter-input{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;min-width:110px;font-family:inherit}
.ft-filter-input:focus{border-color:#174DA4;outline:none}
.ft-filter-select{border:1px solid #e0e5ed;padding:6px 10px;font-size:11px;background:#fff;color:#333;min-width:140px;font-family:inherit}
.ft-filter-select:focus{border-color:#174DA4;outline:none}

.ft-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn--primary{background:#05275C;color:#fff}.ft-btn--primary:hover{background:#174DA4}
.ft-btn--ghost{background:transparent;border:1px solid #e0e5ed;color:#555}.ft-btn--ghost:hover{border-color:#174DA4;color:#174DA4}
.ft-btn--danger{background:transparent;border:1px solid #e0e5ed;color:#c62828}.ft-btn--danger:hover{background:#fde8e8;border-color:#c62828}
.ft-btn--edit{background:transparent;border:1px solid #e0e5ed;color:#174DA4}.ft-btn--edit:hover{background:#e8f0fc;border-color:#174DA4}
.ft-btn--success{background:#2e7d32;color:#fff}.ft-btn--success:hover{background:#1b5e20}
.ft-btn--sm{padding:5px 11px;font-size:10px}
.ft-btn--cancel{background:#757575;color:#fff}.ft-btn--cancel:hover{background:#616161}

.ft-table-wrap{overflow:auto;max-height:560px;position:relative}
.ft-table{width:100%;border-collapse:collapse;min-width:1100px;font-size:12px}
.ft-table thead tr{position:sticky;top:0;z-index:10}
.ft-table thead th{background:#f5f7fa;color:#555;font-size:10px;text-transform:uppercase;letter-spacing:.3px;font-weight:600;padding:9px 12px;border-bottom:2px solid #e0e5ed;white-space:nowrap;box-shadow:0 2px 0 #e0e5ed;text-align:left}
.ft-table tbody tr{border-bottom:1px solid #f0f2f5;transition:background .08s}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover,.ft-table tbody tr:nth-child(even):hover{background:#eef2fc}
.ft-table tbody td{padding:8px 12px;vertical-align:middle;color:#1a1a2e;font-size:11px}
.ft-col-name{font-weight:600;color:#05275C}
.ft-col-actions{width:80px;text-align:center;white-space:nowrap}
.ft-col-thesis{max-width:250px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.ft-col-thesis:hover{white-space:normal;overflow:visible}

.ft-badge{display:inline-block;padding:2px 8px;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.3px}
.ft-badge--green{background:#e6f4ea;color:#2e7d32;border:1px solid #c3e6cb}
.ft-badge--orange{background:#fff3e0;color:#e65100;border:1px solid #ffcc02}
.ft-badge--red{background:#fde8e8;color:#c62828;border:1px solid #f5c6cb}
.ft-badge--blue{background:#e8f0fc;color:#174DA4;border:1px solid #b8d4f0}
.ft-badge--grey{background:#f5f5f5;color:#666;border:1px solid #ddd}

.ft-toast{display:none;padding:9px 14px;font-size:12px;font-weight:600;margin-bottom:12px;border:1px solid transparent}
.ft-toast--success{display:block;background:#e6f4ea;color:#155724;border-color:#c3e6cb}
.ft-toast--error{display:block;background:#fde8e8;color:#c62828;border-color:#f5c6cb}

.ft-nodata{padding:30px 20px;text-align:center;color:#999;font-size:13px}
.ft-pager{display:flex;align-items:center;justify-content:space-between;padding:8px 14px;background:#f8f9fb;border-top:1px solid #e0e5ed;font-size:11px;color:#666}
.ft-pager__info strong{color:#05275C}

/* Thesis Edit Modal */
.ft-modal-overlay{display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.45);z-index:9998;justify-content:center;align-items:center}
.ft-modal-overlay.active{display:flex}
.ft-modal{background:#fff;width:520px;max-width:92vw;box-shadow:0 8px 32px rgba(0,0,0,.2);position:relative;max-height:90vh;overflow-y:auto}
.ft-modal__header{padding:14px 18px;border-bottom:1px solid #e0e5ed;background:#f8f9fb;display:flex;align-items:center;justify-content:space-between}
.ft-modal__title{font-size:13px;font-weight:700;color:#05275C}
.ft-modal__close{background:none;border:none;font-size:18px;cursor:pointer;color:#666;padding:0 4px}
.ft-modal__close:hover{color:#c62828}
.ft-modal__body{padding:18px}
.ft-form-group{margin-bottom:14px}
.ft-form-group label{display:block;font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#666;font-weight:600;margin-bottom:4px}
.ft-form-group input,.ft-form-group select,.ft-form-group textarea{width:100%;border:1px solid #e0e5ed;padding:8px 12px;font-size:12px;font-family:inherit;color:#333;box-sizing:border-box}
.ft-form-group input:focus,.ft-form-group select:focus,.ft-form-group textarea:focus{border-color:#174DA4;outline:none}
.ft-form-group textarea{resize:vertical;min-height:60px}
.ft-form-info{font-size:10px;color:#888;margin-top:3px}
.ft-modal__footer{padding:12px 18px;border-top:1px solid #e0e5ed;background:#f8f9fb;display:flex;gap:8px;justify-content:flex-end}

@media(max-width:768px){.ft-stats{grid-template-columns:repeat(2,1fr)}.ft-filters__row{flex-direction:column}}
@media(max-width:480px){.ft-stats{grid-template-columns:1fr}}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- Message Panel -->
<asp:Panel ID="pnlMsg" runat="server" Visible="false">
    <asp:Literal ID="litMsg" runat="server" />
</asp:Panel>

<!-- ═══ Stats Row ═══ -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--total">
        <div class="ft-stat__icon">
            <svg width="18" height="18" fill="none" stroke="#05275C" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ft-stat__label">Graduate Students</div></div>
    </div>
    <div class="ft-stat ft-stat--thesis">
        <div class="ft-stat__icon">
            <svg width="18" height="18" fill="none" stroke="#2e7d32" stroke-width="2" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litWithThesis" runat="server" Text="0" /></div><div class="ft-stat__label">With Thesis Title</div></div>
    </div>
    <div class="ft-stat ft-stat--supervisor">
        <div class="ft-stat__icon">
            <svg width="18" height="18" fill="none" stroke="#e65100" stroke-width="2" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litWithSupervisor" runat="server" Text="0" /></div><div class="ft-stat__label">Supervisor Assigned</div></div>
    </div>
    <div class="ft-stat ft-stat--progress">
        <div class="ft-stat__icon">
            <svg width="18" height="18" fill="none" stroke="#6a1b9a" stroke-width="2" viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
        </div>
        <div><div class="ft-stat__val"><asp:Literal ID="litInProgress" runat="server" Text="0" /></div><div class="ft-stat__label">In Progress</div></div>
    </div>
</div>

<!-- ═══ Main Student Card ═══ -->
<div class="ft-card">
    <div class="ft-card__header">
        <div class="ft-card__title">
            <svg width="14" height="14" fill="none" stroke="#05275C" stroke-width="2" viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
            Masters Certificate Management
        </div>
        <asp:Literal ID="litBadge" runat="server" />
    </div>

    <!-- Search / Filter Bar -->
    <div class="ft-filters">
        <div class="ft-filters__row">
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Search</span>
                <asp:TextBox ID="txtSearch" runat="server" placeholder="Name, Reg No, Programme..." CssClass="ft-filter-input" style="min-width:260px;" />
            </div>
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="ft-btn ft-btn--primary" OnClick="btnSearch_Click" />
            <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="ft-btn ft-btn--ghost" OnClick="btnClearSearch_Click" />
        </div>
    </div>

    <!-- Student Data Table -->
    <div class="ft-table-wrap">
        <table class="ft-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Reg No</th>
                    <th>Student Name</th>
                    <th>Programme</th>
                    <th>Thesis Title</th>
                    <th>Supervisor</th>
                    <th>Status</th>
                    <th style="text-align:center">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptStudents" runat="server" OnItemCommand="rptStudents_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td style="color:#999;font-size:10px;"><%# Container.ItemIndex + 1 %></td>
                            <td style="font-weight:600;color:#05275C;white-space:nowrap;"><%# Eval("regno") %></td>
                            <td class="ft-col-name"><%# FormatStudentName(Eval("firstname"), Eval("othername")) %></td>
                            <td style="font-size:10px;"><%# Eval("progname") %></td>
                            <td class="ft-col-thesis" title='<%# Eval("thesis_title") %>'><%# TruncateText(Eval("thesis_title"), 50) %></td>
                            <td><%# FormatSupervisor(Eval("supervisor_name")) %></td>
                            <td><%# FormatStatus(Eval("res_status")) %></td>
                            <td class="ft-col-actions">
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditThesis"
                                    CommandArgument='<%# Eval("regno") + "|||" + Eval("thesis_title") + "|||" + Eval("supervior_id") + "|||" + Eval("res_status") %>'
                                    CssClass="ft-btn ft-btn--edit ft-btn--sm" ToolTip="Edit thesis / supervisor">
                                    Edit
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoData" runat="server" Visible="false">
                    <tr><td colspan="8" class="ft-nodata">No graduate students found.</td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Literal ID="litFooter" runat="server" /></span>
    </div>
</div>

<!-- ═══ Thesis Edit Modal (rendered server-side, toggled via CSS class) ═══ -->
<asp:Panel ID="pnlModal" runat="server" CssClass="ft-modal-overlay" Visible="false">
    <div class="ft-modal">
        <div class="ft-modal__header">
            <span class="ft-modal__title">
                <asp:Literal ID="litModalTitle" runat="server" Text="Edit Thesis &amp; Supervisor" />
            </span>
            <asp:LinkButton ID="btnCloseModal" runat="server" CssClass="ft-modal__close" OnClick="btnCloseModal_Click" CausesValidation="false">&times;</asp:LinkButton>
        </div>
        <div class="ft-modal__body">
            <asp:HiddenField ID="hdnEditRegno" runat="server" Value="" />

            <div class="ft-form-group">
                <label>Student</label>
                <asp:Literal ID="litStudentInfo" runat="server" />
            </div>

            <div class="ft-form-group">
                <label>Thesis Title</label>
                <asp:TextBox ID="txtThesisTitle" runat="server" TextMode="MultiLine" Rows="3" placeholder="Enter the official thesis / dissertation title..." CssClass="ft-filter-input" />
                <div class="ft-form-info">This title will appear on the Master's Letter of Award and Academic Transcript.</div>
            </div>

            <div class="ft-form-group">
                <label>Supervisor</label>
                <asp:DropDownList ID="ddlSupervisor" runat="server" CssClass="ft-filter-select" style="width:100%;">
                    <asp:ListItem Text="-- Select Supervisor --" Value="0" />
                </asp:DropDownList>
                <div class="ft-form-info">Active supervisors from the supervisors register.</div>
            </div>
        </div>
        <div class="ft-modal__footer">
            <asp:Button ID="btnCancelModal" runat="server" Text="Cancel" CssClass="ft-btn ft-btn--cancel" OnClick="btnCloseModal_Click" CausesValidation="false" />
            <asp:Button ID="btnSaveThesis" runat="server" Text="Save Thesis Info" CssClass="ft-btn ft-btn--success" OnClick="btnSaveThesis_Click" />
        </div>
    </div>
</asp:Panel>

<!-- Auto-show modal via CSS class when visible -->
<script type="text/javascript">
    // Ensure modal overlay is properly shown when server renders it visible
    (function () {
        var overlay = document.querySelector('.ft-modal-overlay');
        if (overlay && overlay.style.display !== 'none') {
            overlay.classList.add('active');
        }
    })();
</script>

</asp:Content>
