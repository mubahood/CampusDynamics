SELECT f.progcode, IFNULL(p.progname,'?') AS progname, IFNULL(p.couselength,0) AS yrs
FROM campus_dynamics_accounts.fin_programme_fees f 
LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = f.progcode 
LEFT JOIN (
  SELECT DISTINCT progid FROM campus_dynamics_accounts.fin_fees_pay_schedule 
  WHERE ItemID IN (1,52) AND amount > 0 AND curr_year >= 2025
) ps ON ps.progid = f.progcode
WHERE ps.progid IS NULL
ORDER BY IFNULL(p.couselength,0), f.progcode;
