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

  defmodule Tag do
    @enforce_keys [:name]

    defstruct [:name, :metadata]
  end

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
        case tag.name do
          "comment" -> "bg-blue-200"
          "emph" -> "italic"
          "strong" -> "font-bold"
          "underline" -> "underline"
          _ -> tag.name
        end
      end)
      |> Enum.join(" ")

    comment_start_data = Enum.find_value(assigns[:tags], fn tag ->
      if String.contains?(tag.name, "comment-start") do
        tag.metadata
      end
    end) || %{}

    comment_start_id =
      comment_start_data
      |> Map.get("key_value_pairs", %{})
      |> Map.get("id", nil)

    comment_end_data = Enum.find_value(assigns[:tags], fn tag ->
      if String.contains?(tag.name, "comment-end") do
        tag.metadata
      end
    end) || %{}

    comment_end_id =
      comment_end_data
      |> Map.get("key_value_pairs", %{})
      |> Map.get("id", nil)

    ~H"<span
        class={classes}
        data-comment-end={comment_end_id}
        data-comment-start={comment_start_id}
      ><%= @text %></span>"
  end

  attr :text_node, :map, required: true

  def text_node(assigns) do
    node = assigns[:text_node]
    elements = node.text_elements |> Enum.filter(fn e -> e.element_type.name != "comment" end)
    comments = node.text_elements |> Enum.filter(fn e -> e.element_type.name == "comment" end)
    text = node.text

    # turn the bare graphemes list into an indexed list of tuples
    # representing the grapheme and associated inline metadata
    # Sort of akin to what ProseMirror does: https://prosemirror.net/docs/guide/#doc
    graphemes =
      String.graphemes(text)
      |> Enum.with_index(fn g, i -> {i, g, []} end)

    tagged_graphemes = apply_tags(elements, graphemes)
    commented_graphemes = apply_comments(comments, tagged_graphemes)

    grouped_graphemes =
      commented_graphemes
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
            # This might be a good place to start if we need
            # to improve speed at some point --- concatenation
            # traverses the entire list each time. Not a big deal
            # at the moment (2022-09-30), though.
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

  defp apply_tags(elements, graphemes) do
    Enum.reduce(elements, graphemes, fn el, gs ->
      tagged =
        gs
        |> Enum.map(fn g ->
          {i, g, tags} = g

          if i >= el.start_offset && i < el.end_offset do
            {i, g, tags ++ [%Tag{name: el.element_type.name}]}
          else
            {i, g, tags}
          end
        end)

      tagged
    end)
  end

  defp apply_comments(comments, graphemes) do
    ranged_comments = comments |> Enum.group_by(fn c ->
      comment_id(c)
    end, fn c ->
      id = comment_id(c)
      author = comment_author(c)
      date = comment_date(c)
      Map.new(
        id: id,
        author: author,
        content: c.content,
        date: date,
        offset: c.start_offset
      )
    end) |> Enum.map(fn {_id, start_and_end} ->
      [h | t] = start_and_end
      t = hd(t)
      range = h.offset..(t.offset - 1)

      Map.put(h, :range, range)
    end)

    graphemes |> Enum.map(fn g ->
      {i, g, tags} = g

      applicable_comments =
        ranged_comments
        |> Enum.filter(fn c -> i in c.range end)
        |> Enum.map(fn c -> %Tag{name: "comment", metadata: c} end)
      {i, g, tags ++ applicable_comments}
    end)
  end

  defp comment_kv_pairs(comment), do: Map.get(comment.attributes, "key_value_pairs", %{})
  defp comment_author(comment), do: comment_kv_pairs(comment) |> Map.get("author")

  defp comment_date(comment) do
    try do
      {:ok, date} = comment_kv_pairs(comment) |> Map.get("date") |> DateTime.from_iso8601()
      date
    rescue
      _ -> nil
    end
  end

  defp comment_id(comment), do: comment_kv_pairs(comment) |> Map.get("id")
end
