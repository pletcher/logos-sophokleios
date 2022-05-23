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

    pull_repos()

    Mix.shell().info("\n ... Finished pulling repositories ... ")
  end

  defp pull_repo(repo) do
    %{:url => url} = repo
    dir = Path.expand(System.get_env("TEXT_REPO_DESTINATION", "./tmp"))

    repo_dir_name =
      String.split(url, "/")
      |> List.last()
      |> String.replace(".git", "")

    dest = Path.join(dir, repo_dir_name) |> Path.expand("./")

    Mix.Shell.IO.cmd("git -C #{dest} pull")
  end

  defp pull_repos() do
    TextServer.Texts.repositories()
    |> Enum.map(&pull_repo/1)
  end
end
