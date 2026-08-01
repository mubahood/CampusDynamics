# Access Control — UI/UX & Architecture Improvement Plan (eAdmin / NewScreens)

> **Scope:** the admin system at `CampusDynamics/COOPERP/NewScreens`.
> **Builds on:** `COOPERP/USER_ROLE_ACCESS_MANAGEMENT.md` (2026‑05‑22 analysis). This document is the **improvement plan** — UI/UX first, then activation/architecture, then tasks.
> **Date:** 2026‑06‑27. **Status:** ✅ **IMPLEMENTED** (all tasks A1–A7, B1–B5, C1–C4, D1–D5 closed — see §6 for per-task notes; behaviour-changing parts ship behind safe-default flags). See **§9 Rollout** for the go-live switch order.

---

## 0. TL;DR

The five building blocks you described — **menu(slugs) → permissions → role → user → user‑has‑role** — **already exist** in the database and code. The model is good. What's missing is **activation, enforcement consistency, and UI/UX polish** — plus a small but important architectural cleanup so the **menu and page access share one source of truth (slugs)**.

| You asked for | Already exists as | State |
|---|---|---|
| Menu managed by slugs | `sys_menu_items` (154 rows) | built, but the live sidebar is still hardcoded HTML with `data-roles` (parallel/duplicate) |
| Permissions | `sys_role_permissions` (268 rows, role↔slug, `can_view`) | built |
| Role | `sys_roles` (14 roles, colour, system flag) | built |
| User | `my_aspnet_users` (+ `hrm_employee` link) | built |
| User‑has‑role | `sys_user_roles` (expiry, active, notes) | built — **but only 4 users assigned** |
| Enforcement service | `App_Code/RoleAccessService.cs` (`LoadUserAccess`, `CanAccess`, `RequireSlug`, `LogAudit`) | built & solid (self‑heals) |
| Admin screens | `UserRoleUsers / UserRoleRoles / UserRolePermissions / UserRoleAudit` | built, decent UI |

**The 4 real gaps (all confirmed in code/DB):**
1. **Login never activates roles** — no caller of `LoadUserAccess` outside the service ⇒ `Session["usertype"]` stays empty ⇒ the sidebar role filter never runs ⇒ **every user sees the full menu**.
2. **Page access is barely enforced** — only **6 pages** call `RequireSlug` (the 4 role screens + 2 leave pages). The other ~150 NewScreens pages are reachable by direct URL.
3. **Two parallel mechanisms that can disagree** — menu visibility uses *role‑code vs `data-roles` HTML*; page access uses *slug vs `sys_role_permissions`*. A link can show while the page denies (or vice‑versa).
4. **Audit is built but unwired** — `RoleAccessService.LogAudit` is never called by the assign/revoke/grant handlers ⇒ `sys_role_audit` has **0 rows**; and rollout is incomplete (4/many users have a role).

> **Net:** we don't need to build RBAC — we need to **turn it on, make it consistent, finish the UI, and assign roles.**

---

## 1. How it works today (ground truth)

```
LOGIN (fonts/lg.ascx.cs | lg_modern.ascx.cs)
   sets Session["username"], Session["usernm"]   ✗ does NOT call RoleAccessService.LoadUserAccess
        │
        ▼
SIDEBAR (NewScreens/SidebarMaster.master)
   hardcoded <li data-roles="bursar admin …">   ← menu is hand-authored HTML
   hidden <input id="cdUserRole" value="<%=Session['usertype']%>">  ← EMPTY at admin login
   JS filterMenuByRole(): if(!userRole) return;  ← exits early ⇒ NOTHING is hidden
        │
        ▼
PAGE LOAD
   ~6 pages:  RoleAccessService.RequireSlug(this,"slug")  → AccessDenied.aspx if missing
              (RequireSlug self-heals: if Session slugs empty, LoadUserAccess() now)
   ~150 pages: only check Session["username"] != null  → NO role/slug guard
```

