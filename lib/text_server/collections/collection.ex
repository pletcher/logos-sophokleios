defmodule TextServer.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :repository, :string
    field :title, :string
    field :cts_urn, TextServer.Ecto.Types.CTS_URN
    field :urn, :string

    has_many :repositories, TextServer.Collections.Repository
    has_many :text_groups, TextServer.TextGroups.TextGroup

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:cts_urn, :repository, :title, :urn])
    |> validate_required([:repository, :title, :urn])
    |> unique_constraint(:repository)
  end
end
