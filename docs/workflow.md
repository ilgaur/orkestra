# Design System & Workflow

> The design system, Figma workflow, and the bridge between design and code.
>
> For agent methodology and code conventions, see `docs/AGENTS.md`.
> For token theory (two-tier colors, variables vs styles), see `docs/design-system.md`.
> For Figma MCP tools and file hygiene, see `docs/figma-mcp.md`.
> For the full discover → design → code loop, see `docs/agentic-design.md`.

---

## Phase 0: Visual Identity (before tokens exist)

> Skip this section when tokens and Figma variables already exist.
> This is the bridge from **unstructured inspiration** to **concrete design foundations**.
> Canonical token theory lives in `docs/design-system.md`; this section covers only the
> bootstrapping **process**.

### The sequence

1. **Collect references** — mood boards, screenshots, competitor UI, typography
   samples, color palettes. Store them on the Figma **Mood and direction** page.
   Agent can read these via `get_screenshot` on the mood page nodes.
2. **Extract brand adjectives** — distill references into **three** adjectives that
   drive every visual decision. Record in `product/discovery.md` § Brand adjectives.
   Example: _sleek, sexy, fun_.
3. **Derive palette** — from references + adjectives, propose a primitive color
   scale (neutrals, primary hue, accent, status colors). Create a **Primitives**
   variable collection in Figma with HSL values. Then create a **Semantic**
   collection that aliases primitives (`primary`, `foreground`, `background`,
   `muted`, `destructive`, `status-*`). Follow naming rules in
   `docs/design-system.md`.
4. **Choose typefaces** — one sans-serif for UI, one monospace for technical
   values. Load in Figma and define text styles. Record the pair in
   `docs/design-system.md` § Typography.
5. **Set spatial decisions** — border radius (sharp/boxy → small radii; soft →
   large radii), spacing base (default 8 px), elevation philosophy (flat vs
   layered). Create Figma number variables for `radius`, `spacing-*`. Record
   rationale in `docs/design-system.md`.
6. **Create Figma variables** — populate the **Tokens** page with a visual
   reference of all collections and modes (light/dark if applicable). Use
   `use_figma` via the **figma-orchestration** skill (load **figma-use** first).
7. **Mirror to code** — define CSS custom properties in `assets/css/app.css`
   and map them in `tailwind.config.js`. Follow sync rules in
   `docs/design-system.md` § "When tokens change."

After Phase 0 completes, the three layers below take over.

### When the user shares reference images

When a user provides screenshots, Figma links, or mood board references:

1. **Read the mood board** — use `get_screenshot` on the Figma mood page or
   view the provided images directly.
2. **Cross-reference with brand adjectives** in `product/discovery.md`. If no
   adjectives exist yet, run the product-discovery socratic checklist first.
3. **Propose concrete decisions** — suggest palette, typeface, radius, and
   spacing that match the references AND the adjectives. Present 2–3 options
   with tradeoffs.
4. **Wait for approval** before creating Figma variables or Tailwind tokens.
   Never silently derive a full palette from a screenshot.
5. **Execute** — follow steps 3–7 of the sequence above.

### Agent enforcement (Phase 0)

- Do **not** create Figma variable collections without brand adjectives in
  `product/discovery.md`. If missing, ask first.
- Do **not** pick typefaces, palette, or radius without proposing alternatives.
- Do **not** skip the Figma Tokens page — variables must exist in Figma before
  `tailwind.config.js`.
- Log every Phase 0 decision in `product/discovery.md` § Decisions log.

---

## Design System — Three Layers, Built in Order

### Layer 1: Design Tokens

Token theory (two-tier model, naming conventions, Figma variable collections,
CSS custom properties) lives in **`docs/design-system.md`** — that is the
canonical source. This section covers only the **process** of working with tokens.

Tokens exist in two synchronized places: **Figma Variables** and
**tailwind.config.js**. When one changes, the other must update. Follow the
sync process in `docs/design-system.md` § "When tokens change."

**Build order:** primitives → semantic → component (optional). Never create a
component before its tokens exist.

### Layer 2: Components