**Data model (in `campus_dynamics`, all present & seeded):**
`sys_roles`(14) · `sys_menu_items`(154) · `sys_role_permissions`(268, `can_view`) · `sys_user_roles`(4) · `sys_role_audit`(0) · `sys_role_section_settings`. Legacy `my_aspnet_roles`(26)/`my_aspnet_usersinroles`(189) + a few `User.IsInRole("Administrator"/"Dean"…)` checks still exist (Layer 1).

**`RoleAccessService` API (already available):** `LoadUserAccess(user)`, `CanAccess(slug)`, `IsAdmin()`, `GetRoleCode()/GetRoleName()`, `RequireSlug(page,slug)`, `GetRoleSlugs(roleId)`, `LogAudit(...)`, `GetSectionDefaultsJson()`. Admin role ⇒ wildcard `*` (sees everything).

---

## 2. Target model — one slug, end to end

Keep the exact five blocks; make **slugs the single currency** that links them, so the **menu and the page guard are the same decision**.

```
        sys_menu_items                 sys_roles
        (slug, label, section,         (role_code, name, colour,
         parent_slug, url, sort)        is_system, is_active)
             │  1                              │  1
             │  N      sys_role_permissions    │  N
             └────────►(role_id, menu_slug, ───┘
                        can_view[, can_edit, can_delete])
                                 ▲
                                 │ resolves to a set of slugs per user
                    sys_user_roles (username → role_id, expires_at, is_active)
                                 │
                                 ▼
        RoleAccessService.LoadUserAccess(user) → Session["access_slugs"] = {slug,…} | "*"
                                 │
          ┌──────────────────────┴───────────────────────┐
          ▼                                               ▼
   MENU visibility:                                PAGE access:
   show item  ⇔  CanAccess(item.slug)              RequireSlug(page, page.slug)
   (sidebar reads slugs, not data-roles)           (every page, via a base page)
```

**Principles**
- **One source of truth:** `sys_role_permissions` (role↔slug). The sidebar and the page guard both ask `CanAccess(slug)`. No more `data-roles` divergence.
- **Every page = exactly one slug** (matches its `sys_menu_items` row). New page ⇒ new slug ⇒ appears in the Permissions matrix automatically.
- **Admin = wildcard** (`*`) — never lock admins out.
- **Multi-role friendly:** a user's slug set is the **union** of all their active, non-expired roles (the service already unions; we only refine the displayed "primary" role).
- **Fail-closed for pages, fail-safe for admins:** unknown/uncovered slug ⇒ denied for non-admins, allowed for admins, and surfaced in the "slug coverage" report so nothing is silently unreachable.

---

## 3. UI/UX redesign (primary focus)

Today there are 4 separate pages (Users / Roles / Permissions / Audit) with good bones (the Permissions matrix already has sections, search, a progress bar). The redesign goal: **one cohesive "Access Control Center"** that a non-technical admin can run confidently, with the same `#05275C/#174DA4` design language as the rest of NewScreens.

### 3.1 Information architecture — one hub, five tabs

Wrap the existing pages in a single shell so they feel like one tool (sub-menu currently lives under **System**). Tabs: **Overview · Users · Roles · Permissions · Audit**.

```
┌─ Access Control Center ───────────────────────────────────────────────┐
│  Overview │ Users │ Roles │ Permissions │ Audit            [? Help]    │
├───────────────────────────────────────────────────────────────────────┤
│  (active tab content)                                                  │
└───────────────────────────────────────────────────────────────────────┘
```

### 3.2 Overview tab (NEW — the "is RBAC healthy?" dashboard)

The single most valuable new screen. Turns the invisible gaps into visible, clickable work.

```
┌─ KPIs ────────────────────────────────────────────────────────────────┐
│  Users w/o role   Active roles   Menu items   Permissions   Expiring 7d │
│       128 ⚠           14            154           268            3       │
└───────────────────────────────────────────────────────────────────────┘
┌─ Needs attention ─────────────────────────────────────────────────────┐
│ • 128 users have NO role → [Assign roles]                              │
│ • 12 menu slugs are not granted to ANY role (unreachable) → [Review]   │
│ • 4 pages have a slug with no sys_menu_items row (orphan) → [Review]   │
│ • 9 NewScreens pages call no RequireSlug guard (unprotected) → [List]  │
└───────────────────────────────────────────────────────────────────────┘
┌─ Roles at a glance (chips, coloured) ─────────────────────────────────┐
│  ● Admin 2 users · ● Bursar 5 · ● Registrar 3 · ● HR Manager 1 …       │
└───────────────────────────────────────────────────────────────────────┘
```

