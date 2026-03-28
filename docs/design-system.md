# Design System Foundations

> Canonical rules for tokens, naming, and parity between Figma and Phoenix.
> Companion to `docs/workflow.md` (process) and `docs/frontend.md` (components).

This document encodes practices aligned with a **two-tier token model** (primitives →
semantic aliases), Figma variables, and team-scale maintainability. See also
[Maxime Heckel — Building a design system from scratch](https://blog.maximeheckel.com/posts/building-a-design-system-from-scratch/),
[Figma — Design system 102](https://www.figma.com/blog/design-systems-102-how-to-build-your-design-system/),
and [Figma best practices](https://www.figma.com/best-practices/).

---

## Two-tier color system (code)

**Tier 1 — Primitives:** raw HSL components or scales (e.g. `--blue-50` through `--blue-90`).
Components must **not** reference these directly in HEEx.

**Tier 2 — Semantic:** aliases used in UI (e.g. `--primary`, `--foreground`, `--status-running`).
Tailwind theme maps **semantic** names to CSS variables. When the brand shifts, you change
the alias, not every component.

```css
/* Tier 1: primitives in :root (example). */
/* Tier 2: semantic — components use these via Tailwind. */
:root {
  --primary: 221 83% 53%;
  --foreground: 222 47% 11%;
}
```

---

## Figma variables and styles

- **Variables** — single values (color, number, string). Use for spacing scale, radii,
  semantic colors, and modes (light/dark).
- **Styles** — complex fills (gradients), combined text styles, effects. Use when a
  single variable is not enough.

Organize variable **collections** roughly as: `Primitives` → `Semantic` (per
[Figma 102](https://www.figma.com/blog/design-systems-102-how-to-build-your-design-system/)).

**Naming:** prefer purpose over appearance (`destructive` not `red-500`). Align names
with CSS custom properties and Tailwind keys so MCP and humans see one vocabulary.

---

## Spatial system

- Default spacing base: **8px** (divisible breakpoints; common in design systems).
- Map to Tailwind scale and Figma number variables consistently (e.g. `4` → 16px if that
  is your scale; document the mapping once in `product/figma.md` when the app exists).

---

## Typography

- Establish a **type scale** (e.g. display, title, body, caption) with defined sizes and
  line heights.
- Figma text styles should mirror what you encode in Tailwind (`font-sans`, tokenized sizes).
- Minimum body size: respect readability and WCAG; test contrast for semantic colors.

---

## Elevation and hierarchy

Use shadow, surface, and border tokens sparingly. **Operational UI** (dashboards) favors
calm surfaces; reserve strong elevation for modals, popovers, and primary focus.

---

## Accessibility (non-negotiable)

- Contrast: check semantic text on semantic backgrounds; use plugins or MCP annotations
  for intent.
- Do not rely on color alone for state; pair with text, icon, or pattern.
- Motion: respect `prefers-reduced-motion` (`motion-safe:` / `motion-reduce:` in Tailwind).

---

## Components and variants

- **Variants** in Figma map to **explicit `attr` values** in function components — no ad-hoc
  string styling in HEEx.
- One Figma component ↔ one Phoenix module when possible; document exceptions in
  `product/figma.md`.

---

## Cohesion and “craft”

Cohesive does not mean boring. **Sexy** here means: confident hierarchy, restrained palette,
intentional motion, and typography that fits the product — not more gradients and cards.
If a visual idea is not tied to a token or a component rule, it does not ship until it is.

---

## When tokens change

1. Update Figma variables (or styles).
2. Update `assets/css/app.css` and `tailwind.config.js` (when the app exists).
3. Update `product/figma.md` “Last synced” note.
4. If the change is architectural, add a short ADR under `docs/decisions/`.
