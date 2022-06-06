defmodule TextServer.Versions.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :description, :string
    field :title, :string
    field :urn, :string
    field :version_type, Ecto.Enum, values: [:edition, :translation]

    belongs_to :work, TextServer.Works.Work

    has_many :exemplars, TextServer.Exemplars.Exemplar

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:description, :title, :urn, :version_type, :work_id])
    |> validate_required([:title, :urn, :version_type])
    |> assoc_constraint(:work)
    |> unique_constraint(:urn)
  end
end
