defmodule TextServer.TextElements.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_element_users" do

    field :text_element_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(text_element_user, attrs) do
    text_element_user
    |> cast(attrs, [:text_element_id, :user_id])
    |> assoc_constraint(:text_element)
    |> assoc_constraint(:user)
    |> validate_required([:text_element_id, :user_id])
    |> unique_constraint([:text_element_id, :user_id])
  end
end
