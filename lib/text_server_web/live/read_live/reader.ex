defmodule TextServerWeb.ReadLive.Reader do
  require Logger
  use TextServerWeb, :live_view

  alias TextServer.Repo
  alias TextServer.Versions
  alias TextServer.Versions.Version
  alias TextServer.Versions.Passages
  alias TextServer.Versions.XmlDocuments

  alias TextServerWeb.ReadLive.Reader.Navigation
  alias TextServerWeb.ReadLive.Reader.Passage

  def mount(
        %{
          "collection" => collection_s,
          "text_group" => text_group_s,
          "work" => work_s,
          "version" => version_s
        } = params,
        _session,
        socket
      ) do
    current_page = Map.get(params, "page", "1") |> String.to_integer()
    socket = assign(socket, :current_page, current_page)

    version =
      get_version_by_urn!("urn:cts:#{collection_s}:#{text_group_s}.#{work_s}.#{version_s}")

    if is_nil(version.xml_document) do
      mount_docx_version(socket, version)
    else
      mount_xml_version(socket, version)
    end
  end

  defp mount_xml_version(socket, %Version{xml_document: document} = version) do
    current_page = Map.get(socket, :assigns) |> Map.get(:current_page, 1)
    {:ok, refs_decl} = XmlDocuments.get_refs_decl(document)
    {:ok, toc} = XmlDocuments.get_table_of_contents(document, refs_decl)
    {:ok, passage_refs} = Passages.list_passage_refs(toc)

    passage_ref = Enum.at(passage_refs, current_page - 1)
    {:ok, passage} = XmlDocuments.get_passage(document, refs_decl, passage_ref)

    {:ok,
     socket
     |> assign(
       passage: passage |> Enum.join(""),
       passage_refs:
         passage_refs |> Enum.with_index(1) |> Enum.chunk_by(&(elem(&1, 0) |> elem(0))),
       refs_decl: refs_decl,
       toc: toc,
       unit_labels: refs_decl.unit_labels,
       version: version
     )}
  end

  defp mount_docx_version(socket, %Version{} = version) do
    Logger.warning("Cannot render a non-XML-based passage.")

    {:ok,
     socket
     |> assign(
       passage_refs: [],
       unit_labels: [],
       passage: "<p>Unable to render commentary</p>",
       version: version
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex grow gap-y-5 overflow-y-auto px-6">
      <Navigation.navigation_menu current_page={@current_page} passage_refs={@passage_refs} unit_labels={@unit_labels} />
      <div class="px-6">
        <.live_component id={:reader_passage} module={Passage} passage={@passage} />
      </div>
    </div>
    """
  end

  defp get_version_by_urn!(urn_s) do
    Versions.get_version_by_urn!(urn_s) |> Repo.preload(:xml_document)
  end
end
