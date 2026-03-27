# Campus Dynamics — Design Principles
> **This document has been superseded.**
> Full specification lives in: `NewScreens/DESIGN_SYSTEM.md`
> Last updated: 2026-03-25

---

## Full Documentation Has Moved

All component specs, CSS snippets, color tokens, spacing rules, ASP.NET patterns, and anti-patterns are now in:

**`COOPERP/NewScreens/DESIGN_SYSTEM.md`**

Refer to that file for any design or implementation decisions.

---

## DEPRECATED COLORS — DO NOT USE

> **WARNING**: The color values listed below this line were the OLD design scheme and are fully retired.
> Any file, commit, or comment referencing these colors reflects outdated work and must not be replicated.

| Deprecated | Value | Replaced by |
|------------|-------|-------------|
| Old primary | `#422774` (purple) | `#05275C` (navy) |
| Old primary dark | `#331d5c` (dark purple) | `#041d45` (deep navy) |

---

## New Color Palette (Summary)

The design system uses a **navy-dominant, flat** palette.

| Token | Value | Primary Use |
|-------|-------|-------------|
| Primary | `#05275C` | Page headers, primary buttons, icon boxes |
| Primary hover | `#041d45` | Button hover states |
| Accent | `#174DA4` | Links, active tabs, focus rings |
| Accent hover | `#0f3a7d` | Accent button hover |
| Surface | `#f5f7fa` | Page background, table header bg |
| Card | `#ffffff` | Card and modal backgrounds |
| Border | `#e0e5ed` | All borders and dividers |
| Input border | `#cdd3de` | Input, select borders |
| Text primary | `#1a1a2e` | Primary body text |
| Text secondary | `#555` | Labels, column headers |
| Text muted | `#888` | Metadata, placeholder text |
| Success | `#16a34a` / bg `#e6f4ea` | Active status, save actions |
| Danger | `#dc3545` | Delete, error states |
| Warning/amber | `#d97706` / bg `#fff8e1` | Pending, caution states |

---

## Core Design Principles

1. **Flat** — no gradients on buttons or cards; solid fills only.
2. **Compact** — dense information layout; 11–12px body text, tight padding.
3. **Square corners** — `border-radius: 0` on all inputs, buttons, and badges. Modals use `2px`. Cards use `4px` maximum.
4. **No decorative shadows** — `box-shadow` is only used on modal containers.
5. **Navy-primary** — `#05275C` dominates headers and primary actions.
6. **Scoped CSS** — each module uses a 2–3 letter prefix (`fs-`, `hr-`, `fm-`) to prevent collisions.
7. **Font stack**: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif`

---

## Benchmark Reference Files

| File | Purpose |
|------|---------|
| `NewScreens/FeesStructure.aspx` | **Primary benchmark** — the definitive visual reference for all new screens |
| `NewScreens/HRContracts.aspx` | Action popovers, inline status badges |
| `NewScreens/FeesManagement.aspx` | Cross-page tab navigation + section sub-tabs |
| `NewScreens/HRPayroll.aspx` | Multi-panel layout, batch operations |
| `NewScreens/NewFacultyProgrammes.aspx` | Modal CRUD, postback-safe dropdowns |

---

*For all implementation details, component code, and ASP.NET patterns, see `DESIGN_SYSTEM.md`.*
