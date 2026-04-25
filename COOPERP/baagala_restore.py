"""
BAAGALA SARAH - Complete Academic Record Restoration
student numero: 12/U/DPE/0019/KB/INS
regno: MRU1200201305
Programme: DPE - DIPLOMA IN PRIMARY EDUCATION
Years: 2010/2011 - 2011/2012
"""
import mysql.connector
from datetime import date

# ── Connection ──────────────────────────────────────────────────────────────
ACAD_CFG  = dict(host='102.34.160.47', user='dbmanager', password='24thdecember1977', database='campus_dynamics')
PORTAL_CFG = dict(host='102.34.160.47', user='dbmanager', password='24thdecember1977', database='campus_dynamics_portal')

REGNO  = 'MRU1200201305'
PROGID = 'DPE'
SESSION = 'DAY'
RESTORED_BY     = 'SystemRestoration-BAAGALA_2026'
RESTORED_BY_SHORT = 'SysRestore-BAAGALA'   # ≤ 45 chars for approved_by col

# ── Grade helper ─────────────────────────────────────────────────────────────
def grade_info(score):
    if score >= 80: return 'A',  5.0
    if score >= 75: return 'B+', 4.5
    if score >= 70: return 'B',  4.0
    if score >= 65: return 'B-', 3.5
    if score >= 60: return 'C+', 3.0
    if score >= 55: return 'C',  2.5
    if score >= 50: return 'C-', 2.0
    if score >= 45: return 'D',  1.5
    return 'F', 0.0

# ── Academic semesters ───────────────────────────────────────────────────────
# Each semester: (acad_year, studyyear, semester, [(courseid, cw, exam, total)])
SEMESTERS = [
    # Year 1 Session 1 – 2010/2011
    ('2010/2011', 1, 1, [
        ('DIT1101',  31, 46, 77),
        ('PEOI1101', 29, 43, 72),
        ('PEOI1102', 25, 38, 63),
        ('PEOI1103', 27, 40, 67),
        ('PEOI1104', 28, 43, 71),
        ('PEOI1105', 30, 46, 76),
    ]),
    # Year 1 Session 2
    ('2010/2011', 1, 2, [
        ('DEFI1201', 26, 40, 66),
        ('DEFI1202', 28, 40, 68),
        ('DELI1201', 29, 44, 73),
        ('DELI1202', 32, 46, 78),
        ('DSSI1201', 25, 40, 65),
        ('DSSI1202', 34, 51, 85),
    ]),
    # Year 1 Session 3
    ('2010/2011', 1, 3, [
        ('DELI1301', 31, 46, 77),
        ('DELI1302', 32, 47, 79),
        ('DEMI1301', 26, 41, 67),
        ('DSSI1302', 28, 41, 69),
    ]),
    # Year 2 Session 1 – 2011/2012
    ('2011/2012', 2, 1, [
        ('DCUI2101', 28, 44, 72),
        ('DEFI2101', 26, 40, 66),
        ('DELI2101', 35, 53, 88),
        ('DELI2102', 32, 50, 82),
        ('DSSI2101', 28, 43, 71),
        ('DSSI2102', 30, 46, 76),
    ]),
    # Year 2 Session 2
    ('2011/2012', 2, 2, [
        ('DEEI2201', 21, 31, 52),
        ('DELI2201', 31, 46, 77),
        ('DGCI2201', 32, 46, 78),
        ('DSSI2201', 29, 44, 73),
    ]),
    # Year 2 Session 3
    ('2011/2012', 2, 3, [
        ('DELI2301', 25, 37, 62),
        ('DERI2301', 26, 38, 64),
        ('DMAI2301', 27, 41, 68),
        ('DSPI2301', 30, 44, 74),
        ('DSSI2301', 28, 42, 70),
    ]),
]

# ── Pre-compute running CGPA ─────────────────────────────────────────────────
running_gp_sum  = 0.0
running_cu_sum  = 0.0
SEMESTER_META = []   # (acad_year, studyyear, semester, sem_gpa, cgpa_after)
for (ay, yr, sem, courses) in SEMESTERS:
    sem_gp = 0.0; sem_cu = 0.0
    for (cid, cw, ex, tot) in courses:
        g, gp = grade_info(tot)
        cu = 2.0
        sem_gp += gp * cu; sem_cu += cu
        running_gp_sum += gp * cu; running_cu_sum += cu
    sem_gpa  = round(sem_gp / sem_cu, 2)
    cgpa_now = round(running_gp_sum / running_cu_sum, 2)
    SEMESTER_META.append((ay, yr, sem, sem_gpa, cgpa_now))
    print(f"Sem {ay} S{sem}: GPA={sem_gpa}  Running CGPA={cgpa_now}")

print(f"\nFinal CGPA: {SEMESTER_META[-1][4]}  Total CU: {int(running_cu_sum)}\n")

# ── Connect ──────────────────────────────────────────────────────────────────
acad   = mysql.connector.connect(**ACAD_CFG)
portal = mysql.connector.connect(**PORTAL_CFG)
ac = acad.cursor()
pc = portal.cursor()

errors = []
inserted = {'registration': 0, 'course_reg': 0, 'acad_results': 0, 'faculty_results': 0}

