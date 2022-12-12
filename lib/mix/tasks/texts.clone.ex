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

    clone_repos()

    Mix.shell().info("... Finished cloning repositories ... ")
  end

  defp clone_repo(repo) do
    %{:url => url} = repo

    dir = Path.expand(Application.get_env(:text_server, :text_repo_destination, "./tmp"))

    repo_dir_name =
      String.split(url, "/")
      |> List.last()
      |> String.replace(".git", "")

    dest = Path.join(dir, repo_dir_name) |> Path.expand("./")

    Mix.Shell.IO.cmd("git clone #{url} #{dest}")
  end

  defp clone_repos() do
    TextServer.Texts.repositories()
    |> Enum.map(&clone_repo/1)
  end
end
