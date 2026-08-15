using System;
using System.Collections.Generic;
using MySql.Data.MySqlClient;

// Test harness for the Course Records Correction Centre.
// Builds controlled fixtures on the test student, runs the engine, asserts, cleans up.
public static class CCTest
{
    const string CS = "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;Allow User Variables=True;";
    const string STU = "MRU2027000002";
    const string STU2 = "MRUCCTEST0001";
    const string OLD = "ZZOLD100";
    const string NEW = "ZZNEW100";
    static int pass = 0, fail = 0;

    static void Ok(string what, bool cond, string detail = "")
    {
        if (cond) { pass++; Console.WriteLine("  PASS  " + what); }
        else { fail++; Console.WriteLine("  FAIL  " + what + (detail == "" ? "" : "  -> " + detail)); }
    }

    static void Ex(string sql, params object[] ps)
    {
        using (var c = new MySqlConnection(CS)) { c.Open(); using (var cmd = new MySqlCommand(sql, c)) { AddP(cmd, ps); cmd.ExecuteNonQuery(); } }
    }
    static object Sc(string sql, params object[] ps)
    {
        using (var c = new MySqlConnection(CS)) { c.Open(); using (var cmd = new MySqlCommand(sql, c)) { AddP(cmd, ps); return cmd.ExecuteScalar(); } }
    }
    static void AddP(MySqlCommand cmd, object[] ps)
    { for (int i = 0; i < ps.Length; i += 2) cmd.Parameters.AddWithValue((string)ps[i], ps[i + 1]); }
    static string Str(string sql, params object[] ps) { object o = Sc(sql, ps); return o == null || o == DBNull.Value ? "" : Convert.ToString(o); }
    static int Num(string sql, params object[] ps) { object o = Sc(sql, ps); return o == null || o == DBNull.Value ? 0 : Convert.ToInt32(o); }

    static MarksScope Admin()
    {
        return new MarksScope { IsAdmin = true, Mode = "all", Label = "All faculties & departments", RoleNote = "Administrator", AllowedProgCodes = null };
    }

    static void Cleanup()
    {
        Ex("DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno IN (@a,@b) AND courseID IN (@o,@n)", "@a", STU, "@b", STU2, "@o", OLD, "@n", NEW);
        Ex("DELETE FROM campus_dynamics.acad_results WHERE regno IN (@a,@b) AND courseid IN (@o,@n)", "@a", STU, "@b", STU2, "@o", OLD, "@n", NEW);
        Ex("DELETE FROM campus_dynamics.acad_transcript_results WHERE regno IN (@a,@b) AND courseid IN (@o,@n)", "@a", STU, "@b", STU2, "@o", OLD, "@n", NEW);
        Ex("DELETE FROM campus_dynamics.acad_course WHERE courseID IN (@o,@n)", "@o", OLD, "@n", NEW);
        Ex("DELETE r FROM campus_dynamics.acad_correction_row r JOIN campus_dynamics.acad_correction_batch b ON b.id=r.batch_id WHERE b.reason LIKE 'CCTEST%'");
        Ex("DELETE FROM campus_dynamics.acad_correction_batch WHERE reason LIKE 'CCTEST%'");
        Ex("DELETE FROM campus_dynamics.acad_student WHERE regno=@b", "@b", STU2);
    }

    static long AddReg(string regno, string code, string year, int sem, string status, string stage, int? total)
    {
        Ex("INSERT INTO campus_dynamics_portal.acad_course_registration " +
           "(regno,courseID,acad_year,semester,course_status,prog_id,stud_session,registration_type,lecturer_status,mark_stage,provisional_total_marks) " +
           "VALUES (@r,@c,@y,@s,@st,'TEST','DAY','NORMAL','APPROVED',@ms,@t)",
           "@r", regno, "@c", code, "@y", year, "@s", sem, "@st", status, "@ms", stage,
           "@t", total.HasValue ? (object)total.Value : DBNull.Value);
        return Convert.ToInt64(Sc("SELECT LAST_INSERT_ID()"));
    }

