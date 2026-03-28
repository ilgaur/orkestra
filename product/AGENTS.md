# Product Layer — Agent Rules

> Read this when working on anything in `product/`.

---

## Related files

| File | Role |
|---|---|
| `README.md` | Glossary, context map, capabilities |
| `discovery.md` | Open questions, positioning, hypotheses — update during socratic sessions |
| `figma.md` | Registered Figma `file_key`s and URLs — must stay current |
| `CLAUDE.md` | Symlink to `AGENTS.md` for Claude Code — edit **`AGENTS.md` only**. |

---

## Purpose

This directory defines what the product means. It is not optional context.

When a task changes product behavior, the agent MUST:

1. Read the relevant files in `product/` before designing or implementing.
2. Update the relevant product files in the same change if terminology, workflows, states, invariants, capabilities, or context boundaries changed.
3. Create or update a spec in `product/specs/` before substantial implementation.
4. Keep acceptance examples aligned with tests.

---

## Spec Lifecycle

| Status | Meaning |
|---|---|
| `draft` | Still being shaped |
| `building` | Implementation in progress |
| `done` | Code exists, tests pass, spec is validated |
| `superseded` | Replaced by a newer spec |

---

## Directory Structure

| Path | Contains | Format example |
|---|---|---|
| `README.md` | Product overview, glossary, context map, capabilities | — |
| `specs/` | Feature specifications, one file per feature | `specs/EXAMPLE.md` |
| `entities/` | Core business concepts, one file per entity | `entities/EXAMPLE.md` |
| `workflows/` | Business flows, one file per workflow | `workflows/EXAMPLE.md` |

Each directory has an `EXAMPLE.md` that shows the expected format.
Follow the example — don't invent a new structure.

---

## Diagram Policy

- Start with text. Add a diagram only when it removes ambiguity.
- One diagram answers one question. Split if it covers more.
- Prefer 5–9 nodes with short labels.
- Use fenced `mermaid` code blocks. Stick to flowchart, sequence, and state diagrams.
- Place diagrams adjacent to the text that explains them.
- If a diagram becomes stale or harder to maintain than the text, delete it.
