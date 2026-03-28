# Engineering Agent Rules

> Read this alongside the area-specific doc for your current task.
> These rules apply to all engineering work in this repo.
> For **minimal** context loads, see `docs/day-one.md` — this file is deeper.

---

## Methodology

Follow this sequence for every task:

1. **Understand** — State what you understand the task to be. Ask if anything is ambiguous. For product or positioning work, read `product/discovery.md` and ask socratic questions before locking scope.
2. **Locate** — Read the relevant docs from the router in `AGENTS.md`. If product meaning is affected, read `product/` first. Read existing code in the area you'll touch. When studying a third-party repo or OSS pattern, read `external-references/AGENTS.md` first, keep clones under `external-references/`, and read only the paths that matter for the question.
3. **Plan** — Describe your approach briefly. Present alternatives with tradeoffs at decision points.
4. **Implement** — Write focused, minimal code following the area-specific rules.
5. **Specify** — Update the relevant product spec if the work changes workflows, entities, states, or terms.
6. **Test** — Write or update tests for everything you changed.
7. **Explain** — After implementation, explain what you built and why it works in Elixir/Phoenix terms.

---

## Documentation Hygiene

1. Every task must check if `AGENTS.md`, `product/`, `docs/`, or ADRs are affected.
2. If affected, update in the same change. Never defer.
3. If a section is no longer true, delete or rewrite it immediately.
4. Do not duplicate rules across files. Link to the canonical source.
5. The more specific document wins: `product/` for meaning, `docs/` for engineering, ADRs for decisions.
6. When code and docs disagree, fix the disagreement before closing the task.
7. Prefer deletion over drift. Smaller accurate docs beat larger misleading ones.
8. **`CLAUDE.md` is a symlink to `AGENTS.md` in the same directory** (root, `docs/`,
   `product/`, `external-references/`). Edit **`AGENTS.md` only**. If you add a new
   directory that introduces agent rules, add `AGENTS.md` and the matching
   `CLAUDE.md` → `AGENTS.md` symlink in the same change.
9. **Skills live only under `.agents/skills/`.** Do not create a second copy under
   `.claude/skills` or `.codex/skills` — those paths symlink to `.agents/skills/`.

### Design, Figma, and product sync

When work touches UI or design intent, also run the **anti-stale matrix** in
`docs/agentic-design.md` (Figma registry, tokens, specs, glossary). Never close a
change that leaves `product/figma.md` or `product/discovery.md` knowingly wrong.

---

## Communication

- Be direct. Say "this is wrong because X" not "you might want to consider..."
- Present 2–3 concrete options with tradeoffs at decision points.
- Never silently make architectural decisions — always surface them.
- The user is learning Elixir/Phoenix. Briefly explain concepts the first time in context. Don't lecture — teach through the work.

---

## Git Conventions

### Development model

Trunk-based development. Short-lived branches with a single squashed commit
merged into `main`. No long-running feature branches.

### Branch naming

```
<type>/<short-description>

feat/cluster-crud
fix/pubsub-double-subscribe
docs/update-context-map
refactor/extract-query-module
```

### Commit message format

