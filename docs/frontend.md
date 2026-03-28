# Frontend Rules

> UI: components, LiveView pages, hooks, styling, design tokens, and anything
> the user sees.
>
> For general Elixir code conventions, see `docs/AGENTS.md`.
> For the design system process and Figma workflow, see `docs/workflow.md`.
> For design taste, composition, and motion guidance, see `.agents/skills/frontend-design/SKILL.md`.
> For token foundations, see `docs/design-system.md`. For skill routing, see `docs/SKILLS.md`.

---

## Core Mental Model

LiveView owns **state and data flow**. Hooks own **heavy client rendering**.
Function components own **markup and styling**. Tailwind config owns **design tokens**.

Everything flows from the server unless it physically cannot (canvas rendering,
terminal emulation, scroll-position logic). When in doubt, do it in LiveView.

---

## Component Architecture — Three Layers

### Layer 1: `ui/` — Design System Primitives

Pure function components. No domain knowledge. No state.
Accept assigns, render markup with Tailwind classes, compose via slots.

```elixir
defmodule MyAppWeb.UI.Button do
  @moduledoc "Button component with variant and size support."

  use Phoenix.Component

  attr :variant, :string, default: "primary", values: ~w(primary secondary danger ghost)
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(type form phx-click phx-disable-with)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      class={[
        "inline-flex items-center justify-center font-medium rounded-lg transition-colors",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        variant_classes(@variant),
        size_classes(@size),
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ]}
      disabled={@disabled}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp variant_classes("primary"), do: "bg-primary text-primary-foreground hover:bg-primary/90"
  defp variant_classes("secondary"), do: "bg-secondary text-secondary-foreground hover:bg-secondary/90"
  defp variant_classes("danger"), do: "bg-destructive text-destructive-foreground hover:bg-destructive/90"
  defp variant_classes("ghost"), do: "hover:bg-accent hover:text-accent-foreground"

  defp size_classes("sm"), do: "h-8 px-3 text-xs"
  defp size_classes("md"), do: "h-10 px-4 text-sm"
  defp size_classes("lg"), do: "h-12 px-6 text-base"
end
```

**Rules for `ui/` components:**

- Always use `attr` declarations with types, defaults, and allowed values.
- Always accept a `class` assign for override styling.
- Always accept `rest` as `:global` for pass-through HTML attributes.
- Always use `slot` for flexible content injection.
- Never reference domain concepts (no pods, deployments, users).
- Never call contexts or access data — receive everything via assigns.
- Use private helpers for variant/size class mapping.

### Layer 2: `domain/` — Domain-Specific Composed Components

Compose `ui/` primitives with domain knowledge. Still function components, still stateless.

```elixir
defmodule MyAppWeb.Domain.ClusterCard do
  @moduledoc "Displays a cluster's status with visual indicators."

  use Phoenix.Component

  import MyAppWeb.UI.Badge
  import MyAppWeb.UI.Card

  attr :cluster, :map, required: true
  attr :class, :string, default: nil

  def cluster_card(assigns) do
    ~H"""
    <.card class={@class}>
      <:header>
        <div class="flex items-center justify-between">
          <span class="font-mono text-sm">{@cluster.name}</span>
          <.badge variant={status_variant(@cluster.status)}>
            {@cluster.status}
          </.badge>
        </div>
      </:header>
      <:body>
        <dl class="grid grid-cols-2 gap-2 text-sm">
          <dt class="text-muted-foreground">Region</dt>
          <dd>{@cluster.region}</dd>
          <dt class="text-muted-foreground">Nodes</dt>
          <dd>{@cluster.node_count}</dd>
        </dl>
      </:body>
    </.card>
    """
  end

  defp status_variant(:running), do: "success"
  defp status_variant(:provisioning), do: "warning"
  defp status_variant(:failed), do: "danger"
  defp status_variant(_), do: "default"
end
```

**Rules for `domain/` components:**

- Import and compose `ui/` components — don't duplicate their markup.
- Can reference domain concepts (cluster status, deployment states).
- Still stateless — receive all data via assigns.
- Keep domain logic minimal — format/map data for display, nothing more.

### Layer 3: `interactive/` — Stateful LiveComponents with Hooks

For UI that needs its own state or requires JavaScript interop.
Use colocated hooks (LiveView 1.1) to keep JS with its component.

