# ex_check configuration — run all quality tools with `mix check`.
# Activates when the umbrella app is scaffolded and ex_check is installed.
[
  tools: [
    {:compiler, command: "mix compile --warnings-as-errors"},
    {:formatter, command: "mix format --check-formatted"},
    {:credo, command: "mix credo --strict"},
    {:sobelow, command: "mix sobelow --exit", enabled: true},
    {:dialyzer, command: "mix dialyzer", enabled: false},
    {:ex_unit, command: "mix test"}
  ]
]
