#!/bin/bash
# Full quality gate — runs at end of agent turn via stop hook.
# Inert until the Elixir umbrella app is scaffolded (mix.exs exists).
#
# Output contract:
#   Pass → exit 0, no output.
#   Fail → exit 0 + JSON on stdout + human text on stderr.
#
# Agent detection via stdin JSON:
#   Cursor sends:          {"status": "...", "loop_count": 0}
#   Claude Code / Codex:   {"hook_event_name": "Stop", ...}
# Cursor reads followup_message; Claude Code / Codex read decision + reason.

INPUT=$(cat)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

[ -f mix.exs ] || exit 0

ERRORS=""

if ! mix format --check-formatted >/dev/null 2>&1; then
  ERRORS="${ERRORS}- Code formatting issues: run mix format. "
fi

if ! mix credo --strict >/dev/null 2>&1; then
  ERRORS="${ERRORS}- Credo issues found. Run mix credo --strict to see details. "
fi

if mix help sobelow >/dev/null 2>&1; then
  if ! mix sobelow --quiet --exit >/dev/null 2>&1; then
    ERRORS="${ERRORS}- Security issues found. Run mix sobelow to see details. "
  fi
fi

if [ -n "$ERRORS" ]; then
  REASON="Quality gate failed: ${ERRORS}Please fix these issues before completing."
  ESCAPED=$(echo "$REASON" | sed 's/"/\\"/g')

  # Claude Code / Codex include hook_event_name in the input JSON.
  # Cursor does not — it sends {status, loop_count}.
  if echo "$INPUT" | grep -q '"hook_event_name"' 2>/dev/null; then
    echo "{\"decision\":\"block\",\"reason\":\"$ESCAPED\"}"
  else
    echo "{\"followup_message\":\"$ESCAPED\"}"
  fi

  echo "$REASON" >&2
fi

exit 0
