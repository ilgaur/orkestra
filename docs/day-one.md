# Day One — What to Actually Read

> This repo has many docs on purpose. **You should not load them all at once.**
> Models [lose fidelity](https://paddo.dev/blog/your-agents-md-is-a-liability/) when
> instructions pile up; use **thin paths** and add depth only when the task needs it.

---

## Pick one path (human or agent)

| I want to… | Read this much only |
|---|---|
| **Ship backend code** (no UI) | `AGENTS.md` → `docs/AGENTS.md` → `docs/backend.md` |
| **Build UI** without Figma today | `AGENTS.md` → `docs/frontend.md` + skill `frontend-design` |
| **Implement from a Figma link** | Above + `docs/figma-mcp.md` + `product/figma.md` + skill `figma-to-liveview` |
| **Verify UI in real Chrome** (MCP installed) | `docs/chrome-devtools-mcp.md` + skill `browser-verification` — run `mix phx.server` first |
| **Change what the product means** | `product/discovery.md` + `product/README.md` + skill `product-discovery` |
| **Ideate, brainstorm, or shape the product** | **Read ALL docs** — see the full-context rule in `AGENTS.md` context router. Do not respond until you have read product/, design system, architecture, frontend, workflow, agentic-design, and both design-related skills. |
| **Draw or edit Figma via MCP** | `docs/figma-mcp.md` + `product/figma.md` + skill `figma-orchestration` (+ figma-use before writes) |
| **Full vertical slice** (product + design + code) | `docs/agentic-design.md` (the loop is short) then pull area docs as you touch each layer |
| **Learn from external code / OSS** | `external-references/AGENTS.md` — clone or copy repos locally under that tree; summarize patterns; reconcile with `AGENTS.md` principle 8 before reuse |

Everything else is **optional until relevant**.

**Claude Code:** Root `CLAUDE.md` is the same file as `AGENTS.md` (symlink). Subfolder
rules use `docs/CLAUDE.md`, `product/CLAUDE.md`, etc. — always edit the matching
`AGENTS.md`, not the symlink target name in isolation.

---

## Common frustrations (and fixes)

| Frustration | Fix |
|---|---|
| “Too many links in the router.” | Use this file’s table. Ignore the full router until you need a row. |
| “Agent asks too many product questions.” | Say: “defer discovery — scaffold only.” Agent records that in `product/discovery.md` and uses tokenized placeholders. |
| “Figma isn’t ready but I need a screen.” | Allowed in **exploration** (see `docs/agentic-design.md`). Use tokens; sync Figma in a follow-up. |
| “Rules conflict with what I want.” | **You win.** Say explicitly: “override: use X.” Agent notes tradeoff in the PR/spec so docs can catch up. |
| “I don’t know which skill.” | `docs/SKILLS.md` decision tree — one branch only. |
| “Components folder feels messy.” | See `docs/frontend.md` — **Growing the component tree**. Ask the agent to propose a split + ADR. |

---

## Agent behavior we expect

- **Proactive:** If `components/ui/` has many unrelated primitives, suggest subfolders or namespaces and a one-line ADR — don’t wait for you to ask.
- **Listening:** If you narrow scope (“no Figma this week”), follow that and log debt in `product/discovery.md`.
- **Honest:** If a procedure is wrong for the task, say so and use the smallest doc set that fits.

---

## When the full system earns its keep

Pull `docs/design-system.md`, `docs/workflow.md`, and the anti-stale matrix when:

- Tokens multiply or themes diverge.
- Several people or agents touch the same Figma files.
- You are preparing something customer-visible.

Until then, **principles + one area doc** beats reading everything.
