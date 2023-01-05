defmodule Xml.Versions.Version do
  import DataSchema, only: [data_schema: 1]

  # field :description, :string
  # field :filemd5hash, :string
  # field :filename, :string
  # field :label, :string
  # field :parsed_at, :naive_datetime
  # field :source, :string
  # field :source_link, :string
  # field :structure, {:array, :string}
  # field :urn, :string
  # field :version_type

  @cref_xpath_regex ~r/#xpath\((?<xpath>[^)]+)\)/su

  @data_accessor Xml.XPathAccessor
  data_schema(
    list_of:
      {:cref_patterns, "/TEI/teiHeader/encodingDesc/refsDecl/cRefPattern/@replacementPattern",
       &__MODULE__.xpath_from_cref/1},
    field: {:label, "/TEI/teiHeader/fileDesc/titleStmt/title/text()", &{:ok, to_string(&1)}},
    field: {:language_slug, "/TEI/text/body/div/@xml:lang", &{:ok, to_string(&1)}},
    list_of: {:structure, "/TEI/teiHeader/encodingDesc/refsDecl/refState/@unit", &{:ok, to_string(&1)}},
    field: {:urn, "/TEI/text/body/div/@n", &{:ok, to_string(&1)}},
    field: {:version_type, "/TEI/text/body/div/@type", &{:ok, to_string(&1)}}
  )

  def xpath_from_cref(s) do
    {:ok, Regex.named_captures(@cref_xpath_regex, to_string(s)) |> Map.get("xpath")}
  end
end
