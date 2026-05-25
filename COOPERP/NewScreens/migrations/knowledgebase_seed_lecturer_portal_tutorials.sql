-- ═══════════════════════════════════════════════════════════════════════════
-- Knowledgebase Seed — Lecturer Portal Tutorials
-- Purpose:
--   Inserts / updates the "Lecturer Portal Tutorials" category and 17
--   YouTube-based knowledgebase articles in playlist order.
--
-- Notes:
--   - Safe to re-run (idempotent)
--   - Preserves existing article view counts on updates
--   - Publishes all items immediately
--   - Sets visibility to BOTH (students + employees)
--   - Uses the YouTube URL in both `youtube_url` and `content`
-- ═══════════════════════════════════════════════════════════════════════════

START TRANSACTION;

-- 1) Ensure the category exists and is active
INSERT INTO sys_knowledgebase_categories
    (category_key, title, description, photo_path, display_order, is_active, created_by, updated_by)
VALUES
    (
        'lecturer-portal-tutorials',
        'Lecturer Portal Tutorials',
        'Step-by-step YouTube tutorials for using the university lecturer portal, including login, navigation, course assignment, student access, marks management, profile updates, and portal questions and answers.',
        NULL,
        10,
        1,
        'knowledgebase_seed',
        'knowledgebase_seed'
    )
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    description = VALUES(description),
    photo_path = VALUES(photo_path),
    display_order = VALUES(display_order),
    is_active = VALUES(is_active),
    updated_by = VALUES(updated_by);

SET @kb_category_id := (
    SELECT ID
    FROM sys_knowledgebase_categories
    WHERE category_key = 'lecturer-portal-tutorials'
    LIMIT 1
);

