using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using MySql.Data.MySqlClient;

public sealed class KnowledgebaseCategoryModel
{
    public int ID { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public string PhotoPath { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; }
}

public sealed class KnowledgebaseArticleModel
{
    public int ID { get; set; }
    public int CategoryID { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public string Content { get; set; }
    public string PhotoPath { get; set; }
    public int DisplayOrder { get; set; }
    public string Visibility { get; set; }
    public string Status { get; set; }
    public bool IsYoutubeVideo { get; set; }
    public string YoutubeUrl { get; set; }
    public int ViewCount { get; set; }
}

public sealed class KnowledgebaseArticleFilter
{
    public int CategoryID { get; set; }
    public string Status { get; set; }
    public string Visibility { get; set; }
    public string Search { get; set; }
}

public static class KnowledgebaseAdminShared
{
    public const string VisibilityStudents = "STUDENTS";
    public const string VisibilityEmployees = "EMPLOYEES";
    public const string VisibilityBoth = "BOTH";

    public const string StatusDraft = "DRAFT";
    public const string StatusPublished = "PUBLISHED";
    public const string StatusArchived = "ARCHIVED";

    public static string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    public static void EnsureSchema()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();

            ExecuteNonQuery(conn, @"
CREATE TABLE IF NOT EXISTS `sys_knowledgebase_categories` (
    `ID`            INT             NOT NULL AUTO_INCREMENT,
    `category_key`  VARCHAR(160)    NOT NULL,
    `title`         VARCHAR(200)    NOT NULL,
    `description`   TEXT            NULL,
    `photo_path`    VARCHAR(600)    NULL,
    `display_order` INT             NOT NULL DEFAULT 0,
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    `created_by`    VARCHAR(120)    NOT NULL DEFAULT '',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_by`    VARCHAR(120)    NULL,
    `updated_at`    DATETIME        NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uq_kb_category_key` (`category_key`),
    INDEX `idx_kb_category_order` (`is_active`, `display_order`, `title`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

            ExecuteNonQuery(conn, @"
CREATE TABLE IF NOT EXISTS `sys_knowledgebase_articles` (
    `ID`            INT             NOT NULL AUTO_INCREMENT,
    `category_id`   INT             NOT NULL,
    `article_key`   VARCHAR(180)    NOT NULL,
    `title`         VARCHAR(250)    NOT NULL,
    `description`   TEXT            NULL,
    `content`       MEDIUMTEXT      NOT NULL,
    `photo_path`    VARCHAR(600)    NULL,
    `is_youtube_video` TINYINT(1)   NOT NULL DEFAULT 0,
    `youtube_url`   VARCHAR(500)    NULL,
    `display_order` INT             NOT NULL DEFAULT 0,
    `view_count`    INT             NOT NULL DEFAULT 0,
    `visibility`    VARCHAR(20)     NOT NULL DEFAULT 'BOTH',
    `status`        VARCHAR(20)     NOT NULL DEFAULT 'DRAFT',
    `created_by`    VARCHAR(120)    NOT NULL DEFAULT '',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_by`    VARCHAR(120)    NULL,
    `updated_at`    DATETIME        NULL ON UPDATE CURRENT_TIMESTAMP,
    `published_at`  DATETIME        NULL,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uq_kb_article_key` (`article_key`),
    INDEX `idx_kb_article_cat` (`category_id`, `display_order`, `title`(100)),
    INDEX `idx_kb_article_status` (`status`, `visibility`, `display_order`),
    CONSTRAINT `fk_kb_article_category`
        FOREIGN KEY (`category_id`) REFERENCES `sys_knowledgebase_categories` (`ID`)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

            EnsureArticleColumn(conn, "is_youtube_video", "ALTER TABLE `sys_knowledgebase_articles` ADD COLUMN `is_youtube_video` TINYINT(1) NOT NULL DEFAULT 0 AFTER `photo_path`;");
            EnsureArticleColumn(conn, "youtube_url", "ALTER TABLE `sys_knowledgebase_articles` ADD COLUMN `youtube_url` VARCHAR(500) NULL AFTER `is_youtube_video`;");
            EnsureArticleColumn(conn, "view_count", "ALTER TABLE `sys_knowledgebase_articles` ADD COLUMN `view_count` INT NOT NULL DEFAULT 0 AFTER `display_order`;");
        }
    }

    private static void EnsureArticleColumn(MySqlConnection conn, string columnName, string alterSql)
    {
        object scalar = ExecuteScalar(conn,
            "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_knowledgebase_articles' AND COLUMN_NAME = @columnName;",
            new MySqlParameter("@columnName", columnName));
        if (Convert.ToInt32(scalar) <= 0)
        {
            ExecuteNonQuery(conn, alterSql);
        }
    }

    public static DataTable ListCategories()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            return ExecuteQuery(conn, @"
SELECT
    c.ID,
    c.category_key,
    c.title,
    c.description,
    c.photo_path,
    c.display_order,
    c.is_active,
    c.created_at,
    c.updated_at,
    COALESCE(a.article_count, 0) AS article_count
FROM sys_knowledgebase_categories c
LEFT JOIN (
    SELECT category_id, COUNT(*) AS article_count
    FROM sys_knowledgebase_articles
    GROUP BY category_id
) a ON a.category_id = c.ID
ORDER BY c.display_order ASC, c.title ASC;");
        }
    }

    public static DataRow GetCategory(int categoryId)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            DataTable dt = ExecuteQuery(conn,
                "SELECT * FROM sys_knowledgebase_categories WHERE ID = @id LIMIT 1;",
                new MySqlParameter("@id", categoryId));
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }
    }

