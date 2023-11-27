defmodule Mix.Tasks.Texts.Ingest do
  use Mix.Task

  @shortdoc "Ingests TEI XML texts."

  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("... Ingesting repositories ... \n")

    TextServer.Ingestion.Versions.create_versions()

    Mix.shell().info("... Finished ingesting repositories ... ")
  end
end
