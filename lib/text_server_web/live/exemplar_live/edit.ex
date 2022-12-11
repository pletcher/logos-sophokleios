defmodule TextServerWeb.ExemplarLive.Edit do
  use TextServerWeb, :live_view

  alias TextServer.Exemplars
  # alias TextServer.Exemplars.Exemplar
  alias TextServer.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, assign(socket, :exemplar, get_exemplar!(id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    exemplar = get_exemplar!(id)

    socket
    |> assign(:page_title, exemplar.title)
    |> assign(:exemplar, get_exemplar!(id))
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.inspect(event)
    IO.inspect(params)

    {:noreply, socket}
  end

  defp get_exemplar!(id) do
    Exemplars.get_exemplar!(id)
    |> Repo.preload(:language)
    |> Repo.preload([version: [:work]])
  end
end
