defmodule Mix.Tasks.Texts.Pull do
  use Mix.Task

  @shortdoc "Pulls remote repositories of already-cloned XML and JSON texts."

  @moduledoc """
  This task pulls the following repositories:

  #{TextServer.Texts.repositories() |> Enum.map_join("\n", & &1[:url])}
  """

  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info(" ... Pulling repositories ... \n")

    TextServer.Texts.pull_repos()

    Mix.shell().info("\n ... Finished pulling repositories ... ")
  end
end
