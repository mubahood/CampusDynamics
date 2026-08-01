using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_Knowledgebase : System.Web.UI.Page
{
    // eadmin users are staff, so the learning library shows EMPLOYEES + BOTH content.
    private const string Audience = "EMPLOYEES";

    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request.QueryString["ajax"] ?? string.Empty).Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        try
        {
            try { KnowledgebaseAdminShared.EnsureSchema(); }
            catch { }

            switch (ajax)
            {
                case "list":
                    HandleList();
                    break;
                case "record_view":
                    HandleRecordView();
                    break;
                default:
                    WriteJson(new { ok = false, error = "Unknown action." });
                    break;
            }
        }
        catch (System.Threading.ThreadAbortException)
        {
        }
        catch (Exception ex)
        {
            WriteJson(new { ok = false, error = ex.Message });
        }
    }

    private void HandleList()
    {
        string sql = @"
SELECT
    c.ID AS category_id,
    c.title AS category_title,
    c.description AS category_description,
    c.display_order AS category_order,
    a.ID,
    a.title,
    a.description,
    a.content,
    a.photo_path,
    a.display_order,
    a.visibility,
    a.status,
    a.is_youtube_video,
    a.youtube_url,
    a.view_count,
    a.published_at
FROM sys_knowledgebase_categories c
INNER JOIN sys_knowledgebase_articles a ON a.category_id = c.ID
WHERE c.is_active = 1
  AND a.status = 'PUBLISHED'
  AND (a.visibility = 'BOTH' OR a.visibility = @audience)
ORDER BY c.display_order ASC, c.title ASC, a.display_order ASC, a.title ASC;";

        DataTable dt = ExecuteQuery(sql, new MySqlParameter("@audience", Audience));

        List<Dictionary<string, object>> categories = new List<Dictionary<string, object>>();
        Dictionary<int, Dictionary<string, object>> map = new Dictionary<int, Dictionary<string, object>>();

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            DataRow row = dt.Rows[i];
            int categoryId = SafeInt(row["category_id"]);

            Dictionary<string, object> category;
            if (!map.TryGetValue(categoryId, out category))
            {
                category = new Dictionary<string, object>();
                category["ID"] = categoryId;
                category["title"] = SafeStr(row["category_title"]);
                category["description"] = SafeStr(row["category_description"]);
                category["display_order"] = SafeInt(row["category_order"]);
                category["articles"] = new List<Dictionary<string, object>>();
                map[categoryId] = category;
                categories.Add(category);
            }

            List<Dictionary<string, object>> list = (List<Dictionary<string, object>>)category["articles"];
            list.Add(new Dictionary<string, object>
            {
                { "ID", SafeInt(row["ID"]) },
                { "title", SafeStr(row["title"]) },
                { "description", SafeStr(row["description"]) },
                { "content", SafeStr(row["content"]) },
                { "photo_path", SafeStr(row["photo_path"]) },
                { "display_order", SafeInt(row["display_order"]) },
                { "visibility", SafeStr(row["visibility"]) },
                { "status", SafeStr(row["status"]) },
                { "is_youtube_video", SafeInt(row["is_youtube_video"]) },
                { "youtube_url", SafeStr(row["youtube_url"]) },
                { "view_count", SafeInt(row["view_count"]) },
                { "published_at", SafeStr(row["published_at"]) }
            });
        }

        WriteJson(new { ok = true, audience = Audience, categories = categories });
    }

    private void HandleRecordView()
    {
        Dictionary<string, object> payload = ReadJsonBody();
        int id = DictInt(payload, "id");
        if (id <= 0)
        {
            WriteJson(new { ok = false, error = "Invalid article ID." });
            return;
        }

        int updated = ExecuteNonQuery(@"
UPDATE sys_knowledgebase_articles
SET view_count = COALESCE(view_count, 0) + 1
WHERE ID = @id
  AND status = 'PUBLISHED'
  AND (visibility = 'BOTH' OR visibility = @audience);",
            new MySqlParameter("@id", id),
            new MySqlParameter("@audience", Audience));

        if (updated <= 0)
        {
            WriteJson(new { ok = false, error = "Article not found or not available." });
            return;
        }

        object scalar = ExecuteScalar("SELECT COALESCE(view_count,0) FROM sys_knowledgebase_articles WHERE ID = @id LIMIT 1;",
            new MySqlParameter("@id", id));
        int views = scalar == null || scalar == DBNull.Value ? 0 : Convert.ToInt32(scalar);

        WriteJson(new { ok = true, view_count = views });
    }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) da.Fill(dt);
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private object ExecuteScalar(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
                return cmd.ExecuteScalar();
            }
        }
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

    private int SafeInt(object value)
    {
        if (value == null || value == DBNull.Value) return 0;
        int parsed;
        return int.TryParse(value.ToString(), out parsed) ? parsed : 0;
    }

    private string SafeStr(object value)
    {
        return value == null || value == DBNull.Value ? string.Empty : value.ToString();
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
