defmodule TextServer.Versions.XmlDocuments do
  import Ecto.Query, warn: false

  alias TextServer.Repo
  alias TextServer.Versions.XmlDocuments.XmlDocument

  def get_refs_decls(%XmlDocument{} = document) do
    refs_decls = get_xpath_result(document, refs_decl_xpath())

    {:ok, encoding_desc} =
      DataSchema.to_struct(List.first(refs_decls), DataSchemata.Version.EncodingDescription)

    base_refs =
      encoding_desc.refs_declarations |> Enum.find(fn ref -> length(ref.c_ref_patterns) > 0 end)

    unit_labels =
      encoding_desc.refs_declarations
      |> Enum.find(fn ref -> length(ref.unit_labels) > 0 end)
      |> Map.get(:unit_labels)

    {:ok, Map.put(base_refs, :unit_labels, unit_labels)}
  end

  def get_table_of_contents(%XmlDocument{} = document) do
    {:ok, refs_decls} = get_refs_decls(document)

    paths = Enum.map(refs_decls.c_ref_patterns, & &1.reference_path)

    refs =
      paths
      |> Enum.map(fn path ->
        get_xpath_result(document, path <> "/@n")
      end)
      |> TextServer.Versions.XmlDocuments.TableOfContents.collect_citations()

    {:ok, refs}
  end

  @doc """
  Queries the given version using PostgreSQL's built-in
  xpath support.
  """
  def get_xpath_result(%XmlDocument{} = document, path) do
    XmlDocument
    |> where([d], d.id == ^document.id)
    |> select(
      fragment(
        """
        xpath(
          ?,
          document,
          ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']]
        )::text[]
        """,
        ^path
      )
    )
    |> Repo.one()
  end

  defp refs_decl_xpath do
    "/tei:TEI/tei:teiHeader/tei:encodingDesc"
  end
end
