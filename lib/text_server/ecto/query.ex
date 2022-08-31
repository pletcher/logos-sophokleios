# copied from https://github.com/raidcorp/searchy/blob/master/lib/ecto/query.ex

defmodule TextServer.Ecto.Query do
  @moduledoc """
  Provides search functionality to work with `tsvector` columns.
  For more information you can lookup the Postgres documentation on:
  https://www.postgresql.org/docs/current/textsearch-controls.html
  """

  import Ecto.Query

  @doc """
  Transforms the `search_term` in a Postgres `tsquery` data type fragment.
  """
  @spec to_tsquery(atom() | binary(), binary()) :: %Ecto.Query.DynamicExpr{}
  def to_tsquery(search_field, search_term) do
    dynamic(
      [x],
      fragment(
        "? @@ to_tsquery(?)",
        field(x, ^search_field),
        ^search_term
      )
    )
  end

  def split_text_for_tsquery(text) do
    String.split(text, " ", trim: true)
    |> Enum.reject(fn text -> Regex.match?(~r/\(|\)\[|\]\{|\}/, text) end)
    |> Enum.map(fn token -> token <> ":*" end)
    |> Enum.intersperse(" & ")
    |> Enum.join()
  end
end
