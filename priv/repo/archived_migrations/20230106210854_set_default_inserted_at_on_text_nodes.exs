defmodule TextServer.Repo.Migrations.SetDefaultInsertedAtOnTextNodes do
  use Ecto.Migration

  def change do
    alter table(:text_nodes) do
      modify(:inserted_at, :naive_datetime,
        default: fragment("now()"),
        from: {:naive_datetime, default: nil}
      )

      modify(:updated_at, :naive_datetime,
        default: fragment("now()"),
        from: {:naive_datetime, default: nil}
      )
    end
  end
end
