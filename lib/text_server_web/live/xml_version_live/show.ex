defmodule TextServerWeb.XmlVersionLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Xml

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"urn" => urn}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:version, Xml.get_version_reference(urn))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <article class="p-8">
      <section id="xml">
        <%= raw(@version) %>
      </section>
    </article>
    """
  end

  defp page_title(:show), do: "Show Work"
end
