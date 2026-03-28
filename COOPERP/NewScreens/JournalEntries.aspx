<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="JournalEntries.aspx.cs" Inherits="COOPERP_NewScreens_JournalEntries" Title="Journal Entries - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        /* ── PAGE HEADER ───────────────────────────────── */
        .fm-page-header{background:#05275C;color:#fff;padding:18px 24px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
        .fm-page-header__left{display:flex;align-items:center;gap:12px;}
        .fm-page-header__icon{width:38px;height:38px;background:rgba(255,255,255,.12);display:flex;align-items:center;justify-content:center;}
        .fm-page-header__title{font-size:16px;font-weight:700;letter-spacing:.3px;}
        .fm-page-header__sub{font-size:11px;opacity:.72;margin-top:2px;}

        /* ── TAB NAVIGATION ────────────────────────────── */
        .fm-tabs{display:flex;background:#fff;border-bottom:2px solid #e0e5ed;padding:0 24px;gap:0;overflow-x:auto;}
        .fm-tab{padding:11px 18px;font-size:11px;font-weight:600;color:#555;text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;display:flex;align-items:center;gap:5px;white-space:nowrap;transition:color .15s,border-color .15s;}
        .fm-tab:hover{color:#05275C;border-bottom-color:#ccc;}
        .fm-tab--active{color:#05275C;border-bottom-color:#05275C;}

        /* ── CONTENT WRAPPER ───────────────────────────── */
        .je-content{padding:20px 24px;max-width:1320px;animation:jeIn .35s ease;}
        @keyframes jeIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}

        /* ── MESSAGE TOAST ─────────────────────────────── */
        .je-msg{padding:10px 14px;margin-bottom:14px;font-size:12px;display:flex;align-items:center;gap:8px;border-left:3px solid;}
        .je-msg--success{border-color:#16a34a;background:#f0fdf4;color:#166534;}
        .je-msg--error{border-color:#dc3545;background:#fef2f2;color:#991b1b;}

        /* ── FILTER BAR ────────────────────────────────── */
        .je-filter{background:#fff;border:1px solid #e0e5ed;padding:14px 18px;margin-bottom:18px;display:flex;align-items:flex-end;gap:14px;flex-wrap:wrap;}
        .je-fg{display:flex;flex-direction:column;gap:4px;}
        .je-fg label{font-size:10px;font-weight:600;color:#666;text-transform:uppercase;letter-spacing:.3px;}
        .je-fg input,.je-fg select{padding:6px 10px;border:1px solid #e0e5ed;border-radius:0;font-size:12px;color:#1a1a2e;font-family:inherit;background:#fff;outline:none;transition:border-color .15s;}
        .je-fg input:focus,.je-fg select:focus{border-color:#174DA4;}

        /* ── BUTTONS ───────────────────────────────────── */
        .je-btn{padding:7px 16px;font-size:11px;font-weight:600;border:none;border-radius:0;cursor:pointer;display:inline-flex;align-items:center;gap:5px;transition:background .15s,opacity .15s;font-family:inherit;}
        .je-btn--primary{background:#05275C;color:#fff;}
        .je-btn--primary:hover{background:#174DA4;}
        .je-btn--success{background:#16a34a;color:#fff;}
        .je-btn--success:hover{background:#15803d;}
        .je-btn--danger{background:#dc3545;color:#fff;}
        .je-btn--danger:hover{background:#b91c1c;}
        .je-btn--outline{background:#fff;color:#05275C;border:1px solid #e0e5ed;}
        .je-btn--outline:hover{background:#f5f7fa;}

        /* ── SECTION HEADER ────────────────────────────── */
        .je-section-hdr{display:flex;align-items:center;gap:8px;font-size:11px;font-weight:700;color:#05275C;text-transform:uppercase;letter-spacing:.5px;margin:20px 0 10px;padding:0;}
        .je-section-hdr__line{flex:1;height:1px;background:#e0e5ed;}

        /* ── CARD ──────────────────────────────────────── */
        .fs-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:16px;}
        .fs-card__header{padding:12px 16px;border-bottom:1px solid #e0e5ed;display:flex;align-items:center;justify-content:space-between;gap:8px;}
        .fs-card__title{font-size:12px;font-weight:700;color:#1a1a2e;display:flex;align-items:center;gap:6px;}
        .fs-card__meta{font-size:10px;color:#888;}

        /* ── CREATE JOURNAL PANEL ──────────────────────── */
        .je-create{background:#f5f7fa;border:1px solid #e0e5ed;padding:16px 18px;margin-bottom:16px;display:flex;align-items:flex-end;gap:14px;flex-wrap:wrap;}

        /* ── JOURNAL INFO BAR ──────────────────────────── */
        .je-info{background:linear-gradient(135deg,#f0f4ff 0%,#edf2ff 100%);border:1px solid #c7d2e8;padding:12px 16px;margin-bottom:14px;display:flex;gap:22px;flex-wrap:wrap;align-items:center;}
        .je-info__item{display:flex;align-items:center;gap:5px;font-size:11px;color:#555;}
        .je-info__item strong{color:#05275C;font-weight:700;}
        .je-info__divider{width:1px;height:20px;background:#c7d2e8;}

        /* ── BALANCE INDICATOR ──────────────────────────── */
        .je-bal{padding:5px 12px;font-size:11px;font-weight:700;display:inline-flex;align-items:center;gap:5px;}
        .je-bal--ok{background:#f0fdf4;color:#166534;border:1px solid #bbf7d0;}
        .je-bal--off{background:#fef2f2;color:#991b1b;border:1px solid #fecaca;}
        .je-bal--empty{font-size:11px;color:#999;font-weight:400;}

        /* ── ADD LINE FORM ─────────────────────────────── */
        .je-line-form{background:#f9fafb;padding:12px 16px;border-bottom:1px solid #e0e5ed;display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;}

        /* ── BADGE ─────────────────────────────────────── */
        .fs-badge{display:inline-block;padding:3px 8px;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px;}
        .fs-badge--green{background:#f0fdf4;color:#166534;border:1px solid #bbf7d0;}
        .fs-badge--amber{background:#fffbeb;color:#92400e;border:1px solid #fde68a;}
        .fs-badge--red{background:#fef2f2;color:#991b1b;border:1px solid #fecaca;}
        .fs-badge--blue{background:#eff6ff;color:#1e40af;border:1px solid #bfdbfe;}

        /* ── TABLE (shared) ────────────────────────────── */
        .fs-table{width:100%;border-collapse:collapse;}
        .fs-table th{background:#f5f7fa;color:#555;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.3px;padding:9px 12px;text-align:left;border-bottom:2px solid #e0e5ed;}
        .fs-table td{font-size:11px;color:#1a1a2e;padding:8px 12px;border-bottom:1px solid #f0f2f5;}
        .fs-table tbody tr:hover{background:#f8fafd;}
        .fs-table tfoot td{background:#f5f7fa;font-weight:700;border-top:2px solid #e0e5ed;}

        /* ── ACTION ROW ────────────────────────────────── */
        .je-actions{padding:14px 16px;display:flex;gap:8px;border-top:1px solid #e0e5ed;background:#f9fafb;}

        /* ── DX GRID OVERRIDES ─────────────────────────── */
        .dxgvControl_Glass{border:1px solid #e0e5ed !important;}
        .dxgvHeader_Glass td{background:#f5f7fa !important;color:#555 !important;font-size:10px !important;font-weight:600 !important;text-transform:uppercase !important;letter-spacing:.3px !important;padding:9px 12px !important;border-bottom:2px solid #e0e5ed !important;}
        .dxgvDataRow_Glass td{font-size:11px !important;color:#1a1a2e !important;padding:8px 12px !important;border-bottom:1px solid #f0f2f5 !important;}
        .dxgvDataRow_Glass:hover td{background:#f8fafd !important;}
        .dxgvFilterRow_Glass td{padding:4px 6px !important;background:#fff !important;}
        .dxgvFilterRow_Glass input{border:1px solid #e0e5ed !important;border-radius:0 !important;font-size:11px !important;padding:3px 6px !important;}
        .dxgvPagerBar_Glass{background:#f5f7fa !important;border-top:1px solid #e0e5ed !important;padding:6px 12px !important;}
        .dxgvFocusedRow_Glass td{background:#eef3ff !important;border-left:2px solid #05275C !important;}
        .dxgvFooter_Glass td{background:#f5f7fa !important;font-weight:700 !important;font-size:11px !important;border-top:2px solid #e0e5ed !important;}
        td.dxgvCommandColumn_Glass a{color:#dc3545 !important;font-size:10px !important;font-weight:600 !important;}

        /* ── RESPONSIVE ────────────────────────────────── */
        @media(max-width:768px){
            .fm-page-header{padding:14px 16px;}
            .fm-tabs{padding:0 12px;}
            .je-content{padding:14px 12px;}
            .je-filter,.je-create,.je-line-form,.je-info{flex-direction:column;align-items:stretch;}
            .je-info__divider{display:none;}
            .je-fg input,.je-fg select{width:100%;}
        }

        /* ── PRINT ─────────────────────────────────────── */
        @media print{.fm-page-header,.fm-tabs,.je-filter,.je-btn,.je-create,.je-line-form,.je-actions{display:none !important;}}
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- ======= PAGE HEADER =========================================== -->
<div class="fm-page-header">
    <div class="fm-page-header__left">
        <div class="fm-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
        </div>
        <div>
            <div class="fm-page-header__title">Journal Entries</div>
            <div class="fm-page-header__sub">Create, manage &amp; post journal entries to the general ledger</div>
        </div>
    </div>
</div>

<!-- ======= TAB NAVIGATION ======================================== -->
<div class="fm-tabs">
    <a class="fm-tab" href="FinanceDashboard.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
        Dashboard
    </a>
    <a class="fm-tab fm-tab--active" href="JournalEntries.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
        Journal Entries
    </a>
    <a class="fm-tab" href="PaymentVouchers.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
        Payment Vouchers
    </a>
</div>

<div class="je-content">
    <asp:Label ID="lblMessage" runat="server" />

    <!-- ======= FILTER BAR ======================================== -->
    <div class="je-filter">
        <div class="je-fg">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="je-fg">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <div class="je-fg">
            <label>Journal Type</label>
            <asp:DropDownList ID="ddlJournalType" runat="server">
                <asp:ListItem Text="All Types" Value="" />
                <asp:ListItem Text="General" Value="General" />
                <asp:ListItem Text="Receipt" Value="Receipt" />
                <asp:ListItem Text="Payment" Value="Payment" />
                <asp:ListItem Text="Contra" Value="Contra" />
            </asp:DropDownList>
        </div>
        <div class="je-fg">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Text="All" Value="" />
                <asp:ListItem Text="New (Unposted)" Value="New" />
                <asp:ListItem Text="Approved" Value="Approved" />
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="je-btn je-btn--primary" OnClick="btnFilter_Click" />
        <asp:Button ID="btnCreateJournal" runat="server" Text="+ New Journal" CssClass="je-btn je-btn--success" OnClick="btnCreateJournal_Click" />
    </div>

    <!-- ======= CREATE JOURNAL PANEL =============================== -->
    <asp:Panel ID="pnlCreateJournal" runat="server" Visible="false">
        <div class="je-create">
            <div class="je-fg">
                <label>Journal Type</label>
                <asp:DropDownList ID="ddlNewJournalType" runat="server">
                    <asp:ListItem Text="General" Value="General" />
                    <asp:ListItem Text="Receipt" Value="Receipt" />
                    <asp:ListItem Text="Payment" Value="Payment" />
                    <asp:ListItem Text="Contra" Value="Contra" />
                </asp:DropDownList>
            </div>
            <div class="je-fg">
                <label>Reference No</label>
                <asp:TextBox ID="txtNewRefNo" runat="server" MaxLength="50" />
            </div>
            <div class="je-fg" style="flex:1;min-width:200px;">
                <label>Memo / Particulars</label>
                <asp:TextBox ID="txtNewParticulars" runat="server" MaxLength="250" style="width:100%;" />
            </div>
            <asp:Button ID="btnConfirmCreate" runat="server" Text="Create Journal" CssClass="je-btn je-btn--success" OnClick="btnConfirmCreate_Click" />
            <asp:Button ID="btnCancelCreate" runat="server" Text="Cancel" CssClass="je-btn je-btn--outline" OnClick="btnCancelCreate_Click" />
        </div>
    </asp:Panel>

    <!-- ======= ACTIVE JOURNAL DETAIL ============================== -->
    <asp:Panel ID="pnlJournalDetail" runat="server" Visible="false">
        <div class="fs-card" style="margin-bottom:18px;">
            <div class="fs-card__header">
                <div class="fs-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    Journal Detail
                </div>
                <asp:Label ID="lblBalanceIndicator" runat="server" />
            </div>

            <!-- Info bar -->
            <div class="je-info">
                <div class="je-info__item"><span>Journal #:</span> <strong><asp:Label ID="lblJournalNo" runat="server" /></strong></div>
                <div class="je-info__divider"></div>
                <div class="je-info__item"><span>Type:</span> <strong><asp:Label ID="lblJournalType" runat="server" /></strong></div>
                <div class="je-info__divider"></div>
                <div class="je-info__item"><span>Date:</span> <strong><asp:Label ID="lblJournalDate" runat="server" /></strong></div>
                <div class="je-info__divider"></div>
                <div class="je-info__item"><span>Reference:</span> <strong><asp:Label ID="lblRefNo" runat="server" /></strong></div>
                <div class="je-info__divider"></div>
                <div class="je-info__item"><span>Status:</span> <asp:Label ID="lblPostStatus" runat="server" /></div>
            </div>

            <!-- Add Detail Line -->
            <asp:Panel ID="pnlAddLine" runat="server">
                <div class="je-line-form">
                    <div class="je-fg">
                        <label>Account</label>
                        <dx:ASPxComboBox ID="cboDetailAccount" runat="server" Width="260"
                            IncrementalFilteringMode="Contains" TextFormatString="{0} - {1}"
                            ValueField="AccountCode" ClientInstanceName="cboDetailAccount">
                            <Columns>
                                <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                                <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                            </Columns>
                            <Border BorderStyle="Solid" BorderWidth="1" BorderColor="#e0e5ed" />
                        </dx:ASPxComboBox>
                    </div>
                    <div class="je-fg">
                        <label>DR / CR</label>
                        <asp:DropDownList ID="ddlDetailType" runat="server">
                            <asp:ListItem Text="DR" Value="DR" />
                            <asp:ListItem Text="CR" Value="CR" />
                        </asp:DropDownList>
                    </div>
                    <div class="je-fg">
                        <label>Amount</label>
                        <asp:TextBox ID="txtDetailAmount" runat="server" TextMode="Number" Width="130" />
                    </div>
                    <div class="je-fg" style="flex:1;min-width:160px;">
                        <label>Details</label>
                        <asp:TextBox ID="txtDetailParticulars" runat="server" MaxLength="350" style="width:100%;" />
                    </div>
                    <asp:Button ID="btnAddLine" runat="server" Text="+ Add Line" CssClass="je-btn je-btn--primary" OnClick="btnAddLine_Click" />
                </div>
            </asp:Panel>

            <!-- Detail Lines Grid -->
            <div style="overflow-x:auto;">
                <dx:ASPxGridView ID="gvDetails" runat="server" Width="100%" KeyFieldName="TID"
                    ClientInstanceName="gvDetails"
                    OnRowDeleting="gvDetails_RowDeleting"
                    EnableCallBacks="true">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="TID" Caption="ID" Width="50">
                            <CellStyle ForeColor="#999" Font-Size="10px" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="accountcode" Caption="Account" Width="100">
                            <CellStyle ForeColor="#05275C" Font-Bold="true" Font-Size="11px" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="account_type" Caption="Acc Type" Width="90" />
                        <dx:GridViewDataTextColumn FieldName="transactionType" Caption="DR/CR" Width="55" />
                        <dx:GridViewDataTextColumn FieldName="transaction_amount" Caption="Amount" Width="110">
                            <PropertiesTextEdit DisplayFormatString="N0" />
                            <CellStyle HorizontalAlign="Right" Font-Size="11px" />
                            <HeaderStyle HorizontalAlign="Right" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="particulars" Caption="Particulars" />
                        <dx:GridViewCommandColumn Width="55" Caption=" " ShowDeleteButton="true">
                            <HeaderStyle HorizontalAlign="Center" />
                            <CellStyle HorizontalAlign="Center" />
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <TotalSummary>
                        <dx:ASPxSummaryItem FieldName="transaction_amount" SummaryType="Sum" DisplayFormat="Total: {0:N0}" />
                    </TotalSummary>
                    <Settings ShowFooter="true" ShowFilterRow="false" />
                    <SettingsBehavior AllowGroup="false" />
                </dx:ASPxGridView>
            </div>

            <!-- Action Buttons -->
            <div class="je-actions">
                <asp:Button ID="btnApproveJournal" runat="server" Text="Approve & Post" CssClass="je-btn je-btn--success" OnClick="btnApproveJournal_Click" />
                <asp:Button ID="btnCloseDetail" runat="server" Text="Close" CssClass="je-btn je-btn--outline" OnClick="btnCloseDetail_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- ======= JOURNALS LIST ====================================== -->
    <div class="je-section-hdr">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
        Journals List
        <span class="je-section-hdr__line"></span>
    </div>
    <div class="fs-card">
        <div style="overflow-x:auto;">
            <dx:ASPxGridView ID="gvJournals" runat="server" Width="100%" KeyFieldName="JournalNo"
                ClientInstanceName="gvJournals"
                SettingsBehavior-AllowFocusedRow="true"
                OnFocusedRowChanged="gvJournals_FocusedRowChanged"
                SettingsPager-PageSize="20"
                EnableCallBacks="true">
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="JournalNo" Caption="J.No" Width="60">
                        <CellStyle ForeColor="#05275C" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="journalType" Caption="Type" Width="80" />
                    <dx:GridViewDataDateColumn FieldName="journalDate" Caption="Date" Width="95">
                        <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                    </dx:GridViewDataDateColumn>
                    <dx:GridViewDataTextColumn FieldName="RefNo" Caption="Reference" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="journalParticulars" Caption="Particulars" />
                    <dx:GridViewDataTextColumn FieldName="GL_VoucherNo" Caption="Voucher" Width="80" />
                    <dx:GridViewDataTextColumn FieldName="Teller" Caption="Created By" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="PostStatus" Caption="Status" Width="80" />
                </Columns>
                <SettingsPager PageSize="20" />
                <Settings ShowFilterRow="true" />
                <SettingsBehavior AllowGroup="false" />
            </dx:ASPxGridView>
        </div>
    </div>
</div>
</asp:Content>
