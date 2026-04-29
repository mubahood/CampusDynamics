DROP PROCEDURE IF EXISTS acad_Get_GraduationCompletionData;

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `acad_Get_GraduationCompletionData`(
  acad CHAR(25) CHARSET utf8,
  prog CHAR(15) CHARSET utf8,
  yr   INT,
  cat  CHAR(15) CHARSET utf8,
  gdt  DATE,
  sems INT,
  intk CHAR(25) CHARSET utf8
)
BEGIN

  DECLARE lev, prognm, study_sys CHAR(150) CHARSET utf8;

  SELECT levelCode, UPPER(progname), study_system
    INTO lev, prognm, study_sys
    FROM acad_programme WHERE progcode = prog LIMIT 1;

  IF prog = '-' THEN SET prog = '%'; END IF;
  IF intk = '-' THEN SET intk = '%'; END IF;

  IF      lev = '3' THEN SET lev = 'Bachelors';
  ELSEIF  lev = '2' THEN SET lev = 'Diploma';
  ELSEIF  lev = '1' THEN SET lev = 'Certificate';
  ELSEIF  lev = '4' THEN SET lev = 'Postgraduate';
  ELSE                    SET lev = 'Masters';
  END IF;

  UPDATE acad_student  SET gender = 'MALE'   WHERE gender = 'M';
  UPDATE acad_student  SET gender = 'FEMALE' WHERE gender = 'F';
  UPDATE acad_graduands SET gender = 'MALE'  WHERE gender = 'M';
  UPDATE acad_graduands SET gender = 'FEMALE' WHERE gender = 'F';

  IF cat = 'ALL' THEN

    /* Active-registration branch — used by GraduationCentre with specific yr/sems */
    SELECT DISTINCT
      r.regno,
      acad_GetStudNameByID(r.regno)                                      AS stud_name,
      studPhone,
      acad_CompletionCheck(r.regno, acad_GetProgCodeByRegNo(r.regno))    AS comp,
      acad_GetTotalCredit(r.regno)                                        AS credits,
      acad_CGPAFinder(r.regno)                                            AS cgpa,
      acad_GetDegClass(acad_CGPAFinder(r.regno),
                       acad_GetGIDByRegNo(r.regno), lev)                 AS AwardClass,
      acad_GetEntryNoFromRegNo(r.regno)                                   AS entryno,
      'ALL'                                                               AS gen
    FROM acad_registration r
    JOIN acad_student s ON r.regno = s.regno
    WHERE acad_year = acad
      AND acad_GetProgCodeByRegNo(r.regno) = prog
      AND studyyear  = yr
      AND semester   = sems
      AND acad_GetStudIntakeByID(r.regno) LIKE intk
    ORDER BY acad_GetStudNameByID(r.regno);

  ELSEIF cat = 'LIST' THEN

    SELECT
      g.regno, g.stud_name, studPhone,
      'GRADUATED' AS comp, 0 AS credits,
      cgpa,
      UPPER(acad_GetProgNameFromCode(progcode))        AS prognm,
      acad,
      UPPER(acad_GetFacultyFromProgCode(progcode))     AS faculty,
      degclass                                          AS AwardClass,
      UPPER(acad_GetTranscriptStudData(g.regno,'NAT')) AS nationality,
      trans_status, cert_status,
      trans_printer, cert_printer,
      trans_date, cert_date,
      g.gender, grad_date, comp_date,
      acad_GetEntryNoFromRegNo(g.regno)                AS entryno,
      g.gender                                          AS gen
    FROM acad_graduands g
    JOIN acad_student s ON s.regno = g.regno
    WHERE acad_GetProgCodeByRegNo(g.regno) LIKE prog
      AND grad_date = gdt
    ORDER BY g.stud_name;

  ELSEIF cat = 'STATS' THEN

    SELECT
      g.regno, g.stud_name,
      'GRADUATED' AS comp, 0 AS credits,
      cgpa,
      UPPER(acad_GetProgNameFromCode(progcode))        AS prognm,
      acad,
      UPPER(acad_GetFacultyFromProgCode(progcode))     AS faculty,
      degclass                                          AS AwardClass,
      UPPER(acad_GetTranscriptStudData(g.regno,'NAT')) AS nationality,
      trans_status, cert_status,
      trans_printer, cert_printer,
      trans_date, cert_date,
      s.gender, grad_date, comp_date,
      acad_GetEntryNoFromRegNo(g.regno)                AS entryno,
      g.gender                                          AS gen
    FROM acad_graduands g
    JOIN acad_student s ON s.regno = g.regno
    WHERE acad_GetProgCodeByRegNo(g.regno) LIKE prog
      AND grad_date = gdt
    ORDER BY g.stud_name;

  ELSE

    /* GRAD branch — used by TranscriptDocumentCentre.
       FIX: treat acad='' as "all academic years" so the centre can load without
       a specific year selected, while still filtering when a year is chosen. */
    SELECT
      g.regno, g.stud_name,
      'GRADUATED' AS comp,
      acad_GetTotalCredit(g.regno)                     AS credits,
      cgpa,
      UPPER(acad_GetProgNameFromCode(progcode))        AS prognm,
      acad,
      UPPER(acad_GetFacultyFromProgCode(progcode))     AS faculty,
      degclass                                          AS AwardClass,
      UPPER(acad_GetTranscriptStudData(g.regno,'NAT')) AS nationality,
      trans_status, cert_status,
      trans_printer, cert_printer,
      trans_date, cert_date,
      g.gender, grad_date, comp_date,
      acad_GetEntryNoFromRegNo(g.regno)                AS entryno,
      g.gender                                          AS gen
    FROM acad_graduands g
    JOIN acad_student s ON s.regno = g.regno
    WHERE (acad = '' OR acadyear = acad)
      AND acad_GetProgCodeByRegNo(g.regno) LIKE prog
      AND acad_GetStudIntakeByID(g.regno)  LIKE intk
    ORDER BY g.stud_name;

  END IF;

END //

DELIMITER ;
