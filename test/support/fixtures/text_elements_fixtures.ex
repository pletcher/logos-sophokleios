defmodule TextServer.TextElementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextElements` context.
  """

  @doc """
  Generate a text_element.
  """
  def text_element_fixture(attrs \\ %{}) do
    {:ok, text_element} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        end_urn: "some end_urn"
      })
      |> TextServer.TextElements.create_text_element()

    text_element
  end
end
