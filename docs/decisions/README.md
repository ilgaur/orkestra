# Architecture Decisions

> This directory stores Architecture Decision Records (ADRs).

Use an ADR when a change is primarily about a technical or architectural choice,
not product behavior.

Examples:

- choosing a deployment orchestration pattern
- selecting a PubSub topic strategy
- defining how billing usage is aggregated in PostgreSQL
- deciding where a cross-cutting concern belongs in the monolith

Do not use an ADR to replace product specs. Product meaning belongs in
`product/`. Technical decisions belong here.

## Naming

Use a simple sequence:

- `0001-short-title.md`
- `0002-short-title.md`

## Minimum ADR Structure

1. Context
2. Decision
3. Consequences
4. Alternatives considered
