# Marks Lifecycle — Presentation Brief for HODs & Deans

**Prepared for:** External presentation consultant
**Deliverable requested:** A **7-slide PowerPoint** that demonstrates, to **Heads of Department (HODs) and Deans**, how marks move through the Campus Dynamics EMIS — from a lecturer entering them, to publishing, to how errors and missing marks are corrected.
**Institution:** **Muteesa I Royal University (MRU)** — Campus Dynamics EMIS (Education Management Information System).
**Goal of the deck:** Give academic leaders a clear, confident understanding of the **whole journey** and **their role** in it. Non-technical, visual, authoritative.

> This document has two halves:
> 1. **The knowledge** — exactly how the three processes work in the live system (Sections 1–5). Read this to understand the story.
> 2. **The build kit** — a ready-made 7-slide outline (Section 6) and the **MRU / Campus Dynamics brand guide** (Section 7) so the deck looks on-brand.

---

## 1. The Big Picture — Three Journeys, One Rulebook

Marks in the system live one of two lives:

| State | Where it lives | Who can see it |
|-------|----------------|----------------|
| **Provisional** (being worked on) | The portal registration record (`acad_course_registration`) | Staff only, level-by-level |
| **Published** (final, official) | The results ledger (`acad_results`) — the single source of truth for transcripts & GPA | The student, transcripts, the University |

There are **three journeys** every academic leader should know:

1. **Marks Publishing** — the normal, forward path: a mark is entered, checked, approved, and published. *(Section 2)*
2. **Mark Change** — a published/entered mark is **wrong** and must be corrected. *(Section 3)*
3. **Missing Mark** — a mark that was **never entered** for a student who sat the course. *(Section 4)*

**One golden rule underpins all three:** a student only ever sees a **PUBLISHED** result. Nothing provisional, nothing "in progress", nothing under review reaches the transcript until it has passed every gate.

---

## 2. Journey 1 — Marks Publishing (the staged approval chain)

Publishing is **not** a single click by one person. It is a **level-by-level approval chain**, so that no single individual can push marks to a transcript alone. Each mark carries a **stage** that only ever moves forward one step at a time.

### The 5 stages of a mark

```
   LECTURER            HOD               DEAN            SENATE / REGISTRAR
      │                 │                 │                    │
      ▼                 ▼                 ▼                    ▼
 NOT_ENTERED  ──▶  ENTERED  ──▶  CAPTURED  ──▶  APPROVED  ──▶  PUBLISHED
 (enrolled,      (coursework +   (Dept head    (Faculty       (official —
  no marks yet)   exam both in)   verified)     signed off)    on transcript)
```

| Stage | Set by | What it means |
|-------|--------|---------------|
| **NOT_ENTERED** | System (on enrolment) | Student is registered for the course; no marks yet. |
| **ENTERED** | **Lecturer** (student portal) | Lecturer has entered **both** coursework **and** exam marks. (A mark cannot advance until both halves exist.) |
| **CAPTURED** | **HOD** | The Head of Department has reviewed and captured the department's marks. |
| **APPROVED** | **Dean** | The Dean/Faculty has approved the faculty's marks. *(Internal — students still cannot see them.)* |
| **PUBLISHED** | **Senate / Academic Registrar (Admin)** | Marks are released as **final results** and written to the official ledger. Only now do students see them. |

### How each level does its work

Each of HOD-capture, Dean-approve, and Senate-publish happens through a dedicated **console** (screen) that works the same way at every level — a guided **wizard**:

1. **Choose the batch** — programme, academic year, semester, year of study (or "all"), with optional notes.
2. **Preview** — the system shows a snapshot: how many students, performance statistics, and a breakdown, **before** anything is committed.
3. **Commit** — the marks advance one stage. The action is recorded as a **session** with who did it, when, the parameters, and a frozen snapshot.

**Send-back is built in.** Any level can **return marks one step down** with a reason (e.g. a Dean sends a batch back to the HOD to fix an anomaly). This keeps accountability without emails and spreadsheets.

### Visibility narrows as marks climb

As marks advance, the level below **loses edit-sight** of them — so work can't be changed behind the approver's back:

