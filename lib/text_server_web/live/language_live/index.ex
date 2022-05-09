defmodule TextServerWeb.LanguageLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Texts
  alias TextServer.Texts.Language

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :languages, list_languages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Language")
    |> assign(:language, Texts.get_language!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Language")
    |> assign(:language, %Language{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Languages")
    |> assign(:language, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    language = Texts.get_language!(id)
    {:ok, _} = Texts.delete_language(language)

    {:noreply, assign(socket, :languages, list_languages())}
  end

  defp list_languages do
    Texts.list_languages()
  end
end
