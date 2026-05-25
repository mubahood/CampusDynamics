using System;
using System.Collections.Generic;
using System.IO;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;

public partial class COOPERP_NewScreens_KnowledgebaseManagement : System.Web.UI.Page
{
    private string UploadDir
    {
        get { return "~/Data_Uploads/Knowledgebase/"; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request.QueryString["ajax"] ?? string.Empty).Trim().ToLower();

        try
        {
            KnowledgebaseAdminShared.EnsureSchema();

            if (string.IsNullOrEmpty(ajax)) return;

            switch (ajax)
            {
                case "bootstrap":
                    HandleBootstrap();
                    break;
                case "list_categories":
                    HandleListCategories();
                    break;
                case "get_category":
                    HandleGetCategory();
                    break;
                case "save_category":
                    HandleSaveCategory();
                    break;
                case "delete_category":
                    HandleDeleteCategory();
                    break;
                case "list_articles":
                    HandleListArticles();
                    break;
                case "get_article":
                    HandleGetArticle();
                    break;
                case "save_article":
                    HandleSaveArticle();
                    break;
                case "delete_article":
                    HandleDeleteArticle();
                    break;
                case "upload_image":
                    HandleUploadImage();
                    break;
                default:
                    WriteJson(new { ok = false, error = "Unknown action: " + ajax });
                    break;
            }
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Response.End
        }
        catch (Exception ex)
        {
            WriteJson(new { ok = false, error = ex.Message });
        }
    }

    private void HandleBootstrap()
    {
        DataTable stats = KnowledgebaseAdminShared.GetStats();
        DataTable categories = KnowledgebaseAdminShared.ListCategories();
        DataTable articles = KnowledgebaseAdminShared.ListArticles(new KnowledgebaseArticleFilter());

        WriteJson(new
        {
            ok = true,
            stats = stats.Rows.Count > 0 ? RowToDictionary(stats.Rows[0]) : new Dictionary<string, object>(),
            categories = RowsToList(categories),
            articles = RowsToList(articles)
        });
    }

    private void HandleListCategories()
    {
        DataTable categories = KnowledgebaseAdminShared.ListCategories();
        WriteJson(new { ok = true, rows = RowsToList(categories) });
    }

    private void HandleGetCategory()
    {
        int id = ToInt(Request.QueryString["id"]);
        if (id <= 0)
        {
            WriteJson(new { ok = false, error = "Invalid category ID." });
            return;
        }

        DataRow row = KnowledgebaseAdminShared.GetCategory(id);
        if (row == null)
        {
            WriteJson(new { ok = false, error = "Category not found." });
            return;
        }

        WriteJson(new { ok = true, row = RowToDictionary(row) });
    }

    private void HandleSaveCategory()
    {
        Dictionary<string, object> payload = ReadJsonBody();

        KnowledgebaseCategoryModel model = new KnowledgebaseCategoryModel();
        model.ID = DictInt(payload, "ID");
        model.Title = DictStr(payload, "title");
        model.Description = DictStr(payload, "description");
        model.PhotoPath = DictStr(payload, "photo_path");
        model.DisplayOrder = DictInt(payload, "display_order");
        model.IsActive = DictBool(payload, "is_active", true);

        string actor = GetActor();
        int id = KnowledgebaseAdminShared.SaveCategory(model, actor);

        WriteJson(new { ok = true, id = id, message = model.ID <= 0 ? "Category created successfully." : "Category updated successfully." });
    }

    private void HandleDeleteCategory()
    {
        Dictionary<string, object> payload = ReadJsonBody();
        int id = DictInt(payload, "id");

        if (id <= 0)
        {
            WriteJson(new { ok = false, error = "Invalid category ID." });
            return;
        }

        string error;
        if (!KnowledgebaseAdminShared.DeleteCategory(id, out error))
        {
            WriteJson(new { ok = false, error = error });
            return;
        }

        WriteJson(new { ok = true, message = "Category deleted successfully." });
    }

    private void HandleListArticles()
    {
        KnowledgebaseArticleFilter filter = new KnowledgebaseArticleFilter();
        filter.CategoryID = ToInt(Request.QueryString["categoryId"]);
        filter.Status = (Request.QueryString["status"] ?? string.Empty).Trim();
        filter.Visibility = (Request.QueryString["visibility"] ?? string.Empty).Trim();
        filter.Search = (Request.QueryString["search"] ?? string.Empty).Trim();

        DataTable dt = KnowledgebaseAdminShared.ListArticles(filter);
        WriteJson(new { ok = true, rows = RowsToList(dt) });
    }

    private void HandleGetArticle()
    {
        int id = ToInt(Request.QueryString["id"]);
        if (id <= 0)
        {
            WriteJson(new { ok = false, error = "Invalid article ID." });
            return;
        }

        DataRow row = KnowledgebaseAdminShared.GetArticle(id);
        if (row == null)
        {
            WriteJson(new { ok = false, error = "Article not found." });
            return;
        }

        WriteJson(new { ok = true, row = RowToDictionary(row) });
    }