-- 2) Stage the articles in playlist order
DROP TEMPORARY TABLE IF EXISTS tmp_kb_lecturer_portal_tutorials;
CREATE TEMPORARY TABLE tmp_kb_lecturer_portal_tutorials (
    article_key   VARCHAR(180) NOT NULL,
    title         VARCHAR(250) NOT NULL,
    description   TEXT NULL,
    content       MEDIUMTEXT NOT NULL,
    youtube_url   VARCHAR(500) NOT NULL,
    display_order INT NOT NULL,
    PRIMARY KEY (article_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tmp_kb_lecturer_portal_tutorials
    (article_key, title, description, content, youtube_url, display_order)
VALUES
    (
        'lecturer-portal-tutorial-01-how-a-lecturer-logs-in',
        'How a lecturer logs in - University portal',
        'A step-by-step video guide showing lecturers how to log in to the university portal successfully.',
        'https://www.youtube.com/watch?v=4KcYETVEgzk&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=1',
        'https://www.youtube.com/watch?v=4KcYETVEgzk&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=1',
        1
    ),
    (
        'lecturer-portal-tutorial-02-how-to-navigate-the-lecturer-portal',
        'How to navigate the lecturer portal - University portal',
        'An orientation video that walks lecturers through the main areas and navigation flow of the portal.',
        'https://www.youtube.com/watch?v=-p0vyr8vUGw&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=2',
        'https://www.youtube.com/watch?v=-p0vyr8vUGw&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=2',
        2
    ),
    (
        'lecturer-portal-tutorial-03-how-to-set-a-supervisor',
        'How to set a supervisor - University portal',
        'Explains how to assign or configure a supervisor correctly within the university portal.',
        'https://www.youtube.com/watch?v=8xZW9OaggHY&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=3',
        'https://www.youtube.com/watch?v=8xZW9OaggHY&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=3',
        3
    ),
    (
        'lecturer-portal-tutorial-04-how-to-access-the-courses-you-teach',
        'How to access the courses you teach - University portal',
        'Shows lecturers how to find and open the courses assigned to them in the portal.',
        'https://www.youtube.com/watch?v=O02T4Il42RY&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=4',
        'https://www.youtube.com/watch?v=O02T4Il42RY&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=4',
        4
    ),
    (
        'lecturer-portal-tutorial-05-how-to-unassign-a-wrongly-assigned-course',
        'How to unassign a wrongly assigned course - University portal',
        'Guides lecturers through removing a course that was assigned in error.',
        'https://www.youtube.com/watch?v=qixOB2peqBs&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=5',
        'https://www.youtube.com/watch?v=qixOB2peqBs&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=5',
        5
    ),
    (
        'lecturer-portal-tutorial-06-how-to-assign-a-course-to-yourself',
        'How to assign a course to yourself - University portal',
        'Demonstrates how a lecturer can assign a course to themselves inside the portal.',
        'https://www.youtube.com/watch?v=AVO71hjP4Mg&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=6',
        'https://www.youtube.com/watch?v=AVO71hjP4Mg&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=6',
        6
    ),
    (
        'lecturer-portal-tutorial-07-how-to-access-students-that-i-teach',
        'How to access students that I teach - University portal',
        'A tutorial showing lecturers how to open and review the list of students linked to their teaching assignments.',
        'https://www.youtube.com/watch?v=IcXhmuHybGQ&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=7',
        'https://www.youtube.com/watch?v=IcXhmuHybGQ&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=7',
        7
    ),
    (
        'lecturer-portal-tutorial-08-how-to-assign-a-course-to-yourself-alt',
        'How to assign a course to yourself - University portal',
        'An additional version of the course self-assignment tutorial for lecturers using the university portal.',
        'https://www.youtube.com/watch?v=xp7NxHN_MHQ&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=8',
        'https://www.youtube.com/watch?v=xp7NxHN_MHQ&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=8',
        8
    ),
    (
        'lecturer-portal-tutorial-09-how-to-access-students-that-i-teach-alt',
        'How to access students that I teach - University portal',
        'A second walkthrough for accessing students taught by a lecturer, useful as an alternative guide.',
        'https://www.youtube.com/watch?v=6KfHd6gxAy0&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=9',
        'https://www.youtube.com/watch?v=6KfHd6gxAy0&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=9',
        9
    ),
    (
        'lecturer-portal-tutorial-10-how-to-register-a-student-to-a-course-i-teach',
        'How to register a student to a course I teach - University portal',
        'Shows the process for registering a student to a course taught by the lecturer.',
        'https://www.youtube.com/watch?v=_B7OXR-liEU&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=10',
        'https://www.youtube.com/watch?v=_B7OXR-liEU&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=10',
        10
    ),
    (
        'lecturer-portal-tutorial-11-how-to-register-a-student-to-a-course-i-teach-alt',
        'How to register a student to a course I teach - University portal',
        'An alternative tutorial covering student course registration by the lecturer.',
        'https://www.youtube.com/watch?v=f8C8XLwXFNA&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=11',
        'https://www.youtube.com/watch?v=f8C8XLwXFNA&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=11',
        11
    ),
    (
        'lecturer-portal-tutorial-12-how-to-access-filter-and-search-student-marks',
        'How to access, filter, and search student marks - University portal',
        'Teaches lecturers how to open the marks area and use filtering and search tools effectively.',
        'https://www.youtube.com/watch?v=SUqVOFXtM_U&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=12',
        'https://www.youtube.com/watch?v=SUqVOFXtM_U&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=12',
        12
    ),
    (
        'lecturer-portal-tutorial-13-how-to-enter-coursework-and-exam-marks',
        'How to enter coursework and exam marks - University portal',
        'A practical guide for entering coursework and examination marks in the portal.',
        'https://www.youtube.com/watch?v=XmQ5T-VbBVs&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=13',
        'https://www.youtube.com/watch?v=XmQ5T-VbBVs&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=13',
        13
    ),
    (
        'lecturer-portal-tutorial-14-how-to-review-missing-marks-requests',
        'How to review missing marks requests - University portal',
        'Explains how lecturers can open and review missing marks requests submitted in the portal.',
        'https://www.youtube.com/watch?v=3F1TNxnKBQE&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=14',
        'https://www.youtube.com/watch?v=3F1TNxnKBQE&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=14',
        14
    ),
    (
        'lecturer-portal-tutorial-15-how-to-review-missing-marks-requests-alt',
        'How to review missing marks requests - University portal',
        'A second walkthrough for reviewing missing marks requests in the university portal.',
        'https://www.youtube.com/watch?v=IuRUhd7CO14&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=15',
        'https://www.youtube.com/watch?v=IuRUhd7CO14&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=15',
        15
    ),
    (
        'lecturer-portal-tutorial-16-how-to-update-my-profile',
        'How to update my profile University portal',
        'Shows lecturers how to update profile information and keep account details current.',
        'https://www.youtube.com/watch?v=CV8Fg82enr8&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=16',
        'https://www.youtube.com/watch?v=CV8Fg82enr8&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=16',
        16
    ),
    (
        'lecturer-portal-tutorial-17-portal-questions-and-answers',
        'Portal questions and answers - University portal',
        'A questions-and-answers tutorial video addressing common lecturer portal issues and frequently asked questions.',
        'https://www.youtube.com/watch?v=RFA-281UOqg&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=17',
        'https://www.youtube.com/watch?v=RFA-281UOqg&list=PLOR5hj0X3WPdEO7BVd0QlGZGjxlmvRPBq&index=17',
        17
    );

-- 3) Upsert all articles under the category
INSERT INTO sys_knowledgebase_articles
    (
        category_id,
        article_key,
        title,
        description,
        content,
        photo_path,
        is_youtube_video,
        youtube_url,
        display_order,
        view_count,
        visibility,
        status,
        created_by,
        updated_by,
        published_at
    )
SELECT
    @kb_category_id,
    s.article_key,
    s.title,
    s.description,
    s.content,
    NULL,
    1,
    s.youtube_url,
    s.display_order,
    0,
    'BOTH',
    'PUBLISHED',
    'knowledgebase_seed',
    'knowledgebase_seed',
    NOW()
FROM tmp_kb_lecturer_portal_tutorials s
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    title = VALUES(title),
    description = VALUES(description),
    content = VALUES(content),
    photo_path = VALUES(photo_path),
    is_youtube_video = VALUES(is_youtube_video),
    youtube_url = VALUES(youtube_url),
    display_order = VALUES(display_order),
    visibility = VALUES(visibility),
    status = VALUES(status),
    updated_by = VALUES(updated_by),
    published_at = CASE
        WHEN sys_knowledgebase_articles.published_at IS NULL THEN VALUES(published_at)
        ELSE sys_knowledgebase_articles.published_at
    END;

DROP TEMPORARY TABLE IF EXISTS tmp_kb_lecturer_portal_tutorials;

COMMIT;