    public static int SaveCategory(KnowledgebaseCategoryModel model, string actor)
    {
        if (model == null) throw new Exception("Category payload is required.");
        if (string.IsNullOrEmpty((model.Title ?? "").Trim())) throw new Exception("Category title is required.");

        string title = model.Title.Trim();
        string categoryKey = GenerateSlug(title, 150);

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();

            if (model.ID <= 0)
            {
                int suffix = 1;
                string baseKey = categoryKey;
                while (KeyExists(conn, "sys_knowledgebase_categories", "category_key", categoryKey, 0))
                {
                    suffix++;
                    categoryKey = baseKey + "-" + suffix;
                }

                ExecuteNonQuery(conn, @"
INSERT INTO sys_knowledgebase_categories
    (category_key, title, description, photo_path, display_order, is_active, created_by, updated_by)
VALUES
    (@key, @title, @desc, @photo, @order, @active, @actor, @actor);",
                    new MySqlParameter("@key", categoryKey),
                    new MySqlParameter("@title", title),
                    new MySqlParameter("@desc", NullIfEmpty(model.Description)),
                    new MySqlParameter("@photo", NullIfEmpty(model.PhotoPath)),
                    new MySqlParameter("@order", model.DisplayOrder),
                    new MySqlParameter("@active", model.IsActive ? 1 : 0),
                    new MySqlParameter("@actor", actor ?? ""));

                return Convert.ToInt32(ExecuteScalar(conn, "SELECT LAST_INSERT_ID();"));
            }

            if (KeyExists(conn, "sys_knowledgebase_categories", "category_key", categoryKey, model.ID))
            {
                categoryKey = categoryKey + "-" + model.ID;
            }

            ExecuteNonQuery(conn, @"
UPDATE sys_knowledgebase_categories
SET category_key = @key,
    title = @title,
    description = @desc,
    photo_path = @photo,
    display_order = @order,
    is_active = @active,
    updated_by = @actor
WHERE ID = @id;",
                new MySqlParameter("@key", categoryKey),
                new MySqlParameter("@title", title),
                new MySqlParameter("@desc", NullIfEmpty(model.Description)),
                new MySqlParameter("@photo", NullIfEmpty(model.PhotoPath)),
                new MySqlParameter("@order", model.DisplayOrder),
                new MySqlParameter("@active", model.IsActive ? 1 : 0),
                new MySqlParameter("@actor", actor ?? ""),
                new MySqlParameter("@id", model.ID));

            return model.ID;
        }
    }

