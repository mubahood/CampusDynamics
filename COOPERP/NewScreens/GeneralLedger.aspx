<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="GeneralLedger.aspx.cs" Inherits="COOPERP_NewScreens_GeneralLedger" Title="General Ledger - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style>
*{box-sizing:border-box;}

/* ===== GENERAL LEDGER - ft- design system ========================== */

.pm-admin-wrap{max-width:1320px;margin:0 auto;padding:8px 10px 12px;}

/* Stats Row */
.ft-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.ft-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;display:flex;align-items:center;gap:10px;position:relative;overflow:hidden}
.ft-stat::after{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--stat-c,#ccc)}
.ft-stat__icon{width:32px;height:32px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ft-stat__val{font-size:15px;font-weight:700;line-height:1.2;font-variant-numeric:tabular-nums;word-break:break-word;overflow-wrap:break-word}
.ft-stat__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#888;margin-top:2px}
.ft-stat--dr{--stat-c:#174DA4}.ft-stat--dr .ft-stat__icon{background:#e8f0fc}.ft-stat--dr .ft-stat__val{color:#174DA4}
.ft-stat--cr{--stat-c:#2e7d32}.ft-stat--cr .ft-stat__icon{background:#e6f4ea}.ft-stat--cr .ft-stat__val{color:#2e7d32}
.ft-stat--net{--stat-c:#e65100}.ft-stat--net .ft-stat__icon{background:#fff3e0}.ft-stat--net .ft-stat__val{color:#e65100}
.ft-stat--count{--stat-c:#05275C}.ft-stat--count .ft-stat__icon{background:#e8f0fc}.ft-stat--count .ft-stat__val{color:#05275C}

/* Card / Filters */
.ft-card{background:#fff;border:1px solid #e3e9f2;border-radius:8px;overflow:visible;margin-bottom:10px}
.ft-card__header{padding:8px 10px;border-bottom:1px solid #edf1f6;background:#fff;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap}
.ft-card__title{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;display:flex;align-items:center;gap:6px}
.ft-card__sub{font-size:10px;color:#6b7280}
.ft-card__meta{font-size:10px;color:#174DA4;font-weight:700;background:#f1f5ff;padding:3px 8px;border:1px solid #d8e2f6;border-radius:999px}
.ft-filters{background:#fff;border-bottom:1px solid #eef2f6;padding:8px 10px}
.ft-filters__row{display:grid;grid-template-columns:minmax(220px,1.6fr) minmax(150px,.8fr) minmax(240px,1.4fr) minmax(130px,.7fr) auto;gap:6px;align-items:end}
.ft-filters__row--advanced{margin-top:7px;padding-top:7px;border-top:1px dashed #e7edf5;grid-template-columns:minmax(130px,.8fr) minmax(130px,.8fr) minmax(90px,.55fr) 1fr}
.ft-filter-grp{display:flex;flex-direction:column;gap:3px;min-width:0}
.ft-filter-grp--wide{grid-column:auto}
.ft-filter-grp__label{font-size:9px;text-transform:uppercase;letter-spacing:.5px;color:#999;font-weight:600}
.ft-filter-select,.ft-filter-input{height:30px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;color:#1a1a2e;cursor:pointer;min-width:0;width:100%;font-family:inherit;border-radius:6px}
.ft-filter-select:focus,.ft-filter-input:focus{border-color:#174DA4;outline:none;box-shadow:0 0 0 3px rgba(23,77,164,.12);background:#fcfdff}
.ft-select-hidden{display:none !important;}
.ft-filters__actions{display:flex;gap:6px;align-items:end;justify-content:flex-start;flex-wrap:wrap;min-width:max-content}
.ft-filters__adv-toggle{display:inline-flex;align-items:center;gap:5px;font-size:10px;font-weight:700;color:#174DA4;cursor:pointer;user-select:none;white-space:nowrap}
.ft-filters__adv-wrap{display:none}
.ft-filters__adv-wrap.show{display:block}
.ft-filters__hint{font-size:10px;color:#64748b}
.ft-filter-search{margin-bottom:4px}
.ft-modal-search{margin-bottom:4px}
.ft-suggest-wrap{position:relative}
.ft-filter-input::-webkit-calendar-picker-indicator{opacity:.65}

/* Buttons */
.ft-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 9px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;border-radius:6px;min-height:30px;text-decoration:none;white-space:nowrap;transition:all .15s;font-family:inherit}
.ft-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff}
.ft-btn--primary{background:#05275C;color:#fff;border-color:#05275C}.ft-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff}
.ft-btn--ghost{background:transparent;border:1px solid #d2dae6;color:#475569}.ft-btn--ghost:hover{border-color:#174DA4;color:#174DA4;background:#f4f8ff}
.ft-btn--sm{padding:5px 11px;font-size:10px}

/* Alerts */
.ft-alert{padding:9px 12px;border:1px solid transparent;border-radius:6px;font-size:11px;font-weight:700;margin-bottom:10px}
.ft-alert--ok{background:#f0fdf4;border-color:#bbf7d0;color:#15803d}
.ft-alert--err{background:#fef2f2;border-color:#fecaca;color:#b91c1c}

/* Badges */
.ft-badge{display:inline-block;padding:3px 9px;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.3px}
.ft-badge--dr{background:#e8f0fc;color:#174DA4}
.ft-badge--cr{background:#e6f4ea;color:#2e7d32}

/* Data Table */
.ft-table-wrap{overflow:auto;max-height:560px;border-bottom:1px solid #e0e5ed;position:relative;scrollbar-color:#b6c5db #f5f8fc;scrollbar-width:thin;background:#fff}
.ft-table{width:100%;border-collapse:collapse;min-width:1000px;font-size:12px}
.ft-table thead tr{position:sticky;top:0;z-index:10}
.ft-table thead th{background:#f8fafc;color:#64748b;font-size:9px;text-transform:uppercase;letter-spacing:.45px;font-weight:800;padding:6px 8px;border-bottom:1px solid #e0e5ed;white-space:nowrap;box-shadow:0 2px 0 #e0e5ed;text-align:left}
.ft-table thead th a{color:inherit;text-decoration:none;font-weight:inherit}
.ft-table thead th a:hover{color:#174DA4}
.ft-table tbody tr{border-bottom:1px solid #f0f2f5;transition:background .08s}
.ft-table tbody tr:nth-child(even){background:#f9fafb}
.ft-table tbody tr:hover,.ft-table tbody tr:nth-child(even):hover{background:#eef2fc}
.ft-table tbody td{padding:6px 8px;vertical-align:middle;color:#1f2937;font-size:11px}
.ft-col-id{width:60px}.ft-col-date{width:92px;white-space:nowrap}.ft-col-acc{width:100px;color:#05275C;font-weight:700}
.ft-col-acctype{width:90px}.ft-col-part{min-width:180px}.ft-col-drcr{width:50px;text-align:center}
.ft-col-amt{width:120px;text-align:right;font-weight:700;font-variant-numeric:tabular-nums}
.ft-col-voucher{width:80px}.ft-col-user{width:100px}
td.ft-col-part{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:260px}

/* Totals Bar */
.ft-totals{display:flex;align-items:center;gap:16px;padding:7px 14px;background:linear-gradient(90deg,#f0f4fc 0%,#f8f9fb 100%);border-top:1px solid #e0e5ed;font-size:11px}
.ft-totals__label{font-weight:700;color:#555;text-transform:uppercase;letter-spacing:.6px;font-size:9px;margin-right:2px}
.ft-totals__pills{display:flex;gap:8px;flex-wrap:wrap;align-items:center}
.ft-totals__pill{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;font-weight:600;font-variant-numeric:tabular-nums;line-height:1.5;white-space:nowrap}
.ft-totals__pill--dr{background:#e8f0fc;color:#174DA4;border:1px solid #c5d5f0}
.ft-totals__pill--cr{background:#e6f4ea;color:#2e7d32;border:1px solid #c8e6c9}
.ft-totals__pill--net{background:#fff3e0;color:#e65100;border:1px solid #ffcc80}

/* Pager */
.ft-pager{display:flex;align-items:center;justify-content:space-between;padding:8px 14px;background:#f8f9fb;border-top:1px solid #e0e5ed;font-size:11px;color:#666;flex-wrap:wrap;gap:8px}
.ft-pager__info strong{color:#05275C}
.ft-pager__btns{display:flex;gap:3px;align-items:center;flex-wrap:wrap}
.ft-pager__btn{min-width:30px;padding:4px 8px;font-size:11px;font-weight:600;border:1px solid #e0e5ed;background:#fff;color:#444;cursor:pointer;font-family:inherit;line-height:1.4;text-align:center}
.ft-pager__btn:hover:not([disabled]){border-color:#174DA4;color:#174DA4;background:#eef2fc}
.ft-pager__btn[disabled]{opacity:.4;cursor:not-allowed}
.ft-pager__btn--active{background:#05275C!important;color:#fff!important;border-color:#05275C!important}
.ft-pager__ellipsis{padding:4px 2px;color:#aaa;font-size:12px}

/* Modal */
.ft-overlay{display:none;position:fixed;inset:0;background:rgba(5,15,35,.55);z-index:9990}
.ft-overlay.show{display:block}
.ft-modal{display:none;position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);z-index:9991;background:#fff;border:1px solid #dbe2ec;border-radius:8px;box-shadow:0 20px 55px rgba(2,10,30,.28);width:min(860px,95vw);max-height:90vh;overflow:auto}
.ft-modal.show{display:block}
.ft-modal__head{display:flex;align-items:center;justify-content:space-between;padding:12px 14px;border-bottom:1px solid #e7edf5;background:#f8f9fb}
.ft-modal__title{font-size:12px;font-weight:800;letter-spacing:.4px;text-transform:uppercase;color:#05275C}
.ft-modal__close{background:transparent;border:0;font-size:20px;color:#6b7280;cursor:pointer;line-height:1}
.ft-modal__body{padding:14px}
.ft-modal__foot{padding:10px 14px;border-top:1px solid #e7edf5;background:#f8f9fb;display:flex;justify-content:flex-end;gap:8px;flex-wrap:wrap}
.ft-form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}
.ft-form-full{grid-column:1/-1}
.ft-help{font-size:10px;color:#64748b}
.ft-check{display:flex;align-items:center;gap:6px;font-size:11px;color:#334155}

/* Top Loader + Toast */
.ft-top-loader{position:fixed;top:0;left:0;right:0;height:3px;background:#e2e8f0;z-index:10020;display:none}
.ft-top-loader.show{display:block}
.ft-top-loader__bar{height:100%;width:35%;background:linear-gradient(90deg,#05275C,#174DA4);animation:ft-load-move 1.1s linear infinite}
@keyframes ft-load-move{0%{transform:translateX(-120%)}100%{transform:translateX(420%)}}
.ft-top-loader__txt{position:fixed;top:8px;right:12px;background:#05275C;color:#fff;font-size:10px;font-weight:700;padding:4px 8px;border-radius:5px;z-index:10021;display:none}
.ft-top-loader__txt.show{display:block}
.ft-toast{position:fixed;right:16px;bottom:16px;z-index:10030;display:none;min-width:220px;max-width:360px;padding:10px 12px;border-radius:8px;color:#fff;font-size:11px;font-weight:700;box-shadow:0 10px 26px rgba(2,10,30,.22)}
.ft-toast.show{display:block}
.ft-toast--ok{background:#15803d}
.ft-toast--err{background:#b91c1c}

/* No Data */
.ft-nodata{padding:44px 20px;text-align:center;color:#999;font-size:13px}
.ft-nodata svg{display:block;margin:0 auto 8px}

/* Responsive */
@media(max-width:1200px){.ft-filters__row,.ft-filters__row--advanced{grid-template-columns:repeat(2,minmax(0,1fr))}.ft-filter-grp--wide{grid-column:span 2}.ft-filters__actions{grid-column:span 2}}
@media(max-width:900px){.ft-filter-grp--wide,.ft-filters__actions{grid-column:span 1}}
@media(max-width:768px){.ft-stats{grid-template-columns:repeat(2,1fr)}.ft-filters__row,.ft-filters__row--advanced{grid-template-columns:1fr}.ft-filters__actions{grid-column:span 1;justify-content:stretch}.ft-filters__actions .ft-btn{width:100%;justify-content:center}.ft-form-grid{grid-template-columns:1fr}}
@media print{.ft-filters,.ft-btn,.ft-pager{display:none!important}.ft-table-wrap{max-height:none!important;overflow:visible!important}}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<div class="pm-admin-wrap">

<div id="glTopLoader" class="ft-top-loader"><div class="ft-top-loader__bar"></div></div>
<div id="glTopLoaderText" class="ft-top-loader__txt">Loading...</div>
<div id="glToast" class="ft-toast"></div>

<asp:Panel ID="pnlHiddenTopStats" runat="server" Style="display:none;">
    <asp:Literal ID="litSumDR" runat="server" Text="UGX 0" />
    <asp:Literal ID="litSumCR" runat="server" Text="UGX 0" />
    <asp:Literal ID="litNetBalance" runat="server" Text="UGX 0" />
    <asp:Literal ID="litRecordCount" runat="server" Text="0" />
</asp:Panel>

<asp:Literal ID="litPeriodBadge" runat="server" Visible="false" />

<asp:Label ID="lblMessage" runat="server" EnableViewState="false" />

<div id="glOverlay" class="ft-overlay" onclick="closeTxnModal()"></div>
<div id="glTxnModal" class="ft-modal">
    <div class="ft-modal__head">
        <div class="ft-modal__title">Create New Double-Entry Transaction</div>
        <button type="button" class="ft-modal__close" onclick="closeTxnModal()">&times;</button>
    </div>
    <div class="ft-modal__body">
        <div class="ft-form-grid">
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Transaction Date</span>
                <asp:TextBox ID="txtTxnDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Reference / Voucher No</span>
                <asp:TextBox ID="txtTxnReference" runat="server" CssClass="ft-filter-input" MaxLength="40" placeholder="Optional (auto-generated if blank)" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Debit Account</span>
                <div class="ft-suggest-wrap">
                    <input type="text" id="txtTxnDrAccountSearch" class="ft-filter-input ft-modal-search" placeholder="Type debit account..." autocomplete="off" />
                </div>
                <asp:DropDownList ID="ddlTxnDrAccount" runat="server" CssClass="ft-filter-select ft-select-hidden" />
                <span class="ft-help">Debit side is positive <strong>(+)</strong>.</span>
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Credit Account</span>
                <div class="ft-suggest-wrap">
                    <input type="text" id="txtTxnCrAccountSearch" class="ft-filter-input ft-modal-search" placeholder="Type credit account..." autocomplete="off" />
                </div>
                <asp:DropDownList ID="ddlTxnCrAccount" runat="server" CssClass="ft-filter-select ft-select-hidden" />
                <span class="ft-help">Credit side is negative <strong>(-)</strong>.</span>
            </div>
            <div class="ft-filter-grp ft-form-full">
                <span class="ft-filter-grp__label">Amount (UGX)</span>
                <asp:TextBox ID="txtTxnAmount" runat="server" CssClass="ft-filter-input" MaxLength="18" placeholder="UGX e.g. 150000" />
                <span class="ft-help">Amount is in <strong>UGX</strong>. One amount is posted to both sides: DR(+) = CR(-) (strict double-entry).</span>
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Debit Particulars *</span>
                <asp:TextBox ID="txtTxnDrParticulars" runat="server" CssClass="ft-filter-input" MaxLength="200" required="required" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Credit Particulars</span>
                <asp:TextBox ID="txtTxnCrParticulars" runat="server" CssClass="ft-filter-input" MaxLength="200" placeholder="Optional (auto-generated if left blank)" />
            </div>
        </div>
    </div>
    <div class="ft-modal__foot">
        <label class="ft-check" style="margin-right:auto;">
            <input type="checkbox" id="chkKeepAccounts" />
            Continue with same accounts
        </label>
        <button type="button" class="ft-btn ft-btn--ghost" onclick="closeTxnModal()">Cancel</button>
        <button type="button" id="btnCreateTxnAjax" class="ft-btn ft-btn--primary" onclick="saveTransactionAjax()">Post Transaction</button>
        <asp:Button ID="btnCreateTransaction" runat="server" Text="Post Transaction" CssClass="ft-btn ft-btn--primary" OnClick="btnCreateTransaction_Click" Style="display:none;" />
    </div>
</div>

<!-- Filter + Data Card -->
<div class="ft-card">
    <div class="ft-card__header">
        <div>
            <div class="ft-card__title">General Ledger Controller</div>
            <div class="ft-card__sub">Filter, sort, and post balanced double-entry transactions</div>
        </div>
        <span class="ft-card__meta"><asp:Literal ID="litPeriodBadgeView" runat="server" /></span>
    </div>
    <div class="ft-filters">
        <div class="ft-filters__row">
            <div class="ft-filter-grp ft-filter-grp--wide">
                <span class="ft-filter-grp__label">Account</span>
                <div class="ft-suggest-wrap">
                    <input type="text" id="txtAccountSearch" class="ft-filter-input ft-filter-search" placeholder="Type account code or name..." autocomplete="off" />
                </div>
                <asp:DropDownList ID="ddlAccount" runat="server" CssClass="ft-filter-select ft-select-hidden" />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Academic Year</span>
                <asp:DropDownList ID="ddlAcademicYear" runat="server" CssClass="ft-filter-select" />
            </div>
            <div class="ft-filter-grp ft-filter-grp--wide">
                <span class="ft-filter-grp__label">Description Search</span>
                <asp:TextBox ID="txtDescriptionSearch" runat="server" CssClass="ft-filter-input" MaxLength="120" placeholder="Search particulars / description..." />
            </div>
            <div class="ft-filter-grp">
                <span class="ft-filter-grp__label">Type</span>
                <asp:DropDownList ID="ddlType" runat="server" CssClass="ft-filter-select">
                    <asp:ListItem Text="All Types" Value="" />
                    <asp:ListItem Text="DR - Debit" Value="DR" />
                    <asp:ListItem Text="CR - Credit" Value="CR" />
                </asp:DropDownList>
            </div>
            <div class="ft-filters__actions">
                <span class="ft-filters__adv-toggle" onclick="toggleAdvancedFilters()" id="glAdvToggle">▸ Advanced Filters</span>
                <button type="button" class="ft-btn ft-btn--primary" onclick="openTxnModal();">+ New Transaction</button>
                <button type="button" class="ft-btn ft-btn--primary" onclick="applyLedgerFilters();">Load Ledger</button>
                <button type="button" class="ft-btn ft-btn--ghost ft-btn--sm" onclick="window.print();" title="Print">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                    Print
                </button>
            </div>
        </div>
        <div id="glAdvancedFilters" class="ft-filters__adv-wrap">
            <div class="ft-filters__row ft-filters__row--advanced">
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">Start Date</span>
                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
                </div>
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">End Date</span>
                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="ft-filter-input" />
                </div>
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">Per Page</span>
                    <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ft-filter-select" onchange="applyLedgerFilters();">
                        <asp:ListItem Text="30" Value="30" />
                        <asp:ListItem Text="50" Value="50" Selected="True" />
                        <asp:ListItem Text="100" Value="100" />
                        <asp:ListItem Text="200" Value="200" />
                    </asp:DropDownList>
                </div>
                <div class="ft-filter-grp">
                    <span class="ft-filter-grp__label">Hint</span>
                    <div class="ft-filters__hint">Academic Year filter auto-defines date range (Jul→Jun). Use these dates only when AY is set to All.</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Data Table -->
    <div class="ft-table-wrap">
        <table class="ft-table">
            <colgroup>
                <col class="ft-col-id"><col class="ft-col-date"><col class="ft-col-acc">
                <col class="ft-col-acctype"><col class="ft-col-part"><col class="ft-col-drcr">
                <col class="ft-col-amt"><col class="ft-col-voucher"><col class="ft-col-user">
            </colgroup>
            <thead>
                <tr>
                    <th><a href="<%= BuildSortUrl("TID") %>">ID <%= GetSortIndicator("TID") %></a></th>
                    <th><a href="<%= BuildSortUrl("transactionDate") %>">Date <%= GetSortIndicator("transactionDate") %></a></th>
                    <th><a href="<%= BuildSortUrl("accountcode") %>">Account <%= GetSortIndicator("accountcode") %></a></th>
                    <th><a href="<%= BuildSortUrl("account_type") %>">Acc Type <%= GetSortIndicator("account_type") %></a></th>
                    <th><a href="<%= BuildSortUrl("particulars") %>">Particulars <%= GetSortIndicator("particulars") %></a></th>
                    <th><a href="<%= BuildSortUrl("transactionType") %>">DR/CR <%= GetSortIndicator("transactionType") %></a></th>
                    <th style="text-align:right"><a href="<%= BuildSortUrl("transaction_amount") %>">Amount <%= GetSortIndicator("transaction_amount") %></a></th>
                    <th><a href="<%= BuildSortUrl("voucherNo") %>">Voucher <%= GetSortIndicator("voucherNo") %></a></th>
                    <th><a href="<%= BuildSortUrl("teller") %>">User <%= GetSortIndicator("teller") %></a></th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptLedger" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("TID") %></td>
                            <td class="ft-col-date"><%# Eval("transactionDate", "{0:dd MMM yyyy}") %></td>
                            <td class="ft-col-acc"><%# Eval("accountcode") %></td>
                            <td><%# Eval("account_type") %></td>
                            <td class="ft-col-part" title='<%# Eval("particulars") %>'><%# Eval("particulars") %></td>
                            <td style="text-align:center"><span class='ft-badge <%# Eval("transactionType").ToString()=="DR" ? "ft-badge--dr" : "ft-badge--cr" %>'><%# Eval("transactionType").ToString()=="DR" ? "DR (+)" : "CR (-)" %></span></td>
                            <td style="text-align:right;font-weight:700;font-variant-numeric:tabular-nums;"><%# Eval("transaction_amount", "{0:N0}") %></td>
                            <td><%# Eval("voucherNo") %></td>
                            <td><%# Eval("teller") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phNoData" runat="server" Visible="false">
                    <tr><td colspan="9" class="ft-nodata">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        No ledger entries match your current filters.
                    </td></tr>
                </asp:PlaceHolder>
            </tbody>
        </table>
    </div>

    <!-- Totals Bar -->
    <div class="ft-totals">
        <span class="ft-totals__label">Totals</span>
        <div class="ft-totals__pills">
            <span class="ft-totals__pill ft-totals__pill--dr">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/></svg>
                DR: <asp:Literal ID="litTotalBarDR" runat="server" />
            </span>
            <span class="ft-totals__pill ft-totals__pill--cr">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 18 13.5 8.5 8.5 13.5 1 6"/></svg>
                CR: <asp:Literal ID="litTotalBarCR" runat="server" />
            </span>
            <asp:Literal ID="litTotalBarNet" runat="server" />
        </div>
    </div>

    <!-- Pager -->
    <div class="ft-pager">
        <span class="ft-pager__info"><asp:Label ID="lblGridFooter" runat="server" Text="" /></span>
        <asp:Literal ID="litPager" runat="server" />
    </div>
</div>

</div>

<script>
function setTopLoading(show, text){
    var loader = document.getElementById('glTopLoader');
    var lbl = document.getElementById('glTopLoaderText');
    if(loader){ loader.classList[show ? 'add' : 'remove']('show'); }
    if(lbl){
        if(text){ lbl.textContent = text; }
        lbl.classList[show ? 'add' : 'remove']('show');
    }
}

function showToast(message, success){
    var toast = document.getElementById('glToast');
    if(!toast){ return; }
    toast.textContent = message || '';
    toast.className = 'ft-toast show ' + (success ? 'ft-toast--ok' : 'ft-toast--err');
    window.setTimeout(function(){ toast.className = 'ft-toast'; }, 2800);
}

function applyLedgerFilters(){
    if(window.resolveSearchToDropdown){
        window.resolveSearchToDropdown('txtAccountSearch', '<%= ddlAccount.ClientID %>');
    }

    var start = document.getElementById('<%= txtStartDate.ClientID %>').value || '';
    var end = document.getElementById('<%= txtEndDate.ClientID %>').value || '';
    var account = document.getElementById('<%= ddlAccount.ClientID %>').value || '';
    var academicYear = document.getElementById('<%= ddlAcademicYear.ClientID %>').value || '';
    var desc = document.getElementById('<%= txtDescriptionSearch.ClientID %>').value || '';
    var type = document.getElementById('<%= ddlType.ClientID %>').value || '';
    var ps = document.getElementById('<%= ddlPageSize.ClientID %>').value || '50';
    var adv = document.getElementById('glAdvancedFilters').classList.contains('show') ? '1' : '';

    var sort = '<%= (Request.QueryString["sort"] ?? string.Empty).Replace("'", "\\'") %>';
    var dir = '<%= (Request.QueryString["dir"] ?? string.Empty).Replace("'", "\\'") %>';

    var parts = [];
    if(start){ parts.push('start=' + encodeURIComponent(start)); }
    if(end){ parts.push('end=' + encodeURIComponent(end)); }
    if(account){ parts.push('acc=' + encodeURIComponent(account)); }
    if(academicYear){ parts.push('ay=' + encodeURIComponent(academicYear)); }
    if(desc){ parts.push('q=' + encodeURIComponent(desc)); }
    if(type){ parts.push('type=' + encodeURIComponent(type)); }
    if(ps){ parts.push('ps=' + encodeURIComponent(ps)); }
    if(adv){ parts.push('adv=' + adv); }
    parts.push('pg=1');
    if(sort){ parts.push('sort=' + encodeURIComponent(sort)); }
    if(dir){ parts.push('dir=' + encodeURIComponent(dir)); }

    setTopLoading(true, 'Loading ledger...');
    window.location.href = 'GeneralLedger.aspx?' + parts.join('&');
}

function toggleAdvancedFilters(forceShow){
    var panel = document.getElementById('glAdvancedFilters');
    var toggle = document.getElementById('glAdvToggle');
    if(!panel || !toggle){ return; }

    var show = (typeof forceShow === 'boolean') ? forceShow : !panel.classList.contains('show');
    panel.classList[show ? 'add' : 'remove']('show');
    toggle.textContent = (show ? '▾' : '▸') + ' Advanced Filters';
}

function openTxnModal(){
    var overlay = document.getElementById('glOverlay');
    var modal = document.getElementById('glTxnModal');
    if(overlay){ overlay.classList.add('show'); }
    if(modal){ modal.classList.add('show'); }
    document.body.style.overflow = 'hidden';
}

function closeTxnModal(){
    var overlay = document.getElementById('glOverlay');
    var modal = document.getElementById('glTxnModal');
    if(overlay){ overlay.classList.remove('show'); }
    if(modal){ modal.classList.remove('show'); }
    document.body.style.overflow = '';
}

function showClientMessage(message, success){
    var lbl = document.getElementById('<%= lblMessage.ClientID %>');
    if(!lbl){ return; }
    lbl.innerHTML = '<div class="ft-alert ' + (success ? 'ft-alert--ok' : 'ft-alert--err') + '">' +
        String(message || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') +
        '</div>';
    showToast(message, success);
}

function refreshLedgerListAjax(){
    setTopLoading(true, 'Refreshing list...');
    return fetch(window.location.href, { credentials: 'same-origin' })
        .then(function(resp){ return resp.text(); })
        .then(function(html){
            var parser = new DOMParser();
            var doc = parser.parseFromString(html, 'text/html');

            var currentBody = document.querySelector('.ft-table tbody');
            var newBody = doc.querySelector('.ft-table tbody');
            if(currentBody && newBody){ currentBody.innerHTML = newBody.innerHTML; }

            var currentTotals = document.querySelector('.ft-totals .ft-totals__pills');
            var newTotals = doc.querySelector('.ft-totals .ft-totals__pills');
            if(currentTotals && newTotals){ currentTotals.innerHTML = newTotals.innerHTML; }

            var currentFooter = document.getElementById('<%= lblGridFooter.ClientID %>');
            var newFooter = doc.getElementById('<%= lblGridFooter.ClientID %>');
            if(currentFooter && newFooter){ currentFooter.innerHTML = newFooter.innerHTML; }

            var currentPager = document.getElementById('<%= litPager.ClientID %>');
            var newPager = doc.getElementById('<%= litPager.ClientID %>');
            if(currentPager && newPager){ currentPager.innerHTML = newPager.innerHTML; }
        })
        .finally(function(){
            setTopLoading(false);
        });
}

function saveTransactionAjax(){
    if(window.resolveSearchToDropdown){
        var drOk = window.resolveSearchToDropdown('txtTxnDrAccountSearch', '<%= ddlTxnDrAccount.ClientID %>');
        var crOk = window.resolveSearchToDropdown('txtTxnCrAccountSearch', '<%= ddlTxnCrAccount.ClientID %>');
        if(!drOk || !crOk){
            showClientMessage('Please select valid Debit and Credit accounts from suggestions.', false);
            showToast('Please select valid Debit and Credit accounts.', false);
            return;
        }
    }

    var btn = document.getElementById('btnCreateTxnAjax');
    if(btn){ btn.disabled = true; btn.textContent = 'Posting...'; }
    setTopLoading(true, 'Saving transaction...');

    var payload = {
        request: {
            TransactionDate: document.getElementById('<%= txtTxnDate.ClientID %>').value || '',
            Reference: document.getElementById('<%= txtTxnReference.ClientID %>').value || '',
            DebitAccount: document.getElementById('<%= ddlTxnDrAccount.ClientID %>').value || '',
            CreditAccount: document.getElementById('<%= ddlTxnCrAccount.ClientID %>').value || '',
            Amount: document.getElementById('<%= txtTxnAmount.ClientID %>').value || '',
            DebitParticulars: document.getElementById('<%= txtTxnDrParticulars.ClientID %>').value || '',
            CreditParticulars: document.getElementById('<%= txtTxnCrParticulars.ClientID %>').value || ''
        }
    };

    fetch('GeneralLedger.aspx/SaveTransactionAjax', {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify(payload)
    })
    .then(function(resp){ return resp.json(); })
    .then(function(data){
        var result = data && data.d ? data.d : data;
        if(!result){ throw new Error('Invalid server response'); }

        showClientMessage(result.Message || 'Operation completed.', !!result.Success);

        if(result.Success){
            return refreshLedgerListAjax().then(function(){
                var keep = document.getElementById('chkKeepAccounts');
                var keepAccounts = keep && keep.checked;

                document.getElementById('<%= txtTxnReference.ClientID %>').value = '';
                document.getElementById('<%= txtTxnAmount.ClientID %>').value = '';
                document.getElementById('<%= txtTxnDrParticulars.ClientID %>').value = '';
                document.getElementById('<%= txtTxnCrParticulars.ClientID %>').value = '';

                if(!keepAccounts){
                    var dr = document.getElementById('<%= ddlTxnDrAccount.ClientID %>');
                    var cr = document.getElementById('<%= ddlTxnCrAccount.ClientID %>');
                    var drSearch = document.getElementById('txtTxnDrAccountSearch');
                    var crSearch = document.getElementById('txtTxnCrAccountSearch');
                    if(dr){ dr.selectedIndex = 0; }
                    if(cr){ cr.selectedIndex = 0; }
                    if(drSearch){ drSearch.value = ''; }
                    if(crSearch){ crSearch.value = ''; }
                    closeTxnModal();
                } else {
                    var amt = document.getElementById('<%= txtTxnAmount.ClientID %>');
                    if(amt){ amt.focus(); }
                }
            });
        }

        return null;
    })
    .catch(function(err){
        showClientMessage('Error posting transaction: ' + (err && err.message ? err.message : 'Unknown error'), false);
    })
    .finally(function(){
        if(btn){ btn.disabled = false; btn.textContent = 'Post Transaction'; }
        setTopLoading(false);
    });
}

(function(){
    function resolveSearchToDropdown(searchId, dropdownClientId){
        var ddl = document.getElementById(dropdownClientId);
        var search = document.getElementById(searchId);
        if(!ddl || !search){ return false; }

        var raw = (search.value || '').trim();
        if(!raw){
            return !!(ddl.value && ddl.value.trim());
        }

        var q = raw.toLowerCase();
        var codeGuess = raw;
        if(raw.indexOf('—') !== -1){
            codeGuess = raw.split('—')[0].trim();
        } else if(raw.indexOf(' - ') !== -1){
            codeGuess = raw.split(' - ')[0].trim();
        }
        var codeGuessLower = codeGuess.toLowerCase();

        var match = null;

        for(var k=0;k<ddl.options.length;k++){
            var byCode = ddl.options[k];
            if((byCode.value || '').toLowerCase() === codeGuessLower){
                match = byCode;
                break;
            }
        }

        for(var i=0;i<ddl.options.length;i++){
            if(match){ break; }
            var opt = ddl.options[i];
            var text = (opt.text || '').toLowerCase();
            var val = (opt.value || '').toLowerCase();
            if(text === q || val === q){
                match = opt;
                break;
            }
        }

        if(!match){
            for(var j=0;j<ddl.options.length;j++){
                var opt2 = ddl.options[j];
                var text2 = (opt2.text || '').toLowerCase();
                var val2 = (opt2.value || '').toLowerCase();
                if(text2.indexOf(q) === 0 || val2.indexOf(q) === 0 || text2.indexOf(q) !== -1 || val2.indexOf(q) !== -1){
                    match = opt2;
                    break;
                }
            }
        }

        if(match){
            ddl.value = match.value;
            search.value = match.value + ' — ' + match.text;
            return true;
        }

        ddl.value = '';

        return false;
    }

    window.resolveSearchToDropdown = resolveSearchToDropdown;

    function bindSearchableDropdown(searchId, dropdownClientId, listId){
        var ddl = document.getElementById(dropdownClientId);
        var search = document.getElementById(searchId);
        if(!ddl || !search){ return; }

        var list = document.getElementById(listId);
        if(!list){
            list = document.createElement('datalist');
            list.id = listId;
            document.body.appendChild(list);
        }
        list.innerHTML = '';

        for(var i=0;i<ddl.options.length;i++){
            var opt = ddl.options[i];
            if(!opt.value){ continue; }
            var item = document.createElement('option');
            item.value = opt.value + ' — ' + opt.text;
            list.appendChild(item);
        }

        search.setAttribute('list', listId);

        search.addEventListener('blur', function(){ resolveSearchToDropdown(searchId, dropdownClientId); });
        search.addEventListener('keydown', function(e){
            if(e.key === 'Enter'){
                resolveSearchToDropdown(searchId, dropdownClientId);
            }
        });

        ddl.addEventListener('change', function(){
            var selected = ddl.options[ddl.selectedIndex];
            if(selected && selected.value){ search.value = selected.value + ' — ' + selected.text; }
        });

        var selectedInit = ddl.options[ddl.selectedIndex];
        if(selectedInit && selectedInit.value){
            search.value = selectedInit.value + ' — ' + selectedInit.text;
        }
    }

    bindSearchableDropdown('txtAccountSearch', '<%= ddlAccount.ClientID %>', 'dlAccountFilter');
    bindSearchableDropdown('txtTxnDrAccountSearch', '<%= ddlTxnDrAccount.ClientID %>', 'dlTxnDr');
    bindSearchableDropdown('txtTxnCrAccountSearch', '<%= ddlTxnCrAccount.ClientID %>', 'dlTxnCr');

    var descriptionSearch = document.getElementById('<%= txtDescriptionSearch.ClientID %>');
    if(descriptionSearch){
        descriptionSearch.addEventListener('keydown', function(e){
            if(e.key === 'Enter'){
                e.preventDefault();
                applyLedgerFilters();
            }
        });
    }

    var accountSearch = document.getElementById('txtAccountSearch');
    if(accountSearch){
        accountSearch.addEventListener('keydown', function(e){
            if(e.key === 'Enter'){
                e.preventDefault();
                applyLedgerFilters();
            }
        });
    }

    var advRequested = '<%= (Request.QueryString["adv"] ?? string.Empty).Replace("'", "\\'") %>';
    if(advRequested === '1'){
        toggleAdvancedFilters(true);
    }

    document.querySelectorAll('.ft-table thead a, .ft-pager a').forEach(function(a){
        a.addEventListener('click', function(){ setTopLoading(true, 'Loading...'); });
    });
})();
</script>
</asp:Content>
