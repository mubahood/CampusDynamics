<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Homescreen.ascx.cs" Inherits="UserControls_FrontOffice_Homescreen" %>
<style type="text/css">
    .acc-dashboard { padding: 14px 10px; font-family: 'Segoe UI', Arial, sans-serif; font-size: 13px; color: #1a1a2e; }
    .acc-dashboard h2 { margin: 0 0 14px 0; font-size: 16px; color: #05275C; border-bottom: 2px solid #05275C; padding-bottom: 6px; }

    /* KPI cards */
    .acc-kpi-row { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 18px; }
    .acc-kpi-card { flex: 1 1 160px; background: #fff; border: 1px solid #dee2e8; border-radius: 6px; padding: 14px 16px; min-width: 140px; }
    .acc-kpi-card .kpi-label { font-size: 11px; color: #666; text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 6px; }
    .acc-kpi-card .kpi-value { font-size: 22px; font-weight: 700; color: #05275C; }
    .acc-kpi-card .kpi-sub   { font-size: 11px; color: #888; margin-top: 4px; }
    .acc-kpi-card.kpi-warning { border-left: 4px solid #e6a817; }
    .acc-kpi-card.kpi-danger  { border-left: 4px solid #dc3545; }
    .acc-kpi-card.kpi-success { border-left: 4px solid #28a745; }
    .acc-kpi-card.kpi-info    { border-left: 4px solid #007bff; }

    /* Two-column lower section */
    .acc-lower { display: flex; gap: 14px; flex-wrap: wrap; }
    .acc-panel  { flex: 1 1 300px; background: #fff; border: 1px solid #dee2e8; border-radius: 6px; overflow: hidden; }
    .acc-panel-hdr { background: #05275C; color: #fff; padding: 8px 14px; font-size: 12px; font-weight: 600; }
    .acc-panel-body { padding: 10px 14px; }

    /* Recent transactions mini-table */
    .acc-mini-table { width: 100%; border-collapse: collapse; font-size: 12px; }
    .acc-mini-table th { background: #f0f4f8; color: #05275C; padding: 5px 8px; text-align: left; font-size: 11px; text-transform: uppercase; }
    .acc-mini-table td { padding: 5px 8px; border-bottom: 1px solid #f0f0f0; }
    .acc-mini-table tr:last-child td { border-bottom: none; }
    .tag-dr { background: #fff3cd; color: #856404; border-radius: 3px; padding: 1px 6px; font-size: 10px; font-weight: 600; }
    .tag-cr { background: #d1ecf1; color: #0c5460; border-radius: 3px; padding: 1px 6px; font-size: 10px; font-weight: 600; }
    .tag-posted  { background: #d4edda; color: #155724; border-radius: 3px; padding: 1px 6px; font-size: 10px; }
    .tag-pending { background: #fff3cd; color: #856404; border-radius: 3px; padding: 1px 6px; font-size: 10px; }

    /* Alert items */
    .acc-alert-item { display: flex; justify-content: space-between; align-items: center; padding: 7px 0; border-bottom: 1px solid #f0f0f0; font-size: 12px; }
    .acc-alert-item:last-child { border-bottom: none; }
    .acc-badge { background: #dc3545; color: #fff; border-radius: 10px; padding: 1px 8px; font-size: 11px; font-weight: 700; }
    .acc-badge.badge-warn { background: #e6a817; }
    .acc-badge.badge-ok   { background: #28a745; }
    .acc-empty { color: #999; font-size: 12px; padding: 10px 0; text-align: center; }

    .acc-period-bar { background: #e8f4fd; border: 1px solid #bee5f5; border-radius: 4px; padding: 6px 12px; margin-bottom: 14px; font-size: 12px; color: #05275C; }
    .acc-period-bar span { font-weight: 600; }
</style>

<div class="acc-dashboard">
    <h2>Accounting Centre — Financial Dashboard</h2>

    <!-- Financial period bar -->
    <div class="acc-period-bar" id="divPeriodBar" runat="server"></div>

    <!-- KPI Cards row -->
    <div class="acc-kpi-row">
        <div class="acc-kpi-card kpi-warning">
            <div class="kpi-label">Pending Journals</div>
            <div class="kpi-value"><asp:Literal ID="litPending" runat="server" /></div>
            <div class="kpi-sub">Awaiting approval</div>
        </div>
        <div class="acc-kpi-card kpi-danger">
            <div class="kpi-label">Unbalanced Vouchers</div>
            <div class="kpi-value"><asp:Literal ID="litUnbalanced" runat="server" /></div>
            <div class="kpi-sub">DR ≠ CR (repair needed)</div>
        </div>
        <div class="acc-kpi-card kpi-info">
            <div class="kpi-label">Total DR (Posted)</div>
            <div class="kpi-value" style="font-size:16px"><asp:Literal ID="litTotalDR" runat="server" /></div>
            <div class="kpi-sub">Current financial year</div>
        </div>
        <div class="acc-kpi-card kpi-success">
            <div class="kpi-label">Total CR (Posted)</div>
            <div class="kpi-value" style="font-size:16px"><asp:Literal ID="litTotalCR" runat="server" /></div>
            <div class="kpi-sub">Current financial year</div>
        </div>
    </div>

    <!-- Lower panels -->
    <div class="acc-lower">

        <!-- Recent transactions -->
        <div class="acc-panel" style="flex: 2 1 400px">
            <div class="acc-panel-hdr">Recent Transactions (Last 15)</div>
            <div class="acc-panel-body" style="padding: 0">
                <asp:Literal ID="litRecentTxn" runat="server" />
            </div>
        </div>

        <!-- Alerts panel -->
        <div class="acc-panel" style="flex: 1 1 220px">
            <div class="acc-panel-hdr">System Alerts</div>
            <div class="acc-panel-body">
                <asp:Literal ID="litAlerts" runat="server" />
            </div>
        </div>

    </div>
</div>
