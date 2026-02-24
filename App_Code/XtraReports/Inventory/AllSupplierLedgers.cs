using System;
using System.Data;
using System.Drawing;
using DevExpress.XtraReports.UI;
using DevExpress.XtraPrinting;

/// <summary>
/// Consolidated All Supplier Ledgers Report - built programmatically from DataTable
/// </summary>
public class AllSupplierLedgers : DevExpress.XtraReports.UI.XtraReport
{
    private DataTable _data;
    private DateTime _startDate;
    private DateTime _endDate;

    public AllSupplierLedgers()
    {
        this.Landscape = true;
        this.PaperKind = System.Drawing.Printing.PaperKind.A4;
        this.Margins = new System.Drawing.Printing.Margins(20, 17, 19, 15);
    }

    public void SetData(DataTable data, DateTime startDate, DateTime endDate)
    {
        _data = data;
        _startDate = startDate;
        _endDate = endDate;
        BuildReport();
    }

    private Image GetCompanyLogo(out string companyName)
    {
        companyName = "MUTESA I ROYAL UNIVERSITY";
        Image logo = null;
        try
        {
            CoopERPDataTableAdapters.companyinfoTableAdapter compAdapter =
                new CoopERPDataTableAdapters.companyinfoTableAdapter();
            CoopERPData ds = new CoopERPData();
            compAdapter.Fill(ds.companyinfo);
            if (ds.companyinfo.Rows.Count > 0)
            {
                if (ds.companyinfo.Rows[0]["companyname"] != DBNull.Value)
                    companyName = ds.companyinfo.Rows[0]["companyname"].ToString();
                if (ds.companyinfo.Rows[0]["logo"] != DBNull.Value)
                {
                    byte[] logoBytes = (byte[])ds.companyinfo.Rows[0]["logo"];
                    using (System.IO.MemoryStream ms = new System.IO.MemoryStream(logoBytes))
                    {
                        logo = Image.FromStream(ms);
                    }
                }
            }
        }
        catch { }
        return logo;
    }