# ── 1. acad_registration ─────────────────────────────────────────────────────
print("=== Step 1: Semester Registrations ===")
for (ay, yr, sem, sem_gpa, cgpa) in SEMESTER_META:
    # Check if exists
    ac.execute("SELECT COUNT(*) FROM acad_registration WHERE regno=%s AND acad_year=%s AND semester=%s",
               (REGNO, ay, sem))
    if ac.fetchone()[0] > 0:
        print(f"  SKIP  {ay} S{sem} (already exists)")
        continue
    ac.execute("""
        INSERT INTO acad_registration
            (regno, acad_year, semester, regstatus, studyyear,
             id_cardStatus, residence_status, reg_CardStatus, examClearance,
             registeredBy, conducted_new_registration)
        VALUES (%s,%s,%s,'REGISTERED',%s,'PRINTED','UNKNOWN','PRINTED','CLEARED',%s,'Yes')
    """, (REGNO, ay, sem, yr, RESTORED_BY))
    inserted['registration'] += 1
    print(f"  INSERT {ay} S{sem} (year {yr})")

acad.commit()

# ── 2. acad_course_registration (portal DB) ───────────────────────────────────
print("\n=== Step 2: Course Registrations ===")
for (ay, yr, sem, courses) in SEMESTERS:
    for (cid, cw, ex, tot) in courses:
        pc.execute("SELECT COUNT(*) FROM acad_course_registration WHERE regno=%s AND courseID=%s AND acad_year=%s AND semester=%s",
                   (REGNO, cid, ay, sem))
        if pc.fetchone()[0] > 0:
            print(f"  SKIP  {cid} {ay} S{sem}")
            continue
        g, gp = grade_info(tot)
        pc.execute("""
            INSERT INTO acad_course_registration
                (regno, courseID, acad_year, semester, course_status, prog_id, stud_session,
                 provisional_course_work_marks, provisional_exam_marks, provisional_total_marks,
                 provisional_marks_status, provisional_submitted_by, provisional_published_by,
                 provisional_published_date)
            VALUES (%s,%s,%s,%s,'REGISTERED',%s,%s,%s,%s,%s,'approved',%s,%s,NOW())
        """, (REGNO, cid, ay, sem, PROGID, SESSION, cw, ex, tot, RESTORED_BY, RESTORED_BY))
        inserted['course_reg'] += 1
        print(f"  INSERT {cid} {ay} S{sem} cw={cw} ex={ex} tot={tot} {g}")

portal.commit()

# ── 3. acad_results ──────────────────────────────────────────────────────────
print("\n=== Step 3: acad_results ===")
for idx, (ay, yr, sem, courses) in enumerate(SEMESTERS):
    sem_gpa = SEMESTER_META[idx][3]
    for (cid, cw, ex, tot) in courses:
        ac.execute("SELECT COUNT(*) FROM acad_results WHERE regno=%s AND courseid=%s AND acad=%s AND semester=%s",
                   (REGNO, cid, ay, sem))
        if ac.fetchone()[0] > 0:
            print(f"  SKIP  {cid} {ay} S{sem}")
            continue
        g, gp = grade_info(tot)
        ac.execute("""
            INSERT INTO acad_results
                (regno, courseid, semester, acad, studyyear, score, grade, gradept, gpa,
                 result_comment, CreditUnits, progid)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,'RESTORED',%s,%s)
        """, (REGNO, cid, sem, ay, yr, tot, g, gp, sem_gpa, 2.0, PROGID))
        inserted['acad_results'] += 1
        print(f"  INSERT {cid} {ay} S{sem} tot={tot} {g}({gp}) semGPA={sem_gpa}")

acad.commit()

# ── 4. acad_examresults_faculty ───────────────────────────────────────────────
print("\n=== Step 4: acad_examresults_faculty ===")
# inspect columns first
ac.execute("SHOW COLUMNS FROM acad_examresults_faculty")
cols = [r[0] for r in ac.fetchall()]
print("  Columns:", cols)

for idx, (ay, yr, sem, courses) in enumerate(SEMESTERS):
    sem_gpa = SEMESTER_META[idx][3]
    for (cid, cw, ex, tot) in courses:
        ac.execute("SELECT COUNT(*) FROM acad_examresults_faculty WHERE regno=%s AND course_id=%s AND acadyear=%s AND semester=%s",
                   (REGNO, cid, ay, sem))
        if ac.fetchone()[0] > 0:
            print(f"  SKIP  {cid} {ay} S{sem}")
            continue
        g, gp = grade_info(tot)
        ac.execute("""
            INSERT INTO acad_examresults_faculty
                (regno, course_id, acadyear, semester, cw_mark, ex_mark, total_mark,
                 grade, gradept, exam_status, cyear, approved_by, creditUnits, gpa, progid, stud_session)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,'PASS',%s,%s,2,%s,%s,%s)
        """, (REGNO, cid, ay, sem, cw, ex, tot, g, gp, yr, RESTORED_BY_SHORT, sem_gpa, PROGID, SESSION))
        inserted['faculty_results'] += 1
        print(f"  INSERT {cid} {ay} S{sem} cw={cw} ex={ex} {g}")

acad.commit()

# ── Summary ───────────────────────────────────────────────────────────────────
print(f"""
========================================================
  RESTORATION COMPLETE FOR BAAGALA SARAH ({REGNO})
========================================================
  Semester registrations inserted : {inserted['registration']}
  Course registrations inserted   : {inserted['course_reg']}
  acad_results rows inserted      : {inserted['acad_results']}
  acad_examresults_faculty rows   : {inserted['faculty_results']}
  Final CGPA                      : {SEMESTER_META[-1][4]}
  Total Credit Units              : {int(running_cu_sum)}
  Class of Award                  : {'SECOND CLASS UPPER' if SEMESTER_META[-1][4] >= 3.60 else 'SECOND CLASS LOWER'}
========================================================
""")

acad.close()
portal.close()
