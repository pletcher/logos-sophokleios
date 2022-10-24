defmodule TextServer.Exemplars.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exemplar_pages" do
    field :page_number, :integer
    field :end_location, {:array, :integer}
    field :start_location, {:array, :integer}

    belongs_to :exemplar, TextServer.Exemplars.Exemplar

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [
      :end_location,
      :exemplar_id,
      :page_number,
      :start_location
    ])
    |> validate_required([
      :end_location,
      :page_number,
      :start_location
    ])
    |> assoc_constraint(:exemplar)
    |> unique_constraint([:exemplar_id, :page_number])
  end
end
