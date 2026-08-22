-- =====================================================================
--  NAMATOVU Hajarah — MRU2015002129 — Diploma in Information Technology
--  Reconstructing a 2015–2017 academic record from her 2018 testimonial.
--
--  WHO SHE IS. The testimonial prints "Reg No. 15/U/DIT/2124/K/DAY" and
--  "Id Number 1500201599". Neither is hers:
--    · 2124 belongs to BASAALIDDE Martin (15/U/DEE/2124/K/EVE), confirmed
--      on BOTH this database and the pre-ERP server (bioid 2015002124).
--    · 1500201599 exists on neither system, though the 1500201xxx family
--      does (922 rows on the old server, 2,021 here).
--    · The pre-ERP server holds exactly one NAMATOVU Hajarah: bioid
--      2015002129 — the origin of her ERP key MRU2015002129.
--  Both are OCR misreads of a 9. She is MRU2015002129, 15/U/DIT/2129/K/DAY.
--
--  WHAT WAS ALREADY THERE. Her student record and all four semester
--  registrations (2015/2016 S1–S2, 2016/2017 S1–S2) exist and are correct.
--  She had no course registrations, no marks and no results. This fills
--  that gap and nothing else.
--
--  THE GRADES. The testimonial reads C-, C, C+, B-, B, B+. MRU today has
--  no C- or B-. This is not a conflict but a renaming: the two scales have
--  IDENTICAL bands and IDENTICAL grade points, and only the letters moved.
--
--      marks     old letter   today   point
--      50–54         C-         D      2.0
--      55–59         C          D+     2.5
--      60–64         C+         C      3.0
--      65–69         B-         C+     3.5
--      70–74         B          B      4.0
--      75–79         B+         B+     4.5
--
--  So entering her marks under today's scale reproduces every printed
--  figure to the last decimal — 2.71, 2.75, 2.53, 3.43 and CGPA 2.93 —
--  while the letters read D/D+/C/C+ instead of C-/C/C+/B-. The marks are
--  the fact; the letters are the era's vocabulary. Asserted at the end.
--
--  Re-runnable: it removes only her own reconstructed rows first, and
--  every row it writes is stamped TESTIMONIAL_2018.
-- =====================================================================
USE campus_dynamics;

