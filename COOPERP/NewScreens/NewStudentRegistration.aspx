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
.nsr-row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.nsr-row3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
.nsr-row4 { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 10px; }
.nsr-row-title { display: grid; grid-template-columns: 110px 1fr; gap: 10px; }

/* -- Form controls --------------------------------- */
.nsr-group { margin-bottom: 8px; }
.nsr-label {
    display: block; font-size: 10px; text-transform: uppercase;
    letter-spacing: .4px; color: #555; font-weight: 600; margin-bottom: 4px;
}
.nsr-label .req { color: #dc3545; margin-left: 2px; }
.nsr-input, .nsr-select {
    width: 100%; padding: 6px 8px; border: 1px solid #cdd8e6; border-radius: 6px;
    font-size: 12px; box-sizing: border-box; background: #fff;
    transition: border-color .15s;
}
.nsr-input:focus, .nsr-select:focus {
    border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.10);
}
.nsr-input:disabled, .nsr-select:disabled { background: #f5f5f5; color: #999; }
.nsr-hint { font-size: 9px; color: #888; margin-top: 2px; }
.nsr-textarea { min-height: 60px; resize: vertical; }

/* -- Checkbox -------------------------------------- */
.nsr-check-label {
    display: flex; align-items: center; gap: 8px; cursor: pointer;
    font-size: 13px; font-weight: 600; color: #333; padding: 8px 0;
}
.nsr-check-label input[type="checkbox"] { width: 16px; height: 16px; }

/* -- Footer ---------------------------------------- */
.nsr-footer {
    display: flex; justify-content: space-between; align-items: center;
    padding: 10px 0 0; border-top: 1px solid #e4e8f0; margin-top: 12px;
}
.nsr-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 7px 12px; border-radius: 6px; font-size: 12px; font-weight: 600;
    border: none; cursor: pointer; transition: all .15s;
}
.nsr-btn--primary { background: #174DA4; color: #fff; }
.nsr-btn--primary:hover { background: #1557b7; }
.nsr-btn--success { background: #00695c; color: #fff; }
.nsr-btn--success:hover { background: #00796b; }
.nsr-btn--ghost { background: transparent; color: #555; border: 1px solid #ccc; }
.nsr-btn--ghost:hover { background: #f5f5f5; }
.nsr-btn:disabled { opacity: .55; cursor: not-allowed; }

/* -- Alert bar ------------------------------------- */
.nsr-alert {
    display: none; padding: 8px 10px; border-radius: 6px;
    font-size: 12px; margin: 8px 0; position: relative;
}
.nsr-alert--err { background: #fdecea; color: #b91c1c; border-left: 4px solid #dc3545; display: block; }
.nsr-alert--ok  { background: #e6f4ea; color: #155724; border-left: 4px solid #28a745; display: block; }
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
    border: 1px solid #a5d6a7; border-radius: 6px; padding: 14px 16px;
    text-align: center; display: none;
}
.nsr-result-card.show { display: block; }
.nsr-result-card h3 { color: #2e7d32; margin: 8px 0; font-size: 16px; }
.nsr-result-card .nsr-result-detail { font-size: 13px; color: #333; margin: 4px 0; }
.nsr-result-actions { display: flex; gap: 10px; justify-content: center; margin-top: 16px; }

/* -- Responsive ------------------------------------ */
@media (max-width: 768px) {
    .nsr-row2, .nsr-row3, .nsr-row4, .nsr-row-title { grid-template-columns: 1fr; }
    .nsr-body { padding: 12px; }
    .nsr-header { padding: 10px 12px; }
    .nsr-footer { flex-direction: column; gap: 10px; }
}

.nsr-ajax-progress {
    position: fixed;
    right: 14px;
    bottom: 14px;
    z-index: 99999;
    background: #05275C;
    color: #fff;
    border-radius: 6px;
    padding: 7px 10px;
    font-size: 11px;
    box-shadow: 0 6px 20px rgba(2,8,23,.25);
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:ScriptManagerProxy ID="smProxyNewStudentReg" runat="server" />

<asp:UpdatePanel ID="upNewStudentRegistration" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
<ContentTemplate>

<!-- Hidden postback triggers -->
<asp:Button ID="btnSubmitRegistration" runat="server" style="display:none;" OnClick="btnSubmitRegistration_Click" />
<asp:HiddenField ID="hfReturnUrl" runat="server" />
<asp:HiddenField ID="hfEditRegNo" runat="server" />
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

        <div class="nsr-row-title">
            <div class="nsr-group">
                <label class="nsr-label">Title</label>
                <asp:DropDownList ID="ddlTitle" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="MR." Text="MR." />
                    <asp:ListItem Value="MS." Text="MS." />
                    <asp:ListItem Value="MRS." Text="MRS." />
                </asp:DropDownList>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Full Name <span class="req">*</span></label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="nsr-input" placeholder="e.g. MUBIRU JOHN DOE" MaxLength="45" style="text-transform:uppercase;" />
                <div class="nsr-hint">Enter as: SURNAME FIRSTNAME MIDDLENAME (all uppercase)</div>
            </div>
        </div>

        <div class="nsr-row3">
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
        </div>

        <div class="nsr-row3">
            <div class="nsr-group">
                <label class="nsr-label">National ID (NIN)</label>
                <asp:TextBox ID="txtNationalId" runat="server" CssClass="nsr-input" placeholder="e.g. CM98014800BQFL6" MaxLength="30" style="text-transform:uppercase;" />
            </div>
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

        <div class="nsr-row2">
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
            <div class="nsr-group">
                <label class="nsr-label">Physical Disability</label>
                <asp:TextBox ID="txtDisability" runat="server" CssClass="nsr-input" placeholder="None" MaxLength="150" />
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
                <div class="nsr-hint">Filter programmes by selecting a faculty first, or leave on "All" to see every programme.</div>
            </div>
            <div class="nsr-group">
                <label class="nsr-label">Programme <span class="req">*</span></label>
                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="nsr-select" onchange="onProgrammeChange(this)" />
            </div>
        </div>

        <div class="nsr-row2" id="specRow">
            <div class="nsr-group">
                <label class="nsr-label">Specialisation</label>
                <asp:DropDownList ID="ddlSpecialisation" runat="server" CssClass="nsr-select" />
                <div class="nsr-hint">Specialisations are filtered by the selected programme. Leave blank if none apply.</div>
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

        <div class="nsr-row3">
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
            <div class="nsr-group">
                <label class="nsr-label">Study Year</label>
                <asp:DropDownList ID="ddlStudyYear" runat="server" CssClass="nsr-select">
                    <asp:ListItem Value="1" Text="Year 1" Selected="True" />
                    <asp:ListItem Value="2" Text="Year 2" />
                    <asp:ListItem Value="3" Text="Year 3" />
                    <asp:ListItem Value="4" Text="Year 4" />
                    <asp:ListItem Value="5" Text="Year 5" />
                </asp:DropDownList>
                <div class="nsr-hint">Default is Year 1 for new students.</div>
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

        <!-- -- 5. EDUCATION BACKGROUND -------------------------------- -->
        <div class="nsr-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
            Education Background <span style="font-size:9px;color:#888;font-weight:400;text-transform:none;letter-spacing:0;margin-left:6px;">(optional)</span>
        </div>
        <div>
            <div class="nsr-row2">
                <div class="nsr-group">
                    <label class="nsr-label">O-Level School</label>
                    <asp:TextBox ID="txtOLevelSchool" runat="server" CssClass="nsr-input" MaxLength="150" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">O-Level Index No</label>
                    <asp:TextBox ID="txtOLevelIndex" runat="server" CssClass="nsr-input" MaxLength="45" />
                </div>
            </div>
            <div class="nsr-row2">
                <div class="nsr-group">
                    <label class="nsr-label">A-Level School</label>
                    <asp:TextBox ID="txtALevelSchool" runat="server" CssClass="nsr-input" MaxLength="150" />
                </div>
                <div class="nsr-group">
                    <label class="nsr-label">A-Level Index No</label>
                    <asp:TextBox ID="txtALevelIndex" runat="server" CssClass="nsr-input" MaxLength="45" />
                </div>
            </div>
        </div>

        <!-- -- 6. REGISTRATION OPTIONS ------------------------------ -->
        <asp:Panel ID="pnlRegistrationOptions" runat="server">
        <div class="nsr-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            Registration Options
        </div>

        <div class="nsr-group">
            <label class="nsr-check-label">
                <asp:CheckBox ID="chkRegisterNow" runat="server" Checked="true" />
                Register student immediately upon creation
            </label>
            <div class="nsr-hint">If checked, the student will be marked as REGISTERED and auto-billed for their first semester.</div>
        </div>
        </asp:Panel>

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
                <button type="button" id="btnSubmit" class="nsr-btn nsr-btn--success" onclick="submitRegistration()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
                    <asp:Literal ID="litSubmitBtnText" runat="server" Text="Register Student" />
                </button>
            </div>
        </div>
    </div>

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
                View Student Record
            </a>
        </div>
    </div>
</div>

</ContentTemplate>
<Triggers>
    <asp:AsyncPostBackTrigger ControlID="btnSubmitRegistration" EventName="Click" />
</Triggers>
</asp:UpdatePanel>

<asp:UpdateProgress ID="upgNewStudentRegistration" runat="server" AssociatedUpdatePanelID="upNewStudentRegistration" DisplayAfter="100">
<ProgressTemplate>
    <div class="nsr-ajax-progress"><span class="nsr-loading"></span> Saving student record...</div>
</ProgressTemplate>
</asp:UpdateProgress>

<!-- ======= JAVASCRIPT ================================================= -->
<script type="text/javascript">

// -- Programme data cache (loaded from server on page load) ----------
var allProgrammes = <%= GetProgrammesJson() %>;
var allSpecialisations = <%= GetSpecialisationsJson() %>;

// -- On page load: apply faculty filter and restore programme selection --
(function initDropdowns() {
    // If there's a saved faculty value (from hidden field on postback), filter programmes
    var hfFac  = document.getElementById('<%= hfFaculty.ClientID %>');
    var hfProg = document.getElementById('<%= hfProgramme.ClientID %>');
    var ddlFac = document.getElementById('<%= ddlFaculty.ClientID %>');
    var ddlProg = document.getElementById('<%= ddlProgramme.ClientID %>');

    if (hfFac && hfFac.value && ddlFac) {
        // Set faculty dropdown to saved value
        for (var i = 0; i < ddlFac.options.length; i++) {
            if (ddlFac.options[i].value === hfFac.value) { ddlFac.selectedIndex = i; break; }
        }
        // Filter programmes by that faculty
        filterProgrammes(hfFac.value, ddlProg);
    }

    // Restore saved programme selection
    if (hfProg && hfProg.value && ddlProg) {
        for (var j = 0; j < ddlProg.options.length; j++) {
            if (ddlProg.options[j].value === hfProg.value) { ddlProg.selectedIndex = j; break; }
        }
    }

    // Restore specialisation cascade from programme
    var hfSpec = document.getElementById('<%= hfSpecialisation.ClientID %>');
    var ddlSpec = document.getElementById('<%= ddlSpecialisation.ClientID %>');
    if (hfProg && hfProg.value) {
        filterSpecialisations(hfProg.value, ddlSpec);
    }
    // Restore saved specialisation selection
    if (hfSpec && hfSpec.value && ddlSpec) {
        for (var k = 0; k < ddlSpec.options.length; k++) {
            if (ddlSpec.options[k].value === hfSpec.value) { ddlSpec.selectedIndex = k; break; }
        }
    }
})();

// -- Cascading: Faculty → Programme ----------------------------------
function onFacultyChange(sel) {
    var ddlProg = document.getElementById('<%= ddlProgramme.ClientID %>');
    filterProgrammes(sel.value, ddlProg);
    // Reset specialisation when faculty changes
    var ddlSpec = document.getElementById('<%= ddlSpecialisation.ClientID %>');
    filterSpecialisations('', ddlSpec);
}

// -- Cascading: Programme → Specialisation ---------------------------
function onProgrammeChange(sel) {
    var ddlSpec = document.getElementById('<%= ddlSpecialisation.ClientID %>');
    filterSpecialisations(sel.value, ddlSpec);
}

function filterSpecialisations(progCode, ddlSpec) {
    if (!ddlSpec) return;
    ddlSpec.options.length = 0;
    ddlSpec.options[ddlSpec.options.length] = new Option('-- None / Not Applicable --', '');
    if (!progCode) return;
    var filtered = allSpecialisations.filter(function(s) { return s.p === progCode; });
    for (var i = 0; i < filtered.length; i++) {
        ddlSpec.options[ddlSpec.options.length] = new Option(filtered[i].n, filtered[i].id.toString());
    }
    // Show/hide the row based on whether specialisations exist for this programme
    var specRow = document.getElementById('specRow');
    if (specRow) specRow.style.display = filtered.length > 0 ? '' : 'none';
}

function filterProgrammes(fac, ddlProg) {
    if (!ddlProg) return;

    // Clear current options
    ddlProg.options.length = 0;
    ddlProg.options[ddlProg.options.length] = new Option('-- Select Programme --', '');

    var filtered = (fac === '' || fac === 'ALL')
        ? allProgrammes
        : allProgrammes.filter(function(p) { return p.f === fac; });

    for (var i = 0; i < filtered.length; i++) {
        ddlProg.options[ddlProg.options.length] = new Option(
            filtered[i].c + ' - ' + filtered[i].n,
            filtered[i].c
        );
    }
}

// -- Client-side validation ------------------------------------------
function validateForm() {
    var errors = [];
    var fullName = document.getElementById('<%= txtFullName.ClientID %>');
    var phone    = document.getElementById('<%= txtPhone.ClientID %>');
    var prog     = document.getElementById('<%= ddlProgramme.ClientID %>');
    var session  = document.getElementById('<%= ddlSession.ClientID %>');
    var campus   = document.getElementById('<%= ddlCampus.ClientID %>');
    var entryYr  = document.getElementById('<%= ddlEntryYear.ClientID %>');
    var billing  = document.getElementById('<%= ddlBilling.ClientID %>');

    if (!fullName || !fullName.value.trim()) errors.push('Full Name is required.');
    else if (fullName.value.trim().indexOf(' ') < 0) errors.push('Please enter at least two names (SURNAME FIRSTNAME).');
    if (!phone || !phone.value.trim()) errors.push('Phone number is required.');
    if (!prog || !prog.value) errors.push('Please select a Programme.');
    if (!session || !session.value) errors.push('Please select a Study Session.');
    if (!campus || !campus.value) errors.push('Please select a Campus.');
    if (!entryYr || !entryYr.value) errors.push('Please select an Entry Year.');
    if (!billing || !billing.value) errors.push('Please select a Billing System.');

    // DOB validation (if given)
    var dob = document.getElementById('<%= txtDOB.ClientID %>');
    if (dob && dob.value) {
        var d = new Date(dob.value);
        if (isNaN(d.getTime())) errors.push('Invalid Date of Birth format.');
        else if (d > new Date()) errors.push('Date of Birth cannot be in the future.');
    }

    // Email format
    var email = document.getElementById('<%= txtEmail.ClientID %>');
    if (email && email.value.trim()) {
        var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!re.test(email.value.trim())) errors.push('Invalid email address format.');
    }

    return errors;
}

// -- Submit registration ---------------------------------------------
function submitRegistration() {
    var errors = validateForm();
    if (errors.length > 0) {
        showAlert(errors.join('<br/>'), 'err');
        window.scrollTo({ top: 0, behavior: 'smooth' });
        return;
    }

    // Disable button, show spinner
    var btn = document.getElementById('btnSubmit');
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<span class="nsr-loading"></span> Registering...';
    }

    // Force uppercase on name
    var nameEl = document.getElementById('<%= txtFullName.ClientID %>');
    if (nameEl) nameEl.value = nameEl.value.toUpperCase();

    // Copy dropdown values to hidden fields (safety net for ViewState-off postback)
    copyToHidden('<%= ddlProgramme.ClientID %>',    '<%= hfProgramme.ClientID %>');
    copyToHidden('<%= ddlSession.ClientID %>',      '<%= hfSession.ClientID %>');
    copyToHidden('<%= ddlCampus.ClientID %>',       '<%= hfCampus.ClientID %>');
    copyToHidden('<%= ddlEntryYear.ClientID %>',    '<%= hfEntryYear.ClientID %>');
    copyToHidden('<%= ddlBilling.ClientID %>',      '<%= hfBilling.ClientID %>');
    copyToHidden('<%= ddlFaculty.ClientID %>',      '<%= hfFaculty.ClientID %>');
    copyToHidden('<%= ddlNationality.ClientID %>',  '<%= hfNationality.ClientID %>');
    copyToHidden('<%= ddlSpecialisation.ClientID %>','<%= hfSpecialisation.ClientID %>');

    // Trigger postback
    document.getElementById('<%= btnSubmitRegistration.ClientID %>').click();
}

// Helper: copy a dropdown's current value into a hidden field
function copyToHidden(ddlId, hfId) {
    var ddl = document.getElementById(ddlId);
    var hf  = document.getElementById(hfId);
    if (ddl && hf) hf.value = ddl.value;
}

// -- Show/hide alert -------------------------------------------------
function showAlert(msg, type) {
    var box = document.getElementById('<%= alertBox.ClientID %>');
    if (!box) return;
    box.className = 'nsr-alert nsr-alert--' + type;
    box.style.display = 'block';
    box.innerHTML = msg + '<button type="button" class="nsr-alert__close" onclick="this.parentElement.style.display=\'none\';">&times;</button>';
}

// -- Reset form ------------------------------------------------------
function resetForm() {
    var inputs = document.querySelectorAll('.nsr-input');
    for (var i = 0; i < inputs.length; i++) {
        if (inputs[i].defaultValue !== undefined)
            inputs[i].value = inputs[i].defaultValue || '';
    }
    // Reset dropdowns to first option
    var selects = document.querySelectorAll('.nsr-select');
    for (var j = 0; j < selects.length; j++) {
        selects[j].selectedIndex = 0;
    }
    // Reset programme dropdown via faculty cascade (show all)
    var facDdl = document.getElementById('<%= ddlFaculty.ClientID %>');
    if (facDdl) { facDdl.selectedIndex = 0; onFacultyChange(facDdl); }

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
var isEditMode = (function() {
    var hf = document.getElementById('<%= hfEditRegNo.ClientID %>');
    return hf && hf.value && hf.value.length > 0;
})();

if (isEditMode) {
    var btn = document.getElementById('btnSubmit');
    if (btn) {
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg> ' + document.getElementById('<%= litSubmitBtnText.ClientID %>').innerHTML;
    }
    var backLink = document.getElementById('btnBackLink');
    if (backLink) backLink.href = 'javascript:history.back()';
}

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
        viewLink.href = 'StudentProfile.aspx?regno=' + encodeURIComponent(regNo);
        viewLink.style.display = '';
    }
}

// -- Re-enable submit button after error ----------------------------
function reEnableSubmit() {
    var btn = document.getElementById('btnSubmit');
    if (!btn) return;
    btn.disabled = false;
    if (isEditMode) {
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg> Update Student';
    } else {
        btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg> Register Student';
    }
}

// -- Register another ------------------------------------------------
function registerAnother() {
    window.location.href = 'NewStudentRegistration.aspx';
}
</script>

</asp:Content>