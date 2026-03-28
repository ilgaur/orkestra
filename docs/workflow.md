# Design System & Workflow

> The design system, Figma workflow, and the bridge between design and code.
>
> For agent methodology and code conventions, see `docs/AGENTS.md`.
> For token theory (two-tier colors, variables vs styles), see `docs/design-system.md`.
> For Figma MCP tools and file hygiene, see `docs/figma-mcp.md`.
> For the full discover → design → code loop, see `docs/agentic-design.md`.

---

## Design System — Three Layers, Built in Order

### Layer 1: Design Tokens

Tokens are named values that define the visual language. They exist in two
synchronized places: **Figma Variables** and **tailwind.config.js**. When one
changes, the other must update.

**Token categories (build in this order):**

1. **Primitive tokens** — raw values, no semantic meaning:
   - Colors: `blue-500: #3B82F6`, `gray-900: #111827`
   - Spacing: `1: 4px`, `2: 8px`, `4: 16px`, `8: 32px`
   - Font sizes: `xs: 12px`, `sm: 14px`, `base: 16px`, `lg: 18px`
   - Border radius, shadows, line heights, font weights

2. **Semantic tokens** — tokens with meaning, referencing primitives:
   - `primary: blue-600`, `destructive: red-600`, `muted: gray-100`
   - `foreground: gray-900`, `muted-foreground: gray-500`
   - `status-running: green-500`, `status-failed: red-500`
   - These change between themes (light/dark). Primitives do not.

3. **Component tokens** (optional, add when needed):
   - `button-primary-bg: primary`, `button-primary-text: primary-foreground`
   - Only create when enough components justify the indirection.

**In Figma:** tokens are Variables organized into collections (Primitives, Semantic).

**In code:** tokens live in `assets/css/app.css` (CSS custom properties) and
`assets/tailwind.config.js` (maps Tailwind classes to those properties).

```css
/* assets/css/app.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222 47% 11%;
    --primary: 221 83% 53%;
    --primary-foreground: 210 40% 98%;
    --destructive: 0 84% 60%;
    --muted: 210 40% 96%;
    --muted-foreground: 215 16% 47%;
    --border: 214 32% 91%;
    --ring: 221 83% 53%;
    --radius: 0.5rem;
    --status-running: 142 71% 45%;
    --status-pending: 38 92% 50%;
    --status-failed: 0 84% 60%;
    --status-stopped: 215 16% 47%;
  }

  .dark {
    --background: 222 47% 11%;
    --foreground: 210 40% 98%;
    /* ... dark mode overrides ... */
  }
}
```

### Token rules

- Never use a raw color value in a component. Always use a token name.
- Never create a component before its tokens exist.
- Name tokens by purpose, not appearance: `destructive` not `red`, `primary` not `blue`.
- When adding a token in code, note that Figma needs the same token (and vice versa).

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
tool matrix, layer hygiene, and parity rules live in **`docs/figma-mcp.md`**. Every
production file must appear in **`product/figma.md`**.

**Code Connect:** map Figma components to Phoenix function components so MCP returns
your real `attr` / variant names. Add mappings incrementally.

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

Combined with `frontend.md` rules, the agent generates: function components,
LiveView pages composing existing components, Tailwind classes using token names,
proper `attr`/`slot` declarations.

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

- Use a raw color value when a token exists.
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