    public static bool DeleteCategory(int categoryId, out string error)
    {
        error = string.Empty;
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();

            int articleCount = Convert.ToInt32(ExecuteScalar(conn,
                "SELECT COUNT(*) FROM sys_knowledgebase_articles WHERE category_id = @id;",
                new MySqlParameter("@id", categoryId)));

            if (articleCount > 0)
            {
                error = "Category has " + articleCount + " article(s). Move/delete articles first.";
                return false;
            }

            int rows = ExecuteNonQuery(conn,
                "DELETE FROM sys_knowledgebase_categories WHERE ID = @id;",
                new MySqlParameter("@id", categoryId));

            if (rows <= 0)
            {
                error = "Category not found or already deleted.";
                return false;
            }

            return true;
        }
    }

    public static DataTable ListArticles(KnowledgebaseArticleFilter filter)
    {
        if (filter == null) filter = new KnowledgebaseArticleFilter();

        StringBuilder sql = new StringBuilder();
        sql.Append(@"
SELECT
    a.ID,
    a.category_id,
    a.article_key,
    a.title,
    a.description,
    a.photo_path,
    a.is_youtube_video,
    a.youtube_url,
    a.display_order,
    a.view_count,
    a.visibility,
    a.status,
    a.published_at,
    a.created_at,
    a.updated_at,
    c.title AS category_title
FROM sys_knowledgebase_articles a
INNER JOIN sys_knowledgebase_categories c ON c.ID = a.category_id
WHERE 1=1");

        List<MySqlParameter> parameters = new List<MySqlParameter>();

        if (filter.CategoryID > 0)
        {
            sql.Append(" AND a.category_id = @categoryId");
            parameters.Add(new MySqlParameter("@categoryId", filter.CategoryID));
        }

        if (!string.IsNullOrEmpty(filter.Status))
        {
            sql.Append(" AND a.status = @status");
            parameters.Add(new MySqlParameter("@status", NormalizeStatus(filter.Status)));
        }

        if (!string.IsNullOrEmpty(filter.Visibility))
        {
            sql.Append(" AND a.visibility = @visibility");
            parameters.Add(new MySqlParameter("@visibility", NormalizeVisibility(filter.Visibility)));
        }

        if (!string.IsNullOrEmpty((filter.Search ?? string.Empty).Trim()))
        {
            sql.Append(" AND (a.title LIKE @search OR a.description LIKE @search OR a.content LIKE @search OR a.youtube_url LIKE @search)");
            parameters.Add(new MySqlParameter("@search", "%" + filter.Search.Trim() + "%"));
        }

        sql.Append(" ORDER BY c.display_order ASC, a.display_order ASC, a.title ASC;");

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            return ExecuteQuery(conn, sql.ToString(), parameters.ToArray());
        }
    }

