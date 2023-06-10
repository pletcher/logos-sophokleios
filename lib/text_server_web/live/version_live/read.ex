defmodule TextServerWeb.VersionLive.Read do
  use TextServerWeb, :live_view

  # alias TextServerWeb.Components

  # alias TextServer.TextNodes
  alias TextServer.Versions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>Read version</div>
    """
  end

  @impl true
  def handle_params(%{"urn" => urn}, _session, socket) do
    passage_page = get_passage_by_urn(urn)

    if is_nil(passage_page) do
      {:noreply, socket |> put_flash(:error, "No text nodes found for the given passage.")}
    else
      create_response(socket, urn, passage_page)
    end
  end

  def handle_params(params, session, socket) do
    handle_params(
      params |> Enum.into(%{"page" => "1"}),
      session,
      socket
    )
  end

  def create_response(socket, urn, page) do
    # %{comments: comments, footnotes: footnotes, passage: passage}
    {:noreply, socket |> assign(page) |> assign(urn: urn)}
  end

  def get_passage_by_urn(urn) do
    Versions.get_passage_by_urn(urn)
  end
end
