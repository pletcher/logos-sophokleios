defmodule TextServer.ElementTypesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.ElementTypes` context.
  """

  @doc """
  Generate a unique element_type name.
  """
  def unique_element_type_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a element_type.
  """
  def element_type_fixture(attrs \\ %{}) do
    {:ok, element_type} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: unique_element_type_name()
      })
      |> TextServer.ElementTypes.create_element_type()

    element_type
  end
end
