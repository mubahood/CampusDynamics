using System;
using System.Collections.Generic;
using System.IO;
using System.Configuration;
using MySql.Data.MySqlClient;
using DevExpress.XtraReports.UI;
using ResultsDataTableAdapters;

public sealed class AcademicDocumentPdfService
{
	public sealed class ExportResult
	{
		public bool Success { get; set; }
		public string Message { get; set; }
		public string FileName { get; set; }
		public string ContentType { get; set; }
		public byte[] Content { get; set; }
		public int GeneratedCount { get; set; }
	}

	public ExportResult GeneratePdf(string documentType, IEnumerable<string> regnos)
	{
		try
		{
			List<string> normalizedRegnos = NormalizeRegnos(regnos);
			if (normalizedRegnos.Count == 0)
			{
				return new ExportResult
				{
					Success = false,
					Message = "No student registration numbers were provided."
				};
			}

			string normalizedDocumentType = NormalizeDocumentType(documentType);
			if (string.IsNullOrEmpty(normalizedDocumentType))
			{
				return new ExportResult
				{
					Success = false,
					Message = "Unsupported document type. Choose Transcript or Certificate."
				};
			}

			string diagnosticMessage = string.Empty;
			ResultsData dataSource = BuildSelectedStudentsData(normalizedRegnos, out diagnosticMessage);
			if (dataSource == null || dataSource.acad_GetBatchStudentTranscriptData == null || dataSource.acad_GetBatchStudentTranscriptData.Count == 0)
			{
				return new ExportResult
				{
					Success = false,
					Message = string.IsNullOrEmpty(diagnosticMessage)
						? "No printable academic document data was found for the selected student(s)."
						: diagnosticMessage
				};
			}

			XtraReport report = null;
			try
			{
				report = CreateReport(normalizedDocumentType, dataSource);
				if (report == null)
				{
					return new ExportResult
					{
						Success = false,
						Message = "Could not create the requested report template."
					};
				}

				using (MemoryStream output = new MemoryStream())
				{
					report.CreateDocument();
					report.ExportToPdf(output);

					return new ExportResult
					{
						Success = true,
						Content = output.ToArray(),
						ContentType = "application/pdf",
						FileName = BuildFileName(normalizedDocumentType, normalizedRegnos),
						GeneratedCount = dataSource.acad_GetBatchStudentTranscriptData.Count
					};
				}
			}
			finally
			{
				if (report != null)
					report.Dispose();

				if (dataSource != null)
					dataSource.Dispose();
			}
		}
		catch (Exception ex)
		{
			return new ExportResult
			{
				Success = false,
				Message = "Error generating academic document PDF: " + ex.Message
			};
		}
	}

	private static List<string> NormalizeRegnos(IEnumerable<string> regnos)
	{
		List<string> list = new List<string>();
		if (regnos == null)
			return list;

		foreach (string regno in regnos)
		{
			string value = (regno ?? string.Empty).Trim();
			if (string.IsNullOrEmpty(value))
				continue;

			bool exists = false;
			for (int i = 0; i < list.Count; i++)
			{
				if (string.Equals(list[i], value, StringComparison.OrdinalIgnoreCase))
				{
					exists = true;
					break;
				}
			}

			if (!exists)
				list.Add(value);
		}

		return list;
	}

	private static string NormalizeDocumentType(string documentType)
	{
		string value = (documentType ?? string.Empty).Trim().ToUpperInvariant();
		if (value == "TRANSCRIPT")
			return "Transcript";
		if (value == "CERTIFICATE")
			return "Certificate";
		return string.Empty;
	}

	private static string BuildFileName(string documentType, IList<string> regnos)
	{
		string stamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
		if (regnos != null && regnos.Count == 1)
			return string.Format("{0}_{1}_{2}.pdf", documentType, MakeSafeFileName(regnos[0]), stamp);

		int count = regnos != null ? regnos.Count : 0;
		return string.Format("{0}_Batch_{1}_Students_{2}.pdf", documentType, count, stamp);
	}

	private static string MakeSafeFileName(string value)
	{
		string safe = value ?? string.Empty;
		foreach (char ch in Path.GetInvalidFileNameChars())
			safe = safe.Replace(ch, '_');
		return safe;
	}

	private static XtraReport CreateReport(string documentType, ResultsData dataSource)
	{
		if (documentType == "Transcript")
		{
			FinalTranscript report = new FinalTranscript();
			report.DataSource = dataSource;
			report.RequestParameters = false;
			return report;
		}

		if (documentType == "Certificate")
		{
			Certificate report = new Certificate();
			report.DataSource = dataSource;
			report.RequestParameters = false;
			return report;
		}

		return null;
	}