```elixir
defmodule MyAppWeb.Interactive.MetricsChart do
  @moduledoc """
  Real-time metrics chart using Chart.js via a colocated hook.
  LiveView pushes data → hook renders the canvas.
  """

  use MyAppWeb, :live_component

  attr :id, :string, required: true
  attr :series, :list, required: true
  attr :chart_type, :string, default: "line"

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <canvas
        id={"#{@id}-canvas"}
        phx-hook={".MetricsChart"}
        phx-update="ignore"
        data-chart-type={@chart_type}
        data-series={JSON.encode!(@series)}
        class="w-full h-64"
      />

      <script :type={Phoenix.LiveView.ColocatedHook} name=".MetricsChart">
        import Chart from "chart.js/auto"

        export default {
          mounted() {
            const ctx = this.el.getContext("2d")
            const data = JSON.parse(this.el.dataset.series)
            const type = this.el.dataset.chartType

            this.chart = new Chart(ctx, {
              type,
              data,
              options: { responsive: true, maintainAspectRatio: false }
            })

            this.handleEvent("update_series", ({ series }) => {
              this.chart.data = series
              this.chart.update("none")
            })
          },

          destroyed() {
            this.chart?.destroy()
          }
        }
      </script>
    </div>
    """
  end
end
```

**Rules for `interactive/` components:**

- Always use `phx-update="ignore"` on the container the hook owns.
- Always implement `destroyed()` in hooks to clean up resources.
- Always use `handleEvent` for server → hook, `pushEvent` for hook → server.
- Give hook elements a stable `id` that doesn't change between renders.
- Use colocated hooks (`.HookName` with leading dot) for component-specific JS.
- Use shared hooks in `assets/js/hooks/` only for hooks used across multiple components.
- Keep hook code minimal — delegate to third-party libraries.

---

## Growing the component tree (highly custom UI)

The three layers stay fixed: **`ui/` → `domain/` → `interactive/`**. What **scales**
is how you subdivide `ui/` — not how many top-level buckets you invent.

**Start simple:** flat modules under `components/ui/` (e.g. `button.ex`, `input.ex`).
Phoenix resolves `MyAppWeb.UI.*` the same whether files are flat or nested.

**Split when** any of these is true (agents should **say so proactively** before the folder hurts):

- About **~12–15+ unrelated** primitives in one folder and names collide or grep gets noisy.
- Clear **families** emerge: forms, data display, navigation, overlays, feedback.
- Multiple authors keep editing the same directory and causing merge pain.

**How to split (examples):**

```text
components/ui/
├── forms/          # input, select, field_group, …
├── data_display/   # table, badge, stat, …
├── navigation/     # tabs, breadcrumb, …
├── overlays/       # modal, dropdown, …
└── …
```

Use **one namespace per folder** (e.g. `MyAppWeb.UI.Forms.TextInput`) and update imports
in `my_app_web.ex` if you centralize `import`. Document the split in a short ADR or a
paragraph in this file — not a new top-level layer like `widgets/` unless an ADR says why.

**`domain/`** can gain subfolders by **bounded context** if it grows (e.g.
`domain/infrastructure/cluster_card.ex`) — same trigger: pain, not anticipation.

---

## LiveView Page Rules

LiveViews are pages. They handle routing, subscribe to PubSub, manage page state,
and render by composing components.

```elixir
defmodule MyAppWeb.ClusterLive.Index do
  @moduledoc "Cluster overview page."

  use MyAppWeb, :live_view

  alias MyApp.Infrastructure

  @impl true
  def mount(%{"team_id" => team_id}, _session, socket) do
    if connected?(socket) do
      Infrastructure.subscribe(team_id)
    end

    clusters = Infrastructure.list_clusters(team_id)

    {:ok,
     socket
     |> assign(:team_id, team_id)
     |> assign(:page_title, "Clusters")
     |> stream(:clusters, clusters)}
  end

  @impl true
  def handle_info({:cluster_created, cluster}, socket) do
    {:noreply, stream_insert(socket, :clusters, cluster)}
  end

  def handle_info({:cluster_deleted, cluster}, socket) do
    {:noreply, stream_delete(socket, :clusters, cluster)}
  end

  @impl true
  def handle_event("delete_cluster", %{"id" => id}, socket) do
    cluster = Infrastructure.get_cluster!(id)
    {:ok, _} = Infrastructure.delete_cluster(cluster)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <header class="flex items-center justify-between">
        <h1 class="text-2xl font-semibold">{@page_title}</h1>
        <.button phx-click="new_cluster">Create Cluster</.button>
      </header>

      <div id="clusters" phx-update="stream" class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <div :for={{dom_id, cluster} <- @streams.clusters} id={dom_id}>
          <.cluster_card cluster={cluster} />
        </div>
      </div>
    </div>
    """
  end
end
```

