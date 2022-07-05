defmodule TextServer.Repo do
  use Ecto.Repo,
    otp_app: :text_server,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