    private void HandleSaveArticle()
    {
        Dictionary<string, object> payload = ReadJsonBody();

        KnowledgebaseArticleModel model = new KnowledgebaseArticleModel();
        model.ID = DictInt(payload, "ID");
        model.CategoryID = DictInt(payload, "category_id");
        model.Title = DictStr(payload, "title");
        model.Description = DictStr(payload, "description");
        model.Content = DictStr(payload, "content");
        model.PhotoPath = DictStr(payload, "photo_path");
        model.IsYoutubeVideo = DictBool(payload, "is_youtube_video", false);
        model.YoutubeUrl = DictStr(payload, "youtube_url");
        model.DisplayOrder = DictInt(payload, "display_order");
        model.ViewCount = DictInt(payload, "view_count");
        model.Visibility = DictStr(payload, "visibility");
        model.Status = DictStr(payload, "status");

        string actor = GetActor();
        int id = KnowledgebaseAdminShared.SaveArticle(model, actor);

        WriteJson(new { ok = true, id = id, message = model.ID <= 0 ? "Article created successfully." : "Article updated successfully." });
    }

    private void HandleDeleteArticle()
    {
        Dictionary<string, object> payload = ReadJsonBody();
        int id = DictInt(payload, "id");

        if (id <= 0)
        {
            WriteJson(new { ok = false, error = "Invalid article ID." });
            return;
        }

        string error;
        if (!KnowledgebaseAdminShared.DeleteArticle(id, out error))
        {
            WriteJson(new { ok = false, error = error });
            return;
        }

        WriteJson(new { ok = true, message = "Article deleted successfully." });
    }

    private void HandleUploadImage()
    {
        HttpPostedFile file = Request.Files["file"];
        if (file == null || file.ContentLength <= 0)
        {
            WriteJson(new { ok = false, error = "No file uploaded." });
            return;
        }

        string ext = Path.GetExtension(file.FileName ?? string.Empty).ToLowerInvariant();
        string[] allowed = new string[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
        bool allowedExt = false;
        for (int i = 0; i < allowed.Length; i++)
        {
            if (ext == allowed[i]) { allowedExt = true; break; }
        }
        if (!allowedExt)
        {
            WriteJson(new { ok = false, error = "Unsupported file type. Use JPG, PNG, GIF, or WEBP." });
            return;
        }

        int maxBytes = 5 * 1024 * 1024;
        if (file.ContentLength > maxBytes)
        {
            WriteJson(new { ok = false, error = "Image size must be 5MB or less." });
            return;
        }

        string physicalFolder = EnsureUploadFolder();
        string uniqueName = "kb_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + ext;
        string savePath = Path.Combine(physicalFolder, uniqueName);
        file.SaveAs(savePath);

        string relativePath = ResolveUrl(UploadDir + uniqueName);
        WriteJson(new { ok = true, path = relativePath, message = "Image uploaded successfully." });
    }

    private string EnsureUploadFolder()
    {
        string path = Server.MapPath(UploadDir);
        if (!Directory.Exists(path)) Directory.CreateDirectory(path);
        return path;
    }

    private string GetActor()
    {
        string actor = SafeSession("username");
        if (string.IsNullOrEmpty(actor)) actor = SafeSession("regno");
        if (string.IsNullOrEmpty(actor)) actor = "system";
        return actor;
    }

    private string SafeSession(string key)
    {
        object value = Session[key];
        return value == null ? string.Empty : value.ToString();
    }

    private int ToInt(string value)
    {
        int parsed;
        return int.TryParse((value ?? string.Empty).Trim(), out parsed) ? parsed : 0;
    }

    private Dictionary<string, object> ReadJsonBody()
    {
        Request.InputStream.Position = 0;
        using (StreamReader reader = new StreamReader(Request.InputStream))
        {
            string json = reader.ReadToEnd();
            if (string.IsNullOrEmpty(json)) return new Dictionary<string, object>();
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = int.MaxValue;
            return serializer.Deserialize<Dictionary<string, object>>(json);
        }
    }

    private int DictInt(Dictionary<string, object> d, string key)
    {
        if (d == null) return 0;
        object value;
        if (!d.TryGetValue(key, out value) || value == null) return 0;
        int parsed;
        return int.TryParse(value.ToString(), out parsed) ? parsed : 0;
    }

    private string DictStr(Dictionary<string, object> d, string key)
    {
        if (d == null) return string.Empty;
        object value;
        if (!d.TryGetValue(key, out value) || value == null) return string.Empty;
        return value.ToString().Trim();
    }

    private bool DictBool(Dictionary<string, object> d, string key, bool defaultValue)
    {
        if (d == null) return defaultValue;
        object value;
        if (!d.TryGetValue(key, out value) || value == null) return defaultValue;

        string raw = value.ToString().Trim().ToLower();
        if (raw == "1" || raw == "true" || raw == "yes") return true;
        if (raw == "0" || raw == "false" || raw == "no") return false;
        return defaultValue;
    }

    private List<Dictionary<string, object>> RowsToList(DataTable dt)
    {
        List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
        if (dt == null) return list;

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            list.Add(RowToDictionary(dt.Rows[i]));
        }
        return list;
    }

    private Dictionary<string, object> RowToDictionary(DataRow row)
    {
        Dictionary<string, object> dict = new Dictionary<string, object>();
        if (row == null) return dict;

        for (int i = 0; i < row.Table.Columns.Count; i++)
        {
            string key = row.Table.Columns[i].ColumnName;
            object val = row[i];
            dict[key] = (val == DBNull.Value) ? null : val;
        }
        return dict;
    }

    private void WriteJson(object payload)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;

        Response.Clear();
        Response.ContentType = "application/json";
        Response.Write(serializer.Serialize(payload));
        Response.End();
    }
}
