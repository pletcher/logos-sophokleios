defmodule TextServer.Repo.Migrations.MergeExemplarsIntoVersions do
  use Ecto.Migration

  import Ecto.Query

  alias TextServer.Exemplars
  alias TextServer.Exemplars.Page
  alias TextServer.Repo
  alias TextServer.Projects
  alias TextServer.Projects.Exemplar, as: ProjectExemplar
  alias TextServer.Projects.Version, as: ProjectVersion
  alias TextServer.Versions
  alias TextServer.Versions.Passage

  def change do
    create_if_not_exists table(:project_versions) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :version_id, references(:versions, on_delete: :delete_all)

      timestamps()
    end

    create_if_not_exists table(:version_passages) do
      add :passage_number, :integer, null: false
      add :end_location, {:array, :integer}, null: false
      add :start_location, {:array, :integer}, null: false
      add(:version_id, references(:versions, on_delete: :delete_all))
    end

    alter table(:versions) do
      # filemd5hash should be not null and unique
      add(:filemd5hash, :string)
      # filename should be not null
      add(:filename, :string)
      # add(:language_id, references(:languages, on_delete: :delete_all))
      add(:parsed_at, :naive_datetime)
      add(:source, :string)
      add(:source_link, :string)
      add(:tei_header, :map, default: %{})
    end

    alter table(:text_nodes) do
      add(:version_id, references(:versions, on_delete: :delete_all))
    end

    flush()

    change_project_exemplars_to_versions()
    merge_exemplars_and_versions()
    move_exemplar_pages_to_version_passages()

    alter table(:text_nodes) do
      remove(:exemplar_id)
    end

    drop table(:exemplar_pages)
    drop table(:project_exemplars)
    drop table(:exemplars)
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

  defp move_exemplar_pages_to_version_passages do
    Page
    |> Repo.all()
    |> Enum.each(fn p ->
      exemplar = Exemplars.get_exemplar!(p.exemplar_id)
      version = Versions.get_version_by_urn!(exemplar.urn)

      Versions.create_passage(%{
        end_location: p.end_location,
        version_id: version.id,
        passage_number: p.page_number,
        start_location: p.start_location
      })
    end)
  end


  defp merge_exemplars_and_versions do
    Exemplars.list_exemplars()
    |> Enum.each(fn e ->
      version = Versions.get_version_by_urn!(e.urn)

      Versions.update_version(version, %{
        filemd5hash: e.filemd5hash,
        filename: e.filename,
        language_id: e.language_id,
        parsed_at: e.parsed_at,
        source: e.source,
        source_link: e.source_link,
        tei_header: e.tei_header
      })

      q = from(t in TextNode, where: t.exemplar_id == ^e.id, update: [set: [version_id: ^version.id]])

      Repo.update_all(q, [])
    end)
  end
end