    private void BuildReport()
    {
        if (_data == null) return;

        this.DataSource = _data;

        // Total report width in landscape A4: ~1100 (PageWidth=1169 - margins 20+17 = 1132)
        float reportWidth = 1100f;

        // Load company info
        string companyName;
        Image logo = GetCompanyLogo(out companyName);

        // ========== REPORT HEADER ==========
        ReportHeaderBand reportHeader = new ReportHeaderBand();
        reportHeader.HeightF = 115f;

        // Logo
        if (logo != null)
        {
            XRPictureBox picLogo = new XRPictureBox();
            picLogo.Image = logo;
            picLogo.Sizing = ImageSizeMode.ZoomImage;
            picLogo.LocationFloat = new DevExpress.Utils.PointFloat(0f, 2f);
            picLogo.SizeF = new SizeF(60f, 60f);
            reportHeader.Controls.Add(picLogo);
        }

        // Company Name
        XRLabel lblCompany = new XRLabel();
        lblCompany.Text = companyName;
        lblCompany.Font = new Font("Tahoma", 15f, FontStyle.Bold);
        lblCompany.TextAlignment = TextAlignment.TopCenter;
        lblCompany.LocationFloat = new DevExpress.Utils.PointFloat(65f, 2f);
        lblCompany.SizeF = new SizeF(reportWidth - 65f, 30f);
        reportHeader.Controls.Add(lblCompany);

        // Report Title
        XRLabel lblTitle = new XRLabel();
        lblTitle.Text = "ALL SUPPLIER LEDGERS";
        lblTitle.Font = new Font("Tahoma", 11f, FontStyle.Bold);
        lblTitle.TextAlignment = TextAlignment.TopCenter;
        lblTitle.LocationFloat = new DevExpress.Utils.PointFloat(65f, 35f);
        lblTitle.SizeF = new SizeF(reportWidth - 65f, 22f);
        reportHeader.Controls.Add(lblTitle);

        // Date range
        XRLabel lblDates = new XRLabel();
        lblDates.Text = "Period: " + _startDate.ToString("dd MMMM, yyyy") + " to " + _endDate.ToString("dd MMMM, yyyy");
        lblDates.Font = new Font("Tahoma", 9f, FontStyle.Regular);
        lblDates.TextAlignment = TextAlignment.TopCenter;
        lblDates.LocationFloat = new DevExpress.Utils.PointFloat(65f, 58f);
        lblDates.SizeF = new SizeF(reportWidth - 65f, 20f);
        reportHeader.Controls.Add(lblDates);

        // Print date
        XRPageInfo printDate = new XRPageInfo();
        printDate.PageInfo = PageInfo.DateTime;
        printDate.Format = "PRINT DATE :: {0:dd/MM/yyyy}";
        printDate.Font = new Font("Tahoma", 9f, FontStyle.Bold);
        printDate.TextAlignment = TextAlignment.TopCenter;
        printDate.LocationFloat = new DevExpress.Utils.PointFloat(350f, 82f);
        printDate.SizeF = new SizeF(300f, 18f);
        reportHeader.Controls.Add(printDate);

        // Separator line
        XRLine headerLine = new XRLine();
        headerLine.LocationFloat = new DevExpress.Utils.PointFloat(0f, 108f);
        headerLine.SizeF = new SizeF(reportWidth, 5f);
        reportHeader.Controls.Add(headerLine);

        this.Bands.Add(reportHeader);

        // ========== PAGE HEADER (Column headers) ==========
        PageHeaderBand pageHeader = new PageHeaderBand();
        pageHeader.HeightF = 30f;

        string[] headers = { "Supplier", "Entry Date", "Invoice Date", "Particulars", "Journal No", "DR", "CR", "Balance" };
        float[] widths = { 200f, 110f, 95f, 280f, 85f, 110f, 110f, 110f };
        float xPos = 0f;

        XRLine pgHeaderLine = new XRLine();
        pgHeaderLine.LocationFloat = new DevExpress.Utils.PointFloat(0f, 26f);
        pgHeaderLine.SizeF = new SizeF(reportWidth, 3f);
        pageHeader.Controls.Add(pgHeaderLine);

        for (int i = 0; i < headers.Length; i++)
        {
            XRLabel lbl = new XRLabel();
            lbl.Text = headers[i];
            lbl.Font = new Font("Tahoma", 9f, FontStyle.Bold);
            lbl.TextAlignment = (i >= 5) ? TextAlignment.MiddleRight : TextAlignment.MiddleLeft;
            lbl.Padding = new PaddingInfo(3, 3, 0, 0, 100f);
            lbl.LocationFloat = new DevExpress.Utils.PointFloat(xPos, 0f);
            lbl.SizeF = new SizeF(widths[i], 25f);
            pageHeader.Controls.Add(lbl);
            xPos += widths[i];
        }

        this.Bands.Add(pageHeader);

        // ========== DETAIL BAND ==========
        DetailBand detail = new DetailBand();
        detail.HeightF = 22f;

        string[] fields = { "SupplierName", "EntryDate", "InvoiceDate", "Particulars", "VoucherNo", "DR", "CR", "Balance" };
        xPos = 0f;

        for (int i = 0; i < fields.Length; i++)
        {
            XRLabel cell = new XRLabel();
            cell.DataBindings.Add("Text", null, fields[i]);
            cell.Font = new Font("Tahoma", 8.5f);
            cell.TextAlignment = (i >= 5) ? TextAlignment.MiddleRight : TextAlignment.MiddleLeft;
            cell.Padding = new PaddingInfo(3, 3, 0, 0, 100f);
            cell.LocationFloat = new DevExpress.Utils.PointFloat(xPos, 0f);
            cell.SizeF = new SizeF(widths[i], 20f);
            cell.Borders = BorderSide.Bottom;
            cell.BorderColor = Color.FromArgb(200, 200, 200);
            cell.CanShrink = false;
            detail.Controls.Add(cell);
            xPos += widths[i];
        }

        this.Bands.Add(detail);

        // ========== PAGE FOOTER ==========
        PageFooterBand pageFooter = new PageFooterBand();
        pageFooter.HeightF = 35f;

        XRLine footerLine = new XRLine();
        footerLine.LocationFloat = new DevExpress.Utils.PointFloat(0f, 2f);
        footerLine.SizeF = new SizeF(reportWidth, 2f);
        pageFooter.Controls.Add(footerLine);

        XRLabel lblFooterText = new XRLabel();
        lblFooterText.Text = "All Supplier Ledgers";
        lblFooterText.Font = new Font("Tahoma", 8f, FontStyle.Italic);
        lblFooterText.TextAlignment = TextAlignment.MiddleLeft;
        lblFooterText.LocationFloat = new DevExpress.Utils.PointFloat(0f, 8f);
        lblFooterText.SizeF = new SizeF(350f, 18f);
        pageFooter.Controls.Add(lblFooterText);

        XRPageInfo pageNum = new XRPageInfo();
        pageNum.Format = "PAGE {0} OF {1}";
        pageNum.Font = new Font("Tahoma", 8f, FontStyle.Bold);
        pageNum.TextAlignment = TextAlignment.MiddleCenter;
        pageNum.LocationFloat = new DevExpress.Utils.PointFloat(reportWidth - 120f, 8f);
        pageNum.SizeF = new SizeF(120f, 18f);
        pageFooter.Controls.Add(pageNum);

        this.Bands.Add(pageFooter);

        // ========== FORMAT HANDLER - color rows ==========
        detail.BeforePrint += Detail_BeforePrint;
    }

    private void Detail_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        DetailBand band = sender as DetailBand;
        if (band == null) return;

        string particulars = GetCurrentColumnValue("Particulars") != null ? GetCurrentColumnValue("Particulars").ToString() : "";
        string supplierName = GetCurrentColumnValue("SupplierName") != null ? GetCurrentColumnValue("SupplierName").ToString() : "";

        Color bgColor = Color.White;
        Color fgColor = Color.Black;
        Font font = new Font("Tahoma", 8.5f);

        if (particulars.Contains("GENERAL"))
        {
            bgColor = Color.FromArgb(44, 62, 80);
            fgColor = Color.White;
            font = new Font("Tahoma", 9f, FontStyle.Bold);
        }
        else if (particulars == "CLOSING BALANCE" || particulars == "Opening Balance")
        {
            bgColor = Color.FromArgb(245, 245, 220);
            font = new Font("Tahoma", 8.5f, FontStyle.Bold);
        }
        else if (supplierName.Length > 10 && !supplierName.StartsWith("["))
        {
            bgColor = Color.FromArgb(214, 234, 248);
            font = new Font("Tahoma", 8.5f, FontStyle.Bold);
        }

        foreach (XRControl ctrl in band.Controls)
        {
            if (ctrl is XRLabel)
            {
                XRLabel lbl = (XRLabel)ctrl;
                lbl.BackColor = bgColor;
                lbl.ForeColor = fgColor;
                lbl.Font = font;
            }
        }
    }
}
