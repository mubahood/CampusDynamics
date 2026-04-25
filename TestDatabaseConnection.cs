using System;
using System.Configuration;
using MySql.Data.MySqlClient;

class TestDatabaseConnection
{
    static void Main()
    {
        string acadConnStr = "server=localhost;User Id=root;password=24thdecember1977;Persist Security Info=True;database=campus_dynamics;charset=utf8";
        string portalConnStr = "server=localhost;User Id=root;password=24thdecember1977;Persist Security Info=True;database=campus_dynamics_portal;charset=utf8";

        try
        {
            // Test academic database connection
            Console.WriteLine("=== Testing Academic Database Connection ===");
            using (MySqlConnection conn = new MySqlConnection(acadConnStr))
            {
                conn.Open();
                Console.WriteLine("✓ Connected to academic database");

                // Count students
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student", conn))
                {
                    object count = cmd.ExecuteScalar();
                    Console.WriteLine($"Total students in database: {count}");
                }

                // Find first 5 students with email
                Console.WriteLine("\nFirst 5 students with email:");
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT id, regno, email, first_name, last_name FROM acad_student WHERE email IS NOT NULL AND email != '' LIMIT 5", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string regno = reader["regno"].ToString();
                            string email = reader["email"].ToString();
                            string firstName = reader["first_name"].ToString();
                            Console.WriteLine($"  {regno} | {email} | {firstName}");
                        }
                    }
                }

                // Check for MRU test student
                Console.WriteLine("\nSearching for test student MRU2025003471...");
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_student WHERE regno = 'MRU2025003471'", conn))
                {
                    object testCount = cmd.ExecuteScalar();
                    Console.WriteLine($"MRU2025003471 exists: {(testCount.ToString() == "0" ? "NO" : "YES")}");
                }
            }

            // Test portal database connection
            Console.WriteLine("\n=== Testing Portal Database Connection ===");
            using (MySqlConnection conn = new MySqlConnection(portalConnStr))
            {
                conn.Open();
                Console.WriteLine("✓ Connected to portal database");

                // Count portal users
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM my_aspnet_users", conn))
                {
                    object count = cmd.ExecuteScalar();
                    Console.WriteLine($"Total portal users: {count}");
                }
            }

            Console.WriteLine("\n✓ All database connections successful!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"✗ Error: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }
    }
}
