# Architecture Overview

> The big picture — how the system's pieces connect, data flows, and the
> reasoning behind structural decisions.

---

## Ecosystem

Orkestra is two products in one umbrella:

| Product | Audience | Purpose |
|---|---|---|
| **Konsole** | Non-technical users (beginners, indie hackers, small teams) | Deploy and manage apps through a visual Kanvas interface |
| **Kontrol** | Operators / self-hosters | Provision and manage K8s clusters across cloud providers and bare metal |

Both share auth, design system components, and design tokens via `orkestra_shared`.
Both are open source. Both hold the same design quality bar.

Kubernetes is the engine underneath but is **invisible** to Konsole users.

---

## Stack Summary

| Layer | Technology | Role |
|---|---|---|
| Language | Elixir 1.18+ (on BEAM/OTP) | Fault-tolerant concurrent runtime with gradual type checking |
| Web framework | Phoenix 1.8+ | HTTP, WebSocket, routing, Scopes, asset pipeline |
| Frontend runtime | Phoenix LiveView 1.1+ | Server-rendered reactive UI over WebSocket |
| Templating | HEEx | HTML-aware Elixir templates with compile-time checks |
| Styling | Tailwind CSS (+ daisyUI available) | Utility-first CSS with design tokens |
| Client interactivity | Phoenix.LiveView.JS | Client-side commands without custom JS |
| JS interop | LiveView Hooks (colocated) | Lifecycle callbacks for third-party JS libraries |
| Database | PostgreSQL | ACID storage, JSONB for flexible metadata |
| ORM / query | Ecto | Schemas, changesets, migrations, compile-time query checks |
| Real-time messaging | Phoenix PubSub | In-process pub/sub, distributed across cluster via pg |
| Online presence | Phoenix Presence | CRDT-based presence tracking across cluster |
| Background jobs | Oban 2.19+ | PostgreSQL-backed durable job processing |
| Node clustering | libcluster | Automatic node discovery (k8s, DNS, gossip) |
| Observability | Telemetry + LiveDashboard | Metrics, tracing, process inspection |
| JSON | Built-in (Elixir 1.18+) | Native JSON encoding/decoding, no external dependency |
| Asset build | esbuild + Tailwind CLI | Bundling JS and CSS, ships with Phoenix |

**External infrastructure required: PostgreSQL only.** Everything else runs inside the BEAM VM.

---

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          BROWSER                                │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │  LiveView     │  │  LiveView.JS │  │  JS Hooks             │ │
│  │  (DOM diff    │  │  (show/hide/ │  │  (Kanvas canvas,      │ │
│  │   patches)    │  │   transition │  │   drag-drop, xterm,   │ │
│  │              │  │   toggle)    │  │   colocated in LV1.1) │ │
│  └──────┬───────┘  └──────────────┘  └───────────┬───────────┘ │
│         │               WebSocket                 │             │
└─────────┼─────────────────────────────────────────┼─────────────┘
          │                                         │
