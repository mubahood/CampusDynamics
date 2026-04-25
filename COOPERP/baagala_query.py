import mysql.connector

conn = mysql.connector.connect(host='102.34.160.47', user='dbmanager', password='24thdecember1977', database='campus_dynamics')
cur = conn.cursor()

# Find DPE programme
cur.execute("SELECT * FROM acad_programme WHERE progcode LIKE '%DPE%' OR progname LIKE '%Primary%' OR progname LIKE '%DPE%'")
print('=== DPE Programme ===')
for r in cur.fetchall(): print(r)

# Sample acad_student row for the student
cur.execute("SELECT * FROM acad_student WHERE regno='MRU1200201305'")
print('=== Student ===')
for r in cur.fetchall(): print(r)

# Find all possible course codes from her record
codes = ['DIT1101','PEOI1101','PEOI1102','PEOI1103','PEOI1104','PEOI1105',
         'DEFI1201','DEFI1202','DELI1201','DELI1202','DSSI1201','DSSI1202',
         'DELI1301','DELI1302','DEMI1301','DSSI1302',
         'DCUI2101','DEFI2101','DELI2101','DELI2102','DSSI2101','DSSI2102',
         'DEEI2201','DELI2201','DGCI2201','DSSI2201',
         'DELI2301','DERI2301','DMAI2301','DSPI2301','DSSI2301']
placeholders = ','.join(['%s']*len(codes))
cur.execute(f'SELECT courseID, coursename FROM acad_course WHERE courseID IN ({placeholders})', codes)
print('=== Courses found ===')
found = []
for r in cur.fetchall():
    print(r)
    found.append(r[0])
missing = [c for c in codes if c not in found]
print('=== MISSING courses ===', missing)

# Also check acad_course columns
cur.execute("SHOW COLUMNS FROM acad_course")
print('=== acad_course columns ===')
for r in cur.fetchall(): print(r)

conn.close()
