-- ORIGINAL (rollback) — acad_GetStudnameByID built the name reversed: othername + firstname.
USE campus_dynamics;
DROP FUNCTION IF EXISTS acad_GetStudnameByID;
DELIMITER $$
CREATE FUNCTION acad_GetStudnameByID(reg CHAR(90)) RETURNS CHAR(65) CHARSET utf8
BEGIN
DECLARE st_name CHAR(65);
SELECT CONCAT(othername,' ',firstname) INTO st_name FROM acad_student WHERE regno=reg;
RETURN IF(st_name IS NULL,'-',st_name);
END$$
DELIMITER ;
