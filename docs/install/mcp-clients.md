# MCP — Cursor, Codex, Claude Code

**Agent layout:** Shared skills and `CLAUDE.md` symlinks are defined in `AGENTS.md`
(Multi-client agents) and `docs/SKILLS.md`. MCP is configured **per client** below;
keep Figma and other servers registered in each tool you use.

> **This machine (verified 2026-03-24):** Node `v22.22.1`, `npx` works,
> `google-chrome-beta` at `/usr/bin/google-chrome-beta` (147.x),
> `npx -y chrome-devtools-mcp@latest --help` exits 0.

**Restart Cursor** after changing `.cursor/mcp.json`.

---

## Cursor (this repo)

Project file: **`.cursor/mcp.json`** — currently **Chrome DevTools** only (stdio).

**Figma:** Prefer the official Figma plugin (`/add-plugin figma` in agent chat) so MCP +
skills bundle together; see [Figma remote MCP — Cursor](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/).
You can also merge a `figma` entry into `mcpServers` if you configure manually.

Chrome DevTools uses `--channel=beta` + `--isolated` (do not set `executable-path` with
`channel`; they conflict).

Smoke prompt after restart:

```text
Using Chrome DevTools MCP, open https://example.com and take a screenshot.
```

---

## OpenAI Codex

**This repo:** **`.codex/config.toml`** documents the intended servers (Chrome DevTools +
Figma). The **CLI and IDE read `~/.codex/config.toml` for MCP**; project-level TOML
applies only when Codex treats the repo as a [trusted project](https://developers.openai.com/codex/mcp).
After a fresh clone, register MCP once on your machine (below) so `codex mcp list` matches.

### Codex CLI install (Linux / macOS)

Official entry: [Codex CLI](https://developers.openai.com/codex/cli/). Typical install
without `sudo` (Node 18+):

```bash
npm install -g @openai/codex --prefix "$HOME/.local"
```

Ensure **`~/.local/bin`** is on your `PATH` (many distros already include it).

```bash
codex --version
```

### MCP setup (once per machine)

From any directory (writes **`~/.codex/config.toml`**):

```bash
codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest --channel=beta --isolated --no-usage-statistics
codex mcp add figma --url https://mcp.figma.com/mcp
```

**Figma:** `codex mcp add figma` may start an OAuth flow (browser). If the token expires,
run `codex mcp login figma`. See [Figma — Codex](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/)
and [Codex MCP](https://developers.openai.com/codex/mcp).

Then:

```bash
codex mcp list
```

In the TUI, **`/mcp`** shows the same servers.

**Keep `.codex/config.toml` in git** in sync with the commands above so teammates and the
IDE see the same intended shape; re-run `mcp add` (or edit user `config.toml`) when this
file changes.

---

## Claude Code

Official stdio syntax: [Claude Code MCP](https://docs.claude.com/en/docs/claude-code/mcp)
(`claude mcp add [options] <name> -- <command> [args...]`; default transport is stdio).

**This repo:** Chrome DevTools MCP is registered at **project** scope in **`.mcp.json`**
(check in, same spirit as `.cursor/mcp.json`). Recreate with:

```bash
cd /path/to/orkestra
claude mcp add --scope project chrome-devtools -- npx -y chrome-devtools-mcp@latest --channel=beta --isolated --no-usage-statistics
```

Use `--scope user` instead if you want the same server across all projects (stored in
`~/.claude.json`). First use of project-scoped servers may prompt for approval; see
`claude mcp reset-project-choices` if you need to reset that.

**Figma:** Not in committed `.mcp.json` yet; use the [Figma plugin](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/)
(`claude plugin install figma@claude-plugins-official`) or:

```bash
claude mcp add --scope project --transport http figma https://mcp.figma.com/mcp
```

Then `/mcp` → Authenticate for Figma.

---

## Why the agent in Cursor could not “test MCP” here

The **Composer/agent tool bridge** only exposes MCP servers Cursor has loaded for this
session. Until you **restart Cursor** with `.cursor/mcp.json` present, `call_mcp_tool`
will not list `chrome-devtools`. After restart, prompts like “verify localhost:4000 in
Chrome” should reach those tools.

---

## Full Orkestra workflow (manual check)

1. `mix phx.server`
2. In agent chat: “Open http://localhost:4000 with Chrome DevTools MCP, list console errors.”
3. Fix issues; repeat.
