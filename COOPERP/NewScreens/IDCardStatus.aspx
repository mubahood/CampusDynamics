<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="IDCardStatus.aspx.cs" Inherits="COOPERP_NewScreens_IDCardStatus" Title="ID Card Printing Status - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ID Card Status — idc- prefix ===== */

.idc-page{max-width:1200px;margin:0 auto;padding:20px 24px;}
.idc-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;flex-wrap:wrap;gap:10px;}
.idc-hdr h1{font-size:17px;font-weight:700;color:#05275C;display:flex;align-items:center;gap:8px;}
.idc-hdr h1 svg{width:20px;height:20px;}
.idc-hdr__actions{display:flex;gap:8px;align-items:center;}

.idc-btn{border:none;padding:7px 16px;font-size:12px;font-weight:600;cursor:pointer;display:inline-flex;align-items:center;gap:6px;border-radius:4px;transition:background .15s;}
.idc-btn--primary{background:#05275C;color:#fff;}.idc-btn--primary:hover{background:#08348a;}
.idc-btn--ghost{background:#fff;color:#05275C;border:1px solid #d0d5dd;}.idc-btn--ghost:hover{background:#f5f7fa;}
.idc-btn--danger{background:#dc2626;color:#fff;}.idc-btn--danger:hover{background:#b91c1c;}
.idc-btn svg{width:14px;height:14px;}
.idc-btn:disabled{opacity:.5;cursor:not-allowed;}

/* Stats */
.idc-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:16px;}
.idc-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 16px;border-radius:4px;}
.idc-stat__val{font-size:20px;font-weight:800;color:#05275C;}
.idc-stat__lbl{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.3px;margin-top:2px;}
.idc-stat--printed .idc-stat__val{color:#16a34a;}
.idc-stat--notprinted .idc-stat__val{color:#d97706;}
.idc-stat--notfound .idc-stat__val{color:#dc2626;}
.idc-stat--unknown .idc-stat__val{color:#888;}

/* Filters */
.idc-filters{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px;background:#fff;border:1px solid #e0e5ed;padding:10px 14px;border-radius:4px;align-items:center;}
.idc-filters label{font-size:11px;font-weight:600;color:#555;}
.idc-filters select,.idc-filters input[type=text]{font-size:12px;padding:5px 8px;border:1px solid #d0d5dd;border-radius:3px;background:#fff;}
.idc-filters input[type=text]{width:200px;}

/* Table */
.idc-tbl-wrap{border:1px solid #e0e5ed;border-radius:4px;overflow-x:auto;background:#fff;margin-bottom:12px;}
.idc-tbl{width:100%;border-collapse:collapse;font-size:11px;}
.idc-tbl th{padding:8px 12px;text-align:left;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px;color:#555;border-bottom:2px solid #e0e5ed;background:#f9fafc;white-space:nowrap;}
.idc-tbl td{padding:7px 12px;border-bottom:1px solid #f0f2f5;}
.idc-tbl tbody tr:hover td{background:#f9fafc;}
.idc-tbl .idc-chip{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;text-transform:uppercase;border-radius:2px;}
.idc-chip--printed{color:#16a34a;background:rgba(22,163,74,.08);}
.idc-chip--not-printed{color:#d97706;background:rgba(217,119,6,.08);}
.idc-chip--not-found{color:#dc2626;background:rgba(220,38,38,.08);}
.idc-chip--error{color:#dc2626;background:rgba(220,38,38,.08);}
.idc-chip--unknown{color:#888;background:#f5f5f5;}
.idc-tbl .idc-action-btn{border:none;background:transparent;color:#05275C;cursor:pointer;font-size:11px;font-weight:600;padding:3px 8px;border-radius:3px;}
.idc-tbl .idc-action-btn:hover{background:#f0f3fa;}

/* Pager */
.idc-pager{display:flex;justify-content:space-between;align-items:center;font-size:11px;color:#555;}
.idc-pager__btns{display:flex;gap:4px;}
.idc-pager__btn{border:1px solid #d0d5dd;background:#fff;padding:4px 10px;font-size:11px;cursor:pointer;border-radius:3px;}
.idc-pager__btn:hover{background:#f5f7fa;}
.idc-pager__btn--active{background:#05275C;color:#fff;border-color:#05275C;}

/* Toast */
.idc-toast{position:fixed;top:16px;right:16px;z-index:9999;min-width:280px;max-width:420px;padding:12px 16px;border-radius:4px;font-size:12px;font-weight:600;box-shadow:0 4px 12px rgba(0,0,0,.15);display:none;}
.idc-toast--ok{background:#ecfdf3;color:#166534;border:1px solid #bbf7d0;}
.idc-toast--err{background:#fef2f2;color:#b91c1c;border:1px solid #fecaca;}
.idc-toast--show{display:block;animation:idcSlide .3s ease-out;}
@keyframes idcSlide{from{transform:translateX(100%);opacity:0;}to{transform:translateX(0);opacity:1;}}

/* Sync progress */
.idc-sync-bar{display:none;background:#fff;border:1px solid #e0e5ed;padding:12px 16px;border-radius:4px;margin-bottom:12px;}
.idc-sync-bar--show{display:block;}
.idc-sync-bar__progress{height:6px;background:#e0e5ed;border-radius:3px;overflow:hidden;margin-top:8px;}
.idc-sync-bar__fill{height:100%;background:#05275C;transition:width .3s;width:0%;}
.idc-sync-bar__text{font-size:11px;color:#555;}

@media(max-width:768px){.idc-stats{grid-template-columns:repeat(2,1fr);}.idc-filters{flex-direction:column;}}
@media(max-width:500px){.idc-stats{grid-template-columns:1fr;}.idc-hdr{flex-direction:column;align-items:flex-start;}}
</style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="idc-page">

    <!-- Toast -->
    <div id="idcToast" class="idc-toast"></div>

    <!-- Header -->
    <div class="idc-hdr">
        <h1>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
            ID Card Printing Status
        </h1>
        <div class="idc-hdr__actions">
            <button type="button" class="idc-btn idc-btn--ghost" onclick="idcRefreshAll()">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
                Sync All from OmniPass
            </button>
            <asp:Button ID="btnApplyFilter" runat="server" CssClass="idc-btn idc-btn--primary" Text="Apply Filters" OnClick="btnApplyFilter_Click" />
        </div>
    </div>

    <!-- Sync progress bar -->
    <div id="idcSyncBar" class="idc-sync-bar">
        <div class="idc-sync-bar__text" id="idcSyncText">Syncing with OmniPass...</div>
        <div class="idc-sync-bar__progress"><div id="idcSyncFill" class="idc-sync-bar__fill"></div></div>
    </div>

    <!-- Stats -->
    <div class="idc-stats">
        <div class="idc-stat"><div class="idc-stat__val"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div><div class="idc-stat__lbl">Total Students</div></div>
        <div class="idc-stat idc-stat--printed"><div class="idc-stat__val"><asp:Literal ID="litStatPrinted" runat="server" Text="0" /></div><div class="idc-stat__lbl">Printed</div></div>
        <div class="idc-stat idc-stat--notprinted"><div class="idc-stat__val"><asp:Literal ID="litStatNotPrinted" runat="server" Text="0" /></div><div class="idc-stat__lbl">Not Printed</div></div>
        <div class="idc-stat idc-stat--notfound"><div class="idc-stat__val"><asp:Literal ID="litStatNotFound" runat="server" Text="0" /></div><div class="idc-stat__lbl">Not in System</div></div>
        <div class="idc-stat idc-stat--unknown"><div class="idc-stat__val"><asp:Literal ID="litStatUnchecked" runat="server" Text="0" /></div><div class="idc-stat__lbl">Unchecked</div></div>
    </div>

    <!-- Filters -->
    <div class="idc-filters">
        <label>Status:</label>
        <asp:DropDownList ID="ddlStatus" runat="server">
            <asp:ListItem Value="" Text="All" />
            <asp:ListItem Value="PRINTED" Text="Printed" />
            <asp:ListItem Value="NOT_PRINTED" Text="Not Printed" />
            <asp:ListItem Value="NOT_FOUND" Text="Not in System" />
            <asp:ListItem Value="__NULL" Text="Unchecked" />
        </asp:DropDownList>
        <label>Programme:</label>
        <asp:DropDownList ID="ddlProgramme" runat="server" />
        <label>Search:</label>
        <asp:TextBox ID="txtSearch" runat="server" placeholder="Name, Reg No..." />
        <label>Page Size:</label>
        <asp:DropDownList ID="ddlPageSize" runat="server">
            <asp:ListItem Value="50" Text="50" Selected="True" />
            <asp:ListItem Value="100" Text="100" />
            <asp:ListItem Value="200" Text="200" />
        </asp:DropDownList>
    </div>

    <asp:HiddenField ID="hfPageIndex" runat="server" Value="0" />

    <!-- Table -->
    <div class="idc-tbl-wrap">
        <table class="idc-tbl">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Student Name</th>
                    <th>Reg No</th>
                    <th>Programme</th>
                    <th>Entry Year</th>
                    <th>ID Card Status</th>
                    <th>Last Checked</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptStudents" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("row_num") %></td>
                            <td><%# SafeEncode(Eval("student_name")) %></td>
                            <td><strong><%# SafeEncode(Eval("regno")) %></strong></td>
                            <td><%# SafeEncode(Eval("progid")) %></td>
                            <td><%# Eval("entryyear") %></td>
                            <td><span class='idc-chip idc-chip--<%# GetStatusCss(Eval("id_card_status")) %>'><%# GetStatusLabel(Eval("id_card_status")) %></span></td>
                            <td><%# FormatCheckedAt(Eval("id_card_checked_at")) %></td>
                            <td><button type="button" class="idc-action-btn" data-reg='<%# SafeEncode(Eval("regno")) %>' onclick="idcCheckOne(this.getAttribute('data-reg'),this)">&#x21bb; Check</button></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div style="text-align:center;padding:40px;color:#888;background:#fff;border:1px solid #e0e5ed;border-radius:4px;">No students match the current filters.</div>
    </asp:Panel>

    <!-- Pager -->
    <div class="idc-pager">
        <asp:Literal ID="litRecordInfo" runat="server" Text="0 records" />
        <div class="idc-pager__btns"><asp:Literal ID="litPager" runat="server" /></div>
    </div>

</div>

<script type="text/javascript">
    var _idcBaseUrl = '<%= ResolveUrl("~/COOPERP/NewScreens/IDCardStatus.aspx") %>';

    function idcCheckOne(regno, btn) {
        if (!regno) return;
        btn.disabled = true;
        btn.textContent = '...';
        fetch(_idcBaseUrl + '?ajax=check&regno=' + encodeURIComponent(regno) + '&_ts=' + Date.now(), {
            credentials: 'same-origin',
            headers: { 'Accept': 'application/json' }
        })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.ok) {
                // Update the row in place
                var tr = btn.closest('tr');
                if (tr) {
                    var chip = tr.querySelector('.idc-chip');
                    if (chip) {
                        chip.className = 'idc-chip idc-chip--' + d.css;
                        chip.textContent = d.label;
                    }
                    var cells = tr.getElementsByTagName('td');
                    if (cells.length >= 7) cells[6].textContent = d.checked_at;
                }
                idcToast(d.label + ' — ' + (d.message || ''), true);
            } else {
                idcToast(d.error || 'Check failed.', false);
            }
            btn.disabled = false;
            btn.innerHTML = '&#x21bb; Check';
        })
        .catch(function(err) {
            idcToast('Error: ' + err.message, false);
            btn.disabled = false;
            btn.innerHTML = '&#x21bb; Check';
        });
    }

    function idcRefreshAll() {
        if (!confirm('Sync all student records from OmniPass? This may take a moment.')) return;
        var bar = document.getElementById('idcSyncBar');
        var fill = document.getElementById('idcSyncFill');
        var text = document.getElementById('idcSyncText');
        bar.className = 'idc-sync-bar idc-sync-bar--show';
        fill.style.width = '30%';
        text.textContent = 'Syncing with OmniPass API...';

        fetch(_idcBaseUrl + '?ajax=syncall&_ts=' + Date.now(), {
            credentials: 'same-origin',
            headers: { 'Accept': 'application/json' }
        })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            fill.style.width = '100%';
            if (d.ok) {
                text.textContent = 'Sync complete! ' + d.updated + ' records updated.';
                idcToast('Sync complete — ' + d.updated + ' records updated.', true);
                setTimeout(function() { location.reload(); }, 1500);
            } else {
                text.textContent = 'Sync failed: ' + (d.error || 'Unknown error');
                idcToast(d.error || 'Sync failed.', false);
            }
        })
        .catch(function(err) {
            fill.style.width = '100%';
            text.textContent = 'Sync error: ' + err.message;
            idcToast('Sync error.', false);
        });
    }

    function idcToast(msg, ok) {
        var t = document.getElementById('idcToast');
        t.textContent = msg;
        t.className = 'idc-toast ' + (ok ? 'idc-toast--ok' : 'idc-toast--err') + ' idc-toast--show';
        setTimeout(function() { t.className = 'idc-toast'; }, 4000);
    }

    function idcPage(idx) {
        document.getElementById('<%= hfPageIndex.ClientID %>').value = idx;
        __doPostBack('<%= btnApplyFilter.UniqueID %>', '');
    }
</script>

</asp:Content>
