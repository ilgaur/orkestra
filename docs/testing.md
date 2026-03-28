# Testing Rules

> Writing, reviewing, and debugging tests. Every piece of shipped code has
> corresponding tests.
>
> For general Elixir code conventions, see `docs/AGENTS.md`.
> For installing and using Chrome DevTools MCP with Phoenix, see `docs/chrome-devtools-mcp.md`.

---

## What to Test at Each Layer

| Layer | What to test | Tool | Priority |
|---|---|---|---|
| Schemas | Changeset validations, field constraints | ExUnit | High |
| Contexts | Business logic, query correctness, PubSub broadcasts | ExUnit + Ecto sandbox | High |
| Oban Workers | Job execution, retry behavior, idempotency | ExUnit + Oban.Testing | High |
| LiveViews | Rendering, user interactions, PubSub reactions | Phoenix.LiveViewTest | High |
| Components | Render output, assign variations | Phoenix.LiveViewTest | Medium |
| Hooks + E2E | Real browser behavior, JS interactions | Playwright | When hooks exist |
| Live browser pass | Console, network, DOM, screenshots, performance | [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) | After hooks/assets/layout work; before production-done UI |

---

## Test Structure — Mirrors Source

```
test/
├── my_app/                              # Mirrors lib/my_app/
│   ├── infrastructure_test.exs          # Context tests
│   ├── infrastructure/
│   │   └── cluster_test.exs             # Schema/changeset tests
│   ├── accounts_test.exs
│   └── workers/
│       └── provision_cluster_worker_test.exs
│
├── my_app_web/                          # Mirrors lib/my_app_web/
│   ├── live/
│   │   └── cluster_live/
│   │       └── index_test.exs           # LiveView tests
│   └── components/
│       └── ui/
│           └── button_test.exs          # Component tests (when complex)
│
├── support/
│   ├── fixtures/                        # Factory functions
│   │   ├── infrastructure_fixtures.ex
│   │   └── accounts_fixtures.ex
│   ├── conn_case.ex
│   └── data_case.ex
│
└── test_helper.exs
```

---

## Schema / Changeset Tests

Test that validation rules work correctly.

```elixir
defmodule MyApp.Infrastructure.ClusterTest do
  use MyApp.DataCase, async: true

  alias MyApp.Infrastructure.Cluster

  describe "changeset/2" do
    test "valid attributes produce a valid changeset" do
      attrs = %{name: "production", region: "us-east-1", team_id: 1}

      changeset = Cluster.changeset(%Cluster{}, attrs)
      assert changeset.valid?
    end

    test "requires name" do
      changeset = Cluster.changeset(%Cluster{}, %{region: "us-east-1"})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates name format" do
      changeset = Cluster.changeset(%Cluster{}, %{name: "Invalid_Name!"})
      assert %{name: ["must be lowercase alphanumeric with hyphens"]} = errors_on(changeset)
    end
  end
end
```

---

## Context Tests

Test business logic, database operations, and PubSub broadcasts.

```elixir
defmodule MyApp.InfrastructureTest do
  use MyApp.DataCase, async: true

  alias MyApp.Infrastructure

  import MyApp.InfrastructureFixtures
  import MyApp.AccountsFixtures

  describe "list_clusters/1" do
    test "returns clusters for a given team" do
      team = team_fixture()
      cluster = cluster_fixture(team_id: team.id)
      _other = cluster_fixture(team_id: team_fixture().id)

      assert Infrastructure.list_clusters(team.id) == [cluster]
    end

    test "returns empty list when no clusters exist" do
      team = team_fixture()
      assert Infrastructure.list_clusters(team.id) == []
    end
  end

  describe "create_cluster/2" do
    test "creates a cluster with valid attributes" do
      team = team_fixture()

      assert {:ok, cluster} =
               Infrastructure.create_cluster(team.id, %{
                 name: "production",
                 region: "us-east-1"
               })

      assert cluster.name == "production"
      assert cluster.status == :provisioning
    end

    test "returns error changeset with invalid attributes" do
      team = team_fixture()
      assert {:error, changeset} = Infrastructure.create_cluster(team.id, %{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "broadcasts cluster_created event" do
      team = team_fixture()
      Infrastructure.subscribe(team.id)

      {:ok, cluster} =
        Infrastructure.create_cluster(team.id, %{name: "staging", region: "eu-west-1"})

      assert_receive {:cluster_created, ^cluster}
    end
  end
end
```

---

## Fixture Functions

Factory functions that create test data. Keep them simple and composable.

