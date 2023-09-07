defmodule TextServerWeb.ReadLive.Reader do
  use TextServerWeb, :live_view

  alias TextServer.Repo
  alias TextServer.Versions
  alias TextServer.Versions.Passages
  alias TextServer.Versions.XmlDocuments

  alias TextServerWeb.ReadLive.Reader.Navigation

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
    page_number = Map.get(params, "page", "1") |> String.to_integer()

    version =
      get_version_by_urn!("urn:cts:#{collection_s}:#{text_group_s}.#{work_s}.#{version_s}")

    document = version.xml_document
    {:ok, refs_decl} = XmlDocuments.get_refs_decl(document)
    {:ok, toc} = XmlDocuments.get_table_of_contents(document, refs_decl)
    {:ok, passage_refs} = Passages.list_passage_refs(toc)

    passage_ref = Enum.at(passage_refs, page_number - 1)
    {:ok, passage} = XmlDocuments.get_passage(document, refs_decl, passage_ref)

    # TODO: Create a navigation component at TextServerWeb.ReadLive.Reader.Navigation
    # that takes the refs_decl
    # and the toc, applying the unit_labels as appropriate (to the depth
    # of the toc) to each of the links in a collapsible menu nave

    {:ok,
     socket
     |> assign(
       page_number: page_number,
       passage: passage |> Enum.join(""),
       passage_refs: passage_refs |> Enum.with_index(1) |> Enum.chunk_by(&(elem(&1, 0) |> elem(0))),
       refs_decl: refs_decl,
       toc: toc,
       unit_labels: refs_decl.unit_labels,
       version: version
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex grow gap-y-5 overflow-y-auto px-6">
      <Navigation.navigation_menu passage_refs={@passage_refs} unit_labels={@unit_labels} />
      <div class="px-6">
        <%= raw @passage %>
      </div>
    </div>
    """
  end

  defp get_version_by_urn!(urn_s) do
    Versions.get_version_by_urn!(urn_s) |> Repo.preload(:xml_document)
  end
end
