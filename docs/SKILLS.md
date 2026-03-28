# Agent Skills — When to Use What

> Repo-local skills live in `.agents/skills/<name>/SKILL.md`. **Cursor**, **Claude Code**,
> and **Codex** all resolve the same tree: `.claude/skills` and `.codex/skills` are
> symlinks to `.agents/skills` (see `AGENTS.md` — Multi-client agents). Edit skills only
> under `.agents/skills/`.
>
> Cursor also uses `.cursor/rules/*.mdc` for globs and auto-attached guidance; that is
> complementary to skills, not a second skill store.
>
> Curated skills from [openai/skills](https://github.com/openai/skills/tree/main/skills/.curated)
> can be installed with Codex `$skill-installer <name>` when you want the **upstream**
> copy. This repo keeps **adapted** skills so Phoenix LiveView and Orkestra conventions
> stay authoritative.

---

## Multi-client alignment (enforced)

| Client | Instructions | Skills |
|--------|----------------|--------|
| **Cursor** | Root `AGENTS.md`, `docs/AGENTS.md`, etc.; optional `CLAUDE.md` symlink for parity | `.agents/skills/`, `.cursor/skills/` if present, plus `.claude/skills` / `.codex/skills` symlinks ([Cursor skills](https://cursor.com/docs/context/skills)) |
| **Claude Code** | **`CLAUDE.md` → `AGENTS.md`** per directory (symlink); edit `AGENTS.md` only | `.claude/skills` → `.agents/skills` |
| **Codex** | Same markdown as Cursor; reads repo `.agents/skills` from the git root ([Codex skills](https://developers.openai.com/codex/skills/)) | `.codex/skills` → `.agents/skills`; user-level `~/.codex/skills` for extras (e.g. `$skill-installer figma-use`) |

**`figma-use`:** Mandatory before `use_figma` (see **figma-orchestration**). Install via
Cursor Figma plugin cache or Codex `$skill-installer` so every client that runs write
tools has access.

---

## Decision tree (load one path, not all)

```
Are you changing product meaning, pricing, or positioning?
  → product-discovery + product/discovery.md + product/README.md

Are you writing to Figma (create nodes, variables, components)?
  → figma-orchestration + load figma-use (Cursor plugin) before use_figma

Are you reading Figma to implement UI in code?
  → figma-to-liveview + docs/figma-mcp.md + docs/frontend.md

Are you improving visual taste, hierarchy, motion (no Figma yet)?
  → frontend-design

Are you defining tokens, naming, or two-tier color model?
  → docs/design-system.md (canonical)

Are you verifying the running app in a real browser (console, network, layout)?
  → browser-verification + docs/chrome-devtools-mcp.md (MCP must be installed)
```

---

## Repo-local skills (canonical for Orkestra)

| Skill | Path | Trigger |
|---|---|---|
| **frontend-design** | `.agents/skills/frontend-design/SKILL.md` | Any visually-led UI work in LiveView / HEEx / Tailwind. |
| **figma-orchestration** | `.agents/skills/figma-orchestration/SKILL.md` | Creating or editing Figma files via MCP (`use_figma`, new file, variables). |
| **figma-to-liveview** | `.agents/skills/figma-to-liveview/SKILL.md` | Implementing a frame or component from Figma into Phoenix. |
| **product-discovery** | `.agents/skills/product-discovery/SKILL.md` | Shaping product, business model, scope; socratic questions; update `product/discovery.md`. |
| **browser-verification** | `.agents/skills/browser-verification/SKILL.md` | Real Chrome session via Chrome DevTools MCP after UI/hook/asset changes. |

---

## Cursor rules (auto-context)

| Rule | Path | When it attaches |
|---|---|---|
| **frontend-design** | `.cursor/rules/frontend-design.mdc` | `live/`, `components/`, `assets/`, `*.heex`, etc. |
| **design-process** | `.cursor/rules/design-process.mdc` | Product, design docs, Figma registry (see file globs). |

---

## Upstream curated skills (optional installs)

Use `$skill-installer` in Codex when you want OpenAI’s maintained copy. Prefer **repo-local**
skills first so LiveView and `docs/` stay the source of truth.

| Upstream skill | Use when | Notes |
|---|---|---|
| [frontend-skill](https://github.com/openai/skills/tree/main/skills/.curated/frontend-skill) | Generic web taste | We already adapted this as **frontend-design**. |
| [figma-use](https://github.com/openai/skills/tree/main/skills/.curated/figma-use) | Before every `use_figma` call | **Mandatory** for writes; load from Cursor plugin cache or install. |
| [figma-implement-design](https://github.com/openai/skills/tree/main/skills/.curated/figma-implement-design) | Full frame → code | Complement **figma-to-liveview**; stack is HEEx not React. |
| [figma-generate-design](https://github.com/openai/skills/tree/main/skills/.curated/figma-generate-design) | Code → Figma | Use with MCP `generate_figma_design` where supported. |
| [figma-create-design-system-rules](https://github.com/openai/skills/tree/main/skills/.curated/figma-create-design-system-rules) | Agent rules from codebase | Run MCP tool; save output under `.cursor/rules/` if useful. |

Do not install skills that target stacks we do not use (e.g. **aspnet-core**, **winui-app**)
unless you have a concrete need.

---

## Agent loading discipline

1. **Progressive disclosure:** Read skill `description` first; full `SKILL.md` only when the task matches.
2. **One primary skill** per task; add a second only when design + product both change.
3. **Canonical docs beat skill text** if they conflict; fix the skill in the same change.

---

## Frustration quick answers

| Feeling | Response |
|---|---|
| Too many docs | Use **`docs/day-one.md`** — one row in its table. |
| Agent won’t stop asking product questions | Say **“exploration only, defer discovery.”** See strictness phases in `docs/agentic-design.md`. |
| Figma not ready | Allowed in exploration; log **Design debt** in `product/discovery.md`. |
| Unsure which skill | Only the **decision tree** at the top of this file — ignore the tables until needed. |
| Chrome MCP not connecting | See **Requirements** and **Install** in `docs/chrome-devtools-mcp.md`; confirm Node 20+ and Chrome Beta path. |
