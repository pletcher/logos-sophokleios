defmodule TextServer.Ingestion do
  @moduledoc """
  The Ingestion context.
  """

  import Ecto.Query, warn: false

  def find_or_create_language_from_version_header(header_data) do
    case get_language_tuple_from_header(header_data) do
      {nil, slug} ->
        l = TextServer.Languages.get_by_slug(slug)

        if is_nil(l) do
          TextServer.Languages.get_by_slug("en")
        else
          l
        end

      {title, slug} ->
        l = TextServer.Languages.get_by_slug(slug)

        if is_nil(l) do
          {:ok, lang} = TextServer.Languages.find_or_create_language(%{title: title, slug: slug})
          lang
        else
          l
        end
    end
  end

  @doc """
  Takes parsed TEI header data and returns an ordered list
  of ref levels. Note that it expects data in reversed
  order because of how the SAX handler prepends elements.

  Defaults to ["line"] in texts with only one level
  of hierarchy.

  ## Examples

      iex> get_ref_levels_from_tei_header([%{
        tag_name: "refState",
        attributes: [["unit", "section"], ["unit", "book"]]
      }])
      ["book", "section"]

      iex> get_ref_levels_from_tei_header([%{}])
      ["line"]
  """
  def get_ref_levels_from_tei_header(header_data) do
    cref_pattern_units = get_cref_pattern_units(header_data)

    units =
      if Enum.all?(cref_pattern_units) do
        cref_pattern_units
      else
        get_ref_state_units(header_data) |> Enum.reverse()
      end

    units
  end

  defp get_language_tuple_from_header(header_data) do
    language_tags = Enum.filter(header_data, fn d -> d.tag_name == "language" end)

    if length(language_tags) == 0 do
      title_tags = Enum.filter(header_data, fn d -> d.tag_name == "title" end)
      # remember, elements are in reversed order for efficiency
      first_title = List.last(title_tags)
      slug = Map.new(first_title[:attributes]) |> Map.get("xml:lang")

      # this only gets us the slug
      {nil, slug}
    else
      # ideally, we want the slug and the language name
      first_language_tag = List.last(language_tags)
      slug = Map.new(first_language_tag[:attributes]) |> Map.get("ident")

      {first_language_tag[:content], slug}
    end
  end

  defp get_cref_pattern_units(header_data) do
    header_data
    |> Enum.filter(fn d -> Map.get(d, :tag_name) == "cRefPattern" end)
    |> Enum.map(fn r ->
      Map.get(r, :attributes)
      |> Enum.find_value(fn a ->
        if elem(a, 0) == "n" do
          String.downcase(elem(a, 1))
        end
      end)
    end)
  end

  defp get_ref_state_units(header_data) do
    header_data
    |> Enum.filter(fn d -> Map.get(d, :tag_name) == "refState" end)
    |> Enum.map(fn r ->
      Map.get(r, :attributes)
      |> Enum.find_value(fn a ->
        if elem(a, 0) == "unit" do
          elem(a, 1)
        end
      end)
    end)
  end
end