- Once **CAPTURED**, the **lecturer** no longer sees them as editable.
- Once **APPROVED**, the **HOD** no longer sees them.
- Once **PUBLISHED**, the **Dean** no longer sees them; they are final.

### Everyone can *track* a mark without seeing the score

Students and lecturers have a **Mark Status Check** screen that shows **where** a mark is in the pipeline — *Registered? Coursework in? Exam in? HOD captured? Dean approved? Published?* — as a checklist, **without revealing any mark value**. This kills the "where are my results?" queries while protecting confidentiality.

### Scale (live snapshot, for the demo)

> Roughly **68,500 marks PUBLISHED**, **9,850 ENTERED** (with lecturers/HODs), **48,700 NOT_ENTERED** (current enrolments awaiting marks). These numbers make the point that the pipeline is running at real scale.

---

## 3. Journey 2 — Mark Change (correcting a wrong mark)

Sometimes a mark that was entered — or even already published — is **incorrect**. The system has a controlled **correction workflow** so changes are requested, reviewed, and fully audited — never edited quietly.

### The path

```
 STUDENT ──▶ LECTURER ──▶ (optional SUPERVISOR) ──▶ ADMIN / REGISTRAR ──▶ result corrected
 raises a    the one who      escalation for            final approval        GPA & CGPA
 request     taught it        contested cases                                 recomputed
```

### The states a request moves through

`PENDING_LECTURER → PENDING_SUPERVISOR → PENDING_ADMIN → APPROVED` — or it can be **REJECTED** or **CANCELLED** at any appropriate point.

### What happens on approval

When a Mark Change is **APPROVED**, the system:
- Writes the corrected score/grade to the official results ledger,
- **Recomputes the semester GPA and the cumulative CGPA** automatically, and
- Records who approved it and the exact change (e.g. *"Score 48 → 62, Grade F → B"*).

### Safety net — automatic reversal

If an approved correction is later **reopened or downgraded**, the system **automatically reverses** the published result back to its previous value and re-computes GPA/CGPA — so a transcript can never silently drift out of line with the decision record. Every action is stamped in an audit log.

---

## 4. Journey 3 — Missing Mark (a mark that was never entered)

A student may have sat a course but **no mark exists** for it (e.g. the lecturer never entered it, or a record was lost). This uses the **same request rail** as Mark Change, but the request type is **MISSING_MARK**.

### The path

```
 STUDENT ──▶ picks the LECTURER who taught the course ──▶ LECTURER enters the mark
        ──▶ (optional SUPERVISOR) ──▶ ADMIN approves ──▶ result created + GPA recomputed
```

### What's smart about it

- **The student names the right lecturer.** Because teaching allocations change over the years, the student chooses *"who taught this course"* from a **searchable staff directory** (relevant lecturers surfaced at the top). That routes the request straight to the correct person instead of guessing.
- **Everyone is notified by email** at each hand-off — the lecturer when a request arrives, the student and supervisor when the lecturer acts — so nothing stalls in silence.
- **Admins can view the full detail and re-route** a request to a different lecturer if needed, with every action scope-checked and audited.

### Scale (live snapshot, for the demo)

> The correction system has already handled **500+ approved missing-mark cases** and **hundreds** of change/rejection decisions — evidence that the workflow is proven, not theoretical.

---

## 5. Who Does What — Roles at a Glance

| Role | In Publishing | In Corrections |
|------|---------------|----------------|
| **Student** | Sees only final (published) results; tracks status without values | **Initiates** a Mark Change or Missing Mark; names the lecturer |
| **Lecturer** | Enters coursework + exam (→ ENTERED) | First responder — enters/agrees the corrected mark |
| **HOD** | **Captures** the department's marks (→ CAPTURED) | Departmental oversight |
| **Dean** | **Approves** the faculty's marks (→ APPROVED); can send back | Faculty oversight / escalation |
| **Senate / Academic Registrar (Admin)** | **Publishes** final results (→ PUBLISHED) | **Final approval** of corrections; can reassign & override |

