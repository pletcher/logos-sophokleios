# copied from https://github.com/raidcorp/searchy/blob/master/lib/ecto/types/ts_vector.ex

defmodule TextServer.Ecto.Types.TsVector do
  use Ecto.Type

  def type, do: :tsvector

  def cast(tsvector), do: {:ok, tsvector}

  def load(tsvector), do: {:ok, tsvector}

  def dump(tsvector), do: {:ok, tsvector}

  def embed_as(_), do: :self

  def equal?(term1, term2), do: term1 == term2
end