    public static DataRow GetArticle(int articleId)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            DataTable dt = ExecuteQuery(conn,
                "SELECT * FROM sys_knowledgebase_articles WHERE ID = @id LIMIT 1;",
                new MySqlParameter("@id", articleId));
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }
    }

    public static int SaveArticle(KnowledgebaseArticleModel model, string actor)
    {
        if (model == null) throw new Exception("Article payload is required.");
        if (model.CategoryID <= 0) throw new Exception("Article category is required.");
        if (string.IsNullOrEmpty((model.Title ?? "").Trim())) throw new Exception("Article title is required.");
        if (!model.IsYoutubeVideo && string.IsNullOrEmpty((model.Content ?? "").Trim())) throw new Exception("Article content is required.");
        if (model.IsYoutubeVideo && string.IsNullOrEmpty((model.YoutubeUrl ?? "").Trim())) throw new Exception("YouTube URL is required for YouTube video articles.");

        string title = model.Title.Trim();
        string articleKey = GenerateSlug(title, 170);
        string visibility = NormalizeVisibility(model.Visibility);
        string status = NormalizeStatus(model.Status);
        string youtubeUrl = NullIfEmpty(model.YoutubeUrl) == DBNull.Value ? string.Empty : model.YoutubeUrl.Trim();

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();

            // Validate parent category exists
            int categoryExists = Convert.ToInt32(ExecuteScalar(conn,
                "SELECT COUNT(*) FROM sys_knowledgebase_categories WHERE ID = @id;",
                new MySqlParameter("@id", model.CategoryID)));
            if (categoryExists <= 0) throw new Exception("Selected category was not found.");

            if (model.ID <= 0)
            {
                int suffix = 1;
                string baseKey = articleKey;
                while (KeyExists(conn, "sys_knowledgebase_articles", "article_key", articleKey, 0))
                {
                    suffix++;
                    articleKey = baseKey + "-" + suffix;
                }

                ExecuteNonQuery(conn, @"
INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, photo_path,
     is_youtube_video, youtube_url, display_order, view_count, visibility, status, created_by, updated_by, published_at)
VALUES
    (@cat, @key, @title, @desc, @content, @photo,
     @isYoutube, @youtubeUrl, @order, 0, @visibility, @status, @actor, @actor,
     CASE WHEN @status = 'PUBLISHED' THEN NOW() ELSE NULL END);",
                    new MySqlParameter("@cat", model.CategoryID),
                    new MySqlParameter("@key", articleKey),
                    new MySqlParameter("@title", title),
                    new MySqlParameter("@desc", NullIfEmpty(model.Description)),
                    new MySqlParameter("@content", (model.Content ?? string.Empty).Trim()),
                    new MySqlParameter("@photo", NullIfEmpty(model.PhotoPath)),
                    new MySqlParameter("@isYoutube", model.IsYoutubeVideo ? 1 : 0),
                    new MySqlParameter("@youtubeUrl", model.IsYoutubeVideo ? NullIfEmpty(youtubeUrl) : DBNull.Value),
                    new MySqlParameter("@order", model.DisplayOrder),
                    new MySqlParameter("@visibility", visibility),
                    new MySqlParameter("@status", status),
                    new MySqlParameter("@actor", actor ?? ""));

                return Convert.ToInt32(ExecuteScalar(conn, "SELECT LAST_INSERT_ID();"));
            }

            if (KeyExists(conn, "sys_knowledgebase_articles", "article_key", articleKey, model.ID))
            {
                articleKey = articleKey + "-" + model.ID;
            }

            ExecuteNonQuery(conn, @"
UPDATE sys_knowledgebase_articles
SET category_id = @cat,
    article_key = @key,
    title = @title,
    description = @desc,
    content = @content,
    photo_path = @photo,
    is_youtube_video = @isYoutube,
    youtube_url = @youtubeUrl,
    display_order = @order,
    visibility = @visibility,
    status = @status,
    updated_by = @actor,
    published_at = CASE
        WHEN @status = 'PUBLISHED' AND published_at IS NULL THEN NOW()
        WHEN @status <> 'PUBLISHED' THEN NULL
        ELSE published_at
    END
WHERE ID = @id;",
                new MySqlParameter("@cat", model.CategoryID),
                new MySqlParameter("@key", articleKey),
                new MySqlParameter("@title", title),
                new MySqlParameter("@desc", NullIfEmpty(model.Description)),
                new MySqlParameter("@content", (model.Content ?? string.Empty).Trim()),
                new MySqlParameter("@photo", NullIfEmpty(model.PhotoPath)),
                new MySqlParameter("@isYoutube", model.IsYoutubeVideo ? 1 : 0),
                new MySqlParameter("@youtubeUrl", model.IsYoutubeVideo ? NullIfEmpty(youtubeUrl) : DBNull.Value),
                new MySqlParameter("@order", model.DisplayOrder),
                new MySqlParameter("@visibility", visibility),
                new MySqlParameter("@status", status),
                new MySqlParameter("@actor", actor ?? ""),
                new MySqlParameter("@id", model.ID));

            return model.ID;
        }
    }

    public static bool DeleteArticle(int articleId, out string error)
    {
        error = string.Empty;
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            int rows = ExecuteNonQuery(conn,
                "DELETE FROM sys_knowledgebase_articles WHERE ID = @id;",
                new MySqlParameter("@id", articleId));

            if (rows <= 0)
            {
                error = "Article not found or already deleted.";
                return false;
            }

            return true;
        }
    }

    public static DataTable GetStats()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            return ExecuteQuery(conn, @"
SELECT
    (SELECT COUNT(*) FROM sys_knowledgebase_categories) AS category_count,
    (SELECT COUNT(*) FROM sys_knowledgebase_categories WHERE is_active = 1) AS active_category_count,
    (SELECT COUNT(*) FROM sys_knowledgebase_articles) AS article_count,
    (SELECT COUNT(*) FROM sys_knowledgebase_articles WHERE status = 'PUBLISHED') AS published_article_count,
    (SELECT COUNT(*) FROM sys_knowledgebase_articles WHERE status = 'DRAFT') AS draft_article_count,
    (SELECT COUNT(*) FROM sys_knowledgebase_articles WHERE status = 'ARCHIVED') AS archived_article_count;");
        }
    }

    public static string NormalizeVisibility(string value)
    {
        string v = (value ?? string.Empty).Trim().ToUpper();
        if (v == VisibilityStudents || v == VisibilityEmployees || v == VisibilityBoth) return v;
        return VisibilityBoth;
    }

    public static string NormalizeStatus(string value)
    {
        string v = (value ?? string.Empty).Trim().ToUpper();
        if (v == StatusDraft || v == StatusPublished || v == StatusArchived) return v;
        return StatusDraft;
    }

    private static bool KeyExists(MySqlConnection conn, string tableName, string keyColumn, string keyValue, int excludingId)
    {
        object scalar = ExecuteScalar(conn,
            "SELECT COUNT(*) FROM " + tableName + " WHERE " + keyColumn + " = @key AND (@id <= 0 OR ID <> @id);",
            new MySqlParameter("@key", keyValue),
            new MySqlParameter("@id", excludingId));

        return Convert.ToInt32(scalar) > 0;
    }

    public static string GenerateSlug(string value, int maxLength)
    {
        string text = (value ?? string.Empty).Trim().ToLowerInvariant();
        if (text.Length == 0) return "item";

        StringBuilder sb = new StringBuilder();
        bool lastDash = false;

        for (int i = 0; i < text.Length; i++)
        {
            char ch = text[i];
            bool isAlphaNum = (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9');

            if (isAlphaNum)
            {
                sb.Append(ch);
                lastDash = false;
            }
            else
            {
                if (!lastDash)
                {
                    sb.Append('-');
                    lastDash = true;
                }
            }
        }

        string slug = sb.ToString().Trim('-');
        if (slug.Length == 0) slug = "item";
        if (slug.Length > maxLength) slug = slug.Substring(0, maxLength).Trim('-');
        if (slug.Length == 0) slug = "item";
        return slug;
    }

    private static object NullIfEmpty(string value)
    {
        if (string.IsNullOrEmpty((value ?? string.Empty).Trim())) return DBNull.Value;
        return value.Trim();
    }

    private static DataTable ExecuteQuery(MySqlConnection conn, string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parms != null)
            {
                for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
            }
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        return dt;
    }

    private static int ExecuteNonQuery(MySqlConnection conn, string sql, params MySqlParameter[] parms)
    {
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parms != null)
            {
                for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
            }
            return cmd.ExecuteNonQuery();
        }
    }

    private static object ExecuteScalar(MySqlConnection conn, string sql, params MySqlParameter[] parms)
    {
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parms != null)
            {
                for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
            }
            return cmd.ExecuteScalar();
        }
    }
}
