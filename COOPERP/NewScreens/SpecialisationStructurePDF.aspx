<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SpecialisationStructurePDF.aspx.cs" Inherits="COOPERP_NewScreens_SpecialisationStructurePDF" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Specialisation Course Structure &mdash; Campus Dynamics</title>
    <meta name="viewport" content="width=device-width" />
    <style type="text/css">
        @page { size: A4 portrait; margin: 12mm 10mm; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, Helvetica, sans-serif; font-size: 8.5pt; color: #222; background: #dde4f0; }

        /* ---- Toolbar (screen only) ---- */
        .toolbar {
            background: #1a1a2e; color: white;
            padding: 9px 20px; display: flex; gap: 8px; align-items: center;
            position: sticky; top: 0; z-index: 9999;
            box-shadow: 0 2px 8px rgba(0,0,0,.4);
        }
        .toolbar-brand { font-size: 11px; font-weight: 700; letter-spacing: .3px; margin-right: 4px; }
        .tbtn {
            display: inline-flex; align-items: center; gap: 5px;
            background: #174DA4; color: white; border: none;
            padding: 6px 14px; cursor: pointer; font-size: 10px; font-weight: 600;
            border-radius: 3px; transition: background .15s; white-space: nowrap;
        }
        .tbtn:hover { background: #1360c8; }
        .tbtn-grey { background: #555; }
        .tbtn-grey:hover { background: #333; }
        .toolbar-info { margin-left: auto; font-size: 9px; color: #9ab; }
        .toolbar-badge { background: #ffd700; color: #222; border-radius: 10px; padding: 1px 8px; font-weight: 700; font-size: 9px; margin-left: 4px; }

        /* ---- Page wrapper ---- */
        .page-wrap {
            background: white; max-width: 210mm;
            margin: 14px auto 40px; padding: 14mm 12mm 12mm;
            box-shadow: 0 3px 22px rgba(0,0,0,.18);
        }

        /* ---- Institution header ---- */
        .inst-header { display: flex; align-items: center; gap: 12px; padding-bottom: 7px; border-bottom: 2.5pt solid #174DA4; margin-bottom: 9px; }
        .inst-header img { height: 46px; width: auto; }
        .inst-hdr-text h1 { font-size: 12pt; color: #174DA4; font-weight: 700; line-height: 1.25; }
        .inst-hdr-text h2 { font-size: 7.5pt; color: #777; font-weight: 400; margin-top: 2px; text-transform: uppercase; letter-spacing: .5px; }

        /* ---- Batch banner ---- */
        .batch-banner {
            background: linear-gradient(135deg, #174DA4 0%, #1360c8 100%);
            color: white; padding: 8px 12px; margin-bottom: 10px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .batch-banner .bb-left .bb-title { font-size: 10.5pt; font-weight: 700; }
        .batch-banner .bb-left .bb-sub  { font-size: 7.5pt; opacity: .85; margin-top: 2px; }
        .batch-banner .bb-right { font-size: 8pt; text-align: right; opacity: .92; line-height: 1.6; }

        /* ---- Single-spec meta cards ---- */
        .single-meta { display: flex; border: 1pt solid #dce5f8; margin-bottom: 6px; }
        .sm-card { flex: 1; padding: 7px 11px; border-right: 1pt solid #dce5f8; }
        .sm-card:last-child { border-right: none; }
        .sm-card .sc-label { font-size: 6.8pt; text-transform: uppercase; letter-spacing: .5px; color: #8a97b4; font-weight: 700; margin-bottom: 2px; }
        .sm-card .sc-value { font-size: 8.5pt; font-weight: 600; color: #222; }
        .single-summary {
            background: #f0f4ff; border: 1pt solid #c8d8f8;
            padding: 5px 12px; font-size: 8pt; font-weight: 600; color: #174DA4;
            display: flex; gap: 20px; margin-bottom: 12px;
        }

        /* ---- Spec section ---- */
        .spec-section { page-break-after: always; }
        .spec-section:last-child { page-break-after: avoid; }
        .spec-title-bar {
            background: #174DA4; color: white;
            padding: 5px 10px; font-size: 10pt; font-weight: 700;
            margin-bottom: 5px; display: flex; justify-content: space-between; align-items: baseline;
        }
        .spec-title-bar .stb-seq { font-size: 7.5pt; opacity: .7; font-weight: 400; }
        .spec-meta-row {
            display: flex; gap: 14px; flex-wrap: wrap;
            font-size: 7.5pt; color: #444;
            padding: 4px 0 5px; border-bottom: 1pt solid #eaecf5; margin-bottom: 6px;
        }
        .spec-meta-row strong { color: #174DA4; }
        .spec-sumbar {
            background: #f5f7ff; border-left: 3pt solid #174DA4;
            padding: 4px 10px; font-size: 7.5pt; color: #333;
            margin-bottom: 9px; display: flex; gap: 16px;
        }
        .spec-sumbar strong { color: #174DA4; }

        /* ---- Year block ---- */
        .year-block { margin-bottom: 10px; }
        .year-hdr {
            background: #1e5fbf; color: white;
            padding: 4px 9px; font-size: 9pt; font-weight: 700;
            letter-spacing: .2px; margin-bottom: 5px;
        }

        /* ---- 2-column semester row ---- */
        .sems-row { display: flex; gap: 7px; align-items: flex-start; }
        .sem-col { flex: 1; min-width: 0; }
        .sem-hdr {
            background: #eef2ff; border-left: 3pt solid #174DA4;
            padding: 3px 7px; font-size: 8pt; font-weight: 700;
            color: #1a2a5e; margin-bottom: 3px;
        }
        .sem-hdr .sh-meta { font-weight: 400; color: #7a8aba; font-size: 7pt; margin-left: 5px; }

        /* ---- Course table ---- */
        table.ct { width: 100%; border-collapse: collapse; }
        table.ct th {
            background: #f0f3ff; font-size: 6.8pt; font-weight: 700;
            color: #555; padding: 3px 5px; border: 0.5pt solid #ccd;
            text-transform: uppercase; white-space: nowrap;
        }
        table.ct td { font-size: 7.5pt; padding: 2.5px 5px; border: 0.5pt solid #dde; vertical-align: top; }
        table.ct tbody tr:nth-child(even) td { background: #fafbff; }
        .ct-code { font-weight: 700; color: #174DA4; white-space: nowrap; width: 58px; }
        .ct-type { width: 14px; text-align: center; font-size: 7pt; }
        .ct-e { color: #1a7a1a; font-weight: 700; }
        .ct-c { color: #888; }
        .ct-cu { width: 22px; text-align: center; color: #444; font-size: 7pt; }
        tr.ct-tot td {
            background: #eef2ff !important;
            font-weight: 700; color: #174DA4;
            font-size: 7pt; border-top: 1pt solid #b8ccf0;
        }

        /* ---- No data / error ---- */
        .no-data { padding: 25px; text-align: center; color: #999; font-size: 8.5pt; }
        .err-msg {
            padding: 7px 11px; margin-bottom: 7px;
            background: #fff5f5; border-left: 3pt solid #dc3545; color: #721c24; font-size: 8pt;
        }

        /* ---- Footer ---- */
        .doc-footer {
            border-top: 1pt solid #e0e0e0; padding-top: 5px; margin-top: 12px;
            font-size: 7pt; color: #bbb; display: flex; justify-content: space-between;
        }

        /* ---- Print overrides ---- */
        @media print {
            body { background: white; }
            .page-wrap { box-shadow: none; padding: 0; max-width: none; margin: 0; }
            .toolbar { display: none !important; }
            table.ct tbody tr:nth-child(even) td { background: #fafbff !important; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- Toolbar (hidden when printing) -->
        <div class="toolbar">
            <span class="toolbar-brand">Specialisation Structure</span>
            <button type="button" class="tbtn" id="btnDownloadPdf" onclick="downloadPdf()">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                Download PDF
            </button>
            <button type="button" class="tbtn tbtn-grey" onclick="window.print()">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                Print
            </button>
            <button type="button" class="tbtn tbtn-grey" onclick="window.close()">&#x2715; Close</button>
            <span class="toolbar-info" id="spanTbInfo"></span>
        </div>

        <!-- A4 page wrapper -->
        <div class="page-wrap">

            <!-- Institution header -->
            <div class="inst-header">
                <asp:Image ID="imgLogo" runat="server" Visible="false" />
                <div class="inst-hdr-text">
                    <h1><asp:Literal ID="litInstitution" runat="server"></asp:Literal></h1>
                    <h2>Programme Specialisation &mdash; Course Structure</h2>
                </div>
            </div>

            <!-- Meta / banner (filled by code-behind for both single and batch) -->
            <asp:PlaceHolder ID="phMeta" runat="server"></asp:PlaceHolder>

            <!-- Course structure content -->
            <asp:PlaceHolder ID="phContent" runat="server"></asp:PlaceHolder>

            <div class="doc-footer">
                <span>Campus Dynamics ERP &mdash; Academic Module</span>
                <span>Generated: <%= DateTime.Now.ToString("dd MMM yyyy  HH:mm") %></span>
            </div>
        </div>

    </form>
    <script type="text/javascript">
        // Populate toolbar spec count
        var sections = document.querySelectorAll('.spec-section');
        var ti = document.getElementById('spanTbInfo');
        if (ti && sections.length > 1)
            ti.innerHTML = '<span class="toolbar-badge">' + sections.length + '</span> specialisations';
        
        function downloadPdf() {
            var url = window.location.href;
            // Append or replace the download=1 param
            if (url.indexOf('download=1') === -1) {
                url += (url.indexOf('?') === -1 ? '?' : '&') + 'download=1';
            }
            var btn = document.getElementById('btnDownloadPdf');
            if (btn) { btn.textContent = 'Generating\u2026'; btn.disabled = true; }
            window.location.href = url;
            setTimeout(function() {
                if (btn) { btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg> Download PDF'; btn.disabled = false; }
            }, 3000);
        }
    </script>
</body>
</html>