┌─────────┼─────────────────────────────────────────┼─────────────┐
│         ▼          PHOENIX ENDPOINTS              ▼             │
│                                                                 │
│  ┌────────────────────────────┐  ┌─────────────────────────┐   │
│  │     KONSOLE ENDPOINT       │  │    KONTROL ENDPOINT      │   │
│  │  Kanvas, Katalog, deploys  │  │  Clusters, providers,    │   │
│  │  (user-facing)             │  │  nodes (operator-facing)  │   │
│  └──────┬─────────────────────┘  └──────┬──────────────────┘   │
│         │                               │                       │
│  ┌──────▼───────────────────────────────▼───────────────────┐   │
│  │                    CONTEXTS                              │   │
│  │                                                          │   │
│  │  Konsole:  Accounts │ Kanvases │ Deployments │ Katalog   │   │
│  │  Kontrol:  Providers │ Clusters │ Nodes                  │   │
│  │  Shared:   Auth │ Design tokens │ Billing                │   │
│  └──────┬───────────┬───────┬────────────────────────┬──────┘   │
│         │           │       │                        │          │
│  ┌──────▼───────┐ ┌─▼──────┐ ┌──────────────────┐ ┌─▼────────┐│
│  │  Ecto/Repo   │ │ PubSub │ │  Oban            │ │ Scopes   ││
│  │  (PostgreSQL) │ │        │ │  (background)    │ │ (access) ││
│  └──────┬───────┘ └──┬─────┘ └───────┬──────────┘ └──────────┘│
│         │            │               │                         │
│  ┌──────▼────────────▼───────────────▼─────────────────────┐   │
│  │                   SUPERVISION TREE                       │   │
│  │  Repo │ PubSub │ Presence │ Oban │ Endpoints │ Cluster  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│                    BEAM VM (single OS process)                  │
└─────────────────────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────┐
│   PostgreSQL     │
│  ┌────────────┐  │
│  │ App tables  │  │
│  │ Oban jobs   │  │
│  │ Sessions    │  │
│  └────────────┘  │
└──────────────────┘
```

---

## Data Flow Patterns

### Pattern 1: User Action → Immediate UI Update

```
User clicks "Delete Pod"
  → LiveView handle_event("delete_pod", %{"id" => id}, socket)
    → MyApp.Infrastructure.delete_pod(id)
      → Ecto deletes from DB
      → PubSub.broadcast("cluster:#{cluster_id}", {:pod_deleted, id})
    → LiveView returns {:noreply, stream_delete(socket, :pods, pod)}
```

The initiating user's LiveView updates immediately via the return value.
Other users viewing the same cluster update via the PubSub broadcast.

### Pattern 2: Background Work → Async UI Update

```
User clicks "Deploy"
  → LiveView handle_event("deploy", attrs, socket)
    → MyApp.Deployments.create_deployment(attrs)
      → Ecto inserts deployment (status: :pending)
      → Oban enqueues ProvisionWorker
      → PubSub.broadcast("deployment:#{id}", {:status_changed, :pending})
    → LiveView returns {:noreply, assign(socket, deployment: deployment)}

  [Later, asynchronously]
  Oban executes ProvisionWorker
    → Talks to infrastructure API
    → MyApp.Deployments.update_status(deployment, :running)
      → Ecto updates DB
      → PubSub.broadcast("deployment:#{id}", {:status_changed, :running})
    → LiveView handle_info receives broadcast
    → UI updates → user sees "Running"
```

### Pattern 3: External Event → UI Update

```
Kubernetes webhook fires (pod crashed)
  → Phoenix Controller receives POST /api/webhooks/k8s
    → MyApp.Infrastructure.handle_pod_event(event)
      → Ecto updates pod status
      → PubSub.broadcast("cluster:#{cluster_id}", {:pod_updated, pod})
    → Controller returns 200 OK

  All LiveViews subscribed to that cluster receive the broadcast
    → UI updates automatically
```

---

## Context Boundary Rules

Each context is a module that owns a business domain. See `product/README.md`
for the current context map and ownership details.

**The dependency rule:**

- Contexts may call other contexts' public functions.
- Contexts NEVER reach into another context's schemas or internal modules.
- If context A needs data from context B, A calls B's public API.
- Konsole contexts may depend on Kontrol contexts (Deployments → Clusters),
  but Kontrol contexts must NOT depend on Konsole contexts.
- Shared contexts (Auth, Billing) are available to both apps.

```
Konsole:   Accounts → Kanvases → Deployments ← Katalog
Kontrol:   Providers → Clusters → Nodes
Cross-app: Deployments → Clusters (Konsole depends on Kontrol)
Shared:    Auth, Billing (available to both)
```

---

## Supervision Trees

Each umbrella app has its own supervision tree. Shared services (PubSub, Repo)
are started by `orkestra_shared` and available to all apps.

```elixir
# apps/orkestra_shared/lib/orkestra_shared/application.ex
def start(_type, _args) do
  children = [
    OrkestgraShared.Repo,
    {Phoenix.PubSub, name: Orkestra.PubSub},
    {Oban, Application.fetch_env!(:orkestra_shared, Oban)}
  ]
  Supervisor.start_link(children, strategy: :one_for_one)
