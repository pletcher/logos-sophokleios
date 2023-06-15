defmodule TextServerWeb.ReadingEnvironment.Reader do
  use TextServerWeb, :live_component

  @moduledoc """
  Every screen of TextNodes can be represented as a map of
  List<nodes> and List<elements>.

  When these are rendered, the two lists are merged such that
  every `node` is split into a list where its text is interspersed
  with the starts and ends of `element`s.

  Essentially, this is a rope with the ability to store
  pointers to the `element`s list when an `element` starts
  and ends.

  In its deserialized form, the rope is a binary tree
  where each vertex stores a variable-length of text ---
  i.e., a text node --- its location, and a list of pointers
  to elements that need to be added to it. A node can be
  represented as its own subtree when elements need to be
  inserted into it.

  The rope is then serialized as a string of HTML for
  rendering.

  It should be possible to render a `node` and the `element`s
  "inside" it by splitting the `node`'s text at each `element`'s
  `offset`. If the `element` spans multiple `node`s, it can still
  visually apply to every `node` in between its start and end
  `nodes`.
  """

  alias TextServer.TextNodes
  alias TextServerWeb.Components

  def mount(socket) do
    {:ok, socket |> assign(sibling_nodes: %{})}
  end

  attr :command_palette_open, :boolean, default: false
  attr :focused_text_node, :any, default: nil
  attr :sibling_nodes, :map, default: %{}
  attr :text_nodes, :list, required: true
  attr :version_urn, :string, required: true

  def render(assigns) do
    ~H"""
    <article id="reading-environment-reader">
      <button
        type="button"
        class="rounded-full bg-white px-4 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
        phx-click="show-palette-for-page"
        phx-target={@myself}
      >
        Select comparanda for entire page
      </button>
      <section class="whitespace-break-spaces">
        <!-- add parallel list of sibling nodes that can be matched on IDs -->
        <.live_component
          :for={text_node <- @text_nodes}
          module={TextServerWeb.ReadingEnvironment.TextNode}
          id={text_node.id}
          is_focused={is_focused(@focused_text_node, text_node)}
          sibling_node={@sibling_nodes |> Map.get(text_node.location)}
          text_node={text_node}
        />
      </section>
      <.live_component
        module={TextServerWeb.ReadingEnvironment.TextNodeCommandPalette}
        id={:text_node_command_palette}
        is_open={@command_palette_open}
        text_node={@focused_text_node}
        urn={@version_urn}
      />
      <!-- use a different command palette for the whole page -->
      <Components.footnotes footnotes={@footnotes} />
    </article>
    """
  end

  def handle_event("select-sibling-node", %{"text_node_id" => id}, socket) do
    new_sibling = TextNodes.get_text_node!(id) |> TextNodes.tag_text_node()

    send self(), {:focused_text_node, nil}

    {:noreply,
     socket
     |> assign(
       command_palette_open: false,
       sibling_nodes: Map.put(socket.assigns.sibling_nodes, new_sibling.location, new_sibling)
     )}
  end

  def handle_event("show-palette-for-page", _, socket) do
    {:noreply, socket}
  end

  defp is_focused(focused_text_node, _text_node) when is_nil(focused_text_node) do
    false
  end

  defp is_focused(focused_text_node, text_node) do
    focused_text_node == text_node
  end
end
