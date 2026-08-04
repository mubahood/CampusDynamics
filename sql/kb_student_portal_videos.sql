-- Knowledge Base: "Student Portal Video Tutorials" — 10 videos from the
-- "MRU Students - University Portal" playlist. Shown to STUDENTS, at the TOP of the KB
-- (category display_order = 1). Idempotent: keyed inserts skip if already present.

-- 1) Category at the top of the students' knowledge base
INSERT INTO sys_knowledgebase_categories
    (category_key, title, description, display_order, is_active, created_by, created_at)
SELECT 'student-portal-video-tutorials',
       'Student Portal Video Tutorials',
       'Step-by-step video guides for the student portal — logging in, navigation, semester & course registration, fees, exam clearance, results, retakes, photo, ID card and university email.',
       1, 1, 'admin', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_categories WHERE category_key='student-portal-video-tutorials');

SET @cat := (SELECT ID FROM sys_knowledgebase_categories WHERE category_key='student-portal-video-tutorials' LIMIT 1);

-- 2) The 10 videos, in playlist order (display_order 1..10), students-only, published
INSERT INTO sys_knowledgebase_articles
    (category_id, article_key, title, description, content, is_youtube_video, youtube_url,
     display_order, visibility, status, created_by, created_at, published_at)
SELECT v.cid, v.ak, v.tt, v.ds, v.ct, v.iv, v.yu, v.dO,
       'STUDENTS', 'PUBLISHED', 'admin', NOW(), NOW()
FROM (
    SELECT @cat cid, 'student-portal-01-introduction' ak, 'Introduction to the Student Portal' tt,
        'A quick overview of the student portal and what you can do with it.' ds,
        'https://www.youtube.com/watch?v=Ym0vCdJPnGw&list=PLcqSZyC6o8Yk&index=1' ct, 1 iv,
        'https://www.youtube.com/watch?v=Ym0vCdJPnGw&list=PLcqSZyC6o8Yk&index=1' yu, 1 dO
    UNION ALL SELECT @cat, 'student-portal-02-navigation', 'Student Portal Navigation',
        'Find your way around the portal: menus, dashboard and key sections.',
        'https://www.youtube.com/watch?v=E_gBg9wj9Ag&list=PLcqSZyC6o8Yk&index=2', 1,
        'https://www.youtube.com/watch?v=E_gBg9wj9Ag&list=PLcqSZyC6o8Yk&index=2', 2
    UNION ALL SELECT @cat, 'student-portal-03-semester-course-registration', 'Semester and Course Registration',
        'How to register for a new semester and select your courses.',
        'https://www.youtube.com/watch?v=EgHqq8w5N2Q&list=PLcqSZyC6o8Yk&index=3', 1,
        'https://www.youtube.com/watch?v=EgHqq8w5N2Q&list=PLcqSZyC6o8Yk&index=3', 3
    UNION ALL SELECT @cat, 'student-portal-04-school-fees', 'School Fees',
        'Viewing your fees, payments and outstanding balance on the portal.',
        'https://www.youtube.com/watch?v=2UijC5jLDR0&list=PLcqSZyC6o8Yk&index=4', 1,
        'https://www.youtube.com/watch?v=2UijC5jLDR0&list=PLcqSZyC6o8Yk&index=4', 4
    UNION ALL SELECT @cat, 'student-portal-05-exam-clearance-card', 'Exam Clearance Card',
        'How to generate your exam clearance card before sitting exams.',
        'https://www.youtube.com/watch?v=0_QstL9MGHc&list=PLcqSZyC6o8Yk&index=5', 1,
        'https://www.youtube.com/watch?v=0_QstL9MGHc&list=PLcqSZyC6o8Yk&index=5', 5
    UNION ALL SELECT @cat, 'student-portal-06-check-exam-results', 'How to Check Exam Results',
        'View and understand your published examination results.',
        'https://www.youtube.com/watch?v=Yi9tMZOL5Zw&list=PLcqSZyC6o8Yk&index=6', 1,
        'https://www.youtube.com/watch?v=Yi9tMZOL5Zw&list=PLcqSZyC6o8Yk&index=6', 6
    UNION ALL SELECT @cat, 'student-portal-07-register-a-retake', 'How to Register a Retake',
        'Register a retake for a course you need to repeat.',
        'https://www.youtube.com/watch?v=jH4JHXberkk&list=PLcqSZyC6o8Yk&index=7', 1,
        'https://www.youtube.com/watch?v=jH4JHXberkk&list=PLcqSZyC6o8Yk&index=7', 7
    UNION ALL SELECT @cat, 'student-portal-08-photo-uploading', 'Student Photo Uploading',
        'Upload or update your official student passport photo.',
        'https://www.youtube.com/watch?v=__1gK6Q-vgQ&list=PLcqSZyC6o8Yk&index=8', 1,
        'https://www.youtube.com/watch?v=__1gK6Q-vgQ&list=PLcqSZyC6o8Yk&index=8', 8
    UNION ALL SELECT @cat, 'student-portal-09-id-card-request-replacement', 'Student ID Card Request or Replacement',
        'Request a new student ID card or a replacement.',
        'https://www.youtube.com/watch?v=QPboYilF7Zk&list=PLcqSZyC6o8Yk&index=9', 1,
        'https://www.youtube.com/watch?v=QPboYilF7Zk&list=PLcqSZyC6o8Yk&index=9', 9
    UNION ALL SELECT @cat, 'student-portal-10-university-email-request', 'University Email Request',
        'Request and set up your official @mru.ac.ug university email.',
        'https://www.youtube.com/watch?v=6cOJBhmN_Mk&list=PLcqSZyC6o8Yk&index=10', 1,
        'https://www.youtube.com/watch?v=6cOJBhmN_Mk&list=PLcqSZyC6o8Yk&index=10', 10
) v
WHERE NOT EXISTS (SELECT 1 FROM sys_knowledgebase_articles a WHERE a.article_key = v.ak);

SELECT ROW_COUNT() AS videos_inserted;
