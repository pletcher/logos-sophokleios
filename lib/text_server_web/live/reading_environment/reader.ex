defmodule TextServerWeb.ReadingEnvironment.Reader do
  use TextServerWeb, :live_component

  alias TextServerWeb.Components

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

  attr :command_palette_open, :boolean, default: false
  attr :focused_text_node, :any, default: nil
  attr :text_nodes, :list, required: true
  attr :version_urn, :string, required: true

  def reading_page(assigns) do
    ~H"""
    <div>
      <section class="whitespace-break-spaces">
        <.live_component
          :for={text_node <- @text_nodes}
          module={TextServerWeb.ReadingEnvironment.TextNode}
          id={"#{@version_urn}:#{text_node.location}"}
          graphemes_with_tags={text_node.graphemes_with_tags}
          location={text_node.location}
        />
      </section>
      <.live_component
        module={TextServerWeb.ReadingEnvironment.CommandPalette}
        id={:reading_env_command_palette}
        is_open={@command_palette_open}
        text_node={@focused_text_node}
      />
    </div>
    """
  end
end