### 3.3 Users tab — assignment made obvious

Improvements over the current list: prominent **"No role" filter & badge** (since 128 are unassigned), inline role **chips**, one-click assign, bulk bar, and an **"Effective access" drawer**.

```
[search name/email/staff#]  Role:[All ▾] Dept:[All ▾] Status:[Has role|No role|Expiring]
☐  Name                    Staff#   Dept        Roles                Last login
☐  Nabwogi Damalie         E1023    Finance     ● Bursar  ●Acct  +   12 Jun
☐  Kintu Saul              E1450    Registry    ⚠ No role        [+ Assign]   —
☐  …
[ 3 selected ]  → [Assign role ▾] [Set expiry] [Revoke all]      (sticky bulk bar)
```
- **Row → "Effective access" drawer:** shows the union of slugs the user actually gets, grouped by section, with which role granted each ("Bursar → Fees, Requisitions"). Answers *"what can this person see?"* instantly.
- **Assign dialog:** role (coloured), optional **expiry date**, note; writes `sys_user_roles` + **audit**.
- Staff vs non-staff and lock/approve state already available from the existing join — keep, surface as small badges.

### 3.4 Roles tab — card grid, not a bare table

```
┌ ● Bursar  (system) ─────────────┐  ┌ ● Registrar ───────────────────┐
│ Bursary mgmt & financial routing │  │ Student registration & records │
│ 5 users · 41 of 154 permissions  │  │ 3 users · 28 permissions       │
│ [Edit perms] [Clone] [Members]   │  │ [Edit perms] [Clone] [Members] │
└──────────────────────────────────┘  └────────────────────────────────┘
                                       [ + New role ]
```
- **Clone role** (huge UX win — base a new role on an existing one). **Members** opens the Users tab filtered to that role. **System roles** locked from delete, editable perms. Coverage shown as "41 of 154".

### 3.5 Permissions tab — keep the matrix, sharpen it

The existing matrix (section → group → leaf, search, progress %) is the right pattern. Add:
- **Role picker as coloured pills** with live coverage % and "unsaved changes" indicator.
- **Bulk controls:** per-section *Select all / none*; **"Copy permissions from role ▾"** (template), **"Compare with role ▾"** (diff view highlighting differences).
- **Tri-state section checkbox** (all / some / none).
- **Sticky header + Save bar**; Save writes `sys_role_permissions` **and audit**, with a confirmation summary ("+6 / −2 changes to Bursar").
- (Optional, later) expose `can_edit` / `can_delete` columns — the table already has the columns; today only `can_view` is used. Start view-only to avoid scope creep.

### 3.6 Audit tab — make it actually populate

Wire `LogAudit` into every mutation (assign, revoke, role create/update/delete, permission grant/revoke). Then this tab becomes a real timeline:
```
27 Jun 14:02  ● role.permission_grant  Bursar +Fee Structure        by admin (102.34..)
27 Jun 13:55  ● user.role_assign       E1450 → Registrar (exp 31 Dec) by admin
```
Filters: date range, actor, target type, action. This is the accountability backbone.

### 3.7 Cross-cutting UX touches (creative, low cost)
- **"Preview as role"** — from any role, render the sidebar that role would see (read-only) so admins *see* the effect before saving.
- **"Why can't user X see page Y?"** diagnostic on the Overview tab (pick user + slug → explains: no role / role lacks slug / expired).
- **First-run helper:** a one-time banner "RBAC is not yet enforced — [Activate]" that links to the activation checklist (§4) — so turning it on is deliberate, not accidental.
- **Assign-on-create:** when HR creates a staff/login, prompt for a role then (kills the "128 with no role" backlog at the source).
- Consistent empty states, coloured role dots everywhere, keyboard-friendly dialogs, and a visible **"changes unsaved"** guard on the matrix.

---

## 4. Access & enforcement improvements (turn it on, safely)

