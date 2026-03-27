SELECT progid, studyyear, semester, curr_year, session, amount, ItemID 
FROM campus_dynamics_accounts.fin_fees_pay_schedule 
WHERE LENGTH(progid)=1 AND ItemID IN (1,52) AND amount > 0 
ORDER BY curr_year DESC, studyyear, semester 
LIMIT 50;
