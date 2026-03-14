# Environment Variables and Local Configuration Strategy

This document defines the stable configuration policy for the Campus Dynamics workspace.

It exists to solve one recurring problem: contributors should be able to run the system against their own databases without creating merge conflicts, leaking credentials, or breaking other developers' setups.

---

## 1. Goal

The goal is to make configuration:

- predictable
- contributor-safe
- secret-safe
- low-conflict
- consistent across both projects

The two applications in this workspace are tightly related:

- **CampusDynamics** = main admin / ERP system
- **CampusDynamics_Portal** = student/staff portal

Because both projects share databases and some connection names are legacy or misleading, the team must use one agreed configuration vocabulary.

---

## 2. The core rule: code is shared, secrets are local

The team should treat configuration in two layers:

### Shared layer — committed to git
This layer contains:

- config structure
- key names
- connection string names
- placeholder templates
- documentation
- safe example values only

In this project, that includes files such as:

- [web.config.example](web.config.example)
- [connectionStrings.local.config.example](connectionStrings.local.config.example)
- [appSettings.local.config.example](appSettings.local.config.example)

### Local layer — never committed
This layer contains:

- real database hostnames
- usernames
- passwords
- local ports
- machine-specific debug settings
- machine-specific override files

If a value is specific to one machine, one contributor, one server, or one environment, it must stay local.

---

## 3. Canonical variable dictionary for the whole workspace

To avoid contradiction, both projects should use the same logical variable names when documenting or generating local config.

### Shared database variables

| Variable | Meaning | Example |
|---|---|---|
| `CD_DB_HOST` | MySQL host for main/admin databases | `127.0.0.1` |
| `CD_DB_PORT` | MySQL port | `3306` |
| `CD_DB_USER` | MySQL login user | `root` |
| `CD_DB_PASSWORD` | MySQL login password | `localStrongPassword` |
| `CD_DB_MAIN` | Main ERP database | `campus_dynamics` |
| `CD_DB_ADMISSIONS` | Admissions database | `campus_dynamics_admissions` |
| `CD_DB_ACCOUNTS` | Accounts database | `campus_dynamics_accounts` |
| `CD_DB_PORTAL` | Portal database | `campus_dynamics_portal` |
| `CD_DB_ELEARNING` | E-learning database | `campus_dynamics_elearning` |

### Shared application variables

| Variable | Meaning | Example |
|---|---|---|
| `CD_DEBUG` | ASP.NET compilation debug mode | `true` |
| `CD_CUSTOM_ERRORS_MODE` | ASP.NET custom errors mode | `Off` |
| `CD_ENVIRONMENT_NAME` | Current environment label | `local-alice` |

### Why this matters

Even if a project still reads values from `web.config`, the **names above are the source-of-truth vocabulary** for documentation, onboarding, scripts, and review.

That means:

- both projects speak the same naming language
- contributors do not invent their own variable names
- future automation can be added without renaming everything again

---

## 4. Non-negotiable team policy

These rules apply to everyone:

1. **Never commit real credentials.**
2. **Never commit your personal database host or password.**
3. **Never open a PR whose only purpose is changing local connection values.**
4. **Any config shape change must update documentation and example files together.**
5. **Connection string names are stable APIs. Do not rename them casually.**
6. **Local database differences must be handled by local files or local git protections, not by editing shared tracked files.**
7. **If a secret is exposed, rotate it immediately.**

---

## 5. How CampusDynamics should be handled

CampusDynamics already follows the safer pattern more closely than the portal.

### Current position

In this project:

- the real `web.config` is git-ignored
- the committed source of truth is `web.config.example`
- local fragment examples are available for contributor reference
- setup documentation exists in `CONFIGURATION.md`

That means the main project should continue using this rule:

### CampusDynamics rule

- contributors copy `web.config.example` to `web.config`
- contributors fill in their own values locally
- contributors never commit the generated real `web.config`
- all shared config changes happen in example/template files only

### Recommended contributor workflow for CampusDynamics

1. Pull latest changes.
2. Review [web.config.example](web.config.example).
3. Copy it to local `web.config`.
4. Replace placeholders with local values.
5. Run the app.
6. If a new setting is needed, update:
   - `web.config.example`
   - [CONFIGURATION.md](CONFIGURATION.md)
   - this document if the policy changes

### PowerShell example

