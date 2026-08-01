<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewStudentRegistration.aspx.cs" Inherits="COOPERP_NewScreens_NewStudentRegistration" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===================================================================
   NEW STUDENT REGISTRATION - Standalone Page Styles
   =================================================================== */

/* -- Layout ---------------------------------------- */
.nsr-page { max-width: 930px; margin: 0 auto; }

.nsr-header {
    background: #05275C;
    color: #fff; border-radius: 0; padding: 12px 16px;
    display: flex; align-items: center; justify-content: space-between;
}
.nsr-header h1 { margin: 0; font-size: 14px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.nsr-header .nsr-sub { font-size: 10px; opacity: .8; margin-top: 1px; }

.nsr-body {
    background: #fff; border: 1px solid #e0e0e0; border-top: none;
    border-radius: 0; padding: 14px 16px 12px;
}

/* -- Section headers ------------------------------- */
.nsr-section {
    font-size: 10px; text-transform: uppercase; letter-spacing: .7px;
    color: #174DA4; font-weight: 700; padding: 8px 0 5px;
    border-bottom: 1px solid #e8ecf4; margin: 14px 0 8px;
    display: flex; align-items: center; gap: 8px;
}
.nsr-section:first-child { margin-top: 0; }
.nsr-section svg { flex-shrink: 0; }



/* -- Form grid layouts ----------------------------- */
/* -- Grid layouts ---------------------------------- */
.nsr-row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.nsr-row3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
.nsr-row4 { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 10px; }
/* Title (90px) + Surname + First Name + Other Names */
.nsr-row-name { display: grid; grid-template-columns: 90px 1fr 1fr 1fr; gap: 10px; }

/* -- Form controls --------------------------------- */
.nsr-group { margin-bottom: 8px; }
.nsr-label {
    display: block; font-size: 10px; text-transform: uppercase;
    letter-spacing: .4px; color: #555; font-weight: 600; margin-bottom: 4px;
}
.nsr-label .req { color: #dc3545; margin-left: 2px; }
.nsr-input, .nsr-select {
    width: 100%; padding: 6px 8px; border: 1px solid #cdd8e6; border-radius: 0;
    font-size: 12px; box-sizing: border-box; background: #fff;
    transition: border-color .15s;
}
.nsr-input:focus, .nsr-select:focus {
    border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.08);
}
.nsr-input:disabled, .nsr-select:disabled { background: #f5f7fa; color: #999; }
.nsr-hint { font-size: 9px; color: #888; margin-top: 2px; line-height: 1.4; }
.nsr-textarea { min-height: 60px; resize: vertical; }
/* auto-uppercase for name fields */
.nsr-upper { text-transform: uppercase; }

/* -- Checkbox -------------------------------------- */
.nsr-check-label {
    display: flex; align-items: center; gap: 8px; cursor: pointer;
    font-size: 12px; font-weight: 600; color: #333; padding: 8px 0;
}
.nsr-check-label input[type="checkbox"] { width: 15px; height: 15px; }

/* -- Footer ---------------------------------------- */
.nsr-footer {
    display: flex; justify-content: space-between; align-items: center;
    padding: 10px 0 0; border-top: 1px solid #e4e8f0; margin-top: 12px;
}
.nsr-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 7px 12px; border-radius: 0; font-size: 12px; font-weight: 600;
    border: none; cursor: pointer; transition: all .15s;
}
.nsr-btn--primary { background: #174DA4; color: #fff; }
.nsr-btn--primary:hover { background: #0c3580; }
.nsr-btn--success { background: #05275C; color: #fff; }
.nsr-btn--success:hover { background: #174DA4; }
.nsr-btn--ghost { background: transparent; color: #555; border: 1px solid #cdd3de; }
.nsr-btn--ghost:hover { background: #f0f4fc; border-color: #174DA4; color: #174DA4; }
.nsr-btn:disabled { opacity: .5; cursor: not-allowed; }

/* -- Alert bar ------------------------------------- */
.nsr-alert {
    display: none; padding: 9px 12px; border-radius: 0;
    font-size: 12px; margin: 8px 0; position: relative;
}
.nsr-alert--err { background: #fdecea; color: #b91c1c; border-left: 4px solid #c62828; display: block; }
.nsr-alert--ok  { background: #e6f4ea; color: #155724; border-left: 4px solid #2e7d32; display: block; }
.nsr-alert__close {
    position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
    background: none; border: none; font-size: 18px; cursor: pointer; color: inherit; opacity: .6;
}

/* -- Loading spinner ------------------------------- */
.nsr-loading {
    display: inline-block; width: 14px; height: 14px; border: 2px solid rgba(255,255,255,.3);
    border-top-color: #fff; border-radius: 50%; animation: nsrSpin .6s linear infinite;
    vertical-align: middle; margin-right: 6px;
}
@keyframes nsrSpin { to { transform: rotate(360deg); } }

/* -- Cascading dropdown indicator ------------------ */
.nsr-select--loading { background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" stroke="%23ccc" stroke-width="3" fill="none" stroke-dasharray="31" stroke-linecap="round"><animateTransform attributeName="transform" type="rotate" dur="0.6s" from="0 12 12" to="360 12 12" repeatCount="indefinite"/></circle></svg>'); background-repeat: no-repeat; background-position: right 8px center; }

/* -- Success result card --------------------------- */
.nsr-result-card {
    background: #f0fdf4;
    border: 1px solid #a5d6a7; border-radius: 4px; padding: 14px 16px;
    text-align: center; display: none;
}
.nsr-result-card.show { display: block; }
.nsr-result-card h3 { color: #2e7d32; margin: 8px 0; font-size: 16px; }
.nsr-result-card .nsr-result-detail { font-size: 13px; color: #333; margin: 4px 0; }
.nsr-result-actions { display: flex; gap: 10px; justify-content: center; margin-top: 16px; }

/* -- Responsive ------------------------------------ */
@media (max-width: 768px) {
    .nsr-row2, .nsr-row3, .nsr-row4, .nsr-row-name { grid-template-columns: 1fr; }
    .nsr-body { padding: 12px; }
    .nsr-header { padding: 10px 12px; }
    .nsr-footer { flex-direction: column; gap: 10px; }
}
@media (max-width: 480px) {
    .nsr-row-name { grid-template-columns: 1fr 1fr; }
    .nsr-row-name .nsr-group:first-child { grid-column: 1 / -1; }
}

.nsr-ajax-progress {
    position: fixed;
    right: 14px;
    bottom: 14px;
    z-index: 99999;
    background: #05275C;
    color: #fff;
    border-radius: 0;
    padding: 7px 10px;
    font-size: 11px;
    box-shadow: 0 6px 20px rgba(2,8,23,.25);
}

/* ── Searchable Select (ss-*) ────────────────────────────── */
.nsr-ss-wrap { position: relative; }
.nsr-ss-trigger {
    width: 100%; display: flex; align-items: center; justify-content: space-between;
    padding: 6px 8px; border: 1px solid #cdd8e6; background: #fff;
    font-size: 12px; font-family: inherit; text-align: left; cursor: pointer;
    box-sizing: border-box; min-height: 30px; transition: border-color .15s; color: #1a1a2e;
}
.nsr-ss-trigger:hover { border-color: #174DA4; }
.nsr-ss-wrap.ss-open .nsr-ss-trigger { border-color: #174DA4; border-bottom-color: transparent; box-shadow: 0 0 0 2px rgba(23,77,164,.08); }
.nsr-ss-display { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.nsr-ss-trigger.ph .nsr-ss-display { color: #aaa; }
.nsr-ss-caret { margin-left: 6px; flex-shrink: 0; transition: transform .15s; opacity: .5; }
.nsr-ss-wrap.ss-open .nsr-ss-caret { transform: rotate(180deg); }
.nsr-ss-drop {
    display: none; position: absolute; top: 100%; left: 0; right: 0; z-index: 7000;
    background: #fff; border: 1px solid #174DA4; border-top: none;
    box-shadow: 0 8px 24px rgba(5,39,92,.14); flex-direction: column;
}
.nsr-ss-wrap.ss-open .nsr-ss-drop { display: flex; }
.nsr-ss-search-wrap { padding: 6px 8px; border-bottom: 1px solid #e8ecf4; flex-shrink: 0; background: #f8fafc; }
.nsr-ss-q {
    width: 100%; padding: 5px 8px; border: 1px solid #d0d7e3; font-size: 12px;
    font-family: inherit; box-sizing: border-box; outline: none; background: #fff;
}
.nsr-ss-q:focus { border-color: #174DA4; }
.nsr-ss-opts { overflow-y: auto; max-height: 230px; }
.nsr-ss-opt {
    padding: 7px 10px; font-size: 12px; cursor: pointer;
    border-bottom: 1px solid #f0f2f5; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.nsr-ss-opt:hover { background: #eef5ff; color: #05275C; }
.nsr-ss-opt.sel { background: #05275C; color: #fff; font-weight: 600; }
.nsr-ss-opt.ph { color: #aaa; font-style: italic; }
.nsr-ss-opt mark { background: #fef08a; color: #1a1a2e; font-weight: 700; font-style: normal; }
.nsr-ss-empty { padding: 14px 10px; font-size: 11px; color: #aaa; text-align: center; }
.nsr-ss-footer { padding: 4px 8px; font-size: 10px; color: #aaa; border-top: 1px solid #eee; background: #f8f9fa; flex-shrink: 0; text-align: right; }

/* ── Education sub-sections ──────────────────────────────── */
.nsr-edu-block { background: #fafbfc; border: 1px solid #e8ecf4; padding: 10px 12px; margin-bottom: 10px; }
.nsr-edu-block-title { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: #174DA4; margin-bottom: 8px; }

/* ── Document Management Panel ───────────────────────────── */
.nsr-docs-panel {
    background: #fff; border: 1px solid #e0e5ed; border-top: 3px solid #174DA4;
    margin-top: 16px;
}
.nsr-docs-header {
    background: #f5f7fa; border-bottom: 1px solid #e0e5ed;
    padding: 10px 16px; display: flex; align-items: center; justify-content: space-between;
}
.nsr-docs-header h2 {
    margin: 0; font-size: 13px; font-weight: 700; color: #05275C;
    display: flex; align-items: center; gap: 8px;
}
.nsr-docs-body { padding: 14px 16px 16px; }
.nsr-doc-count { font-size: 10px; color: #888; background: #e8ecf4; padding: 2px 8px; font-weight: 600; }

/* Document table */
.nsr-doc-table { width: 100%; border-collapse: collapse; font-size: 11px; margin-bottom: 16px; }
.nsr-doc-table th {
    background: #f0f4fc; color: #05275C; font-size: 10px; text-transform: uppercase;
    letter-spacing: .4px; padding: 6px 10px; text-align: left; border-bottom: 2px solid #e0e5ed;
    font-weight: 700;
}
.nsr-doc-table td { padding: 7px 10px; border-bottom: 1px solid #f0f2f5; vertical-align: middle; }
.nsr-doc-table tr:hover td { background: #fafbfc; }
.nsr-doc-type-badge {
    display: inline-block; padding: 2px 7px; font-size: 9px; font-weight: 700;
    text-transform: uppercase; letter-spacing: .4px; background: #05275C; color: #fff; white-space: nowrap;
}
.nsr-doc-type-badge.dt-photo   { background: #6d28d9; }
.nsr-doc-type-badge.dt-olevel  { background: #065f46; }
.nsr-doc-type-badge.dt-alevel  { background: #0c4a6e; }
.nsr-doc-type-badge.dt-natid   { background: #92400e; }
.nsr-doc-type-badge.dt-other   { background: #4b5563; }
.nsr-doc-filename { font-weight: 600; color: #1a1a2e; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.nsr-doc-actions { display: flex; gap: 5px; }
.nsr-doc-btn { padding: 3px 10px; font-size: 10px; font-weight: 600; border: none; cursor: pointer; white-space: nowrap; }
.nsr-doc-btn--view   { background: #174DA4; color: #fff; }
.nsr-doc-btn--view:hover { background: #0c3580; }
.nsr-doc-btn--del    { background: #dc2626; color: #fff; }
.nsr-doc-btn--del:hover  { background: #b91c1c; }
.nsr-doc-btn:disabled { opacity: .5; cursor: not-allowed; }
.nsr-doc-empty { text-align: center; color: #aaa; font-style: italic; padding: 20px 0; font-size: 11px; }

/* Drop zone */
.nsr-drop-zone {
    border: 2px dashed #cdd8e6; padding: 22px 16px; text-align: center;
    cursor: pointer; transition: border-color .15s, background .15s; margin-bottom: 12px;
}
.nsr-drop-zone:hover, .nsr-drop-zone.dz-over { border-color: #174DA4; background: #eef5ff; }
.nsr-drop-zone p { margin: 4px 0; font-size: 11px; color: #777; }
.nsr-drop-zone .dz-icon { font-size: 30px; opacity: .35; line-height: 1; margin-bottom: 6px; }
.nsr-drop-zone strong { color: #174DA4; }
.nsr-doc-upload-row { display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap; margin-top: 8px; }
.nsr-doc-upload-row .nsr-group { margin-bottom: 0; }
.nsr-selected-file {
    flex: 1; min-width: 140px; font-size: 11px; font-weight: 600; color: #333;
    background: #f0f4fc; border: 1px solid #cdd8e6; padding: 6px 8px;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.nsr-upload-progress-wrap { height: 3px; background: #e0e5ed; margin-top: 8px; display: none; }
.nsr-upload-progress-bar  { height: 100%; background: #174DA4; width: 0; transition: width .2s; }
.nsr-upload-status { font-size: 11px; margin-top: 6px; min-height: 16px; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:HiddenField ID="hfReturnUrl" runat="server" />
<asp:HiddenField ID="hfEditRegNo" runat="server" />
<asp:HiddenField ID="hfEditEno"   runat="server" />
<!-- Safety-net hidden fields: JS copies dropdown values here before postback
     in case ASP.NET can't match them (e.g. programme filtered client-side) -->
<asp:HiddenField ID="hfProgramme" runat="server" />
<asp:HiddenField ID="hfSession" runat="server" />
<asp:HiddenField ID="hfCampus" runat="server" />
<asp:HiddenField ID="hfEntryYear" runat="server" />
<asp:HiddenField ID="hfBilling" runat="server" />
<asp:HiddenField ID="hfFaculty" runat="server" />
<asp:HiddenField ID="hfNationality" runat="server" />
<asp:HiddenField ID="hfSpecialisation" runat="server" />

<div class="nsr-page">

    <!-- ======= HEADER ================================================ -->
    <div class="nsr-header">
        <div>
            <h1>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
                <asp:Literal ID="litPageTitle" runat="server" Text="Register New Student" />
            </h1>
            <div class="nsr-sub"><asp:Literal ID="litPageSubtitle" runat="server" Text="Create a new student record, generate registration number, and optionally register &amp; bill immediately." /></div>
        </div>
        <a id="btnBackLink" href="javascript:history.back()" class="nsr-btn nsr-btn--ghost" style="color:#fff;border-color:rgba(255,255,255,.3);">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
            Back
        </a>
    </div>

    <!-- ======= FORM BODY ============================================= -->
    <div class="nsr-body" id="formContainer">

        <!-- Alert Area -->
        <div id="alertBox" runat="server" class="nsr-alert" visible="false">
            <asp:Literal ID="litAlert" runat="server" />
            <button type="button" class="nsr-alert__close" onclick="this.parentElement.style.display='none';">&times;</button>
        </div>

        <!-- -- 1. PERSONAL INFORMATION ------------------------------ -->
        <div class="nsr-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
            Personal Information
        </div>

        <%-- Hidden merged name field — JS combines the 3 visible name fields into this before postback --%>
        <asp:TextBox ID="txtFullName" runat="server" style="display:none;visibility:hidden;" MaxLength="100" />

        <%-- Name row: Title | Surname | First Name | Other Names --%>
        <div class="nsr-row-name">
            <div class="nsr-group">
                <label class="nsr-label">Title</label>
                <asp:DropDownList ID="ddlTitle" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="MR." Text="Mr." />
                    <asp:ListItem Value="MS." Text="Ms." />
                    <asp:ListItem Value="MRS." Text="Mrs." />
                    <asp:ListItem Value="DR." Text="Dr." />
                    <asp:ListItem Value="PROF." Text="Prof." />
                    <asp:ListItem Value="REV." Text="Rev." />
                </asp:DropDownList>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Surname / Family Name <span class="req">*</span></label>
                <asp:TextBox ID="txtSurname" runat="server" CssClass="nsr-input nsr-upper" placeholder="e.g. MUBIRU" MaxLength="30" />
                <div class="nsr-hint">As in national ID</div>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">First Name <span class="req">*</span></label>
                <asp:TextBox ID="txtFirstName" runat="server" CssClass="nsr-input nsr-upper" placeholder="e.g. JOHN" MaxLength="30" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Other Name(s)</label>
                <asp:TextBox ID="txtOtherName" runat="server" CssClass="nsr-input nsr-upper" placeholder="e.g. DOE" MaxLength="30" />
                <div class="nsr-hint">Middle name (optional)</div>
            </div>
        </div>

        <div class="nsr-row4">
            <div class="nsr-group">
                <label class="nsr-label">Gender <span class="req">*</span></label>
                <asp:DropDownList ID="ddlGender" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="M" Text="Male" />
                    <asp:ListItem Value="F" Text="Female" />
                    <asp:ListItem Value="OTHER" Text="Other" />
                </asp:DropDownList>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Date of Birth</label>
                <asp:TextBox ID="txtDOB" runat="server" CssClass="nsr-input" TextMode="Date" MaxLength="20" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Nationality</label>
                <asp:DropDownList ID="ddlNationality" runat="server" CssClass="nsr-select" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">National ID (NIN)</label>
                <asp:TextBox ID="txtNationalId" runat="server" CssClass="nsr-input nsr-upper" placeholder="e.g. CM98014800BQFL6" MaxLength="30" />
            </div>
        </div>

        <div class="nsr-row3">
            <div class="nsr-group">
                <label class="nsr-label">Phone <span class="req">*</span></label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="nsr-input" placeholder="e.g. 0772123456" MaxLength="60" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="nsr-input" placeholder="student@example.com" MaxLength="65" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Marital Status</label>
                <asp:DropDownList ID="ddlMarital" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="SINGLE" Text="Single" Selected="True" />
                    <asp:ListItem Value="MARRIED" Text="Married" />
                    <asp:ListItem Value="DIVORCED" Text="Divorced" />
                    <asp:ListItem Value="WIDOWED" Text="Widowed" />
                </asp:DropDownList>
            </div>
        </div>

        <div class="nsr-row3">
            <div class="nsr-group">
                <label class="nsr-label">Religion</label>
                <asp:DropDownList ID="ddlReligion" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="-" Text="&#8212; Not Specified &#8212;" />
                    <asp:ListItem Value="CATHOLIC" Text="Catholic" />
                    <asp:ListItem Value="PROTESTANT" Text="Protestant" />
                    <asp:ListItem Value="ANGLICAN" Text="Anglican" />
                    <asp:ListItem Value="MUSLIM" Text="Muslim" />
                    <asp:ListItem Value="BORN AGAIN" Text="Born Again" />
                    <asp:ListItem Value="ADVENTIST" Text="Adventist" />
                    <asp:ListItem Value="SDA" Text="SDA" />
                    <asp:ListItem Value="PENTACOSTAL" Text="Pentecostal" />
                    <asp:ListItem Value="ORTHODOX" Text="Orthodox" />
                    <asp:ListItem Value="OTHERS" Text="Others" />
                </asp:DropDownList>
            </div>
            <div class="nsr-group" style="grid-column:span 2;">
                <label class="nsr-label">Physical Disability</label>
                <asp:TextBox ID="txtDisability" runat="server" CssClass="nsr-input" placeholder="None or describe condition" MaxLength="150" />
                <div class="nsr-hint">Leave blank or write "None" if not applicable</div>
            </div>
        </div>

        <!-- -- 2. ACADEMIC DETAILS ---------------------------------- -->
        <div class="nsr-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"></path><path d="M6 12v5c3 3 9 3 12 0v-5"></path></svg>
            Academic Details
        </div>

        <div class="nsr-row2">
            <div class="nsr-group">
                <label class="nsr-label">Faculty / School</label>
                <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="nsr-select" onchange="onFacultyChange(this)" />
                <div class="nsr-hint">Narrows the programme list below. Leave on "All" to show all programmes.</div>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Programme <span class="req">*</span></label>
                <%-- Underlying DDL stays hidden — searchable select below drives it --%>
                <asp:DropDownList ID="ddlProgramme" runat="server" style="display:none;" />
                <div class="nsr-ss-wrap" id="ss-prog">
                    <button type="button" class="nsr-ss-trigger ph" onclick="ssToggle('ss-prog')">
                        <span class="nsr-ss-display">-- Select Programme --</span>
                        <svg class="nsr-ss-caret" xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="nsr-ss-drop">
                        <div class="nsr-ss-search-wrap">
                            <input type="text" class="nsr-ss-q" placeholder="&#128269; Type code or name to filter…" oninput="ssFilter('ss-prog',this.value)" autocomplete="off">
                        </div>
                        <div class="nsr-ss-opts"></div>
                        <div class="nsr-ss-footer" id="ss-prog-count"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="nsr-row2" id="specRow" style="display:none;">
            <div class="nsr-group">
                <label class="nsr-label">Specialisation / Major</label>
                <%-- Hidden DDL for postback --%>
                <asp:DropDownList ID="ddlSpecialisation" runat="server" style="display:none;" />
                <div class="nsr-ss-wrap" id="ss-spec">
                    <button type="button" class="nsr-ss-trigger ph" onclick="ssToggle('ss-spec')">
                        <span class="nsr-ss-display">-- None / Not Applicable --</span>
                        <svg class="nsr-ss-caret" xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="nsr-ss-drop">
                        <div class="nsr-ss-search-wrap">
                            <input type="text" class="nsr-ss-q" placeholder="&#128269; Filter specialisations…" oninput="ssFilter('ss-spec',this.value)" autocomplete="off">
                        </div>
                        <div class="nsr-ss-opts"></div>
                    </div>
                </div>
                <div class="nsr-hint">Filtered by selected programme. Leave blank if not applicable.</div>
            </div>
            <div class="nsr-group"></div>
        </div>

        <div class="nsr-row4">
            <div class="nsr-group">
                <label class="nsr-label">Study Session <span class="req">*</span></label>
                <asp:DropDownList ID="ddlSession" runat="server" CssClass="nsr-select" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Campus <span class="req">*</span></label>
                <asp:DropDownList ID="ddlCampus" runat="server" CssClass="nsr-select" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Entry Year <span class="req">*</span></label>
                <asp:DropDownList ID="ddlEntryYear" runat="server" CssClass="nsr-select" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Entry Method</label>
                <asp:DropDownList ID="ddlEntryMethod" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="DIRECT" Text="Direct" Selected="True" />
                    <asp:ListItem Value="A LEVEL" Text="A Level" />
                    <asp:ListItem Value="O LEVEL" Text="O Level" />
                    <asp:ListItem Value="DIPLOMA" Text="Diploma" />
                    <asp:ListItem Value="CERTIFICATE" Text="Certificate" />
                    <asp:ListItem Value="MATURE AGE" Text="Mature Age" />
                    <asp:ListItem Value="BACHELORS DEGREE" Text="Bachelor's Degree" />
                    <asp:ListItem Value="ACCESS" Text="Access" />
                    <asp:ListItem Value="SKILLING" Text="Skilling" />
                    <asp:ListItem Value="HIGHER EDUCATION CERTIFICATE(HEC)" Text="HEC" />
                </asp:DropDownList>
            </div>
        </div>

        <%-- Study Year is always Year 1 for new students — kept hidden for CS compatibility --%>
        <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="nsr-select" style="display:none;">
            <asp:ListItem Value="1" Text="Year 1" Selected="True" />
            <asp:ListItem Value="2" Text="Year 2" />
            <asp:ListItem Value="3" Text="Year 3" />
            <asp:ListItem Value="4" Text="Year 4" />
            <asp:ListItem Value="5" Text="Year 5" />
        </asp:DropDownList>

        <div class="nsr-row2">
            <div class="nsr-group">
                <label class="nsr-label">Intake <span class="req">*</span></label>
                <asp:DropDownList ID="ddlIntake" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="JANUARY" Text="January" />
                    <asp:ListItem Value="FEBRUARY" Text="February" />
                    <asp:ListItem Value="MARCH" Text="March" />
                    <asp:ListItem Value="APRIL" Text="April" />
                    <asp:ListItem Value="MAY" Text="May" />
                    <asp:ListItem Value="JUNE" Text="June" />
                    <asp:ListItem Value="JULY" Text="July" />
                    <asp:ListItem Value="AUGUST" Text="August" />
                    <asp:ListItem Value="SEPTEMBER" Text="September" />
                    <asp:ListItem Value="OCTOBER" Text="October" />
                    <asp:ListItem Value="NOVEMBER" Text="November" />
                    <asp:ListItem Value="DECEMBER" Text="December" />
                </asp:DropDownList>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Billing System <span class="req">*</span></label>
                <asp:DropDownList ID="ddlBilling" runat="server" CssClass="nsr-select" />
            </div>
        </div>

        <!-- -- 3. ADDRESS & CONTACT --------------------------------- -->
        <div class="nsr-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
            Address &amp; Contact
        </div>

        <div class="nsr-group">
            <label class="nsr-label">Physical Address</label>
            <asp:TextBox ID="txtAddress" runat="server" CssClass="nsr-input" placeholder="Street address or location" MaxLength="200" />
        </div>

        <div class="nsr-row3">
            <div class="nsr-group">
                <label class="nsr-label">Post Box</label>
                <asp:TextBox ID="txtPostBox" runat="server" CssClass="nsr-input" MaxLength="45" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Home District</label>
                <asp:TextBox ID="txtDistrict" runat="server" CssClass="nsr-input" Text="UGANDA" MaxLength="45" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Residence Country</label>
                <asp:TextBox ID="txtResCountry" runat="server" CssClass="nsr-input" Text="UGANDA" MaxLength="45" />
            </div>
        </div>

        <!-- -- 4. SPONSOR & NEXT OF KIN ----------------------------- -->
        <div class="nsr-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            Sponsor &amp; Next of Kin
        </div>

        <div class="nsr-row2">
            <div class="nsr-group">
                <label class="nsr-label">Sponsor Name</label>
                <asp:TextBox ID="txtSponsor" runat="server" CssClass="nsr-input" MaxLength="100" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Sponsor Contact</label>
                <asp:TextBox ID="txtSponsorContact" runat="server" CssClass="nsr-input" MaxLength="100" />
            </div>
        </div>

        <div class="nsr-row3">
            <div class="nsr-group">
                <label class="nsr-label">Next of Kin Name</label>
                <asp:TextBox ID="txtKinName" runat="server" CssClass="nsr-input" MaxLength="45" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Relationship</label>
                <asp:DropDownList ID="ddlKinRelation" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="" Text="&#8212; Select &#8212;" />
                    <asp:ListItem Value="FATHER" Text="Father" />
                    <asp:ListItem Value="MOTHER" Text="Mother" />
                    <asp:ListItem Value="BROTHER" Text="Brother" />
                    <asp:ListItem Value="SISTER" Text="Sister" />
                    <asp:ListItem Value="UNCLE" Text="Uncle" />
                    <asp:ListItem Value="AUNT" Text="Aunt" />
                    <asp:ListItem Value="GUARDIAN" Text="Guardian" />
                    <asp:ListItem Value="SPOUSE" Text="Spouse" />
                    <asp:ListItem Value="OTHER" Text="Other" />
                </asp:DropDownList>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Kin Contact</label>
                <asp:TextBox ID="txtKinContact" runat="server" CssClass="nsr-input" placeholder="Phone number" MaxLength="150" />
            </div>
        </div>

        <div class="nsr-row2">
            <div class="nsr-group">
                <label class="nsr-label">Referee Name</label>
                <asp:TextBox ID="txtRefereeName" runat="server" CssClass="nsr-input" MaxLength="100" placeholder="Full name of referee (optional)" />
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Referee Contact</label>
                <asp:TextBox ID="txtRefereeContact" runat="server" CssClass="nsr-input" MaxLength="100" placeholder="Phone or email (optional)" />
            </div>
        </div>

        <!-- -- 5. EDUCATION BACKGROUND -------------------------------- -->
        <div class="nsr-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
            Education Background <span style="font-size:9px;color:#aaa;font-weight:400;text-transform:none;letter-spacing:0;margin-left:6px;">(optional — fill what applies)</span>
        </div>

        <%-- O-Level / UCE --%>
        <div class="nsr-edu-block">
            <div class="nsr-edu-block-title">O&#8209;Level &nbsp;/&nbsp; UCE</div>
            <div class="nsr-row4">
                <div class="nsr-group">
                    <label class="nsr-label">School / Institution</label>
                    <asp:TextBox ID="txtOLevelSchool" runat="server" CssClass="nsr-input nsr-upper" MaxLength="150" placeholder="e.g. ST. MARY'S S.S.S." />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Index / Exam No.</label>
                    <asp:TextBox ID="txtOLevelIndex" runat="server" CssClass="nsr-input nsr-upper" MaxLength="45" placeholder="e.g. U0001/001" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Year of Completion</label>
                    <asp:TextBox ID="txtOLevelYear" runat="server" CssClass="nsr-input" MaxLength="4" placeholder="e.g. 2022" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Aggregate</label>
                    <asp:TextBox ID="txtOLevelAgg" runat="server" CssClass="nsr-input" MaxLength="20" placeholder="e.g. 23" />
                    <div class="nsr-hint">Total aggregate points</div>
                </div>
            </div>
        </div>

        <%-- A-Level / UACE --%>
        <div class="nsr-edu-block">
            <div class="nsr-edu-block-title">A&#8209;Level &nbsp;/&nbsp; UACE</div>
            <div class="nsr-row4">
                <div class="nsr-group">
                    <label class="nsr-label">School / Institution</label>
                    <asp:TextBox ID="txtALevelSchool" runat="server" CssClass="nsr-input nsr-upper" MaxLength="150" placeholder="e.g. ALLIANCE HIGH S.S." />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Index / Exam No.</label>
                    <asp:TextBox ID="txtALevelIndex" runat="server" CssClass="nsr-input nsr-upper" MaxLength="45" placeholder="e.g. U0001/001" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Year of Completion</label>
                    <asp:TextBox ID="txtALevelYear" runat="server" CssClass="nsr-input" MaxLength="4" placeholder="e.g. 2024" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Points</label>
                    <asp:TextBox ID="txtALevelPoints" runat="server" CssClass="nsr-input" MaxLength="20" placeholder="e.g. 16 or PPP" />
                    <div class="nsr-hint">Total points or principal passes</div>
                </div>
            </div>
        </div>

        <%-- Other Qualification (Diploma / Degree / Certificate etc.) --%>
        <div class="nsr-edu-block">
            <div class="nsr-edu-block-title">Other Qualification <span style="font-weight:400;color:#aaa;text-transform:none;letter-spacing:0;">(Diploma, Degree, Certificate, etc.)</span></div>
            <div class="nsr-row4">
                <div class="nsr-group">
                    <label class="nsr-label">Institution</label>
                    <asp:TextBox ID="txtOtherInst" runat="server" CssClass="nsr-input nsr-upper" MaxLength="150" placeholder="e.g. KYAMBOGO UNIVERSITY" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Qualification / Award</label>
                    <asp:TextBox ID="txtOtherQual" runat="server" CssClass="nsr-input nsr-upper" MaxLength="100" placeholder="e.g. DIPLOMA IN NURSING" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Year of Completion</label>
                    <asp:TextBox ID="txtOtherYear" runat="server" CssClass="nsr-input" MaxLength="4" placeholder="e.g. 2023" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">Grade / Class</label>
                    <asp:TextBox ID="txtOtherGrade" runat="server" CssClass="nsr-input nsr-upper" MaxLength="50" placeholder="e.g. SECOND UPPER" />
                </div>
            </div>
        </div>

        <!-- -- FOOTER ----------------------------------------------- -->
        <div class="nsr-footer">
            <div>
                <button type="button" class="nsr-btn nsr-btn--ghost" onclick="resetForm()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path></svg>
                    Reset Form
                </button>
            </div>
            <div style="display:flex;gap:8px;">
                <button type="button" class="nsr-btn nsr-btn--ghost" onclick="goBack()">Cancel</button>
                <asp:Button ID="btnSubmit" runat="server" CssClass="nsr-btn nsr-btn--success"
                    Text="Register Student"
                    OnClick="btnSubmitRegistration_Click"
                    OnClientClick="return syncBeforeSubmit();" />
            </div>
        </div>
    </div>

    <!-- ======= DOCUMENT MANAGEMENT (edit mode only) ================ -->
    <asp:Panel ID="pnlDocuments" runat="server" Visible="false">
    <div class="nsr-docs-panel">

        <div class="nsr-docs-header">
            <h2>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/></svg>
                Supporting Documents
            </h2>
            <span class="nsr-doc-count" id="docCountBadge">Loading…</span>
        </div>

        <div class="nsr-docs-body">

            <!-- Existing documents table -->
            <table class="nsr-doc-table" id="docTable">
                <thead>
                    <tr>
                        <th style="width:130px;">Type</th>
                        <th>File Name</th>
                        <th style="width:80px;">Size</th>
                        <th style="width:130px;">Uploaded</th>
                        <th style="width:110px;">Actions</th>
                    </tr>
                </thead>
                <tbody id="docTableBody">
                    <tr><td colspan="5" class="nsr-doc-empty" id="docLoadingRow">Loading documents…</td></tr>
                </tbody>
            </table>

            <!-- Upload new document -->
            <div class="nsr-section" style="margin-top:4px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 16 12 12 8 16"></polyline><line x1="12" y1="12" x2="12" y2="21"></line><path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3"></path></svg>
                Upload New Document
            </div>

            <%-- Drop zone — click or drag a file onto it --%>
            <div class="nsr-drop-zone" id="docDropZone" onclick="document.getElementById('docFileInput').click()">
                <div class="dz-icon">📎</div>
                <p>Drag &amp; drop a file here, or <strong>click to browse</strong></p>
                <p style="font-size:9px;color:#bbb;margin-top:2px;">Accepted: JPG · PNG · PDF &nbsp;·&nbsp; Max 50 MB</p>
            </div>
            <%-- No name attribute — must not be submitted with the main form --%>
            <input type="file" id="docFileInput" accept=".jpg,.jpeg,.png,.pdf" style="display:none;" />

            <div class="nsr-doc-upload-row">
                <div class="nsr-group">
                    <label class="nsr-label">Document Type <span class="req">*</span></label>
                    <select id="docTypeSelect" class="nsr-select" style="width:190px;">
                        <option value="">— Select Type —</option>
                        <option value="PHOTO">Passport Photo</option>
                        <option value="OLEVEL">O-Level Certificate (UCE)</option>
                        <option value="ALEVEL">A-Level Certificate (UACE)</option>
                        <option value="NATID">National ID / NIN</option>
                        <option value="PASSPORT">Passport</option>
                        <option value="TRANSCRIPT">Academic Transcript</option>
                        <option value="BIRTH_CERTIFICATE">Birth Certificate</option>
                        <option value="RECOMMENDATION">Recommendation Letter</option>
                        <option value="MEDICAL">Medical Report</option>
                        <option value="OTHER">Other Document</option>
                    </select>
                </div>
                <div class="nsr-group" style="flex:1;">
                    <label class="nsr-label">Selected File</label>
                    <div class="nsr-selected-file" id="docSelectedName">No file selected</div>
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">&nbsp;</label>
                    <button type="button" id="btnDocUpload" class="nsr-btn nsr-btn--primary" onclick="docUpload()" disabled="disabled">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="16 16 12 12 8 16"></polyline><line x1="12" y1="12" x2="12" y2="21"></line><path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3"></path></svg>
                        Upload
                    </button>
                </div>
            </div>

            <div class="nsr-upload-progress-wrap" id="docProgressWrap">
                <div class="nsr-upload-progress-bar" id="docProgressBar"></div>
            </div>
            <div class="nsr-upload-status" id="docUploadStatus"></div>

            <%-- One-time maintenance: consolidate all files to standard folder --%>
            <div style="margin-top:14px;padding-top:10px;border-top:1px solid #eef0f4;">
                <button type="button" class="nsr-btn nsr-btn--ghost" style="font-size:10px;" onclick="docConsolidate(this)"
                        title="Scan all documents and move any portal-uploaded files into the shared ApplyUploadPath folder. Safe to run multiple times.">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
                    Consolidate Document Files
                </button>
                <span id="docConsolidateStatus" style="font-size:10px;color:#888;margin-left:8px;"></span>
            </div>

        </div><%-- /nsr-docs-body --%>
    </div><%-- /nsr-docs-panel --%>
    </asp:Panel>

    <!-- ======= SUCCESS CARD (shown after registration) =============== -->
    <div class="nsr-result-card" id="successCard">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        <h3 id="successTitle">Student Registered Successfully!</h3>
        <div class="nsr-result-detail" id="successEntryNo"></div>
        <div class="nsr-result-detail" id="successRegNo"></div>
        <div class="nsr-result-detail" id="successExtra"></div>
        <div class="nsr-result-actions">
            <button type="button" class="nsr-btn nsr-btn--primary" id="btnSuccessAction" onclick="registerAnother()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                <asp:Literal ID="litSuccessActionText" runat="server" Text="Register Another Student" />
            </button>
            <a id="lnkViewStudent" href="#" class="nsr-btn nsr-btn--ghost">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                View Full Profile
            </a>
            <button type="button" id="btnDeleteStudent" onclick="deleteStudent()" class="nsr-btn" style="background:#c62828;color:#fff;border:none;display:none;">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"></path><path d="M10 11v6"></path><path d="M14 11v6"></path><path d="M9 6V4h6v2"></path></svg>
                Delete Student
            </button>
        </div>
    </div>
</div>

<!-- ======= JAVASCRIPT ================================================= -->
<script type="text/javascript">

// -- Programme / Specialisation data (server-rendered JSON) ----------
var allProgrammes     = <%= GetProgrammesJson() %>;
var allSpecialisations = <%= GetSpecialisationsJson() %>;

// ══════════════════════════════════════════════════════════════
//  SEARCHABLE SELECT ENGINE  (ss-*)
// ══════════════════════════════════════════════════════════════
var _ss = {};  // id → { items:[{v,t}], v, t, ph, onPick }

function ssSetItems(id, items, preserveVal) {
    var reg = _ss[id] = _ss[id] || { v: '', t: '', ph: '-- Select --', onPick: null };
    reg.items = items;
    if (preserveVal) {
        // keep current selection only if still valid in new list
        var ok = false;
        for (var i = 0; i < items.length; i++) { if (items[i].v === reg.v && items[i].v) { reg.t = items[i].t; ok = true; break; } }
        if (!ok) { reg.v = ''; reg.t = ''; }
    } else {
        reg.v = ''; reg.t = '';
    }
    ssUpdateTrigger(id);
    // Re-render list if panel is open
    var w = document.getElementById(id);
    if (w && w.classList.contains('ss-open')) {
        var q = w.querySelector('.nsr-ss-q'); ssRender(id, q ? q.value : '');
    }
}

function ssSetVal(id, v) {
    var reg = _ss[id];
    if (!reg) return;
    reg.v = ''; reg.t = '';
    if (v) { for (var i = 0; i < reg.items.length; i++) { if (reg.items[i].v === v) { reg.v = v; reg.t = reg.items[i].t; break; } } }
    ssUpdateTrigger(id);
}

function ssUpdateTrigger(id) {
    var w = document.getElementById(id); var reg = _ss[id];
    if (!w || !reg) return;
    var disp = w.querySelector('.nsr-ss-display');
    var trig = w.querySelector('.nsr-ss-trigger');
    if (disp) disp.textContent = reg.v ? reg.t : reg.ph;
    if (trig) { if (reg.v) trig.classList.remove('ph'); else trig.classList.add('ph'); }
}

function ssToggle(id) {
    var w = document.getElementById(id);
    if (!w) return;
    var isOpen = w.classList.contains('ss-open');
    // close all open
    document.querySelectorAll('.nsr-ss-wrap.ss-open').forEach(function(el) { el.classList.remove('ss-open'); });
    if (!isOpen) {
        w.classList.add('ss-open');
        var q = w.querySelector('.nsr-ss-q'); if (q) { q.value = ''; q.focus(); }
        ssRender(id, '');
    }
}

function ssFilter(id, q) { ssRender(id, q); }

function ssRender(id, q) {
    var w = document.getElementById(id); var reg = _ss[id];
    if (!w || !reg) return;
    var box = w.querySelector('.nsr-ss-opts'); if (!box) return;
    var qlo = (q || '').toLowerCase().trim();
    var items = reg.items || [];
    var flt = qlo ? items.filter(function(o) {
        return (o.t || '').toLowerCase().indexOf(qlo) >= 0 || (o.v || '').toLowerCase().indexOf(qlo) >= 0;
    }) : items;
    // Update count footer
    var ctr = document.getElementById(id + '-count');
    if (ctr) ctr.textContent = flt.length + ' option' + (flt.length === 1 ? '' : 's');
    if (!flt.length) { box.innerHTML = '<div class="nsr-ss-empty">No matches' + (qlo ? ' for &ldquo;' + escH(q) + '&rdquo;' : '') + '</div>'; return; }
    box.innerHTML = '';
    var cur = reg.v;
    var re  = qlo ? new RegExp('(' + qlo.replace(/[.*+?^${}()|[\]\\]/g,'\\$&') + ')', 'gi') : null;
    flt.forEach(function(o) {
        var d = document.createElement('div');
        d.className = 'nsr-ss-opt' + (!o.v ? ' ph' : '') + (o.v === cur ? ' sel' : '');
        if (re && o.v) {
            d.innerHTML = escH(o.t).replace(re, '<mark>$1</mark>');
        } else {
            d.textContent = o.t;
        }
        d.addEventListener('click', (function(val, txt) {
            return function() { ssPick(id, val, txt); };
        })(o.v, o.t));
        box.appendChild(d);
    });
    // Auto-scroll to selected item
    var sel = box.querySelector('.sel'); if (sel) sel.scrollIntoView({ block: 'nearest' });
}

function ssPick(id, v, t) {
    var reg = _ss[id]; if (!reg) return;
    reg.v = v; reg.t = t;
    ssUpdateTrigger(id);
    var w = document.getElementById(id); if (w) w.classList.remove('ss-open');
    if (reg.onPick) reg.onPick(v, t);
}

function escH(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

// Close on outside click / Escape
document.addEventListener('click', function(e) {
    if (!e.target.closest('.nsr-ss-wrap'))
        document.querySelectorAll('.nsr-ss-wrap.ss-open').forEach(function(el) { el.classList.remove('ss-open'); });
});
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape')
        document.querySelectorAll('.nsr-ss-wrap.ss-open').forEach(function(el) { el.classList.remove('ss-open'); });
});

// ══════════════════════════════════════════════════════════════
//  CASCADE HELPERS: Programme ↔ Specialisation
// ══════════════════════════════════════════════════════════════

function filterProgrammes(fac, ddlProg) {
    // Rebuild the hidden DDL (still needed for postback safety-net)
    if (ddlProg) {
        ddlProg.options.length = 0;
        ddlProg.options[ddlProg.options.length] = new Option('-- Select Programme --', '');
        var filtered = (fac === '' || fac === 'ALL') ? allProgrammes
            : allProgrammes.filter(function(p) { return p.f === fac; });
        for (var i = 0; i < filtered.length; i++)
            ddlProg.options[ddlProg.options.length] = new Option(filtered[i].c + ' — ' + filtered[i].n, filtered[i].c);
    }
    // Rebuild the programme searchable select
    var filtered2 = (!fac || fac === 'ALL') ? allProgrammes
        : allProgrammes.filter(function(p) { return p.f === fac; });
    var items = [{ v: '', t: '-- Select Programme --' }];
    filtered2.forEach(function(p) { items.push({ v: p.c, t: p.c + ' — ' + p.n }); });
    if (!_ss['ss-prog']) _ss['ss-prog'] = { v: '', t: '', ph: '-- Select Programme --', items: [], onPick: ssProgPick };
    ssSetItems('ss-prog', items, true);  // true = preserve valid selection across faculty changes
}

function filterSpecialisations(progCode, ddlSpec) {
    var specFiltered = progCode ? allSpecialisations.filter(function(s) { return s.p === progCode; }) : [];
    // Rebuild hidden DDL
    if (ddlSpec) {
        ddlSpec.options.length = 0;
        ddlSpec.options[ddlSpec.options.length] = new Option('-- None / Not Applicable --', '');
        specFiltered.forEach(function(s) { ddlSpec.options[ddlSpec.options.length] = new Option(s.n, s.id.toString()); });
    }
    // Show/hide specRow
    var specRow = document.getElementById('specRow');
    if (specRow) specRow.style.display = specFiltered.length > 0 ? '' : 'none';
    // Rebuild spec searchable select
    var items = [{ v: '', t: '-- None / Not Applicable --' }];
    specFiltered.forEach(function(s) { items.push({ v: s.id.toString(), t: s.n }); });
    if (!_ss['ss-spec']) _ss['ss-spec'] = { v: '', t: '', ph: '-- None / Not Applicable --', items: [], onPick: ssSpecPick };
    ssSetItems('ss-spec', items, true);
}

// Called when user picks from programme SS
function ssProgPick(v, t) {
    var ddlProg = document.getElementById('<%= ddlProgramme.ClientID %>');
    var hfProg  = document.getElementById('<%= hfProgramme.ClientID %>');
    if (ddlProg) { for (var i = 0; i < ddlProg.options.length; i++) { if (ddlProg.options[i].value === v) { ddlProg.selectedIndex = i; break; } } }
    if (hfProg) hfProg.value = v;
    // Cascade to specialisation
    var ddlSpec = document.getElementById('<%= ddlSpecialisation.ClientID %>');
    filterSpecialisations(v, ddlSpec);
    ssSetVal('ss-spec', '');  // clear spec selection on programme change
}

// Called when user picks from specialisation SS
function ssSpecPick(v, t) {
    var ddlSpec = document.getElementById('<%= ddlSpecialisation.ClientID %>');
    var hfSpec  = document.getElementById('<%= hfSpecialisation.ClientID %>');
    if (ddlSpec) { for (var i = 0; i < ddlSpec.options.length; i++) { if (ddlSpec.options[i].value === v) { ddlSpec.selectedIndex = i; break; } } }
    if (hfSpec) hfSpec.value = v;
}

// -- Cascading: Faculty → Programme ----------------------------------
function onFacultyChange(sel) {
    var ddlProg = document.getElementById('<%= ddlProgramme.ClientID %>');
    filterProgrammes(sel.value, ddlProg);
    var hfFac = document.getElementById('<%= hfFaculty.ClientID %>');
    if (hfFac) hfFac.value = sel.value;
    // Reset specialisation
    var ddlSpec = document.getElementById('<%= ddlSpecialisation.ClientID %>');
    filterSpecialisations('', ddlSpec);
    ssSetVal('ss-prog', '');
    ssSetVal('ss-spec', '');
}

// -- Initialise dropdowns on page load and restore saved values ------
(function initDropdowns() {
    var hfFac  = document.getElementById('<%= hfFaculty.ClientID %>');
    var hfProg = document.getElementById('<%= hfProgramme.ClientID %>');
    var hfSpec = document.getElementById('<%= hfSpecialisation.ClientID %>');
    var ddlFac = document.getElementById('<%= ddlFaculty.ClientID %>');
    var ddlProg = document.getElementById('<%= ddlProgramme.ClientID %>');
    var ddlSpec = document.getElementById('<%= ddlSpecialisation.ClientID %>');

    // Init SS registries with their pick callbacks
    _ss['ss-prog'] = { v: '', t: '', ph: '-- Select Programme --', items: [], onPick: ssProgPick };
    _ss['ss-spec'] = { v: '', t: '', ph: '-- None / Not Applicable --', items: [], onPick: ssSpecPick };

    // Restore faculty filter if saved
    var fac = (hfFac && hfFac.value) ? hfFac.value : '';
    if (fac && ddlFac) {
        for (var i = 0; i < ddlFac.options.length; i++) {
            if (ddlFac.options[i].value === fac) { ddlFac.selectedIndex = i; break; }
        }
    }

    // Build programme SS (filtered by faculty if saved)
    filterProgrammes(fac, ddlProg);

    // Restore programme selection
    var progVal = (hfProg && hfProg.value) ? hfProg.value : (ddlProg && ddlProg.selectedIndex > 0 ? ddlProg.options[ddlProg.selectedIndex].value : '');
    if (progVal) {
        if (ddlProg) { for (var j = 0; j < ddlProg.options.length; j++) { if (ddlProg.options[j].value === progVal) { ddlProg.selectedIndex = j; break; } } }
        ssSetVal('ss-prog', progVal);
        // Build spec list for this programme
        filterSpecialisations(progVal, ddlSpec);
    }

    // Restore specialisation selection
    var specVal = (hfSpec && hfSpec.value) ? hfSpec.value : (ddlSpec && ddlSpec.selectedIndex > 0 ? ddlSpec.options[ddlSpec.selectedIndex].value : '');
    if (specVal) {
        if (ddlSpec) { for (var k = 0; k < ddlSpec.options.length; k++) { if (ddlSpec.options[k].value === specVal) { ddlSpec.selectedIndex = k; break; } } }
        ssSetVal('ss-spec', specVal);
    }
})();

// -- Pre-submit sync: copy SS selections and name to server controls --
// Called via OnClientClick on the submit button. Returns true to allow submit.
function syncBeforeSubmit() {
    // Name: copy three visible fields into the hidden merged control
    var sur  = document.getElementById('<%= txtSurname.ClientID %>');
    var fst  = document.getElementById('<%= txtFirstName.ClientID %>');
    var oth  = document.getElementById('<%= txtOtherName.ClientID %>');
    var full = document.getElementById('<%= txtFullName.ClientID %>');
    if (full) {
        full.value = [sur  ? sur.value.trim().toUpperCase()  : '',
                      fst  ? fst.value.trim().toUpperCase()  : '',
                      oth  ? oth.value.trim().toUpperCase()  : '']
                     .filter(Boolean).join(' ');
    }
    // Programme SS → hidden DDL + hidden field
    if (_ss['ss-prog'] && _ss['ss-prog'].v) {
        var hfP = document.getElementById('<%= hfProgramme.ClientID %>');
        if (hfP) hfP.value = _ss['ss-prog'].v;
        var ddP = document.getElementById('<%= ddlProgramme.ClientID %>');
        if (ddP) for (var i = 0; i < ddP.options.length; i++)
            if (ddP.options[i].value === _ss['ss-prog'].v) { ddP.selectedIndex = i; break; }
    }
    // Specialisation SS → hidden DDL + hidden field
    if (_ss['ss-spec'] && _ss['ss-spec'].v) {
        var hfS = document.getElementById('<%= hfSpecialisation.ClientID %>');
        if (hfS) hfS.value = _ss['ss-spec'].v;
        var ddS = document.getElementById('<%= ddlSpecialisation.ClientID %>');
        if (ddS) for (var j = 0; j < ddS.options.length; j++)
            if (ddS.options[j].value === _ss['ss-spec'].v) { ddS.selectedIndex = j; break; }
    }
    // Sync standard dropdowns to hidden fields — DdlOrHidden() uses these as
    // fallback because ViewState is off: ASP.NET's first ProcessPostData pass
    // fires before Page_Load when the DDLs have no items yet, so selections
    // are lost before the second pass ever runs.
    [['<%= ddlSession.ClientID %>',     '<%= hfSession.ClientID %>'],
     ['<%= ddlCampus.ClientID %>',      '<%= hfCampus.ClientID %>'],
     ['<%= ddlEntryYear.ClientID %>',   '<%= hfEntryYear.ClientID %>'],
     ['<%= ddlBilling.ClientID %>',     '<%= hfBilling.ClientID %>'],
     ['<%= ddlNationality.ClientID %>', '<%= hfNationality.ClientID %>']
    ].forEach(function(pair) {
        var dd = document.getElementById(pair[0]);
        var hf = document.getElementById(pair[1]);
        if (dd && hf && dd.value) hf.value = dd.value;
    });
    return true; // allow native form submit
}

// -- Split a full name back into the three visible fields (edit mode load) --
function splitNameIntoFields(fullName) {
    var parts = (fullName || '').trim().split(/\s+/);
    var sur   = document.getElementById('<%= txtSurname.ClientID %>');
    var fst   = document.getElementById('<%= txtFirstName.ClientID %>');
    var oth   = document.getElementById('<%= txtOtherName.ClientID %>');
    if (sur) sur.value = parts[0] || '';
    if (fst) fst.value = parts[1] || '';
    if (oth) oth.value = parts.slice(2).join(' ');
}

// -- Show/hide alert (used by server-rendered error/success via ClientScript) --
function showAlert(msg, type) {
    var box = document.getElementById('<%= alertBox.ClientID %>');
    if (!box) return;
    box.className = 'nsr-alert nsr-alert--' + type;
    box.style.display = 'block';
    box.innerHTML = msg + '<button type="button" class="nsr-alert__close" onclick="this.parentElement.style.display=\'none\';">&times;</button>';
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// -- Reset form ------------------------------------------------------
function resetForm() {
    var inputs = document.querySelectorAll('.nsr-input');
    for (var i = 0; i < inputs.length; i++) {
        if (inputs[i].defaultValue !== undefined)
            inputs[i].value = inputs[i].defaultValue || '';
    }
    // Clear the three name fields explicitly
    var surEl = document.getElementById('<%= txtSurname.ClientID %>');
    var fstEl = document.getElementById('<%= txtFirstName.ClientID %>');
    var othEl = document.getElementById('<%= txtOtherName.ClientID %>');
    var fulEl = document.getElementById('<%= txtFullName.ClientID %>');
    if (surEl) surEl.value = '';
    if (fstEl) fstEl.value = '';
    if (othEl) othEl.value = '';
    if (fulEl) fulEl.value = '';

    // Reset dropdowns to first option
    var selects = document.querySelectorAll('.nsr-select');
    for (var j = 0; j < selects.length; j++) {
        selects[j].selectedIndex = 0;
    }
    // Reset searchable selects
    ssSetItems('ss-prog', [{ v:'', t:'-- Select Programme --' }]);
    ssSetItems('ss-spec', [{ v:'', t:'-- None / Not Applicable --' }]);
    if (document.getElementById('specRow')) document.getElementById('specRow').style.display = 'none';
    // Rebuild programme list (show all)
    filterProgrammes('', document.getElementById('<%= ddlProgramme.ClientID %>'));

    // Clear hidden fields
    var hfIds = ['<%= hfProgramme.ClientID %>','<%= hfSession.ClientID %>','<%= hfCampus.ClientID %>',
                 '<%= hfEntryYear.ClientID %>','<%= hfBilling.ClientID %>','<%= hfFaculty.ClientID %>',
                 '<%= hfNationality.ClientID %>','<%= hfSpecialisation.ClientID %>'];
    for (var h = 0; h < hfIds.length; h++) {
        var hf = document.getElementById(hfIds[h]);
        if (hf) hf.value = '';
    }

    // Hide alerts
    var box = document.getElementById('<%= alertBox.ClientID %>');
    if (box) box.style.display = 'none';

    // Reset defaults
    var dist = document.getElementById('<%= txtDistrict.ClientID %>');
    if (dist) dist.value = 'UGANDA';
    var res = document.getElementById('<%= txtResCountry.ClientID %>');
    if (res) res.value = 'UGANDA';
}

// -- On page load: split full name into the three visible fields -----
// (Runs on page load — edit mode: server sets txtFullName, split it into the three visible fields)
(function splitNameOnLoad() {
    var full = document.getElementById('<%= txtFullName.ClientID %>');
    if (full && full.value) splitNameIntoFields(full.value);
})();

// -- Go back ---------------------------------------------------------
function goBack() {
    var returnUrl = document.getElementById('<%= hfReturnUrl.ClientID %>');
    if (returnUrl && returnUrl.value) {
        window.location.href = returnUrl.value;
    } else {
        history.back();
    }
}

// -- Edit mode detection ----------------------------------------------
var isApplicantMode = (function() {
    var hf = document.getElementById('<%= hfEditEno.ClientID %>');
    return hf && hf.value && hf.value.length > 0;
}());
var isEditMode = (function() {
    var hf = document.getElementById('<%= hfEditRegNo.ClientID %>');
    return hf && hf.value && hf.value.length > 0;
})();

var backLink = document.getElementById('btnBackLink');
if (backLink) backLink.href = 'javascript:history.back()';

// -- Show success card -----------------------------------------------
function showSuccess(entryNo, regNo, registered) {
    var form = document.getElementById('formContainer');
    var card = document.getElementById('successCard');
    if (form) form.style.display = 'none';
    if (card) card.style.display = 'block';
    card.className = 'nsr-result-card show';

    var titleEl = document.getElementById('successTitle');
    var entryEl = document.getElementById('successEntryNo');
    var regEl   = document.getElementById('successRegNo');
    var extraEl = document.getElementById('successExtra');

    if (isEditMode) {
        if (titleEl) titleEl.innerText = 'Student Updated Successfully!';
        if (entryEl) entryEl.innerHTML = '<strong>Entry No:</strong> ' + entryNo;
        if (regEl) regEl.innerHTML = '<strong>Reg No:</strong> ' + regNo;
        if (extraEl) extraEl.innerHTML = '';
        var actionBtn = document.getElementById('btnSuccessAction');
        if (actionBtn) { actionBtn.innerHTML = 'Back to Student Record'; actionBtn.onclick = function() { history.back(); }; }
    } else {
        if (titleEl) titleEl.innerText = registered ? 'Student Registered & Billed!' : 'Student Record Created!';
        if (entryEl) entryEl.innerHTML = '<strong>Entry No:</strong> ' + entryNo;
        if (regEl) regEl.innerHTML = '<strong>Reg No:</strong> ' + regNo;
        if (extraEl) extraEl.innerHTML = registered ? 'Auto-billing has been applied for the first semester.' : 'Student has been created but not yet registered.';
    }

    var viewLink = document.getElementById('lnkViewStudent');
    if (viewLink && regNo && regNo !== '-') {
        viewLink.href = '/COOPERP/NewScreens/StudentProfile.aspx?regno=' + encodeURIComponent(regNo);
        viewLink.style.display = '';
    }

    // Store regno for delete action and show delete button
    var delBtn = document.getElementById('btnDeleteStudent');
    if (delBtn && regNo && regNo !== '-') {
        delBtn.setAttribute('data-regno', regNo);
        delBtn.style.display = '';
    }
}

// -- Show success for applicant edit mode ----------------------------
function showAppEditSuccess(eno, returnUrl) {
    var form = document.getElementById('formContainer');
    var card = document.getElementById('successCard');
    if (form) form.style.display = 'none';
    if (card) { card.style.display = 'block'; card.className = 'nsr-result-card show'; }

    var titleEl = document.getElementById('successTitle');
    var entryEl = document.getElementById('successEntryNo');
    var regEl   = document.getElementById('successRegNo');
    var extraEl = document.getElementById('successExtra');

    if (titleEl) titleEl.innerText = 'Application Updated Successfully!';
    if (entryEl) entryEl.innerHTML = '<strong>Entry No:</strong> ' + eno;
    if (regEl)   regEl.innerHTML   = '';
    if (extraEl) extraEl.innerHTML = 'All application data has been saved.';

    var actionBtn = document.getElementById('btnSuccessAction');
    if (actionBtn) {
        actionBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg> Back to Admissions';
        actionBtn.onclick = function() { window.location.href = returnUrl || 'AdmissionsController.aspx'; };
    }

    // Hide delete/view buttons (not relevant for applicant edits)
    var delBtn  = document.getElementById('btnDeleteStudent');
    var viewLink= document.getElementById('lnkViewStudent');
    if (delBtn)   delBtn.style.display   = 'none';
    if (viewLink) viewLink.style.display = 'none';

    // Auto-redirect after 1.8 seconds
    setTimeout(function() {
        window.location.href = returnUrl || 'AdmissionsController.aspx';
    }, 1800);
}

// -- Delete student --------------------------------------------------
function deleteStudent() {
    var btn = document.getElementById('btnDeleteStudent');
    if (!btn) return;
    var regno = btn.getAttribute('data-regno');
    if (!regno) return;
    if (!confirm('DELETE student ' + regno + '?\n\nThis will permanently remove the student record and cannot be undone.\nOnly proceed if the record was created in error.')) return;
    btn.disabled = true;
    btn.textContent = 'Deleting...';
    fetch('NewStudentRegistration.aspx?ajax=delete&regno=' + encodeURIComponent(regno), { method: 'GET' })
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (d.ok) {
                alert('Student ' + regno + ' has been deleted.');
                window.location.href = 'NewStudentRegistration.aspx';
            } else {
                alert('Delete failed: ' + (d.error || 'Unknown error'));
                btn.disabled = false;
                btn.textContent = 'Delete Student';
            }
        })
        .catch(function() {
            alert('Network error. Please try again.');
            btn.disabled = false;
            btn.textContent = 'Delete Student';
        });
}


// -- Register another ------------------------------------------------
function registerAnother() {
    window.location.href = 'NewStudentRegistration.aspx';
}

// ══════════════════════════════════════════════════════════════
//  DOCUMENT MANAGEMENT
//  Only active in edit/applicant mode (pnlDocuments is rendered
//  server-side only when _docEntryNo is non-empty).
// ══════════════════════════════════════════════════════════════

var docEntryNo  = '<%= GetDocEntryNo() %>';
var docPageBase = 'NewStudentRegistration.aspx';

var docTypeLabels = {
    PHOTO: 'Passport Photo', OLEVEL: 'O-Level (UCE)', ALEVEL: 'A-Level (UACE)',
    NATID: 'National ID', PASSPORT: 'Passport', TRANSCRIPT: 'Transcript',
    BIRTH_CERTIFICATE: 'Birth Cert.', RECOMMENDATION: 'Recommendation',
    MEDICAL: 'Medical', OTHER: 'Other'
};
var docTypeCss = {
    PHOTO: 'dt-photo', OLEVEL: 'dt-olevel', ALEVEL: 'dt-alevel',
    NATID: 'dt-natid', OTHER: 'dt-other'
};

// ── Helpers ─────────────────────────────────────────────────
function fmtSize(bytes) {
    if (bytes < 1024)    return bytes + ' B';
    if (bytes < 1048576) return Math.round(bytes / 1024) + ' KB';
    return (bytes / 1048576).toFixed(1) + ' MB';
}

// ── Load & render document list ──────────────────────────────
function docLoad() {
    if (!docEntryNo) return;
    var tbody = document.getElementById('docTableBody');
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="5" class="nsr-doc-empty">Loading…</td></tr>';

    fetch(docPageBase + '?ajax=docs_list&eno=' + encodeURIComponent(docEntryNo))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.ok) {
                tbody.innerHTML = '<tr><td colspan="5" class="nsr-doc-empty" style="color:#c62828;">Failed to load: ' + escH(data.error || '') + '</td></tr>';
                return;
            }
            docRender(data.docs);
        })
        .catch(function() {
            tbody.innerHTML = '<tr><td colspan="5" class="nsr-doc-empty" style="color:#c62828;">Network error loading documents.</td></tr>';
        });
}

function docRender(docs) {
    var tbody  = document.getElementById('docTableBody');
    var badge  = document.getElementById('docCountBadge');
    if (!tbody) return;
    if (badge) badge.textContent = docs.length + ' document' + (docs.length !== 1 ? 's' : '');

    if (!docs.length) {
        tbody.innerHTML = '<tr><td colspan="5" class="nsr-doc-empty">No documents uploaded yet.</td></tr>';
        return;
    }

    tbody.innerHTML = '';
    docs.forEach(function(doc) {
        var label  = docTypeLabels[doc.doc_type] || doc.doc_type;
        var css    = 'nsr-doc-type-badge ' + (docTypeCss[doc.doc_type] || '');
        var viewUrl = docPageBase + '?ajax=view_doc&id=' + doc.id + '&eno=' + encodeURIComponent(docEntryNo);
        var tr = document.createElement('tr');
        tr.setAttribute('data-doc-id', doc.id);
        tr.innerHTML =
            '<td><span class="' + css + '">' + escH(label) + '</span></td>' +
            '<td><span class="nsr-doc-filename" title="' + escH(doc.filename) + '">' + escH(doc.filename) + '</span></td>' +
            '<td style="color:#666;">' + escH(fmtSize(doc.size)) + '</td>' +
            '<td style="color:#666;font-size:10px;">' + escH(doc.uploaded_at) + '</td>' +
            '<td><div class="nsr-doc-actions">' +
            '<a href="' + viewUrl + '" target="_blank" class="nsr-doc-btn nsr-doc-btn--view">View</a>' +
            '<button type="button" class="nsr-doc-btn nsr-doc-btn--del" onclick="docDelete(' + doc.id + ',this)">Delete</button>' +
            '</div></td>';
        tbody.appendChild(tr);
    });
}

// ── Delete a document ────────────────────────────────────────
function docDelete(id, btn) {
    if (!confirm('Delete this document?\nThis will permanently remove the file and cannot be undone.')) return;
    btn.disabled = true;
    btn.textContent = '…';
    fetch(docPageBase + '?ajax=del_doc&id=' + id + '&eno=' + encodeURIComponent(docEntryNo))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.ok) {
                var row = document.querySelector('tr[data-doc-id="' + id + '"]');
                if (row) row.parentNode.removeChild(row);
                docLoad(); // refresh count badge
            } else {
                alert('Delete failed: ' + (data.error || 'Unknown error'));
                btn.disabled = false;
                btn.textContent = 'Delete';
            }
        })
        .catch(function() {
            alert('Network error. Please try again.');
            btn.disabled = false;
            btn.textContent = 'Delete';
        });
}

// ── Drag-and-drop + file input wiring ────────────────────────
var _docSelectedFile = null;

(function wireDocUpload() {
    var dropZone = document.getElementById('docDropZone');
    var fileInput = document.getElementById('docFileInput');
    if (!dropZone || !fileInput) return;

    fileInput.addEventListener('change', function() {
        if (this.files && this.files.length) docSetFile(this.files[0]);
    });

    dropZone.addEventListener('dragover', function(e) {
        e.preventDefault(); e.stopPropagation();
        dropZone.classList.add('dz-over');
    });
    dropZone.addEventListener('dragleave', function(e) {
        e.preventDefault(); e.stopPropagation();
        dropZone.classList.remove('dz-over');
    });
    dropZone.addEventListener('drop', function(e) {
        e.preventDefault(); e.stopPropagation();
        dropZone.classList.remove('dz-over');
        var files = e.dataTransfer ? e.dataTransfer.files : null;
        if (files && files.length) docSetFile(files[0]);
    });
})();

function docSetFile(file) {
    _docSelectedFile = file;
    var nameEl = document.getElementById('docSelectedName');
    var btn    = document.getElementById('btnDocUpload');
    var dz     = document.getElementById('docDropZone');
    if (nameEl) nameEl.textContent = file.name + '  (' + fmtSize(file.size) + ')';
    if (btn)    btn.disabled = false;
    if (dz)     dz.style.borderColor = '#174DA4';
    var st = document.getElementById('docUploadStatus');
    if (st) st.textContent = '';
}

// ── Upload via XHR (for progress) ────────────────────────────
function docUpload() {
    if (!_docSelectedFile) { alert('Please select or drop a file first.'); return; }
    var typeEl = document.getElementById('docTypeSelect');
    if (!typeEl || !typeEl.value) { alert('Please select a document type.'); return; }

    var fd = new FormData();
    fd.append('file', _docSelectedFile);
    fd.append('doc_type', typeEl.value);

    var btn     = document.getElementById('btnDocUpload');
    var progW   = document.getElementById('docProgressWrap');
    var progB   = document.getElementById('docProgressBar');
    var status  = document.getElementById('docUploadStatus');

    btn.disabled = true; btn.textContent = 'Uploading…';
    if (progW) progW.style.display = 'block';
    if (progB) progB.style.width = '0%';
    if (status) { status.textContent = ''; status.style.color = ''; }

    var xhr = new XMLHttpRequest();
    xhr.open('POST', docPageBase + '?ajax=upload_doc&eno=' + encodeURIComponent(docEntryNo));

    if (xhr.upload && progB) {
        xhr.upload.addEventListener('progress', function(e) {
            if (e.lengthComputable && progB)
                progB.style.width = Math.round(e.loaded / e.total * 100) + '%';
        });
    }

    xhr.onload = function() {
        if (progB) progB.style.width = '100%';
        try {
            var data = JSON.parse(xhr.responseText);
            if (data.ok) {
                if (status) {
                    status.style.color = '#15803d';
                    status.textContent = '✔  ' + data.doc.filename + ' uploaded successfully.';
                }
                // Reset form state
                _docSelectedFile = null;
                var fi = document.getElementById('docFileInput');
                if (fi) fi.value = '';
                var ns = document.getElementById('docSelectedName');
                if (ns) ns.textContent = 'No file selected';
                var dz = document.getElementById('docDropZone');
                if (dz) dz.style.borderColor = '';
                if (typeEl) typeEl.value = '';
                btn.textContent = 'Upload';
                // Refresh list
                docLoad();
            } else {
                if (status) { status.style.color = '#dc2626'; status.textContent = '✖  ' + (data.error || 'Upload failed.'); }
                btn.disabled = false; btn.textContent = 'Upload';
            }
        } catch (ex) {
            if (status) { status.style.color = '#dc2626'; status.textContent = '✖  Server error. Please try again.'; }
            btn.disabled = false; btn.textContent = 'Upload';
        }
        setTimeout(function() { if (progW) progW.style.display = 'none'; if (progB) progB.style.width = '0%'; }, 2000);
    };

    xhr.onerror = function() {
        if (status) { status.style.color = '#dc2626'; status.textContent = '✖  Network error. Please try again.'; }
        if (progW) progW.style.display = 'none';
        btn.disabled = false; btn.textContent = 'Upload';
    };

    xhr.send(fd);
}

// ── Bootstrap: load docs on page ready ───────────────────────
if (docEntryNo) {
    docLoad();
}

// ── Consolidate all document files into the standard folder ──
function docConsolidate(btn) {
    if (!confirm('Scan ALL documents and move any files that are not in the standard ApplyUploadPath folder.\n\nThis is safe to run multiple times. Continue?')) return;
    btn.disabled = true;
    btn.textContent = 'Consolidating…';
    var st = document.getElementById('docConsolidateStatus');
    if (st) st.textContent = 'Running…';
    fetch(docPageBase + '?ajax=consolidate_docs')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            btn.disabled = false;
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg> Consolidate Document Files';
            if (!d.ok) {
                if (st) { st.style.color = '#dc2626'; st.textContent = '✖ ' + (d.error || 'Failed.'); }
                return;
            }
            var msg = '✔ Done — moved: ' + d.moved + ', already ok: ' + d.already_ok + ', not found: ' + d.not_found;
            if (d.errors > 0) msg += ', errors: ' + d.errors;
            if (st) { st.style.color = d.errors > 0 ? '#d97706' : '#16a34a'; st.textContent = msg; }
            if (d.moved > 0) docLoad(); // refresh the doc list
        })
        .catch(function() {
            btn.disabled = false;
            if (st) { st.style.color = '#dc2626'; st.textContent = '✖ Network error.'; }
        });
}
</script>

</asp:Content>