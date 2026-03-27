-- ================================================================
-- MIGRATION: Populate fin_programme_fees with actual fee amounts
-- Source: fin_fees_pay_schedule (2025 data, 2024 for Masters)
-- All amounts verified: same across DAY/WEEKEND/EVENING sessions
-- Date: 2025 Migration
-- ================================================================
USE campus_dynamics_accounts;

-- ================================================================
-- SECTION 1: PROGRAMMES WITH SPECIFIC FEE DATA (2025)
-- ================================================================

-- --- BACHELOR: STANDARD 630k TUITION (3yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=630000, y1_s1_functional=767000,
  y1_s2_tuition=630000, y1_s2_functional=677000,
  y2_s1_tuition=630000, y2_s1_functional=687000,
  y2_s2_tuition=630000, y2_s2_functional=653000,
  y3_s1_tuition=630000, y3_s1_functional=663000,
  y3_s2_tuition=630000, y3_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BBA';

UPDATE fin_programme_fees SET
  y1_s1_tuition=630000, y1_s1_functional=767000,
  y1_s2_tuition=630000, y1_s2_functional=677000,
  y2_s1_tuition=630000, y2_s1_functional=767000,
  y2_s2_tuition=630000, y2_s2_functional=653000,
  y3_s1_tuition=630000, y3_s1_functional=663000,
  y3_s2_tuition=630000, y3_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('BBM','BCOM','BPA','BSAF','BSM','BHRM');

UPDATE fin_programme_fees SET
  y1_s1_tuition=630000, y1_s1_functional=767000,
  y1_s2_tuition=630000, y1_s2_functional=677000,
  y2_s1_tuition=630000, y2_s1_functional=687000,
  y2_s2_tuition=630000, y2_s2_functional=853000,
  y3_s1_tuition=630000, y3_s1_functional=663000,
  y3_s2_tuition=630000, y3_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BAED';

UPDATE fin_programme_fees SET
  y1_s1_tuition=630000, y1_s1_functional=767000,
  y1_s2_tuition=630000, y1_s2_functional=877000,
  y2_s1_tuition=630000, y2_s1_functional=687000,
  y2_s2_tuition=630000, y2_s2_functional=933000,
  y3_s1_tuition=630000, y3_s1_functional=663000,
  y3_s2_tuition=630000, y3_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BECD';

UPDATE fin_programme_fees SET
  y1_s1_tuition=630000, y1_s1_functional=767000,
  y1_s2_tuition=630000, y1_s2_functional=877000,
  y2_s1_tuition=630000, y2_s1_functional=687000,
  y2_s2_tuition=630000, y2_s2_functional=853000,
  y3_s1_tuition=630000, y3_s1_functional=663000,
  y3_s2_tuition=630000, y3_s2_functional=733000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'SWSA';

UPDATE fin_programme_fees SET
  y1_s1_tuition=630000, y1_s1_functional=767000,
  y1_s2_tuition=630000, y1_s2_functional=677000,
  y2_s1_tuition=630000, y2_s1_functional=767000,
  y2_s2_tuition=630000, y2_s2_functional=653000,
  y3_s1_tuition=630000, y3_s1_functional=669000,
  y3_s2_tuition=630000, y3_s2_functional=939000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BPLM';

-- --- BACHELOR: ICT EDUCATION 680k (3yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=680000, y1_s1_functional=767000,
  y1_s2_tuition=680000, y1_s2_functional=677000,
  y2_s1_tuition=680000, y2_s1_functional=687000,
  y2_s2_tuition=680000, y2_s2_functional=853000,
  y3_s1_tuition=680000, y3_s1_functional=663000,
  y3_s2_tuition=680000, y3_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BEICT';

-- --- BACHELOR: ART/DESIGN 730k (3yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=730000, y1_s1_functional=985250,
  y1_s2_tuition=730000, y1_s2_functional=895250,
  y2_s1_tuition=730000, y2_s1_functional=905250,
  y2_s2_tuition=730000, y2_s2_functional=1071250,
  y3_s1_tuition=730000, y3_s1_functional=881250,
  y3_s2_tuition=730000, y3_s2_functional=951250,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BIFA';

UPDATE fin_programme_fees SET
  y1_s1_tuition=730000, y1_s1_functional=985250,
  y1_s2_tuition=730000, y1_s2_functional=895250,
  y2_s1_tuition=730000, y2_s1_functional=905250,
  y2_s2_tuition=730000, y2_s2_functional=1071250,
  y3_s1_tuition=730000, y3_s1_functional=881250,
  y3_s2_tuition=730000, y3_s2_functional=1151250,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BVS';

-- --- BACHELOR: IT/TECH 780k (3yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=780000, y1_s1_functional=867000,
  y1_s2_tuition=780000, y1_s2_functional=677000,
  y2_s1_tuition=780000, y2_s1_functional=787000,
  y2_s2_tuition=780000, y2_s2_functional=853000,
  y3_s1_tuition=780000, y3_s1_functional=763000,
  y3_s2_tuition=780000, y3_s2_functional=733000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BIT';

UPDATE fin_programme_fees SET
  y1_s1_tuition=780000, y1_s1_functional=887000,
  y1_s2_tuition=780000, y1_s2_functional=797000,
  y2_s1_tuition=780000, y2_s1_functional=887000,
  y2_s2_tuition=780000, y2_s2_functional=973000,
  y3_s1_tuition=780000, y3_s1_functional=783000,
  y3_s2_tuition=780000, y3_s2_functional=1053000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BMC';

UPDATE fin_programme_fees SET
  y1_s1_tuition=780000, y1_s1_functional=1033700,
  y1_s2_tuition=780000, y1_s2_functional=943700,
  y2_s1_tuition=780000, y2_s1_functional=953700,
  y2_s2_tuition=780000, y2_s2_functional=1119700,
  y3_s1_tuition=780000, y3_s1_functional=929700,
  y3_s2_tuition=780000, y3_s2_functional=1199700,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BTHM';

-- --- BACHELOR: ENGINEERING 1,455k (4yr but table holds 3yr) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=1455000, y1_s1_functional=1402000,
  y1_s2_tuition=1455000, y1_s2_functional=1312000,
  y2_s1_tuition=1455000, y2_s1_functional=1402000,
  y2_s2_tuition=1455000, y2_s2_functional=1488000,
  y3_s1_tuition=1455000, y3_s1_functional=1298000,
  y3_s2_tuition=1455000, y3_s2_functional=1488000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BCE';

UPDATE fin_programme_fees SET
  y1_s1_tuition=1455000, y1_s1_functional=1402000,
  y1_s2_tuition=1455000, y1_s2_functional=1312000,
  y2_s1_tuition=1455000, y2_s1_functional=1402000,
  y2_s2_tuition=1455000, y2_s2_functional=1488000,
  y3_s1_tuition=1455000, y3_s1_functional=1402000,
  y3_s2_tuition=1455000, y3_s2_functional=1488000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BEE';

-- --- BACHELOR: EDUCATION TRIMESTER 280k (3yr, 3sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=280000, y1_s1_functional=184000,
  y1_s2_tuition=280000, y1_s2_functional=154000,
  y1_s3_tuition=280000, y1_s3_functional=154000,
  y2_s1_tuition=280000, y2_s1_functional=154000,
  y2_s2_tuition=280000, y2_s2_functional=154000,
  y2_s3_tuition=280000, y2_s3_functional=154000,
  y3_s1_tuition=280000, y3_s1_functional=154000,
  y3_s2_tuition=280000, y3_s2_functional=154000,
  y3_s3_tuition=280000, y3_s3_functional=234000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('BBEI','BED(P)','BED(S)');

UPDATE fin_programme_fees SET
  y1_s1_tuition=280000, y1_s1_functional=184000,
  y1_s2_tuition=280000, y1_s2_functional=154000,
  y1_s3_tuition=280000, y1_s3_functional=154000,
  y2_s1_tuition=280000, y2_s1_functional=154000,
  y2_s2_tuition=280000, y2_s2_functional=264000,
  y2_s3_tuition=280000, y2_s3_functional=264000,
  y3_s1_tuition=280000, y3_s1_functional=154000,
  y3_s2_tuition=280000, y3_s2_functional=344000,
  y3_s3_tuition=280000, y3_s3_functional=344000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BED(ECD)';

-- --- DIPLOMA: STANDARD 430k (2yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=430000, y1_s1_functional=767000,
  y1_s2_tuition=430000, y1_s2_functional=677000,
  y2_s1_tuition=430000, y2_s1_functional=687000,
  y2_s2_tuition=430000, y2_s2_functional=733000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('DAF','DBA','DBM','DHRM','DPA','DPLM','DSM');

UPDATE fin_programme_fees SET
  y1_s1_tuition=430000, y1_s1_functional=917000,
  y1_s2_tuition=430000, y1_s2_functional=677000,
  y2_s1_tuition=430000, y2_s1_functional=837000,
  y2_s2_tuition=430000, y2_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DIT';

UPDATE fin_programme_fees SET
  y1_s1_tuition=430000, y1_s1_functional=767000,
  y1_s2_tuition=430000, y1_s2_functional=677000,
  y2_s1_tuition=430000, y2_s1_functional=687000,
  y2_s2_tuition=430000, y2_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'decd';

-- --- DIPLOMA: HIGHER 530k (2yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=985250,
  y1_s2_tuition=530000, y1_s2_functional=895250,
  y2_s1_tuition=530000, y2_s1_functional=905250,
  y2_s2_tuition=530000, y2_s2_functional=1151250,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('DAD','DFD');

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=984500,
  y1_s2_tuition=530000, y1_s2_functional=1094500,
  y2_s1_tuition=530000, y2_s1_functional=904500,
  y2_s2_tuition=530000, y2_s2_functional=1150500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DCE';

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=1058500,
  y1_s2_tuition=530000, y1_s2_functional=1168500,
  y2_s1_tuition=530000, y2_s1_functional=978500,
  y2_s2_tuition=530000, y2_s2_functional=1224500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DEE';

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=879500,
  y1_s2_tuition=530000, y1_s2_functional=789500,
  y2_s1_tuition=530000, y2_s1_functional=799500,
  y2_s2_tuition=530000, y2_s2_functional=1045500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DMC';

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=1044500,
  y1_s2_tuition=530000, y1_s2_functional=1154500,
  y2_s1_tuition=530000, y2_s1_functional=964500,
  y2_s2_tuition=530000, y2_s2_functional=1210500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DME';

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=1033700,
  y1_s2_tuition=530000, y1_s2_functional=943700,
  y2_s1_tuition=530000, y2_s1_functional=953700,
  y2_s2_tuition=530000, y2_s2_functional=1469700,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DTHM';

-- --- DIPLOMA: EDUCATION TRIMESTER 230k (2yr, 3sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=230000, y1_s1_functional=184000,
  y1_s2_tuition=230000, y1_s2_functional=154000,
  y1_s3_tuition=230000, y1_s3_functional=264000,
  y2_s1_tuition=230000, y2_s1_functional=154000,
  y2_s2_tuition=230000, y2_s2_functional=154000,
  y2_s3_tuition=230000, y2_s3_functional=344000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DPE';

-- --- CERTIFICATE: HEC 400k (1yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=400000, y1_s1_functional=430000,
  y1_s2_tuition=400000, y1_s2_functional=365000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'HEC';

-- --- MASTERS: MBA (2yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=1563500, y1_s1_functional=914500,
  y1_s2_tuition=1563500, y1_s2_functional=834500,
  y2_s1_tuition=1563500, y2_s1_functional=854500,
  y2_s2_tuition=1563500, y2_s2_functional=834500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'MBA';

-- --- MASTERS: MEMA (2yr, 3sem Y1 only) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=1585000, y1_s1_functional=914500,
  y1_s2_tuition=1585000, y1_s2_functional=834500,
  y1_s3_tuition=528000,  y1_s3_functional=289000,
  y2_s1_tuition=1563500, y2_s1_functional=854500,
  y2_s2_tuition=1563500, y2_s2_functional=834500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'MEMA';

-- --- MASTERS: MMC (2yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=1701500, y1_s1_functional=914500,
  y1_s2_tuition=1701500, y1_s2_functional=834500,
  y2_s1_tuition=1563500, y2_s1_functional=854500,
  y2_s2_tuition=1563500, y2_s2_functional=834500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'MMC';

-- --- MASTERS: MPCHD (2yr, 2sem) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=1808000, y1_s1_functional=914500,
  y1_s2_tuition=1808000, y1_s2_functional=834500,
  y2_s1_tuition=1563500, y2_s1_functional=854500,
  y2_s2_tuition=1563500, y2_s2_functional=834500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'MPCHD';


-- ================================================================
-- SECTION 2: PROGRAMMES MAPPED FROM SIMILAR TIERS (no specific data)
-- ================================================================

-- --- 1-YEAR CERTIFICATES: HEC tier (T=400000) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=400000, y1_s1_functional=430000,
  y1_s2_tuition=400000, y1_s2_functional=365000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('ACAD','ACBA','ACFD','ACGC','ACITE','ACJ','ACSM',
                   'CAD','CEI','CFD','CGC','CITE','CJ','CLIS','MSOP');

-- --- 1-YEAR PGD: Masters tier (T=1563500) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=1563500, y1_s1_functional=914500,
  y1_s2_tuition=1563500, y1_s2_functional=834500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('PGD','PGDPAM');

-- --- 2-YEAR TECHNICAL CERTIFICATES: Standard Diploma tier (T=430000) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=430000, y1_s1_functional=767000,
  y1_s2_tuition=430000, y1_s2_functional=677000,
  y2_s1_tuition=430000, y2_s1_functional=687000,
  y2_s2_tuition=430000, y2_s2_functional=733000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('CAEM','CBCP','CMEC','CMVT','CP','CRAC','CRTE','CWF');

-- --- 2-YEAR DIPLOMAS: Standard (T=430000) ---
-- DDS, DGC, DLIS - general non-tech diplomas

UPDATE fin_programme_fees SET
  y1_s1_tuition=430000, y1_s1_functional=767000,
  y1_s2_tuition=430000, y1_s2_functional=677000,
  y2_s1_tuition=430000, y2_s1_functional=687000,
  y2_s2_tuition=430000, y2_s2_functional=733000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('DDS','DGC','DLIS');

-- --- 2-YEAR DIPLOMAS: IT/Computing (T=430000, DIT functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=430000, y1_s1_functional=917000,
  y1_s2_tuition=430000, y1_s2_functional=677000,
  y2_s1_tuition=430000, y2_s1_functional=837000,
  y2_s2_tuition=430000, y2_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('DBC','DCS');

-- --- 2-YEAR DIPLOMAS: Art/Design (T=530000, DAD functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=985250,
  y1_s2_tuition=530000, y1_s2_functional=895250,
  y2_s1_tuition=530000, y2_s1_functional=905250,
  y2_s2_tuition=530000, y2_s2_functional=1151250,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('DADE','DADE/A');

-- --- 2-YEAR DIPLOMAS: Engineering (T=530000, DCE functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=984500,
  y1_s2_tuition=530000, y1_s2_functional=1094500,
  y2_s1_tuition=530000, y2_s1_functional=904500,
  y2_s2_tuition=530000, y2_s2_functional=1150500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('DAE','DWF','HDCE');

-- --- 2-YEAR DIPLOMAS: Journalism/Media (T=530000, DMC functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=530000, y1_s1_functional=879500,
  y1_s2_tuition=530000, y1_s2_functional=789500,
  y2_s1_tuition=530000, y2_s1_functional=799500,
  y2_s2_tuition=530000, y2_s2_functional=1045500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'DJ';

-- --- 2-YEAR DIPLOMAS: Education Trimester (T=230000, DPE functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=230000, y1_s1_functional=184000,
  y1_s2_tuition=230000, y1_s2_functional=154000,
  y1_s3_tuition=230000, y1_s3_functional=264000,
  y2_s1_tuition=230000, y2_s1_functional=154000,
  y2_s2_tuition=230000, y2_s2_functional=154000,
  y2_s3_tuition=230000, y2_s3_functional=344000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('DES','DSE','DSE/A','DVS');

-- --- 2-YEAR DIPLOMA: DVS also needs same education tier ---
-- (already included above)

-- --- 2-YEAR MASTERS: MHHS (MBA tier) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=1563500, y1_s1_functional=914500,
  y1_s2_tuition=1563500, y1_s2_functional=834500,
  y2_s1_tuition=1563500, y2_s1_functional=854500,
  y2_s2_tuition=1563500, y2_s2_functional=834500,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'MHHS';

-- --- 3-YEAR BACHELOR: Standard Business/Social (T=630000, BBA functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=630000, y1_s1_functional=767000,
  y1_s2_tuition=630000, y1_s2_functional=677000,
  y2_s1_tuition=630000, y2_s1_functional=687000,
  y2_s2_tuition=630000, y2_s2_functional=653000,
  y3_s1_tuition=630000, y3_s1_functional=663000,
  y3_s2_tuition=630000, y3_s2_functional=933000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('BAED/A','BBE','BDS','BEM','BES','BGC','BLIS',
                   'BMF','BMM','BPPM','BSCED','BSCEDU','BSDE','BSPM');

-- --- 3-YEAR BACHELOR: Art/Design (T=730000, BIFA functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=730000, y1_s1_functional=985250,
  y1_s2_tuition=730000, y1_s2_functional=895250,
  y2_s1_tuition=730000, y2_s1_functional=905250,
  y2_s2_tuition=730000, y2_s2_functional=1071250,
  y3_s1_tuition=730000, y3_s1_functional=881250,
  y3_s2_tuition=730000, y3_s2_functional=951250,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BADE';

-- --- 3-YEAR BACHELOR: IT/Computing (T=780000, BIT functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=780000, y1_s1_functional=867000,
  y1_s2_tuition=780000, y1_s2_functional=677000,
  y2_s1_tuition=780000, y2_s1_functional=787000,
  y2_s2_tuition=780000, y2_s2_functional=853000,
  y3_s1_tuition=780000, y3_s1_functional=763000,
  y3_s2_tuition=780000, y3_s2_functional=733000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode IN ('BBC','BCS','BSE');

-- --- 3-YEAR BACHELOR: PR/Communications (T=780000, BMC functional) ---

UPDATE fin_programme_fees SET
  y1_s1_tuition=780000, y1_s1_functional=887000,
  y1_s2_tuition=780000, y1_s2_functional=797000,
  y2_s1_tuition=780000, y2_s1_functional=887000,
  y2_s2_tuition=780000, y2_s2_functional=973000,
  y3_s1_tuition=780000, y3_s1_functional=783000,
  y3_s2_tuition=780000, y3_s2_functional=1053000,
  is_active='Yes', created_by='SYSTEM_MIGRATION'
WHERE progcode = 'BPRM';


-- ================================================================
-- VERIFICATION QUERIES
-- ================================================================

SELECT 'MIGRATION COMPLETE' AS status;

SELECT is_active, COUNT(*) AS cnt FROM fin_programme_fees GROUP BY is_active;

SELECT progcode, y1_s1_tuition, y1_s1_functional,
       (y1_s1_tuition + y1_s1_functional + y1_s2_tuition + y1_s2_functional +
        y1_s3_tuition + y1_s3_functional +
        y2_s1_tuition + y2_s1_functional + y2_s2_tuition + y2_s2_functional +
        y2_s3_tuition + y2_s3_functional +
        y3_s1_tuition + y3_s1_functional + y3_s2_tuition + y3_s2_functional +
        y3_s3_tuition + y3_s3_functional) AS grand_total
FROM fin_programme_fees
WHERE is_active = 'Yes'
ORDER BY grand_total DESC
LIMIT 10;

SELECT progcode FROM fin_programme_fees WHERE is_active = 'No' ORDER BY progcode;