	private static ResultsData BuildSelectedStudentsData(IEnumerable<string> regnos, out string diagnosticMessage)
	{
		diagnosticMessage = string.Empty;
		ResultsData master = new ResultsData();
		master.EnforceConstraints = false;

		acad_universityTableAdapter universityAdapter = new acad_universityTableAdapter();
		acad_GetBatchStudentTranscriptDataTableAdapter transcriptAdapter = new acad_GetBatchStudentTranscriptDataTableAdapter();

		universityAdapter.Fill(master.acad_university);

		List<string> diagnostics = new List<string>();

		foreach (string regno in regnos)
		{
			ResultsData single = new ResultsData();
			single.EnforceConstraints = false;

			int rowsBeforeFallback = 0;
			transcriptAdapter.SingleTranscript(single.acad_GetBatchStudentTranscriptData, regno);
			rowsBeforeFallback = single.acad_GetBatchStudentTranscriptData != null ? single.acad_GetBatchStudentTranscriptData.Count : 0;
			CertificateDataHelper.EnsureSingleStudentData(single, regno);
			int rowsAfterFallback = single.acad_GetBatchStudentTranscriptData != null ? single.acad_GetBatchStudentTranscriptData.Count : 0;

			if (single.acad_GetBatchStudentTranscriptData != null && single.acad_GetBatchStudentTranscriptData.Count > 0)
			{
				foreach (ResultsData.acad_GetBatchStudentTranscriptDataRow row in single.acad_GetBatchStudentTranscriptData.Rows)
					master.acad_GetBatchStudentTranscriptData.ImportRow(row);
			}
			else
			{
				diagnostics.Add(BuildUnavailableReason(regno, rowsBeforeFallback, rowsAfterFallback));
			}

			single.Dispose();
		}

		CertificateDataHelper.RemapMastersClassifications(master);

		if (master.acad_GetBatchStudentTranscriptData == null || master.acad_GetBatchStudentTranscriptData.Count == 0)
		{
			diagnosticMessage = diagnostics.Count > 0
				? string.Join(" ", diagnostics.ToArray())
				: "No printable academic document data was found for the selected student(s).";
		}

		return master;
	}

	private static string BuildUnavailableReason(string regno, int rowsBeforeFallback, int rowsAfterFallback)
	{
		string safeRegno = string.IsNullOrEmpty(regno) ? "(blank regno)" : regno;
		try
		{
			string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
				? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
				: string.Empty;

			if (string.IsNullOrEmpty(connStr))
			{
				return string.Format("{0}: classic document data was empty (SP rows: {1}, fallback rows: {2}) and the database connection for deeper diagnostics is unavailable.", safeRegno, rowsBeforeFallback, rowsAfterFallback);
			}

			using (MySqlConnection conn = new MySqlConnection(connStr))
			{
				conn.Open();

				bool studentExists = false;
				bool graduandExists = false;
				string studentName = string.Empty;
				string programmeName = string.Empty;

				using (MySqlCommand cmdStudent = new MySqlCommand(@"SELECT CONCAT(IFNULL(firstname,''), ' ', IFNULL(othername,'')) AS stud_name,
					(SELECT progname FROM acad_programme WHERE progcode = acad_student.progid LIMIT 1) AS prog_name
					FROM acad_student WHERE TRIM(regno)=@reg LIMIT 1", conn))
				{
					cmdStudent.Parameters.AddWithValue("@reg", safeRegno);
					using (MySqlDataReader reader = cmdStudent.ExecuteReader())
					{
						if (reader.Read())
						{
							studentExists = true;
							studentName = Convert.ToString(reader["stud_name"] ?? string.Empty).Trim();
							programmeName = Convert.ToString(reader["prog_name"] ?? string.Empty).Trim();
						}
					}
				}

				using (MySqlCommand cmdGrad = new MySqlCommand("SELECT COUNT(*) FROM acad_graduands WHERE TRIM(regno)=@reg", conn))
				{
					cmdGrad.Parameters.AddWithValue("@reg", safeRegno);
					graduandExists = Convert.ToInt32(cmdGrad.ExecuteScalar()) > 0;
				}

				if (!studentExists)
				{
					return string.Format("{0}: student record was not found in acad_student.", safeRegno);
				}

				if (!graduandExists)
				{
					return string.Format("{0}: no printable classic document data was found. The student{1}{2} is in acad_student but not in acad_graduands, and the classic SingleTranscript pipeline returned 0 rows. In the old system, certificates/transcripts are generated from the Transcript Document Centre graduand dataset, not from every student in New Student Info.",
						safeRegno,
						string.IsNullOrEmpty(studentName) ? string.Empty : " (" + studentName + ")",
						string.IsNullOrEmpty(programmeName) ? string.Empty : " for programme " + programmeName);
				}

				return string.Format("{0}: the student exists in the graduand dataset, but the classic SingleTranscript pipeline still returned no printable rows (SP rows: {1}, fallback rows: {2}). This usually means transcript preparation or transcript-format data is incomplete in the classic document setup.", safeRegno, rowsBeforeFallback, rowsAfterFallback);
			}
		}
		catch (Exception ex)
		{
			return string.Format("{0}: no printable academic document data was found, and diagnostic lookup failed: {1}", safeRegno, ex.Message);
		}
	}
}
