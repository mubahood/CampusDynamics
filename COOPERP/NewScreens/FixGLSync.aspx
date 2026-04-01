<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FixGLSync.aspx.cs" Inherits="FixGLSync" %>
<!DOCTYPE html>
<html>
<head>
<title>GL Sync Fix — Admin Only</title>
<style>
body { font-family: monospace; background: #111; color: #eee; padding: 24px; }
h2 { color: #f87171; }
h3 { color: #60a5fa; margin-top: 28px; border-bottom: 1px solid #334; padding-bottom: 6px; }
table { border-collapse: collapse; margin-top: 8px; font-size: 12px; }
th { background: #1e3a5f; color: #93c5fd; padding: 6px 12px; text-align: left; }
td { padding: 5px 12px; border-bottom: 1px solid #222; }
tr:hover td { background: #1a1a2e; }
.ok  { color: #4ade80; font-weight: bold; }
.err { color: #f87171; font-weight: bold; }
.warn { color: #fbbf24; font-weight: bold; }
.badge { display:inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; }
.badge-dr { background: #7f1d1d; color: #fca5a5; }
.badge-cr { background: #14532d; color: #86efac; }
pre { background: #1e1e1e; padding: 12px; border-radius: 6px; color: #a3e635; font-size: 12px; white-space: pre-wrap; }
.summary-box { background: #1e293b; border: 1px solid #334; border-radius: 8px; padding: 16px; margin: 12px 0; }
.btn { display: inline-block; padding: 10px 22px; background: #dc2626; color: #fff;
       text-decoration: none; border-radius: 6px; font-weight: bold; cursor: pointer;
       border: none; font-family: monospace; font-size: 14px; margin-top: 16px; }
.btn:hover { background: #b91c1c; }
.btn-safe { background: #1d4ed8; }
.btn-safe:hover { background: #1e40af; }
</style>
</head>
<body>
<h2>⚠ GL Sync Fix Tool — Administrators Only</h2>
<p style="color:#fbbf24">This page inserts missing bill entries into fin_ledger so the student portal shows correct balances. Delete this file after use.</p>

<asp:Panel ID="pnlDiag" runat="server"></asp:Panel>

<asp:Panel ID="pnlActions" runat="server">
    <asp:Button ID="btnRunDiag" runat="server" Text="1. Run Diagnostics" CssClass="btn btn-safe" OnClick="btnRunDiag_Click" />
    &nbsp;&nbsp;
    <asp:Button ID="btnRunFix" runat="server" Text="2. Apply Fix (INSERT missing GL rows)" CssClass="btn"
        OnClick="btnRunFix_Click"
        OnClientClick="return confirm('This will INSERT rows into fin_ledger. Are you sure?');" />
</asp:Panel>

<asp:Panel ID="pnlResult" runat="server"></asp:Panel>
</body>
</html>
