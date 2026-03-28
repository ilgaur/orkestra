---
name: frontend-design
description: Use when building or improving UI — LiveView pages, function components, layouts, or any visually-led frontend work. Enforces restrained composition, strong hierarchy, cohesive design tokens, and tasteful motion while avoiding generic card grids, weak branding, and UI clutter. Adapted for Phoenix LiveView and Tailwind CSS.
---

# Frontend Design Skill

Use this skill when the quality of the work depends on art direction, hierarchy,
restraint, imagery, and motion rather than component count.

Goal: ship interfaces that feel deliberate, premium, and current. Default toward
award-level composition: one big idea, strong imagery, sparse copy, rigorous
spacing, and a small number of memorable motions.

## This Project's Stack

This is a Phoenix LiveView application. All frontend guidance must respect:

- **Phoenix LiveView** for all page state, data flow, and server-driven UI.
- **HEEx templates** with function components (`attr`, `slot`, `~H` sigil).
- **Tailwind CSS** with design tokens defined in `tailwind.config.js` and CSS custom properties.
- **LiveView.JS** (`Phoenix.LiveView.JS`) for client micro-interactions (show/hide, transitions, class toggles).
- **Colocated hooks** (LiveView 1.1) for third-party JS libraries (charts, terminals, maps).
- **No React, no Framer Motion.** Motion is CSS transitions + LiveView.JS + occasional hook-based animation.
- Component layers: `ui/` (primitives) → `domain/` (composed) → `interactive/` (stateful with hooks).
- All colors, spacing, and typography use token classes from `tailwind.config.js`. No raw values.

See `docs/frontend.md` (components — includes **Growing the component tree**),
`docs/design-system.md` (tokens), `docs/workflow.md` (process), `docs/figma-mcp.md` (MCP),
`docs/agentic-design.md` (loop), and `docs/day-one.md` (when not to load everything).

If `components/ui/` is crowded, **proactively** suggest subfolders or namespaces per
`docs/frontend.md` and offer a minimal ADR.

## Working Model

Before building a page or significant UI, write three things:

- **Visual thesis:** one sentence describing mood, material, and energy.
- **Content plan:** what each section of the page does (hero, support, detail, action).
- **Interaction thesis:** 2–3 motion ideas that change the feel of the page.

Each section gets one job, one dominant visual idea, and one primary takeaway or action.

## Beautiful Defaults

- Start with composition, not components.
- Prefer a full-bleed hero or full-canvas visual anchor on marketing surfaces.
- Make the brand or product name the loudest text.
- Keep copy short enough to scan in seconds.
- Use whitespace, alignment, scale, cropping, and contrast before adding chrome.
- Limit the system: two typefaces max, one accent color by default.
- Default to cardless layouts. Use sections, columns, dividers, lists, and media blocks instead.
- Treat the first viewport as a poster, not a document.

## App UI — The Primary Mode

This is a cloud infrastructure platform. Most pages are operational dashboards,
not marketing pages. Default to Linear-style restraint:

- Calm surface hierarchy.
- Strong typography and spacing.
- Few colors — lean on `foreground`, `muted-foreground`, and one `primary` accent.
- Dense but readable information.
- Minimal chrome.
- Cards only when the card IS the interaction (e.g., a cluster card you click into).

Organize app surfaces around:

- Primary workspace (the main content area).
- Navigation (sidebar or top nav).
- Secondary context or inspector (detail panels, slide-overs).
- One clear accent for action or state.

Avoid:

- Dashboard-card mosaics.
- Thick borders on every region.
- Decorative gradients behind routine product UI.
- Multiple competing accent colors.
- Ornamental icons that do not improve scanning.

If a panel can become plain layout without losing meaning, remove the card treatment.

## Utility Copy For Product UI

When building dashboards, admin tools, or operational workspaces:

- Prioritize orientation, status, and action over promise, mood, or brand voice.
- Start with the working surface: KPIs, charts, filters, tables, status, or task context.
- Section headings say what the area IS or what the user can DO there.
- Good: "Clusters", "Recent Deployments", "Resource Usage", "Team Members".
- Bad: "Your Infrastructure Journey", "Unleash Your Cloud Potential".
- Supporting text explains scope, behavior, freshness, or decision value in one sentence.
- If a sentence could appear in a homepage hero or ad, rewrite it for product UI.
- If a section does not help someone operate, monitor, or decide, remove it.
- Litmus: if an operator scans only headings, labels, and numbers, can they understand the page immediately?

