<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentLedgerExport.aspx.cs" Inherits="API_StudentLedgerExport" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Student Ledger – <%= Server.HtmlEncode(StudentName) %></title>
    <style type="text/css">
        /* ===== RESET / BASE ===== */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 11px;
            color: #1a1a2e;
            background: #fff;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }
        .page-wrap {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px 30px;
        }

        /* ===== HEADER ===== */
        .hdr {
            margin-bottom: 18px;
            border: none;
            padding: 10px 12px 14px;
            border-bottom: 1px solid #d9e1ef;
        }
        .hdr-top {
            display: grid;
            grid-template-columns: 90px 1fr 90px;
            align-items: center;
            gap: 12px;
        }
        .hdr-logo-box,
        .hdr-photo-box {
            width: 90px;
            height: 90px;
            border: none;
            background: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        .hdr-logo-box img { max-width: 82px; max-height: 82px; object-fit: contain; }
        .hdr-photo-box img { width: 100%; height: 100%; object-fit: cover; }
        .hdr-photo-placeholder {
            width: 100%; height: 100%;
            display: flex; align-items: center; justify-content: center;
            text-align: center; font-size: 10px; color: #6b7280; padding: 6px;
            background: #f8fafc;
        }
        .hdr-main { text-align: center; }
        .hdr h1 { font-size: 18px; color: #05275C; letter-spacing: .9px; margin: 1px 0; }
        .hdr h2 { font-size: 12px; color: #444; font-weight: 700; margin: 1px 0 0; letter-spacing: .5px; }
        .hdr h3 { font-size: 11px; color: #4b5563; font-weight: 500; margin: 4px 0 0; }

        /* ===== STUDENT INFO BLOCK ===== */
        .info-block { margin-bottom: 14px; }
        .info-block h3 { font-size: 15px; color: #05275C; margin-bottom: 6px; text-transform: uppercase; letter-spacing: .5px; }
        .info-grid { display: table; width: 100%; }
        .info-row  { display: table-row; }
        .info-lbl  { display: table-cell; width: 180px; font-weight: 600; color: #555; padding: 2px 8px 2px 0; }
        .info-val  { display: table-cell; color: #1a1a2e; padding: 2px 0; }

        /* ===== SUMMARY CARDS ===== */
        .summary { display: flex; gap: 12px; margin-bottom: 16px; }
        .summary-card { flex: 1; background: #f8f9fc; border: 1px solid #dde1ea; border-radius: 4px; padding: 10px 14px; text-align: center; }
        .summary-card .lbl { font-size: 10px; color: #777; text-transform: uppercase; letter-spacing: .5px; }
        .summary-card .val { font-size: 16px; font-weight: 700; color: #05275C; margin-top: 2px; }
        .summary-card .val.cr { color: #0a8754; }
        .summary-card .val.dr { color: #c62828; }

        /* ===== LEDGER TABLE ===== */
        .ledger-title { font-size: 13px; font-weight: 700; color: #05275C; text-transform: uppercase; margin-bottom: 6px; letter-spacing: .5px; }
        table.ledger { width: 100%; border-collapse: collapse; margin-bottom: 4px; }
        table.ledger thead th {
            background: #05275C; color: #fff; font-weight: 600; font-size: 10px;
            text-transform: uppercase; letter-spacing: .4px;
            padding: 6px 8px; text-align: left; border: 1px solid #05275C;
        }
        table.ledger thead th.r { text-align: right; }
        table.ledger tbody td {
            padding: 5px 8px; border: 1px solid #dde1ea; font-size: 11px; vertical-align: top;
        }
        table.ledger tbody td.r { text-align: right; font-family: 'Consolas', 'Courier New', monospace; }
        table.ledger tbody td.particulars { max-width: 260px; word-wrap: break-word; }
        table.ledger tbody tr:nth-child(even) { background: #f8f9fc; }
        table.ledger tbody tr.opening { background: #eef2fa; font-weight: 600; }
        table.ledger tbody tr.closing { background: #05275C; color: #fff; font-weight: 700; }
        table.ledger tbody tr.closing td { border-color: #05275C; }
        .bal-cr { color: #0a8754; font-weight: 700; }
        .bal-dr { color: #c62828; font-weight: 700; }

        /* ===== FOOTER ===== */
        .footer { margin-top: 16px; padding-top: 10px; border-top: 1px solid #ccc; display: flex; justify-content: space-between; font-size: 10px; color: #888; }
        .footer .left  { text-align: left; }
        .footer .right { text-align: right; }

        /* ===== PRINT ===== */
        .no-print { margin-bottom: 16px; text-align: center; }
        .no-print button {
            background: #05275C; color: #fff; border: none; padding: 8px 28px;
            font-size: 13px; border-radius: 4px; cursor: pointer; margin: 0 6px;
        }
        .no-print button:hover { background: #08348a; }
        .no-print button.sec { background: #fff; color: #05275C; border: 1px solid #05275C; }
        .no-print button.sec:hover { background: #f0f3fa; }
        @media print {
            .no-print { display: none !important; }
            body { font-size: 10px; }
            .page-wrap { padding: 10px 15px; max-width: 100%; }
            .summary-card .val { font-size: 13px; }
            table.ledger thead th { font-size: 9px; padding: 4px 6px; }
            table.ledger tbody td { font-size: 10px; padding: 3px 6px; }
        }

        /* ERROR */
        .error-box { background: #fdecea; border: 1px solid #f5c6cb; color: #721c24; padding: 20px; border-radius: 4px; text-align: center; margin-top: 40px; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="page-wrap">

    <!-- PRINT TOOLBAR -->
    <div class="no-print">
        <button type="button" onclick="window.print();">&#128438; Print Statement</button>
        <button type="button" class="sec" onclick="window.close();">Close</button>
    </div>

    <% if (!string.IsNullOrEmpty(ErrorMessage)) { %>
    <div class="error-box"><%= Server.HtmlEncode(ErrorMessage) %></div>
    <% } else { %>

    <!-- HEADER -->
    <div class="hdr">
        <div class="hdr-top">
            <div class="hdr-logo-box">
                <img src="<%= ResolveUrl(UniversityLogoUrl) %>" alt="Muteesa I Royal University" />
            </div>
            <div class="hdr-main">
                <h1><%= Server.HtmlEncode(UniversityName.ToUpperInvariant()) %></h1>
                <h2>STUDENT FEES PAYMENT LEDGER</h2>
                <h3>Official Statement</h3>
            </div>
            <div class="hdr-photo-box">
                <% if (HasStudentPhoto) { %>
                    <img src="<%= System.Web.HttpUtility.HtmlAttributeEncode(StudentPhotoUrl) %>" alt="Student Photo" />
                <% } else { %>
                    <div class="hdr-photo-placeholder">Student Photo</div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- STUDENT INFO -->
    <div class="info-block">
        <h3>Student Ledger</h3>
        <div class="info-grid">
            <div class="info-row"><span class="info-lbl">Student Name</span><span class="info-val"><%= Server.HtmlEncode(StudentName) %> [<%= Server.HtmlEncode(RegNo) %>]</span></div>
            <div class="info-row"><span class="info-lbl">Programme</span><span class="info-val"><%= Server.HtmlEncode(Programme) %> [<%= Server.HtmlEncode(SessionType) %>]</span></div>
            <div class="info-row"><span class="info-lbl">Current Period</span><span class="info-val">Year <%= StudyYear %>, Semester <%= Semester %>, Academic Year <%= Server.HtmlEncode(AcadYear) %></span></div>
            <div class="info-row"><span class="info-lbl">Ledger Period</span><span class="info-val"><%= LedgerStart.ToString("dd-MM-yyyy") %> TO <%= LedgerEnd.ToString("dd-MM-yyyy") %></span></div>
            <div class="info-row"><span class="info-lbl">Print Date</span><span class="info-val"><%= DateTime.Now.ToString("dd/MM/yyyy  HH:mm") %></span></div>
        </div>
    </div>

    <!-- SUMMARY CARDS -->
    <div class="summary">
        <div class="summary-card">
            <div class="lbl">Total Invoiced</div>
            <div class="val">UGX <%= TotalBilled.ToString("N0") %></div>
        </div>
        <div class="summary-card">
            <div class="lbl">Total Paid / Credits</div>
            <div class="val cr">UGX <%= TotalPaid.ToString("N0") %></div>
        </div>
        <div class="summary-card">
            <div class="lbl">Balance</div>
            <div class="val <%= ClosingBalance >= 0 ? "dr" : "cr" %>">UGX <%= FormatBalance(ClosingBalance) %></div>
        </div>
        <div class="summary-card">
            <div class="lbl">Transactions</div>
            <div class="val"><%= TxCount %></div>
        </div>
    </div>

    <!-- LEDGER TABLE -->
    <div class="ledger-title">Transaction Ledger</div>
    <table class="ledger">
        <thead>
            <tr>
                <th style="width:75px;">Date</th>
                <th style="width:80px;">Created By</th>
                <th>Particulars</th>
                <th style="width:70px;">Voucher No</th>
                <th class="r" style="width:95px;">DR (UGX)</th>
                <th class="r" style="width:95px;">CR (UGX)</th>
                <th class="r" style="width:105px;">Balance (UGX)</th>
            </tr>
        </thead>
        <tbody>
            <!-- Opening balance row -->
            <tr class="opening">
                <td><%= LedgerStart.ToString("dd/MM/yyyy") %></td>
                <td></td>
                <td colspan="2"><strong>Opening Balance</strong></td>
                <td class="r"></td>
                <td class="r"></td>
                <td class="r"><%= FormatBalanceHtml(OpeningBalance) %></td>
            </tr>
            <asp:Literal ID="litRows" runat="server" />
            <!-- Closing balance row -->
            <tr class="closing">
                <td colspan="4" style="text-align:right; padding-right:12px;">CLOSING BALANCE</td>
                <td class="r"><%= TotalBilled.ToString("N0") %></td>
                <td class="r"><%= TotalPaid.ToString("N0") %></td>
                <td class="r"><%= FormatBalance(ClosingBalance) %></td>
            </tr>
        </tbody>
    </table>

    <!-- FOOTER -->
    <div class="footer">
        <div class="left">Fees Payment Ledger for :: <%= Server.HtmlEncode(StudentName) %> [<%= Server.HtmlEncode(RegNo) %>]</div>
        <div class="right">Generated on <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %> · &copy; <%= DateTime.Now.Year %> <%= Server.HtmlEncode(UniversityName) %></div>
    </div>

    <% } %>
</div>
</form>
</body>
</html>