```powershell
$env:CD_DB_HOST = "127.0.0.1"
$env:CD_DB_PORT = "3306"
$env:CD_DB_USER = "root"
$env:CD_DB_PASSWORD = "your-password"
$env:CD_DB_MAIN = "campus_dynamics"
$env:CD_DB_ADMISSIONS = "campus_dynamics_admissions"
$env:CD_DB_ACCOUNTS = "campus_dynamics_accounts"
$env:CD_DB_PORTAL = "campus_dynamics_portal"
```

Then use those values to populate the local `web.config` copy.

### Example local connection mapping

| Connection string name in CampusDynamics | Should point to |
|---|---|
| `LocalMySqlServer` | `CD_DB_MAIN` |
| `vacConnectionString` | `CD_DB_MAIN` |
| `campus_dynamics_admissionsConnectionString` | `CD_DB_ADMISSIONS` |
| `accountsConnectionString` | `CD_DB_ACCOUNTS` |
| `campus_dynamics_portalConnectionString` | `CD_DB_PORTAL` |

### Stability benefit

Because the real file is already ignored, developers can use totally different:

- MySQL hosts
- usernames
- passwords
- ports
- local database copies

without producing git noise.

---

## 6. How CampusDynamics_Portal should be handled

The portal needs stricter discipline because its `web.config` is currently tracked in git.

That makes accidental config commits much more likely.

### Important reality

Until the portal is fully migrated to local external config fragments, contributors must treat its tracked `web.config` as a **shared baseline file**, not a personal environment file.

### Portal rule

Contributors must **not** use tracked `web.config` as their personal place for database credentials.

Instead, the stable mechanism is:

1. use `web.config.example` as the reference template
2. keep personal values out of commits
3. protect tracked local edits with `skip-worktree`
4. use ignored local files for notes/overrides/templates where possible

### Mandatory protection for contributors

Each contributor working on the portal should run this once in their local clone:

```powershell
git update-index --skip-worktree web.config
```

If the contributor also keeps local transform files, they should protect those too:

```powershell
git update-index --skip-worktree web.Debug.config
git update-index --skip-worktree web.Release.config
```

### When a contributor actually needs to change tracked config structure

Temporarily unprotect the file:

```powershell
git update-index --no-skip-worktree web.config
```

Make only the shared structural change, then recommit and re-protect locally:

```powershell
git update-index --skip-worktree web.config
```

### Why `skip-worktree` is important here

Because the portal currently tracks `web.config`, local DB edits can easily appear in `git status` and get pushed by mistake.

`skip-worktree` reduces that risk for every contributor without requiring an immediate runtime refactor.

### Portal connection mapping

The portal has some legacy connection names that can be confusing.

| Connection string name in Portal | Actually points to |
|---|---|
| `LocalMySqlServer` | `CD_DB_PORTAL` |
| `vacConnectionString` | `CD_DB_PORTAL` |
| `schoolMISConnectionString` | `CD_DB_PORTAL` |
| `hoteldynamicsConnectionString` | `CD_DB_PORTAL` |
| `SecurityConnectionString` | `CD_DB_PORTAL` |
| `campus_dynamics_portalConnectionString` | `CD_DB_MAIN` |
| `campus_dynamics_elearningConnectionString` | `CD_DB_ELEARNING` |
| `campus_dynamics_accountsConnectionString` | `CD_DB_ACCOUNTS` |

### Critical note on naming

The name `campus_dynamics_portalConnectionString` in the portal project is legacy and misleading because it currently targets the **main** `campus_dynamics` database in some environments.

Contributors must not assume the connection string name equals the database name. They should verify the intended target database before changing anything.

### Stability benefit

This prevents one contributor from overwriting another contributor's DB host, password, or local topology when pushing code.

---

## 7. Recommended stable mechanism for both projects

The long-term stable mechanism for this workspace is:

### A. Shared committed templates
Keep these committed:

- `web.config.example`
- any `*.example` transform or local config template
- docs that define key names and rules

### B. Local untracked runtime values
Keep these local only:

- real `web.config` where the file is ignored
- local override files
- local scripts with secrets
- machine-specific secrets files

### C. Git protection for tracked config files
Where a config file is still tracked, use:

```powershell
git update-index --skip-worktree <file>
```

### D. One source of truth for naming
All scripts and documentation should use the canonical `CD_*` names from this document.

### E. Shared shape, local values
When a new setting is introduced:

