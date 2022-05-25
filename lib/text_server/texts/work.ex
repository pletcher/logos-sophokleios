defmodule TextServer.Texts.Work do
  use Ecto.Schema
  import Ecto.Changeset

  schema "works" do
    field :description, :string
    field :english_title, :string
    field :filemd5hash, :string
    field :filename, :string
    field :form, :string
    field :full_urn, :string
    field :label, :string
    field :original_title, :string
    field :slug, :string
    field :structure, :string
    field :urn, :string
    field :work_type, :string

    belongs_to :author, TextServer.Texts.Author
    belongs_to :language_id, TextServer.Texts.Language
    belongs_to :text_group, TextServer.Texts.TextGroup
    has_many :text_nodes, TextServer.Texts.TextNode

    timestamps()
  end

  @doc false
  def changeset(work, attrs) do
    work
    |> cast(attrs, [
      :description,
      :english_title,
      :filemd5hash,
      :filename,
      :form,
      :full_urn,
      :label,
      :original_title,
      :slug,
      :structure,
      :urn,
      :work_type
    ])
    |> validate_required([
      :english_title,
      :filemd5hash,
      :filename,
      :full_urn,
      :slug,
      :text_group_id,
      :urn
    ])
    |> unique_constraint([
      :filemd5hash,
      :text_group_id
    ])
  end
end
