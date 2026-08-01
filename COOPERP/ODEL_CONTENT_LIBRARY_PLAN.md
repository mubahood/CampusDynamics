# ODEL Course Content & Material Library — Redesign Plan

**Goal:** replace the flat "topic → material" model with a clear hierarchy **Chapter → Topic → Material**, where materials are **independent, reusable library items** (a video or reading lives once and is linked into many topics/chapters), with ordering everywhere, sharing controls, tagging/search, drag-and-drop authoring, preview-before-publish, and undeletable fallback folders.

Status: **Decisions locked 2026-07-17. Building.**

**Locked decisions:** (1) kinds = **YOUTUBE + READING + PAGE + LINK** (all four); (2) readings = **PDF, .doc/.docx, .ppt/.pptx**, hard cap **10 MB**; (3) SHARED items reusable by **all lecturers university-wide**; (4) tags = simple `tags` column (search) for now; (5) sharing default = **PRIVATE**; (6) General chapter/topic = **undeletable but renamable** (`is_system=1`, delete blocked, rename allowed). Build approach: **additive schema first** (keep old `odel_material.topic_id` etc. until the new UI/service is live, so nothing breaks — content is near-greenfield anyway), then switch over.

## 1. Current state (analyzed 2026-07-17)

- `odel_course_space` → `odel_topic(space_id, title, sort_order, is_published)` → `odel_material(topic_id, type FILE|PAGE|LINK, title, file_id, url, page_html, sort_order, is_published)`.
- Materials are **owned by one topic** (`topic_id` FK) → no reuse, duplication required.
- `odel_file(stored_path, orig_name, mime, size_bytes, sha1, owner_type, owner_ref)` — files on disk, **sha1 already computed** (dedup possible, unused today). Upload via `OdelUpload.ashx` (policy `max_upload_mb`, `SaveAs`).
- Student view: `StudentSpace` → published topics → published materials. Teacher builder: `BuildContent.aspx` + `GetContent/SaveTopic/SaveMaterial/SetContentPublished/CopyForward`.
- **Data volume: 1 topic, 0 materials, 0 files** → essentially greenfield; migration is trivial.

## 2. New hierarchy

```
Course Space
 └─ Chapter        (ordered, publishable, one "General" chapter is system/undeletable)
     └─ Topic      (ordered, publishable, one "General" topic per chapter is system/undeletable)
         └─ Material LINK (ordered, publishable)  ─────┐
                                                        ▼
                                    Material Library item (independent, reusable)
                                      ├─ YOUTUBE  (video URL)
                                      ├─ READING  (PDF/Word/doc ≤ 10 MB)
                                      ├─ PAGE     (rich text)      [optional kind]
                                      └─ LINK     (external URL)   [optional kind]
```

A **material exists once in the library** and is attached to any number of topics through a link row; editing it updates every place it appears (single source of truth), and deleting a still-linked material is blocked/warned.

## 3. Data model (new + changed tables)

**NEW `odel_chapter`**
`id, space_id, title, sort_order, is_published TINYINT, is_system TINYINT DEFAULT 0, created_at, updated_at`
- `is_system=1` = the undeletable "General" chapter auto-created per space.

