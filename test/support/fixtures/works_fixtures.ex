defmodule TextServer.WorksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Works` context.
  """

  @doc """
  Generate a work.
  """
  def work_fixture(attrs \\ %{}) do
    {:ok, work} =
      attrs
      |> Enum.into(%{
        description: "some description",
        english_title: "some english_title",
        original_title: "some original_title",
        text_group_id: text_group_fixture().id,
        urn: "some urn"
      })
      |> TextServer.Works.create_work()

    work
  end

  defp text_group_fixture() do
    TextServer.TextGroupsFixtures.text_group_fixture()
  end
end
