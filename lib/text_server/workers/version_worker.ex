defmodule TextServer.Workers.VersionWorker do
  use Oban.Worker

  alias TextServer.Versions
  alias TextServer.Xml

  # We can implement different actions by passing additional
  # args to Oban when adding an item to the queue
  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    version = Versions.get_version!(id)

    parse(version)
  end

  def perform(%Oban.Job{args: %{"id" => id, "task" => "set_refs_decl"} = _args}) do
    version = Xml.get_version!(id)

    set_refs_decl(version)
  end

  defp parse(version) do
    # parse version, saving/updating TextNodes and TextElements
    case Versions.parse_version(version) do
      {:ok, version} ->
        {:ok, version}

      {:error, reason} ->
        IO.inspect(reason)
        :error
    end
  end

  defp set_refs_decl(version) do
    case Xml.set_version_refs_declaration(version) do
      {:ok, version} ->
        {:ok, version}

      {:error, reason} ->
        IO.inspect(reason)
        :error
    end
  end
end