Components are built FROM tokens. See `docs/frontend.md` for the three-layer
component architecture (`ui/` → `domain/` → `interactive/`).

**Component lifecycle:**

1. Need identified (a page needs a button, a badge, a card).
2. Check: does this already exist in `components/ui/`?
   - Yes → use it, customize via variant/size/class assigns.
   - No → design it in Figma first (even roughly), then build it.
3. Design in Figma using only Figma Variables for all values.
4. Build as a Phoenix function component using only Tailwind token classes.
5. Verify visual match between Figma and rendered component.

### Layer 3: Patterns & Pages

Patterns are recurring arrangements of components (form layout, data table
with filters, detail page with tabs). Pages compose patterns and components.

Don't pre-design patterns. Build pages, notice repetition, extract the pattern.

---

## Figma MCP (summary)

The Figma MCP server connects the canvas to the agent for **read** (design context,
screenshots, variables) and **write** (`use_figma` with the figma-use skill). Canonical
tool matrix, layer hygiene, Code Connect, and parity rules live in
**`docs/figma-mcp.md`**. Every production file must appear in **`product/figma.md`**.

---

## The Design-to-Code Process

### 1. Start in Figma (even roughly)

You need: layout structure, which tokens are used, and which components are
reusable. A rough wireframe with your tokens beats a detailed mockup with
random values.

### 2. Share with the agent

Select the frame in Figma. Reference the link or use selection-based MCP.
Tell the agent: "Implement this design" or "Build this as a function component."

### 3. Agent reads design context via MCP

See `docs/figma-mcp.md` for the tool pipeline. Combined with `docs/frontend.md`
rules, the agent generates function components, LiveView pages, and proper
`attr`/`slot` declarations — all using semantic token classes.

### 4. Review

- Does it use existing components from `components/ui/`?
- Does it use token classes, not hardcoded values?
- Does the structure follow ui → domain → interactive?
- Is the LiveView thin?

### 5. Reflect changes back

When code-side changes are meaningful (spacing, color, layout), update the
Figma design to stay in sync.

### 6. Extract and systematize

After a few pages, patterns emerge. A card used three times → extract to
`ui/`. A form pattern that repeats → reusable form component. The design
system grows from real usage, not speculation.

---

## Agent Design Enforcement

### Before building any UI, the agent MUST:

1. Check existing components in `components/ui/`. Use what exists.
2. Verify colors, spacing, and typography are defined in `tailwind.config.js`. If a value is missing, ask before adding it.
3. Check Figma design context via MCP if available.

### When building a new component, the agent MUST:

1. Determine the correct layer: `ui/` (generic), `domain/` (domain-aware), or `interactive/` (needs hooks).
2. Define all `attr` declarations with types, defaults, and allowed values.
3. Accept a `class` assign for styling overrides.
4. Use only Tailwind token classes.

### When building a page, the agent MUST:

1. Compose from existing components. Pages are arrangements, not raw HTML.
2. Build missing components FIRST, then the page.
3. Keep business logic out of templates.
4. Subscribe to relevant PubSub topics.

### The agent must REFUSE to:

- Bypass token-only styling (per `docs/design-system.md`).
- Duplicate an existing component.
- Skip `attr`/`slot` declarations on function components.

---

## Development Increments

A single increment should be ONE of:

- New design tokens in both Figma and Tailwind config.
- A new function component (one file, one concern).
- A new LiveView page composing existing components.
- A new context function + schema + migration + tests.
- A new Oban worker + its tests.

If touching more than 5 files, break it down.

---

## Code Review — Design Checklist

Before considering UI work complete:

- [ ] All colors use token classes (`bg-primary`, not `bg-blue-500`).
- [ ] All spacing uses Tailwind scale (`p-4`, `gap-6`, not `p-[17px]`).
- [ ] New tokens added to BOTH Tailwind config AND noted for Figma sync.
- [ ] Existing components reused where applicable.
- [ ] New components have `attr`/`slot` declarations.
- [ ] `stream` used for lists, `phx-debounce` on inputs.
- [ ] Interactive elements keyboard accessible.
- [ ] `motion-safe:` on animation classes.
