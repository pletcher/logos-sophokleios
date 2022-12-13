defmodule Mix.Tasks.Texts.Clone do
  use Mix.Task

  @shortdoc "Clones remote repositories of XML and JSON texts."

  @moduledoc """
  This task clones the following repositories:

  #{TextServer.Texts.repositories() |> Enum.map_join("\n", & &1[:url])}
  """

  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("... Cloning repositories ... \n")

    TextServer.Texts.clone_repos()

    Mix.shell().info("... Finished cloning repositories ... ")
  end
end
