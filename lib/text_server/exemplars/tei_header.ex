defmodule TextServer.Exemplars.TeiHeader do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :file_description, :map
    field :encoding_description, :map
    field :profile_description, :map
    field :revision_description, :map
  end

  def changeset(%TextServer.Exemplars.TeiHeader{} = tei_header, attrs \\ %{}) do
    tei_header
    |> cast(attrs, [
      :encoding_description,
      :file_description,
      :profile_description,
      :revision_description
    ])
  end
end