end

# apps/konsole/lib/konsole/application.ex
def start(_type, _args) do
  children = [
    KonsoleWeb.Presence,
    {Cluster.Supervisor, [topologies(), [name: Konsole.ClusterSupervisor]]},
    KonsoleWeb.Endpoint
  ]
  Supervisor.start_link(children, strategy: :one_for_one)
end

# apps/kontrol/lib/kontrol/application.ex
def start(_type, _args) do
  children = [
    KontrolWeb.Endpoint
  ]
  Supervisor.start_link(children, strategy: :one_for_one)
end
```

**Why order matters:** The Endpoint must start last because it depends on Repo,
PubSub, and Oban being available. Strategy `:one_for_one` means if one child
crashes, only that child restarts — others are unaffected.

---

## Clustering and Distribution

For production with multiple nodes:

1. **libcluster** handles node discovery (k8s API, DNS, or gossip).
2. **PubSub** automatically propagates messages across all connected nodes.
3. **Oban** coordinates job processing across nodes (only one picks up a job).
4. **Presence** merges presence data across nodes via CRDTs.

A user on Node A sees a pod status change from a webhook hitting Node B.
No external message broker needed.

---

## Key Architectural Decisions

### Why umbrella, not monolith or microservices?

Orkestra has two distinct products (Konsole and Kontrol) that share code (auth,
design system, billing). An umbrella gives each product its own OTP application,
supervision tree, and web endpoint while sharing one repo, one deploy pipeline,
and one config tree. BEAM gives isolation benefits of microservices (independent
processes, fault isolation, message passing) inside a single deployable. Contexts
provide logical boundaries. GenServers and supervision provide runtime isolation.

Self-hosters install one thing and get both products. If separation is ever needed,
an umbrella makes that migration easier than untangling a monolith.

### Why PostgreSQL only, no Redis?

PubSub uses Distributed Erlang (zero latency, no serialization). Oban uses
PostgreSQL for job persistence (ACID guarantees). Redis would add operational
complexity with no clear benefit.

### Why LiveView, not SPA?

LiveView gives real-time UI with one language, one mental model, zero client
state management. For a cloud dashboard where most interactivity is "show me
what changed on the server," this is ideal. JS hooks only for things the browser
must own (charts, terminals, animations).

### Why colocated hooks (LiveView 1.1)?

Hooks that belong to a specific component live with that component. Prevents
disconnected JS files where the agent or developer can't see a component's full
behavior. One file, one component, all behavior together.

### Why Phoenix 1.8 Scopes?

Scopes propagate security context (current user, team, permissions) through
requests by default. This prevents broken access control vulnerabilities at the
framework level rather than relying on manual checks in every context call.

---

## Project Structure

Orkestra uses an **Elixir umbrella project**. Bootstrap with
`mix new orkestra --umbrella`, then generate Phoenix apps inside `apps/`.

```
AGENTS.md                            # Constitution + router (canonical)
CLAUDE.md                            # Symlink → AGENTS.md (Claude Code)
.mcp.json                            # Claude Code — project-scoped MCP (e.g. chrome-devtools)
.codex/config.toml                   # Codex CLI / IDE — project MCP (chrome-devtools, figma)
.agents/skills/                      # Agent skills (canonical); .claude/skills + .codex/skills → here
mix.exs                              # Umbrella root mix (no app code here)
config/                              # Shared config (all apps read from here)

