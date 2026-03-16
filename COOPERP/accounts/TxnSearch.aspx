<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TxnSearch.aspx.cs" Inherits="COOPERP_accounts_TxnSearch" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Transaction Search</title>
<style>
    body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 12px; margin: 0; padding: 10px; color: #1a1a2e; background: #f5f7fa; }
    h3 { margin: 0 0 10px; font-size: 14px; color: #05275C; border-bottom: 2px solid #05275C; padding-bottom: 5px; }
    table { width: 100%; border-collapse: collapse; background: #fff; }
    th { background: #05275C; color: #fff; padding: 6px 8px; text-align: left; font-size: 11px; text-transform: uppercase; }
    td { padding: 6px 8px; border-bottom: 1px solid #f0f0f0; }
    tr:hover td { background: #e8f4fd; }
    a { color: #174DA4; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .tag-dr  { background: #fff3cd; color: #856404; border-radius: 3px; padding: 1px 6px; font-size: 10px; font-weight: 600; }
    .tag-cr  { background: #d1ecf1; color: #0c5460; border-radius: 3px; padding: 1px 6px; font-size: 10px; font-weight: 600; }
    .tag-pos { background: #d4edda; color: #155724; border-radius: 3px; padding: 1px 6px; font-size: 10px; }
    .tag-pen { background: #fff3cd; color: #856404; border-radius: 3px; padding: 1px 6px; font-size: 10px; }
    .empty { color: #999; text-align: center; padding: 20px; }
    .qbar  { margin-bottom: 8px; font-size: 11px; color: #666; }
</style>
</head>
<body>
    <h3>Transaction Search</h3>
    <div class="qbar">Query: <strong><asp:Literal ID="litQuery" runat="server" /></strong></div>
    <asp:Literal ID="litResults" runat="server" />
</body>
</html>
