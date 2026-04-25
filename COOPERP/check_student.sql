-- Check if student MRU2025003471 exists in acad_student table
SELECT 
    'acad_student' as source,
    id,
    regno,
    firstname,
    othername,
    email,
    studphone,
    entryyear
FROM campus_dynamics.acad_student
WHERE regno = 'MRU2025003471'
LIMIT 1;

-- Also check portal users table by registration number as username
SELECT 
    'my_aspnet_users' as source,
    id,
    name,
    verified_email,
    CAST(createdate AS VARCHAR) as createdate
FROM campus_dynamics_portal.my_aspnet_users
WHERE LOWER(TRIM(name)) = LOWER('MRU2025003471')
LIMIT 1;

-- Check if there's any user with this registration number or student ID in any form
SELECT 
    'Any match' as source,
    id,
    name,
    verified_email
FROM campus_dynamics_portal.my_aspnet_users
WHERE name LIKE '%2025003471%'
LIMIT 10;
