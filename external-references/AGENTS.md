# External References — Local Rules

> This directory is for inspiration and comparison only.
> It is intentionally messy. Everything here is git-ignored except this file and
> `CLAUDE.md` (symlink to this file for Claude Code).

`CLAUDE.md` in this directory is a symlink to `AGENTS.md`. Edit **`AGENTS.md` only**.

---

## Purpose

Use this workspace to collect external material that helps thinking:

- cloned repositories (for example `git clone` from GitHub into a subfolder here)
- copied examples
- screenshots
- notes
- rough architectural comparisons
- product inspiration

This directory is **not** part of the canonical repo knowledge base.

---

## Cloned repositories and local code

The maintainer or an agent may **clone or copy** a whole codebase here so it can be
opened and searched alongside Orkestra. Typical uses:

- see how another product structures a domain, API, or UI flow
- compare error handling, state machines, or data modeling
- extract **ideas and constraints**, then re-express them in Elixir/Phoenix

The main app stays **one stack** (`AGENTS.md`). Reference code in other languages
or frameworks is for comparison; port idiomatically, do not smuggle foreign frameworks
into the monolith.

---

## Web search and OSS during feature work

While designing or implementing a feature, it is reasonable to **search the web**
for open-source projects, blog posts, or docs that solve a similar problem. Treat
those hits like anything else in this directory: **provisional**.

Suggested flow:

1. Name the capability you need and what would count as “good enough.”
2. Optionally clone the most relevant repo **into** `external-references/` (or save a
   minimal excerpt with attribution in a local note) so review is concrete.
3. Summarize what is worth stealing (pattern, API shape, failure modes) vs what
   does not fit Orkestra.
4. Record the chosen direction in `product/`, `docs/`, or an ADR **before** or
   **with** the implementation, not only in chat.

---

## What This Workspace Is Not

It is not:

- source of truth
- approved architecture
- approved product specification
- permission to copy code blindly

Anything important learned here must be brought back into the real repo through
discussion and then recorded in `product/`, `docs/`, or ADRs.

---

## Rules For Agents

1. Read this file before using anything in this directory.
2. Treat all contents as provisional and external.
3. Assume patterns here may be wrong for this repo until proven otherwise.
4. Compare references against this repo's constraints before recommending them.
5. Explain why a borrowed idea fits or does not fit.
6. Discuss meaningful adaptations with the user before applying them in the main repo.
7. Prefer extracting principles over copying implementations.
8. If a direct code reuse idea comes up, call it out explicitly and discuss risks
   and mismatch before using it.

---

## Preferred Workflow

1. Gather references.
2. Extract useful patterns.
3. Compare them to this repo's product and technical rules.
4. Discuss tradeoffs with the user.
5. Write the chosen direction into the canonical docs.
6. Implement only after the reasoning is clear.

---

## Context Engineering Guidance

This workspace can get noisy fast. Keep agent context quality high:

- read only the relevant reference files
- summarize findings instead of dragging large external files into the main task
- do not let reference material crowd out the repo's own canonical docs
- prefer small comparison notes over broad copy-paste dumps
