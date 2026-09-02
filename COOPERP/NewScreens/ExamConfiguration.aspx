<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ExamConfiguration.aspx.cs" Inherits="COOPERP_NewScreens_ExamConfiguration" Title="Examination Configuration - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--ok:#1c7a45;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}
.xc-head{background:#fff;border-bottom:1px solid var(--bdr);padding:20px 28px;}
.xc-head h1{font-size:18px;font-weight:700;color:var(--txt);margin:0;}
.xc-head p{font-size:12px;color:var(--muted);margin:3px 0 0;max-width:760px;line-height:1.55;}
.xc-wrap{padding:20px 28px 44px;}
.xc-note{display:flex;gap:10px;align-items:flex-start;background:#eef4ff;border:1px solid #c5d8f7;border-left:4px solid var(--brand);
    padding:11px 13px;font-size:12px;color:#1a4da4;line-height:1.55;margin:0 0 18px;}
.xc-note svg{width:16px;height:16px;flex:0 0 auto;margin-top:1px;}
.xc-note b{color:var(--brand-dk);}

.xc-grp{margin:0 0 22px;}
.xc-grp__t{font-size:11px;font-weight:800;color:var(--brand-dk);text-transform:uppercase;letter-spacing:.5px;margin:0 0 9px;}
.xc-card{background:#fff;border:1px solid var(--bdr);border-radius:4px;}
.xc-row{display:flex;gap:14px;align-items:flex-start;padding:13px 15px;border-bottom:1px solid #f1f5f9;}
.xc-row:last-child{border-bottom:none;}
.xc-row__main{flex:1;min-width:0;}
.xc-row__t{font-size:13px;font-weight:600;color:var(--txt);}
.xc-row__h{font-size:11.5px;color:var(--muted);line-height:1.55;margin-top:2px;}
.xc-row__ctl{flex:0 0 auto;display:flex;align-items:center;gap:8px;}
.xc-val{border:1px solid var(--bdr);height:32px;font-size:12px;padding:0 9px;font-family:inherit;background:#fff;min-width:88px;}
.xc-mini{background:#eef1f6;border:1px solid var(--bdr);color:var(--brand-dk);font-size:11px;font-weight:600;padding:6px 10px;cursor:pointer;}
.xc-mini:hover{border-color:var(--brand);}

/* overrides under a setting */
.xc-ovs{padding:0 15px 12px 15px;display:flex;flex-wrap:wrap;gap:6px;}
.xc-ov{display:inline-flex;align-items:center;gap:7px;background:#fff8e1;border:1px solid #f0dfa8;color:#6b5200;font-size:11px;padding:4px 9px;}
.xc-ov b{color:#7a4f00;}
.xc-ov__x{background:none;border:none;color:#b3261e;cursor:pointer;font-size:14px;line-height:1;padding:0 0 0 3px;}
.xc-ov--global{background:var(--surf);border-color:var(--bdr);color:var(--muted);}
.xc-ov--global b{color:var(--txt);}

.xc-btn{display:inline-flex;align-items:center;gap:6px;border:0;padding:8px 14px;font-size:12px;font-weight:600;cursor:pointer;font-family:inherit;}
.xc-btn--p{background:var(--brand-dk);color:#fff;} .xc-btn--p:hover{background:var(--brand);}
.xc-btn--g{background:#fff;color:var(--brand-dk);border:1px solid var(--bdr);}

/* "what is in force" panel */
.xc-eff{background:#fff;border:1px solid var(--bdr);border-radius:4px;padding:15px;margin:0 0 20px;}
.xc-eff__t{font-size:12.5px;font-weight:700;color:var(--brand-dk);margin:0 0 3px;}
.xc-eff__s{font-size:11.5px;color:var(--muted);margin:0 0 11px;line-height:1.5;}
.xc-eff__f{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end;}
.xc-fld{display:flex;flex-direction:column;gap:3px;}
.xc-fld label{font-size:10px;color:var(--muted);text-transform:uppercase;letter-spacing:.3px;}
.xc-fld select,.xc-fld input{border:1px solid var(--bdr);height:32px;font-size:12px;padding:0 8px;font-family:inherit;background:#fff;min-width:130px;}
.xc-eff__out{margin-top:13px;display:none;}
.xc-eff__row{display:flex;justify-content:space-between;gap:12px;padding:6px 0;border-bottom:1px solid #f1f5f9;font-size:12px;}
.xc-eff__row:last-child{border-bottom:none;}
.xc-eff__src{font-size:10.5px;color:var(--muted);}
.xc-on{color:var(--ok);font-weight:700;}
.xc-off{color:var(--danger);font-weight:700;}

.xc-modal{display:none;position:fixed;inset:0;background:rgba(8,15,30,.5);z-index:1000;align-items:flex-start;justify-content:center;padding:40px 16px;overflow:auto;}
.xc-modal.on{display:flex;}
.xc-modal__c{background:#fff;width:100%;max-width:480px;}
.xc-modal__h{background:var(--brand-dk);color:#fff;padding:13px 17px;display:flex;justify-content:space-between;align-items:center;font-size:14px;font-weight:700;}
.xc-modal__x{background:none;border:0;color:#fff;font-size:20px;cursor:pointer;}
.xc-modal__b{padding:17px;}
.xc-modal__f{padding:12px 17px;border-top:1px solid var(--bdr);display:flex;justify-content:flex-end;gap:8px;}
.xc-msg{display:none;font-size:12px;padding:9px 11px;margin-top:11px;line-height:1.5;}
.xc-toast{display:none;position:fixed;bottom:22px;right:22px;z-index:3000;background:#fff;border:1px solid var(--bdr);border-left:4px solid var(--ok);
    padding:12px 17px;font-size:12px;box-shadow:0 4px 18px rgba(0,0,0,.14);max-width:340px;}
.xc-toast.on{display:block;}
.xc-toast--err{border-left-color:var(--danger);}
@media(max-width:760px){.xc-row{flex-direction:column;}.xc-row__ctl{width:100%;}}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="xc-head">
    <h1>Examination Configuration</h1>
    <p>What lecturers and students are allowed to do in the portal. Set a rule once for the whole university, then override it for a campus, faculty or single programme where it needs to differ.</p>
</div>

<div class="xc-wrap">

    <%-- The distinction that makes this screen worth having. Without it an operator
         will look here for deadlines, not find them, and set a date somewhere else. --%>
    <div class="xc-note">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
        <span><b>Deadlines are not set here.</b> A deadline says <em>by when</em> and lives in the Deadlines screen. These switches say <em>whether at all</em>. Use them to close mark entry without backdating a deadline, or to close it for one faculty while leaving the rest open.</span>
    </div>

    <%-- Answers "why can this lecturer not enter marks" without reading the table. --%>
    <div class="xc-eff">
        <div class="xc-eff__t">What is in force right now</div>
        <div class="xc-eff__s">Pick a programme to see the rules a lecturer there is actually working under, and which setting decided each one.</div>
        <div class="xc-eff__f">
            <div class="xc-fld"><label>Programme</label><select id="efProg"><option value="">Any</option></select></div>
            <div class="xc-fld"><label>Campus</label><select id="efCampus"><option value="">Any</option></select></div>
            <div class="xc-fld"><label>Academic year</label><input type="text" id="efYear" placeholder="2025/2026" autocomplete="off" /></div>
            <div class="xc-fld"><label>Semester</label><select id="efSem"><option value="0">Any</option><option>1</option><option>2</option><option>3</option></select></div>
            <button type="button" class="xc-btn xc-btn--p" onclick="showEffective()">Check</button>
        </div>
        <div class="xc-eff__out" id="efOut"></div>
    </div>

    <div id="xcGroups"><div style="font-size:12px;color:#64748b;padding:20px;">Loading settings&hellip;</div></div>
</div>

<div class="xc-modal" id="ovModal">
    <div class="xc-modal__c">
        <div class="xc-modal__h"><span>Add an override</span><button type="button" class="xc-modal__x" onclick="closeOv()">&times;</button></div>
        <div class="xc-modal__b">
            <div style="font-size:12.5px;color:#05275C;font-weight:600;margin-bottom:2px;" id="ovTitle">&mdash;</div>
            <div style="font-size:11.5px;color:#64748b;line-height:1.55;margin-bottom:13px;" id="ovHelp"></div>

            <div class="xc-fld" style="margin-bottom:10px;"><label>Applies to</label>
                <select id="ovScope" onchange="ovScopeChanged()">
                    <option value="CAMPUS">One campus</option>
                    <option value="FACULTY">One faculty</option>
                    <option value="PROGRAMME">One programme</option>
                </select>
            </div>
            <div class="xc-fld" style="margin-bottom:10px;"><label>Which one</label><select id="ovValue"></select></div>
            <div style="display:flex;gap:8px;">
                <div class="xc-fld" style="flex:1;"><label>Academic year (optional)</label><input type="text" id="ovYear" placeholder="any year" autocomplete="off" /></div>
                <div class="xc-fld"><label>Semester</label><select id="ovSem"><option value="0">Any</option><option>1</option><option>2</option><option>3</option></select></div>
            </div>
            <div class="xc-fld" style="margin-top:10px;"><label>Value</label><div id="ovValueCtl"></div></div>
            <div class="xc-fld" style="margin-top:10px;"><label>Why (recorded in the log)</label><input type="text" id="ovNotes" placeholder="e.g. Board of examiners sitting" autocomplete="off" /></div>
            <div class="xc-msg" id="ovMsg"></div>
        </div>
        <div class="xc-modal__f">
            <button type="button" class="xc-btn xc-btn--g" onclick="closeOv()">Cancel</button>
            <button type="button" class="xc-btn xc-btn--p" id="ovGo" onclick="saveOv()">Add override</button>
        </div>
    </div>
</div>

<div class="xc-toast" id="xcToast"></div>

<script type="text/javascript">
(function () {
    "use strict";
    var DATA = null, SCOPES = { campuses: [], faculties: [], programmes: [] }, CUR = null;

    function esc(v) {
        return String(v == null ? "" : v).replace(/&/g, "&amp;").replace(/</g, "&lt;")
            .replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
    }
    function post(action, body, cb) {
        var x = new XMLHttpRequest();
        x.open("POST", window.location.pathname + "?action=" + action, true);
        x.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        x.onreadystatechange = function () {
            if (x.readyState !== 4) return;
            if (x.status === 200) { try { cb(JSON.parse(x.responseText)); } catch (e) { cb({ success: false, message: "Unexpected server response." }); } }
            else cb({ success: false, message: "Server error (" + x.status + ")." });
        };
        x.onerror = function () { cb({ success: false, message: "Network error." }); };
        x.send(body);
    }
    function toast(m, err) {
        var t = document.getElementById("xcToast");
        t.textContent = m; t.className = "xc-toast on" + (err ? " xc-toast--err" : "");
        clearTimeout(t._t); t._t = setTimeout(function () { t.className = "xc-toast"; }, 3600);
    }

    function load() {
        post("List", "", function (d) {
            if (!d || !d.success) { document.getElementById("xcGroups").innerHTML =
                '<div style="color:#b42318;font-size:12px;padding:20px;">' + esc((d && d.message) || "Could not load.") + '</div>'; return; }
            DATA = d.settings; SCOPES = d.scopes || SCOPES;
            fillScopePickers();
            render();
        });
    }

    function fillScopePickers() {
        var p = document.getElementById("efProg"), c = document.getElementById("efCampus");
        p.innerHTML = '<option value="">Any</option>';
        (SCOPES.programmes || []).forEach(function (o) { p.innerHTML += '<option value="' + esc(o.v) + '">' + esc(o.t) + '</option>'; });
        c.innerHTML = '<option value="">Any</option>';
        (SCOPES.campuses || []).forEach(function (o) { c.innerHTML += '<option value="' + esc(o.v) + '">' + esc(o.t) + '</option>'; });
    }

    function render() {
        var groups = [], byGroup = {};
        DATA.forEach(function (s) {
            if (!byGroup[s.group]) { byGroup[s.group] = []; groups.push(s.group); }
            byGroup[s.group].push(s);
        });
        var h = "";
        groups.forEach(function (g) {
            h += '<div class="xc-grp"><div class="xc-grp__t">' + esc(g) + '</div><div class="xc-card">';
            byGroup[g].forEach(function (s) { h += rowHtml(s); });
            h += '</div></div>';
        });
        document.getElementById("xcGroups").innerHTML = h;
    }

    function globalOf(s) {
        for (var i = 0; i < s.rules.length; i++) if (s.rules[i].scopeType === "GLOBAL") return s.rules[i];
        return null;
    }

    function rowHtml(s) {
        var g = globalOf(s);
        var val = g ? g.value : "";
        var ctl;
        if (s.type === "BOOL") {
            ctl = '<select class="xc-val" data-key="' + esc(s.key) + '" onchange="XC.setGlobal(this)">'
                + '<option value="1"' + (val === "1" ? " selected" : "") + '>On</option>'
                + '<option value="0"' + (val === "0" ? " selected" : "") + '>Off</option></select>';
        } else {
            ctl = '<input class="xc-val" type="text" value="' + esc(val) + '" data-key="' + esc(s.key)
                + '" onchange="XC.setGlobal(this)" />';
        }

        var h = '<div class="xc-row"><div class="xc-row__main">'
              + '<div class="xc-row__t">' + esc(s.title) + '</div>'
              + '<div class="xc-row__h">' + esc(s.help) + '</div></div>'
              + '<div class="xc-row__ctl">' + ctl
              + '<button type="button" class="xc-mini" onclick="XC.addOv(\'' + esc(s.key) + '\')">Override&hellip;</button>'
              + '</div></div>';

        var ovs = s.rules.filter(function (r) { return r.scopeType !== "GLOBAL"; });
        if (ovs.length) {
            h += '<div class="xc-ovs">';
            ovs.forEach(function (r) {
                var where = r.scopeType.charAt(0) + r.scopeType.slice(1).toLowerCase() + " " + r.scopeValue;
                var when = (r.acadYear ? " · " + r.acadYear : "") + (r.semester ? " S" + r.semester : "");
                h += '<span class="xc-ov"><b>' + esc(where) + '</b>' + esc(when) + ' &rarr; '
                   + (s.type === "BOOL" ? (r.value === "1" ? "On" : "Off") : esc(r.value))
                   + '<button type="button" class="xc-ov__x" title="Remove this override" onclick="XC.delOv(' + r.id + ')">&times;</button></span>';
            });
            h += '</div>';
        }
        return h;
    }

    window.XC = {
        setGlobal: function (el) {
            var key = el.getAttribute("data-key");
            post("Save", "key=" + encodeURIComponent(key) + "&scopeType=GLOBAL&scopeValue=&acadYear=&semester=0"
                + "&value=" + encodeURIComponent(el.value) + "&notes=", function (d) {
                    toast((d && d.message) || "Saved.", !(d && d.success));
                    if (d && d.success) load();
                });
        },
        addOv: function (key) {
            CUR = null;
            for (var i = 0; i < DATA.length; i++) if (DATA[i].key === key) CUR = DATA[i];
            if (!CUR) return;
            document.getElementById("ovTitle").textContent = CUR.title;
            document.getElementById("ovHelp").textContent = CUR.help;
            document.getElementById("ovYear").value = "";
            document.getElementById("ovSem").value = "0";
            document.getElementById("ovNotes").value = "";
            document.getElementById("ovMsg").style.display = "none";
            document.getElementById("ovScope").value = "PROGRAMME";
            ovScopeChanged();
            var g = globalOf(CUR);
            document.getElementById("ovValueCtl").innerHTML = CUR.type === "BOOL"
                ? '<select class="xc-val" id="ovVal" style="width:100%"><option value="1">On</option><option value="0">Off</option></select>'
                : '<input class="xc-val" id="ovVal" type="text" style="width:100%" value="' + esc(g ? g.value : "") + '" />';
            document.getElementById("ovModal").classList.add("on");
        },
        delOv: function (id) {
            if (!confirm("Remove this override?\n\nThe wider rule will apply again.")) return;
            post("Delete", "id=" + encodeURIComponent(id), function (d) {
                toast((d && d.message) || "Done.", !(d && d.success));
                if (d && d.success) load();
            });
        }
    };

    window.ovScopeChanged = function () {
        var t = document.getElementById("ovScope").value, sel = document.getElementById("ovValue");
        var list = t === "CAMPUS" ? SCOPES.campuses : (t === "FACULTY" ? SCOPES.faculties : SCOPES.programmes);
        sel.innerHTML = "";
        (list || []).forEach(function (o) { sel.innerHTML += '<option value="' + esc(o.v) + '">' + esc(o.t) + '</option>'; });
    };
    window.closeOv = function () { document.getElementById("ovModal").classList.remove("on"); };
    window.saveOv = function () {
        if (!CUR) return;
        var msg = document.getElementById("ovMsg");
        var body = "key=" + encodeURIComponent(CUR.key)
                 + "&scopeType=" + encodeURIComponent(document.getElementById("ovScope").value)
                 + "&scopeValue=" + encodeURIComponent(document.getElementById("ovValue").value)
                 + "&acadYear=" + encodeURIComponent(document.getElementById("ovYear").value.replace(/^\s+|\s+$/g, ""))
                 + "&semester=" + encodeURIComponent(document.getElementById("ovSem").value)
                 + "&value=" + encodeURIComponent(document.getElementById("ovVal").value)
                 + "&notes=" + encodeURIComponent(document.getElementById("ovNotes").value);
        var b = document.getElementById("ovGo"); b.disabled = true;
        post("Save", body, function (d) {
            b.disabled = false;
            if (d && d.success) { closeOv(); toast("Override added."); load(); }
            else { msg.style.display = "block"; msg.style.background = "#fef2f2"; msg.style.color = "#b42318";
                   msg.style.border = "1px solid #fecaca"; msg.textContent = (d && d.message) || "Could not save."; }
        });
    };

    window.showEffective = function () {
        var body = "programme=" + encodeURIComponent(document.getElementById("efProg").value)
                 + "&campus=" + encodeURIComponent(document.getElementById("efCampus").value)
                 + "&acadYear=" + encodeURIComponent(document.getElementById("efYear").value.replace(/^\s+|\s+$/g, ""))
                 + "&semester=" + encodeURIComponent(document.getElementById("efSem").value);
        post("Effective", body, function (d) {
            var out = document.getElementById("efOut");
            if (!d || !d.success) { out.style.display = "block"; out.innerHTML = '<span style="color:#b42318;font-size:12px;">' + esc((d && d.message) || "Could not check.") + '</span>'; return; }
            var h = "";
            if (d.faculty) h += '<div style="font-size:11px;color:#64748b;margin-bottom:7px;">Faculty resolved from the programme: <b>' + esc(d.faculty) + '</b></div>';
            d.settings.forEach(function (s) {
                var shown = s.type === "BOOL"
                    ? (s.value === "1" ? '<span class="xc-on">On</span>' : '<span class="xc-off">Off</span>')
                    : esc(s.value === "" ? "-" : s.value);
                h += '<div class="xc-eff__row"><span>' + esc(s.title) + '</span>'
                   + '<span style="text-align:right;">' + shown
                   + '<div class="xc-eff__src">' + esc(s.source || "not configured") + '</div></span></div>';
            });
            out.style.display = "block"; out.innerHTML = h;
        });
    };

    load();
})();
</script>
</asp:Content>
