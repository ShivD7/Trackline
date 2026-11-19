# DESIGN.md — Trackline

## Product overview

Trackline is a personal job application management platform.

It helps users organize applications, manage company profiles, record interview notes, visualize hiring pipelines, track follow-up deadlines, and understand application performance through response rates and weekly progress.

The interface should make job searching feel more organized and less overwhelming.

## Design philosophy

- **Organize without friction:** Adding and updating applications should be quick.
- **Progress should be visible:** Users should immediately understand their pipeline.
- **Calm productivity:** Avoid loud dashboards and excessive gamification.
- **Actions over analytics:** Prioritize upcoming interviews and follow-ups.
- **Thoughtful simplicity:** Every interface element should serve a clear purpose.

## Visual identity

**Style:** Modern productivity workspace inspired by Linear, Notion, and premium personal CRM tools.

**Personality:** Calm, focused, professional, slightly editorial.

**Color palette:**
- Background: `#FAFAF9`
- Surface: `#FFFFFF`
- Secondary surface: `#F5F5F4`
- Primary text: `#1C1917`
- Secondary text: `#78716C`
- Border: `#E7E5E4`
- Brand: `#2563EB`
- Brand hover: `#1D4ED8`
- Success: `#16A34A`
- Warning: `#D97706`
- Error: `#DC2626`
- Muted accent: `#EFF6FF`

Default to a bright, neutral interface with restrained blue accents.

Use generous whitespace without sacrificing information density.

## Typography

- UI font: Inter or Geist
- Base size: 14px
- Page titles: 26–32px
- Section titles: 16–20px
- Secondary labels: 12–13px
- Metrics: 28–36px with tabular numerals

Maintain consistent hierarchy throughout the application.

## Layout and navigation

Use a compact sidebar with:
- Overview
- Applications
- Pipeline
- Companies
- Follow-ups
- Analytics

Keep the most frequently used actions easily accessible.

Include a prominent but restrained "Add Application" action.

### Overview dashboard

The dashboard should answer:

1. How many applications are active?
2. What stage are they in?
3. What needs attention today?
4. How has the search progressed recently?

Include:
- Total active applications
- Response rate
- Upcoming interviews, if recorded
- Overdue follow-ups
- Due-today follow-ups
- Upcoming follow-ups
- Weekly application activity
- Recent applications

Make time-sensitive follow-ups more prominent than secondary analytics.

### Applications page

Provide a searchable, filterable list with:
- Company
- Role
- Location, if available
- Application date
- Current stage
- Last activity
- Next follow-up

Users should be able to create, edit, and inspect applications with minimal navigation.

Use a compact table rather than oversized cards.

### Hiring pipeline

Create a visual Kanban board.

Suggested stages:
- Applied
- Online Assessment
- Interview
- Offer
- Rejected
- Withdrawn

Treat these as configurable design defaults, not assumptions about existing database values.

Each card should include:
- Company name
- Role title
- Application date or recent activity
- Next action or follow-up indicator

Support drag-and-drop only if it can be implemented reliably with Stimulus and server persistence.

Provide accessible stage changes without requiring drag-and-drop.

### Application detail

Use a clean, structured detail page.

Include:
- Company and role information
- Current hiring stage
- Application timeline
- Interview notes
- Follow-up dates
- Important links, when saved

Use inline editing or focused edit forms where appropriate.

Avoid overwhelming the page with too many panels.

### Companies page

Organize company profiles with:
- Company name
- Associated applications
- Relevant notes
- Links and contact information when stored

Use company detail pages to connect multiple applications to the same employer.

### Follow-ups

Organize follow-ups into:
- Overdue
- Due Today
- Upcoming
- Completed, if tracked

Use clear date labels and quick actions.

Users should be able to identify the next task without opening multiple pages.

### Analytics

Keep analytics practical and understated.

Include:
- Weekly application counts
- Response rate
- Application stage distribution
- Application progress over time

Ensure metric definitions are consistent with existing Active Record queries.

Use line or bar charts when appropriate.

Avoid decorative charts and misleading percentages.

## Component guidelines

- Buttons: 7–8px radius
- Cards: Minimal shadows, subtle borders
- Tables: Compact but breathable
- Inputs: Clear labels and focus states
- Badges: Neutral backgrounds with selective semantic colors
- Dropdowns: Keyboard-friendly
- Dialogs: Simple, focused workflows
- Toasts: Short confirmation messages
- Empty states: Helpful and encouraging without excessive illustrations

Avoid gradients, glassmorphism, oversized hero sections, and excessive iconography.

## Interaction design

- Application creation should require as few steps as practical.
- Support quick stage updates.
- Use Turbo Frames for localized page updates.
- Use Turbo Streams where appropriate for live UI changes after server actions.
- Use Stimulus for lightweight interactions.
- Preserve user context when saving edits.
- Display clear server-confirmed success and error states.
- Confirm destructive actions.
- Avoid unnecessary JavaScript-heavy components.

## Responsive design

Desktop:
- Persistent sidebar
- Full application table
- Multi-column Kanban board

Tablet:
- Collapsible navigation
- Scrollable pipeline
- Condensed tables

Mobile:
- Simple top navigation or drawer
- Application list as structured rows
- Pipeline stages accessible individually
- Full-width forms
- Accessible follow-up actions

## Accessibility

- WCAG AA contrast
- Keyboard navigation
- Visible focus states
- Semantic HTML
- Accessible form validation
- Proper focus management
- Non-color-dependent status labels
- Reduced-motion support

## Implementation guidance

Preserve Rails 8.1, Turbo, Stimulus, SQLite, and Minitest.

Prefer server-rendered Rails views over introducing a separate React frontend.

Create reusable Rails partials for:
- Application rows
- Stage badges
- Company summaries
- Follow-up items
- Dashboard metrics
- Pipeline cards
- Interview notes

Use CSS custom properties for colors, typography, spacing, and component tokens.

Use Stimulus controllers only when interaction requires client-side behavior.

Keep existing database models and application workflows intact.

Add tests for any new interactions or business logic.

## Design acceptance criteria

Trackline should feel like a polished personal productivity tool rather than a generic admin dashboard.

Users should be able to record applications quickly, understand their hiring pipeline, and identify upcoming follow-ups immediately.

The experience should be simple enough to use every day without feeling like additional work.
