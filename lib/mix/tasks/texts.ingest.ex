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
    |> Phoenix.Naming.underscore()
    |> Phoenix.Naming.camelize(:lower)
  end

  defp ingest_collection(f, collection) do
    {:ok, binary} = File.read(f)
    {:ok, parsed} = Jason.decode(binary, keys: :atoms)
    {:ok, text_group} = process_text_group(parsed, collection)
    {:ok, work} = get_work(parsed, collection, text_group, binary, f)
    {:ok, _version} = maybe_get_version(parsed, work)
  end

  def maybe_get_version(
        %{edition: edition, source: "The Center for Hellenic Studies", language: "english"} =
          data,
        work
      ) do
    TextServer.Texts.find_or_create_version(%{title: edition, urn: "#{work.urn}.chs-translation"})
  end

  def maybe_get_version(
        %{edition: edition, source: "The Center for Hellenic Studies"} = data,
        work
      ) do
    TextServer.Texts.find_or_create_version(%{
      title: edition,
      urn: "#{work.urn}.chs-#{Phoenix.Naming.camelize(edition)}"
    })
  end

  defp maybe_get_version(
         %{edition: edition} = data,
         work
       ) do
    TextServer.Texts.find_or_create_version(%{
      title: edition,
      urn: work.urn
    })
  end

  defp maybe_get_version(_data, _work) do
    {:ok, nil}
  end

  defp ingest_json(dir, collection) do
    Mix.shell().info("... Ingesting JSON-based texts in #{dir} ... \n")

    Path.wildcard("#{dir}/*.json")
    |> Stream.map(fn f -> ingest_collection(f, collection) end)
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
    |> Stream.map(&ingest_repo/1)
    |> Enum.to_list()
  end

  defp get_text_group(data, collection) do
    # NOTE: (charles) At least for the Hebrew Sefarim,
    # "author" is "Not available". Is this actually what we want
    # in our URNs?

    author = data[:author]

    title = if author == "", do: "unknown", else: author

    urn = "#{collection.urn}:#{Phoenix.Naming.camelize(title)}"

    text_group_attrs = %{
      collection_id: collection.id,
      title: title,
      urn: urn
    }

    TextServer.Texts.upsert_text_group(text_group_attrs)
  end

  defp get_work(data, collection, text_group, raw, filename) do
    description = data[:description]
    english_title = data[:english_title] || text_group.title
    path_prefix = Path.expand(System.get_env("TEXT_REPO_DESTINATION", "./tmp"))
    filename = String.replace_prefix(filename, "#{path_prefix}/", "")
    filemd5hash = :crypto.hash(:md5, raw) |> Base.encode16(case: :lower)

    [language_fragment, work_fragment | _] =
      String.split(filename, ".") |> List.first() |> String.split("__") |> Enum.reverse()

    form = nil

    full_urn =
      "#{text_group.urn}.#{Phoenix.Naming.camelize(work_fragment)}-#{Phoenix.Naming.camelize(language_fragment)}"

    label = nil
    language = data[:language]
    original_title = data[:original_title]
    structure = nil
    urn = "#{text_group.urn}.#{Phoenix.Naming.camelize(english_title)}"
    work_type = nil

    TextServer.Texts.upsert_work(%{
      description: description,
      english_title: english_title,
      filename: filename,
      filemd5hash: filemd5hash,
      form: form,
      full_urn: full_urn,
      label: label,
      language: language,
      original_title: original_title,
      structure: structure,
      text_group_id: text_group.id,
      urn: urn,
      work_type: work_type
    })
  end
end
