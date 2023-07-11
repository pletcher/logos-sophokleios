defmodule Mix.Tasks.Exist.Ingest do
  use Mix.Task

  @shortdoc "Ingests TEI XML files and persists them in eXist-db"

  @moduledoc """
  This task clones the following repositories:

  #{TextServer.Texts.repositories() |> Enum.map_join("\n", & &1[:url])}
  """

  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("... Saving texts in eXist-db ... \n")

    TextServer.Xml.save_versions_in_exist()

    Mix.shell().info("... Finished saving texts in eXist-db ... ")
  end
end