**Two guarantees leaders should take away:**
1. **No single point of release** — every mark passes lecturer → HOD → Dean → Senate before it becomes official.
2. **Nothing is lost or hidden** — every advance, approval, correction, and reversal is recorded with who, when, what changed, and a frozen snapshot. GPA and CGPA always stay consistent with the decisions on record.

---

## 6. The 7-Slide Deck — Suggested Outline

> Map the knowledge above onto exactly 7 slides. Each slide below gives the **headline**, the **one key message**, a **visual suggestion**, and **speaker-note cues**. Keep it visual — one strong diagram per slide, minimal text.

### Slide 1 — Title & Purpose
- **Headline:** *"The Life of a Mark — From Entry to Transcript"*
- **Message:** How marks are entered, approved, published, and corrected at MRU — and your role as HOD / Dean.
- **Visual:** MRU logo, navy title bar, subtitle "Campus Dynamics EMIS". Optional small pipeline motif.
- **Notes:** Set expectation: "By the end you'll know exactly where you sit in the chain and what the safeguards are."

### Slide 2 — The Big Picture
- **Headline:** *"Two lives of a mark, three journeys"*
- **Message:** Provisional vs Published; and the three journeys (Publishing, Mark Change, Missing Mark). One golden rule: students only ever see PUBLISHED.
- **Visual:** Left = "Provisional (staff only)", Right = "Published (official)", with a divider labelled "the publishing gate". Three journey icons underneath.
- **Notes:** Emphasise the golden rule up front.

### Slide 3 — Journey 1: The Publishing Chain
- **Headline:** *"Marks are published level-by-level — never by one person"*
- **Message:** The 5 stages: NOT_ENTERED → ENTERED (Lecturer) → CAPTURED (HOD) → APPROVED (Dean) → PUBLISHED (Senate).
- **Visual:** The horizontal 5-stage arrow (Section 2), each stage colour-chipped, with the role under each.
- **Notes:** Call out "both coursework AND exam needed to advance", and "send-back one level down with a reason".

### Slide 4 — Journey 1: How a Level Approves (the wizard) + Visibility
- **Headline:** *"Choose a batch → Preview → Commit — fully recorded"*
- **Message:** Every level uses the same 3-step wizard with a preview snapshot; visibility narrows as marks climb; students/lecturers can track status without seeing values.
- **Visual:** 3-step wizard strip (Batch → Preview → Commit) + a small "who sees what" ladder.
- **Notes:** Stress the audit snapshot and the Mark Status Check screen (kills "where are my results?" queries).

### Slide 5 — Journey 2: Correcting a Wrong Mark
- **Headline:** *"Mark Change — requested, reviewed, auto-audited"*
- **Message:** Student → Lecturer → (Supervisor) → Admin; on approval the result + GPA/CGPA update automatically; downgrades auto-reverse.
- **Visual:** The 4-step correction arrow (Section 3) + a small "GPA recomputed / auto-revert" safety badge.
- **Notes:** "A transcript can never silently drift from the decision on record."

### Slide 6 — Journey 3: Filling a Missing Mark
- **Headline:** *"Missing Mark — routed to the lecturer who actually taught it"*
- **Message:** Same rail as Mark Change; the student names the right lecturer from a searchable directory; email notifications at each hand-off.
- **Visual:** The missing-mark arrow (Section 4) + envelope icons at hand-offs. Include the "500+ already resolved" stat as proof.
- **Notes:** Explain why student-chooses-lecturer matters (teaching allocations change over years).

### Slide 7 — Roles, Safeguards & Takeaways
- **Headline:** *"Your role, and why the system is trustworthy"*
- **Message:** The roles table (Section 5) + the two guarantees (no single point of release; nothing lost or hidden).
- **Visual:** Compact roles grid; two large "guarantee" callouts.
- **Notes:** Close by inviting HODs/Deans to log in and try their console.

---

## 7. Brand Kit — Campus Dynamics / MRU (please follow exactly)

The EMIS uses a **flat, compact, navy-dominant** design language. Please match the deck to it.