-- ---------------------------------------------------------------------
--  0. The document itself, kept as a table so the reconstruction can be
--     audited against its source without the scan to hand. printed_grade
--     and printed_gpa are the OLD scale, recorded for comparison only —
--     nothing downstream reads them.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS src_namatovu_testimonial_2018;
CREATE TABLE src_namatovu_testimonial_2018 (
    seq            INT NOT NULL,
    acad           CHAR(9)  NOT NULL,
    semester       INT      NOT NULL,
    studyyear      INT      NOT NULL,
    courseid       CHAR(25) NOT NULL,
    printed_title  VARCHAR(120) NOT NULL,
    score          INT      NOT NULL,
    cu             DOUBLE   NOT NULL,
    printed_grade  CHAR(3)  NOT NULL,
    printed_gpa    DOUBLE   NOT NULL,
    PRIMARY KEY (seq)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO src_namatovu_testimonial_2018
 (seq,acad,semester,studyyear,courseid,printed_title,score,cu,printed_grade,printed_gpa) VALUES
 -- Year 1, Semester 1 — printed GPA 2.71, CGPA 2.71
 ( 1,'2015/2016',1,1,'ICT1102D','Discrete Math',                                 51,3,'C-',2.71),
 ( 2,'2015/2016',1,1,'ICT1101D','Principles of Programming',                     66,4,'B-',2.71),
 ( 3,'2015/2016',1,1,'ICT1103D','Management Information System',                 50,3,'C-',2.71),
 ( 4,'2015/2016',1,1,'ICT1104D','Elementary Web Design and Internet Technology', 65,4,'B-',2.71),
 ( 5,'2015/2016',1,1,'FND1101D','Communication Skills',                          52,3,'C-',2.71),
 -- Year 1, Semester 2 — printed GPA 2.75, CGPA 2.73
 ( 6,'2015/2016',2,1,'ICT1202D','Object Oriented Programming',                   66,4,'B-',2.75),
 ( 7,'2015/2016',2,1,'ICT1201D','Computer Organization & Architecture',          55,3,'C', 2.75),
 ( 8,'2015/2016',2,1,'ICT1203D','Database Management Systems',                   59,3,'C', 2.75),
 ( 9,'2015/2016',2,1,'ICT1204D','Elementary Systems Administration',             50,3,'C-',2.75),
 (10,'2015/2016',2,1,'MGT1201D','Entreprenurship Skills',                        60,3,'C+',2.75),
 -- Year 2, Semester 1 — printed GPA 2.53, CGPA 2.66
 (11,'2016/2017',1,2,'ICT2105D','Mobile Application Development',                50,4,'C-',2.53),
 (12,'2016/2017',1,2,'ICT2103D','Advanced Systems Administration',               73,4,'B', 2.53),
 (13,'2016/2017',1,2,'ICT2101D','Computer Repair and Maintenance',               52,3,'C-',2.53),
 (14,'2016/2017',1,2,'ICT2102D','Computer Networking',                           51,4,'C-',2.53),
 (15,'2016/2017',1,2,'ICT2104D','Research Methodology',                          58,3,'C', 2.53),
 -- Year 2, Semester 2 — printed GPA 3.43, CGPA 2.93 (final)
 (16,'2016/2017',2,2,'ICT2203D','Advanced Web Technologies',                     69,4,'B-',3.43),
 (17,'2016/2017',2,2,'ICT2201D','Event Driven Programming',                      69,4,'B-',3.43),
 (18,'2016/2017',2,2,'ICT2202D','Database Programming',                          64,4,'C+',3.43),
 (19,'2016/2017',2,2,'ICT2205D','Graphics and Multimedia Technology',            62,4,'C+',3.43),
 (20,'2016/2017',2,2,'ICT2204D','Data Communication',                            52,4,'C-',3.43),
 (21,'2016/2017',2,2,'ICT2301D','Industrial Training',                           75,8,'B+',3.43);

-- ---------------------------------------------------------------------
--  1. Backups. She has no marks today, so these should come out empty —
--     they exist so a re-run has something to roll back to.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS bak_namatovu_results_20260822;
CREATE TABLE bak_namatovu_results_20260822
  AS SELECT * FROM acad_results WHERE regno='MRU2015002129';

DROP TABLE IF EXISTS bak_namatovu_student_20260822;
CREATE TABLE bak_namatovu_student_20260822
  AS SELECT * FROM acad_student WHERE regno='MRU2015002129';

DROP TABLE IF EXISTS bak_namatovu_registration_20260822;
CREATE TABLE bak_namatovu_registration_20260822
  AS SELECT * FROM acad_registration WHERE regno='MRU2015002129';

DROP TABLE IF EXISTS bak_namatovu_coursereg_20260822;
CREATE TABLE bak_namatovu_coursereg_20260822
  AS SELECT * FROM campus_dynamics_portal.acad_course_registration WHERE regno='MRU2015002129';

-- ---------------------------------------------------------------------
--  2. The marks.
--
--     grade and gradept are DERIVED from the score by the NCHE 2015 scale
--     rather than transcribed, so the only thing a human could get wrong
--     is a number that the arithmetic at the end then checks.
--
--     CreditUnits carries the testimonial's own figure. That matters for
--     one course: ICT2301D Industrial Training is 8 CU on her document and
--     on the pre-ERP master (gensubject: 8.0 across all 182 offerings),
--     but 5 CU in today's catalogue. Her printed Y2S2 GPA, her total of 79
--     and her final CGPA all reconcile only at 8, so 8 is what her record
--     holds. See the note at the foot of this file.
-- ---------------------------------------------------------------------
DELETE FROM acad_results WHERE regno='MRU2015002129';

INSERT INTO acad_results
    (regno, courseid, semester, acad, studyyear, score, grade, gradept, gpa,
     result_comment, CreditUnits, progid, is_retake)
SELECT 'MRU2015002129', t.courseid, t.semester, t.acad, t.studyyear, t.score,
       CASE WHEN t.score>=80 THEN 'A'  WHEN t.score>=75 THEN 'B+' WHEN t.score>=70 THEN 'B'
            WHEN t.score>=65 THEN 'C+' WHEN t.score>=60 THEN 'C'  WHEN t.score>=55 THEN 'D+'
            WHEN t.score>=50 THEN 'D'  ELSE 'F' END,
       CASE WHEN t.score>=80 THEN 5.0  WHEN t.score>=75 THEN 4.5  WHEN t.score>=70 THEN 4.0
            WHEN t.score>=65 THEN 3.5  WHEN t.score>=60 THEN 3.0  WHEN t.score>=55 THEN 2.5
            WHEN t.score>=50 THEN 2.0  ELSE 0.0 END,
       0, '', t.cu, 'DIT', 0
  FROM src_namatovu_testimonial_2018 t
 ORDER BY t.seq;

-- The gpa column holds the SEMESTER GPA repeated on every row of that
-- semester — the shape every other student in this table uses.
UPDATE acad_results r
  JOIN (SELECT acad, semester,
               ROUND(SUM(CreditUnits*gradept)/SUM(CreditUnits),2) g
          FROM acad_results WHERE regno='MRU2015002129'
         GROUP BY acad, semester) s
    ON s.acad=r.acad AND s.semester=r.semester
   SET r.gpa = s.g
 WHERE r.regno='MRU2015002129';

-- ---------------------------------------------------------------------
--  3. The course registrations that those marks belong to.
--     Shaped exactly like her cohort's (peer MRU1500201288), including the
--     40/60 coursework:exam split the classic migration used — verified as
--     ROUND(total*0.4) on 551,838 of its 552,561 rows.
-- ---------------------------------------------------------------------
DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno='MRU2015002129';

INSERT INTO campus_dynamics_portal.acad_course_registration
    (regno, courseID, acad_year, semester, course_status, prog_id, stud_session,
     provisional_course_work_marks, provisional_exam_marks, provisional_total_marks,
     provisional_marks_status, provisional_marks_reviewed_by, provisional_marks_review_date,
     provisional_published_by, provisional_published_date,
     mark_stage, mark_stage_changed_at, mark_stage_changed_by,
     registration_type, lecturer_status, lecturer_status_by, lecturer_status_at)
SELECT 'MRU2015002129', t.courseid, t.acad, t.semester, 'NORMAL', 'DIT', 'DAY',
       ROUND(t.score*0.4), t.score-ROUND(t.score*0.4), t.score,
       'published', 'TESTIMONIAL_2018', NOW(),
       'TESTIMONIAL_2018', NOW(),
       'PUBLISHED', NOW(), 'TESTIMONIAL_2018',
       'NORMAL', 'APPROVED', 'TESTIMONIAL_2018', NOW()
  FROM src_namatovu_testimonial_2018 t
 ORDER BY t.seq;

-- ---------------------------------------------------------------------
--  4. Does it reproduce the document?
-- ---------------------------------------------------------------------
SELECT '=== per semester: reconstructed vs printed ===' AS x;
SELECT r.acad, r.semester, r.studyyear,
       COUNT(*)                                             courses,
       SUM(r.CreditUnits)                                   credit_units,
       ROUND(SUM(r.CreditUnits*r.gradept)/SUM(r.CreditUnits),2) gpa,
       MAX(t.printed_gpa)                                   printed_gpa,
       IF(ROUND(SUM(r.CreditUnits*r.gradept)/SUM(r.CreditUnits),2)=MAX(t.printed_gpa),'MATCH','*** MISMATCH ***') verdict
  FROM acad_results r
  JOIN src_namatovu_testimonial_2018 t
    ON t.courseid=r.courseid AND t.acad=r.acad AND t.semester=r.semester
 WHERE r.regno='MRU2015002129'
 GROUP BY r.acad, r.semester, r.studyyear
 ORDER BY r.acad, r.semester;

SELECT '=== the award ===' AS x;
SELECT COUNT(*) courses, SUM(CreditUnits) total_cu, 79 printed_cu,
       acad_CGPAFinder('MRU2015002129') cgpa, 2.93 printed_cgpa,
       IF(SUM(CreditUnits)=79 AND acad_CGPAFinder('MRU2015002129')=2.93,'MATCH','*** MISMATCH ***') verdict
  FROM acad_results WHERE regno='MRU2015002129';

SELECT '=== grade letters: today vs the document ===' AS x;
SELECT r.courseid, r.score, r.CreditUnits, r.grade AS grade_today,
       t.printed_grade AS grade_2018, r.gradept,
       IF(r.gradept = CASE t.printed_grade
            WHEN 'C-' THEN 2.0 WHEN 'C' THEN 2.5 WHEN 'C+' THEN 3.0
            WHEN 'B-' THEN 3.5 WHEN 'B'  THEN 4.0 WHEN 'B+' THEN 4.5 END,
          'same point','*** POINT DIFFERS ***') point_check
  FROM acad_results r JOIN src_namatovu_testimonial_2018 t ON t.courseid=r.courseid
 WHERE r.regno='MRU2015002129' ORDER BY t.seq;

SELECT '=== marks and registrations agree ===' AS x;
SELECT (SELECT COUNT(*) FROM acad_results WHERE regno='MRU2015002129') results,
       (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration WHERE regno='MRU2015002129') course_regs,
       (SELECT COUNT(*) FROM acad_registration WHERE regno='MRU2015002129') semester_regs,
       (SELECT COUNT(*) FROM acad_results r
          LEFT JOIN campus_dynamics_portal.acad_course_registration cr
            ON cr.regno=r.regno AND cr.courseID=r.courseid
           AND cr.acad_year=r.acad AND cr.semester=r.semester
         WHERE r.regno='MRU2015002129' AND cr.ID IS NULL) marks_without_a_registration,
       (SELECT COUNT(*) FROM acad_results r
          LEFT JOIN acad_registration rg
            ON rg.regno=r.regno AND rg.acad_year=r.acad AND rg.semester=r.semester
         WHERE r.regno='MRU2015002129' AND rg.ID IS NULL) marks_without_a_semester;

-- ---------------------------------------------------------------------
--  NOTE — the one thing this script cannot settle on its own.
--
--  acad_GetStudentTranscript begins by doing this:
--
--      UPDATE acad_results r JOIN acad_course c ON c.CourseID = r.courseid
--         SET r.creditUnits = c.CreditUnit WHERE regno = reg;
--
--  Every printed transcript therefore re-prices every course at TODAY's
--  catalogue value and overwrites the stored one. For her that turns
--  ICT2301D from 8 CU into 5, and the transcript prints 76 CU and CGPA
--  2.87 instead of the 79 and 2.93 on her testimonial.
--
--  It is not only her: 91,576 of 647,231 result rows (14%) hold a credit
--  unit that differs from the catalogue, and all of them are silently
--  restated at print time. A catalogue with one CU per course cannot
--  express a curriculum that changed, which is what happened here —
--  Industrial Training was 8 CU in her era and is 5 CU now.
--
--  Three ways out, none of which belong inside a one-student script:
--    (a) set acad_course.ICT2301D.CreditUnit = 8 — right for the 75 rows
--        up to 2018, wrong for the 101 after it;
--    (b) stop the overwrite clobbering a stored value — right in
--        principle, but it moves 91,576 rows at once;
--    (c) leave it, and accept that her reprint reads 2.87.
--  Raised with the Academic Registrar rather than chosen here.
-- ---------------------------------------------------------------------
