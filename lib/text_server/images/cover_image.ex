defmodule TextServer.Images.CoverImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cover_images" do
    # attribution_name and attribution_url refer to the photographer/artist
    # attribution_source and attribution_source_url refer to the site (e.g., Unsplash)
    field :attribution_name, :string
    field :attribution_source, :string
    field :attribution_source_url, :string
    field :attribution_url, :string
    field :image_url, :string

    timestamps()
  end

  @doc false
  def changeset(cover_image, attrs) do
    cover_image
    |> cast(attrs, [
      :attribution_name,
      :attribution_source,
      :attribution_source_url,
      :attribution_url,
      :image_url
    ])
    |> validate_required([
      :attribution_name,
      :attribution_source,
      :attribution_source_url,
      :attribution_url,
      :image_url
    ])
    |> unique_constraint(:attribution_url)
  end
end
