defmodule TextServer.Repo.Migrations.CreateXmlDocuments do
  use Ecto.Migration

  alias TextServer.Repo
  alias TextServer.Versions
  alias TextServer.Versions.Version
  alias TextServer.Versions.XmlDocument

  def up do
    create table(:xml_documents) do
      add(:document, :xml, null: false)
      add(:version_id, references(:versions, on_delete: :delete_all))

      timestamps()
    end

    flush()

    cwd = File.cwd!()

    Repo.transaction(fn ->
      Version
      |> Repo.stream()
      |> Enum.each(fn version ->
        IO.puts("#{version.filename}")

        if String.ends_with?(version.filename, ".xml") do
          case File.read(version.filename) do
            {:ok, doc} ->
              try do
                Versions.create_xml_document!(version, %{document: doc})
              rescue
                e in Postgrex.Error ->
                  IO.puts("there was a Postgrex error --- probably a problem with the XML.")
                  IO.inspect(e)
              end

            {:error, error} ->
              IO.inspect(error)
          end
        end
      end)
    end)
  end

  def down do
    drop(table(:xml_documents))
  end
end
