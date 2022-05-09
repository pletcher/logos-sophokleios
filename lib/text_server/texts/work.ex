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
    field :author_id, :id
    field :language_id, :id
    field :text_group_id, :id

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
      :filemd5hash,
      :filename,
      :form,
      :full_urn,
      :label,
      :original_title,
      :slug,
      :structure,
      :urn
    ])
  end
end
