# Figma — Canonical Registry

> Every design file that matters for implementation must be listed here.
> If it is not here, agents treat links as **exploratory** until registered.

---

## Files

| Name | file_key | URL | Purpose |
|---|---|---|---|
| Orkestra — Design System | `TFHCjsrcP7T16TPjuUDBq9` | [Open in Figma](https://www.figma.com/design/TFHCjsrcP7T16TPjuUDBq9) | Components, tokens, UI kit |

_Add rows when new files exist (marketing, flows, separate libraries)._

---

## Pages / structure (update as the file evolves)

| Page | Contents |
|---|---|
| Components | Status Badge component set (example); extend with primitives |

---

## Sync contract

- **Last synced (code):** _not applicable — app not bootstrapped_
- **Last synced (Figma):** 2026-03-24 (initial MCP sample)

When tokens or components change in Figma or in code, bump **Last synced** and touch
`docs/design-system.md` if naming or tiering changed.

---

## Variable naming

Prefer the same names as semantic CSS variables (e.g. `primary`, `foreground`,
`status-running`). Document primitive collections separately in the Figma file’s
Variables panel; keep this file as the **registry**, not a full token dump.
