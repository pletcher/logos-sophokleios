defmodule TextServerWeb.WorkLive.New do
  use TextServerWeb, :live_view

  alias TextServer.Works.Work

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Create work",
       selected_text_group: nil,
       work: %Work{}
     )}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(event_name, _params, socket) do
    IO.puts("Should probably handle the event called #{event_name}...")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:selected_text_group, text_group}, socket) do
    {:noreply, socket |> assign(:selected_text_group, text_group)}
  end
end
