-- ============================================================================
-- kb_admin_marks_videos.sql
-- Posts the admin/marks-processing tutorial videos (playlist items 22-27) into
-- the knowledge base. Idempotent: safe to run more than once (keyed on
-- category_key / article_key). Target DB: campus_dynamics.
-- ============================================================================
USE campus_dynamics;

-- 1) Category ---------------------------------------------------------------
INSERT INTO sys_knowledgebase_categories (category_key, title, description, display_order, is_active, created_by, updated_by)
SELECT 'marks-processing-administration',
       'Marks Processing & Administration',
       'Step-by-step guides for administrators, HODs, deans and the board of examiners on capturing, approving, exporting and publishing student results in the university portal.',
       20, 1, 'system', 'system'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_categories WHERE category_key='marks-processing-administration');

SET @cat := (SELECT ID FROM sys_knowledgebase_categories WHERE category_key='marks-processing-administration' LIMIT 1);

-- 2) Articles (YouTube videos) ---------------------------------------------
-- Reusable insert pattern keyed on article_key.
INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, is_youtube_video, youtube_url, display_order, visibility, status, created_by, updated_by, published_at)
SELECT @cat, 'admin-marks-tutorial-22-introduction-to-marks-processing',
       'Introduction to Marks Processing for Administrators',
       'An overview of how administrators process student marks in the university portal, from capture through to publishing.',
       'https://www.youtube.com/watch?v=iouhuFI7nX8&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=21',
       1, 'https://www.youtube.com/watch?v=iouhuFI7nX8&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=21',
       1, 'EMPLOYEES', 'PUBLISHED', 'system', 'system', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_articles WHERE article_key='admin-marks-tutorial-22-introduction-to-marks-processing');

INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, is_youtube_video, youtube_url, display_order, visibility, status, created_by, updated_by, published_at)
SELECT @cat, 'admin-marks-tutorial-23-system-configuration',
       'System Configuration for Marks Processing',
       'How to configure the system settings that govern marks processing and the results workflow.',
       'https://www.youtube.com/watch?v=6iuzK3p7JiY&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=22',
       1, 'https://www.youtube.com/watch?v=6iuzK3p7JiY&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=22',
       2, 'EMPLOYEES', 'PUBLISHED', 'system', 'system', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_articles WHERE article_key='admin-marks-tutorial-23-system-configuration');

INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, is_youtube_video, youtube_url, display_order, visibility, status, created_by, updated_by, published_at)
SELECT @cat, 'admin-marks-tutorial-24-hod-marks-capture',
       'HOD Marks Capture',
       'How Heads of Department capture and submit student marks for the courses in their department.',
       'https://www.youtube.com/watch?v=LReKLFK0Dt4&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=23',
       1, 'https://www.youtube.com/watch?v=LReKLFK0Dt4&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=23',
       3, 'EMPLOYEES', 'PUBLISHED', 'system', 'system', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_articles WHERE article_key='admin-marks-tutorial-24-hod-marks-capture');

INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, is_youtube_video, youtube_url, display_order, visibility, status, created_by, updated_by, published_at)
SELECT @cat, 'admin-marks-tutorial-25-dean-marks-approval',
       'Dean Marks Approval',
       'How Deans review and approve submitted marks for the programmes in their faculty.',
       'https://www.youtube.com/watch?v=J7rGcJK7Jjg&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=24',
       1, 'https://www.youtube.com/watch?v=J7rGcJK7Jjg&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=24',
       4, 'EMPLOYEES', 'PUBLISHED', 'system', 'system', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_articles WHERE article_key='admin-marks-tutorial-25-dean-marks-approval');

INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, is_youtube_video, youtube_url, display_order, visibility, status, created_by, updated_by, published_at)
SELECT @cat, 'admin-marks-tutorial-26-results-export',
       'Results Export',
       'How to export processed results for reporting and external submission.',
       'https://www.youtube.com/watch?v=GQR2Z1zYJwI&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=25',
       1, 'https://www.youtube.com/watch?v=GQR2Z1zYJwI&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=25',
       5, 'EMPLOYEES', 'PUBLISHED', 'system', 'system', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_articles WHERE article_key='admin-marks-tutorial-26-results-export');

INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, is_youtube_video, youtube_url, display_order, visibility, status, created_by, updated_by, published_at)
SELECT @cat, 'admin-marks-tutorial-27-board-of-examiners-publishes-results',
       'How the Board of Examiners Publishes Results',
       'How the board of examiners reviews and publishes final student results in the university portal.',
       'https://www.youtube.com/watch?v=dYVHqlKdkBs&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=26',
       1, 'https://www.youtube.com/watch?v=dYVHqlKdkBs&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=26',
       6, 'EMPLOYEES', 'PUBLISHED', 'system', 'system', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_articles WHERE article_key='admin-marks-tutorial-27-board-of-examiners-publishes-results');
