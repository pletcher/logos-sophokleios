[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Phoenix.LivewView.HTMLFormatter],
  subdirectories: ["priv/*/migrations"]
]
