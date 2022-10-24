defmodule TextServer.TextNodes.TextNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_nodes" do
    field :location, {:array, :integer}
    field :normalized_text, :string
    field :text, :string
    field :_search, TextServer.Ecto.Types.TsVector

    belongs_to :exemplar, TextServer.Exemplars.Exemplar

    has_many :text_elements, TextServer.TextElements.TextElement, foreign_key: :start_text_node_id

    timestamps()
  end

  @doc false
  def changeset(text_node, attrs) do
    text_node
    |> cast(attrs, [:exemplar_id, :location, :text])
    |> validate_required([:location, :text])
    |> assoc_constraint(:exemplar)
  end

  defmodule Tag do
    @enforce_keys [:name]

    defstruct [:name, :metadata]
  end

  def tag_graphemes(text_node) do
    elements =
      text_node.text_elements |> Enum.filter(fn e -> e.element_type.name != "comment" end)

    comments =
      text_node.text_elements |> Enum.filter(fn e -> e.element_type.name == "comment" end)

    text = text_node.text

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

    %{graphemes_with_tags: grouped_graphemes, location: text_node.location}
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
    ranged_comments =
      comments
      |> Enum.group_by(
        fn c ->
          comment_id(c)
        end,
        fn c ->
          author = comment_author(c)
          date = comment_date(c)

          Map.new(
            id: Integer.to_string(c.id),
            author: author,
            content: c.content,
            date: date,
            offset: c.start_offset
          )
        end
      )
      |> Enum.map(fn {_id, start_and_end} ->
        [h | t] = start_and_end

        range =
          unless t == [] do
            t = hd(t)
            h.offset..(t.offset - 1)
          else
            h.offset..Enum.count(graphemes)
          end

        Map.put(h, :range, range)
      end)

    graphemes
    |> Enum.map(fn g ->
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
