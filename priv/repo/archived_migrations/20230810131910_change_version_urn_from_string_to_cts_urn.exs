defmodule TextServer.Repo.Migrations.ChangeVersionUrnFromStringToCtsUrn do
  use Ecto.Migration

  alias CTS
  alias TextServer.Repo
  alias TextServer.Versions
  alias TextServer.Versions.Version

  def change do
    alter table(:versions) do
      add :cts_urn, :map
    end

    flush()

    Version |> Repo.all() |> Enum.each(fn version ->
      Versions.update_version(version, %{cts_urn: version.urn})
    end)

    alter table(:versions) do
      remove :urn
    end

    flush()

    rename table(:versions), :cts_urn, to: :urn

    create unique_index(:versions, :urn)
  end
end
