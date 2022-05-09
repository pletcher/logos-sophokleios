defmodule TextServerWeb.TextGroupLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Texts
  alias TextServer.Texts.TextGroup

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :text_groups, list_text_groups())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Text group")
    |> assign(:text_group, Texts.get_text_group!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Text group")
    |> assign(:text_group, %TextGroup{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Text groups")
    |> assign(:text_group, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    text_group = Texts.get_text_group!(id)
    {:ok, _} = Texts.delete_text_group(text_group)

    {:noreply, assign(socket, :text_groups, list_text_groups())}
  end

  defp list_text_groups do
    Texts.list_text_groups()
  end
end
