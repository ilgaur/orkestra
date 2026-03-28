---
name: browser-verification
description: Use after meaningful frontend changes — verify the running Phoenix app in a real Chrome session via Chrome DevTools MCP (console, network, DOM, layout, screenshots, performance). Trigger when hooks, assets, or visual correctness matter, or before closing production-strictness UI work.
---

# Browser Verification (Chrome DevTools MCP)

## Preconditions

1. Chrome DevTools MCP is configured in the user’s MCP client per `docs/chrome-devtools-mcp.md`.
2. **Phoenix dev server is running** (e.g. `mix phx.server`) unless the task is an external URL.
3. Prefer **Chrome Beta + `--isolated`** so automation does not use the user’s daily profile.

## Typical flow

1. Navigate to the relevant URL (e.g. `http://localhost:4000` and the route under test).
2. `take_snapshot` or equivalent to understand structure; `list_console_messages` for errors.
3. `list_network_requests` / failed requests for assets, CORS, 404s.
4. `take_screenshot` when layout fidelity is in question.
5. For performance: `performance_start_trace` / `performance_stop_trace` when LCP or load
   time is the issue (see upstream tool list).

## LiveView specifics

- Errors may appear in **browser console** (hook JS) even when ExUnit passes.
- **WebSocket** to LiveView: watch for failed WS or repeated disconnects in network tools.
- After fixes, **re-verify** the same path.

## Output

- Summarize: blocking errors vs warnings, failed requests, visual issues.
- File bugs or fix in code; do not mark UI work complete if console shows uncaught errors
  tied to the change (unless exploration phase with logged debt in `product/discovery.md`).

## Docs

Canonical install and flags: `docs/chrome-devtools-mcp.md`.
