<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="JournalEntries.aspx.cs" Inherits="COOPERP_NewScreens_JournalEntries" Title="Journal Entries - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .je-filter-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .je-filter-group { display: flex; flex-direction: column; gap: 4px; }
        .je-filter-group label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .je-filter-group input, .je-filter-group select { padding: 5px 8px; border: 1px solid #ccc; font-size: 12px; }
        .je-btn {
            padding: 6px 14px; font-size: 11px; font-weight: 600; border: 1px solid #1976d2;
            color: #fff; background: #1976d2; cursor: pointer;
        }
        .je-btn:hover { background: #1565c0; }
        .je-btn--outline { background: #fff; color: #1976d2; }
        .je-btn--outline:hover { background: #e3f2fd; }
        .je-btn--success { background: #388e3c; border-color: #388e3c; }
        .je-btn--success:hover { background: #2e7d32; }
        .je-btn--danger { background: #d32f2f; border-color: #d32f2f; }
        .je-btn--danger:hover { background: #c62828; }

        .je-section { background: #fff; border: 1px solid #e0e0e0; margin-bottom: 16px; }
        .je-section__header {
            padding: 10px 16px; border-bottom: 1px solid #e0e0e0;
            font-size: 13px; font-weight: 600; color: #333;
            display: flex; align-items: center; gap: 8px;
        }
        .je-section__header svg { width: 16px; height: 16px; color: #666; }
        .je-section__body { padding: 16px; }

        .je-create-form {
            background: #f8f9fa; border: 1px solid #e0e0e0; padding: 14px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .je-detail-form {
            background: #f8f9fa; padding: 12px 16px; border-bottom: 1px solid #e0e0e0;
            display: flex; align-items: flex-end; gap: 10px; flex-wrap: wrap;
        }

        .je-journal-info {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 10px 14px; margin-bottom: 12px;
            display: flex; gap: 20px; font-size: 12px; flex-wrap: wrap;
        }
        .je-journal-info__item { display: flex; gap: 4px; }
        .je-journal-info__item strong { color: #1565c0; }

        .je-balance-indicator { padding: 6px 12px; font-size: 12px; font-weight: 600; border-radius: 3px; }
        .je-balance--ok { background: #e8f5e9; color: #2e7d32; }
        .je-balance--off { background: #ffebee; color: #c62828; }

        .je-msg { padding: 8px 14px; margin-bottom: 10px; font-size: 12px; border-left: 3px solid; }
        .je-msg--success { border-color: #388e3c; background: #e8f5e9; color: #2e7d32; }
        .je-msg--error { border-color: #d32f2f; background: #ffebee; color: #c62828; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:Label ID="lblMessage" runat="server" />

    <!-- Filter & List Journals -->
    <div class="je-filter-bar">
        <div class="je-filter-group">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="je-filter-group">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <div class="je-filter-group">
            <label>Journal Type</label>
            <asp:DropDownList ID="ddlJournalType" runat="server">
                <asp:ListItem Text="All Types" Value="" />
                <asp:ListItem Text="General" Value="General" />
                <asp:ListItem Text="Receipt" Value="Receipt" />
                <asp:ListItem Text="Payment" Value="Payment" />
                <asp:ListItem Text="Contra" Value="Contra" />
            </asp:DropDownList>
        </div>
        <div class="je-filter-group">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Text="All" Value="" />
                <asp:ListItem Text="New (Unposted)" Value="New" />
                <asp:ListItem Text="Approved" Value="Approved" />
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="je-btn" OnClick="btnFilter_Click" />
        <asp:Button ID="btnCreateJournal" runat="server" Text="+ New Journal" CssClass="je-btn je-btn--success" OnClick="btnCreateJournal_Click" />
    </div>

    <!-- Create Journal Panel (visible when creating) -->
    <asp:Panel ID="pnlCreateJournal" runat="server" Visible="false">
        <div class="je-create-form">
            <div class="je-filter-group">
                <label>Journal Type</label>
                <asp:DropDownList ID="ddlNewJournalType" runat="server">
                    <asp:ListItem Text="General" Value="General" />
                    <asp:ListItem Text="Receipt" Value="Receipt" />
                    <asp:ListItem Text="Payment" Value="Payment" />
                    <asp:ListItem Text="Contra" Value="Contra" />
                </asp:DropDownList>
            </div>
            <div class="je-filter-group">
                <label>Reference No</label>
                <asp:TextBox ID="txtNewRefNo" runat="server" MaxLength="50" />
            </div>
            <div class="je-filter-group">
                <label>Memo / Particulars</label>
                <asp:TextBox ID="txtNewParticulars" runat="server" MaxLength="250" Width="250" />
            </div>
            <asp:Button ID="btnConfirmCreate" runat="server" Text="Create Journal" CssClass="je-btn je-btn--success" OnClick="btnConfirmCreate_Click" />
            <asp:Button ID="btnCancelCreate" runat="server" Text="Cancel" CssClass="je-btn je-btn--outline" OnClick="btnCancelCreate_Click" />
        </div>
    </asp:Panel>

    <!-- Active Journal Details (visible when a journal is selected) -->
    <asp:Panel ID="pnlJournalDetail" runat="server" Visible="false">
        <div class="je-journal-info">
            <div class="je-journal-info__item"><span>Journal #:</span> <strong><asp:Label ID="lblJournalNo" runat="server" /></strong></div>
            <div class="je-journal-info__item"><span>Type:</span> <strong><asp:Label ID="lblJournalType" runat="server" /></strong></div>
            <div class="je-journal-info__item"><span>Date:</span> <strong><asp:Label ID="lblJournalDate" runat="server" /></strong></div>
            <div class="je-journal-info__item"><span>Reference:</span> <strong><asp:Label ID="lblRefNo" runat="server" /></strong></div>
            <div class="je-journal-info__item"><span>Status:</span> <strong><asp:Label ID="lblPostStatus" runat="server" /></strong></div>
            <div class="je-journal-info__item">
                <asp:Label ID="lblBalanceIndicator" runat="server" />
            </div>
        </div>

        <!-- Add Detail Line -->
        <asp:Panel ID="pnlAddLine" runat="server">
            <div class="je-detail-form">
                <div class="je-filter-group">
                    <label>Account</label>
                    <dx:ASPxComboBox ID="cboDetailAccount" runat="server" Width="250" 
                        IncrementalFilteringMode="Contains" TextFormatString="{0} - {1}"
                        ValueField="AccountCode" ClientInstanceName="cboDetailAccount">
                        <Columns>
                            <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                            <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                        </Columns>
                    </dx:ASPxComboBox>
                </div>
                <div class="je-filter-group">
                    <label>DR / CR</label>
                    <asp:DropDownList ID="ddlDetailType" runat="server">
                        <asp:ListItem Text="DR" Value="DR" />
                        <asp:ListItem Text="CR" Value="CR" />
                    </asp:DropDownList>
                </div>
                <div class="je-filter-group">
                    <label>Amount</label>
                    <asp:TextBox ID="txtDetailAmount" runat="server" TextMode="Number" Width="120" />
                </div>
                <div class="je-filter-group">
                    <label>Details</label>
                    <asp:TextBox ID="txtDetailParticulars" runat="server" MaxLength="350" Width="200" />
                </div>
                <asp:Button ID="btnAddLine" runat="server" Text="Add Line" CssClass="je-btn" OnClick="btnAddLine_Click" />
            </div>
        </asp:Panel>

        <!-- Detail Lines Grid -->
        <dx:ASPxGridView ID="gvDetails" runat="server" Width="100%" KeyFieldName="TID"
            ClientInstanceName="gvDetails"
            OnRowDeleting="gvDetails_RowDeleting">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="TID" Caption="ID" Width="50" />
                <dx:GridViewDataTextColumn FieldName="accountcode" Caption="Account" Width="100" />
                <dx:GridViewDataTextColumn FieldName="account_type" Caption="Acc Type" Width="90" />
                <dx:GridViewDataTextColumn FieldName="transactionType" Caption="DR/CR" Width="50" />
                <dx:GridViewDataTextColumn FieldName="transaction_amount" Caption="Amount" Width="100">
                    <PropertiesTextEdit DisplayFormatString="N0" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="particulars" Caption="Particulars" />
                <dx:GridViewCommandColumn Width="60" Caption=" " ShowDeleteButton="true" />
            </Columns>
            <TotalSummary>
                <dx:ASPxSummaryItem FieldName="transaction_amount" SummaryType="Sum" DisplayFormat="N0" />
            </TotalSummary>
            <Settings ShowFooter="true" />
            <Styles>
                <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                <Row Font-Size="12px" />
                <AlternatingRow BackColor="#fafbfc" />
                <Footer BackColor="#f0f0f0" Font-Bold="true" Font-Size="11px" />
            </Styles>
        </dx:ASPxGridView>

        <!-- Action Buttons -->
        <div style="padding: 12px 16px; display: flex; gap: 8px;">
            <asp:Button ID="btnApproveJournal" runat="server" Text="Approve & Post" CssClass="je-btn je-btn--success" OnClick="btnApproveJournal_Click" />
            <asp:Button ID="btnCloseDetail" runat="server" Text="Close" CssClass="je-btn je-btn--outline" OnClick="btnCloseDetail_Click" />
        </div>
    </asp:Panel>

    <!-- Journals List -->
    <div class="je-section">
        <div class="je-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
            Journals
        </div>
        <dx:ASPxGridView ID="gvJournals" runat="server" Width="100%" KeyFieldName="JournalNo"
            ClientInstanceName="gvJournals"
            SettingsBehavior-AllowFocusedRow="true"
            OnFocusedRowChanged="gvJournals_FocusedRowChanged"
            SettingsPager-PageSize="20">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="JournalNo" Caption="J.No" Width="60" />
                <dx:GridViewDataTextColumn FieldName="journalType" Caption="Type" Width="80" />
                <dx:GridViewDataDateColumn FieldName="journalDate" Caption="Date" Width="90">
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
            <Styles>
                <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                <Row Font-Size="12px" />
                <AlternatingRow BackColor="#fafbfc" />
                <FocusedRow BackColor="#e3f2fd" />
            </Styles>
        </dx:ASPxGridView>
    </div>
</asp:Content>