- add the key to templates with placeholders
- document it
- do not commit real values

That is the most important anti-conflict rule.

---

## 8. Example contributor setups

### Developer A

```text
CD_DB_HOST=127.0.0.1
CD_DB_PORT=3306
CD_DB_USER=root
CD_DB_PASSWORD=alicepass
CD_DB_MAIN=campus_dynamics_alice
CD_DB_PORTAL=campus_dynamics_portal_alice
CD_DB_ACCOUNTS=campus_dynamics_accounts_alice
CD_DB_ADMISSIONS=campus_dynamics_admissions_alice
CD_DB_ELEARNING=campus_dynamics_elearning_alice
```

### Developer B

```text
CD_DB_HOST=192.168.1.20
CD_DB_PORT=3307
CD_DB_USER=campusdev
CD_DB_PASSWORD=bobpass
CD_DB_MAIN=campus_dynamics_bob
CD_DB_PORTAL=campus_dynamics_portal_bob
CD_DB_ACCOUNTS=campus_dynamics_accounts_bob
CD_DB_ADMISSIONS=campus_dynamics_admissions_bob
CD_DB_ELEARNING=campus_dynamics_elearning_bob
```

Both developers can work safely as long as:

- their values stay local
- shared templates remain generic
- no one commits personal connection details

---

## 9. Pull request rules for contributors

A pull request that touches configuration is valid only if it follows all of these:

### Allowed in PRs

- adding a new connection string name
- adding a new app setting key
- changing placeholder structure
- improving example files
- improving documentation
- changing transform logic with safe placeholder values

### Not allowed in PRs

- replacing placeholders with real passwords
- changing hostnames to a contributor's machine
- changing tracked config just to make one developer's machine work
- committing local-only debug behavior without explanation
- changing database names to personal copies in shared files

### Required PR note when config changes

Any PR that changes config shape should state:

1. what key was added or changed
2. which project is affected
3. whether both projects need the same key
4. whether templates/docs were updated
5. whether existing environments need manual action

---

## 10. Contributor checklist before pushing

Before pushing, every contributor should verify:

- `git status` does not show personal config files
- no passwords are present in staged diffs
- no local DB hostnames are staged
- templates still contain placeholders, not secrets
- portal `web.config` is protected with `skip-worktree` if used locally
- any new config key is documented

A useful check is:

```powershell
git diff --staged
```

If the diff contains:

- `password=`
- `server=`
- personal IP addresses
- local machine names

stop and review before pushing.

---

## 11. Conflict prevention when contributors push code

To minimize config conflicts specifically:

### Rule 1: Never use shared files as personal environment storage
This is the biggest cause of conflict.

### Rule 2: Add config keys once, fill values locally
A contributor may add a new key with a placeholder, but each developer fills the value locally.

### Rule 3: Do not rename connection string names unless absolutely necessary
Those names are consumed by:

- `ConfigurationManager`
- TableAdapters
- membership providers
- legacy code paths
- external deployment assumptions

### Rule 4: Keep both projects aligned when shared infrastructure changes
If a DB host, driver option, or policy changes for one project, check whether the other project depends on the same database family.

### Rule 5: Prefer additive changes over destructive ones
Add a new safe placeholder first. Remove old keys only after both projects are updated and tested.

---

## 12. Handling database-specific differences safely

Different contributors may have different:

- DB host
- DB port
- DB credentials
- database names
- partially restored schemas

That is acceptable.

What must remain stable is:

- connection string **names** used by the applications
- documented variable names
- template structure
- shared expectations of what each connection string is for

This is how contributors can have different databases without breaking the codebase.

---

## 13. Suggested migration path for the portal

The safest future improvement for the portal is:

1. move secrets out of tracked `web.config`
2. keep only safe placeholders or external references in tracked files
3. use ignored local config fragments for real values
4. keep `web.config.example` as the onboarding template

Until that migration is fully implemented, `skip-worktree` is the minimum required safety net.

---

## 14. Final team standard

The workspace standard should be read as:

> Shared repository files define configuration shape.
> Local machines define real values.
> Contributors never push personal environment values.
> CampusDynamics uses ignored real config files.
> CampusDynamics_Portal uses a tracked baseline plus local protection with `skip-worktree` until a full externalized config migration is completed.

That standard is the safest way to avoid contradiction, accidental breakage, and contributor-to-contributor config conflicts.
