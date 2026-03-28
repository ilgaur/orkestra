# Figma — Canonical Registry

> Every design file that matters for implementation must be listed here.
> If it is not here, agents treat links as **exploratory** until registered.

---

## Files

| Name | file_key | URL | Purpose |
|---|---|---|---|
| Orkestra | `19qqtZ6SQR8JvMsqh4Ji7w` | [Open in Figma](https://www.figma.com/design/19qqtZ6SQR8JvMsqh4Ji7w/Orkestra) | Mood board, tokens, components, exploration |

_Add rows when new files exist (marketing, flows, separate libraries)._

---

## Pages / structure (update as the file evolves)

| Page | Contents |
|---|---|
| Mood and direction | Reference images, design direction notes (boxy/chiseled, Linear-inspired, dark UI, halftone ideas) |
| Tokens | Empty — ready for variable setup |
| Components | Empty — ready for component buildout |
| Exploration Space | Hello Card (MCP test), Weather Card (MCP test) |

---

## Sync contract

- **Last synced (code):** _not applicable — app not bootstrapped_
- **Last synced (Figma):** 2026-03-28 (registry updated to correct file key)

When tokens or components change in Figma or in code, bump **Last synced** and touch
`docs/design-system.md` if naming or tiering changed.

---

## Variable naming

Prefer the same names as semantic CSS variables (e.g. `primary`, `foreground`,
`status-running`). Document primitive collections separately in the Figma file’s
Variables panel; keep this file as the **registry**, not a full token dump.
