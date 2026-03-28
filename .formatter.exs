# Formatter configuration — applies to `mix format`.
# TailwindFormatter sorts Tailwind classes in HEEx templates.
# Activates when the umbrella app is scaffolded and deps are installed.
[
  plugins: [],
  inputs: [
    "{mix,.formatter,.credo,.check}.exs",
    "{config,lib,test}/**/*.{ex,exs,heex}",
    "apps/*/lib/**/*.{ex,exs,heex}",
    "apps/*/test/**/*.{ex,exs,heex}",
    "apps/*/{config,priv}/**/*.{ex,exs}"
  ]
]