```elixir
defmodule MyApp.InfrastructureFixtures do
  @moduledoc "Test fixtures for the Infrastructure context."

  alias MyApp.Repo
  alias MyApp.Infrastructure.{Cluster, Pod}

  def cluster_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "cluster-#{System.unique_integer([:positive])}",
        region: "us-east-1"
      })

    %Cluster{}
    |> Cluster.changeset(attrs)
    |> Repo.insert!()
  end

  def pod_fixture(attrs \\ %{}) do
    cluster_id = attrs[:cluster_id] || cluster_fixture().id

    attrs =
      Enum.into(attrs, %{
        name: "pod-#{System.unique_integer([:positive])}",
        status: :running,
        cpu_limit: 500,
        memory_limit: 256,
        cluster_id: cluster_id
      })

    %Pod{}
    |> Pod.changeset(attrs)
    |> Repo.insert!()
  end
end
```

### Fixture rules

- Use `System.unique_integer([:positive])` for unique names.
- Provide sensible defaults for all required fields.
- Accept overrides via `attrs` parameter.
- One fixture file per context in `test/support/fixtures/`.

---

## LiveView Tests

Test rendering, user interactions, and PubSub reactions.

```elixir
defmodule MyAppWeb.ClusterLive.IndexTest do
  use MyAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MyApp.InfrastructureFixtures
  import MyApp.AccountsFixtures

  describe "Index" do
    setup do
      team = team_fixture()
      %{team: team}
    end

    test "renders cluster list", %{conn: conn, team: team} do
      cluster_fixture(team_id: team.id, name: "production")

      {:ok, _view, html} = live(conn, ~p"/teams/#{team.id}/clusters")

      assert html =~ "production"
    end

    test "updates when cluster status changes via PubSub", %{conn: conn, team: team} do
      cluster = cluster_fixture(team_id: team.id, status: :provisioning)

      {:ok, view, _html} = live(conn, ~p"/teams/#{team.id}/clusters")

      updated = %{cluster | status: :running}
      Phoenix.PubSub.broadcast(MyApp.PubSub, "team:#{team.id}", {:cluster_created, updated})

      assert render(view) =~ "running"
    end

    test "deletes a cluster", %{conn: conn, team: team} do
      cluster = cluster_fixture(team_id: team.id)

      {:ok, view, _html} = live(conn, ~p"/teams/#{team.id}/clusters")

      view
      |> element("[phx-click='delete_cluster'][phx-value-id='#{cluster.id}']")
      |> render_click()

      refute render(view) =~ cluster.name
    end
  end
end
```

---

## Oban Worker Tests

```elixir
defmodule MyApp.Workers.ProvisionClusterWorkerTest do
  use MyApp.DataCase, async: true
  use Oban.Testing, repo: MyApp.Repo

  alias MyApp.Workers.ProvisionClusterWorker

  import MyApp.InfrastructureFixtures

  test "provisions a cluster successfully" do
    cluster = cluster_fixture(status: :provisioning)

    assert :ok = perform_job(ProvisionClusterWorker, %{cluster_id: cluster.id})

    updated = MyApp.Infrastructure.get_cluster!(cluster.id)
    assert updated.status == :running
  end

  test "job is enqueued when cluster is created" do
    team = MyApp.AccountsFixtures.team_fixture()

    {:ok, cluster} =
      MyApp.Infrastructure.create_cluster(team.id, %{name: "test", region: "us-east-1"})

    assert_enqueued(worker: ProvisionClusterWorker, args: %{cluster_id: cluster.id})
  end
end
```

---

## Parameterized Tests (Elixir 1.18+)

Run the same test module under different configurations using ExUnit's
parameterized test support. Useful for testing behavior across database
adapters, feature flags, or configuration variants.

```elixir
defmodule MyApp.Infrastructure.ValidationTest do
  use MyApp.DataCase, async: true, parameterize: [
    %{region: "us-east-1", valid: true},
    %{region: "eu-west-1", valid: true},
    %{region: "", valid: false}
  ]

  test "validates region", %{region: region, valid: expected} do
    changeset = Cluster.changeset(%Cluster{}, %{name: "test", region: region, team_id: 1})
    assert changeset.valid? == expected
  end
end
```

---

## Assertion Style

Put the expression being tested on the left, expected result on the right —
unless the assertion is a pattern match.

```elixir
# DO: actual on the left.
assert Infrastructure.list_clusters(team.id) == []
assert length(results) == 3

# DO: pattern match when destructuring.
assert {:ok, cluster} = Infrastructure.create_cluster(team.id, attrs)
assert %{name: "production"} = cluster

# DON'T: expected on the left.
assert [] == Infrastructure.list_clusters(team.id)
```

---

## Test Rules Summary

- Every context function gets at least a happy path and an error path test.
- Every changeset gets validation tests for required fields and custom validations.
- Every Oban worker gets a `perform_job` test and an `assert_enqueued` test.
- Every LiveView page gets a render test and interaction tests for key user flows.
- PubSub broadcasts are tested by subscribing in the test and using `assert_receive`.
- Use `async: true` on all tests that don't share state — runs them in parallel.
- Use the Ecto sandbox (`DataCase`) — each test gets an isolated transaction that rolls back.
- Test names describe behavior: `"creates a cluster with valid attributes"`, not `"test create"`.
