defmodule TextServer.Versions.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :description, :string
    field :label, :string
    field :urn, :string
    field :version_type, Ecto.Enum, values: [:commentary, :edition, :translation]

    belongs_to :work, TextServer.Works.Work

    has_many :exemplars, TextServer.Exemplars.Exemplar

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:description, :label, :urn, :version_type, :work_id])
    |> validate_required([:label, :urn, :version_type])
    |> assoc_constraint(:work)
    |> unique_constraint(:urn)
  end
end
