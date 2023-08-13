defmodule TextServer.TextGroups.TextGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_groups" do
    field :title, :string
    field :urn, TextServer.Ecto.Types.CTS_URN
    field :_search, TextServer.Ecto.Types.TsVector

    belongs_to :collection, TextServer.Collections.Collection

    has_many :works, TextServer.Works.Work

    timestamps()
  end

  @doc false
  def changeset(text_group, attrs) do
    text_group
    |> cast(attrs, [:collection_id, :title, :urn])
    |> validate_required([:title, :urn])
    |> assoc_constraint(:collection)
    |> unique_constraint(:urn)
  end
end
