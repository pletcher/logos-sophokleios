defmodule TextServer.Repo.Migrations.ChangePassages do
  use Ecto.Migration

  def change do
    alter table("version_passages") do
      modify :end_location, {:array, :string}, from: {:array, :integer}
      modify :start_location, {:array, :string}, from: {:array, :integer}
    end
  end
end
