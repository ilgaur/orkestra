# Product Discovery

> Open questions, hypotheses, and positioning while Orkestra is still taking shape.
> Agents use this file for **socratic** refinement — answers get promoted to
> `product/README.md` when stable.

---

## Working thesis

Orkestra is an **open-source visual PaaS** for people who have an app and want it
running on the internet without learning infrastructure. Kubernetes is the engine
but users never see it.

**Differentiator vs Railway/Render:** The Kanvas — a spatial, OS-like workspace
where deployed apps feel like windows on a desktop, not rows in a dashboard.
More visual, more fun, more alive.

**Ecosystem:** Konsole (user-facing) + Kontrol (operator/self-hosting infra tool).
Both open source, both beautifully designed.

---

## Hypotheses (test, don’t assert)

| Hypothesis | Evidence we need | Status |
|---|---|---|
| Non-technical users will deploy apps if the UX is visual and spatial (Kanvas) | Early user testing, onboarding completion rates | open |
| The OS/window metaphor makes infra management less intimidating | User interviews, A/B with traditional dashboard | open |
| Self-hosters will adopt Kontrol to provision their own clusters | GitHub stars, community adoption | open |
| A drag-and-drop Katalog reduces friction vs form-based "create service" flows | Usability testing | open |
| Billing by usage resonates | Pricing experiments | open |

---

## Open questions

### Answered
- ~~Primary buyer~~ → Non-technical users: beginners, indie hackers, small teams
- ~~Multi-tenant model~~ → Workspace is the collaboration boundary; contains multiple Kanvases
- ~~Relationship to Kubernetes~~ → Fully abstracted away; users know nothing about K8s

### Still open
- What does the OS-like window interaction actually look like? (close, minimize, arrange — needs design exploration)
- What can be deployed from the Katalog in v1? (just web apps from GitHub repos? databases too?)
- How does Kontrol connect to Konsole? (shared database in umbrella? API boundary? both?)
- Pricing model: free tier + usage-based? Open source with paid hosted offering?
- Compliance targets (SOC2, region locking) in v1 or later?
- How deep does AI integration go later? (deploy assistant? auto-scaling suggestions? natural language infra?)
- Can a Kanvas represent an environment (staging vs prod)? Or is that a separate concept?

---

## Design debt (Figma / parity)

_Use when exploration phase allows code ahead of design. Each line should be removable._

| Item | Opened | Target |
|---|---|---|
| _Example: status badge in code only_ | _YYYY-MM-DD_ | _Sync Figma component set_ |

---

## Brand adjectives

Three words that drive all visual and interaction decisions:

1. **Sleek** — clean lines, confident hierarchy, no clutter
2. **Sexy** — premium feel, surprising details, not boring
3. **Fun** — playful interactions, the OS metaphor, inviting for beginners

These translate directly to token choices, motion philosophy, and the
frontend-design skill's visual thesis.

---

## Non-goals (current slice)

_Record explicit non-goals per milestone to prevent scope creep._

- CLI tool or API-first interface (this is a visual product)
- Exposing Kubernetes concepts to Konsole users
- Enterprise features (SSO, RBAC, audit logging) in v1
- Mobile app (responsive web is fine)
- Multi-region deployment orchestration in v1
- Custom domain management in v1

---

## Decisions log (short)

| Date | Decision | Rationale |
|---|---|---|
| 2026-03-25 | Target audience is non-technical users, not platform engineers | We want to make deployment accessible, not build another DevOps tool |
| 2026-03-25 | Two-product ecosystem: Konsole (user PaaS) + Kontrol (operator infra) | Separates user UX from operator complexity; both can stand alone |
| 2026-03-25 | K8s is fully invisible to Konsole users | Beginners don't need to know what runs underneath |
| 2026-03-25 | Kanvas is the core UX — spatial, OS-like workspace | Differentiates from dashboard-style competitors like Railway |
| 2026-03-25 | Katalog for browsing/dragging deployable items | Plus button opens list; items can also be dragged onto Kanvas |
| 2026-03-25 | Entirely open source | Community-driven, self-hostable |
| 2026-03-25 | K naming convention is brand identity | Konsole, Kontrol, Kanvas, Katalog |
| 2026-03-25 | Design bar is equally high for all products | Kontrol (technical) gets the same design quality as Konsole (consumer) |
| 2026-03-25 | Umbrella project architecture | Konsole + Kontrol + orkestra_shared as separate OTP apps in one repo |
| 2026-03-25 | Brand adjectives: sleek, sexy, fun | These drive token choices, motion, and visual taste |

When a decision is technical, mirror or reference `docs/decisions/`.
