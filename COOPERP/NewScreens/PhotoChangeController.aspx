<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="PhotoChangeController.aspx.cs" Inherits="COOPERP_NewScreens_PhotoChangeController" Title="Photo Change Approvals - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.pc-wrap{padding:6px 2px 40px;}
.pc-head h1{font-size:20px;font-weight:700;color:#05275C;margin:0 0 3px;}
.pc-head p{font-size:12.5px;color:#5b6472;margin:0 0 16px;}
.pc-bar{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:12px;}
.pc-tabs{display:flex;gap:6px;flex-wrap:wrap;}
.pc-tab{font-size:12px;font-weight:700;color:#5b6472;text-decoration:none;padding:7px 13px;border:1px solid #e0e5ed;background:#fff;white-space:nowrap;}
.pc-tab em{font-style:normal;color:#9aa4b5;font-weight:600;}
.pc-tab:hover{border-color:#174DA4;color:#174DA4;}
.pc-tab--on{background:#05275C;border-color:#05275C;color:#fff;} .pc-tab--on em{color:#c9d5ea;}
.pc-search{display:flex;align-items:center;gap:6px;}
.pc-search__in{border:1px solid #e0e5ed;padding:7px 10px;font-size:12px;font-family:inherit;min-width:210px;}
.pc-clear{font-size:11px;color:#8b93a3;text-decoration:none;}
.pc-btn{border:0;padding:8px 14px;font-size:12px;font-weight:700;cursor:pointer;font-family:inherit;background:#eef1f6;color:#05275C;}
.pc-btn--sm{padding:7px 12px;}
.pc-btn--ok{background:#1c7a45;color:#fff;} .pc-btn--ok:hover{background:#166534;}
.pc-btn--danger{background:#b3261e;color:#fff;} .pc-btn--danger:hover{background:#8f1c16;}
.pc-btn:disabled{opacity:.5;cursor:not-allowed;}
.pc-batch{display:flex;align-items:center;gap:10px;background:#f5f7fa;border:1px solid #e0e5ed;padding:9px 12px;margin-bottom:14px;flex-wrap:wrap;}
.pc-selall{font-size:12px;color:#3a4250;font-weight:600;display:flex;align-items:center;gap:6px;cursor:pointer;}
.pc-batch__spacer{flex:1;}
.pc-selcount{font-size:11px;color:#8b93a3;}
.pc-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:14px;}
.pc-card{border:1px solid #e0e5ed;background:#fff;display:flex;flex-direction:column;}
.pc-card__h{display:flex;align-items:center;gap:8px;padding:10px 12px;border-bottom:1px solid #eef1f6;}
.pc-card__id{min-width:0;flex:1;display:flex;flex-direction:column;line-height:1.25;}
.pc-card__id b{font-size:12.5px;color:#1a1a2e;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.pc-card__id span{font-size:10.5px;color:#174DA4;font-weight:600;}
.pc-st{font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;padding:2px 7px;white-space:nowrap;}
.pc-st--pending{background:#fff8e1;color:#7a5c00;} .pc-st--approved{background:#e9f7ef;color:#1c7a45;}
.pc-st--rejected{background:#fdecec;color:#b3261e;} .pc-st--deleted{background:#eef1f6;color:#5b6472;}
.pc-imgs{display:flex;gap:8px;padding:12px;justify-content:center;background:#fafbfc;}
.pc-img{position:relative;background:#eef1f6;border:1px solid #e0e5ed;overflow:hidden;}
.pc-img--new{width:132px;height:176px;} .pc-img--old{width:78px;height:104px;align-self:flex-end;opacity:.85;}
.pc-img img{width:100%;height:100%;object-fit:cover;display:block;}
.pc-img__none{width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:10px;color:#9aa4b5;text-align:center;}
.pc-img__lbl{position:absolute;bottom:0;left:0;right:0;background:rgba(5,39,92,.72);color:#fff;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;text-align:center;padding:2px;}
.pc-meta{font-size:10.5px;color:#6b7280;padding:3px 12px;line-height:1.45;}
.pc-meta i{color:#8b6f00;}
.pc-acts{display:flex;gap:8px;padding:10px 12px;border-top:1px solid #eef1f6;margin-top:auto;}
.pc-acts .pc-btn{flex:1;}
.pc-empty{text-align:center;padding:44px 20px;color:#8b93a3;font-size:13px;background:#fff;border:1px solid #e0e5ed;}
.pc-pager{display:flex;align-items:center;justify-content:space-between;margin-top:14px;font-size:11px;color:#6b7280;}
.pc-pg{border:1px solid #e0e5ed;background:#fff;padding:5px 11px;font-size:11px;font-weight:700;color:#05275C;text-decoration:none;}
.pc-pg.off{opacity:.4;pointer-events:none;}
.pc-toast{position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:#05275C;color:#fff;padding:11px 18px;font-size:12.5px;font-weight:600;z-index:9999;box-shadow:0 6px 22px rgba(5,39,92,.3);display:none;}
.pc-toast--err{background:#b3261e;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="pc-wrap">
    <div class="pc-head">
        <h1>Student Photo Change Approvals</h1>
        <p>Every student photo change starts as <strong>Pending</strong>. Approve it to keep the new photo, or reject it &mdash; a rejected photo is removed from the student, who must then upload a new one or delete it.</p>
    </div>
    <asp:Literal ID="litBody" runat="server" />
</div>
<div class="pc-toast" id="pcToast"></div>

<script type="text/javascript">
(function () {
    window.pcToast = function (text, err) {
        var t = document.getElementById("pcToast");
        t.textContent = text; t.className = "pc-toast" + (err ? " pc-toast--err" : "");
        t.style.display = "block"; clearTimeout(t._t); t._t = setTimeout(function () { t.style.display = "none"; }, 3200);
    };
    function post(data) {
        return fetch("PhotoChangeController.aspx", {
            method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded", "X-Requested-With": "XMLHttpRequest" }, body: data
        }).then(function (r) { return r.json(); });
    }
    window.pcReview = function (id, approve) {
        var comment = "";
        if (!approve) {
            comment = prompt("Reason for rejecting this photo (shown to the student):", "");
            if (comment === null) return; // cancelled
        } else {
            if (!confirm("Approve this photo?")) return;
        }
        post("action=review&id=" + encodeURIComponent(id) + "&decision=" + (approve ? "approve" : "reject") + "&comment=" + encodeURIComponent(comment))
            .then(function (d) { pcToast(d.message || "Done", !d.success); if (d.success) setTimeout(reloadKeep, 700); })
            .catch(function () { pcToast("Request failed.", true); });
    };
    window.pcBatch = function (approve) {
        var ids = [];
        document.querySelectorAll(".pc-chk:checked").forEach(function (c) { ids.push(c.value); });
        if (ids.length === 0) { pcToast("Select at least one photo first.", true); return; }
        var comment = "";
        if (!approve) {
            comment = prompt("Reason for rejecting these " + ids.length + " photos (shown to the students):", "");
            if (comment === null) return;
        } else {
            if (!confirm("Approve " + ids.length + " selected photo(s)?")) return;
        }
        post("action=batch&ids=" + encodeURIComponent(ids.join(",")) + "&decision=" + (approve ? "approve" : "reject") + "&comment=" + encodeURIComponent(comment))
            .then(function (d) { pcToast(d.message || "Done", !d.success); if (d.success) setTimeout(reloadKeep, 800); })
            .catch(function () { pcToast("Request failed.", true); });
    };
    window.pcToggleAll = function (cb) {
        document.querySelectorAll(".pc-chk").forEach(function (c) { c.checked = cb.checked; });
        pcCount();
    };
    window.pcCount = function () {
        var n = document.querySelectorAll(".pc-chk:checked").length;
        var el = document.getElementById("pcSelCount"); if (el) el.textContent = n + " selected";
    };
    function reloadKeep() { window.location.reload(); }
})();
</script>
</asp:Content>
