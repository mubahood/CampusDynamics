<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ApplySpFix.aspx.cs" Inherits="COOPERP_Admin_ApplySpFix" %>
<!DOCTYPE html>
<html>
<head><title>SP Fix — Admin Only</title>
<style>body{font-family:sans-serif;max-width:700px;margin:40px auto;padding:20px}
pre{background:#f4f4f4;padding:12px;border-radius:4px;white-space:pre-wrap;word-break:break-all}
.ok{color:green;font-weight:700}.err{color:red;font-weight:700}
input[type=password]{padding:8px;width:280px}button{padding:8px 20px;margin-left:8px}</style>
</head>
<body>
<h2>acad_RegisterApplicant — Remove Year Restriction</h2>
<form method="post">
    <label>Admin password: <input type="password" name="pwd" /></label>
    <button type="submit">Apply Fix</button>
</form>
<asp:Literal ID="litResult" runat="server" />
</body>
</html>
