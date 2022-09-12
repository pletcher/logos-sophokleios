defmodule TextServer.Ingestion do
  @moduledoc """
  The Ingestion context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

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
      if Enum.empty?(cref_pattern_units) do
        get_ref_state_units(header_data) |> Enum.reverse()
      else
        cref_pattern_units
      end

    units
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
