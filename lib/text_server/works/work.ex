defmodule TextServer.Works.Work do
  use Ecto.Schema
  import Ecto.Changeset

  schema "works" do
    field :description, :string
    field :english_title, :string
    field :original_title, :string
    field :title, :string, source: :english_title
    field :urn, TextServer.Ecto.Types.CTS_URN
    field :_search, TextServer.Ecto.Types.TsVector

    belongs_to :text_group, TextServer.TextGroups.TextGroup

    has_many :versions, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(work, attrs) do
    work
    |> cast(attrs, [
      :description,
      :english_title,
      :original_title,
      :text_group_id,
      :urn
    ])
    |> validate_required(:urn)
    |> assoc_constraint(:text_group)
    |> unique_constraint(:urn)
  end
end
