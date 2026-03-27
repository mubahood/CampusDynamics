SELECT f.progcode, p.progname, p.couselength, p.faculty 
FROM campus_dynamics_accounts.fin_programme_fees f 
LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = f.progcode 
WHERE f.progcode NOT IN ('BAED','BBA','BBEI','BBM','BCE','BCOM','BECD','BED(ECD)','BED(P)','BED(S)','BEE','BEICT','BHRM','BIFA','BIT','BMC','BPA','BPLM','BSAF','BSM','BTHM','BVS','DAD','DAF','DBA','DBM','DCE','decd','DEE','DFD','DHRM','DIT','DMC','DME','DPA','DPE','DPLM','DSM','DTHM','HEC','MBA','MEMA','MMC','MPCHD','SWSA') 
ORDER BY p.couselength, f.progcode;
