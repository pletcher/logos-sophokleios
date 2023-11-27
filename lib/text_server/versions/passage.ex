defmodule TextServer.Versions.Passage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "version_passages" do
    field :passage_number, :integer
    field :end_location, {:array, :string}
    field :start_location, {:array, :string}

    belongs_to :version, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(passage, attrs) do
    passage
    |> cast(attrs, [
      :end_location,
      :version_id,
      :passage_number,
      :start_location
    ])
    |> validate_required([
      :end_location,
      :passage_number,
      :start_location
    ])
    |> assoc_constraint(:version)
    |> unique_constraint([:version_id, :passage_number])
  end
end