apps/
├── orkestra_shared/                 # Shared code: auth, design system, billing
│   ├── lib/orkestra_shared/
│   │   ├── auth.ex                  # Auth context (shared across Konsole + Kontrol)
│   │   ├── auth/
│   │   │   └── user.ex
│   │   └── billing.ex               # Billing context
│   ├── test/
│   └── mix.exs
│
├── konsole/                         # User-facing PaaS
│   ├── lib/
│   │   ├── konsole/                 # Business logic (NEVER import KonsoleWeb here)
│   │   │   ├── application.ex
│   │   │   ├── repo.ex
│   │   │   ├── accounts.ex          # Workspaces, memberships
│   │   │   ├── accounts/
│   │   │   │   └── workspace.ex
│   │   │   ├── kanvases.ex          # Kanvas CRUD, layout state
│   │   │   ├── kanvases/
│   │   │   │   └── kanvas.ex
│   │   │   ├── deployments.ex       # App deployment, builds
│   │   │   ├── katalog.ex           # Available services, templates
│   │   │   └── workers/
│   │   │
│   │   └── konsole_web/             # Web layer
│   │       ├── router.ex
│   │       ├── endpoint.ex
│   │       ├── components/
│   │       │   ├── core_components.ex
│   │       │   ├── layouts.ex
│   │       │   ├── ui/              # Shared design system primitives (import from orkestra_shared)
│   │       │   ├── domain/          # Konsole-specific composed components
│   │       │   └── interactive/     # Kanvas surface, window chrome, drag-drop hooks
│   │       └── live/
│   │           ├── kanvas_live/
│   │           └── workspace_live/
│   ├── assets/
│   │   ├── js/app.js
│   │   ├── css/app.css              # Tailwind imports + design tokens
│   │   └── tailwind.config.js       # Token definitions
│   ├── test/
│   └── mix.exs
│
├── kontrol/                         # Operator-facing infra tool
│   ├── lib/
│   │   ├── kontrol/                 # Business logic
│   │   │   ├── application.ex
│   │   │   ├── repo.ex
│   │   │   ├── providers.ex         # Cloud provider credentials, SSH keys
│   │   │   ├── clusters.ex          # Cluster lifecycle, K8s provisioning
│   │   │   ├── nodes.ex             # Node management, scaling
│   │   │   └── workers/
│   │   │
│   │   └── kontrol_web/             # Web layer
│   │       ├── router.ex
│   │       ├── endpoint.ex
│   │       ├── components/
│   │       │   ├── ui/              # Shared design system primitives (import from orkestra_shared)
│   │       │   ├── domain/          # Kontrol-specific composed components
│   │       │   └── interactive/
│   │       └── live/
│   │           ├── cluster_live/
│   │           └── provider_live/
│   ├── assets/
│   ├── test/
│   └── mix.exs

docs/                                # Engineering rules
├── AGENTS.md                        # Methodology, git, Elixir conventions, sync notes
├── CLAUDE.md                        # Symlink → AGENTS.md (Claude Code)
├── day-one.md                       # Minimal read paths; frustration FAQ
├── SKILLS.md                        # Which skill when (Cursor + Claude Code + Codex)
├── architecture.md                  # This file
├── agentic-design.md                # Design–product–code loop, strictness phases
├── design-system.md                 # Token foundations, Figma parity
├── figma-mcp.md                     # MCP tool matrix
├── chrome-devtools-mcp.md           # Browser verification MCP (Chrome)
├── backend.md
├── frontend.md
├── testing.md
├── workflow.md                      # Token workflow, design enforcement
├── install/                         # Client setup (MCP, etc.)
└── decisions/                       # Architecture Decision Records

product/                             # Product specification
├── AGENTS.md                        # Product layer agent rules
├── CLAUDE.md                        # Symlink → AGENTS.md (Claude Code)
├── README.md                        # Glossary, context map, capabilities
├── discovery.md                     # Open questions, hypotheses, design debt
├── figma.md                         # Registered Figma files (file_key, URLs)
├── entities/                        # One file per core concept
├── workflows/                       # One file per business flow
└── specs/                           # Feature specifications

external-references/                 # Local-only, git-ignored (except AGENTS + CLAUDE)
├── AGENTS.md
└── CLAUDE.md                        # Symlink → AGENTS.md (Claude Code)
```
