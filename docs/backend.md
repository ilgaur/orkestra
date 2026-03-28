# Backend Rules

> Business logic, database schemas, contexts, PubSub, background jobs, and
> everything behind the web layer.
>
> For general Elixir code conventions (naming, pipes, module organization),
> see `docs/AGENTS.md`.

---

## Contexts — The Public API of Business Logic

A context is a plain Elixir module that groups related functionality behind a
clean public API. LiveViews call contexts. Contexts call Ecto. Nothing else
touches the database.

```elixir
defmodule MyApp.Infrastructure do
  @moduledoc """
  The Infrastructure context.
  Manages clusters, nodes, and pods.
  """

  import Ecto.Query

  alias MyApp.Repo
  alias MyApp.Infrastructure.{Cluster, Node, Pod}

  # --- Clusters ---

  @doc "Lists all clusters for a team, ordered by name."
  def list_clusters(team_id) do
    Cluster
    |> where(team_id: ^team_id)
    |> order_by(:name)
    |> Repo.all()
  end

  @doc "Gets a single cluster. Raises if not found."
  def get_cluster!(id), do: Repo.get!(Cluster, id)

  @doc "Creates a cluster with the given attributes."
  def create_cluster(team_id, attrs) do
    %Cluster{team_id: team_id}
    |> Cluster.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:cluster_created)
  end

  @doc "Deletes a cluster."
  def delete_cluster(%Cluster{} = cluster) do
    Repo.delete(cluster)
    |> broadcast(:cluster_deleted)
  end

  # --- PubSub ---

  @doc "Subscribe the calling process to team infrastructure events."
  def subscribe(team_id) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "team:#{team_id}")
  end

  defp broadcast({:ok, entity} = result, event) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, "team:#{entity.team_id}", {event, entity})
    result
  end

  defp broadcast({:error, _} = result, _event), do: result
end
```

### Context rules

- One context per business domain. Don't mix concerns.
- Public functions return `{:ok, result}` or `{:error, changeset}` for writes.
- Return bare values for reads: `list_clusters/1` returns a list, `get_cluster!/1` raises.
- PubSub broadcasting happens inside the context, after successful DB operations.
- Queries belong in the context module. Extract to a private `Query` module only for genuinely complex ones.
- Never expose Ecto queries outside the context — return data, not queryables.

---

## Schemas and Changesets

Schemas define data shape. Changesets validate and transform input.

```elixir
defmodule MyApp.Infrastructure.Cluster do
  @moduledoc "A managed infrastructure cluster."

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "clusters" do
    field :name, :string
    field :region, :string
    field :status, Ecto.Enum, values: [:provisioning, :running, :failed, :deleting]
    field :metadata, :map, default: %{}

    belongs_to :team, MyApp.Accounts.Team
    has_many :pods, MyApp.Infrastructure.Pod

    timestamps(type: :utc_datetime)
  end

  @required ~w(name region team_id)a
  @optional ~w(metadata)a

  @doc "Changeset for creating or updating a cluster."
  def changeset(cluster, attrs) do
    cluster
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_length(:name, min: 1, max: 63)
    |> validate_format(:name, ~r/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/,
         message: "must be lowercase alphanumeric with hyphens")
    |> unique_constraint([:name, :team_id])
    |> foreign_key_constraint(:team_id)
  end
end
```

### Schema rules

- Always define `@type t :: %__MODULE__{}`.
- Always use `timestamps(type: :utc_datetime)` — UTC everywhere.
- Use `Ecto.Enum` for status fields — compile-time safety, DB-level constraints.
- Group required and optional fields as module attributes for clarity.
- Validation lives in the changeset. Business rules live in the context.
- Use JSONB (`field :metadata, :map`) for flexible data that doesn't need its own table.
- Name changesets `changeset/2`. Use separate functions for specific cases: `status_changeset/2`.

---

## Ecto Queries

```elixir
# Simple — inline in the context.
def list_running_pods(cluster_id) do
  Pod
  |> where(cluster_id: ^cluster_id, status: :running)
  |> order_by(:name)
  |> Repo.all()
end

# With preloads.
def get_cluster_with_pods!(id) do
  Cluster
  |> Repo.get!(id)
  |> Repo.preload(:pods)
end

# Complex — extract to a function with keyword options.
def list_pods_by_usage(cluster_id, opts \\ []) do
  limit = Keyword.get(opts, :limit, 50)
  min_cpu = Keyword.get(opts, :min_cpu, 0)

  Pod
  |> where(cluster_id: ^cluster_id)
  |> where([p], p.cpu_usage >= ^min_cpu)
  |> order_by([p], desc: p.cpu_usage)
  |> limit(^limit)
  |> Repo.all()
end
```

### Query rules

- Always use parameterized queries (the `^` pin operator) — never interpolate.
- Use keyword syntax `where(status: :running)` for simple conditions.
- Use expression syntax `where([p], p.cpu_usage >= ^min)` for complex conditions.
- Preload associations explicitly — Ecto has no lazy loading by design.
- `Repo.all/1` for lists, `Repo.one/1` for optional single results, `Repo.get!/2` for required lookups.

---

## Migrations

