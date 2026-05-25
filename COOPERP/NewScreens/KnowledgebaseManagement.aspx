<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="KnowledgebaseManagement.aspx.cs" Inherits="COOPERP_NewScreens_KnowledgebaseManagement" Title="Knowledgebase Management - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.kb-header{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:14px;}
.kb-header__title{font-size:18px;font-weight:700;color:#1f2937;}
.kb-header__sub{font-size:12px;color:#6b7280;margin-top:2px;}
.kb-btn{border:1px solid #d1d5db;background:#fff;color:#111827;padding:7px 12px;font-size:12px;font-weight:600;cursor:pointer;}
.kb-btn:hover{background:#f9fafb;}
.kb-btn--primary{background:#174DA4;color:#fff;border-color:#174DA4;}
.kb-btn--primary:hover{background:#123b7e;}
.kb-btn--danger{background:#b91c1c;color:#fff;border-color:#b91c1c;}
.kb-btn--danger:hover{background:#991b1b;}
.kb-btn--sm{padding:4px 8px;font-size:11px;}

.kb-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:12px;}
.kb-stat{background:#fff;border:1px solid #e5e7eb;padding:10px 12px;}
.kb-stat__val{font-size:18px;font-weight:700;color:#1f2937;line-height:1.1;}
.kb-stat__lbl{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#6b7280;margin-top:3px;}

.kb-grid{display:grid;grid-template-columns:1fr 1.5fr;gap:12px;}
.kb-card{background:#fff;border:1px solid #e5e7eb;}
.kb-card__head{padding:10px 12px;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;justify-content:space-between;}
.kb-card__title{font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#374151;}
.kb-card__body{padding:10px 12px;}

.kb-filters{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:8px;}
.kb-filters select,.kb-filters input,.kb-field input,.kb-field textarea,.kb-field select{border:1px solid #d1d5db;padding:7px 8px;font-size:12px;width:100%;box-sizing:border-box;}
.kb-filters .kb-field{min-width:140px;flex:1;}
.kb-field label{display:block;font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#6b7280;margin-bottom:3px;}
.kb-row{display:grid;grid-template-columns:1fr 1fr;gap:8px;}

.kb-table{width:100%;border-collapse:collapse;font-size:12px;}
.kb-table th{background:#f9fafb;border-bottom:2px solid #e5e7eb;color:#6b7280;font-size:10px;text-transform:uppercase;letter-spacing:.4px;text-align:left;padding:8px;white-space:nowrap;}
.kb-table td{border-bottom:1px solid #f3f4f6;padding:8px;color:#111827;vertical-align:top;}
.kb-empty{text-align:center;color:#9ca3af;padding:18px;font-size:12px;}
.kb-badge{display:inline-block;padding:2px 7px;font-size:10px;font-weight:700;}
.kb-badge--ok{background:#dcfce7;color:#166534;}
.kb-badge--off{background:#f3f4f6;color:#4b5563;}
.kb-badge--draft{background:#ffedd5;color:#9a3412;}
.kb-badge--pub{background:#dbeafe;color:#1e3a8a;}
.kb-badge--arch{background:#f3e8ff;color:#6b21a8;}
.kb-photo{width:34px;height:34px;object-fit:cover;border:1px solid #d1d5db;background:#f9fafb;}
.kb-actions{display:flex;gap:4px;}
.kb-truncate{max-width:220px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}

.kb-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:1100;}
.kb-modal{display:none;position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);width:760px;max-width:96vw;max-height:90vh;overflow:auto;background:#fff;border:1px solid #d1d5db;z-index:1101;}
.kb-modal__head{padding:10px 12px;background:#174DA4;color:#fff;display:flex;align-items:center;justify-content:space-between;}
.kb-modal__title{font-size:14px;font-weight:700;}
.kb-modal__body{padding:12px;}
.kb-modal__foot{padding:10px 12px;border-top:1px solid #e5e7eb;display:flex;justify-content:flex-end;gap:8px;}
.kb-close{background:none;border:none;color:#fff;font-size:22px;cursor:pointer;line-height:1;}
.kb-result{font-size:12px;min-height:16px;color:#b91c1c;margin-bottom:8px;}
.kb-result--ok{color:#166534;}

@media (max-width:1000px){.kb-grid{grid-template-columns:1fr;} .kb-stats{grid-template-columns:repeat(2,1fr);} }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="kb-header">
    <div>
        <div class="kb-header__title">Knowledgebase Management</div>
        <div class="kb-header__sub">Manage ordered categories, rich articles, and YouTube video guides for students/employees.</div>
    </div>
    <button type="button" class="kb-btn kb-btn--primary" onclick="kbOpenArticle(0)">New Article</button>
</div>

<div class="kb-stats">
    <div class="kb-stat"><div class="kb-stat__val" id="stCategories">0</div><div class="kb-stat__lbl">Categories</div></div>
    <div class="kb-stat"><div class="kb-stat__val" id="stActiveCategories">0</div><div class="kb-stat__lbl">Active Categories</div></div>
    <div class="kb-stat"><div class="kb-stat__val" id="stArticles">0</div><div class="kb-stat__lbl">Articles</div></div>
    <div class="kb-stat"><div class="kb-stat__val" id="stPublished">0</div><div class="kb-stat__lbl">Published Articles</div></div>
    <div class="kb-stat"><div class="kb-stat__val" id="stDraft">0</div><div class="kb-stat__lbl">Draft Articles</div></div>
</div>

<div class="kb-grid">
    <div class="kb-card">
        <div class="kb-card__head">
            <div class="kb-card__title">Categories</div>
            <button type="button" class="kb-btn kb-btn--sm kb-btn--primary" onclick="kbOpenCategory(0)">New Category</button>
        </div>
        <div class="kb-card__body" id="kbCategoriesWrap">
            <div class="kb-empty">Loading categories...</div>
        </div>
    </div>

    <div class="kb-card">
        <div class="kb-card__head">
            <div class="kb-card__title">Articles</div>
            <button type="button" class="kb-btn kb-btn--sm kb-btn--primary" onclick="kbOpenArticle(0)">New Article</button>
        </div>
        <div class="kb-card__body">
            <div class="kb-filters">
                <div class="kb-field">
                    <label>Category</label>
                    <select id="fltCategory" onchange="kbLoadArticles()"><option value="">All Categories</option></select>
                </div>
                <div class="kb-field">
                    <label>Status</label>
                    <select id="fltStatus" onchange="kbLoadArticles()">
                        <option value="">All Statuses</option>
                        <option value="DRAFT">Draft</option>
                        <option value="PUBLISHED">Published</option>
                        <option value="ARCHIVED">Archived</option>
                    </select>
                </div>
                <div class="kb-field">
                    <label>Visibility</label>
                    <select id="fltVisibility" onchange="kbLoadArticles()">
                        <option value="">All Visibility</option>
                        <option value="STUDENTS">Students</option>
                        <option value="EMPLOYEES">Employees</option>
                        <option value="BOTH">Both</option>
                    </select>
                </div>
                <div class="kb-field">
                    <label>Search</label>
                    <input type="text" id="fltSearch" placeholder="Search title/description/content" onkeyup="kbDebounceArticles()" />
                </div>
            </div>
            <div id="kbArticlesWrap"><div class="kb-empty">Loading articles...</div></div>
        </div>
    </div>
</div>

<div class="kb-overlay" id="kbOverlay" onclick="kbCloseModals()"></div>

<div class="kb-modal" id="kbCategoryModal">
    <div class="kb-modal__head">
        <div class="kb-modal__title" id="kbCategoryTitle">New Category</div>
        <button class="kb-close" type="button" onclick="kbCloseModals()">&times;</button>
    </div>
    <div class="kb-modal__body">
        <div id="kbCategoryResult" class="kb-result"></div>
        <input type="hidden" id="catID" value="0" />
        <div class="kb-field"><label>Title *</label><input type="text" id="catTitle" maxlength="200" /></div>
        <div class="kb-field"><label>Description</label><textarea id="catDescription" rows="4"></textarea></div>
        <div class="kb-row">
            <div class="kb-field"><label>Display Order</label><input type="number" id="catOrder" value="0" /></div>
            <div class="kb-field"><label>Active</label><select id="catActive"><option value="1">Yes</option><option value="0">No</option></select></div>
        </div>
        <div class="kb-field">
            <label>Photo (optional)</label>
            <div style="display:flex;gap:8px;align-items:center;">
                <input type="file" id="catPhotoFile" accept="image/*" />
                <button type="button" class="kb-btn kb-btn--sm" onclick="kbUploadPhoto('category')">Upload</button>
                <img id="catPhotoPreview" class="kb-photo" src="" alt="" style="display:none;" />
            </div>
            <input type="hidden" id="catPhotoPath" />
        </div>
    </div>
    <div class="kb-modal__foot">
        <button type="button" class="kb-btn" onclick="kbCloseModals()">Cancel</button>
        <button type="button" class="kb-btn kb-btn--primary" onclick="kbSaveCategory()">Save Category</button>
    </div>
</div>

<div class="kb-modal" id="kbArticleModal">
    <div class="kb-modal__head">
        <div class="kb-modal__title" id="kbArticleTitle">New Article</div>
        <button class="kb-close" type="button" onclick="kbCloseModals()">&times;</button>
    </div>
    <div class="kb-modal__body">
        <div id="kbArticleResult" class="kb-result"></div>
        <input type="hidden" id="artID" value="0" />
        <div class="kb-row">
            <div class="kb-field"><label>Category *</label><select id="artCategory"></select></div>
            <div class="kb-field"><label>Title *</label><input type="text" id="artTitle" maxlength="250" /></div>
        </div>
        <div class="kb-field"><label>Description</label><textarea id="artDescription" rows="3"></textarea></div>
        <div class="kb-row">
            <div class="kb-field"><label>Is YouTube Video?</label><select id="artIsYoutube" onchange="kbToggleYoutubeFields()"><option value="0">No (Standard Article)</option><option value="1">Yes (YouTube Video)</option></select></div>
            <div class="kb-field"><label>YouTube URL</label><input type="text" id="artYoutubeUrl" maxlength="500" placeholder="https://www.youtube.com/watch?v=..." /></div>
        </div>
        <div class="kb-field"><label>Content / Notes</label><textarea id="artContent" rows="10" placeholder="Enter article content"></textarea></div>
        <div class="kb-row">
            <div class="kb-field"><label>Display Order</label><input type="number" id="artOrder" value="0" /></div>
            <div class="kb-field"><label>Visibility</label><select id="artVisibility"><option value="BOTH">Both</option><option value="STUDENTS">Students</option><option value="EMPLOYEES">Employees</option></select></div>
        </div>
        <div class="kb-row">
            <div class="kb-field"><label>Status</label><select id="artStatus"><option value="DRAFT">Draft</option><option value="PUBLISHED">Published</option><option value="ARCHIVED">Archived</option></select></div>
            <div class="kb-field"><label>Views</label><input type="number" id="artViewCount" value="0" readonly="readonly" /></div>
            <div class="kb-field">
                <label>Photo (optional)</label>
                <div style="display:flex;gap:8px;align-items:center;">
                    <input type="file" id="artPhotoFile" accept="image/*" />
                    <button type="button" class="kb-btn kb-btn--sm" onclick="kbUploadPhoto('article')">Upload</button>
                    <img id="artPhotoPreview" class="kb-photo" src="" alt="" style="display:none;" />
                </div>
                <input type="hidden" id="artPhotoPath" />
            </div>
        </div>
    </div>
    <div class="kb-modal__foot">
        <button type="button" class="kb-btn" onclick="kbCloseModals()">Cancel</button>
        <button type="button" class="kb-btn kb-btn--primary" onclick="kbSaveArticle()">Save Article</button>
    </div>
</div>

<script type="text/javascript">
(function(){
    var searchTimer = null;
    var cacheCategories = [];

    function esc(s){
        s = s == null ? '' : String(s);
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }

    function apiGet(url, ok, fail){
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'KnowledgebaseManagement.aspx' + url, true);
        xhr.onreadystatechange = function(){
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200){ fail('Request failed.'); return; }
            try { ok(JSON.parse(xhr.responseText)); } catch(ex){ fail('Invalid server response.'); }
        };
        xhr.send();
    }

    function apiPost(url, payload, ok, fail){
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'KnowledgebaseManagement.aspx' + url, true);
        xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
        xhr.onreadystatechange = function(){
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200){ fail('Request failed.'); return; }
            try { ok(JSON.parse(xhr.responseText)); } catch(ex){ fail('Invalid server response.'); }
        };
        xhr.send(JSON.stringify(payload || {}));
    }

    function renderStats(s){
        document.getElementById('stCategories').textContent = s.category_count || 0;
        document.getElementById('stActiveCategories').textContent = s.active_category_count || 0;
        document.getElementById('stArticles').textContent = s.article_count || 0;
        document.getElementById('stPublished').textContent = s.published_article_count || 0;
        document.getElementById('stDraft').textContent = s.draft_article_count || 0;
    }

    function renderCategories(rows){
        cacheCategories = rows || [];
        var wrap = document.getElementById('kbCategoriesWrap');
        if (!rows || rows.length === 0){
            wrap.innerHTML = '<div class="kb-empty">No categories found.</div>';
            renderCategoryDropdowns();
            return;
        }

        var html = '<table class="kb-table"><thead><tr><th>Order</th><th>Title</th><th>Photo</th><th>Status</th><th>Articles</th><th></th></tr></thead><tbody>';
        for (var i=0;i<rows.length;i++){
            var r = rows[i];
            var active = Number(r.is_active || 0) === 1;
            var badge = active ? '<span class="kb-badge kb-badge--ok">Active</span>' : '<span class="kb-badge kb-badge--off">Inactive</span>';
            var photo = r.photo_path ? '<img class="kb-photo" src="'+esc(r.photo_path)+'" />' : '&mdash;';
            html += '<tr>'+
                '<td>'+esc(r.display_order || 0)+'</td>'+
                '<td><div><strong>'+esc(r.title || '')+'</strong></div><div class="kb-truncate" title="'+esc(r.description || '')+'">'+esc(r.description || '')+'</div></td>'+
                '<td>'+photo+'</td>'+
                '<td>'+badge+'</td>'+
                '<td>'+esc(r.article_count || 0)+'</td>'+
                '<td><div class="kb-actions">'+
                '<button class="kb-btn kb-btn--sm" type="button" onclick="kbOpenCategory(' + Number(r.ID || 0) + ')">Edit</button>'+
                '<button class="kb-btn kb-btn--sm kb-btn--danger" type="button" onclick="kbDeleteCategory(' + Number(r.ID || 0) + ')">Delete</button>'+
                '</div></td>'+
                '</tr>';
        }
        html += '</tbody></table>';
        wrap.innerHTML = html;
        renderCategoryDropdowns();
    }

    function renderCategoryDropdowns(){
        var f = document.getElementById('fltCategory');
        var a = document.getElementById('artCategory');
        var i;

        f.innerHTML = '<option value="">All Categories</option>';
        a.innerHTML = '<option value="">-- Select Category --</option>';

        for (i=0;i<cacheCategories.length;i++){
            var c = cacheCategories[i];
            var id = String(c.ID || '');
            var text = String(c.title || '');
            f.options.add(new Option(text, id));
            if (Number(c.is_active || 0) === 1){
                a.options.add(new Option(text, id));
            }
        }
    }

    function statusBadge(v){
        v = String(v || '').toUpperCase();
        if (v === 'PUBLISHED') return '<span class="kb-badge kb-badge--pub">Published</span>';
        if (v === 'ARCHIVED') return '<span class="kb-badge kb-badge--arch">Archived</span>';
        return '<span class="kb-badge kb-badge--draft">Draft</span>';
    }

    function renderArticles(rows){
        var wrap = document.getElementById('kbArticlesWrap');
        if (!rows || rows.length === 0){
            wrap.innerHTML = '<div class="kb-empty">No articles match the selected filters.</div>';
            return;
        }

        var html = '<table class="kb-table"><thead><tr><th>Order</th><th>Title</th><th>Category</th><th>Type</th><th>Video</th><th>Views</th><th>Visibility</th><th>Status</th><th>Photo</th><th></th></tr></thead><tbody>';
        for (var i=0;i<rows.length;i++){
            var r = rows[i];
            var photo = r.photo_path ? '<img class="kb-photo" src="'+esc(r.photo_path)+'" />' : '&mdash;';
            var isYoutube = Number(r.is_youtube_video || 0) === 1;
            var typeText = isYoutube ? 'YouTube' : 'Article';
            var ytText = isYoutube ? '<span class="kb-badge kb-badge--pub">Video linked</span>' : '&mdash;';
            html += '<tr>'+
                '<td>'+esc(r.display_order || 0)+'</td>'+
                '<td><div><strong>'+esc(r.title || '')+'</strong></div><div class="kb-truncate" title="'+esc(r.description || '')+'">'+esc(r.description || '')+'</div></td>'+
                '<td>'+esc(r.category_title || '')+'</td>'+
                '<td>'+typeText+'</td>'+
                '<td>'+ytText+'</td>'+
                '<td>'+esc(r.view_count || 0)+'</td>'+
                '<td>'+esc(r.visibility || '')+'</td>'+
                '<td>'+statusBadge(r.status)+'</td>'+
                '<td>'+photo+'</td>'+
                '<td><div class="kb-actions">'+
                '<button class="kb-btn kb-btn--sm" type="button" onclick="kbOpenArticle(' + Number(r.ID || 0) + ')">Edit</button>'+
                '<button class="kb-btn kb-btn--sm kb-btn--danger" type="button" onclick="kbDeleteArticle(' + Number(r.ID || 0) + ')">Delete</button>'+
                '</div></td>'+
                '</tr>';
        }
        html += '</tbody></table>';
        wrap.innerHTML = html;
    }

    window.kbLoadAll = function(){
        apiGet('?ajax=bootstrap', function(res){
            if (!res.ok){ alert(res.error || 'Failed to load module data.'); return; }
            renderStats(res.stats || {});
            renderCategories(res.categories || []);
            renderArticles(res.articles || []);
        }, function(err){ alert(err); });
    };

    window.kbLoadArticles = function(){
        var q = '?ajax=list_articles'
            + '&categoryId=' + encodeURIComponent(document.getElementById('fltCategory').value || '')
            + '&status=' + encodeURIComponent(document.getElementById('fltStatus').value || '')
            + '&visibility=' + encodeURIComponent(document.getElementById('fltVisibility').value || '')
            + '&search=' + encodeURIComponent(document.getElementById('fltSearch').value || '');

        apiGet(q, function(res){
            if (!res.ok){ alert(res.error || 'Unable to load articles.'); return; }
            renderArticles(res.rows || []);
        }, function(err){ alert(err); });
    };

    window.kbDebounceArticles = function(){
        if (searchTimer) window.clearTimeout(searchTimer);
        searchTimer = window.setTimeout(window.kbLoadArticles, 250);
    };

    window.kbOpenCategory = function(id){
        document.getElementById('kbCategoryResult').className = 'kb-result';
        document.getElementById('kbCategoryResult').textContent = '';
        document.getElementById('kbCategoryModal').style.display = 'block';
        document.getElementById('kbOverlay').style.display = 'block';

        document.getElementById('kbCategoryTitle').textContent = id > 0 ? 'Edit Category' : 'New Category';
        document.getElementById('catID').value = id || 0;
        document.getElementById('catTitle').value = '';
        document.getElementById('catDescription').value = '';
        document.getElementById('catOrder').value = '0';
        document.getElementById('catActive').value = '1';
        document.getElementById('catPhotoPath').value = '';
        document.getElementById('catPhotoPreview').style.display = 'none';

        if (!id || id <= 0) return;

        apiGet('?ajax=get_category&id=' + encodeURIComponent(id), function(res){
            if (!res.ok){ alert(res.error || 'Failed to load category.'); return; }
            var r = res.row || {};
            document.getElementById('catID').value = r.ID || id;
            document.getElementById('catTitle').value = r.title || '';
            document.getElementById('catDescription').value = r.description || '';
            document.getElementById('catOrder').value = r.display_order || 0;
            document.getElementById('catActive').value = Number(r.is_active || 0) === 1 ? '1' : '0';
            document.getElementById('catPhotoPath').value = r.photo_path || '';
            if (r.photo_path){
                document.getElementById('catPhotoPreview').src = r.photo_path;
                document.getElementById('catPhotoPreview').style.display = 'inline-block';
            }
        }, function(err){ alert(err); });
    };

    window.kbSaveCategory = function(){
        var payload = {
            ID: Number(document.getElementById('catID').value || 0),
            title: document.getElementById('catTitle').value || '',
            description: document.getElementById('catDescription').value || '',
            photo_path: document.getElementById('catPhotoPath').value || '',
            display_order: Number(document.getElementById('catOrder').value || 0),
            is_active: document.getElementById('catActive').value === '1'
        };

        apiPost('?ajax=save_category', payload, function(res){
            if (!res.ok){
                document.getElementById('kbCategoryResult').className = 'kb-result';
                document.getElementById('kbCategoryResult').textContent = res.error || 'Unable to save category.';
                return;
            }
            document.getElementById('kbCategoryResult').className = 'kb-result kb-result--ok';
            document.getElementById('kbCategoryResult').textContent = res.message || 'Saved.';
            window.setTimeout(function(){ kbCloseModals(); kbLoadAll(); }, 250);
        }, function(err){
            document.getElementById('kbCategoryResult').className = 'kb-result';
            document.getElementById('kbCategoryResult').textContent = err;
        });
    };

    window.kbDeleteCategory = function(id){
        if (!confirm('Delete this category?')) return;
        apiPost('?ajax=delete_category', { id: Number(id || 0) }, function(res){
            if (!res.ok){ alert(res.error || 'Unable to delete category.'); return; }
            kbLoadAll();
        }, function(err){ alert(err); });
    };

    window.kbOpenArticle = function(id){
        document.getElementById('kbArticleResult').className = 'kb-result';
        document.getElementById('kbArticleResult').textContent = '';
        document.getElementById('kbArticleModal').style.display = 'block';
        document.getElementById('kbOverlay').style.display = 'block';

        document.getElementById('kbArticleTitle').textContent = id > 0 ? 'Edit Article' : 'New Article';
        document.getElementById('artID').value = id || 0;
        document.getElementById('artCategory').value = '';
        document.getElementById('artTitle').value = '';
        document.getElementById('artDescription').value = '';
        document.getElementById('artIsYoutube').value = '0';
        document.getElementById('artYoutubeUrl').value = '';
        document.getElementById('artContent').value = '';
        document.getElementById('artOrder').value = '0';
        document.getElementById('artViewCount').value = '0';
        document.getElementById('artVisibility').value = 'BOTH';
        document.getElementById('artStatus').value = 'DRAFT';
        document.getElementById('artPhotoPath').value = '';
        document.getElementById('artPhotoPreview').style.display = 'none';
        kbToggleYoutubeFields();

        if (!id || id <= 0) return;

        apiGet('?ajax=get_article&id=' + encodeURIComponent(id), function(res){
            if (!res.ok){ alert(res.error || 'Failed to load article.'); return; }
            var r = res.row || {};
            document.getElementById('artID').value = r.ID || id;
            document.getElementById('artCategory').value = r.category_id || '';
            document.getElementById('artTitle').value = r.title || '';
            document.getElementById('artDescription').value = r.description || '';
            document.getElementById('artIsYoutube').value = Number(r.is_youtube_video || 0) === 1 ? '1' : '0';
            document.getElementById('artYoutubeUrl').value = r.youtube_url || '';
            document.getElementById('artContent').value = r.content || '';
            document.getElementById('artOrder').value = r.display_order || 0;
            document.getElementById('artViewCount').value = r.view_count || 0;
            document.getElementById('artVisibility').value = r.visibility || 'BOTH';
            document.getElementById('artStatus').value = r.status || 'DRAFT';
            document.getElementById('artPhotoPath').value = r.photo_path || '';
            kbToggleYoutubeFields();
            if (r.photo_path){
                document.getElementById('artPhotoPreview').src = r.photo_path;
                document.getElementById('artPhotoPreview').style.display = 'inline-block';
            }
        }, function(err){ alert(err); });
    };

    window.kbSaveArticle = function(){
        var isYoutube = document.getElementById('artIsYoutube').value === '1';
        if (isYoutube && !String(document.getElementById('artYoutubeUrl').value || '').trim()){
            document.getElementById('kbArticleResult').className = 'kb-result';
            document.getElementById('kbArticleResult').textContent = 'YouTube URL is required when "Is YouTube Video" is set to Yes.';
            return;
        }

        var payload = {
            ID: Number(document.getElementById('artID').value || 0),
            category_id: Number(document.getElementById('artCategory').value || 0),
            title: document.getElementById('artTitle').value || '',
            description: document.getElementById('artDescription').value || '',
            is_youtube_video: isYoutube,
            youtube_url: document.getElementById('artYoutubeUrl').value || '',
            content: document.getElementById('artContent').value || '',
            photo_path: document.getElementById('artPhotoPath').value || '',
            display_order: Number(document.getElementById('artOrder').value || 0),
            view_count: Number(document.getElementById('artViewCount').value || 0),
            visibility: document.getElementById('artVisibility').value || 'BOTH',
            status: document.getElementById('artStatus').value || 'DRAFT'
        };

        apiPost('?ajax=save_article', payload, function(res){
            if (!res.ok){
                document.getElementById('kbArticleResult').className = 'kb-result';
                document.getElementById('kbArticleResult').textContent = res.error || 'Unable to save article.';
                return;
            }
            document.getElementById('kbArticleResult').className = 'kb-result kb-result--ok';
            document.getElementById('kbArticleResult').textContent = res.message || 'Saved.';
            window.setTimeout(function(){ kbCloseModals(); kbLoadAll(); }, 250);
        }, function(err){
            document.getElementById('kbArticleResult').className = 'kb-result';
            document.getElementById('kbArticleResult').textContent = err;
        });
    };

    window.kbDeleteArticle = function(id){
        if (!confirm('Delete this article?')) return;
        apiPost('?ajax=delete_article', { id: Number(id || 0) }, function(res){
            if (!res.ok){ alert(res.error || 'Unable to delete article.'); return; }
            kbLoadAll();
        }, function(err){ alert(err); });
    };

    window.kbUploadPhoto = function(type){
        var fileInput = type === 'category' ? document.getElementById('catPhotoFile') : document.getElementById('artPhotoFile');
        var pathInput = type === 'category' ? document.getElementById('catPhotoPath') : document.getElementById('artPhotoPath');
        var preview = type === 'category' ? document.getElementById('catPhotoPreview') : document.getElementById('artPhotoPreview');
        var result = type === 'category' ? document.getElementById('kbCategoryResult') : document.getElementById('kbArticleResult');

        if (!fileInput.files || fileInput.files.length === 0){
            result.className = 'kb-result';
            result.textContent = 'Select an image first.';
            return;
        }

        var formData = new FormData();
        formData.append('file', fileInput.files[0]);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'KnowledgebaseManagement.aspx?ajax=upload_image&type=' + encodeURIComponent(type), true);
        xhr.onreadystatechange = function(){
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200){
                result.className = 'kb-result';
                result.textContent = 'Upload failed.';
                return;
            }
            try {
                var res = JSON.parse(xhr.responseText);
                if (!res.ok){
                    result.className = 'kb-result';
                    result.textContent = res.error || 'Upload failed.';
                    return;
                }
                pathInput.value = res.path || '';
                preview.src = pathInput.value;
                preview.style.display = pathInput.value ? 'inline-block' : 'none';
                result.className = 'kb-result kb-result--ok';
                result.textContent = res.message || 'Upload successful.';
            } catch(ex){
                result.className = 'kb-result';
                result.textContent = 'Invalid upload response.';
            }
        };
        xhr.send(formData);
    };

    window.kbCloseModals = function(){
        document.getElementById('kbOverlay').style.display = 'none';
        document.getElementById('kbCategoryModal').style.display = 'none';
        document.getElementById('kbArticleModal').style.display = 'none';
    };

    window.kbToggleYoutubeFields = function(){
        var isYoutube = document.getElementById('artIsYoutube').value === '1';
        var content = document.getElementById('artContent');
        if (isYoutube){
            content.placeholder = 'Optional notes for this YouTube video';
        } else {
            content.placeholder = 'Enter article content';
        }
    };

    if (document.readyState === 'loading'){
        document.addEventListener('DOMContentLoaded', function(){ window.kbLoadAll(); kbToggleYoutubeFields(); });
    } else {
        kbToggleYoutubeFields();
        window.kbLoadAll();
    }
})();
</script>
</asp:Content>
