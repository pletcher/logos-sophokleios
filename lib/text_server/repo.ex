defmodule TextServer.Repo do
  use Ecto.Repo,
    otp_app: :text_server,
    adapter: Ecto.Adapters.Postgres
end
