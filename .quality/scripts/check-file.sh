#!/bin/bash
# Per-file quality check — runs after file edits via hook.
# Lightweight: format + credo on a single file. Does not block (exit 0 always).
# Inert until the Elixir umbrella app is scaffolded (mix.exs exists).
#
# Cursor sends: {"file_path": "/abs/path", "edits": [...]}
# Claude Code sends: {"tool_name": "Write", "tool_input": {"file_path": "/abs/path", ...}}
# Codex sends: {"tool_name": "Bash", "tool_input": {"command": "..."}} (per-file N/A).

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // .tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [[ ! "$FILE_PATH" =~ \.(ex|exs|heex)$ ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

[ -f mix.exs ] || exit 0

mix format --check-formatted "$FILE_PATH" 2>&1 || true
mix credo "$FILE_PATH" 2>&1 || true

exit 0
