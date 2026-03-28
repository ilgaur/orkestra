---
name: figma-orchestration
description: Use when creating, editing, or organizing Figma files via MCP (use_figma, create_new_file, variables, components, frames). Do not use for read-only codegen from a link — use figma-to-liveview instead.
---

# Figma Orchestration (Orkestra)

## Before anything

1. Read `product/figma.md`. The target file must be **registered** or you register it in the same session after `create_new_file`.
2. Read `docs/figma-mcp.md` for the tool matrix.

## Writes (`use_figma`)

- Load the **figma-use** skill from your environment (Cursor plugin cache or Codex-installed skill) **before** every `use_figma` call.
- Pass a clear `description` and `skillNames` including `figma-use` as required by the client.
- Work **incrementally**: small scripts, return node ids, validate with `get_metadata` or `get_screenshot`.
- Never use `figma.notify`.

## New files

- Call `whoami` if `planKey` is unknown.
- `create_new_file` → append row to `product/figma.md` with `file_key` and URL.

## Creating variable collections from brand decisions

When the Figma **Tokens** page is empty and no variable collections exist, follow
`docs/workflow.md` § Phase 0 to bootstrap. The short version:

1. Confirm **brand adjectives** exist in `product/discovery.md`. If not, run the
   product-discovery socratic checklist first — do not guess a palette.
2. Create a **Primitives** collection (color scales in HSL, spacing base, radii).
   Use `docs/design-system.md` for naming rules.
3. Create a **Semantic** collection that aliases primitives (`primary`,
   `foreground`, `background`, `muted`, `destructive`, `status-*`).
4. Optionally set up modes (light/dark) as collection modes.
5. Use `get_variable_defs` to verify collections after creation.
6. Populate the **Tokens** page with a visual reference frame showing all
   variables (color swatches, spacing scale).
7. Mirror to `assets/css/app.css` + `tailwind.config.js` per
   `docs/design-system.md` § "When tokens change."

Each step is a separate `use_figma` call (load **figma-use** first). Validate
with `get_metadata` / `get_screenshot` between steps.

## Systematic layout

- Auto layout for responsive intent; meaningful layer names; annotations for interaction.
- Prefer `search_design_system` before inventing a new component.

## After changes

- Update `product/figma.md` sync note.
- If tokens changed, align `docs/design-system.md` and (when the app exists) CSS/Tailwind.
