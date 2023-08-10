defmodule TextServer.Ecto.Types.CTS_URN do
  use Ecto.Type

  alias CTS

  def type, do: :map

  @spec cast(binary) :: {:ok, CTS.URN.t()}
  def cast(urn) when is_binary(urn) do
    {:ok, CTS.URN.parse(urn)}
  end

  def cast(%CTS.URN{} = urn), do: {:ok, urn}

  def cast(_), do: :error_handler

  @spec load(map) :: {:ok, CTS.URN.t()}
  def load(data) when is_map(data) do
    data =
      for {key, val} <- data do
        {String.to_atom(key), val}
      end

    {:ok, struct!(CTS.URN, data)}
  end

  @spec dump(any) :: :error | {:ok, map}
  def dump(%CTS.URN{} = urn), do: {:ok, Map.from_struct(urn)}
  def dump(_), do: :error
end
