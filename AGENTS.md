# AGENTS.md — Project Constitution

> Read this FIRST on every session. Route to specific docs from the table below.

---

## Identity

A **cloud infrastructure platform** built as an **Elixir/Phoenix monolith**.
PostgreSQL is the only external dependency. Real-time updates, background jobs,
WebSocket, and presence all run inside the BEAM VM.

**Repo layers:**

| Layer | Purpose |
|---|---|
| `AGENTS.md` | Constitution — principles and routing |
| `docs/` | Engineering rules — architecture, backend, frontend, testing, design system, Figma MCP, agentic loop |
| `product/` | Product specification — discovery, Figma registry, domains, entities, workflows, specs |
| `external-references/` | Local-only scratch: cloned OSS, examples, notes (git-ignored except this folder's rules file) |

---

## Multi-client agents (Cursor, Claude Code, Codex)

The same repository is used from **Cursor**, **Claude Code**, and **Codex**. Paths below
are fixed; do not duplicate instructions into parallel files.

### Instructions (`AGENTS.md` and `CLAUDE.md`)

- **`AGENTS.md` is canonical** in every directory where it exists: repository root,
  `docs/`, `product/`, and `external-references/`.
- **`CLAUDE.md` is a symlink** to `AGENTS.md` in the same directory. Claude Code reads
  `CLAUDE.md`; **edit only `AGENTS.md`**. Never replace a `CLAUDE.md` symlink with a
  standalone copy — that would fork the rules.

### Skills

- **Canonical tree:** `.agents/skills/<name>/SKILL.md`.
- **`.cursor/skills`, `.claude/skills`, and `.codex/skills`** are all symlinks to
  `.agents/skills`. Add or change skills only under `.agents/skills/`.
- All three agents discover skills from `.agents/skills/` natively (Cursor also
  reads `.cursor/skills/`; Claude Code reads `.claude/skills/`; Codex scans
  `.agents/skills/` from CWD up to repo root). The symlinks ensure every path
  resolves to the same canonical files.

### MCP

- Each client loads **its own** MCP configuration (format differs per tool).
  All three configs are checked in and kept **semantically equivalent**:
  - **Cursor:** `.cursor/mcp.json` — Chrome DevTools (stdio). Figma via the
    official Figma plugin (`.cursor/settings.json`).
  - **Claude Code:** `.mcp.json` — Chrome DevTools (stdio) + Figma (HTTP remote).
  - **Codex:** `.codex/config.toml` — Chrome DevTools (stdio) + Figma (HTTP remote).
- **Figma** requires a one-time OAuth authenticate per machine in each client.
  See `docs/install/mcp-clients.md` for per-client setup commands.

### Cursor Rules

- `.cursor/rules/*.mdc` files are **Cursor-only** auto-trigger rules (glob-activated).
  They are thin pointers that reference canonical skills or docs — never duplicate
  the content. Claude Code and Codex do not have an equivalent feature; they rely
  on `AGENTS.md` and skills for the same coverage.

### Hooks (quality gates)

- **Shared scripts** live in `.quality/scripts/` (committed, not agent-specific).
  `check-all.sh` runs the full gate (`mix format`, Credo, Sobelow) at the end of
  an agent turn. `check-file.sh` runs lightweight per-file checks after edits.
- **Per-agent wiring** (format differs per tool, semantically equivalent):
  - **Cursor:** `.cursor/hooks.json` — `afterFileEdit` + `stop`.
  - **Claude Code:** `.claude/settings.json` — `PostToolUse` (Edit|Write) + `Stop`.
  - **Codex:** `.codex/hooks.json` — `PostToolUse` (Write) + `Stop`.
    Requires `codex_hooks = true` in `.codex/config.toml` (experimental).
- Scripts are **inert** until `mix.exs` exists (they exit 0 immediately if no
  Elixir project is detected).
- When changing hooks, update all three agent configs in the same change.

---

## Principles

1. **One language, one stack.** Elixir/Phoenix for everything. JS only for what the browser must own.
2. **Contexts are sacred boundaries.** LiveViews → Contexts → Ecto. Never skip a layer.
3. **Composition over complexity.** Small functions compose into larger ones. Decompose, don't add flags.
4. **Real-time is default.** PubSub for all state changes. Users never refresh.
5. **Tests are not optional.** Every context function, LiveView interaction, and worker gets tested.
6. **Progressive, not perfect.** Simplest version first. Add complexity only when the current approach fails.
7. **Stale docs are bugs.** If docs don't match code, fix them in the same change.
8. **External references are inputs, not truth.** Clone or park third-party code under `external-references/` (local-only), or discover comparable OSS via web search; use that to learn and compare — never as authority over `product/` or `docs/`. Stack fit must be explicit before literal reuse.
9. **Design is systematic.** Tokens, Figma variables, and code stay one vocabulary; no orphan hex in components. Custom UI must still obey the system.
10. **Figma is registered truth.** Production design files live in `product/figma.md`. MCP reads/writes target registered files unless exploring.
11. **Product is chiseled, not assumed.** Open questions live in `product/discovery.md`. Agents ask before inventing scope, personas, or business model.
12. **Cohesion is a feature.** Aim for deliberate, premium UI; agents refuse generic clutter and token bypass (see skills).
13. **Human intent wins explicit conflicts.** If you override a procedure, agents comply and record the tradeoff so docs can catch up — the system serves you, not the reverse.

---

## Context Router

**Overwhelmed?** Start with [`docs/day-one.md`](docs/day-one.md) — minimal read list per task.

**Doc ownership (one canonical source per topic):**

- **Token theory, naming, Figma variables:** `docs/design-system.md`
- **Component architecture, layers, LiveView patterns:** `docs/frontend.md`
- **Design-to-code process, enforcement checklists, Phase 0 bootstrapping:** `docs/workflow.md`
- **MCP tool matrix, file hygiene, Figma pipeline:** `docs/figma-mcp.md`
- **The loop, strictness phases, anti-stale matrix:** `docs/agentic-design.md`
- **Browser verification, Chrome DevTools MCP:** `docs/chrome-devtools-mcp.md`
- **Visual taste, composition, motion, copy:** `.agents/skills/frontend-design/SKILL.md`

When two docs say the same thing, the owner above is correct and the other
copy is a bug to fix.

| Working on... | Read these |
|---|---|
| Agent methodology, code conventions, git, doc hygiene, doc–design sync | `docs/AGENTS.md` |
| System overview, stack, data flow, project structure | `docs/architecture.md` |
| Business logic, contexts, schemas, PubSub, Oban | `docs/backend.md` |
| UI, components, LiveView pages, hooks, styling | `docs/frontend.md` |
| Writing or reviewing tests | `docs/testing.md` |
| Design system process, token workflow, design-to-code steps | `docs/workflow.md` |
| Token foundations, two-tier colors, Figma parity | `docs/design-system.md` |
| Figma MCP tools, file hygiene, design → LiveView | `docs/figma-mcp.md` |
| Agentic loop, socratic discovery, anti-stale matrix | `docs/agentic-design.md` |
| Chrome DevTools MCP, browser verification, Beta/isolated setup | `docs/chrome-devtools-mcp.md` |
| Product meaning, glossary, domains, capabilities | `product/README.md` |
| Open questions, hypotheses, positioning | `product/discovery.md` |
| Figma file registry (`file_key`, URLs) | `product/figma.md` |
| Product layer agent rules, spec lifecycle | `product/AGENTS.md` |
| Feature specs | `product/specs/` |
| Core entities | `product/entities/` |
| Business workflows | `product/workflows/` |
| Architecture decisions | `docs/decisions/` |
| Skill map, decision tree, optional upstream skills | `docs/SKILLS.md` |
| First session, low-friction paths, common frustrations | `docs/day-one.md` |
| Frontend design taste, composition, motion | `.agents/skills/frontend-design/SKILL.md` |
| Figma MCP writes and file setup | `.agents/skills/figma-orchestration/SKILL.md` |
| Implement Figma → LiveView | `.agents/skills/figma-to-liveview/SKILL.md` |
| Socratic product / business shaping | `.agents/skills/product-discovery/SKILL.md` |
| Browser verification after UI changes | `.agents/skills/browser-verification/SKILL.md` |
| MCP client installation (Cursor, Claude Code, Codex) | `docs/install/mcp-clients.md` |
| Local inspiration material | `external-references/AGENTS.md` |

**Routing discipline (agents enforce this):**

1. For a focused task, load **at most** the root `AGENTS.md` + one area doc + one skill.
   Use the table above or `docs/day-one.md` to pick the right path.
2. Do NOT pre-load docs "just in case." If you discover mid-task that another
   doc is needed, load it then — not at session start.
3. If two loaded docs say the same thing, the more specific doc wins and the
   general doc's copy is a bug. Flag it.
4. The full-context rule (read all 7 docs below) applies ONLY to product/ideation/
   cross-cutting conversations — never to focused implementation.

**Full-context rule — for product, ideation, or cross-cutting conversations** — when
the user is shaping what the product is, discussing architecture, or working across
multiple areas — **read ALL of the following before responding:**

1. `product/discovery.md` + `product/README.md` (what the product is and isn't)
2. `docs/architecture.md` (system shape)
3. `docs/design-system.md` + `docs/workflow.md` (design language and process)
4. `docs/frontend.md` (component architecture)
5. `docs/agentic-design.md` (the loop)
6. `.agents/skills/frontend-design/SKILL.md` (visual taste)
7. `.agents/skills/product-discovery/SKILL.md` (socratic process)

**If you skip these and ask a question the repo already answers, that's a bug in
your behavior, not a gap in the docs.**

**Multi-area tasks:** If the slice is large, read `docs/agentic-design.md` (short),
then `product/discovery.md` / `product/README.md` if product meaning moves, then
`docs/architecture.md`, then only the docs for layers you touch. For UI from Figma,
add `docs/figma-mcp.md` and `product/figma.md`. For a quick hack, see `docs/day-one.md`
instead of loading the full stack.

**Before finishing any task:** Check which docs are affected. Update or delete
affected docs before closing the work.

---

## Critical Reminders

- **Contexts are the API.** Never let LiveViews touch the database.
- **PubSub for all state changes.** Broadcast after every successful mutation.
- **Oban for background work.** Never `Task.async` for anything that must survive a crash.
- **Function components for UI.** LiveComponents only when the component owns its own state.
- **Tailwind config is the design token source.** Never hardcode colors, spacing, or type.
- **Figma registry stays current.** New or renamed files → `product/figma.md` in the same change batch.
- **Ask before inventing product truth.** Use `product/discovery.md` for unknowns.
- **Browser truth for UI.** When Chrome DevTools MCP is configured, use it to verify
  critical UI (console, network, layout) — see `docs/chrome-devtools-mcp.md`.
- **One concern per module.** If it does two things, split it.
- **Check existing components first.** Reuse beats rebuild.
- **Specs precede substantial features.** Write a spec in `product/specs/` before deep implementation.
- **The user is learning Elixir.** Explain concepts when they first appear. Teach through the work.
- **Claude Code entry is `CLAUDE.md`.** It mirrors `AGENTS.md` via symlink at each layer;
  keep them in sync by editing `AGENTS.md` only.
- **Agent configs stay equivalent.** When adding an MCP server, skill, or rule
  to one agent, add the equivalent for all three (Cursor, Claude Code, Codex)
  in the same change. See Multi-client agents section.
- **Quality hooks run automatically.** `mix format`, Credo, and Sobelow run via
  hooks at the end of each agent turn. Fix reported issues before declaring work
  complete. See `.quality/scripts/` for the shared gate scripts.
