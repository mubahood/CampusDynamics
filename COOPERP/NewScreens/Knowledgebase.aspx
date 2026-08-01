<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="Knowledgebase.aspx.cs" Inherits="COOPERP_NewScreens_Knowledgebase" Title="Knowledge Base - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.kbp-page{max-width:1120px;margin:0 auto;padding:6px 0 24px;}
.kbp-header{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:12px;}
.kbp-title{font-size:20px;font-weight:800;color:#05275C;line-height:1.2;margin:0;}
.kbp-sub{font-size:12px;color:#667085;margin-top:4px;}
.kbp-role{display:inline-flex;align-items:center;padding:5px 10px;background:#e8f0fc;color:#174DA4;font-size:10px;font-weight:800;border-radius:2px;white-space:nowrap;}

.kbp-toolbar{background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:10px;display:grid;grid-template-columns:1fr 190px 160px auto;gap:8px;align-items:center;margin-bottom:8px;}
.kbp-search{position:relative;min-width:180px;}
.kbp-search input,.kbp-select{width:100%;box-sizing:border-box;border:1px solid #d0d5dd;padding:8px 10px;font-size:12px;background:#fff;color:#1f2937;font-family:inherit;}
.kbp-search input{padding-left:30px;}
.kbp-search svg{position:absolute;left:9px;top:50%;transform:translateY(-50%);width:14px;height:14px;color:#98a2b3;}
.kbp-clear{border:1px solid #d0d5dd;background:#f8fafc;color:#344054;font-size:11px;font-weight:700;padding:8px 12px;cursor:pointer;}
.kbp-clear:hover{background:#eef2f7;}

.kbp-status{display:flex;justify-content:space-between;align-items:center;gap:8px;background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:7px 10px;margin-bottom:8px;}
.kbp-count{font-size:11px;font-weight:700;color:#475467;}
.kbp-msg{font-size:11px;color:#667085;}

.kbp-list{display:grid;gap:12px;}
.kbp-cat{background:#fff;border:1px solid #e0e5ed;border-radius:4px;overflow:hidden;}
.kbp-cat__head{display:flex;justify-content:space-between;align-items:flex-start;gap:8px;padding:11px 13px;background:#05275C;color:#fff;}
.kbp-cat__title{font-size:13px;font-weight:800;}
.kbp-cat__desc{font-size:10px;color:#c7d8f5;margin-top:3px;line-height:1.4;max-width:760px;}
.kbp-cat__meta{font-size:10px;font-weight:700;color:#05275C;background:#fff;padding:3px 8px;white-space:nowrap;border-radius:2px;}

.kbp-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:10px;padding:12px;}
.kbp-card{border:1px solid #e6e9f0;border-radius:4px;overflow:hidden;display:flex;flex-direction:column;background:#fff;cursor:pointer;transition:box-shadow .15s,border-color .15s;}
.kbp-card:hover{border-color:#174DA4;box-shadow:0 4px 14px rgba(5,39,92,.12);}
.kbp-thumb{position:relative;width:100%;padding-top:56.25%;background:#0b1b34;}
.kbp-thumb img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;}
.kbp-thumb__play{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:44px;height:44px;border-radius:50%;background:rgba(23,77,164,.92);display:flex;align-items:center;justify-content:center;}
.kbp-thumb__play svg{width:18px;height:18px;color:#fff;margin-left:2px;}
.kbp-thumb__tag{position:absolute;left:6px;top:6px;padding:2px 7px;font-size:9px;font-weight:800;letter-spacing:.2px;border-radius:2px;}
.kbp-tag--video{background:#fee2e2;color:#991b1b;}
.kbp-tag--article{background:#dcfce7;color:#166534;}
.kbp-card__body{padding:9px 11px;display:flex;flex-direction:column;gap:4px;flex:1;}
.kbp-card__title{font-size:12px;font-weight:700;color:#111827;line-height:1.35;}
.kbp-card__desc{font-size:11px;color:#667085;line-height:1.4;flex:1;}
.kbp-card__meta{display:flex;justify-content:space-between;align-items:center;margin-top:2px;}
.kbp-views{font-size:10px;font-weight:700;color:#8a94a6;}
.kbp-card__open{font-size:10px;font-weight:800;color:#174DA4;}

.kbp-loading,.kbp-empty,.kbp-error{background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:26px 14px;text-align:center;font-size:12px;color:#667085;}
.kbp-error{color:#b42318;}
.kbp-retry{margin-top:10px;border:1px solid #174DA4;background:#174DA4;color:#fff;font-size:11px;font-weight:700;padding:7px 12px;cursor:pointer;border-radius:2px;}
.kbp-skel{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:10px;}
.kbp-skel__row{height:180px;border-radius:4px;background:linear-gradient(90deg,#f2f4f7 25%,#e4e7ec 37%,#f2f4f7 63%);background-size:400% 100%;animation:kbpShimmer 1.25s infinite;border:1px solid #eef2f6;}
@keyframes kbpShimmer{0%{background-position:100% 0;}100%{background-position:0 0;}}

.kbp-modal-backdrop{display:none;position:fixed;inset:0;background:rgba(15,23,42,.72);z-index:9000;}
.kbp-modal{display:none;position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);width:92vw;max-width:960px;max-height:90vh;background:#fff;border-radius:4px;z-index:9001;overflow:auto;}
.kbp-modal__head{display:flex;align-items:center;justify-content:space-between;gap:8px;padding:11px 13px;background:#05275C;color:#fff;position:sticky;top:0;}
.kbp-modal__title{font-size:13px;font-weight:800;line-height:1.3;}
.kbp-modal__close{border:none;background:none;color:#fff;font-size:22px;line-height:1;cursor:pointer;}
.kbp-modal__body{padding:13px;}
.kbp-player{position:relative;width:100%;padding-top:56.25%;background:#000;border-radius:3px;overflow:hidden;}
.kbp-player iframe{position:absolute;inset:0;width:100%;height:100%;border:0;}
.kbp-player__loading{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;color:#fff;background:rgba(0,0,0,.4);font-size:12px;font-weight:700;}
.kbp-modal__content{margin-top:11px;font-size:12px;color:#334155;line-height:1.6;white-space:pre-wrap;}

@media(max-width:900px){ .kbp-toolbar{grid-template-columns:1fr 1fr;} }
@media(max-width:600px){
    .kbp-header{flex-direction:column;}
    .kbp-title{font-size:17px;}
    .kbp-toolbar{grid-template-columns:1fr;}
    .kbp-grid{grid-template-columns:1fr;}
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="kbp-page">
    <div class="kbp-header">
        <div>
            <h1 class="kbp-title">Knowledge Base</h1>
            <div class="kbp-sub">Training videos and step-by-step guides for staff &mdash; learn how to use the university portal.</div>
        </div>
        <div class="kbp-role" id="kbpRole">Staff learning library</div>
    </div>

    <div class="kbp-toolbar" id="kbpToolbar" style="display:none;">
        <div class="kbp-search">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            <input type="text" id="kbpSearch" placeholder="Search videos, guides, or keywords..." />
        </div>
        <select class="kbp-select" id="kbpCategoryFilter"><option value="ALL">All Categories</option></select>
        <select class="kbp-select" id="kbpTypeFilter"><option value="ALL">All Types</option><option value="VIDEO">Videos</option><option value="ARTICLE">Guides</option></select>
        <button type="button" id="kbpClear" class="kbp-clear">Clear</button>
    </div>

    <div class="kbp-status" id="kbpStatus" style="display:none;">
        <div class="kbp-count" id="kbpCount">0 item(s)</div>
        <div class="kbp-msg" id="kbpMsg">Ready</div>
    </div>

    <div id="kbpLoading" class="kbp-loading">
        <div style="margin-bottom:10px;font-weight:700;">Loading knowledge base...</div>
        <div class="kbp-skel"><div class="kbp-skel__row"></div><div class="kbp-skel__row"></div><div class="kbp-skel__row"></div><div class="kbp-skel__row"></div></div>
    </div>
    <div id="kbpEmpty" class="kbp-empty" style="display:none;">No published learning content is currently available.</div>
    <div id="kbpError" class="kbp-error" style="display:none;"><div id="kbpErrorText">Unable to load knowledge base.</div><button id="kbpRetry" type="button" class="kbp-retry">Retry</button></div>
    <div id="kbpWrap" class="kbp-list" style="display:none;"></div>
</div>

<div class="kbp-modal-backdrop" id="kbpBackdrop" onclick="kbpCloseModal()"></div>
<div class="kbp-modal" id="kbpModal">
    <div class="kbp-modal__head">
        <div class="kbp-modal__title" id="kbpModalTitle">Knowledge Base Item</div>
        <button type="button" class="kbp-modal__close" onclick="kbpCloseModal()">&times;</button>
    </div>
    <div class="kbp-modal__body" id="kbpModalBody"></div>
</div>

<script type="text/javascript">
(function(){
    var PAGE = window.location.pathname;

    var State = { raw: [], map: {}, query: '', category: 'ALL', type: 'ALL' };

    var Dom = {
        loading: document.getElementById('kbpLoading'),
        empty: document.getElementById('kbpEmpty'),
        error: document.getElementById('kbpError'),
        errorText: document.getElementById('kbpErrorText'),
        wrap: document.getElementById('kbpWrap'),
        toolbar: document.getElementById('kbpToolbar'),
        status: document.getElementById('kbpStatus'),
        count: document.getElementById('kbpCount'),
        msg: document.getElementById('kbpMsg'),
        search: document.getElementById('kbpSearch'),
        categoryFilter: document.getElementById('kbpCategoryFilter'),
        typeFilter: document.getElementById('kbpTypeFilter'),
        clear: document.getElementById('kbpClear'),
        retry: document.getElementById('kbpRetry'),
        backdrop: document.getElementById('kbpBackdrop'),
        modal: document.getElementById('kbpModal'),
        modalTitle: document.getElementById('kbpModalTitle'),
        modalBody: document.getElementById('kbpModalBody')
    };

    function esc(s){
        s = s == null ? '' : String(s);
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }
    function debounce(fn, ms){
        var t = null;
        return function(){ var args = arguments; if (t) clearTimeout(t); t = setTimeout(function(){ fn.apply(null, args); }, ms); };
    }

    var Api = {
        ajax: function(action, body, cb){
            var url = PAGE + '?ajax=' + encodeURIComponent(action);
            var xhr = new XMLHttpRequest();
            if (body){ xhr.open('POST', url, true); xhr.setRequestHeader('Content-Type','application/json; charset=utf-8'); }
            else { xhr.open('GET', url, true); }
            xhr.onreadystatechange = function(){
                if (xhr.readyState !== 4) return;
                if (xhr.status !== 200){ cb({ ok:false, error:'HTTP ' + xhr.status }); return; }
                try { cb(JSON.parse(xhr.responseText)); } catch(ex){ cb({ ok:false, error:'Invalid server response' }); }
            };
            xhr.send(body ? JSON.stringify(body) : null);
        },
        list: function(cb){ this.ajax('list', null, cb); },
        recordView: function(id, cb){ this.ajax('record_view', { id:id }, cb); }
    };

    function youtubeId(url){
        var s = String(url || '').trim();
        if (!s) return '';
        var m = s.match(/[?&]v=([a-zA-Z0-9_-]{11})/); if (m && m[1]) return m[1];
        m = s.match(/youtu\.be\/([a-zA-Z0-9_-]{11})/); if (m && m[1]) return m[1];
        m = s.match(/\/embed\/([a-zA-Z0-9_-]{11})/); if (m && m[1]) return m[1];
        m = s.match(/\/shorts\/([a-zA-Z0-9_-]{11})/); if (m && m[1]) return m[1];
        return '';
    }
    function resolveYoutubeId(item){
        if (!item) return '';
        var id = youtubeId(item.youtube_url || '');
        if (id) return id;
        return youtubeId(item.content || '');
    }

    function normalize(categories){
        var out = [];
        for (var i = 0; i < categories.length; i++){
            var c = categories[i] || {};
            var rows = c.articles || [];
            for (var j = 0; j < rows.length; j++){
                var r = rows[j] || {};
                out.push({
                    ID: Number(r.ID || 0),
                    title: String(r.title || ''),
                    description: String(r.description || ''),
                    content: String(r.content || ''),
                    youtube_url: String(r.youtube_url || ''),
                    is_youtube_video: Number(r.is_youtube_video || 0),
                    view_count: Number(r.view_count || 0),
                    category_title: String(c.title || ''),
                    category_description: String(c.description || '')
                });
            }
        }
        return out;
    }

    var Filter = {
        apply: function(items){
            var text = State.query, category = State.category, type = State.type, res = [];
            for (var i = 0; i < items.length; i++){
                var it = items[i];
                var yt = resolveYoutubeId(it);
                var isVideo = it.is_youtube_video === 1 || !!yt;
                if (category !== 'ALL' && it.category_title !== category) continue;
                if (type === 'VIDEO' && !isVideo) continue;
                if (type === 'ARTICLE' && isVideo) continue;
                if (text){
                    var hay = (it.title + ' ' + it.description + ' ' + it.category_title + ' ' + it.content).toLowerCase();
                    if (hay.indexOf(text) < 0) continue;
                }
                res.push(it);
            }
            return res;
        },
        categories: function(items){
            var map = {}, order = [];
            for (var i = 0; i < items.length; i++){
                var k = items[i].category_title || 'General';
                if (!map[k]){ map[k] = true; order.push(k); }
            }
            return order;
        }
    };

    function grouped(items){
        var map = {}, order = [];
        for (var i = 0; i < items.length; i++){
            var it = items[i];
            var key = it.category_title || 'General';
            if (!map[key]){ map[key] = []; order.push(key); }
            map[key].push(it);
        }
        return { map: map, order: order };
    }

    var Ui = {
        setMessage: function(text){ Dom.msg.textContent = text || ''; },
        showLoading: function(){
            Dom.loading.style.display = ''; Dom.empty.style.display = 'none'; Dom.error.style.display = 'none';
            Dom.wrap.style.display = 'none'; Dom.toolbar.style.display = 'none'; Dom.status.style.display = 'none';
        },
        showError: function(text){
            Dom.loading.style.display = 'none'; Dom.empty.style.display = 'none'; Dom.wrap.style.display = 'none';
            Dom.error.style.display = ''; Dom.errorText.textContent = text || 'Unable to load knowledge base.';
            Dom.toolbar.style.display = 'none'; Dom.status.style.display = 'none';
        },
        showEmpty: function(text){
            Dom.loading.style.display = 'none'; Dom.error.style.display = 'none'; Dom.wrap.style.display = 'none';
            Dom.empty.style.display = ''; Dom.empty.textContent = text || 'No published learning content is currently available.';
            Dom.status.style.display = ''; Dom.toolbar.style.display = '';
        },
        renderFilters: function(){
            var cats = Filter.categories(State.raw);
            var html = '<option value="ALL">All Categories</option>';
            for (var i = 0; i < cats.length; i++){ html += '<option value="' + esc(cats[i]) + '">' + esc(cats[i]) + '</option>'; }
            Dom.categoryFilter.innerHTML = html;
        },
        renderList: function(items){
            Dom.count.textContent = items.length + ' item(s)';
            if (!items.length){ this.showEmpty('No items match your current filters.'); return; }
            Dom.loading.style.display = 'none'; Dom.error.style.display = 'none'; Dom.empty.style.display = 'none';
            Dom.toolbar.style.display = ''; Dom.status.style.display = '';

            var g = grouped(items), html = '';
            for (var i = 0; i < g.order.length; i++){
                var cat = g.order[i], rows = g.map[cat];
                var catDesc = rows.length ? rows[0].category_description : '';
                html += '<section class="kbp-cat">';
                html += '<div class="kbp-cat__head"><div><div class="kbp-cat__title">' + esc(cat) + '</div><div class="kbp-cat__desc">' + esc(catDesc) + '</div></div><span class="kbp-cat__meta">' + rows.length + ' item(s)</span></div>';
                html += '<div class="kbp-grid">';
                for (var j = 0; j < rows.length; j++){
                    var r = rows[j];
                    State.map[r.ID] = r;
                    var ytId = resolveYoutubeId(r);
                    var isVideo = r.is_youtube_video === 1 || !!ytId;
                    var tag = isVideo ? '<span class="kbp-thumb__tag kbp-tag--video">VIDEO</span>' : '<span class="kbp-thumb__tag kbp-tag--article">GUIDE</span>';
                    var thumb;
                    if (isVideo && ytId){
                        thumb = '<div class="kbp-thumb"><img loading="lazy" src="https://img.youtube.com/vi/' + esc(ytId) + '/mqdefault.jpg" alt="" onerror="this.style.display=\'none\'" />' +
                                '<div class="kbp-thumb__play"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg></div>' + tag + '</div>';
                    } else {
                        thumb = '<div class="kbp-thumb" style="background:#123b7e;">' +
                                '<div class="kbp-thumb__play" style="background:rgba(255,255,255,.15);"><svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg></div>' + tag + '</div>';
                    }
                    html += '<div class="kbp-card" data-kbp-open="' + r.ID + '">' + thumb +
                            '<div class="kbp-card__body"><div class="kbp-card__title">' + esc(r.title) + '</div>' +
                            '<div class="kbp-card__desc">' + esc(r.description) + '</div>' +
                            '<div class="kbp-card__meta"><span class="kbp-views" id="kbViews_' + r.ID + '">' + r.view_count + ' views</span>' +
                            '<span class="kbp-card__open">' + (isVideo ? 'Play &rsaquo;' : 'Open &rsaquo;') + '</span></div></div></div>';
                }
                html += '</div></section>';
            }
            Dom.wrap.innerHTML = html;
            Dom.wrap.style.display = '';
            this.setMessage('Ready');
        }
    };

    var Player = {
        open: function(id){
            var item = State.map[Number(id || 0)];
            if (!item) return;
            Dom.modalTitle.textContent = item.title || 'Knowledge Base Item';
            var html = '', recorded = false;
            var yt = resolveYoutubeId(item);
            if (yt){
                html += '<div class="kbp-player"><div class="kbp-player__loading" id="kbpPlayerLoading">Loading video...</div><iframe id="kbpIframe" loading="lazy" allowfullscreen referrerpolicy="strict-origin-when-cross-origin" src="https://www.youtube.com/embed/' + esc(yt) + '?autoplay=1&rel=0" title="YouTube player"></iframe></div>';
                recorded = true;
                if (item.description){ html += '<div class="kbp-modal__content">' + esc(item.description) + '</div>'; }
            } else if (item.content) {
                html += '<div class="kbp-modal__content">' + esc(item.content) + '</div>';
                recorded = true;
            }
            Dom.modalBody.innerHTML = html;
            Dom.backdrop.style.display = 'block';
            Dom.modal.style.display = 'block';
            var iframe = document.getElementById('kbpIframe');
            if (iframe){ iframe.onload = function(){ var l = document.getElementById('kbpPlayerLoading'); if (l) l.style.display = 'none'; }; }
            if (recorded){
                Api.recordView(id, function(res){
                    if (res && res.ok){
                        item.view_count = Number(res.view_count || item.view_count || 0);
                        var v = document.getElementById('kbViews_' + id);
                        if (v) v.textContent = Number(item.view_count || 0) + ' views';
                    }
                });
            }
        },
        close: function(){ Dom.backdrop.style.display = 'none'; Dom.modal.style.display = 'none'; Dom.modalBody.innerHTML = ''; }
    };

    function applyAndRender(){ Ui.renderList(Filter.apply(State.raw)); }

    function loadData(){
        Ui.showLoading();
        Ui.setMessage('Loading content...');
        Api.list(function(res){
            if (!res || !res.ok){ Ui.showError((res && res.error) ? res.error : 'Unable to load knowledge base.'); return; }
            State.raw = normalize(res.categories || []);
            State.map = {};
            Ui.renderFilters();
            applyAndRender();
        });
    }

    var debouncedSearch = debounce(function(value){ State.query = String(value || '').toLowerCase().trim(); applyAndRender(); }, 160);

    Dom.search.onkeyup = function(){ debouncedSearch(Dom.search.value); };
    Dom.categoryFilter.onchange = function(){ State.category = Dom.categoryFilter.value || 'ALL'; applyAndRender(); };
    Dom.typeFilter.onchange = function(){ State.type = Dom.typeFilter.value || 'ALL'; applyAndRender(); };
    Dom.clear.onclick = function(){
        Dom.search.value = ''; Dom.categoryFilter.value = 'ALL'; Dom.typeFilter.value = 'ALL';
        State.query = ''; State.category = 'ALL'; State.type = 'ALL'; applyAndRender();
    };
    Dom.retry.onclick = function(){ loadData(); };
    Dom.wrap.onclick = function(e){
        var target = e.target || e.srcElement;
        while (target && target !== Dom.wrap && !target.getAttribute('data-kbp-open')) target = target.parentNode;
        if (!target || target === Dom.wrap) return;
        var id = target.getAttribute('data-kbp-open');
        if (id) Player.open(Number(id));
    };
    window.kbpCloseModal = function(){ Player.close(); };
    document.addEventListener('keydown', function(e){ if ((e.key && e.key === 'Escape') || e.keyCode === 27) Player.close(); });

    loadData();
})();
</script>
</asp:Content>
