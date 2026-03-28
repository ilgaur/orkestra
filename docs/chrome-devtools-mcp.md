# Chrome DevTools MCP — Browser Verification

> Lets agents **see** the running app: console, network, DOM, layout, performance.
> Complements ExUnit and LiveView tests — use after meaningful UI changes.
>
> Official: [Chrome DevTools MCP announcement](https://developer.chrome.com/blog/chrome-devtools-mcp),
> [GitHub — chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp).

---

## Why we use it

LiveView tests prove server-driven behavior. **Chrome MCP** proves what users see:
hydration, hooks, CSS, CORS, asset loading, and console errors. Agents are otherwise
“programming with a blindfold on” for the real browser.

---

## Requirements

- **Node.js** v20.19+ (LTS).
- **Chrome** stable, **Beta**, or Canary — see setup below.
- **npm** / **npx** available to the MCP client.

---

## Install in Cursor

This repository includes **`.cursor/mcp.json`** with `chrome-devtools` (Chrome Beta via
`--channel=beta`, `--isolated`). **Restart Cursor** after pull or edit.

**Do not pass `--channel` and `--executable-path` together** — the CLI rejects that
combination. Use **`--channel=beta`** when Beta is installed normally, **or** only
`--executable-path=/path/to/chrome` when you must point at a binary (no channel).

For Codex / Claude Code and a verified machine snapshot, see **`docs/install/mcp-clients.md`**.

You can instead add the server via **Cursor Settings → MCP** using the same `command` /
`args` as in `.cursor/mcp.json`.

### Recommended: Chrome **Beta** + **isolated** profile (agent-only)

Keeps automation off your daily browsing profile and reduces accidental data exposure
([disclaimer](https://github.com/ChromeDevTools/chrome-devtools-mcp#disclaimers)).

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--channel=beta",
        "--isolated"
      ]
    }
  }
}
```

`--channel=beta` uses the **Beta** channel if installed. If Beta is in a weird location,
**drop `--channel`** and use **only**:

```json
"--executable-path=/path/to/Google Chrome Beta"
```

Never combine `channel` and `executablePath` in the same args list.

### Optional flags (from upstream docs)

| Flag | When |
|---|---|
| `--headless` | CI or no display; less useful for visual layout debugging. |
| `--slim` | Only basic navigation + script + screenshot — lighter tool set. |
| `--no-usage-statistics` | Opt out of Google usage stats for the MCP server. |
| `--no-performance-crux` | Disable CrUX / field data in performance flows. |
| `--viewport=1280x720` | Consistent initial size for screenshots. |

### Alternative: attach to **your** running Chrome

If you prefer one visible Chrome (e.g. signed-in dev session), enable remote debugging
and point the server at it — see
[Connecting to a running Chrome instance](https://github.com/ChromeDevTools/chrome-devtools-mcp#connecting-to-a-running-chrome-instance).
**Warning:** debugging port exposes control of the browser; use a **dedicated** profile,
not your personal one.

---

## Codex / other agents

```bash
codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest --channel=beta --isolated
```

Adapt to your client’s MCP config format.

---

## Verify it works

With the dev server running (or any URL), prompt:

```text
Open http://localhost:4000 and report console errors and failed network requests.
```

Or the [official smoke test](https://developer.chrome.com/blog/chrome-devtools-mcp):

```text
Check the performance of https://developers.chrome.com
```

---

## Orkestra workflow (Phoenix)

1. `mix phx.server` (typical **http://localhost:4000** — use your actual port).
2. Agent uses Chrome MCP to: navigate, snapshot DOM, read console, list network,
   screenshot, optional performance trace.
3. Fix issues; re-run MCP check on changed routes.

Register the **base URL** in `product/discovery.md` or team notes when the team agrees
on a default dev URL.

---

## When agents should use it

- After new **hooks**, **colocated JS**, or **asset** pipeline changes.
- When **layout** or **responsive** behavior is hard to infer from code alone.
- Before treating a UI task **done** in **production** strictness (see `docs/agentic-design.md`).
- **Not** a substitute for ExUnit — use **both**.

---

## Security

- MCP clients can **inspect and drive** the browser session. Do not use a profile with
  production secrets or personal data you are unwilling to expose to the agent.
- Prefer **`--isolated`** for agent-driven runs.

---

## Skill

Repo skill: `.agents/skills/browser-verification/SKILL.md`. Routing: `docs/SKILLS.md`.