[Conventional Commits](https://www.conventionalcommits.org/) with project-specific scopes.
Every commit message follows this structure:

```
<type>(<scope>): <summary>

<optional body — explain WHY, not WHAT>

<optional footer — references, breaking changes>
```

**Summary rules:**

- Lowercase, imperative mood: "add cluster CRUD" not "Added cluster CRUD".
- No period at the end.
- Under 72 characters.
- Describe the change from the user's or system's perspective, not implementation detail.

### Types

| Type | When to use |
|---|---|
| `feat` | New feature or user-visible capability |
| `fix` | Bug fix |
| `refactor` | Code restructuring with no behavior change |
| `docs` | Documentation only |
| `test` | Adding or updating tests only |
| `chore` | Dependencies, config, CI, tooling |
| `style` | Formatting changes (rare — `mix format` handles most) |
| `perf` | Performance improvement with no behavior change |

### Scopes

Scopes map to the project's bounded contexts and layers. Use them to signal
which area of the codebase a change touches.

| Scope | Area |
|---|---|
| `accounts` | Accounts context (users, workspaces, auth) |
| `kanvas` | Kanvas context (spatial workspace, layout state, item placement) |
| `katalog` | Katalog context (available services, templates, provider integrations) |
| `deployments` | Deployments context (deploys, builds, environment config) |
| `billing` | Billing context (subscriptions, usage) |
| `providers` | Kontrol: cloud provider credentials, SSH keys |
| `clusters` | Kontrol: cluster lifecycle, K8s provisioning |
| `nodes` | Kontrol: node management, scaling |
| `shared` | orkestra_shared: design system, auth, cross-app code |
| `konsole` | Konsole app-level changes (router, endpoint, config) |
| `kontrol` | Kontrol app-level changes (router, endpoint, config) |
| `ui` | Design system components (`components/ui/`) |
| `live` | LiveView pages |
| `hooks` | JS hooks |
| `tokens` | Design tokens (Tailwind config, CSS variables) |
| `deps` | Dependency updates |
| `ci` | CI/CD pipeline |
| `db` | Migrations and database schema |
| `design` | Design system docs, Figma registry, discovery, agentic-design docs |

Scope is optional but encouraged. Omit it only when the change genuinely spans
the entire codebase.

### Examples

```
feat(infrastructure): add cluster creation with PubSub broadcast

fix(live): guard PubSub subscribe with connected? check

refactor(accounts): extract team membership into separate schema

docs: update context map with billing dependencies

test(infrastructure): add PubSub broadcast assertions for cluster events

chore(deps): update oban to 2.19

feat(ui): add badge component with status variants

fix(db): add missing index on clusters.team_id

perf(infrastructure): use stream for pod listing in cluster view

feat(tokens): add status color tokens for cluster states

docs(design): register flows file and sync discovery hypotheses
```

### Multi-line commit body

Use the body to explain WHY a change was made when the summary alone isn't enough.
Separate the summary from the body with a blank line.

```
fix(infrastructure): prevent cluster deletion with active deployments

The previous implementation allowed deleting clusters that still had
running deployments, leaving orphaned pods. Added a pre-delete check
in the context that returns {:error, :has_active_deployments}.

Closes #42
```

### Breaking changes

Prefix the body with `BREAKING CHANGE:` or append `!` after the type.

```
feat(accounts)!: replace session auth with magic link tokens

BREAKING CHANGE: existing sessions are invalidated. Users must
re-authenticate via magic link after this deploy.
```

---

## Elixir Code Conventions

`mix format` handles whitespace, indentation, line length, and parentheses automatically.
The rules below cover what the formatter does not.

### Module Organization

Order contents in this sequence, with blank lines between groups:

```elixir
defmodule MyApp.Example do
  @moduledoc "Brief description of this module's responsibility."

  @behaviour SomeBehaviour

  use GenServer

  import Ecto.Query

  require Logger

  alias MyApp.Accounts.User
  alias MyApp.Infrastructure.Cluster

  @constant_value 42

  defstruct [:name, active: true]

  @type t :: %__MODULE__{}

  @callback some_function(term()) :: :ok

  # --- Public functions ---
  # --- Private functions ---
end
```

### Naming

```elixir
# snake_case for atoms, variables, functions, file names.
:some_atom
some_variable = 5
def some_function, do: :ok

# CamelCase for modules. Acronyms stay uppercase.
defmodule MyApp.HTTPClient do ... end
defmodule MyApp.XMLParser do ... end

# ? suffix for boolean-returning functions.
def active?(user), do: user.status == :active

# is_ prefix ONLY for guard-safe boolean checks.
defguard is_admin(user) when user.role == :admin

# ! suffix for functions that raise on failure.
def get_user!(id), do: Repo.get!(User, id)

# __MODULE__ for self-references inside a module.
def new(attrs), do: struct(__MODULE__, attrs)

# Avoid repeating fragments in module names.
# Bad:  MyApp.Todo.Todo
# Good: MyApp.Todo.Item

# Exception modules end with Error.
defmodule MyApp.ProvisionError do
  defexception [:message]
end
```

### Pipes and Expressions

```elixir
# DO: bare variable first in pipe chains.
some_string
|> String.trim()
|> String.downcase()
|> String.split()

# DON'T: function call first in a pipe.
String.trim(some_string) |> String.downcase()

# DON'T: single-pipe — just call the function directly.
# Bad:  some_string |> String.downcase()
# Good: String.downcase(some_string)

# DO: parentheses on zero-arity in pipes.
System.version() |> Version.parse()

# DO: if/do: for single-line conditionals.
if some_condition, do: :ok

# DON'T: unless with else — rewrite as positive condition.
if success, do: :ok, else: :error

# DO: true as cond catch-all.
cond do
  x > 10 -> :large
  x > 0 -> :small
  true -> :zero_or_negative
end
```

### Functions

- Keep functions under 15 lines. Decompose aggressively.
- Use pattern matching and guard clauses over nested conditionals.
- Return `{:ok, value}` / `{:error, reason}` for fallible operations.
- `@moduledoc` on every public module. `@doc` on every public function.
- `@moduledoc false` on internal modules not meant for external use.
- Add `@spec` on public functions when the types are non-obvious.
- Raise with lowercase messages, no trailing punctuation: `raise ArgumentError, "invalid input"`.

### Error Handling

```elixir
# Pattern match on tagged tuples — never try/rescue for expected failures.
case Infrastructure.create_cluster(attrs) do
  {:ok, cluster} -> handle_success(cluster)
  {:error, changeset} -> handle_failure(changeset)
end

# Use bang functions only when the record is guaranteed to exist.
cluster = Infrastructure.get_cluster!(id)

# Let unexpected errors crash — the supervisor restarts the process.
```

### Typespecs

```elixir
# Name the main struct type t.
@type t :: %__MODULE__{name: String.t(), status: atom()}

# Place @typedoc and @type together, separated by blank lines between pairs.
@typedoc "A valid cluster status."
@type status :: :provisioning | :running | :failed | :deleting

@typedoc "Cluster creation attributes."
@type create_attrs :: %{name: String.t(), region: String.t()}

# Multi-line union types: one part per line.
@type result ::
        {:ok, t()}
        | {:error, Ecto.Changeset.t()}
        | {:error, :not_found}
```

### Comments and Annotations

- Comments explain WHY, not WHAT. If code needs a comment to explain what it does, simplify the code.
- End comments with a period.
- Use annotations for known issues: `TODO:`, `FIXME:`, `HACK:`, `OPTIMIZE:`.

```elixir
# TODO: Replace with batch insert when volume exceeds 1000/minute.
def insert_metrics(metrics) do
  ...
end
```
