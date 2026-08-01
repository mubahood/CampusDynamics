# ID Card Management API — Complete Plan

**Goal:** turn `API/v2/idcard.aspx` into a complete, secure management API giving 100% control over the entire ID-card lifecycle — rich filters, pagination, sorting, single + batch operations, windows management, and requester self-service — all flowing through the one audited `IDCardService` state machine (no bypass), and consistent with the existing v2 API conventions (`ApiHelper` + `TokenManager`).

Status: **BUILT & verified 2026-07-16.** Decisions in §12 locked; all phases (§13) complete. See memory [[idcard-management-api]].

---

## 1. Current state

**Endpoint** `API/v2/idcard.aspx` (v2, token-auth, action-routed) currently supports:
- Read: `queue`, `detail`, `windows`
- Write: `approve`, `halt`, `printed`, `ready`, `collected`

**Engine** `App_Code/IDCard/IDCardService(.Business).cs` (copied in both apps) exposes: `IdentityJson`, `FinanceJson`, `CreateJson`, `SubmitJson`, `ActionJson`, `ListJson`, `DetailJson`, `MyRequestJson`, `StatsJson`, `WindowsJson`, `CreateWindowJson`, `SetWindowActiveJson`, plus the core `CreateRequest` / `Transition` funnel.

## 2. Gaps (why this needs work)

1. **Security (must fix):** endpoint uses `RequireAuth` (any valid token) then hardcodes actor=XAXU/role=xaxu. A **student token can approve/print/ready any card**. No role separation.
2. **Missing lifecycle coverage:** no `stats`, `cancel`, `submit`, `create`, no windows CRUD (create/activate/close), no `finance`/`identity`/`my` lookups over the API.
3. **No batch operations** over the API (only the eadmin UI has a controller-only loop).
4. **Weak pagination:** `page` only, fixed size 100, no `page_size`, no `sort`/`order`, thin metadata (no `has_next`/`from`/`to`).
5. **Thin filters:** `status`/`type`/`card_type`/`q` only. No multi-status (`IN`), date range, window, or finance-state filters.
6. **Envelope inconsistency:** most v2 endpoints use `ApiHelper.Success(data,…)`; idcard writes raw service JSON.
7. **No meta/config endpoint** (statuses, legal transitions, action→status map) for driving generic UIs.
8. **No idempotency semantics or per-item batch results** documented.

## 3. Design principles

- **One funnel:** every write goes through `IDCardService.Transition` — same validation, optimistic guard, audit events. API never touches tables directly for lifecycle.
- **Server-authoritative:** transitions, finance gate, window gate all decided server-side.
- **Role-based authZ:** operators/admin manage; requesters only touch their own record.
- **Backward compatible:** keep existing action names + behaviour; add new actions.
- **Consistent with v2:** `ApiHelper` envelope, error codes, CORS, rate-limit; `TokenManager` auth.
- **Both service copies stay identical** (main app + portal).

## 4. Authorization model

`TokenInfo` has `UserType` (today: `student`, `staff`). Introduce an operator identity for ops/integration:

- **New token UserType `idcard_operator`** (XAXU + Registry ID desk). Minimal, additive.
- Optional `admin` type (or reuse an existing staff+role check) for windows management.

**Authorization matrix**

| Capability | student | staff | idcard_operator | admin |
|---|---|---|---|---|
| `my`, `identity`, `finance` (own) | ✔ own | ✔ own | — | — |
| `create`, `submit`, `cancel` (own) | ✔ own | ✔ own | — | — |
| `queue`, `detail`, `stats`, `windows`, `meta` | — | (decision §12.3) | ✔ | ✔ |
| single ops `approve/halt/printed/ready/collected/cancel` | — | — | ✔ | ✔ |
| `batch` | — | — | ✔ | ✔ |
| windows `create/activate/close` | — | — | (decision) | ✔ |

Enforced with `RequireAuth` + explicit `UserType` checks returning `FORBIDDEN`. Actor recorded from the token (`UserId`/`FullName`), not hardcoded.

## 5. Endpoint catalog (all under `API/v2/idcard.aspx?action=…`)

**A. Read / reporting (operator/admin)**
- `queue` — list with filters + pagination + sort (see §6, §7)
- `detail` — full request + identity + finance snapshot + timeline
- `stats` — funnel counts; optional `date_from`/`date_to`, breakdown by type/card
- `windows` — list request windows
- `meta` — statuses, legal transition map, action→status map, filter enums (drives generic UIs)
- `export` — CSV of the current filter set (decision §12.4)

**B. Single lifecycle ops (operator/admin)** — `POST`, `request_no` + params
- `approve`, `halt` (`reason` required), `printed`, `ready` (`collection_point`), `collected`, `cancel`

**C. Batch ops (operator/admin)** — `POST`
- `batch` — `request_nos` (CSV or JSON array) + `action` + shared `reason`/`collection_point` → per-item results

**D. Windows management (admin)** — `POST`
- `window_create` (title, scope, opens_at, closes_at, notes), `window_activate` (id), `window_close` (id)

