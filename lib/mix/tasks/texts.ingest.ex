defmodule Mix.Tasks.Texts.Ingest do
  use Mix.Task

  @shortdoc "Ingests cloned repositories of XML and JSON texts."

  @moduledoc """
  This task ingests the following repositories:

  #{TextServer.Texts.repositories() |> Enum.map_join("\n", & &1[:url])}
  """

  def run(_args) do
    Mix.Task.run("app.start")

    Mix.shell().info("... Ingesting repositories ... \n")

    ingest_repos()

    Mix.shell().info("... Finished ingesting repositories ... ")
  end

  def collection_urn(url) do
    String.split(url, "/")
    |> List.last()
    |> String.replace(Path.extname(url), "")
    |> Phoenix.Naming.camelize(:lower)
  end

  defp ingest_json(dir, collection) do
    Mix.shell().info("... Ingesting JSON-based texts in #{dir} ... \n")

    Path.wildcard("#{dir}/*.json")
    |> Stream.map(&read_file/1)
    |> Stream.map(&parse_cltk_json/1)
    |> Stream.map(fn json -> process_text_group(json, collection) end)
    |> Enum.to_list()
  end

  defp ingest_xml(dir, collection) do
    Mix.shell().info("Ingesting XML: #{dir}")
  end

  defp ingest_repo(repo) do
    %{:title => title, :url => url} = repo
    dir = Path.expand(System.get_env("TEXT_REPO_DESTINATION", "./tmp"))

    repo_dir_name =
      String.split(url, "/")
      |> List.last()
      |> String.replace(".git", "")

    dest = Path.join(dir, repo_dir_name) |> Path.expand("./")
    urn = Map.get(repo, :urn) || "urn:cts:#{collection_urn(url)}"

    collection_attrs = %{
      repository: url,
      title: title,
      urn: urn
    }

    {:ok, collection} = TextServer.Texts.find_or_create_collection(collection_attrs)

    if File.dir?(json_dir = Path.join(dest, "cltk_json")) do
      ingest_json(json_dir, collection)
    else
      ingest_xml(dest, collection)
    end
  end

  defp ingest_repos() do
    TextServer.Texts.repositories()
    |> Enum.map(&ingest_repo/1)
  end

  defp parse_cltk_json({:error, reason}) do
    Mix.shell().error(reason)
  end

  defp parse_cltk_json({:ok, binary}) do
    case Jason.decode(binary) do
      {:ok, parsed} ->
        parsed

      {:error, reason} ->
        Mix.shell().error(reason)
        %{}
    end
  end

  defp parse_cltk_json(m) do
    Mix.shell().info("I don't know what to do with this:\n#{m}\n")
  end

  defp process_text_group(json, collection) do
    # NOTE: (charles) At least for the Hebrew Sefarim,
    # "author" is "Not available". Is this actually what we want
    # in our URNs?

    author = json["author"]
    english_title = json["englishTitle"]

    title = if author == "", do: english_title, else: author

    if title == "" do
      Mix.shell().info("-------- englishTitle field was blank -------")
    end

    urn = "#{collection.urn}:#{Recase.to_camel(title)}"

    text_group_attrs = %{
      collection_id: collection.id,
      title: title,
      urn: urn
    }

    TextServer.Texts.find_or_create_text_group(text_group_attrs)
  end

  defp read_file(f) do
    Mix.shell().info("-------- Reading #{f} ---------")

    File.read(f)
  end
end
