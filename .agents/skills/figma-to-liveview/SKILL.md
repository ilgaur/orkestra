---
name: figma-to-liveview
description: Use when implementing a Figma frame, component, or selection as Phoenix LiveView + function components + HEEx. Trigger when the user shares a figma.com design link or asks to build UI from Figma.
---

# Figma → LiveView

## Preconditions

1. `docs/figma-mcp.md` — tool choice.
2. `docs/frontend.md` — component layers and HEEx rules.
3. `docs/design-system.md` — token tiers and naming.
4. `product/figma.md` — file registered.

## Read path

1. Parse `fileKey` and `node-id` from the URL (hyphens → colons in node id).
2. Prefer `get_design_context` on the target node. For huge pages, `get_metadata` first.
3. Use `get_screenshot` when layout fidelity is uncertain.

## Adaptation rules (non-negotiable)

- MCP output is often **React + Tailwind reference**. **Rewrite** to:
  - Phoenix function components with `attr` / `slot`.
  - Semantic Tailwind token classes from this project — no permanent hex.
  - LiveView for state; `Phoenix.LiveView.JS` for micro-interactions; hooks only when required.
- Reuse `MyAppWeb.UI.*` and `MyAppWeb.Domain.*` when they exist.

## Product alignment

- If the UI implies a new workflow or entity, update or create `product/specs/*` and
  `product/discovery.md` before deep implementation.

## Verification

- Compare rendered UI to screenshot when possible.
- When Chrome DevTools MCP is configured, run a **browser pass** (skill
  **browser-verification**, `docs/chrome-devtools-mcp.md`) on the implemented routes.
- Update `product/figma.md` last-synced when parity is intentional.
