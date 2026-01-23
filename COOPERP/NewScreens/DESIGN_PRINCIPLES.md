# Campus Dynamics - New Screens Design Principles

## Overview

This document defines the core design principles for the new Campus Dynamics screens. These guidelines ensure consistency, professionalism, and maintainability across all UI components while maintaining compatibility with DevExpress controls.

---

## Core Design Philosophy

### 1. Space Optimization
- **Small paddings** (4-10px)
- **Small margins** (4-12px)
- **Compact layouts** that maximize content density
- No wasted white space

### 2. Typography
- **Small, readable fonts** (10-14px)
- Base font size: **12px**
- System font stack for consistency
- Font weights: 400 (normal), 500 (medium), 600 (semi-bold)

### 3. Visual Style
- **Square corners** (border-radius: 0) - NO rounded corners
- **Flat design** - NO gradients, shadows, or 3D effects
- Clean, professional appearance
- Minimal visual noise

### 4. Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| **Primary** | `#422774` | Headers, buttons, active states, branding |
| **Primary Dark** | `#331d5c` | Hover states, borders |
| **White** | `#FFFFFF` | Backgrounds, text on dark |
| **Light Gray** | `#F5F5F5` | Secondary backgrounds |
| **Border Gray** | `#E0E0E0` | Borders, dividers |
| **Text** | `#333333` | Primary text |
| **Text Secondary** | `#666666` | Secondary text, labels |
| **Text Muted** | `#999999` | Placeholders, disabled |
| **Success** | `#28A745` | Success states |
| **Warning** | `#FFC107` | Warning states |
| **Danger** | `#DC3545` | Error states, destructive actions |
| **Info** | `#17A2B8` | Informational |

---

## Spacing Scale

| Name | Value | Usage |
|------|-------|-------|
| `xs` | 4px | Tight spacing, icon gaps |
| `sm` | 6px | Small component padding |
| `md` | 8px | Default spacing |
| `lg` | 10px | Card padding |
| `xl` | 12px | Section spacing |
| `xxl` | 16px | Major section separation |

---

## Typography Scale

| Name | Size | Usage |
|------|------|-------|
| `xs` | 10px | Captions, badges, metadata |
| `sm` | 11px | Secondary text, table content |
| `base` | 12px | Body text, form controls |
| `md` | 13px | Emphasis, labels |
| `lg` | 14px | Section headers |
| `xl` | 16px | Page titles |
| `xxl` | 18px | Major headings |

---

## Component Guidelines

### Buttons
```css
padding: 6px 12px;
font-size: 12px;
font-weight: 500;
border: 1px solid;
border-radius: 0;
```

**Variants:**
- **Default**: White background, gray border
- **Primary**: Purple background (#422774), white text
- **Success/Danger/Warning**: Semantic colors

### Form Controls
```css
height: 30px;
padding: 6px 8px;
font-size: 12px;
border: 1px solid #E0E0E0;
border-radius: 0;
```

### Cards
```css
background: #FFFFFF;
border: 1px solid #E0E0E0;
border-radius: 0;
```
- Header: Light gray background (#FAFAFA), 8-10px padding
- Body: 10px padding

### Tables
```css
font-size: 11px;
```
- Header: Purple background (#422774), white text
- Row padding: 6px 8px
- Alternating row colors for readability

### Badges
```css
padding: 2px 6px;
font-size: 10px;
font-weight: 600;
border-radius: 0;
```

---

## DevExpress Integration

All DevExpress controls are styled to match our design principles:

### ASPxGridView
- Purple header rows
- Compact cell padding
- No gradients or rounded corners
- Flat pager buttons

### ASPxRoundPanel
- Square corners (despite the name)
- Purple headers
- Clean borders

### ASPxTextBox / ASPxComboBox
- Consistent with native form controls
- Purple focus border
- Square corners

### ASPxButton
- Matches our button styles
- No gradient backgrounds

---

## File Structure

```
COOPERP/NewScreens/
├── css/
│   ├── sidebar.css      # Layout: sidebar, header, content area
│   └── theme.css        # Components: buttons, forms, tables, DevExpress overrides
├── SidebarMaster.master # Master page template
├── SidebarMaster.master.cs
├── NewFaculties.aspx    # Example page
└── DESIGN_PRINCIPLES.md # This file
```

---

## CSS Usage

### In Master Page (SidebarMaster.master)
```html
<link rel="stylesheet" type="text/css" href="~/COOPERP/NewScreens/css/sidebar.css" runat="server" />
<link rel="stylesheet" type="text/css" href="~/COOPERP/NewScreens/css/theme.css" runat="server" />
```

### CSS Class Naming Convention
- Prefix: `cd-` (Campus Dynamics)
- BEM-like structure: `cd-component__element--modifier`
- Examples:
  - `cd-btn`, `cd-btn--primary`, `cd-btn--sm`
  - `cd-card`, `cd-card__header`, `cd-card__body`
  - `cd-form-control`, `cd-form-control--error`

---

## Utility Classes

### Spacing
- `cd-m-{size}`, `cd-mt-{size}`, `cd-mb-{size}`, etc.
- `cd-p-{size}`, `cd-pt-{size}`, `cd-pb-{size}`, etc.

### Display
- `cd-d-none`, `cd-d-block`, `cd-d-flex`

### Text
- `cd-text-{size}`, `cd-text-{color}`, `cd-text-bold`

### Background
- `cd-bg-white`, `cd-bg-light`, `cd-bg-primary`

---

## Do's and Don'ts

### ✅ DO
- Use the defined color palette
- Keep padding and margins small
- Use square corners everywhere
- Follow the spacing scale
- Use utility classes for quick styling
- Test on mobile devices

### ❌ DON'T
- Use rounded corners
- Add gradients or shadows
- Use fonts larger than 18px (except logos)
- Introduce new colors outside the palette
- Add unnecessary animations
- Use inline styles for repeated patterns

---

## Responsive Breakpoints

| Breakpoint | Width | Target |
|------------|-------|--------|
| Mobile | ≤576px | Phones |
| Tablet | ≤768px | Tablets |
| Desktop | ≤992px | Small desktops |
| Large | >992px | Large screens |

---

## Quick Reference - Common Patterns

### Card with Table
```html
<div class="cd-card">
    <div class="cd-card__header">
        <h3 class="cd-card__title">Title</h3>
        <div class="cd-card__actions">
            <asp:LinkButton CssClass="cd-btn cd-btn--primary cd-btn--sm">Add</asp:LinkButton>
        </div>
    </div>
    <div class="cd-card__body cd-p-0">
        <dx:ASPxGridView ... />
    </div>
</div>
```

### Form Layout
```html
<div class="cd-form-row">
    <div class="cd-form-group">
        <label class="cd-form-label">Field 1</label>
        <dx:ASPxTextBox CssClass="cd-form-control" />
    </div>
    <div class="cd-form-group">
        <label class="cd-form-label">Field 2</label>
        <dx:ASPxTextBox CssClass="cd-form-control" />
    </div>
</div>
```

### Toolbar
```html
<div class="cd-toolbar">
    <div class="cd-toolbar__group">
        <button class="cd-btn cd-btn--primary">Add New</button>
        <button class="cd-btn">Export</button>
    </div>
    <div class="cd-toolbar__spacer"></div>
    <div class="cd-toolbar__search">
        <input type="text" placeholder="Search..." />
    </div>
</div>
```

---

*Last Updated: January 2026*
