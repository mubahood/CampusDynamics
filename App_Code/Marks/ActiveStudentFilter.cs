using System;

/// <summary>
/// Single source of truth for the "active student" rule used by ALL exam-results
/// stats and summaries.
///
/// A student is ACTIVE only after completing onboarding and being flagged
/// <c>'ACTIVE STUDENT'</c> in the portal login store
/// <c>campus_dynamics_portal.my_aspnet_users.user_verification_status</c>
/// (where <c>name = regno</c>). Alumni ('ALUMNI'), not-yet-onboarded (NULL) and
/// accountless regnos are excluded, so counts — especially "not entered" — reflect
/// real active students instead of the entire historical registration/results tables.
///
/// PERFORMANCE: <c>my_aspnet_users.name</c> is UNIQUE-indexed, so this correlated
/// EXISTS resolves as an eq_ref index lookup (fastest form). Safe to use inside
/// aggregate COUNT/SUM/GROUP BY queries over the large marks tables.
///
/// Cross-database: callers usually run on the campus_dynamics (vacConnectionString)
/// connection; the clause fully-qualifies the portal table so it works either way
/// (same MySQL server), matching how acad_course_registration is referenced.
/// </summary>
public static class ActiveStudentFilter
{
    /// <summary>
    /// Returns an " AND EXISTS(...)" clause (leading space, ready to append to a WHERE)
    /// restricting to active students. <paramref name="regnoExpr"/> is the SQL expression
    /// for the row's registration number, e.g. "r.regno", "cr.regno", "s.regno".
    /// </summary>
    public static string Clause(string regnoExpr)
    {
        return " AND EXISTS(SELECT 1 FROM campus_dynamics_portal.my_aspnet_users u_asf " +
               "WHERE u_asf.name=" + regnoExpr + " AND u_asf.user_verification_status='ACTIVE STUDENT') ";
    }

    /// <summary>Same predicate without the leading "AND", for use after WHERE/AND yourself.</summary>
    public static string Predicate(string regnoExpr)
    {
        return " EXISTS(SELECT 1 FROM campus_dynamics_portal.my_aspnet_users u_asf " +
               "WHERE u_asf.name=" + regnoExpr + " AND u_asf.user_verification_status='ACTIVE STUDENT') ";
    }
}