### LiveView rules

- Subscribe to PubSub in `mount`, guarded by `if connected?(socket)`.
- Always use `@impl true` on callback functions.
- Use `stream` for lists of items — memory-efficient and diff-friendly.
- Keep LiveViews thin — no business logic, no database queries. Call contexts only.
- `handle_info` for PubSub messages. `handle_event` for user interactions.
- One LiveView per route. Extract to LiveComponent only when independent state is needed.

---

## LiveView.JS — Client Commands Without JavaScript

For show/hide, transitions, class toggles, and micro-animations — use
`Phoenix.LiveView.JS` instead of custom JS. These execute on the client,
survive DOM patches, and don't round-trip to the server.

```elixir
alias Phoenix.LiveView.JS

def show_modal(js \\ %JS{}, id) do
  js
  |> JS.show(to: "##{id}-bg", transition: {"ease-out duration-300", "opacity-0", "opacity-100"})
  |> JS.show(to: "##{id}-container", transition: {"ease-out duration-300", "opacity-0 translate-y-4", "opacity-100 translate-y-0"})
  |> JS.focus_first(to: "##{id}-content")
end

def hide_modal(js \\ %JS{}, id) do
  js
  |> JS.hide(to: "##{id}-bg", transition: {"ease-in duration-200", "opacity-100", "opacity-0"})
  |> JS.hide(to: "##{id}-container", transition: {"ease-in duration-200", "opacity-100 translate-y-0", "opacity-0 translate-y-4"})
  |> JS.pop_focus()
end
```

**Use JS commands for:** modals, dropdowns, tooltips, slide-overs, accordions,
tab switches, loading states, toast notifications.

**Use Hooks for:** continuous rendering (charts, maps), third-party library
integration (xterm, editors), scroll-position logic, complex animations.

---

## Design Tokens and Tailwind

`tailwind.config.js` is the single source of truth for all design values.
Every color, spacing, font, shadow, and radius used in the app must be defined there.

```javascript
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/my_app_web.ex",
    "../lib/my_app_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))"
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))"
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))"
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))"
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))"
        },
        status: {
          running: "hsl(var(--status-running))",
          pending: "hsl(var(--status-pending))",
          failed: "hsl(var(--status-failed))",
          stopped: "hsl(var(--status-stopped))"
        }
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)"
      },
      fontFamily: {
        sans: ["var(--font-sans)"],
        mono: ["var(--font-mono)"]
      }
    }
  }
}
```

### Styling rules

- Never hardcode color values — use token names (`bg-primary`, `text-muted-foreground`).
- Never write custom CSS files — use Tailwind utilities exclusively.
- Use CSS custom properties (HSL variables) in `app.css` so themes can be swapped.
- Use `font-mono` for technical values (names, IDs, resource amounts, logs).
- Use `font-sans` for all other text.

---

## Accessibility Minimums

- All interactive elements must be keyboard accessible.
- Modals trap focus (`JS.focus_first` and `JS.pop_focus`).
- Use semantic HTML: `<button>` for actions, `<a>` for navigation, `<nav>`, `<main>`, `<header>`.
- Respect `prefers-reduced-motion` via `motion-safe:` and `motion-reduce:` Tailwind variants.
- Status indicators must not rely on color alone — include text or icon labels.
- Form inputs must have associated `<label>` elements.

---

## Performance Rules

- Use `stream` for any list that could exceed 20 items.
- Use `phx-debounce` on search inputs (300ms default).
- Use `phx-throttle` on high-frequency events (scroll, resize) at 100ms.
- Use `assign_async` for data that doesn't block initial render.
- Use `phx-update="ignore"` on hook-owned DOM to prevent unnecessary patching.
- Lazy-load images with `loading="lazy"` and set explicit `width`/`height`.
- Keep render functions under 50 lines — decompose into smaller components.
