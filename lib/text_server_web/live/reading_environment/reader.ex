defmodule TextServerWeb.ReadingEnvironment.Reader do
  use TextServerWeb, :live_component

  @doc """
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
  def update(%{text_nodes: _text_nodes} = assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def reading_page(assigns) do
    ~H"""
    <article>
      <%= for text_node <- @text_nodes do %>
        <.text_node text_node={text_node} />
      <% end %>
    </article>
    """
  end

  attr :tags, :list, default: []
  attr :text, :string

  def text_element(assigns) do
    classes =
      assigns[:tags]
      |> Enum.map(fn tag ->
        case tag do
          "comment" -> "bg-blue-300"
          "emph" -> "italic"
          "strong" -> "font-bold"
          "underline" -> "underline"
          _ -> tag
        end
      end)
      |> Enum.join(" ")

    ~H"<span class={classes}><%= @text %></span>"
  end

  # BUGS: Comments aren't showing up correctly,
  # styles are occasionally lost

  attr :text_node, :map, required: true

  def text_node(assigns) do
    node = assigns[:text_node]
    elements = node.text_elements
    text = node.text

    # turn the bare graphemes list into a list of tuples
    # representing the grapheme and associated inline metadata
    # Sort of akin to what ProseMirror does: https://prosemirror.net/docs/guide/#doc
    graphemes =
      String.graphemes(text)
      |> Enum.with_index()
      |> Enum.map(fn {g, i} -> {i, g, []} end)

    tagged_graphemes =
      Enum.reduce(elements, graphemes, fn el, gs ->
        tagged =
          gs
          |> Enum.map(fn g ->
            {i, g, tags} = g

            if i >= el.start_offset && i < el.end_offset do
              {i, g, tags ++ [el.element_type.name]}
            else
              {i, g, tags}
            end
          end)

        tagged
      end)

    grouped_graphemes =
      tagged_graphemes
      |> Enum.reduce([], fn tagged_grapheme, acc ->
        {_i, g, tags} = tagged_grapheme
        last = List.last(acc)

        if last == nil do
          [{[g], tags}]
        else
          {g_list, last_tags} = last

          if last_tags == tags do
            List.replace_at(acc, -1, {g_list ++ [g], tags})
          else
            acc ++ [{[g], tags}]
          end
        end
      end)

    # NOTE: (charles) It's important, unfortunately, for the `for` statement
    # to be on one line so that we don't get extra spaces around elements.
    ~H"""
    <p>
      <%= for {graphemes, tags} <- grouped_graphemes do %><.text_element tags={tags} text={Enum.join(graphemes)} /><% end %>
    </p>
    """
  end
end