    public static void Main()
    {
        Console.WriteLine("=== Course Records Correction Centre — engine tests ===\n");
        Cleanup();

        // Catalogue fixtures
        Ex("INSERT INTO campus_dynamics.acad_course (courseID,courseName,CreditUnit,stat,course_state) VALUES (@c,'ZZ Test Course OLD',3,'ACTIVE','ACTIVE')", "@c", OLD);
        Ex("INSERT INTO campus_dynamics.acad_course (courseID,courseName,CreditUnit,stat,course_state) VALUES (@c,'ZZ Test Course NEW',3,'ACTIVE','ACTIVE')", "@c", NEW);

        // ---------------- Scenario A: clean move + satellites + reversal ----------------
        Console.WriteLine("A. Clean move, satellites carried, then reversal");
        long rA = AddReg(STU, OLD, "2026/2027", 1, "NORMAL", "NOT_ENTERED", null);
        Ex("INSERT INTO campus_dynamics.acad_results (regno,courseid,semester,acad,studyyear,score,grade,gradept,gpa,CreditUnits,progid,is_retake) " +
           "VALUES (@r,@c,1,'2026/2027',2,71,'B',4.0,4.0,3,'TEST',0)", "@r", STU, "@c", OLD);
        Ex("INSERT INTO campus_dynamics.acad_transcript_results (regno,courseid,semester,acad,studyyear,progid) VALUES (@r,@c,1,'2026/2027',2,'TEST')", "@r", STU, "@c", OLD);

        var cfg = new CorrectionConfig
        {
            operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW,
            students = STU, reason = "CCTEST scenario A", moveResults = true
        };
        var pv = CourseCorrectionService.Preview(cfg, Admin());
        Ok("preview succeeds", pv.success, pv.message);
        Ok("one actionable row", pv.actionable == 1, "actionable=" + pv.actionable);
        Ok("satellites counted (result + transcript)", pv.satelliteRows == 2, "satellites=" + pv.satelliteRows);
        Ok("checksum produced", pv.checksum.Length > 0);

        var ap = CourseCorrectionService.Apply(cfg, Admin(), "cctest", "127.0.0.1", pv.checksum);
        Ok("apply succeeds", ap.success, ap.message);
        Ok("1 registration moved", ap.rowsApplied == 1, "applied=" + ap.rowsApplied);
        Ok("2 satellite rows moved", ap.satelliteRows == 2, "satellites=" + ap.satelliteRows);
        Ok("no residual on old code", ap.residual == 0, "residual=" + ap.residual);
        Ok("registration now on new code", Str("SELECT courseID FROM campus_dynamics_portal.acad_course_registration WHERE ID=@i", "@i", rA) == NEW);
        Ok("result now on new code", Num("SELECT COUNT(*) FROM campus_dynamics.acad_results WHERE regno=@r AND courseid=@c", "@r", STU, "@c", NEW) == 1);
        Ok("transcript now on new code", Num("SELECT COUNT(*) FROM campus_dynamics.acad_transcript_results WHERE regno=@r AND courseid=@c", "@r", STU, "@c", NEW) == 1);
        Ok("3 snapshots stored", Num("SELECT COUNT(*) FROM campus_dynamics.acad_correction_row WHERE batch_id=@b AND action='UPDATE'", "@b", ap.batchId) == 3,
           "rows=" + Num("SELECT COUNT(*) FROM campus_dynamics.acad_correction_row WHERE batch_id=@b", "@b", ap.batchId));
        Ok("before-image holds the old code",
           Str("SELECT before_json FROM campus_dynamics.acad_correction_row WHERE batch_id=@b AND table_name='acad_course_registration' LIMIT 1", "@b", ap.batchId).Contains(OLD));

        var rv = CourseCorrectionService.Reverse(ap.batchId, "CCTEST reversal A", Admin(), "cctest", "127.0.0.1", null);
        Ok("reversal succeeds", rv.success, rv.message);
        Ok("3 records restored", rv.rowsApplied == 3, "restored=" + rv.rowsApplied);
        Ok("registration back on old code", Str("SELECT courseID FROM campus_dynamics_portal.acad_course_registration WHERE ID=@i", "@i", rA) == OLD);
        Ok("result back on old code", Num("SELECT COUNT(*) FROM campus_dynamics.acad_results WHERE regno=@r AND courseid=@c", "@r", STU, "@c", OLD) == 1);
        Ok("nothing left on the new code", Num("SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND courseID=@c", "@r", STU, "@c", NEW) == 0);
        Ok("batch marked REVERSED", Str("SELECT status FROM campus_dynamics.acad_correction_batch WHERE id=@b", "@b", ap.batchId) == "REVERSED");
        Ok("second reversal refused", !CourseCorrectionService.Reverse(ap.batchId, "CCTEST double reverse", Admin(), "cctest", "127.0.0.1", null).success);

        // ---------------- Scenario B: duplicate target ----------------
        Console.WriteLine("\nB. Target slot already occupied");
        AddReg(STU, NEW, "2026/2027", 2, "NORMAL", "NOT_ENTERED", null);
        AddReg(STU, OLD, "2026/2027", 2, "NORMAL", "NOT_ENTERED", null);
        var cfgB = new CorrectionConfig { operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW, students = STU, reason = "CCTEST scenario B" };
        var pvB = CourseCorrectionService.Preview(cfgB, Admin());
        int dup = 0, mv = 0;
        foreach (var r in pvB.rows) { if (r.verdict == CorrectionVerdict.SkippedDuplicate) dup++; if (r.verdict == CorrectionVerdict.Moved) mv++; }
        Ok("duplicate detected", dup == 1, "dup=" + dup + " moved=" + mv);
        Ok("the sem-1 row is still movable", mv == 1, "moved=" + mv);

        // ---------------- Scenario C: published rows excluded by default ----------------
        Console.WriteLine("\nC. Published marks excluded unless asked for");
        AddReg(STU, OLD, "2026/2027", 3, "NORMAL", "PUBLISHED", 77);
        var cfgC = new CorrectionConfig { operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW, students = STU, reason = "CCTEST scenario C" };
        var pvC = CourseCorrectionService.Preview(cfgC, Admin());
        int pub = 0; foreach (var r in pvC.rows) if (r.verdict == CorrectionVerdict.SkippedPublished) pub++;
        Ok("published row skipped by default", pub == 1, "published-skipped=" + pub);
        cfgC.includePublished = true;
        var pvC2 = CourseCorrectionService.Preview(cfgC, Admin());
        int pub2 = 0; foreach (var r in pvC2.rows) if (r.verdict == CorrectionVerdict.SkippedPublished) pub2++;
        Ok("published row included when ticked", pub2 == 0, "still-skipped=" + pub2);

        // ---------------- Scenario D: acad_results unique(regno,courseid) clash ----------------
        Console.WriteLine("\nD. Student already has a result on the target code");
        Ex("INSERT INTO campus_dynamics.acad_student (regno,firstname,othername,progid,entryyear,duration) VALUES (@r,'CC','Tester','TEST',2026,3)", "@r", STU2);
        AddReg(STU2, OLD, "2026/2027", 1, "NORMAL", "NOT_ENTERED", null);
        Ex("INSERT INTO campus_dynamics.acad_results (regno,courseid,semester,acad,studyyear,score,grade,gradept,gpa,CreditUnits,progid,is_retake) VALUES (@r,@c,1,'2026/2027',1,60,'C',3.0,3.0,3,'TEST',0)", "@r", STU2, "@c", OLD);
        Ex("INSERT INTO campus_dynamics.acad_results (regno,courseid,semester,acad,studyyear,score,grade,gradept,gpa,CreditUnits,progid,is_retake) VALUES (@r,@c,2,'2026/2027',1,55,'D',2.0,2.0,3,'TEST',0)", "@r", STU2, "@c", NEW);
        var cfgD = new CorrectionConfig { operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW, students = STU2, reason = "CCTEST scenario D" };
        var pvD = CourseCorrectionService.Preview(cfgD, Admin());
        int clash = 0; foreach (var r in pvD.rows) if (r.verdict == CorrectionVerdict.SkippedResultClash) clash++;
        Ok("result clash detected before any write", clash == 1, "clash=" + clash + " rows=" + pvD.rows.Count);
        var apD = CourseCorrectionService.Apply(cfgD, Admin(), "cctest", "127.0.0.1", pvD.checksum);
        Ok("apply refuses when nothing is actionable", !apD.success, apD.message);
        Ok("both results still intact", Num("SELECT COUNT(*) FROM campus_dynamics.acad_results WHERE regno=@r", "@r", STU2) == 2);

        // ---------------- Scenario E: drift between preview and apply ----------------
        Console.WriteLine("\nE. Records change between preview and apply");
        var cfgE = new CorrectionConfig { operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW, students = STU, reason = "CCTEST scenario E" };
        var pvE = CourseCorrectionService.Preview(cfgE, Admin());
        Ex("UPDATE campus_dynamics_portal.acad_course_registration SET provisional_total_marks=99 WHERE regno=@r AND courseID=@c AND semester=1", "@r", STU, "@c", OLD);
        var apE = CourseCorrectionService.Apply(cfgE, Admin(), "cctest", "127.0.0.1", pvE.checksum);
        Ok("drift is detected and nothing is written", !apE.success, apE.message);
        Ok("registration untouched after refusal", Num("SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND courseID=@c", "@r", STU, "@c", OLD) >= 1);

        // ---------------- Scenario F: reversal refuses a record edited afterwards ----------------
        Console.WriteLine("\nF. Reversal leaves records that changed since the correction");
        var cfgF = new CorrectionConfig { operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW, students = STU, reason = "CCTEST scenario F", includePublished = true };
        var pvF = CourseCorrectionService.Preview(cfgF, Admin());
        var apF = CourseCorrectionService.Apply(cfgF, Admin(), "cctest", "127.0.0.1", pvF.checksum);
        Ok("apply succeeds", apF.success, apF.message);
        // somebody re-codes one of the moved rows by hand afterwards
        long any = Convert.ToInt64(Sc("SELECT pk_value FROM campus_dynamics.acad_correction_row WHERE batch_id=@b AND table_name='acad_course_registration' ORDER BY id LIMIT 1", "@b", apF.batchId));
        Ex("UPDATE campus_dynamics_portal.acad_course_registration SET courseID='ZZMANUAL' WHERE ID=@i", "@i", any);
        var rvF = CourseCorrectionService.Reverse(apF.batchId, "CCTEST reversal F", Admin(), "cctest", "127.0.0.1", null);
        Ok("reversal runs", rvF.success, rvF.message);
        Ok("the hand-edited row is left alone", Str("SELECT courseID FROM campus_dynamics_portal.acad_course_registration WHERE ID=@i", "@i", any) == "ZZMANUAL");
        Ok("it is recorded as CHANGED_SINCE",
            Num("SELECT COUNT(*) FROM campus_dynamics.acad_correction_row WHERE batch_id=@b AND verdict='CHANGED_SINCE'", "@b", rvF.batchId) >= 1);
        Ok("batch marked PARTIALLY_REVERSED", Str("SELECT status FROM campus_dynamics.acad_correction_batch WHERE id=@b", "@b", apF.batchId) == "PARTIALLY_REVERSED");

        // ---------------- Scenario G: scope cannot be widened ----------------
        Console.WriteLine("\nG. A restricted user cannot reach out-of-scope programmes");
        var narrow = new MarksScope { IsAdmin = false, Mode = "department", Label = "Department — Other", RoleNote = "Head of Department", AllowedProgCodes = new List<string> { "SOMETHINGELSE" } };
        var cfgG = new CorrectionConfig { operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW, students = STU, reason = "CCTEST scenario G" };
        var pvG = CourseCorrectionService.Preview(cfgG, narrow);
        Ok("out-of-scope preview returns nothing", pvG.rows.Count == 0, "rows=" + pvG.rows.Count);
        var apG = CourseCorrectionService.Apply(cfgG, narrow, "cctest", "127.0.0.1", pvG.checksum);
        Ok("out-of-scope apply refuses", !apG.success, apG.message);

        // ---------------- Scenario H: validation ----------------
        Console.WriteLine("\nH. Validation");
        Ok("same source and target refused",
            !CourseCorrectionService.Preview(new CorrectionConfig { sourceCode = OLD, targetCode = OLD, reason = "CCTEST" }, Admin()).success);
        Ok("missing reason refused on apply",
            !CourseCorrectionService.Apply(new CorrectionConfig { sourceCode = OLD, targetCode = NEW, reason = "" }, Admin(), "cctest", "1.1.1.1", null).success);
        Ok("merge refused for a non-administrator",
            !CourseCorrectionService.Preview(new CorrectionConfig { operation = CorrectionOp.CourseMerge, sourceCode = OLD, targetCode = NEW, reason = "CCTEST" },
                new MarksScope { IsAdmin = false, AllowedProgCodes = new List<string> { "TEST" }, Label = "d", RoleNote = "HOD" }).success);

        // ---------------- Scenario I: term transfer ----------------
        Console.WriteLine("\nI. Registration term transfer");
        Ex("DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND courseID IN (@o,@n,'ZZMANUAL')", "@r", STU, "@o", OLD, "@n", NEW);
        Ex("DELETE FROM campus_dynamics.acad_results WHERE regno=@r AND courseid IN (@o,@n)", "@r", STU, "@o", OLD, "@n", NEW);
        Ex("DELETE FROM campus_dynamics.acad_transcript_results WHERE regno=@r AND courseid IN (@o,@n)", "@r", STU, "@o", OLD, "@n", NEW);
        long rI = AddReg(STU, OLD, "2024/2025", 1, "NORMAL", "NOT_ENTERED", null);
        Ex("INSERT INTO campus_dynamics.acad_results (regno,courseid,semester,acad,studyyear,score,grade,gradept,gpa,CreditUnits,progid,is_retake) VALUES (@r,@c,1,'2024/2025',1,80,'A',5,5,3,'TEST',0)", "@r", STU, "@c", OLD);
        var cfgI = new CorrectionConfig
        {
            operation = CorrectionOp.TermTransfer, sourceYear = "2024/2025", sourceSemester = "1",
            targetYear = "2025/2026", targetSemester = "2", sourceCode = OLD, students = STU, reason = "CCTEST scenario I"
        };
        var pvI = CourseCorrectionService.Preview(cfgI, Admin());
        Ok("term preview finds the row", pvI.actionable == 1, "actionable=" + pvI.actionable + " msg=" + pvI.message);
        var apI = CourseCorrectionService.Apply(cfgI, Admin(), "cctest", "127.0.0.1", pvI.checksum);
        Ok("term transfer applies", apI.success, apI.message);
        Ok("registration term changed", Str("SELECT CONCAT(acad_year,'/',semester) FROM campus_dynamics_portal.acad_course_registration WHERE ID=@i", "@i", rI) == "2025/2026/2");
        Ok("result term moved with it", Str("SELECT CONCAT(acad,'/',semester) FROM campus_dynamics.acad_results WHERE regno=@r AND courseid=@c", "@r", STU, "@c", OLD) == "2025/2026/2");
        var rvI = CourseCorrectionService.Reverse(apI.batchId, "CCTEST reversal I", Admin(), "cctest", "127.0.0.1", null);
        Ok("term reversal succeeds", rvI.success, rvI.message);
        Ok("registration term restored", Str("SELECT CONCAT(acad_year,'/',semester) FROM campus_dynamics_portal.acad_course_registration WHERE ID=@i", "@i", rI) == "2024/2025/1");
        Ok("result term restored", Str("SELECT CONCAT(acad,'/',semester) FROM campus_dynamics.acad_results WHERE regno=@r AND courseid=@c", "@r", STU, "@c", OLD) == "2024/2025/1");

        // ---------------- Scenario J: self-collision inside one batch ----------------
        Console.WriteLine("\nJ. Two records in the same batch landing on one slot");
        Ex("DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND courseID IN (@o,@n)", "@r", STU, "@o", OLD, "@n", NEW);
        Ex("DELETE FROM campus_dynamics.acad_results WHERE regno=@r AND courseid IN (@o,@n)", "@r", STU, "@o", OLD, "@n", NEW);
        AddReg(STU, OLD, "2023/2024", 1, "NORMAL", "NOT_ENTERED", null);
        AddReg(STU, OLD, "2023/2024", 2, "NORMAL", "NOT_ENTERED", null);
        var cfgJ = new CorrectionConfig
        {
            operation = CorrectionOp.TermTransfer, sourceYear = "2023/2024",
            targetYear = "2022/2023", targetSemester = "1", sourceCode = OLD, students = STU, reason = "CCTEST scenario J"
        };
        var pvJ = CourseCorrectionService.Preview(cfgJ, Admin());
        int jMove = 0, jDup = 0;
        foreach (var r in pvJ.rows) { if (r.verdict == CorrectionVerdict.Moved) jMove++; if (r.verdict == CorrectionVerdict.SkippedDuplicate) jDup++; }
        Ok("only one of the pair is movable", jMove == 1, "moved=" + jMove);
        Ok("the other is flagged before any write", jDup == 1, "dup=" + jDup);
        var apJ = CourseCorrectionService.Apply(cfgJ, Admin(), "cctest", "127.0.0.1", pvJ.checksum);
        Ok("apply moves exactly one", apJ.success && apJ.rowsApplied == 1, apJ.message);
        CourseCorrectionService.Reverse(apJ.batchId, "CCTEST reversal J", Admin(), "cctest", "127.0.0.1", null);
        Ex("DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND courseID IN (@o,@n)", "@r", STU, "@o", OLD, "@n", NEW);

        // ---------------- Scenario K: course code merge, catalogue included ----------------
        Console.WriteLine("\nK. Course Code Merge consolidates the catalogue and archives the old code");
        long rK = AddReg(STU, OLD, "2026/2027", 1, "NORMAL", "NOT_ENTERED", null);
        Ex("INSERT INTO campus_dynamics.acad_programmecourses (progcode,course_code,study_year,semester,CurriculumID,course_type,status) VALUES ('TEST',@c,1,1,0,'CORE','Active')", "@c", OLD);
        Ex("INSERT INTO campus_dynamics_portal.acad_examsettings (empCode,courseID,acad_year,semester,prog_id,cyear,EntryYear,stud_session,dateCreated) VALUES ('CCT',@c,'2026/2027',1,'TEST',1,2026,'DAY',NOW())", "@c", OLD);
        var cfgK = new CorrectionConfig { operation = CorrectionOp.CourseMerge, sourceCode = OLD, targetCode = NEW, reason = "CCTEST scenario K", students = STU };
        var pvK = CourseCorrectionService.Preview(cfgK, Admin());
        Ok("merge preview works", pvK.success && pvK.actionable == 1, pvK.message + " actionable=" + pvK.actionable);
        var apK = CourseCorrectionService.Apply(cfgK, Admin(), "cctest", "127.0.0.1", pvK.checksum);
        Ok("merge applies", apK.success, apK.message);
        Ok("registration on surviving code", Str("SELECT courseID FROM campus_dynamics_portal.acad_course_registration WHERE ID=@i", "@i", rK) == NEW);
        Ok("curriculum repointed", Num("SELECT COUNT(*) FROM campus_dynamics.acad_programmecourses WHERE course_code=@c AND progcode='TEST'", "@c", NEW) == 1);
        Ok("exam setting repointed", Num("SELECT COUNT(*) FROM campus_dynamics_portal.acad_examsettings WHERE courseID=@c AND empCode='CCT'", "@c", NEW) == 1);
        Ok("retired code archived, not deleted", Str("SELECT course_state FROM campus_dynamics.acad_course WHERE courseID=@c", "@c", OLD) == "MERGED");
        Ok("archive points at the survivor", Str("SELECT IFNULL(merged_into,'') FROM campus_dynamics.acad_course WHERE courseID=@c", "@c", OLD) == NEW);
        var rvK = CourseCorrectionService.Reverse(apK.batchId, "CCTEST reversal K", Admin(), "cctest", "127.0.0.1", null);
        Ok("merge reverses", rvK.success, rvK.message);
        Ok("curriculum restored", Num("SELECT COUNT(*) FROM campus_dynamics.acad_programmecourses WHERE course_code=@c AND progcode='TEST'", "@c", OLD) == 1);
        Ok("exam setting restored", Num("SELECT COUNT(*) FROM campus_dynamics_portal.acad_examsettings WHERE courseID=@c AND empCode='CCT'", "@c", OLD) == 1);
        Ok("catalogue entry active again", Str("SELECT course_state FROM campus_dynamics.acad_course WHERE courseID=@c", "@c", OLD) == "ACTIVE");
        Ex("DELETE FROM campus_dynamics.acad_programmecourses WHERE course_code IN (@o,@n) AND progcode='TEST'", "@o", OLD, "@n", NEW);
        Ex("DELETE FROM campus_dynamics_portal.acad_examsettings WHERE empCode='CCT'");
        Ex("DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND courseID IN (@o,@n)", "@r", STU, "@o", OLD, "@n", NEW);

        // ---------------- Scenario L: real-scale batch ----------------
        Console.WriteLine("\nL. A batch the size of a real course (2,000 registrations)");
        var sw = System.Diagnostics.Stopwatch.StartNew();
        using (var c = new MySqlConnection(CS))
        {
            c.Open();
            using (var tx = c.BeginTransaction())
            {
                var sb = new System.Text.StringBuilder("INSERT INTO campus_dynamics_portal.acad_course_registration (regno,courseID,acad_year,semester,course_status,prog_id,stud_session,registration_type,lecturer_status,mark_stage) VALUES ");
                for (int i = 0; i < 2000; i++)
                {
                    if (i > 0) sb.Append(',');
                    sb.Append("('CCPERF").Append(i.ToString("D5")).Append("','").Append(OLD).Append("','2026/2027',1,'NORMAL','TEST','DAY','NORMAL','APPROVED','NOT_ENTERED')");
                }
                using (var cmd = new MySqlCommand(sb.ToString(), c, tx)) { cmd.CommandTimeout = 300; cmd.ExecuteNonQuery(); }
                tx.Commit();
            }
        }
        Console.WriteLine("     fixtures inserted in " + sw.ElapsedMilliseconds + " ms");
        var cfgL = new CorrectionConfig { operation = CorrectionOp.CourseTransfer, sourceCode = OLD, targetCode = NEW, programme = "TEST", reason = "CCTEST scenario L" };
        sw.Restart();
        var pvL = CourseCorrectionService.Preview(cfgL, Admin());
        long pms = sw.ElapsedMilliseconds;
        Ok("preview finds all 2,000", pvL.actionable == 2000, "actionable=" + pvL.actionable + " msg=" + pvL.message);
        Console.WriteLine("     preview took " + pms + " ms");
        sw.Restart();
        var apL = CourseCorrectionService.Apply(cfgL, Admin(), "cctest", "127.0.0.1", pvL.checksum);
        long ams = sw.ElapsedMilliseconds;
        Ok("2,000 registrations moved", apL.success && apL.rowsApplied == 2000, apL.message);
        Console.WriteLine("     apply took " + ams + " ms");
        Ok("apply completes inside 60 seconds", ams < 60000, ams + " ms");
        Ok("2,000 snapshots stored", Num("SELECT COUNT(*) FROM campus_dynamics.acad_correction_row WHERE batch_id=@b AND action='UPDATE'", "@b", apL.batchId) == 2000);
        sw.Restart();
        var rvL = CourseCorrectionService.Reverse(apL.batchId, "CCTEST reversal L", Admin(), "cctest", "127.0.0.1", null);
        long rms = sw.ElapsedMilliseconds;
        Ok("all 2,000 restored", rvL.success && rvL.rowsApplied == 2000, rvL.message);
        Console.WriteLine("     reversal took " + rms + " ms");
        Ok("every record back on the old code", Num("SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration WHERE regno LIKE 'CCPERF%' AND courseID=@c", "@c", OLD) == 2000);
        Ex("DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno LIKE 'CCPERF%'");

        Console.WriteLine("\n--- cleaning up ---");
        Ex("DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno IN (@a,@b) AND courseID IN (@o,@n,'ZZMANUAL')", "@a", STU, "@b", STU2, "@o", OLD, "@n", NEW);
        Cleanup();
        int leftovers = Num("SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration WHERE regno=@a AND courseID IN (@o,@n,'ZZMANUAL')", "@a", STU, "@o", OLD, "@n", NEW);
        Ok("test fixtures removed", leftovers == 0, "left=" + leftovers);

        Console.WriteLine("\n==============================");
        Console.WriteLine("  PASSED " + pass + "   FAILED " + fail);
        Console.WriteLine("==============================");
        Environment.Exit(fail == 0 ? 0 : 1);
    }
}
