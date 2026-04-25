import mysql.connector

conn = mysql.connector.connect(host='102.34.160.47', user='dbmanager', password='24thdecember1977', database='campus_dynamics')
conn2 = mysql.connector.connect(host='102.34.160.47', user='dbmanager', password='24thdecember1977', database='campus_dynamics_portal')
c = conn.cursor()
p = conn2.cursor()

c.execute("SELECT COUNT(*) FROM acad_registration WHERE regno='MRU1200201305'")
print('Semester registrations:', c.fetchone()[0])

p.execute("SELECT COUNT(*) FROM acad_course_registration WHERE regno='MRU1200201305'")
print('Course registrations:', p.fetchone()[0])

c.execute("SELECT COUNT(*) FROM acad_results WHERE regno='MRU1200201305'")
print('acad_results rows:', c.fetchone()[0])

c.execute("SELECT COUNT(*) FROM acad_examresults_faculty WHERE regno='MRU1200201305'")
print('faculty results rows:', c.fetchone()[0])

c.execute("SELECT ROUND(SUM(gradept*CreditUnits)/SUM(CreditUnits),2) AS cgpa, SUM(CreditUnits) AS total_cu FROM acad_results WHERE regno='MRU1200201305'")
row = c.fetchone()
print(f'Computed CGPA: {row[0]}   Total CU: {row[1]}')

c.execute("SELECT acad, semester, COUNT(*) courses, ROUND(SUM(gradept*CreditUnits)/SUM(CreditUnits),2) AS gpa FROM acad_results WHERE regno='MRU1200201305' GROUP BY acad, semester ORDER BY acad, semester")
print('\nPer-semester breakdown:')
for r in c.fetchall():
    print(f'  {r[0]} S{r[1]}: {r[2]} courses  GPA={r[3]}')

conn.close()
conn2.close()
