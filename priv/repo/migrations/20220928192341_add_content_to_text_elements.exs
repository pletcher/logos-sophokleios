defmodule TextServer.Repo.Migrations.AddContentToTextElements do
  use Ecto.Migration

  def change do
    alter table(:text_elements) do
      add :content, :text
    end
  end
end
