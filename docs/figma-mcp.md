# Figma MCP — Deterministic Tool Use

> How agents use the official Figma MCP server with this repo. Read this before any
> design-to-code or code-to-Figma task.
>
> Context: [Design systems and AI: Why MCP servers are the unlock](https://www.figma.com/blog/design-systems-ai-mcp/),
> [Design context, everywhere you build](https://www.figma.com/blog/design-context-everywhere-you-build/),
> [Why you should care about design context](https://www.figma.com/blog/why-you-should-care-about-design-context/).

---

## Quick start (for agents)

| Direction | Load these | Prereq |
|---|---|---|
| **Figma → Code** | This doc + skill `figma-to-liveview` | Frame registered in `product/figma.md` |
| **Code → Figma** | This doc + skill `figma-orchestration` | Load **figma-use** skill before every `use_figma` call |
| **Verify parity** | `get_screenshot` after changes | — |

All production files must be in `product/figma.md`. If not listed, register first.

---

## Canonical file registry

All production Figma files **must** be listed in `product/figma.md` with `file_key`, URL,
and owner page names. If a link is not in that file, treat it as **non-canonical** until
registered.

---

## MCP tools — when to use which

| Tool | Use when | Notes |
|---|---|---|
| **whoami** | Need `planKey` to create a file; verify auth. | First step before `create_new_file` if plan unknown. |
| **create_new_file** | New blank Design or FigJam file in team drafts. | Then continue with `use_figma` using returned `file_key`. |
| **get_design_context** | Implement a **specific frame or node** in code. | Requires file link (remote) or selection (desktop). Output is **reference** — adapt to LiveView. |
| **get_metadata** | Large file; need structure only before targeted reads. | Sparse XML; then call `get_design_context` on chosen ids. |
| **get_screenshot** | Verify layout, contrast, cropping after changes. | Use after substantive `use_figma` writes. |
| **get_variable_defs** | List tokens used in selection. | Align names with `docs/design-system.md`. |
| **use_figma** | **Create, edit, delete** nodes, variables, components. | **STOP: Load the `figma-use` skill before calling this tool. Every time.** Pass `description` + `skillNames`. |
| **search_design_system** | Reuse library components before drawing new ones. | Prefer import over redraw. |
| **create_design_system_rules** | Generate agent rule file from codebase. | Save only if reviewed; avoid duplicate of `docs/design-system.md`. |

Do **not** use `figma.notify` in plugin scripts (unsupported in this runtime).

---

## File hygiene (for better AI output)

From Figma’s design-context guidance:

1. **Frames per breakpoint** when layout meaningfully differs.
2. **Auto layout** on lists, rows, and grids; document responsive intent.
3. **Clean layer tree** — no deep empty groups; meaningful names (`PrimaryButton`, not `Frame 412`).
4. **Annotations** for interaction: hover, disabled, loading, data-bound copy.

---

## Design → LiveView pipeline

1. Confirm frame is registered in `product/figma.md`.
2. `get_metadata` if the page is large; else `get_design_context` on the target node.
3. Map variables to **semantic** Tailwind tokens (never copy hex into HEEx as permanent).
4. Reuse `components/ui/*` and `components/domain/*` per `docs/frontend.md`.
5. After implementation, update spec or `product/discovery.md` if scope shifted.

---

## LiveView → Figma (when pushing UI back)

1. Prefer tokens and component names that already exist in Figma.
2. Use `use_figma` in small steps; **return node ids** from each script.
3. `get_screenshot` to validate.

---

## Code Connect

When available, map Figma components to Phoenix function components so MCP returns
**your** component names. Progressive mapping beats big-bang.

---

## Rate limits and beta

Figma MCP is evolving. If a tool fails, retry with a smaller scope; check Figma status.
Prefer **incremental** `use_figma` scripts over monolithic writes.