**E. Requester self-service (student/staff, own record)** — bound to token identity
- `my` (GET), `identity` (GET), `finance` (GET), `create` (POST), `submit` (POST), `cancel` (POST)

## 6. Pagination spec

Request: `page` (1-based, default 1), `page_size` (default 50, max 200), `sort` (`created_at|submitted_at|updated_at|status|request_no`, default `created_at`), `order` (`asc|desc`, default `desc`).

Response meta:
```
"page":2,"page_size":50,"total":312,"pages":7,"has_prev":true,"has_next":true,"from":51,"to":100
```

## 7. Filter spec

`status` (single or CSV → `IN`), `type` (STUDENT|STAFF), `card_type` (NEW|REPLACEMENT), `q` (request_no / student-no / name), `date_from`/`date_to` (on `created_at`), `window_id`, `finance` (`ok|below|flagged`), `has_replacement_fee` (0|1). All optional and composable.

## 8. Batch spec

Input: `request_nos` (CSV or JSON array, cap 500), `action` (forward transition or cancel), shared `reason`/`collection_point`. Idempotent: an item already in the target state → success no-op. Each item independently through `Transition`; partial success allowed.

Output:
```
{"success":true,"data":{"ok":8,"fail":2,"total":10,
 "results":[{"request_no":"IDR-2026-000123","ok":true,"status":"APPROVED","message":""},
            {"request_no":"IDR-2026-000124","ok":false,"status":"HALTED","message":"Illegal transition HALTED→APPROVED"}]}}
```

## 9. Envelope & error codes

Standard v2 envelope `{success, data, message, error_code}` (decision §12.2 on wrapping list/detail `data`). Error codes: `MISSING_PARAM`, `INVALID_ACTION`, `FORBIDDEN`, `NOT_FOUND`, `INVALID_TRANSITION`, `WINDOW_CLOSED`, `FINANCE_BLOCKED`, `BATCH_TOO_LARGE`, `RATE_LIMITED`, `SERVER_ERROR`.

## 10. Service changes required (`App_Code/IDCard/` — BOTH copies, kept identical)

1. `ListJsonEx(filter, page, size, sort, order)` — new overload backing rich filters + sort + full pagination meta. Keep old `ListJson` delegating to it (compat).
2. `BatchActionJson(requestNos, action, reason, collectionPoint, actor, role, channel)` — service-level batch (shared by API + eadmin UI; replaces the controller-only loop just added).
3. `StatsJson(dateFrom, dateTo)` overload + optional type/card breakdown.
4. `MetaJson()` — statuses, `Allowed` transition map, action→status map, filter enums.
5. `ActionJson`/`Transition` unchanged (already the funnel); actor now passed from token.

## 11. eadmin / eportal alignment

- Repoint the eadmin `IDCardController.BatchAction` WebMethod at the new `IDCardService.BatchActionJson` (dedupe logic; one implementation).
- eadmin queue UI already GET-filtered; optionally surface the new filters (date range, multi-status) later.
- eportal wizard unaffected (self-service already uses the same service).

## 12. Decisions — LOCKED (2026-07-16)

1. **AuthZ:** ✔ New `idcard_operator` token type. **Issuance:** in `auth.aspx`, a staff account is minted as `idcard_operator` (instead of `staff`) when its username is in app-setting `IDCard.OperatorUsers` (CSV) **or** it holds the `idcard_operator` RBAC permission slug; the XAXU integration account is an `idcard_operator`. Guard `RequireOperator(auth)` passes for `idcard_operator` (and `admin`). Windows management additionally allowed to `admin` (app-setting `IDCard.AdminUsers` / admin role); operators may also manage windows unless restricted.
2. **Envelope:** ✔ Consistent with existing v2 — every response goes through `ApiHelper.Success(data,…)` / `ApiHelper.Error(…)`. The API layer deserialises the service JSON, drops the inner `success`/`message`, and re-emits the payload under `data` (e.g. `data:{rows,total,page,pages,page_size,has_next,from,to}`).
3. **Read access:** ✔ Broad. `queue`/`detail`/`stats`/`windows`/`meta` are readable by any authenticated **staff / idcard_operator / admin** token. **Student/applicant tokens are limited to their own record** (`my`, and `detail` only for the request they own) — the global queue is never exposed to a student (PII protection). *If you want students to read the whole queue too, say so and I'll widen it.*
4. **Export + batch:** ✔ Build `export` (CSV) in this pass. Batch cap = **500** request numbers per call (`BATCH_TOO_LARGE` beyond that).

## 13. Build phases

- **P1 — Service:** `ListJsonEx`, `BatchActionJson`, `StatsJson(range)`, `MetaJson` in both copies; verify via SQL.
- **P2 — API:** rebuild `API/v2/idcard.aspx.cs` with the full action catalog, auth matrix, envelope, pagination/filters/batch.
- **P3 — Integrate + document:** repoint eadmin batch to the service; update `API/v2/API_DOCUMENTATION.md` with the full ID-card management section; end-to-end verification (lifecycle, authZ, pagination, filters, batch).
