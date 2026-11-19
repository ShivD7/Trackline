# Trackline UI review and refinement

Source of truth: repository-root `DESIGN.md`, copied unchanged from the workspace root. Active application: `trackline-dev`.

Method: dual-agent (A: `/root/design_review`; B: `/root/evidence_review`). The source reviews were independent. A reviewed product design and heuristics without detector output; B reviewed markup, styles, accessibility, and the detector. The parent inspected the rendered app in Chrome, using an isolated sample SQLite database.

## Initial critique

Trackline already had useful job-search vocabulary, shared application rows, explicit stage history, labelled forms, server-confirmed saves, and helpful empty states. The visual implementation was internally coherent, but its green/cream palette, dark sidebar, large Georgia headings, gradient, and shadowed cards conflicted with the approved neutral/blue productivity workspace.

The largest usability problem was the dashboard's hierarchy: metrics and reporting preceded the next action. Its actionable list also excluded overdue follow-ups, allowing an overdue count beside a misleading empty state.

Initial source-based Nielsen assessment (not a post-change score):

| Heuristic | Score / 4 | Initial finding |
|---|---:|---|
| Visibility of system status | 3 | Useful history and flashes; overdue list incomplete |
| Match with the real world | 2 | Familiar vocabulary; response-rate caption contradicted its calculation |
| User control and freedom | 2 | Cancel and confirmation available; edits require leaving the current view |
| Consistency and standards | 3 | Shared components, but inconsistent action treatments |
| Error prevention | 2 | Validation and confirmations; date completion has no undo |
| Recognition rather than recall | 2 | Pipeline omitted action/date context; rows hid activity when dated |
| Flexibility and efficiency | 1 | Stage changes required the complete edit form |
| Aesthetic and minimalist design | 2 | Large framing and repeated cards competed with tasks |
| Error recovery | 2 | Error summary had no field links or focus management |
| Help and documentation | 1 | Some hints, but unclear metric definitions |
| **Total** | **20 / 40** | **Significant improvements needed** |

### Priority findings and implemented response

1. **P1 — Daily actions were obscured.** Put follow-ups first, include overdue records before today's and upcoming dates, show timing counts and explicit overdue labels, and reuse the existing completion endpoint. Empty-state copy now reflects the same query as the list.
2. **P1 — Routine updates required excessive scanning.** Added a focused stage/date form on application detail using the existing update action and history service. Pipeline cards now show activity and follow-up dates and link directly to the existing stage-edit section.
3. **P1 — Responsive and accessibility defects.** Replaced the low-contrast mobile navigation with a native disclosure menu, wrapped filters, reflowed the semantic application table into labelled phone rows, increased operational text and touch targets, restored input focus styles, and linked validation errors to invalid fields through a small Stimulus controller.
4. **P2 — Visual design drift.** Applied the specified background, white surfaces, neutral borders, blue accents, compact sans-serif hierarchy, tabular metrics, restrained radii, and consistent spacing. Removed the gradient, backdrop blur, dark sidebar, ornamental section numbers, and redundant section labels. The existing Inter/Geist-first font stack retains system fallbacks without introducing a remote font dependency.
5. **P2 — Misleading metric copy.** Preserved the response-rate calculation and added its actual definition. Added a modest four-week activity bar chart based on application dates; its query remains scoped to the signed-in user. Analytics navigation links to this Overview section, preserving routes.

### Cognitive load and personas

The initial composition put five metrics and pipeline reporting before actionable records. The application form exposed fourteen fields. Familiar labelled navigation and grouped forms helped, but small operational text and repeated context switching increased the burden on distracted phone users, keyboard users, and people updating multiple roles.

The refinement gives returning users their next step first, makes dates and stages recognizable without opening every record, and supports error recovery with keyboard focus. Existing full forms and business workflows are preserved. Bulk actions, shortcuts, drag-and-drop, undo/history for completed follow-ups, and progressive disclosure of optional form fields remain outside this refinement.

## Verification

- Rails: **61 tests, 278 assertions, zero failures or errors**.
- RuboCop: **75 files inspected, no offenses**.
- Browser workflows: **2 tests, 26 assertions, zero failures or errors**, covering the existing account/company/application/notes/follow-up/search flow and the new phone menu, validation focus, and focused stage update.
- This machine's Chrome 158 rejects Capybara 3.40's wildcard storage-clear request during test teardown. The normal browser command completed all assertions but raised cleanup errors. A temporary preload selected Capybara's existing standard reset path for verification; it was removed afterward. No dependency or permanent test-driver change was added.
- Chrome visual checks covered the overview, application table, application detail, pipeline, creation form, and companies across desktop, 780px tablet, and 390px phone layouts. Page-width measurements showed no page-level horizontal overflow; wide tables and pipeline boards scroll within their containers.
- The initial deterministic detector returned `[]` (exit 0). Manual review additionally identified low-contrast mobile links, small pipeline text, a missing note-date focus style, tablet filter risk, and an authentication grid whose former minimum widths exceeded its breakpoint. These informed the shared CSS fixes.
- New query tests check overdue ordering, closed/private record exclusion, and application-date weekly counts. The focused stage test checks that company, notes, and location survive the update and stage history is recorded.

## Run notes

Context loading was attempted once and initially failed because the engine/cache was unavailable. Existing project context and the Impeccable critique, operate, polish, and craft-floor references were read directly. The independent detector attempt subsequently succeeded. No ignore list existed. No browser overlay was injected because the available evaluate API is read-only. No visible overlay is claimed. Visual verification used Chrome screenshots and DOM measurements; the original-source assessments were not live-browser assessments.

The critique is archived here rather than as a live detector backlog. No historical trend was available. Temporary preview servers and the test compatibility preload were removed. Test screenshot artifacts remain in ignored `tmp/screenshots` for review. Routes, database models, account ownership boundaries, authentication, and backend integrations were preserved. No packages were added.

Questions skipped: the user explicitly authorized implementation using DESIGN.md, so the refinement proceeded within that scope.