## Landing Pages

When building marketing or landing pages (not the app itself), use this sequence:

1. **Hero:** brand, promise, CTA, and one dominant visual.
2. **Support:** one concrete feature, offer, or proof point.
3. **Detail:** atmosphere, workflow, product depth, or story.
4. **Final CTA:** convert, start, visit, or contact.

Hero rules:

- One composition only.
- Full-bleed image or dominant visual plane.
- Brand first, headline second, body third, CTA fourth.
- No hero cards, stat strips, logo clouds, pill clusters, or floating dashboards.
- Keep headlines to ~2–3 lines on desktop, readable in one glance on mobile.
- All text over imagery must maintain strong contrast and clear tap targets.

If the first viewport still works after removing the image, the image is too weak.
If the brand disappears after hiding the nav, the hierarchy is too weak.

## Imagery

Imagery must do narrative work.

- Prefer in-situ photography over abstract gradients or fake 3D objects.
- Choose or crop images with a stable tonal area for text overlay.
- Do not use images with embedded signage, logos, or typographic clutter fighting the UI.
- If multiple moments are needed, use multiple images, not one collage.

The first viewport needs a real visual anchor. Decorative texture is not enough.

## Copy

- Write in product language, not design commentary.
- Let the headline carry the meaning.
- Supporting copy should usually be one short sentence.
- Cut repetition between sections.
- Do not include prompt language or design commentary in the UI.
- Give every section one responsibility: explain, prove, deepen, or convert.

If deleting 30% of the copy improves the page, keep deleting.

## Motion — LiveView.JS + CSS

Use motion to create presence and hierarchy, not noise.

Ship at least 2–3 intentional motions for visually-led work:

- One entrance sequence (CSS `@keyframes` or LiveView.JS transition on mount).
- One scroll-linked, sticky, or depth effect (hook-based if complex).
- One hover, reveal, or layout transition that sharpens affordance (LiveView.JS or CSS `:hover`).

Implementation guide for our stack:

- **Simple transitions:** Use `Phoenix.LiveView.JS` — `JS.show/hide` with transition tuples.
- **CSS transitions:** Use Tailwind `transition-*`, `duration-*`, `ease-*` classes.
- **Entrance animations:** Use CSS `@keyframes` with Tailwind `animate-*` classes.
- **Complex motion:** Use a colocated hook with GSAP or a lightweight animation library.
- **Scroll effects:** Use an `IntersectionObserver` in a hook.
- Always wrap motion in `motion-safe:` Tailwind variant to respect `prefers-reduced-motion`.

```elixir
# LiveView.JS transition example.
def show_panel(js \\ %JS{}, id) do
  js
  |> JS.show(
    to: "##{id}",
    transition: {"ease-out duration-300", "opacity-0 translate-y-2", "opacity-100 translate-y-0"}
  )
end
```

Motion rules:

- Noticeable in a quick recording.
- Smooth on mobile.
- Fast and restrained (200–400ms for most transitions).
- Consistent across the page.
- Removed if ornamental only.

## Hard Rules

- No cards by default. Cards only when they represent an interactive entity.
- No more than one dominant idea per section.
- No section should need many tiny UI devices to explain itself.
- No headline should overpower the brand on branded pages.
- No filler copy.
- No more than two typefaces without a clear reason.
- No more than one accent color unless the design system requires it.
- No raw color values — every color comes from the design token system.
- No custom CSS — Tailwind utilities only.
- Ensure every page works on both desktop and mobile.

## Reject These Failures

- Generic SaaS card grid as the first impression.
- Beautiful image with weak brand presence.
- Strong headline with no clear action.
- Busy imagery behind text.
- Sections that repeat the same mood statement.
- Carousel with no narrative purpose.
- App UI made of stacked cards instead of layout.
- Purple-on-white or dark-mode-only defaults.

## Litmus Checks

- Is the brand or product unmistakable in the first screen?
- Is there one strong visual anchor?
- Can the page be understood by scanning headlines only?
- Does each section have one job?
- Are cards actually necessary, or could layout alone work?
- Does motion improve hierarchy or atmosphere?
- Would the design still feel premium if all decorative shadows were removed?
- Does every color come from a token? Every spacing from the Tailwind scale?
