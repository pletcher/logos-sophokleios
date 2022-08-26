defmodule TextServer.Exemplars.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exemplar_files" do
    field :extension, Ecto.Enum, values: [:docx, :xml]
    field :title, :string
    field :url, :string

    belongs_to :exemplar, TextServer.Exemplars.Exemplar

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:exemplar_id, :extension, :title, :url])
    |> validate_required([:exemplar_id, :extension, :title, :url])
    |> assoc_constraint(:exemplar)
    |> unique_constraint(:exemplar_id)
    |> unique_constraint(:url)
  end
end
