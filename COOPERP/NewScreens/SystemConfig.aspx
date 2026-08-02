<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="SystemConfig.aspx.cs"
    Inherits="COOPERP_NewScreens_SystemConfig"
    Title="System Configuration - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===============================================================
   SYSTEM CONFIGURATION - page styles
   Follows the NewScreens design system (primary #174DA4, 13 px base)
   =============================================================== */

/* -- Page header ----------------------------------------------- */
.sys-page-header {
    display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 8px;
    padding: 14px 18px; background: #fff;
    border-bottom: 2px solid #174DA4; margin-bottom: 18px;
}
.sys-page-header__left { display: flex; align-items: center; gap: 10px; }
.sys-page-header__icon {
    width: 36px; height: 36px; background: #eef2fb; border-radius: 6px;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.sys-page-title   { font-size: 16px; font-weight: 700; color: #1a1a2e; }
.sys-page-sub     { font-size: 11px; color: #666; margin-top: 1px; }

/* -- Last-updated banner ---------------------------------------- */
.sys-updated-bar {
    display: flex; align-items: center; gap: 8px;
    padding: 8px 14px; background: #e8f0fe;
    border-left: 3px solid #174DA4; margin-bottom: 14px;
    font-size: 11px; color: #174DA4;
}

/* -- Section card ----------------------------------------------- */
.sys-card {
    background: #fff; border: 1px solid #e0e0e0;
    border-top: 3px solid #174DA4; margin-bottom: 18px;
}
.sys-card__header {
    display: flex; align-items: center; gap: 9px;
    padding: 10px 16px; background: #fafbfc;
    border-bottom: 1px solid #e0e0e0;
}
.sys-card__title { font-size: 13px; font-weight: 700; color: #1a1a2e; }
.sys-card__desc  { font-size: 11px; color: #888; margin-left: auto; }
.sys-card__body  { padding: 16px; }

/* -- Info notice ----------------------------------------------- */
.sys-notice {
    display: flex; align-items: flex-start; gap: 8px;
    padding: 9px 12px; background: #fffbea;
    border-left: 3px solid #f0b429; border-radius: 0;
    font-size: 11px; color: #7a4f00; margin-bottom: 14px;
    line-height: 1.5;
}

/* -- Form grid ------------------------------------------------- */
.sys-form-grid   { display: grid; grid-template-columns: repeat(2,1fr); gap: 14px; }
.sys-form-grid1  { display: grid; grid-template-columns: 1fr; gap: 14px; }
.sys-form-group  { display: flex; flex-direction: column; gap: 4px; }
.sys-form-group.sys-span2 { grid-column: span 2; }

.sys-label {
    font-size: 11px; font-weight: 600; color: #333;
    display: flex; align-items: center; gap: 5px;
}
.sys-label span.sys-opt { color: #999; font-size: 10px; }
.sys-hint { font-size: 10px; color: #999; margin-top: 2px; }

.sys-input, .sys-select {
    height: 32px; padding: 0 9px;
    border: 1px solid #d0d5dd; border-radius: 0;
    font-size: 12px; color: #1a1a2e; background: #fff;
    transition: border-color .15s;
    width: 100%; box-sizing: border-box;
}
.sys-input:focus, .sys-select:focus {
    outline: none; border-color: #174DA4;
    box-shadow: 0 0 0 2px rgba(23,77,164,.12);
}
.sys-input:disabled, .sys-input[readonly] {
    background: #f5f5f5; color: #999; cursor: default;
}
.sys-input--small { width: 100px; }
.sys-textarea {
    min-height: 80px; padding: 8px 9px;
    border: 1px solid #d0d5dd; border-radius: 0;
    font-size: 12px; color: #1a1a2e; background: #fff;
    font-family: inherit; resize: vertical;
    transition: border-color .15s;
    width: 100%; box-sizing: border-box;
}
.sys-textarea:focus {
    outline: none; border-color: #174DA4;
    box-shadow: 0 0 0 2px rgba(23,77,164,.12);
}

/* -- Toggle Controls ------------------------------------------- */
.sys-toggle-wrap {
    display: flex; align-items: center; gap: 10px;
}
.sys-toggle-switch {
    display: inline-flex; width: 44px; height: 24px;
    background: #d0d5dd; border-radius: 12px; cursor: pointer;
    position: relative; border: none; padding: 0; transition: background 0.2s;
}
.sys-toggle-switch.active { background: #28a745; }
.sys-toggle-switch::after {
    content: ''; position: absolute; width: 20px; height: 20px;
    background: #fff; border-radius: 50%; top: 2px; left: 2px;
    transition: left 0.2s;
}
.sys-toggle-switch.active::after { left: 22px; }
.sys-toggle-label { font-size: 11px; color: #666; }

/* -- Buttons --------------------------------------------------- */
.sys-actions {
    display: flex; align-items: center; justify-content: flex-end;
    gap: 10px; padding: 14px 18px;
    background: #fff; border-top: 1px solid #e0e0e0;
    position: sticky; bottom: 0; z-index: 20;
    box-shadow: 0 -2px 8px rgba(0,0,0,.07);
}
.sys-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 0 18px; height: 34px; font-size: 12px; font-weight: 600;
    border: none; cursor: pointer; border-radius: 0; white-space: nowrap;
    transition: background .15s, opacity .15s;
}
.sys-btn:disabled { opacity: .6; cursor: not-allowed; }
.sys-btn--primary { background: #174DA4; color: #fff; }
.sys-btn--primary:hover { background: #0f3a7d; }
.sys-btn--ghost   { background: #f5f5f5; color: #333; border: 1px solid #d0d5dd; }
.sys-btn--ghost:hover { background: #ebebeb; }

/* -- Result message ------------------------------------------- */
.sys-result {
    display: none; padding: 10px 14px;
    font-size: 12px; font-weight: 600; border-left: 4px solid;
    margin: 0 18px 14px; align-items: center; gap: 8px;
}
.sys-result--ok  { display: flex; background: #d4edda; border-color: #28a745; color: #155724; }
.sys-result--err { display: flex; background: #f8d7da; border-color: #dc3545; color: #721c24; }

/* -- Misc ------------------------------------------------------ */
.sys-suffix { font-size: 11px; color: #888; white-space: nowrap; align-self: center; padding: 0 4px; }
.sys-input-wrap { display: flex; align-items: center; gap: 4px; }

@media (max-width: 800px) {
    .sys-form-grid  { grid-template-columns: 1fr; }
    .sys-form-group.sys-span2 { grid-column: span 1; }
}
@media (max-width: 520px) {
    .sys-form-grid, .sys-form-grid1 { grid-template-columns: 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- -- Page Header ----------------------------------------------- -->
<div class="sys-page-header">
    <div class="sys-page-header__left">
        <div class="sys-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                 fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
            </svg>
        </div>
        <div>
            <div class="sys-page-title">System Configuration</div>
            <div class="sys-page-sub">Manage school details, application settings, and live support meeting configuration</div>
        </div>
    </div>
</div>

<!-- -- Last Updated Banner -------------------------------------- -->
<asp:Panel ID="pnlLastUpdated" runat="server" Visible="false" CssClass="sys-updated-bar">
    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
         fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <span><asp:Literal ID="litLastUpdated" runat="server" /></span>
</asp:Panel>

<!-- -- Result ---------------------------------------------------- -->
<div id="divResult" class="sys-result" runat="server">
    <asp:Literal ID="litResult" runat="server" />
</div>

<!-- ===========================================================
     SECTION 1 - SCHOOL IDENTITY
     =========================================================== -->
<div class="sys-card">
    <div class="sys-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/></svg>
        <span class="sys-card__title">School Identity</span>
        <span class="sys-card__desc">Institution information and branding</span>
    </div>
    <div class="sys-card__body">
        <div class="sys-notice">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;margin-top:1px">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            All fields are optional. The system uses default values if any field is left blank.
        </div>

        <div class="sys-form-grid">
            <div class="sys-form-group sys-span2">
                <label class="sys-label">School Name <span class="sys-opt">(optional)</span></label>
                <asp:TextBox ID="txtSchoolName" runat="server" CssClass="sys-input"
                    placeholder="e.g., Makerere University" />
                <span class="sys-hint">Leave blank to use default name (Makerere University)</span>
            </div>
            <div class="sys-form-group sys-span2">
                <label class="sys-label">School Logo URL <span class="sys-opt">(optional)</span></label>
                <asp:TextBox ID="txtSchoolLogo" runat="server" CssClass="sys-input"
                    placeholder="e.g., https://example.com/logo.png" />
                <span class="sys-hint">Full URL to school logo image. Leave blank to use default logo.</span>
            </div>
            <div class="sys-form-group sys-span2">
                <label class="sys-label">School Address <span class="sys-opt">(optional)</span></label>
                <asp:TextBox ID="txtSchoolAddress" runat="server" CssClass="sys-textarea"
                    placeholder="e.g., Kampala, Uganda" TextMode="MultiLine" />
                <span class="sys-hint">Full address including city and country</span>
            </div>
            <div class="sys-form-group">
                <label class="sys-label">School Phone <span class="sys-opt">(optional)</span></label>
                <asp:TextBox ID="txtSchoolPhone" runat="server" CssClass="sys-input"
                    placeholder="e.g., +256 414 531 000" />
                <span class="sys-hint">Contact phone number</span>
            </div>
            <div class="sys-form-group">
                <label class="sys-label">School Email <span class="sys-opt">(optional)</span></label>
                <asp:TextBox ID="txtSchoolEmail" runat="server" CssClass="sys-input" TextMode="Email"
                    placeholder="e.g., info@example.ac.ug" />
                <span class="sys-hint">Contact email address</span>
            </div>
        </div>
    </div>
</div>

<!-- ===========================================================
     SECTION 1b - COMMUNITY & LINKS
     =========================================================== -->
<div class="sys-card">
    <div class="sys-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>
        <span class="sys-card__title">Community &amp; Links</span>
        <span class="sys-card__desc">Links shown to students on the portal — update any time, no redeploy</span>
    </div>
    <div class="sys-card__body">
        <div class="sys-notice">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;margin-top:1px">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            The student portal's "Join the WhatsApp Group" button uses this link live. If left blank, the system keeps the current default so the button never breaks.
        </div>

        <div class="sys-form-grid">
            <div class="sys-form-group sys-span2">
                <label class="sys-label">Students' WhatsApp Group Link</label>
                <asp:TextBox ID="txtWhatsappUrl" runat="server" CssClass="sys-input"
                    placeholder="https://chat.whatsapp.com/xxxxxxxxxxxxxxxxxxxxxx" />
                <span class="sys-hint">Must be a WhatsApp invite link (https://chat.whatsapp.com/…). Get it from the group &rarr; Invite via link.</span>
            </div>
        </div>
    </div>
</div>

<!-- ===========================================================
     SECTION 2 - APPLICATION SETTINGS
     =========================================================== -->
<div class="sys-card">
    <div class="sys-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/></svg>
        <span class="sys-card__title">Application Settings</span>
        <span class="sys-card__desc">Configure application access and time windows</span>
    </div>
    <div class="sys-card__body">
        <div class="sys-notice">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;margin-top:1px">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Control application availability and define access periods. Settings can be modified at any time.
        </div>

        <div class="sys-form-grid">
            <div class="sys-form-group sys-span2">
                <label class="sys-label">Application Status <span class="sys-opt">(optional)</span></label>
                <asp:DropDownList ID="ddlAppStatus" runat="server" CssClass="sys-select">
                    <asp:ListItem Value="">Not Set (Default: Open)</asp:ListItem>
                    <asp:ListItem Value="Open">Open - Application is active</asp:ListItem>
                    <asp:ListItem Value="Closed">Closed - Application is not available</asp:ListItem>
                    <asp:ListItem Value="Pause">Paused - Temporary maintenance</asp:ListItem>
                </asp:DropDownList>
                <span class="sys-hint">Controls whether the application is accessible to users</span>
            </div>
            <div class="sys-form-group">
                <label class="sys-label">Application Start Date <span class="sys-opt">(optional)</span></label>
                <asp:TextBox ID="txtAppStartDate" runat="server" CssClass="sys-input" TextMode="Date" />
                <span class="sys-hint">When the application becomes available</span>
            </div>
            <div class="sys-form-group">
                <label class="sys-label">Application End Date <span class="sys-opt">(optional)</span></label>
                <asp:TextBox ID="txtAppEndDate" runat="server" CssClass="sys-input" TextMode="Date" />
                <span class="sys-hint">When the application expires or closes</span>
            </div>
        </div>
    </div>
</div>

<!-- ===========================================================
     SECTION 3 - LIVE SUPPORT MEETING
     =========================================================== -->
<div class="sys-card">
    <div class="sys-card__header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="#174DA4" stroke-width="2"><path d="M23 7l-7 5 7 5V7z"/>
            <rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>
        <span class="sys-card__title">Live Support Meeting</span>
        <span class="sys-card__desc">Configure live support meeting for students and users</span>
    </div>
    <div class="sys-card__body">
        <div class="sys-notice">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;margin-top:1px">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Enable live support meetings and provide meeting details. All fields are optional - if not configured, live support is disabled.
        </div>

        <div class="sys-form-grid sys-span2">
            <div class="sys-form-group sys-span2">
                <label class="sys-label">Enable Live Support Meetings</label>
                <div class="sys-toggle-wrap">
                    <button type="button" class="sys-toggle-switch" id="btnLiveSupportToggle" onclick="toggleLiveSupport()"></button>
                    <span class="sys-toggle-label" id="lblLiveSupportStatus">Disabled</span>
                </div>
                <asp:HiddenField ID="hfLiveSupportEnabled" runat="server" Value="false" />
                <span class="sys-hint">Turn on to enable live support meeting feature</span>
            </div>
        </div>

        <div id="divLiveSupportFields" style="display:none">
            <div class="sys-form-grid">
                <div class="sys-form-group">
                    <label class="sys-label">Meeting Start Time <span class="sys-opt">(optional)</span></label>
                    <asp:TextBox ID="txtMeetingStartTime" runat="server" CssClass="sys-input sys-input--small" 
                        placeholder="09:00" />
                    <span class="sys-hint">Format: HH:MM (24-hour)</span>
                </div>
                <div class="sys-form-group">
                    <label class="sys-label">Meeting End Time <span class="sys-opt">(optional)</span></label>
                    <asp:TextBox ID="txtMeetingEndTime" runat="server" CssClass="sys-input sys-input--small" 
                        placeholder="17:00" />
                    <span class="sys-hint">Format: HH:MM (24-hour)</span>
                </div>
            </div>
            <div class="sys-form-grid sys-span2">
                <div class="sys-form-group sys-span2">
                    <label class="sys-label">Meeting Link <span class="sys-opt">(optional)</span></label>
                    <asp:TextBox ID="txtMeetingLink" runat="server" CssClass="sys-input"
                        placeholder="e.g., https://zoom.us/j/123456789" />
                    <span class="sys-hint">URL to video conference or meeting platform</span>
                </div>
            </div>
            <div class="sys-form-grid sys-span2">
                <div class="sys-form-group sys-span2">
                    <label class="sys-label">Admin Message to Users <span class="sys-opt">(optional)</span></label>
                    <asp:TextBox ID="txtLiveSupportAdminMessage" runat="server" CssClass="sys-textarea"
                        TextMode="MultiLine" placeholder="e.g., Our support team is available to answer your questions. Please ensure your camera and microphone are working before joining." />
                    <span class="sys-hint">This message will appear to users before they join the live support meeting, e.g., 'Please ensure your camera is enabled' or 'We are here to help!'</span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- -- Sticky Save Bar ------------------------------------------- -->
<div class="sys-actions">
    <asp:Button ID="btnReset" runat="server" Text="Reset to Defaults" CssClass="sys-btn sys-btn--ghost"
        OnClick="btnReset_Click"
        OnClientClick="return confirm('Reset ALL settings to factory defaults? This cannot be undone.');" />
    <asp:Button ID="btnSave" runat="server" Text="Save Configuration" CssClass="sys-btn sys-btn--primary"
        OnClick="btnSave_Click" />
</div>

<script>
// -- Toggle live support meetings ----------------------------
function toggleLiveSupport() {
    var btn = document.getElementById('btnLiveSupportToggle');
    var hf = document.getElementById('<%= hfLiveSupportEnabled.ClientID %>');
    var lbl = document.getElementById('lblLiveSupportStatus');
    var fields = document.getElementById('divLiveSupportFields');
    
    if (btn.classList.contains('active')) {
        btn.classList.remove('active');
        hf.value = 'false';
        lbl.textContent = 'Disabled';
        fields.style.display = 'none';
    } else {
        btn.classList.add('active');
        hf.value = 'true';
        lbl.textContent = 'Enabled';
        fields.style.display = 'block';
    }
}

// -- Initialize on page load --------------------------------
(function() {
    var hf = document.getElementById('<%= hfLiveSupportEnabled.ClientID %>');
    if (hf && hf.value === 'true') {
        document.getElementById('btnLiveSupportToggle').classList.add('active');
        document.getElementById('lblLiveSupportStatus').textContent = 'Enabled';
        document.getElementById('divLiveSupportFields').style.display = 'block';
    }
})();
</script>

</asp:Content>
