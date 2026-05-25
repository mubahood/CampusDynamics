using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Caching;
using MySql.Data.MySqlClient;

public partial class API_v2_knowledgebase : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;
        if (ApiHelper.IsRateLimited(Request, Response)) return;

        try { KnowledgebaseAdminShared.EnsureSchema(); } catch { }

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "categories":       HandleCategories();     break;
                case "articles":         HandleArticles();       break;
                case "article":          HandleArticle();        break;
                case "search":           HandleSearch();         break;
                case "save_category":    HandleSaveCategory();   break;
                case "delete_category":  HandleDeleteCategory(); break;
                case "save_article":     HandleSaveArticle();    break;
                case "delete_article":   HandleDeleteArticle();  break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". Valid actions: categories, articles, article, search, save_category, delete_category, save_article, delete_article",
                        "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CATEGORIES  — all active categories ordered by display_order
    // ═══════════════════════════════════════════════════════════════════

    private void HandleCategories()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        DataTable dt = KnowledgebaseAdminShared.ListCategories();

        var rows = ApiHelper.TableToList(dt);

        // Filter inactive for non-admin students
        if (auth.UserType != "staff")
        {
            var filtered = new List<Dictionary<string, object>>();
            foreach (var row in rows)
            {
                bool isActive = row.ContainsKey("is_active") && Convert.ToInt32(row["is_active"]) == 1;
                if (isActive) filtered.Add(row);
            }
            rows = filtered;
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", rows.Count },
            { "categories", rows }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ARTICLES  — articles in a category, optional search
    // ═══════════════════════════════════════════════════════════════════

    private void HandleArticles()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff = auth.UserType == "staff";

        int categoryId  = ApiHelper.ParamInt(Request, "category_id", 0);
        string search   = ApiHelper.Param(Request, "search", "");
        string statusF  = ApiHelper.Param(Request, "status", "");
        int page        = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size        = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 20)));
        int offset      = (page - 1) * size;

        var filter = new KnowledgebaseArticleFilter
        {
            CategoryID = categoryId,
            Search     = search,
            Status     = isStaff ? statusF : KnowledgebaseAdminShared.StatusPublished,
            Visibility = isStaff ? "" : (auth.UserType == "staff" ? KnowledgebaseAdminShared.VisibilityEmployees : KnowledgebaseAdminShared.VisibilityStudents)
        };

        DataTable dt = KnowledgebaseAdminShared.ListArticles(filter);
        var allRows = ApiHelper.TableToList(dt);

        // Strip content for list view (keep description only)
        foreach (var row in allRows)
            if (row.ContainsKey("content")) row.Remove("content");

        // Manual pagination since ListArticles returns all
        int total = allRows.Count;
        var page_rows = new List<Dictionary<string, object>>();
        for (int i = offset; i < Math.Min(offset + size, total); i++)
            page_rows.Add(allRows[i]);

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "articles", page_rows }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ARTICLE  — single article (full content), increments view_count
    // ═══════════════════════════════════════════════════════════════════

    private void HandleArticle()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff = auth.UserType == "staff";

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        DataRow row = KnowledgebaseAdminShared.GetArticle(id);
        if (row == null) { ApiHelper.Error(Response, "Article not found.", "NOT_FOUND"); return; }

        string status     = row["status"].ToString();
        string visibility = row["visibility"].ToString();

        // Non-admin cannot see drafts
        if (!isStaff && status != KnowledgebaseAdminShared.StatusPublished)
        {
            ApiHelper.Error(Response, "Article not found.", "NOT_FOUND"); return;
        }

        // Visibility check
        if (!isStaff)
        {
            if (visibility == KnowledgebaseAdminShared.VisibilityEmployees)
            {
                ApiHelper.Error(Response, "Article not available.", "FORBIDDEN"); return;
            }
        }

        // Increment view_count — debounced per (user, article, day)
        string debounceKey = "kbview_" + auth.UserId + "_" + id + "_" + DateTime.Now.ToString("yyyyMMdd");
        if (HttpRuntime.Cache[debounceKey] == null)
        {
            try
            {
                ApiHelper.Execute(
                    "UPDATE sys_knowledgebase_articles SET view_count = view_count + 1 WHERE ID = @id",
                    new MySqlParameter("@id", id));
            }
            catch { }
            HttpRuntime.Cache.Insert(debounceKey, 1, null,
                DateTime.Now.AddHours(24), Cache.NoSlidingExpiration);
        }

        var article = DataRowToDict(row);
        ApiHelper.Success(Response, article);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SEARCH  — full-text search across title, description, content
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSearch()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        bool isStaff = auth.UserType == "staff";

        string q    = ApiHelper.Param(Request, "q", "").Trim();
        if (string.IsNullOrEmpty(q)) { ApiHelper.Error(Response, "q (search term) is required.", "MISSING_PARAM"); return; }

        int page = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size = Math.Min(50, Math.Max(1, ApiHelper.ParamInt(Request, "size", 10)));
        int offset = (page - 1) * size;

        string visWhere = isStaff ? "" : " AND a.status = 'PUBLISHED' AND a.visibility IN ('STUDENTS','BOTH')";
        string like = "%" + q + "%";

        string countSql = @"SELECT COUNT(*) FROM sys_knowledgebase_articles a
                            WHERE (a.title LIKE @q OR a.description LIKE @q OR a.content LIKE @q)" + visWhere;
        int total = Convert.ToInt32(ApiHelper.Query(countSql, new MySqlParameter("@q", like)).Rows[0][0]);

        string dataSql = @"SELECT a.ID, a.category_id, c.title AS category_title,
                                  a.title, a.description, a.display_order,
                                  a.view_count, a.visibility, a.status,
                                  a.is_youtube_video, a.youtube_url, a.created_at, a.updated_at
                           FROM sys_knowledgebase_articles a
                           LEFT JOIN sys_knowledgebase_categories c ON c.ID = a.category_id
                           WHERE (a.title LIKE @q OR a.description LIKE @q OR a.content LIKE @q)" + visWhere +
                         " ORDER BY a.view_count DESC, a.display_order, a.title LIMIT @lim OFFSET @off";

        DataTable dt = ApiHelper.Query(dataSql,
            new MySqlParameter("@q", like),
            new MySqlParameter("@lim", size),
            new MySqlParameter("@off", offset));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "query", q }, { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "results", ApiHelper.TableToList(dt) }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SAVE_CATEGORY  — create or update (admin/staff only)
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSaveCategory()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int id              = ApiHelper.ParamInt(Request, "id", 0);
        string title        = ApiHelper.RequireParam(Request, Response, "title"); if (title == null) return;
        string description  = ApiHelper.Param(Request, "description", "");
        string photoPath    = ApiHelper.Param(Request, "photo_path", "");
        int displayOrder    = ApiHelper.ParamInt(Request, "display_order", 0);
        bool isActive       = ApiHelper.Param(Request, "is_active", "1") == "1";

        var model = new KnowledgebaseCategoryModel
        {
            ID           = id,
            Title        = title,
            Description  = description,
            PhotoPath    = photoPath,
            DisplayOrder = displayOrder,
            IsActive     = isActive
        };

        int savedId = KnowledgebaseAdminShared.SaveCategory(model, auth.UserId);

        ApiHelper.Success(Response, new Dictionary<string, object> { { "id", savedId } },
            id == 0 ? "Category created" : "Category updated");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DELETE_CATEGORY  — only if no published articles remain
    // ═══════════════════════════════════════════════════════════════════

    private void HandleDeleteCategory()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        string delCatError;
        bool catDeleted = KnowledgebaseAdminShared.DeleteCategory(id, out delCatError);
        if (!catDeleted)
        {
            ApiHelper.Error(Response, delCatError, "DELETE_FAILED"); return;
        }
        ApiHelper.Success(Response, new Dictionary<string, object> { { "deleted_id", id } }, "Category deleted");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SAVE_ARTICLE  — create or update (admin/staff only)
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSaveArticle()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int id            = ApiHelper.ParamInt(Request, "id", 0);
        int categoryId    = ApiHelper.ParamInt(Request, "category_id", 0);
        string title      = ApiHelper.RequireParam(Request, Response, "title"); if (title == null) return;
        string content    = ApiHelper.Param(Request, "content", "");
        string description= ApiHelper.Param(Request, "description", "");
        string visibility = ApiHelper.Param(Request, "visibility", KnowledgebaseAdminShared.VisibilityBoth).ToUpper();
        string status     = ApiHelper.Param(Request, "status", KnowledgebaseAdminShared.StatusDraft).ToUpper();
        int displayOrder  = ApiHelper.ParamInt(Request, "display_order", 0);
        string photoPath  = ApiHelper.Param(Request, "photo_path", "");
        bool isYoutube    = ApiHelper.Param(Request, "is_youtube_video", "0") == "1";
        string youtubeUrl = ApiHelper.Param(Request, "youtube_url", "");

        // For updates, look up existing category_id if not provided
        if (categoryId <= 0 && id > 0)
        {
            DataRow existing = KnowledgebaseAdminShared.GetArticle(id);
            if (existing != null) categoryId = Convert.ToInt32(existing["category_id"]);
        }
        if (categoryId <= 0)
        {
            ApiHelper.Error(Response, "category_id is required for new articles.", "MISSING_PARAM"); return;
        }

        // Validate visibility
        string[] validVis = { "STUDENTS", "EMPLOYEES", "BOTH" };
        bool visOk = false;
        foreach (var v in validVis) if (v == visibility) { visOk = true; break; }
        if (!visOk) visibility = KnowledgebaseAdminShared.VisibilityBoth;

        // Validate status
        string[] validSt = { "DRAFT", "PUBLISHED", "ARCHIVED" };
        bool stOk = false;
        foreach (var s in validSt) if (s == status) { stOk = true; break; }
        if (!stOk) status = KnowledgebaseAdminShared.StatusDraft;

        var model = new KnowledgebaseArticleModel
        {
            ID            = id,
            CategoryID    = categoryId,
            Title         = title,
            Description   = description,
            Content       = content,
            PhotoPath     = photoPath,
            DisplayOrder  = displayOrder,
            Visibility    = visibility,
            Status        = status,
            IsYoutubeVideo= isYoutube,
            YoutubeUrl    = youtubeUrl
        };

        int savedId = KnowledgebaseAdminShared.SaveArticle(model, auth.UserId);

        ApiHelper.Success(Response, new Dictionary<string, object> { { "id", savedId } },
            id == 0 ? "Article created" : "Article updated");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DELETE_ARTICLE
    // ═══════════════════════════════════════════════════════════════════

    private void HandleDeleteArticle()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        DataRow existing = KnowledgebaseAdminShared.GetArticle(id);
        if (existing == null) { ApiHelper.Error(Response, "Article not found.", "NOT_FOUND"); return; }

        string delArtError;
        bool artDeleted = KnowledgebaseAdminShared.DeleteArticle(id, out delArtError);
        if (!artDeleted)
        {
            ApiHelper.Error(Response, delArtError, "DELETE_FAILED"); return;
        }
        ApiHelper.Success(Response, new Dictionary<string, object> { { "deleted_id", id } }, "Article deleted");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════

    private Dictionary<string, object> DataRowToDict(DataRow row)
    {
        var dict = new Dictionary<string, object>();
        foreach (DataColumn col in row.Table.Columns)
            dict[col.ColumnName] = row[col] == DBNull.Value ? null : row[col];
        return dict;
    }
}
