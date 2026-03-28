# Agentic Design–Product–Code Loop

> End-to-end workflow for building Orkestra from scratch with agents: **discover**,
> **design**, **specify**, **implement**, **verify** — without doc drift.
>
> Reads: [Design systems from the basics to big things ahead](https://www.figma.com/blog/design-systems-from-the-basics-to-big-things-ahead/),
> [openai/skills curated](https://github.com/openai/skills/tree/main/skills/.curated).

---

## The loop (repeat every feature)

```
0. Visual identity   → brand adjectives, palette, type, spatial decisions
                        (docs/workflow.md Phase 0; skip if tokens already exist)
1. Product clarity   → product/discovery.md, product/README.md, maybe new spec
2. Figma intent      → tokens + components + frames (product/figma.md updated)
3. Spec acceptance   → product/specs/<feature>.md (draft → building)
4. Implementation    → contexts → LiveView → tests (docs/frontend.md, docs/backend.md)
5. Parity check      → Figma vs browser; tokens vs code; **Chrome DevTools MCP** on key routes when MCP is configured (`docs/chrome-devtools-mcp.md`)
6. Doc sync          → close the loop (matrix below)
```

Agents **stop** between steps when something is ambiguous — they ask; they do not guess
product or brand into existence.

---

## Strictness phases (avoid blocking day one)

**Exploration** — early scaffolding, learning Elixir, or Figma not wired yet:

- Tokens still required in code (no permanent raw hex in committed components).
- Figma parity can **lag one increment**: note intent in `product/discovery.md` under a
  “Design debt” bullet with a target date or follow-up issue.
- Full socratic checklist is **optional** if you explicitly ask for a thin slice.

**Production** — user-visible releases, multiple contributors, or paying users:

- Full loop: discovery → Figma (or ADR) → spec → code → matrix.
- No silent Figma drift: `product/figma.md` and tokens stay aligned.

Agents state which phase they are assuming; you correct in one sentence if wrong.

---

## User overrides

If you explicitly choose speed or a different shape (“skip spec”, “no Figma this PR”),
the agent complies, records the debt in `product/discovery.md` or the spec, and does
not treat docs as more important than your stated intent.

---

## Socratic questions (agent must use before big UI bets)

Ask the user **short, concrete** questions until answers land in `product/discovery.md`:

- **Who** is the primary user (role, skill level)?
- **Job to be done** in one sentence?
- **Differentiator** vs “another dashboard”?
- **Monetization hypothesis** (if any): who pays, for what unit?
- **Non-goals** for this slice?
- **Brand adjectives** (max three) — we translate to tokens, not vibes in code.

If the user cannot answer yet, record **Open questions** in `product/discovery.md` and
build only **non-committing** UI (layout shells, tokenized placeholders).

---

## Red lines (agent enforces)

- Token-only styling per `docs/design-system.md` — no raw hex, no arbitrary pixel classes.
- **Production phase:** no new public `ui/` component without Figma variable alignment
  **or** an explicit ADR. **Exploration phase:** allowed with a “Design debt” note in
  `product/discovery.md` naming what to sync later.
- No marketing copy on operational surfaces (per `frontend-design` skill).
- No closing a task with **stale** `product/figma.md`, `product/discovery.md`, or spec status.

---

## Anti-stale matrix (run before marking work complete)

| If you changed… | You must update… |
|---|---|
| Visual identity (palette, type, radius, spatial) | `product/discovery.md` brand adjectives + Figma variables + `docs/design-system.md` |
| Figma structure or new file | `product/figma.md` |
| Token semantics | `docs/design-system.md` note + Figma variables + (when app exists) CSS/Tailwind |
| User-visible behavior | `product/specs/*` status + acceptance examples |
| Domain language | `product/README.md` glossary |
| Architecture | `docs/architecture.md` or `docs/decisions/` |
| Component API | `docs/frontend.md` example or pointer to real file |

If a doc would only duplicate code, **replace** with a pointer to the canonical module
instead of letting two sources drift.

---

## Skill stack for this loop

| Phase | Skill(s) |
|---|---|
| Visual identity (Phase 0) | **product-discovery** + **figma-orchestration** (+ `docs/workflow.md` Phase 0) |
| Product shaping | **product-discovery** |
| Figma authoring | **figma-orchestration** (+ upstream **figma-use** before `use_figma`) |
| Visual taste | **frontend-design** |
| Figma → code | **figma-to-liveview** |
| Browser verification | **browser-verification** |

Full map: `docs/SKILLS.md`.

---

## Evolutionary soundness

The system is **rigid on rules** and **flexible on inventory**: tokens and components
grow iteratively. When the old structure lies, **delete or rewrite** in the same PR —
never leave known-wrong guidance to “save time.”
