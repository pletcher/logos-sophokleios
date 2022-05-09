defmodule TextServerWeb.TranslationLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Texts
  alias TextServer.Texts.Translation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :translations, list_translations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Translation")
    |> assign(:translation, Texts.get_translation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Translation")
    |> assign(:translation, %Translation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Translations")
    |> assign(:translation, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    translation = Texts.get_translation!(id)
    {:ok, _} = Texts.delete_translation(translation)

    {:noreply, assign(socket, :translations, list_translations())}
  end

  defp list_translations do
    Texts.list_translations()
  end
end
