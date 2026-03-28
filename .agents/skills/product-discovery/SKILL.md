---
name: product-discovery
description: Use when shaping what Orkestra is, who it serves, pricing hypotheses, scope, or non-goals. Use for socratic dialogue before or during design and implementation. Updates product/discovery.md and promotes stable answers to product/README.md.
---

# Product Discovery

## Stance

- **Conventions over whims.** Beautiful product is **clear**, not vague.
- Ask **short, hard** questions; wait or record open items in `product/discovery.md`.
- Never invent a business model silently.
- **Listen:** If the user says “no discovery this session” or “exploration only,”
  stop drilling; append a **Design debt** or **Open questions** line and move on.
- **Propose structure:** If product scope implies new contexts, entities, or Figma
  files, say so and offer updates to `product/README.md` or `product/figma.md` — do not
  wait to be asked.

## Required reads

- `product/README.md` — glossary, context map, capabilities.
- `product/discovery.md` — open questions and hypotheses.

## Socratic checklist (ask until resolved or explicitly deferred)

1. Primary user and their main job-to-be-done?
2. What outcome makes this slice a success?
3. What is **out of scope** for this slice?
4. Differentiation — why not generic cloud console?
5. Monetization hypothesis (if relevant now)?
6. Brand adjectives (max three) for visual direction?

## Writes

- Log new questions and answers in `product/discovery.md`.
- When a term stabilizes, add to glossary in `product/README.md`.
- When scope changes, update or create `product/specs/<feature>.md`.
- If a capability is new, update the capability table in `product/README.md`.

## With design

- Before greenfield UI, ensure **tokens** and **screens** will match the thesis in
  `product/discovery.md`. If not, adjust Figma or the thesis — not both silently.
