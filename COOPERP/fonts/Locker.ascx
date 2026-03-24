<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Locker.ascx.cs" Inherits="COOPERP_fonts_Locker" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html,body{height:100%;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif}

/* ── Full-page shell ── */
.ntl-lock{
    position:fixed;inset:0;display:flex;z-index:99999;
    background:#06111f;
}

/* ── Animated background orbs ── */
.ntl-orbs{position:absolute;inset:0;overflow:hidden;pointer-events:none}
.ntl-orb{
    position:absolute;border-radius:50%;filter:blur(80px);opacity:.18;
    animation:orbFloat 12s ease-in-out infinite alternate;
}
.ntl-orb-1{width:520px;height:520px;background:#039DE1;top:-120px;left:-100px;animation-delay:0s}
.ntl-orb-2{width:380px;height:380px;background:#039DE1;bottom:-80px;right:-60px;animation-delay:-4s}
.ntl-orb-3{width:260px;height:260px;background:#0270a0;top:40%;left:40%;animation-delay:-8s;opacity:.1}
@keyframes orbFloat{
    0%{transform:translate(0,0) scale(1)}
    100%{transform:translate(30px,20px) scale(1.08)}
}

/* ── Left brand panel ── */
.ntl-left{
    flex:0 0 420px;display:flex;flex-direction:column;justify-content:space-between;
    padding:40px 36px;position:relative;z-index:1;
    border-right:1px solid rgba(3,157,225,.18);
}
.ntl-left::before{
    content:'';position:absolute;inset:0;
    background:linear-gradient(160deg,rgba(3,157,225,.12) 0%,rgba(3,157,225,.04) 60%,transparent 100%);
    pointer-events:none;
}

/* Logo / brand */
.ntl-logo-wrap{display:flex;align-items:center;gap:12px}
.ntl-logo-icon{
    width:44px;height:44px;background:#039DE1;display:flex;align-items:center;justify-content:center;
    flex-shrink:0;position:relative;
}
.ntl-logo-icon::after{
    content:'';position:absolute;inset:-3px;
    border:1px solid rgba(3,157,225,.4);
}
.ntl-brand-name{color:#fff;font-size:13px;font-weight:800;line-height:1.2;letter-spacing:.3px}
.ntl-brand-tagline{color:rgba(3,157,225,.8);font-size:10px;margin-top:2px;letter-spacing:.5px;text-transform:uppercase}

/* Lock animation */
.ntl-lock-anim{
    flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;
    gap:20px;padding:30px 0;
}
.ntl-lock-ring{
    width:110px;height:110px;border-radius:50%;
    border:2px solid rgba(3,157,225,.25);
    display:flex;align-items:center;justify-content:center;
    position:relative;animation:ringPulse 2.4s ease-in-out infinite;
}
.ntl-lock-ring::before{
    content:'';position:absolute;inset:-10px;border-radius:50%;
    border:1px solid rgba(3,157,225,.12);animation:ringPulse 2.4s ease-in-out infinite .6s;
}
@keyframes ringPulse{
    0%,100%{box-shadow:0 0 0 0 rgba(3,157,225,.3)}
    50%{box-shadow:0 0 0 18px rgba(3,157,225,0)}
}
.ntl-lock-icon-inner{
    width:74px;height:74px;background:rgba(3,157,225,.12);border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    border:2px solid rgba(3,157,225,.4);
}
.ntl-expired-badge{
    background:rgba(3,157,225,.1);border:1px solid rgba(3,157,225,.3);
    padding:5px 16px;color:#039DE1;font-size:10px;font-weight:700;
    letter-spacing:2px;text-transform:uppercase;text-align:center;
}
.ntl-expired-msg{color:rgba(255,255,255,.55);font-size:11px;text-align:center;line-height:1.6;max-width:220px}

/* Contacts */
.ntl-contacts{display:flex;flex-direction:column;gap:8px}
.ntl-contacts-title{
    color:rgba(3,157,225,.7);font-size:9px;text-transform:uppercase;
    letter-spacing:1px;font-weight:700;padding-bottom:6px;
    border-bottom:1px solid rgba(3,157,225,.15);margin-bottom:4px;
}
.ntl-contact{display:flex;align-items:center;gap:10px}
.ntl-contact__dot{
    width:28px;height:28px;background:rgba(3,157,225,.1);border:1px solid rgba(3,157,225,.25);
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
}
.ntl-contact__info{min-width:0}
.ntl-contact__label{font-size:9px;color:rgba(255,255,255,.35);text-transform:uppercase;letter-spacing:.4px}
.ntl-contact__val{font-size:11px;color:rgba(255,255,255,.85);font-weight:600;white-space:nowrap}
.ntl-contact__val a{color:#039DE1;text-decoration:none}
.ntl-contact__val a:hover{color:#5fcaee}

/* Footer bottom */
.ntl-left-footer{
    color:rgba(255,255,255,.2);font-size:9px;text-align:center;
    border-top:1px solid rgba(255,255,255,.06);padding-top:12px;margin-top:8px;
}
.ntl-left-footer a{color:rgba(3,157,225,.6);text-decoration:none}

/* ── Right content panel ── */
.ntl-right{
    flex:1;display:flex;flex-direction:column;overflow-y:auto;
    position:relative;z-index:1;background:rgba(255,255,255,.97);
}

/* Top accent bar */
.ntl-right-accent{
    height:4px;
    background:linear-gradient(90deg,#039DE1 0%,#5fcaee 50%,#039DE1 100%);
    background-size:200% 100%;animation:accentSlide 3s linear infinite;
    flex-shrink:0;
}
@keyframes accentSlide{0%{background-position:0% 0}100%{background-position:200% 0}}

.ntl-right-inner{flex:1;padding:36px 40px;display:flex;flex-direction:column;gap:22px}

/* Status header */
.ntl-status-header{display:flex;align-items:flex-start;gap:14px}
.ntl-status-icon{
    width:48px;height:48px;background:#fff0f0;border:2px solid #fca5a5;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
}
.ntl-status-title{font-size:22px;font-weight:800;color:#1a1a2e;line-height:1.1;margin-bottom:4px}
.ntl-status-sub{font-size:12px;color:#666;line-height:1.5}
.ntl-status-sub strong{color:#039DE1}

/* Notice */
.ntl-notice{
    background:linear-gradient(135deg,#f0faff 0%,#e6f6fd 100%);
    border:1px solid #bae6f8;border-left:4px solid #039DE1;
    padding:14px 16px;font-size:12px;color:#1a4a5c;line-height:1.7;
}

/* Contact cards (mobile-only / right side on small screens) */
.ntl-right-contacts{display:none}

/* Activation box */
.ntl-activate{
    background:#f8fffe;border:1px solid #c0e8f6;border-top:3px solid #039DE1;
    padding:18px;
}
.ntl-activate__label{
    font-size:10px;text-transform:uppercase;letter-spacing:.7px;
    color:#039DE1;font-weight:700;margin-bottom:10px;display:flex;align-items:center;gap:6px;
}
.ntl-activate__row{display:flex;gap:0}
.ntl-activate__input{
    flex:1;padding:10px 14px;border:1px solid #c0e8f6;border-right:none;
    font-size:12px;outline:none;background:#fff;color:#1a1a2e;
    letter-spacing:1px;transition:border-color .2s;
}
.ntl-activate__input:focus{border-color:#039DE1;box-shadow:0 0 0 3px rgba(3,157,225,.12)}
.ntl-activate__input::placeholder{letter-spacing:0;color:#bbb;font-size:11px}
.ntl-activate__btn{
    padding:10px 20px;background:#039DE1;color:#fff;
    border:none;font-size:11px;font-weight:800;cursor:pointer;
    text-transform:uppercase;letter-spacing:.8px;transition:background .2s;
    white-space:nowrap;
}
.ntl-activate__btn:hover{background:#027ab0}
.ntl-activate__btn:active{background:#015f8a}

.ntl-feedback{margin-top:8px;font-size:11px;min-height:18px;padding:0 2px}
.ntl-feedback--err{color:#dc2626;display:flex;align-items:center;gap:5px}
.ntl-feedback--ok{color:#16a34a;font-weight:700;display:flex;align-items:center;gap:5px}

/* Copyright strip at bottom of right panel */
.ntl-right-footer{
    flex-shrink:0;padding:10px 40px;background:#f5f8fc;border-top:1px solid #e8eef6;
    display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:4px;
}
.ntl-right-footer__copy{font-size:10px;color:#999}
.ntl-right-footer__copy strong{color:#039DE1}
.ntl-right-footer__addr{font-size:9px;color:#bbb;text-align:right}

/* ── RESPONSIVE ── */
@media(max-width:900px){
    .ntl-lock{flex-direction:column;overflow-y:auto;overflow-x:hidden}
    .ntl-left{
        flex:none;width:100%;padding:20px;border-right:none;
        border-bottom:1px solid rgba(3,157,225,.18);
    }
    .ntl-lock-anim{padding:16px 0;flex-direction:row;flex-wrap:wrap;justify-content:center}
    .ntl-lock-ring{width:70px;height:70px}
    .ntl-lock-icon-inner{width:46px;height:46px}
    .ntl-lock-ring::before{inset:-6px}
    .ntl-contacts{display:none}   /* contacts move to right panel on mobile */
    .ntl-right-contacts{display:flex;flex-direction:column;gap:8px}
    .ntl-right-inner{padding:20px}
    .ntl-right-footer{padding:10px 20px}
    .ntl-left-footer{display:none}
}
@media(max-width:480px){
    .ntl-status-title{font-size:18px}
    .ntl-activate__btn{padding:10px 12px;font-size:10px}
    .ntl-right-footer{flex-direction:column;align-items:flex-start}
    .ntl-right-footer__addr{text-align:left}
}
</style>

<div class="ntl-lock">

    <!-- Background orbs -->
    <div class="ntl-orbs">
        <div class="ntl-orb ntl-orb-1"></div>
        <div class="ntl-orb ntl-orb-2"></div>
        <div class="ntl-orb ntl-orb-3"></div>
    </div>

    <!-- ══ LEFT BRAND PANEL ══ -->
    <div class="ntl-left">

        <!-- Logo -->
        <div class="ntl-logo-wrap">
            <div class="ntl-logo-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24"
                     fill="none" stroke="#fff" stroke-width="2.2">
                    <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
                </svg>
            </div>
            <div>
                <div class="ntl-brand-name">Newline Technologies<br/>Limited</div>
                <div class="ntl-brand-tagline">Software &amp; Systems</div>
            </div>
        </div>

        <!-- Animated lock -->
        <div class="ntl-lock-anim">
            <div class="ntl-lock-ring">
                <div class="ntl-lock-icon-inner">
                    <svg xmlns="http://www.w3.org/2000/svg" width="30" height="30" viewBox="0 0 24 24"
                         fill="none" stroke="#039DE1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                </div>
            </div>
            <div class="ntl-expired-badge">Access Suspended</div>
            <div class="ntl-expired-msg">
                Your institution's software license has expired.<br/>
                Please contact us to restore access.
            </div>
        </div>

        <!-- Contact details (desktop) -->
        <div>
            <div class="ntl-contacts">
                <div class="ntl-contacts-title">Reach Us — Restore Access Now</div>

                <div class="ntl-contact">
                    <div class="ntl-contact__dot">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"
                             fill="none" stroke="#039DE1" stroke-width="2">
                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.37 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.6a16 16 0 0 0 6 6l1.8-1.8a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/>
                        </svg>
                    </div>
                    <div class="ntl-contact__info">
                        <span class="ntl-contact__label">Office</span>
                        <span class="ntl-contact__val"><a href="tel:+256414581765">+256-414-581765</a></span>
                    </div>
                </div>

                <div class="ntl-contact">
                    <div class="ntl-contact__dot">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"
                             fill="none" stroke="#039DE1" stroke-width="2">
                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.37 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.6a16 16 0 0 0 6 6l1.8-1.8a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/>
                        </svg>
                    </div>
                    <div class="ntl-contact__info">
                        <span class="ntl-contact__label">CEO / WhatsApp</span>
                        <span class="ntl-contact__val"><a href="tel:+256772851937">+256-772-851937</a></span>
                    </div>
                </div>

                <div class="ntl-contact">
                    <div class="ntl-contact__dot">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"
                             fill="none" stroke="#039DE1" stroke-width="2">
                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.37 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.6a16 16 0 0 0 6 6l1.8-1.8a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/>
                        </svg>
                    </div>
                    <div class="ntl-contact__info">
                        <span class="ntl-contact__label">Business Dev</span>
                        <span class="ntl-contact__val"><a href="tel:+256704888512">+256-704-888512</a></span>
                    </div>
                </div>

                <div class="ntl-contact">
                    <div class="ntl-contact__dot">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"
                             fill="none" stroke="#039DE1" stroke-width="2">
                            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                            <polyline points="22,6 12,13 2,6"/>
                        </svg>
                    </div>
                    <div class="ntl-contact__info">
                        <span class="ntl-contact__label">Email</span>
                        <span class="ntl-contact__val"><a href="mailto:info@ntl.co.ug">info@ntl.co.ug</a></span>
                    </div>
                </div>

                <div class="ntl-contact">
                    <div class="ntl-contact__dot">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"
                             fill="none" stroke="#039DE1" stroke-width="2">
                            <circle cx="12" cy="12" r="10"/>
                            <line x1="2" y1="12" x2="22" y2="12"/>
                            <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
                        </svg>
                    </div>
                    <div class="ntl-contact__info">
                        <span class="ntl-contact__label">Website</span>
                        <span class="ntl-contact__val"><a href="https://ntl.co.ug/" target="_blank">www.ntl.co.ug</a></span>
                    </div>
                </div>

            </div>

            <div class="ntl-left-footer">
                Wildlife Tower, 1st Floor, Kanjokya St, Kampala &mdash;
                <a href="https://ntl.co.ug/" target="_blank">ntl.co.ug</a>
            </div>
        </div>

    </div>
    <!-- /left -->

    <!-- ══ RIGHT CONTENT PANEL ══ -->
    <div class="ntl-right">
        <div class="ntl-right-accent"></div>

        <div class="ntl-right-inner">

            <!-- Status header -->
            <div class="ntl-status-header">
                <div class="ntl-status-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                         fill="none" stroke="#ef4444" stroke-width="2.2">
                        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                        <line x1="12" y1="9" x2="12" y2="13"/>
                        <line x1="12" y1="17" x2="12.01" y2="17"/>
                    </svg>
                </div>
                <div>
                    <div class="ntl-status-title">Software License Expired</div>
                    <div class="ntl-status-sub">
                        Access to <strong>Campus Dynamics ERP</strong> has been suspended for your institution.
                    </div>
                </div>
            </div>

            <!-- Notice -->
            <div class="ntl-notice">
                <strong>Dear Valued Client,</strong><br/>
                Your Campus Dynamics software license has expired and all system access — including
                staff portals, student portals, and administrative modules — has been temporarily
                suspended. Please contact <strong>Newline Technologies Limited</strong> as soon as
                possible to renew your license and restore full access for your institution.
                We are available and ready to assist you promptly.
            </div>

            <!-- Mobile-only contacts -->
            <div class="ntl-right-contacts">
                <div class="ntl-contacts-title" style="font-size:9px;text-transform:uppercase;letter-spacing:.8px;color:#039DE1;font-weight:700;border-bottom:1px solid #e0f4fc;padding-bottom:6px;margin-bottom:4px;">
                    Contact Newline Technologies
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
                    <div style="background:#f0faff;border:1px solid #bae6f8;padding:8px 10px;font-size:11px;">
                        <div style="font-size:9px;color:#888;text-transform:uppercase;letter-spacing:.4px;">Office</div>
                        <a href="tel:+256414581765" style="color:#039DE1;font-weight:600;text-decoration:none;">+256-414-581765</a>
                    </div>
                    <div style="background:#f0faff;border:1px solid #bae6f8;padding:8px 10px;font-size:11px;">
                        <div style="font-size:9px;color:#888;text-transform:uppercase;letter-spacing:.4px;">CEO</div>
                        <a href="tel:+256772851937" style="color:#039DE1;font-weight:600;text-decoration:none;">+256-772-851937</a>
                    </div>
                    <div style="background:#f0faff;border:1px solid #bae6f8;padding:8px 10px;font-size:11px;">
                        <div style="font-size:9px;color:#888;text-transform:uppercase;letter-spacing:.4px;">Email</div>
                        <a href="mailto:info@ntl.co.ug" style="color:#039DE1;font-weight:600;text-decoration:none;">info@ntl.co.ug</a>
                    </div>
                    <div style="background:#f0faff;border:1px solid #bae6f8;padding:8px 10px;font-size:11px;">
                        <div style="font-size:9px;color:#888;text-transform:uppercase;letter-spacing:.4px;">Website</div>
                        <a href="https://ntl.co.ug/" target="_blank" style="color:#039DE1;font-weight:600;text-decoration:none;">ntl.co.ug</a>
                    </div>
                </div>
            </div>

            <!-- Activation -->
            <div class="ntl-activate">
                <div class="ntl-activate__label">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                         fill="none" stroke="#039DE1" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    Enter Renewal Code to Restore Access
                </div>
                <div class="ntl-activate__row">
                    <asp:TextBox ID="txtLicenseCode" runat="server"
                        CssClass="ntl-activate__input"
                        placeholder="Paste your activation / renewal code here..." />
                    <asp:Button ID="cmdActivate" runat="server"
                        Text="Activate" CssClass="ntl-activate__btn"
                        OnClick="cmdActivate_Click" />
                </div>
                <div class="ntl-feedback">
                    <asp:Label ID="lbl_comment" runat="server" />
                </div>
            </div>

        </div><!-- /right-inner -->

        <!-- Right footer -->
        <div class="ntl-right-footer">
            <div class="ntl-right-footer__copy">
                &copy; <%=DateTime.Today.Year %> <strong>Newline Technologies Limited</strong> &mdash;
                Campus Dynamics ERP
            </div>
            <div class="ntl-right-footer__addr">
                Wildlife Tower, 1st Floor, Kanjokya Street, Kampala &nbsp;|&nbsp; P.O Box 149725, Uganda
            </div>
        </div>

    </div><!-- /right -->

</div><!-- /ntl-lock -->

<!-- Hidden legacy control kept for code-behind compatibility -->
<asp:Label ID="lbl_lock" runat="server" style="display:none;" />
