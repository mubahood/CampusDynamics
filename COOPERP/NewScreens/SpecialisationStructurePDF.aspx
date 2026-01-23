<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SpecialisationStructurePDF.aspx.cs" Inherits="COOPERP_NewScreens_SpecialisationStructurePDF" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Specialisation Structure</title>
    <style type="text/css">
        @media print {
            body { margin: 0; padding: 10mm; }
            .no-print { display: none !important; }
        }
        body {
            font-family: Arial, sans-serif;
            font-size: 11px;
            line-height: 1.4;
            color: #333;
            padding: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #422774;
        }
        .header h1 {
            margin: 0 0 5px 0;
            font-size: 16px;
            color: #422774;
        }
        .header h2 {
            margin: 0 0 5px 0;
            font-size: 14px;
            color: #333;
        }
        .header p {
            margin: 0;
            color: #666;
            font-size: 11px;
        }
        .structure-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        .structure-table th, .structure-table td {
            border: 1px solid #ddd;
            padding: 6px 8px;
            text-align: left;
        }
        .year-header {
            background: #422774;
            color: #fff;
            font-weight: bold;
            font-size: 12px;
        }
        .semester-header {
            background: #f5f5f5;
            font-weight: 600;
            width: 100px;
        }
        .course-row {
            font-size: 10px;
        }
        .course-code {
            font-weight: bold;
            width: 100px;
        }
        .course-name {
            
        }
        .credits {
            width: 60px;
            text-align: center;
        }
        .footer {
            margin-top: 20px;
            padding-top: 10px;
            border-top: 1px solid #ddd;
            font-size: 10px;
            color: #666;
            text-align: center;
        }
        .print-btn {
            position: fixed;
            top: 10px;
            right: 10px;
            padding: 8px 16px;
            background: #422774;
            color: #fff;
            border: none;
            cursor: pointer;
            font-size: 12px;
        }
        .print-btn:hover {
            background: #5a3a9a;
        }
        .summary {
            margin-top: 15px;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 3px;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <button type="button" class="print-btn no-print" onclick="window.print();">Print PDF</button>
        
        <div class="header">
            <h1>PROGRAMME SPECIALISATION STRUCTURE</h1>
            <h2><asp:Literal ID="litProgName" runat="server"></asp:Literal></h2>
            <p>Specialisation: <strong><asp:Literal ID="litSpecName" runat="server"></asp:Literal></strong></p>
        </div>
        
        <asp:Literal ID="litStructure" runat="server"></asp:Literal>
        
        <div class="summary">
            <asp:Literal ID="litSummary" runat="server"></asp:Literal>
        </div>
        
        <div class="footer">
            Generated on <asp:Literal ID="litDate" runat="server"></asp:Literal> | Campus Dynamics ERP System
        </div>
    </form>
</body>
</html>
