<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentReceipts.aspx.cs" Inherits="COOPERP_NewScreens_StudentReceipts" Title="Student Receipts - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .sr-filter-bar { background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px; display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap; }
        .sr-fg { display: flex; flex-direction: column; gap: 4px; }
        .sr-fg label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .sr-fg input, .sr-fg select { padding: 5px 8px; border: 1px solid #ccc; font-size: 12px; }
        .sr-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: 1px solid #1976d2; color: #fff; background: #1976d2; cursor: pointer; }
        .sr-btn:hover { background: #1565c0; }
        .sr-btn--success { background: #388e3c; border-color: #388e3c; }
        .sr-btn--success:hover { background: #2e7d32; }
        .sr-btn--outline { background: #fff; color: #1976d2; }
        .sr-btn--outline:hover { background: #e3f2fd; }
        .sr-section { background: #fff; border: 1px solid #e0e0e0; margin-bottom: 16px; }
        .sr-section__header { padding: 10px 16px; border-bottom: 1px solid #e0e0e0; font-size: 13px; font-weight: 600; color: #333; display: flex; align-items: center; gap: 8px; }
        .sr-section__header svg { width: 16px; height: 16px; color: #666; }
        .sr-create-form { background: #f8f9fa; border: 1px solid #e0e0e0; padding: 14px 16px; margin-bottom: 16px; }
        .sr-create-form__row { display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap; margin-bottom: 10px; }
        .sr-msg { padding: 8px 14px; margin-bottom: 10px; font-size: 12px; border-left: 3px solid; }
        .sr-msg--success { border-color: #388e3c; background: #e8f5e9; color: #2e7d32; }
        .sr-msg--error { border-color: #d32f2f; background: #ffebee; color: #c62828; }
        .sr-detail-info { background: #e3f2fd; border: 1px solid #90caf9; padding: 10px 14px; margin-bottom: 12px; display: flex; gap: 20px; font-size: 12px; flex-wrap: wrap; }
        .sr-detail-info strong { color: #1565c0; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:Label ID="lblMessage" runat="server" />

    <!-- Filter -->
    <div class="sr-filter-bar">
        <div class="sr-fg">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="sr-fg">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <div class="sr-fg">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Text="All" Value="" />
                <asp:ListItem Text="New" Value="New" />
                <asp:ListItem Text="Approved" Value="Approved" />
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="sr-btn" OnClick="btnFilter_Click" />
        <asp:Button ID="btnNewReceipt" runat="server" Text="+ New Receipt" CssClass="sr-btn sr-btn--success" OnClick="btnNewReceipt_Click" />
    </div>

    <!-- Create Receipt Form -->
    <asp:Panel ID="pnlCreate" runat="server" Visible="false">
        <div class="sr-create-form">
            <div style="font-size:13px;font-weight:600;color:#333;margin-bottom:10px;">Create Student Receipt</div>
            <div class="sr-create-form__row">
                <div class="sr-fg">
                    <label>Student Admission No</label>
                    <asp:TextBox ID="txtAdmissionNo" runat="server" MaxLength="45" Width="150" />
                </div>
                <div class="sr-fg">
                    <label>Academic Year</label>
                    <asp:TextBox ID="txtAcadYear" runat="server" MaxLength="20" Width="100" />
                </div>
                <div class="sr-fg">
                    <label>Semester</label>
                    <asp:DropDownList ID="ddlSemester" runat="server">
                        <asp:ListItem Text="1" Value="1" />
                        <asp:ListItem Text="2" Value="2" />
                        <asp:ListItem Text="3" Value="3" />
                    </asp:DropDownList>
                </div>
                <div class="sr-fg">
                    <label>Debit Account (Bank/Cash)</label>
                    <dx:ASPxComboBox ID="cboDRAccount" runat="server" Width="280" IncrementalFilteringMode="Contains"
                        TextFormatString="{0} - {1}" ValueField="AccountCode" ClientInstanceName="cboDRReceipt">
                        <Columns>
                            <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                            <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                        </Columns>
                    </dx:ASPxComboBox>
                </div>
            </div>
            <div class="sr-create-form__row">
                <div class="sr-fg">
                    <label>Credit Account (Revenue/Fees)</label>
                    <dx:ASPxComboBox ID="cboCRAccount" runat="server" Width="280" IncrementalFilteringMode="Contains"
                        TextFormatString="{0} - {1}" ValueField="AccountCode" ClientInstanceName="cboCRReceipt">
                        <Columns>
                            <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                            <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                        </Columns>
                    </dx:ASPxComboBox>
                </div>
                <div class="sr-fg">
                    <label>Amount</label>
                    <asp:TextBox ID="txtAmount" runat="server" TextMode="Number" Width="150" />
                </div>
                <div class="sr-fg">
                    <label>Particulars</label>
                    <asp:TextBox ID="txtParticulars" runat="server" MaxLength="350" Width="250" />
                </div>
            </div>
            <div style="margin-top:8px;display:flex;gap:8px;">
                <asp:Button ID="btnConfirmCreate" runat="server" Text="Create Receipt" CssClass="sr-btn sr-btn--success" OnClick="btnConfirmCreate_Click" />
                <asp:Button ID="btnCancelCreate" runat="server" Text="Cancel" CssClass="sr-btn sr-btn--outline" OnClick="btnCancelCreate_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- Receipt Detail -->
    <asp:Panel ID="pnlDetail" runat="server" Visible="false">
        <div class="sr-detail-info">
            <span>Receipt #: <strong><asp:Label ID="lblReceiptNo" runat="server" /></strong></span>
            <span>Status: <strong><asp:Label ID="lblReceiptStatus" runat="server" /></strong></span>
        </div>
        <div class="sr-section">
            <dx:ASPxGridView ID="gvReceiptTrans" runat="server" Width="100%" KeyFieldName="TID" ClientInstanceName="gvReceiptTrans">
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="accountcode" Caption="Account" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="account_type" Caption="Type" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="transactionType" Caption="DR/CR" Width="50" />
                    <dx:GridViewDataTextColumn FieldName="transaction_amount" Caption="Amount" Width="120">
                        <PropertiesTextEdit DisplayFormatString="N0" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="particulars" Caption="Particulars" />
                </Columns>
                <Styles>
                    <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                    <Row Font-Size="12px" />
                </Styles>
            </dx:ASPxGridView>
            <div style="padding:10px 16px;display:flex;gap:8px;">
                <asp:Button ID="btnApproveReceipt" runat="server" Text="Approve Receipt" CssClass="sr-btn sr-btn--success" OnClick="btnApproveReceipt_Click" />
                <asp:Button ID="btnCloseDetail" runat="server" Text="Close" CssClass="sr-btn sr-btn--outline" OnClick="btnCloseDetail_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- Receipts List -->
    <div class="sr-section">
        <div class="sr-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1z"></path><line x1="8" y1="6" x2="16" y2="6"></line><line x1="8" y1="10" x2="16" y2="10"></line><line x1="8" y1="14" x2="12" y2="14"></line></svg>
            Student Receipts
        </div>
        <dx:ASPxGridView ID="gvReceipts" runat="server" Width="100%" KeyFieldName="VoucherNo"
            ClientInstanceName="gvReceipts"
            SettingsBehavior-AllowFocusedRow="true"
            OnFocusedRowChanged="gvReceipts_FocusedRowChanged"
            SettingsPager-PageSize="20">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="VoucherNo" Caption="Receipt#" Width="70" />
                <dx:GridViewDataDateColumn FieldName="voucherDate" Caption="Date" Width="90">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="Teller" Caption="Created By" Width="100" />
                <dx:GridViewDataTextColumn FieldName="PostStatus" Caption="Status" Width="80" />
            </Columns>
            <Settings ShowFilterRow="true" />
            <SettingsPager PageSize="20" />
            <Styles>
                <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                <Row Font-Size="12px" />
                <AlternatingRow BackColor="#fafbfc" />
                <FocusedRow BackColor="#e3f2fd" />
            </Styles>
        </dx:ASPxGridView>
    </div>
</asp:Content>
