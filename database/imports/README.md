# Database Imports

Place vetted baseline SQL dumps in this folder when bootstrapping a fresh local or shared environment.

Expected names for this project:

- `main.sql`
- `admissions.sql`
- `accounts.sql`
- `portal.sql`

These files are intentionally ignored by git because they may be large and environment-specific.

Use them with:

```powershell
.\database\cd-db.ps1 init -CreateDatabases -ImportDumps -RunSeeds -RunValidation
```
