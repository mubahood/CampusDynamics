USE campus_dynamics;

DELIMITER ;;
DROP PROCEDURE IF EXISTS `acad_GetStudentTranscript` ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acad_GetStudentTranscript`(reg CHAR(30))
BEGIN
DECLARE dobs,nat,gen,prog,fax,deg,lev,studnm,photo,stud_sys,entno VARCHAR(150);
DECLARE cgpa DOUBLE;
DECLARE gid INT;



SELECT gradSystemID,CONCAT(othername,' ',firstname),nationality,gender,photofile,progid,entryno
INTO gid,studnm,nat,gen,photo,prog,entno FROM acad_student WHERE regno=reg;

SELECT IF(levelCode=1,'Certificate',IF(levelCode=2,'Diploma',
IF(levelCode>=3,'Bachelors','Masters'))) AS levels,study_system,progname INTO lev,stud_sys,prog FROM acad_programme WHERE progcode=prog;

SET dobs=acad_GetTranscriptStudData(reg,'DOB');

UPDATE acad_results r JOIN acad_course c ON c.CourseID = r.courseid
SET r.creditUnits  = c.CreditUnit WHERE regno = reg;

UPDATE acad_results SET gpa = acad_gpaFinder(reg,studyyear,semester)
 WHERE regno = reg;

SET fax=acad_GetTranscriptStudData(reg,'FAX');
SET cgpa=acad_CGPAFinder(reg);
SET deg=acad_GetDegClass(cgpa,gid,lev);
SET photo=CONCAT('~/COOPERP/StudentInfo/photos/',photo);


SELECT deg,fax,dobs,nat,gen,prog,cgpa,deg,studnm,photo,CONCAT(acad_GetCourseNameByCode(courseid),IF(COALESCE(r.is_retake,0)=1,' (RT)','')) AS coursename,stud_sys,
entno AS entryno,
r.* FROM acad_results r
  , acad_student s,acad_registration rg WHERE  s.regno = r.regno AND s.regno = rg.regno AND
 r.acad = rg.acad_year AND r.semester = rg.semester
AND r.regno=reg AND
IF(CAST(SUBSTRING(acad,1,4) AS UNSIGNED)>=2024,acad_GetResultsSecurityLevel(r.progid, acad, r.semester,intake, studsesion, r.studyyear,studCampus)>1,
acad_GetResultsSecurityLevel(r.progid, acad, r.semester,intake, studsesion, r.studyyear,studCampus)>=0)
AND IF(CAST(SUBSTRING(acad,1,4) AS UNSIGNED)>=2024,examclearance != 'UNCLEARED',TRUE);


END ;;
DROP PROCEDURE IF EXISTS `acad_CreateTranscript` ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `acad_CreateTranscript`(reg CHAR(45), typ CHAR(25), fid INT)
BEGIN
  DECLARE prog, sys CHAR(45);
  SET prog = acad_GetProgCodeByRegNo(reg);
  SELECT study_system INTO sys FROM acad_programme WHERE progcode = prog LIMIT 1;

  IF (typ = 'Custom') THEN

    DELETE FROM acad_transcript_results WHERE regno = reg;
    INSERT INTO acad_transcript_results
      (regno, courseid, semester, acad, studyyear, score, grade, gradept, gpa,
       result_comment, CreditUnits, progid, study_system, is_retake)
    SELECT
      regno, courseid, tfd.semester, acad, study_year, score, grade, gradept, gpa,
      result_comment, CreditUnits, progid, study_system, COALESCE(r.is_retake,0)
    FROM acad_results r, acad_transcript_format tf, acad_transcript_format_detail tfd
    WHERE tfd.format_id = tf.ID
      AND tfd.course_id = r.courseid
      AND regno = reg
      AND tf.ID = fid;

    UPDATE acad_transcript_results
    SET gpa = acad_TranscriptGPAFinder(regno, studyyear, semester)
    WHERE regno = reg;

  ELSE

    DELETE FROM acad_transcript_results WHERE regno = reg;
    INSERT INTO acad_transcript_results
      (regno, courseid, semester, acad, studyyear, score, grade, gradept, gpa,
       result_comment, CreditUnits, progid, study_system, is_retake)
    SELECT
      regno, r.courseid, semester, acad, studyyear, score, grade, gradept, gpa,
      result_comment,
      COALESCE(c.CreditUnit, r.CreditUnits, 3),
      progid, sys, COALESCE(r.is_retake,0)
    FROM acad_results r
    LEFT JOIN acad_course c ON c.courseID = r.courseid
    WHERE regno = reg;

  END IF;

  UPDATE acad_transcript_results a
  JOIN (
    SELECT progcode, course_code, study_year, semester
    FROM acad_programmecourses p
    WHERE p.curriculumID = acad_GetStudentStudyCurriculum(reg)
  ) p ON p.progcode = a.progid AND p.course_code = a.courseid
  SET a.studyyear = p.study_year, a.semester = p.semester
  WHERE regno = reg;

  
  
  
  
  UPDATE acad_transcript_results t
  JOIN (
      SELECT studyyear, semester, MIN(acad_year) AS acad_year
      FROM acad_registration
      WHERE regno = reg AND IFNULL(acad_year,'') NOT IN ('', '-')
      GROUP BY studyyear, semester
  ) rg ON rg.studyyear = t.studyyear AND rg.semester = t.semester
  SET t.acad = rg.acad_year
  WHERE t.regno = reg;

  UPDATE acad_transcript_results
  SET gpa = acad_TranscriptGPAFinder(regno, studyyear, semester)
  WHERE regno = reg;

END ;;
DELIMITER ;
