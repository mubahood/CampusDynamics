DROP PROCEDURE IF EXISTS `acad_GetStudentTranscript`;
DELIMITER $$
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

#examclearance IN ('CLEARED','UNCLEARED')
END
$$
DELIMITER ;