**CHANGE `odel_topic`** — add `chapter_id INT`, `is_system TINYINT DEFAULT 0`, `updated_at`. Keep `space_id` (denormalised = chapter's space) so existing space-scoped queries keep working. Topic now lives under a chapter.

**REPURPOSE `odel_material` → the LIBRARY** (drop topic ownership):
`id, owner_empid INT, kind VARCHAR(10) [YOUTUBE|READING|PAGE|LINK], title, description VARCHAR(500), file_id INT NULL, url VARCHAR(500) NULL, page_html MEDIUMTEXT NULL, visibility VARCHAR(8) [PRIVATE|SHARED] DEFAULT 'PRIVATE', category VARCHAR(40) NULL, tags VARCHAR(400) NULL (lowercased, comma-sep), space_id INT NULL (origin course, for "my course" scoping), created_at, updated_at`
- Old `type`/`topic_id`/per-topic `sort_order`/`is_published` **move out** (topic_id → link table; publish → link table).

**NEW `odel_topic_material`** (many-to-many link)
`id, topic_id INT, material_id INT, sort_order INT, is_published TINYINT DEFAULT 0, added_by INT, created_at`
- Unique `(topic_id, material_id)`. `is_published` = student-visible **in this topic**. Ordering is per link.

**`odel_file`** — unchanged; add sha1 **dedup** on upload (reuse existing row when hash matches for the same owner) to "reduce redundancy".

**Two orthogonal visibility concepts (important):**
- **Library visibility** (`odel_material.visibility`): PRIVATE (only owner can reuse) vs SHARED (any lecturer can find + link). Set at upload/creation.
- **Per-topic publish** (`odel_topic_material.is_published`): whether students see the material in that topic. Independent of library visibility.

## 4. Ordering (all levels)

`sort_order INT` on `odel_chapter`, `odel_topic`, `odel_topic_material`. Reorder endpoint takes an ordered list of ids for a parent and rewrites `sort_order` in one transaction. Drag-and-drop in the UI calls it.

## 5. The Material Library (WordPress-media-library style)

- **Store:** `odel_material` is the central library. Each item: owner, kind, title/description, tags, category, visibility, and the payload (file_id / url / page_html).
- **Scope a lecturer sees:** their own items (any visibility) ∪ all `SHARED` items from others.
- **Search/filter:** by text (title/description/tags via LIKE/`FIND_IN_SET`), `kind`, `category`, and scope (mine | shared | all).
- **Reuse:** "Add material to topic" opens the library picker → search → select one/many → creates `odel_topic_material` links. Same item can be linked to many topics/chapters.
- **Upload/create new** (inline in the picker): YOUTUBE (paste URL → validate + extract video id + thumbnail) or READING (drag-drop file ≤10 MB → `OdelUpload.ashx` with a 10 MB cap for readings) — plus title, description, tags, category, and the PRIVATE/SHARED choice.
- **Thumbnails:** YouTube → `img.youtube.com/vi/{id}/hqdefault.jpg`; READING → doc-type icon; PAGE/LINK → glyphs.

## 6. Sharing & permissions

- At upload: radio **"Keep private to my course" / "Share for other lecturers to reuse"** → `visibility`.
- SHARED items are discoverable by all lecturers in the library picker; only the **owner** can edit/delete the library item. Other lecturers can only link/unlink it in their own topics.
- Unlinking a material from a topic never deletes the library item. Deleting a library item is blocked while links exist (offer "unlink everywhere" first).

## 7. Fallback undeletable folders

On `EnsureSpace` (and a self-heal sweep), every space gets:
- a **"General" chapter** (`is_system=1`), containing
- a **"General" topic** (`is_system=1`).
So there is always a home for content. System rows: cannot be deleted or renamed away (rename allowed? — decision §12.5), always sort first. "General materials" = an **Uncategorised** default category in the library (also non-removable) so every material has a category even if the lecturer sets none.

## 8. Front-end (BuildContent rebuild)

A single authoring surface (still `BuildContent.aspx`, wide, consistent with the module):
- **Chapters** as collapsible sections (accordion), each with a drag handle; "+ Add chapter".
- **Topics** inside each chapter, drag handle; "+ Add topic"; can drag a topic between chapters.
- **Material links** inside each topic (rows with thumbnail, title, kind badge, publish toggle, drag handle, remove/unlink); "+ Add material" → **Library picker modal**.
- **Library picker modal:** tabs = *Browse library* (search/filter/select existing) | *Upload reading* | *Add YouTube*. Selecting/creating links into the current topic.
- **Preview:** inline preview of a material (YouTube embed, PDF in an iframe/new tab, page HTML) before/after publishing.
- **Drag-and-drop:** native HTML5 DnD (no external libs — CSP-safe), reordering chapters, topics, and material links; drop → reorder API call.
- Publish toggles at every level; "General" system rows are visually marked and can't be deleted.

## 9. Service / API (OdelApi.ashx actions)

Reads: `teach.outline` (chapters→topics→links, for the builder), `lib.search` (library query), `lib.item` (one item), student `student.space` (rebuilt to the new hierarchy).
Writes: `chapter.save` / `chapter.delete` / `chapter.reorder`; `topic.save` / `topic.delete` / `topic.reorder` (+ move to chapter); `lib.save` (create/update library item) / `lib.upload` (reading, ≤10 MB) / `lib.delete`; `link.add` / `link.remove` / `link.reorder` / `link.publish`. All StaffAuth'd; system rows guarded; deletes are safe (links checked).

## 10. Student side

`StudentSpace` rebuilt: published chapters → published topics → published material links (join `odel_topic_material` → `odel_material`), rendering YouTube embeds and reading downloads. Ordering respected at all levels.

## 11. Migration & compatibility

Near-greenfield. One-time: for the single existing topic, create its space's General chapter and set `chapter_id`. Any legacy `odel_material.topic_id` rows (currently 0) → convert to library items + links. Update all counters (`TeachingSpaces`, `CourseDashboard`, `GetContent`, `CopyForward`) to count via `odel_topic_material`. `CopyForward` copies chapters/topics and **re-links** the same library items (no file duplication).

## 12. Decisions to confirm

1. **Extra material kinds** — support only **YOUTUBE + READING** now (cleanest), or also keep **PAGE (rich text)** and **LINK (external URL)** as available kinds?
2. **Tags** — simple `tags` column with search (fast to build) vs a normalised `odel_material_tag` table (nicer faceting). Recommend the column for now.
3. **Reading file types & size** — allow PDF, Word (doc/docx), PowerPoint (ppt/pptx), and plain docs, hard cap **10 MB**? Any others (e.g., images, spreadsheets)?
4. **Sharing default** — new uploads default to **PRIVATE** (opt-in to share) — confirm.
5. **System "General" rows** — undeletable; may they be **renamed**, or fully locked?
6. **Cross-course reuse scope** — SHARED items reusable by **all lecturers** university-wide, or limited to the same department/faculty?

## 13. Build phases (after approval)

- **P1 Schema** — `odel_chapter`, alter `odel_topic`, repurpose `odel_material`, `odel_topic_material`; EnsureSchema self-heal + General fallback seeding; migrate the 1 legacy topic.
- **P2 Service/API** — outline/library/link/reorder/upload endpoints; dedup on upload; system-row + safe-delete guards.
- **P3 Builder UI** — chapters/topics/links with drag-drop, library picker modal, preview, publish toggles.
- **P4 Student view** — rebuilt hierarchy render (YouTube + readings).
- **P5 Counters + CopyForward + verify** — update dashboards/counts, copy-forward re-linking, end-to-end test.

---

## 14. API Reference — Content Library (all via `OdelApi.ashx?action=...`)

Reads use GET (`Odel.get`), writes use POST JSON (`Odel.post`). Every call is staff-authenticated; space is resolved from the chapter/topic/link for authorisation; system ("General") rows are protected; deletes are safe (links checked / materials preserved). All return `{ success, ... }` or `{ success:false, message }`.

**Outline & library (reads)**
| action | params | returns |
|---|---|---|
| `teach.outline` | `spaceId` | `{ courseID, title, chapters:[{ id,title,published,isSystem, topics:[{ id,title,published,isSystem, materials:[{ linkId,materialId,kind,title,url,fileId,fileName,size,published }] }] }] }` |
| `lib.search` | `kind`, `category`, `q`, `scope`(mine\|shared\|all), `page` | `{ items:[{ id,kind,title,description,category,tags,visibility,mine,url,fileId,fileName,size,links }], total,page,pages }` |
| `lib.item` | `id` | `{ item:{ …incl pageHtml } }` (own or SHARED only) |

**Material library (writes)**
| action | params | notes |
|---|---|---|
| `lib.save` | `json` = `{ id?,kind,title,description,url,pageHtml,fileId,category,tags,visibility,spaceId }` | kind ∈ YOUTUBE\|READING\|PAGE\|LINK; YouTube URL validated; READING ≤10 MB + PDF/Word/PPT; owner-only edit; sets `type='LIB'` → `{ id }` |
| `lib.delete` | `id`, `force`(bool) | owner-only; if linked & !force → `{ needsConfirm:true, links }`; force unlinks-all then deletes |

**Structure (writes) — StaffAuth'd, system-guarded**
| action | params |
|---|---|
| `chapter.save` | `spaceId`, `id`(0=new), `title` |
| `chapter.delete` | `spaceId`, `id` (topics move to General; General not deletable) |
| `chapter.reorder` | `spaceId`, `ids` (CSV in order) |
| `topic.save` | `spaceId`, `id`(0=new), `chapterId`, `title` |
| `topic.delete` | `spaceId`, `id` (links dropped, library items kept; General not deletable) |
| `topic.reorder` | `chapterId`, `ids` (CSV; also moves topics into the chapter) |
| `content.pub` | `kind`(chapter\|topic\|link), `id`, `publish`(bool) — auto-activates a DRAFT space |
| `link.add` | `topicId`, `materialIds` (CSV) — links library items into a topic (INSERT IGNORE) |
| `link.remove` | `linkId` — unlink (library item preserved) |
| `link.reorder` | `topicId`, `linkIds` (CSV) |
| `content.copyforward` | `spaceId` — copies chapters+topics, **re-links** the same materials → `{ chapters, topics, materials }` |

**Student (read):** `student.space` `{ spaceId }` → now returns `chapters:[{ title, topics:[{ title, materials:[{ kind,title,url,fileId,fileName,size }] }] }]` + assignments + coursework.
**Files:** upload `OdelUpload.ashx` (multipart; **sha1 dedup** reuses identical files per owner); serve/preview `OdelFile.ashx?id={fileId}`.

## 15. Build status

- **P1 schema** ✔ (odel_chapter, odel_topic_material, +columns, General seeding, legacy topic_id/type nullable). Self-heal `OdelCore.EnsureContentSchema`/`EnsureGeneral`.
- **P2 service/API** ✔ (`OdelContentService.cs`, 15 actions).
- **P3 builder UI** ✔ (`BuildContent.aspx` — chapters/topics/link rows, native drag-drop, library picker modal, publish toggles, preview).
- **P4 student view** ✔ (`StudentSpace` chapters model + `CourseSpace.aspx` YouTube embeds/reading downloads).
- **P5 counters/copyforward/dedup** ✔. End-to-end data flow verified (create→link→outline/student/count).
- Legacy `odel_material.topic_id`/`type` kept (nullable) — old rows harmless; formal column retirement optional later.
