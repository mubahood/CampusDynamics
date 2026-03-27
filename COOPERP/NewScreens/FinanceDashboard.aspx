<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FinanceDashboard.aspx.cs" Inherits="COOPERP_NewScreens_FinanceDashboard" Title="Finance Dashboard - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        /* Finance Dashboard Styles */
        .fin-stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-bottom: 16px;
        }
        @media (max-width: 1100px) { .fin-stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 600px) { .fin-stats-grid { grid-template-columns: 1fr; } }

        .fin-stat-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .fin-stat-card__icon {
            width: 40px; height: 40px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; border-radius: 4px;
        }
        .fin-stat-card__icon svg { width: 20px; height: 20px; }
        .fin-stat-card__icon--blue { background: #e3f2fd; color: #1976d2; }
        .fin-stat-card__icon--green { background: #e8f5e9; color: #388e3c; }
        .fin-stat-card__icon--orange { background: #fff3e0; color: #f57c00; }
        .fin-stat-card__icon--red { background: #ffebee; color: #d32f2f; }
        .fin-stat-card__icon--purple { background: #f3e5f5; color: #7b1fa2; }
        .fin-stat-card__icon--teal { background: #e0f2f1; color: #00897b; }
        .fin-stat-card__content { flex: 1; min-width: 0; }
        .fin-stat-card__value { font-size: 20px; font-weight: 700; color: #333; line-height: 1.2; }
        .fin-stat-card__label { font-size: 10px; color: #888; text-transform: uppercase; letter-spacing: 0.3px; margin-top: 2px; }

        .fin-section { background: #fff; border: 1px solid #e0e0e0; margin-bottom: 16px; }
        .fin-section__header {
            padding: 12px 16px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 13px;
            font-weight: 600;
            color: #333;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .fin-section__header svg { width: 16px; height: 16px; color: #666; }
        .fin-section__body { padding: 16px; }

        .fin-period-badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 10px; border-radius: 3px; font-size: 11px; font-weight: 600;
        }
        .fin-period-badge--open { background: #e8f5e9; color: #2e7d32; }
        .fin-period-badge--closed { background: #ffebee; color: #c62828; }

        .fin-two-col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        @media (max-width: 900px) { .fin-two-col { grid-template-columns: 1fr; } }

        .fin-alert { padding: 10px 14px; border-left: 3px solid; margin-bottom: 8px; font-size: 12px; }
        .fin-alert--warning { border-color: #f57c00; background: #fff8e1; color: #e65100; }
        .fin-alert--info { border-color: #1976d2; background: #e3f2fd; color: #0d47a1; }
        .fin-alert--danger { border-color: #d32f2f; background: #ffebee; color: #b71c1c; }

        .fin-recent-table { width: 100%; border-collapse: collapse; font-size: 12px; }
        .fin-recent-table th { text-align: left; padding: 8px 10px; border-bottom: 2px solid #e0e0e0; color: #666; font-weight: 600; text-transform: uppercase; font-size: 10px; }
        .fin-recent-table td { padding: 7px 10px; border-bottom: 1px solid #f0f0f0; color: #333; }
        .fin-recent-table tr:hover { background: #fafafa; }
        .fin-status { padding: 2px 8px; border-radius: 3px; font-size: 10px; font-weight: 600; }
        .fin-status--new { background: #fff3e0; color: #e65100; }
        .fin-status--approved { background: #e8f5e9; color: #2e7d32; }
        .fin-status--void { background: #ffebee; color: #c62828; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <!-- KPI Stats Row -->
    <div class="fin-stats-grid">
        <div class="fin-stat-card">
            <div class="fin-stat-card__icon fin-stat-card__icon--blue">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
            </div>
            <div class="fin-stat-card__content">
                <div class="fin-stat-card__value"><asp:Label ID="lblTotalDR" runat="server" Text="0" /></div>
                <div class="fin-stat-card__label">Total Debits (Current Period)</div>
            </div>
        </div>
        <div class="fin-stat-card">
            <div class="fin-stat-card__icon fin-stat-card__icon--green">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
            </div>
            <div class="fin-stat-card__content">
                <div class="fin-stat-card__value"><asp:Label ID="lblTotalCR" runat="server" Text="0" /></div>
                <div class="fin-stat-card__label">Total Credits (Current Period)</div>
            </div>
        </div>
        <div class="fin-stat-card">
            <div class="fin-stat-card__icon fin-stat-card__icon--orange">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
            </div>
            <div class="fin-stat-card__content">
                <div class="fin-stat-card__value"><asp:Label ID="lblUnpostedJournals" runat="server" Text="0" /></div>
                <div class="fin-stat-card__label">Unposted Journals</div>
            </div>
        </div>
        <div class="fin-stat-card">
            <div class="fin-stat-card__icon fin-stat-card__icon--purple">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
            </div>
            <div class="fin-stat-card__content">
                <div class="fin-stat-card__value"><asp:Label ID="lblTotalAccounts" runat="server" Text="0" /></div>
                <div class="fin-stat-card__label">Chart of Accounts</div>
            </div>
        </div>
    </div>

    <!-- Alerts & Period Status -->
    <div class="fin-two-col">
        <div class="fin-section">
            <div class="fin-section__header">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                Financial Period Status
            </div>
            <div class="fin-section__body">
                <asp:Label ID="lblCurrentPeriod" runat="server" Text="" />
                <asp:Repeater ID="rptPeriods" runat="server">
                    <ItemTemplate>
                        <div style="display:flex;align-items:center;justify-content:space-between;padding:6px 0;border-bottom:1px solid #f0f0f0;">
                            <span style="font-size:12px;color:#333;"><%# Eval("finacial_Year") %></span>
                            <span style="font-size:11px;color:#666;"><%# Eval("start_date", "{0:dd MMM yyyy}") %> - <%# Eval("end_date", "{0:dd MMM yyyy}") %></span>
                            <span class='<%# Eval("status").ToString() == "Open" ? "fin-period-badge fin-period-badge--open" : "fin-period-badge fin-period-badge--closed" %>'><%# Eval("status") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div class="fin-section">
            <div class="fin-section__header">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                Alerts &amp; Notices
            </div>
            <div class="fin-section__body">
                <asp:Panel ID="pnlAlerts" runat="server">
                    <asp:Literal ID="litAlerts" runat="server" />
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- Recent Journals -->
    <div class="fin-section">
        <div class="fin-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
            Recent Journals (Last 20)
        </div>
        <div class="fin-section__body" style="padding:0;">
            <dx:ASPxGridView ID="gvRecentJournals" runat="server" Width="100%" KeyFieldName="JournalNo"
                ClientInstanceName="gvRecentJournals"
                Settings-ShowFilterRow="false"
                Settings-ShowGroupPanel="false"
                SettingsBehavior-AllowFocusedRow="true"
                SettingsPager-PageSize="20"
                CssClass="fin-grid">
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="JournalNo" Caption="J.No" Width="60" />
                    <dx:GridViewDataTextColumn FieldName="journalType" Caption="Type" Width="80" />
                    <dx:GridViewDataDateColumn FieldName="journalDate" Caption="Date" Width="90">
                        <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                    </dx:GridViewDataDateColumn>
                    <dx:GridViewDataTextColumn FieldName="RefNo" Caption="Reference" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="journalParticulars" Caption="Particulars" />
                    <dx:GridViewDataTextColumn FieldName="GL_VoucherNo" Caption="Voucher #" Width="80" />
                    <dx:GridViewDataTextColumn FieldName="Teller" Caption="Created By" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="PostStatus" Caption="Status" Width="80" />
                </Columns>
                <SettingsPager PageSize="20" />
                <Settings ShowFilterRow="false" />
                <Styles>
                    <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                    <Row Font-Size="12px" />
                    <AlternatingRow BackColor="#fafbfc" />
                    <FocusedRow BackColor="#e3f2fd" />
                </Styles>
            </dx:ASPxGridView>
        </div>
    </div>
</asp:Content>