```elixir
defmodule MyApp.Repo.Migrations.CreateClusters do
  use Ecto.Migration

  def change do
    create table(:clusters) do
      add :name, :string, null: false
      add :region, :string, null: false
      add :status, :string, null: false, default: "provisioning"
      add :metadata, :map, default: %{}
      add :team_id, references(:teams, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:clusters, [:team_id])
    create unique_index(:clusters, [:name, :team_id])
  end
end
```

### Migration rules

- Always `null: false` on required fields — enforce at the database level.
- Always add indexes on foreign keys and frequently queried columns.
- Always add unique indexes to back `unique_constraint` in changesets.
- Use `on_delete: :restrict` when deletion should be prevented, `:delete_all` for cascades.
- Use `change/0` for reversible migrations. Use `up/down` only for irreversible ones.

---

## PubSub Patterns

### Topic naming

```
"team:#{team_id}"                  — team-level events (clusters, members)
"cluster:#{cluster_id}"            — cluster-level events (pods, nodes)
"deployment:#{deployment_id}"      — deployment-specific events
"user:#{user_id}"                  — user-specific notifications
"system:alerts"                    — system-wide alerts
```

### Message format

Always tagged tuples: `{:event_name, payload}`.

```elixir
# Broadcasting (inside a context).
Phoenix.PubSub.broadcast(MyApp.PubSub, "cluster:#{id}", {:pod_updated, pod})

# Receiving (in a LiveView).
def handle_info({:pod_updated, pod}, socket) do
  {:noreply, stream_insert(socket, :pods, pod)}
end
```

### Subscribe in mount, guarded

```elixir
def mount(params, _session, socket) do
  if connected?(socket) do
    MyApp.Infrastructure.subscribe(params["team_id"])
  end
  # ...
end
```

The `if connected?(socket)` guard is critical — `mount` runs twice: once for
the initial HTTP render (PubSub useless) and once for the WebSocket connection.

---

## Oban — Background Jobs

### Worker pattern

```elixir
defmodule MyApp.Workers.ProvisionClusterWorker do
  @moduledoc "Provisions a cluster on the infrastructure layer."

  use Oban.Worker,
    queue: :infrastructure,
    max_attempts: 5,
    unique: [period: 60, fields: [:args]]

  alias MyApp.Infrastructure

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"cluster_id" => cluster_id}}) do
    cluster = Infrastructure.get_cluster!(cluster_id)

    case Infrastructure.provision_to_provider(cluster) do
      {:ok, _result} ->
        Infrastructure.update_cluster_status(cluster, :running)
        :ok

      {:error, :rate_limited} ->
        {:snooze, 30}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
```

### Enqueueing from a context with Ecto.Multi

```elixir
def create_cluster(team_id, attrs) do
  Multi.new()
  |> Multi.insert(:cluster, Cluster.changeset(%Cluster{team_id: team_id}, attrs))
  |> Multi.run(:enqueue, fn _repo, %{cluster: cluster} ->
    %{cluster_id: cluster.id}
    |> MyApp.Workers.ProvisionClusterWorker.new()
    |> Oban.insert()
  end)
  |> Repo.transaction()
  |> case do
    {:ok, %{cluster: cluster}} -> broadcast({:ok, cluster}, :cluster_created)
    {:error, :cluster, changeset, _} -> {:error, changeset}
  end
end
```

### Worker rules

- Workers must be idempotent — running the same job twice produces the same result.
- Keep job args minimal — store IDs, not full objects. Fetch fresh data in `perform/1`.
- Use `Ecto.Multi` to insert the job in the same transaction as the triggering DB change.
- Use `unique` to prevent duplicate jobs.
- Return `:ok` for success, `{:error, reason}` for retryable failure, `{:snooze, seconds}` for temporary backoff, `{:cancel, reason}` for permanent failure.
- Workers live in `lib/my_app/workers/` — they're business logic, not web layer.
- Use descriptive queue names: `:infrastructure`, `:notifications`, `:billing`, `:cleanup`.

---

## Multi-Step Operations with Ecto.Multi

When an operation involves multiple writes that must all succeed or all fail:

```elixir
alias Ecto.Multi

def transfer_pod(pod, from_cluster, to_cluster) do
  Multi.new()
  |> Multi.update(:detach, Pod.changeset(pod, %{cluster_id: nil, status: :pending}))
  |> Multi.run(:provision, fn _repo, %{detach: pod} ->
    %{pod_id: pod.id, target_cluster_id: to_cluster.id}
    |> MyApp.Workers.MigratePodWorker.new()
    |> Oban.insert()
  end)
  |> Repo.transaction()
end
```

If you're calling `Repo.insert` and `Repo.update` separately and they must be
atomic, use `Multi`.

---

## Configuration

```elixir
# config/config.exs — shared.
config :my_app, Oban,
  repo: MyApp.Repo,
  queues: [infrastructure: 10, default: 10, notifications: 5, billing: 3]

# config/dev.exs
config :my_app, MyApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "my_app_dev"

# config/runtime.exs — production (reads from environment).
config :my_app, MyApp.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))
```

Never hardcode secrets or environment-specific values. Use `config/runtime.exs`
with `System.get_env/1` for production.
