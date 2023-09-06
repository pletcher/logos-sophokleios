defmodule DataSchemata.Version.EncodingDescription do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemata.XPathAccessor

  data_schema(
    has_many: {:refs_declarations, "/encodingDesc/refsDecl", DataSchemata.Version.RefsDeclaration}
  )
end
