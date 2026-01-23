<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SpecialisationStructurePDF.aspx.cs" Inherits="COOPERP_NewScreens_SpecialisationStructurePDF" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Specialisation Course Structure</title>
    <style type="text/css">
        * { box-sizing: border-box; }
        body { 
            margin: 0; 
            padding: 20px; 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; 
            background: #f5f5f5;
            font-size: 12px;
        }
        .print-container {
            max-width: 900px;
            margin: 0 auto;
            background: #fff;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .header { display: flex; align-items: center; margin-bottom: 15px; border-bottom: 2px solid #422774; padding-bottom: 15px; }
        .header img { width: 60px; height: auto; margin-right: 15px; }
        .header-text h1 { margin: 0; font-size: 18px; color: #422774; }
        .header-text h2 { margin: 5px 0 0 0; font-size: 12px; color: #666; font-weight: normal; }
        .meta { display: flex; justify-content: space-between; margin-bottom: 15px; padding: 10px; background: #f9f9f9; }
        .meta-item { font-size: 11px; }
        .meta-item strong { color: #422774; }
        .summary { background: #422774; color: #fff; padding: 8px 12px; font-size: 11px; margin-bottom: 15px; }
        .year-section { margin-bottom: 20px; }
        .year-header { background: #422774; color: #fff; padding: 8px 12px; font-size: 13px; font-weight: bold; }
        .semester-section { margin: 10px 0; }
        .semester-header { background: #f0f0f0; padding: 6px 12px; font-size: 11px; font-weight: bold; color: #333; border-left: 3px solid #422774; }
        table { width: 100%; border-collapse: collapse; margin-top: 5px; }
        th { background: #f5f5f5; padding: 6px 8px; text-align: left; font-size: 10px; border: 1px solid #ddd; color: #333; }
        td { padding: 5px 8px; border: 1px solid #ddd; font-size: 10px; }
        .code { font-weight: bold; color: #422774; width: 80px; }
        .type { width: 50px; text-align: center; }
        .type-core { color: #666; }
        .type-elective { color: #2e7d32; font-weight: bold; }
        .cu { width: 40px; text-align: center; }
        .footer { margin-top: 20px; padding-top: 10px; border-top: 1px solid #ddd; font-size: 9px; color: #999; display: flex; justify-content: space-between; }
        .toolbar { margin-bottom: 15px; text-align: right; }
        .toolbar button { background: #422774; color: #fff; border: none; padding: 8px 16px; cursor: pointer; font-size: 11px; margin-left: 5px; }
        .toolbar button:hover { background: #5a3a8c; }
        .no-data { padding: 40px; text-align: center; color: #999; }
        @media print {
            body { padding: 0; background: #fff; }
            .print-container { box-shadow: none; padding: 15px; }
            .toolbar { display: none; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="print-container">
            <div class="toolbar">
                <button type="button" onclick="window.print();">🖨️ Print</button>
                <button type="button" onclick="window.close();">✕ Close</button>
            </div>
            
            <div class="header">
                <asp:Image ID="imgLogo" runat="server" Visible="false" />
                <div class="header-text">
                    <h1><asp:Literal ID="litInstitution" runat="server"></asp:Literal></h1>
                    <h2>PROGRAMME SPECIALISATION STRUCTURE</h2>
                </div>
            </div>
            
            <div class="meta">
                <div class="meta-item"><strong>Programme:</strong> <asp:Literal ID="litProgramme" runat="server"></asp:Literal></div>
                <div class="meta-item"><strong>Specialisation:</strong> <asp:Literal ID="litSpecialisation" runat="server"></asp:Literal></div>
                <div class="meta-item"><strong>Date:</strong> <%= DateTime.Now.ToString("dd MMM yyyy") %></div>
            </div>
            
            <div class="summary">
                Total Courses: <asp:Literal ID="litTotalCourses" runat="server"></asp:Literal> | 
                Total Credits: <asp:Literal ID="litTotalCredits" runat="server"></asp:Literal> CU
            </div>
            
            <asp:PlaceHolder ID="phContent" runat="server"></asp:PlaceHolder>
            
            <div class="footer">
                <span>Campus Dynamics ERP</span>
                <span>Generated: <%= DateTime.Now.ToString("dd MMM yyyy HH:mm") %></span>
            </div>
        </div>
    </form>
</body>
</html>
