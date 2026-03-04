<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NCHEExporter.aspx.cs" Inherits="COOPERP_NewScreens_NCHEExporter" Title="NCHE Student Data Export - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style type="text/css">

/* ── NCHE Exporter — page-scoped styles ─────────────────────────────── */

.nche-header {
    background: linear-gradient(135deg, #05275C 0%, #0a3a7a 100%);
    border-bottom: 4px solid #c9a227;
    padding: 22px 28px;
    display: flex;
    align-items: center;
    gap: 18px;
}
.nche-header-icon {
    width: 52px;
    height: 52px;
    background: rgba(201,162,39,0.15);
    border: 2px solid rgba(201,162,39,0.4);
    border-radius: 2px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.nche-header-text { flex: 1; }
.nche-header-text h1 {
    color: #fff;
    font-size: 18px;
    font-weight: 700;
    margin: 0 0 4px 0;
    letter-spacing: 0.2px;
}
.nche-header-text p {
    color: rgba(255,255,255,0.72);
    font-size: 12px;
    line-height: 1.55;
    margin: 0;
}
.nche-ref-badge {
    background: rgba(201,162,39,0.18);
    border: 1px solid rgba(201,162,39,0.4);
    color: #c9a227;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.6px;
    padding: 5px 12px;
    white-space: nowrap;
    flex-shrink: 0;
    align-self: flex-start;
}

/* ── Body wrapper ───────────────────────────────────────────────────── */
.nche-body { padding: 22px 26px 40px; }

/* ── Info strip ─────────────────────────────────────────────────────── */
.nche-info-strip {
    background: #fffbee;
    border: 1px solid #ead98a;
    border-left: 4px solid #c9a227;
    padding: 10px 16px;
    margin-bottom: 18px;
    font-size: 12px;
    color: #705e12;
    line-height: 1.6;
}
.nche-info-strip strong { color: #4a3e0a; }
.nche-cols-list {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-top: 7px;
}
.nche-col-chip {
    background: rgba(201,162,39,0.12);
    border: 1px solid rgba(201,162,39,0.3);
    color: #5a4a10;
    font-size: 10.5px;
    font-weight: 600;
    padding: 2px 8px;
    letter-spacing: 0.3px;
}

/* ── Filter card ─────────────────────────────────────────────────────── */
.nche-filter-card {
    background: #fff;
    border: 1px solid #e0e5ed;
    border-top: 3px solid #05275C;
    padding: 18px 22px 16px;
    margin-bottom: 18px;
}
.nche-filter-card-title {
    font-size: 11.5px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.7px;
    color: #05275C;
    margin-bottom: 16px;
    padding-bottom: 10px;
    border-bottom: 1px solid #edf0f5;
    display: flex;
    align-items: center;
    gap: 7px;
}
.nche-filter-grid {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 14px;
    margin-bottom: 16px;
}
.nche-filter-field label {
    display: block;
    font-size: 10.5px;
    font-weight: 700;
    color: #6a7585;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 5px;
}
.nche-filter-actions {
    display: flex;
    align-items: center;
    gap: 10px;
    padding-top: 14px;
    border-top: 1px solid #edf0f5;
}
.nche-btn {
    height: 38px;
    padding: 0 20px;
    border: none;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.4px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 7px;
    transition: background 0.15s;
}
.nche-btn-load   { background: #05275C; color: #fff; }
.nche-btn-load:hover { background: #041d45; }
.nche-btn-export { background: #1a6b3c; color: #fff; }
.nche-btn-export:hover { background: #134f2d; }
.nche-btn-clear  { background: transparent; color: #666; border: 1px solid #d0d6e0; }
.nche-btn-clear:hover { background: #f5f7fa; }
.nche-count-lbl { margin-left: auto; }

/* ── Grid card ──────────────────────────────────────────────────────── */
.nche-grid-card {
    background: #fff;
    border: 1px solid #e0e5ed;
    overflow: hidden;
}
.nche-grid-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    border-bottom: 1px solid #edf0f5;
    background: #f8fafd;
}
.nche-grid-header h3 {
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #05275C;
    margin: 0;
}
.nche-grid-hint {
    font-size: 11px;
    color: #999;
}

</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div>

    <%-- ── Page Header ──────────────────────────────────────────────── --%>
    <div class="nche-header">
        <div class="nche-header-icon">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none"
                 stroke="#c9a227" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 2L2 7l10 5 10-5-10-5z"/>
                <path d="M2 17l10 5 10-5"/>
                <path d="M2 12l10 5 10-5"/>
            </svg>
        </div>
        <div class="nche-header-text">
            <h1>NCHE Student Data Export</h1>
            <p>National Council for Higher Education &mdash; Student Admission Number Initiative &mdash; Ref: NCHE/GR/U/78 (9&nbsp;February 2026)</p>
            <p>Pursuant to Section 4(j), Universities and Other Tertiary Institutions Act Cap.&nbsp;262, Laws of Uganda</p>
        </div>
        <div class="nche-ref-badge">NCHE / GR / U / 78</div>
    </div>

    <div class="nche-body">

        <%-- ── Required columns notice ──────────────────────────────── --%>
        <div class="nche-info-strip">
            <strong>NCHE Required Data Columns (10 fields per student record):</strong>
            <div class="nche-cols-list">
                <span class="nche-col-chip">S/N</span>
                <span class="nche-col-chip">Names</span>
                <span class="nche-col-chip">Sex</span>
                <span class="nche-col-chip">National ID No.</span>
                <span class="nche-col-chip">Institutional Reg. No.</span>
                <span class="nche-col-chip">Programme Code</span>
                <span class="nche-col-chip">Programme Name</span>
                <span class="nche-col-chip">Award Level</span>
                <span class="nche-col-chip">Year of Study</span>
                <span class="nche-col-chip">Study Centre</span>
            </div>
        </div>

        <%-- ── Filter card ───────────────────────────────────────────── --%>
        <div class="nche-filter-card">
            <div class="nche-filter-card-title">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                     stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
                </svg>
                Export Criteria
            </div>

            <div class="nche-filter-grid">
                <div class="nche-filter-field">
                    <label>Student Status</label>
                    <dx:ASPxComboBox ID="cmbStatus" runat="server" Width="100%" Height="35px" AutoPostBack="false">
                        <Items>
                            <dx:ListEditItem Text="Active Students"   Value="ACTIVE"    Selected="true" />
                            <dx:ListEditItem Text="All Students"      Value="ALL" />
                            <dx:ListEditItem Text="Inactive"          Value="INACTIVE" />
                            <dx:ListEditItem Text="Deferred"          Value="DEFERRED" />
                            <dx:ListEditItem Text="Completed"         Value="COMPLETED" />
                        </Items>
                    </dx:ASPxComboBox>
                </div>

                <div class="nche-filter-field">
                    <label>Entry Year</label>
                    <dx:ASPxComboBox ID="cmbAcadYear" runat="server" Width="100%" Height="35px" AutoPostBack="false">
                    </dx:ASPxComboBox>
                </div>

                <div class="nche-filter-field">
                    <label>Programme</label>
                    <dx:ASPxComboBox ID="cmbProgramme" runat="server" Width="100%" Height="35px" AutoPostBack="false">
                    </dx:ASPxComboBox>
                </div>

                <div class="nche-filter-field">
                    <label>Award Level</label>
                    <dx:ASPxComboBox ID="cmbAwardLevel" runat="server" Width="100%" Height="35px" AutoPostBack="false">
                        <Items>
                            <dx:ListEditItem Text="All Levels"            Value=""              Selected="true" />
                            <dx:ListEditItem Text="Bachelor's Degree"     Value="Bachelor" />
                            <dx:ListEditItem Text="Master's Degree"       Value="Master" />
                            <dx:ListEditItem Text="Doctoral Degree"       Value="Doctor" />
                            <dx:ListEditItem Text="Postgraduate Diploma"  Value="Postgraduate" />
                            <dx:ListEditItem Text="Diploma"               Value="Diploma" />
                            <dx:ListEditItem Text="Certificate"           Value="Certificate" />
                        </Items>
                    </dx:ASPxComboBox>
                </div>

                <div class="nche-filter-field">
                    <label>Study Centre</label>
                    <dx:ASPxComboBox ID="cmbCampus" runat="server" Width="100%" Height="35px" AutoPostBack="false">
                    </dx:ASPxComboBox>
                </div>
            </div>

            <div class="nche-filter-actions">
                <asp:Button ID="btnLoad" runat="server" Text="Load Preview" OnClick="btnLoad_Click"
                    CssClass="nche-btn nche-btn-load" CausesValidation="false" />

                <asp:Button ID="btnExport" runat="server" Text="Export to Excel (.xlsx)" OnClick="btnExport_Click"
                    CssClass="nche-btn nche-btn-export" CausesValidation="false"
                    OnClientClick="if(this.innerText.indexOf('Exporting')>=0) return false;" />

                <asp:Button ID="btnClear" runat="server" Text="Reset" OnClick="btnClear_Click"
                    CssClass="nche-btn nche-btn-clear" CausesValidation="false" />

                <div class="nche-count-lbl">
                    <asp:Label ID="lblCount" runat="server" />
                </div>
            </div>
        </div>

        <%-- ── Preview grid ──────────────────────────────────────────── --%>
        <div class="nche-grid-card">
            <div class="nche-grid-header">
                <h3>
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                         stroke-width="2.5" stroke-linecap="round" style="vertical-align:-1px; margin-right:5px;">
                        <rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M3 15h18M9 3v18"/>
                    </svg>
                    Data Preview
                </h3>
                <span class="nche-grid-hint">Showing first 200 rows &mdash; export downloads all matched records</span>
            </div>

            <dx:ASPxGridView ID="gvNCHE" runat="server"
                AutoGenerateColumns="false"
                Width="100%"
                KeyFieldName="regno"
                Theme="Aqua">

                <Settings ShowGroupPanel="false" ShowFilterRow="false" />
                <SettingsPager PageSize="50" />
                <SettingsExport ExportSelectedRowsOnly="false" />
                <SettingsBehavior AllowSort="true" />

                <Columns>
                    <dx:GridViewDataTextColumn FieldName="sn"           Caption="S/N"                    Width="52px"  />
                    <dx:GridViewDataTextColumn FieldName="full_name"     Caption="Names"                  Width="185px" />
                    <dx:GridViewDataTextColumn FieldName="sex"           Caption="Sex"                    Width="58px"  />
                    <dx:GridViewDataTextColumn FieldName="national_id"   Caption="National ID No."        Width="140px" />
                    <dx:GridViewDataTextColumn FieldName="regno"         Caption="Institutional Reg. No." Width="148px" />
                    <dx:GridViewDataTextColumn FieldName="progcode"      Caption="Prog. Code"             Width="100px" />
                    <dx:GridViewDataTextColumn FieldName="progname"      Caption="Programme Name"         Width="240px" />
                    <dx:GridViewDataTextColumn FieldName="award_level"   Caption="Award Level"            Width="155px" />
                    <dx:GridViewDataTextColumn FieldName="yearofstudy"   Caption="Year of Study"          Width="95px"  />
                    <dx:GridViewDataTextColumn FieldName="study_centre"  Caption="Study Centre"           Width="140px" />
                </Columns>

            </dx:ASPxGridView>
        </div>

    </div><%-- /nche-body --%>

</div>
</asp:Content>
