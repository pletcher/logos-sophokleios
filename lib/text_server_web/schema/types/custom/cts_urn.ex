# credit to https://github.com/stevelacy/elixir-urn/blob/master/lib/urn.ex
defmodule TextServerWeb.Schema.Types.Custom.CtsUrn do
  use Absinthe.Schema.Notation

  scalar :cts_urn, name: "CtsUrn" do
    description("""
    The `CtsUrn` scalar type represents a
    [CapiTainS](http://capitains.org/pages/guidelines#cts-urn-choice)
    Uniform Resource Name.
    """)

    serialize(&encode/1)
    parse(&decode/1)
  end

  @type t() :: %{
          nid: term(),
          nss: term(),
          resolution: term(),
          query: term(),
          fragment: term()
        }

  @type reason() :: String.t() | term()

  defp encode(value), do: value

  @spec decode(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
  @spec decode(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
    case parse_urn_string(value) do
      {:ok, urn_str} -> {:ok, urn_str}
      _ -> :error
    end
  end

  defp decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode(_) do
    :error
  end

  @doc """
  Parses a urn string into it's various parts.
  # Example
      {:ok, urn} = URN.parse("urn:example:a123,z456?+abc")
  """
  @spec parse_urn_string(String.t()) :: {:ok, t()} | {:reason, reason()}
  def parse_urn_string(str) when is_binary(str) do
    with {:ok, parts} <- extract_parts(str) do
      try do
        {
          :ok,
          %{
            nid: maybe_decode(Map.get(parts, "nid")),
            nss: maybe_decode(Map.get(parts, "nss")),
            resolution: maybe_decode(Map.get(parts, "resolution")),
            query: maybe_decode(Map.get(parts, "query")),
            fragment: maybe_decode(Map.get(parts, "fragment"))
          }
        }
      rescue
        ArgumentError -> {:error, "Invalid URN"}
      end
    end
  end

  defp extract_parts(str) do
    alphanum = ~r/[a-zA-Z0-9\-]+/.source
    pchar = ~r/([a-zA-Z0-9\-!\$\&'\(\)\*\+\.,;=_~:@\/\%])+/.source

    # I know this looks ugly, but I don't know a better way to compose this
    ~r/\A(?<scheme>[uU][rR][nN]):(?<nid>#{alphanum}):(?<nss>#{pchar})(\?\+(?<resolution>#{pchar}))?(\?=(?<query>#{pchar}))?(#(?<fragment>#{pchar}))?\Z/
    |> Regex.named_captures(str)
    |> case do
      nil -> {:error, "invalid urn"}
      matched -> {:ok, matched}
    end
  end

  defp maybe_decode(nil), do: nil
  defp maybe_decode(""), do: nil
  defp maybe_decode(str), do: URI.decode(str)
end