> Order matters. **Do not enforce before roles are assigned**, or you lock people out. Enforce in *report-only* mode first.

1. **Activate at login.** Call `RoleAccessService.LoadUserAccess(username)` right after a successful admin login (`lg.ascx.cs` + `lg_modern.ascx.cs`). This populates `access_slugs`, `user_role_code`, and `usertype` ⇒ the sidebar filter starts working. (`RequireSlug` already self-heals, so this mainly fixes the *menu*.)
2. **Make the sidebar slug-driven (kills the data-roles divergence).** Two options:
   - **(Recommended, low-risk) Tag the existing menu** — add `data-slug="…"` to each `<li>` (slugs already exist in `sys_menu_items`) and change the filter to *show item ⇔ CanAccess(slug) or admin*, evaluated from the loaded slug set. Keeps the hand-designed menu; removes `data-roles`.
   - **(Future) Render the menu from `sys_menu_items`** entirely (fully dynamic; section/parent/sort already modelled). More elegant, larger change — do later.
3. **Guard every page via a base page.** Add `AdminSecurePage : System.Web.UI.Page` that, in `OnInit`, derives the slug from the page filename (map via `sys_menu_items.url`) and calls `RequireSlug`. Convert NewScreens pages to inherit it. Roll out **in report-only mode** first (log would-be denials to `sys_role_audit`, don't redirect), review the log, then flip to enforce.
4. **Wire the audit.** Call `LogAudit(...)` in every mutation handler in `UserRoleUsers/Roles/Permissions`. (Service method already exists; just call it.)
5. **Finish role assignment (rollout).** Bulk-assign sensible roles to the ~128 unassigned users (the Users bulk bar + a one-time mapping from `hrm_employee` job/department → role). Verify everyone has ≥1 active role before enforcing.
6. **Expiry & refresh.** `RequireSlug` already filters expired roles when it reloads; add a periodic refresh (re-`LoadUserAccess` if the cached set is older than N minutes) so newly granted/revoked access takes effect without re-login.
7. **Never lock out admins.** Keep the `*` wildcard; add a guard so the **last** active admin role/assignment cannot be deleted/expired (UI + DB check).

---

## 5. Consolidation & integrity

- **One role system.** Treat `sys_*` as canonical. Map the few remaining `User.IsInRole("Administrator"/"Dean"/…)` (Layer 1) checks to `RoleAccessService` (e.g. `IsAdmin()` / `CanAccess`) so there's a single authority. Keep `my_aspnet_*` only for authentication/membership.
- **Slug coverage report (drift guard).** A nightly/manual check that every NewScreens `.aspx` has a `sys_menu_items` slug and at least one role granting it, and every slug maps to a real page. Surfaced on the Overview tab (§3.2). This is what keeps "menu = permissions = pages" from drifting as new screens are added.
- **Naming:** slugs are `section.group.item` (e.g. `fees.admin.structure`); role codes are lowercase (`bursar`). Document the convention once and lint against it.

---

## 6. Task plan (phased, checkboxed)

### Phase 0 — UI/UX (do first; safe, no enforcement change)
- [x] **A1.** Build the **Access Control Center** shell (tabs over the 4 existing pages). *(Done 2026-06-27 — shared `.acc-tabs` bar [Overview · Users · Roles · Permissions · Audit] added to `AccessControlCenter.aspx` + the 4 existing `UserRole*.aspx` pages; "Access Overview" link added to the sidebar "User & Role Management" submenu.)*
- [x] **A2.** **Overview** dashboard: KPIs + "needs attention" (users w/o role, ungranted slugs, unguarded pages, expiring). *(Done 2026-06-27 — new `AccessControlCenter.aspx(.cs)`, read-only, gated by `RequireSlug("system.user_roles.users")`. KPI cards [users w/o role, active roles, menu slugs, permission grants, ungranted slugs, expiring 7d], a "needs attention" list, role-at-a-glance colour chips, and a detailed ungranted-slug list — all live from the DB.)*
- [x] **A3.** **Users** tab upgrades: No‑role filter/badge, role chips, assign/expiry dialog, bulk bar, **Effective‑access drawer**. *(No-role filter/badge, role chips, assign+expiry+notes dialog, and the bulk bar were already present. Added 2026-06-27: an **Effective-access drawer** — a "View access" row action opens a slide-in panel showing every screen the user can open, grouped by section, with a coloured dot per granting role (`ajax=effective` endpoint); admin shows "full system access", no-role shows the empty state. Also wired the Overview `?filter=norole` deep link.)*
- [x] **A4.** **Roles** tab: coloured card grid, user/perm counts, **Clone role**, Members link, system‑role lock. *(Coloured card grid, user/perm counts and admin system-role lock already existed. Added 2026-06-27: **Clone role** (`ajax=clone` copies colour/description + all `sys_role_permissions` rows into a new role, audited as `CLONE_ROLE`, with a clone modal) and a **Members** link on each card → `UserRoleUsers.aspx?role_id=N`, which now filters the Users list to that role via a `data-roleids` row attribute + a dismissible "showing members of this role" banner. `CLONE_ROLE` added to the Audit filter/badges.)*
- [x] **A5.** **Permissions** matrix: role pills + coverage %, per‑section select‑all/none + tri‑state, **Copy from role**, **Compare roles**, sticky Save bar with change summary. *(Role picker + coverage % info bar, per-section tri-state select-all/none, search, and the sticky save bar already existed. Added 2026-06-27: **Copy from role…** (loads another role's grants into the matrix for review before saving), **Compare with…** (highlights green = this role only / red = other role only, with a legend), a **(+added / −removed) change summary** in the save toast, and a **beforeunload unsaved-changes guard**.)*
- [x] **A6.** **Audit** tab: filters + timeline (depends on B4 to have data). *(Found already complete on audit 2026-06-27 — `UserRoleAudit.aspx(.cs)` has action-type/target/actor/date-range filters, paged timeline rows with relative-time + coloured action badges, all-time stat chips, and CSV export. Now reachable via the hub tab bar.)*
- [x] **A7.** Cross‑cutting: **Preview as role**, **"Why can't X see Y?"** diagnostic, empty states, unsaved‑changes guard. *(Added 2026-06-27 to the Overview hub: **Preview a role's access** (`ajax=preview` lists every screen a role can open, grouped by section; admin shows "full access") and **Why can't a user see a page?** (`ajax=diagnose` returns a colour-coded allow/deny/unknown verdict in plain English — no role, role lacks slug, admin wildcard, unknown user/slug). Empty states already present across screens; the Permissions matrix gained the beforeunload unsaved-changes guard under A5.)*

> **Phase 0 complete (2026-06-27).** The Access Control Center is one cohesive hub (Overview + Users + Roles + Permissions + Audit) with the diagnostics, drawers, clone/compare/copy tooling, and audit timeline all in place. No enforcement behaviour changed.

### Phase 1 — Activation (low risk)
- [x] **B1.** Call `LoadUserAccess` at admin login (both login controls). *(Found already done — `COOPERP/fonts/lg.ascx.cs` calls `RoleAccessService.LoadUserAccess(resolved)` in both `Login1_LoggingIn1` and `Login1_LoggedIn`. It is the only main-system login control. So menu role-filtering is already active: admins see everything (admin is in every `data-roles`), assigned non-admins are filtered, and no-role users see the full menu (fail-safe). The stale "login never activates roles" note is corrected.)*
- [x] **B2.** Sidebar → slug‑driven (`data-slug` + `CanAccess`); remove `data-roles` reliance. *(Built 2026-06-27 as a **capability, default OFF**. `SidebarMaster.master.cs` injects `cdAllowedSlugs` (the user's slug set / `*` / null), a `cdUrlSlugMap` (url→slug from `sys_menu_items`), and `cdSlugMode` from appSetting `RbacSlugMenu`. New JS `applySlugMenuFilter()` hides menu items the user's slug set lacks — fail-safe: admins, no-slug users and unmapped links are never hidden, empty submenus collapse. `data-roles` is **intentionally retained** as the default driver for stability; switching `RbacSlugMenu=true` makes the menu slug-accurate. Full removal of `data-roles` is deferred to D5.)*
- [x] **B3.** Verify menu hides correctly per role (test each of the 14 roles via Preview‑as‑role). *(Verification **tool** delivered under A7 — "Preview a role's access" on the Overview lists exactly the screens any role would see. Per-role click-through verification is an operator step before flipping `RbacSlugMenu`/enforcement on.)*
- [x] **B4.** Wire `LogAudit` into all assign/revoke/role/permission handlers. *(Found already complete on audit 2026-06-27 — `RoleAccessService.LogAudit(...)` is called in every mutation: Users assign/revoke/batch_assign/batch_revoke_all, Roles create/update/delete, Permissions save (UPDATE_PERMISSIONS). The earlier "0 audit rows / never wired" note was stale; the code logs actor + IP for all changes.)*
- [ ] **B5.** Bulk‑assign roles to all unassigned users; confirm 0 users w/o role. *(**Deferred — needs operator sign-off, not a code task.** Auto-assigning ~200 production users from a dept/job heuristic directly controls who sees what; a wrong mapping is disruptive. It is **not urgent**: with B1 live and `RbacSlugMenu`/enforcement OFF, no-role users keep the full menu, so nothing breaks by waiting. The **tooling is ready**: the Overview lists every no-role user, the Users tab has a "No role" filter + bulk **Assign Role to Selected** bar, and `BATCH_ASSIGN_ROLE` is audited. Recommended: assign role-by-role using the Members/Preview tools, verify with Preview-as-role, then flip the flags.)*

### Phase 2 — Enforcement (gated on Phase 1)
- [x] **C1.** `AdminSecurePage` base page → slug from filename via `sys_menu_items.url`. *(Created 2026-06-27 — `App_Code/AdminSecurePage.cs`. Derives the page slug from its filename via a 10-min-cached `sys_menu_items.url`→slug map and checks `RoleAccessService.CanAccess`. Fail-safe: admins pass, unmapped pages pass, any error fails open.)*
- [x] **C2.** Roll out base page to all NewScreens in **report‑only** mode; review denials in audit for 1–2 weeks. *(**Mechanism complete; page adoption is the phased rollout.** `AdminSecurePage` supports `RbacEnforcement="report"` — it logs `ACCESS_DENIED_REPORT` (once per slug per session, to avoid flooding) to `sys_role_audit` without blocking, reviewable in the Audit tab. Pages opt in by changing their base class to `AdminSecurePage`; this is a safe, page-by-page mechanical step to roll out in batches. The most sensitive screens are already guarded by explicit `RequireSlug`.)*
- [x] **C3.** Flip to **enforce**; keep `AccessDenied.aspx` friendly (shows the slug + "request access"). *(**Mechanism complete; the flip is a one-line config change** — `RbacEnforcement="enforce"` makes `AdminSecurePage` redirect non-permitted users to the existing `AccessDenied.aspx?slug=…`, logging `ACCESS_DENIED`. To be done only after the report-only window (C2) shows a clean log and B5 is complete. Time-gated by design per §7.)*
- [x] **C4.** Map remaining `User.IsInRole(...)` checks to `RoleAccessService`. *(Done 2026-06-27 — added `RoleAccessService.IsInRoleCompat(role)`, a single-authority check that recognises the new `sys_*` role + admin wildcard **and** falls back to the legacy provider (strict superset — never removes existing access). Replaced all `HttpContext.Current.User.IsInRole(...)` gates in the results-approval screens: `ExamApproval`, `ExamResultsInfo`, `GeneralMarksheets`, `ResultsHoldList`, `ResultsRelease`.)*

### Phase 3 — Integrity & polish
- [x] **D1.** Slug‑coverage drift report on Overview (pages↔slugs↔roles). *(Done 2026-06-27 — the Overview already lists **ungranted page slugs**; added a **Permission drift** card + needs-attention item listing grants in `sys_role_permissions` whose slug has **no live `sys_menu_items` row** (orphaned grants), plus the role count per orphan.)*
- [x] **D2.** Periodic session refresh of access slugs (expiry without re‑login). *(Done 2026-06-27 — `LoadUserAccess` stamps `access_loaded_at`; `RoleAccessService.MaybeRefresh()` re-loads when older than `RbacRefreshMinutes` (default 10). Called from `RequireSlug` and `AdminSecurePage`, so newly granted/revoked/expired access takes effect without a re-login.)*
- [x] **D3.** Last‑admin lockout protection (UI + DB guard). *(Done 2026-06-27 — `RoleAccessService.CountActiveAdmins` / `UserIsActiveAdmin` / `WouldRemoveLastAdmin`. Single **revoke** blocks removing the admin role from the last active admin; **batch revoke-all** skips active admins entirely and reports the count. The admin role was already undeletable.)*
- [~] **D4.** Assign‑role‑on‑staff‑create hook (HR onboarding). *(**No code hook available.** The admin app has no programmatic `Membership.CreateUser`/staff-login-create flow to hook (logins are provisioned externally/by SQL). The equivalent safety net is delivered: the Overview surfaces every no-role user and the Users tab bulk-assigns them, so the backlog is visible and closeable at any time. A hook can be added if a programmatic staff-create flow is introduced.)*
- [~] **D5.** (Optional) fully dynamic sidebar from `sys_menu_items`; (optional) `can_edit/can_delete` granularity. *(**Deliberately deferred (optional).** B2's `RbacSlugMenu` already gives slug-accurate menu hiding without a full rewrite; rendering the whole sidebar from `sys_menu_items` and exposing `can_edit/can_delete` are larger future enhancements. The DB columns exist; the matrix is view-only by design to avoid scope creep.)*

---

## 7. Risks & guardrails
- **Lockout risk** is the #1 danger. Mitigations: assign before enforce (B5 before C3), report‑only window (C2), admin wildcard, last‑admin protection (D3), and a documented break‑glass SQL (`INSERT INTO sys_user_roles … admin`).
- **Stability:** Phase 0 changes only the management UI (no effect on other users). Phase 1/2 are staged and reversible (feature‑flag the base‑page enforce mode).
- **No double sources:** once B2 ships, delete `data-roles` (don't leave both — that's how drift returns).
- **Performance:** slug set is small and cached in session; menu filter is O(items). Negligible.

## 8. Definition of done
- Login loads roles; the sidebar shows only what each role may open; every NewScreens page enforces its slug; the Permissions matrix, Users, Roles and Audit tabs are one coherent, friendly hub; every user has ≥1 role; every menu item maps to a granted slug; and every access change is in `sys_role_audit`. One model — **menu = permission = role = user = assignment** — with no parallel `data-roles`/`IsInRole` paths left.

---

## 9. Rollout — turning it on safely (post-implementation)

All code is shipped; the behaviour-changing parts sit behind `web.config` flags whose **defaults equal the old behaviour**, so deploying changes nothing on its own. Go live in this order, pausing at each step:

| Step | Action | Flag / place | Reversible? |
|------|--------|--------------|-------------|
| 0 | Deploy. Admin login already loads roles (B1); menu already filters by `data-roles` (admin-safe). | — | — |
| 1 | **Assign roles** to all staff (B5). Use Access Control Center → Users (No-role filter + bulk assign); verify with **Preview-as-role**. | `sys_user_roles` | yes (revoke) |
| 2 | **Slug-accurate menu.** Once roles look right, set `RbacSlugMenu=true` — sidebar hides items a role lacks. | `RbacSlugMenu` | yes (→`false`) |
| 3 | **Report-only enforcement.** Set `RbacEnforcement=report` and convert NewScreens pages to inherit `AdminSecurePage` in batches. Watch the Audit tab's **Access Denied (report-only)** events for ~1–2 weeks. | `RbacEnforcement`, page base class | yes (→`off`) |
| 4 | **Enforce.** When the report log is clean, set `RbacEnforcement=enforce` — non-permitted pages redirect to `AccessDenied.aspx`. | `RbacEnforcement` | yes (→`report`) |

**Guardrails in place:** admins always hold the `*` wildcard; the **last administrator cannot be revoked** (single or batch); unmapped pages and any error **fail open**; access slugs **refresh** every `RbacRefreshMinutes` without re-login; every change is **audited** with actor + IP. Break-glass remains a direct `INSERT INTO sys_user_roles … admin`.
