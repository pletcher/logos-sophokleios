defmodule TextServer.Repo.Migrations.MergeExemplarsIntoVersions do
  use Ecto.Migration

  alias TextServer.Exemplars
  alias TextServer.Repo
  alias TextServer.Projects
  alias TextServer.Projects.Exemplar, as: ProjectExemplar
  alias TextServer.Projects.Version, as: ProjectVersion
  alias TextServer.Versions

  def change do
    create table(:project_versions) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :version_id, references(:versions, on_delete: :delete_all)

      timestamps()
    end

    alter table(:versions) do
      add(:title, :string)
      add(:language_id, references(:languages, on_delete: :delete_all))
    end

    flush()

    change_project_exemplars_to_versions()
    merge_exemplars_and_versions()

    alter table(:exemplars) do
      remove(:language_id)
      remove(:title)
      remove(:urn)
    end
  end

  defp change_project_exemplars_to_versions do
    ProjectExemplar
    |> Repo.all()
    |> Repo.preload([:project, :exemplar])
    |> Enum.each(fn pe ->
      version = Versions.get_version_by_urn!(pe.exemplar.urn)
      Projects.create_project_version(pe.project, version)
      Repo.delete!(pe)
    end)
  end

  defp merge_exemplars_and_versions do
    Exemplars.list_exemplars()
    |> Enum.each(fn e ->
      version = Versions.get_version_by_urn!(e.urn)

      Versions.update_version(version, %{
        language_id: e.language_id,
        source: e.source,
        source_link: e.source_link,
        title: e.title
      })

      Exemplars.delete_exemplar(e)
    end)
  end
end