### 7.1 Institution
- **Full name:** **Muteesa I Royal University** (abbreviation **MRU**).
- ⚠️ **Critical:** never write "Mbarara Research University" or any other expansion — MRU is **Muteesa I Royal University**. Use the official MRU logo/crest (request from the client).
- **System name:** *Campus Dynamics EMIS*. Office context: *Office of the Academic Registrar*.

### 7.2 Colour palette (use these hex values)

| Role | Hex | Use for |
|------|-----|---------|
| **Primary navy** | `#05275C` | Title bars, headers, primary shapes, key arrows |
| Primary hover/deep | `#041D45` | Darker accents, footers |
| **Accent blue** | `#174DA4` | Links, highlights, active/emphasis elements |
| Accent deep | `#0F3A7D` | Secondary emphasis |
| **Surface** | `#F5F7FA` | Slide / panel backgrounds |
| Card white | `#FFFFFF` | Cards, boxes, content areas |
| **Border/divider** | `#E0E5ED` | Lines, separators, table borders |
| Body text | `#1A1A2E` | Main text |
| Secondary text | `#555555` | Labels, captions |
| Muted text | `#888888` | Metadata, footnotes |
| Success green | `#16A34A` (bg `#E6F4EA`, text `#155724`) | "Approved / Published" states |
| Warning amber | `#D97706` (bg `#FFF8E1`, text `#B45309`) | "Pending / in-review" states |
| Danger red | `#DC3545` | "Rejected / reversed" states |

**Suggested stage colours** (for the publishing pipeline chips): NOT_ENTERED = muted grey `#888`; ENTERED = accent `#174DA4`; CAPTURED = navy `#05275C`; APPROVED = amber `#D97706`; PUBLISHED = success green `#16A34A`.

> ❌ **Do NOT use purple `#422774`** — it is a retired legacy colour and must never appear.

### 7.3 Typography
- **Font:** Segoe UI (or its equivalents: -apple-system, Helvetica Neue, Arial). Clean, sans-serif, no decorative fonts.
- **Weights:** 700 for slide titles, 600 for section/card headings, 400–500 for body.
- Generous size for a presentation (titles ~28–36pt, body ~16–20pt) — the on-screen app is compact, but a projected deck should be large and legible.

### 7.4 Visual style (match the app's language)
- **Flat and clean:** **no gradients, no drop shadows, no glossy 3-D effects.**
- **Small radii:** square or lightly-rounded corners (2–4px feel), never large pill/blob shapes.
- **Navy-dominant** with white space; blue as the accent; colour used purposefully (green = done, amber = pending, red = rejected).
- **Iconography:** simple line icons (single-stroke), not filled cartoon icons.
- **Diagrams over text:** each journey is a left-to-right arrow flow — lean on those.

### 7.5 Tone
- Audience is **senior academics (HODs, Deans)** — confident, plain-English, governance-minded. Emphasise **accountability, integrity, and their specific role**. Avoid database/technical jargon on the slides (keep the table/column names in this brief only, not on-screen).

---

## 8. Glossary (for the consultant — keep off the slides)

| Term | Plain meaning |
|------|---------------|
| **Provisional marks** | Marks still being worked on by staff; not yet official. |
| **Published results** | Final, official marks on the transcript (the results ledger). |
| **mark_stage** | The internal label tracking a mark's position: NOT_ENTERED → ENTERED → CAPTURED → APPROVED → PUBLISHED. |
| **Capture / Approve / Publish** | The HOD / Dean / Senate actions that advance a mark one level. |
| **Send-back / return** | Pushing a batch one level down with a reason, for correction. |
| **Mark Change** | A request to correct a mark that is wrong. |
| **Missing Mark** | A request to supply a mark that was never entered. |
| **GPA / CGPA** | Semester and cumulative grade averages — recomputed automatically whenever a result changes. |
| **Grading** | NCHE 2015 scheme; pass mark 50. (A≥80, B+ 75–79, B 70–74, C+ 65–69, C 60–64, D+ 55–59, D 50–54, F<50.) |

---

*Everything in this brief reflects the live Campus Dynamics EMIS at MRU. If any figure or screen name needs to be confirmed before the presentation, ask the client's system team for the current snapshot.*
