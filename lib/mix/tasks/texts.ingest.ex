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
    |> Recase.to_camel()
  end

  defp parse_text_group_cts(f, collection) do
    Mix.shell().info("Ingesting text_group CTS at #{f}")

    stream = File.stream!(f)
    {:ok, data} = Saxy.parse_stream(stream, Xml.TextGroupCtsHandler, %{})

    %{
      collection_id: collection.id,
      title: data[:groupname],
      urn: data[:urn],
      language: data[:language]
    }
  end

  defp parse_work_xml(f) do
    Mix.shell().info("Ingesting work CTS at #{f}")

    stream = File.stream!(f)
    {:ok, cts_data} = Saxy.parse_stream(stream, Xml.WorkCtsHandler, {nil, []})

    cts_data
  end

  defp ingest_json_collection(f, collection) do
    path_prefix = Path.expand(System.get_env("TEXT_REPO_DESTINATION", "./tmp"))
    filename = String.replace_prefix(f, "#{path_prefix}/", "")

    Mix.shell().info("Ingesting #{filename}")

    [text_group_fragment, work_fragment, language_fragment] =
      String.split(filename, ".")
      |> List.first()
      |> String.split("__")

    {:ok, binary} = File.read(f)
    {:ok, parsed} = Jason.decode(binary)

    # NOTE: (charles) For many of these texts, "author" is "Not available". Is
    # this actually what we want in our URNs?
    text_group_title =
      case parsed["author"] do
        "" -> "unknown"
        "(Original Book)" -> "original book"
        "Not available" -> "unknown"
        _ -> parsed["author"]
      end

    {:ok, text_group} =
      TextServer.TextGroups.find_or_create_text_group(%{
        collection_id: collection.id,
        title: text_group_title,
        urn: "#{collection.urn}:#{Recase.to_camel(text_group_title)}"
      })

    {:ok, language} =
      TextServer.Languages.find_or_create_language(%{title: String.downcase(parsed["language"])})

    work_urn = "#{text_group.urn}.#{Recase.to_camel(work_fragment)}"
    english_title = parsed["englishTitle"] || text_group.title
    original_title = parsed["originalTitle"]
    description = parsed["description"]

    {:ok, work} =
      TextServer.Works.find_or_create_work(%{
        description: description,
        english_title: english_title,
        original_title: original_title,
        urn: work_urn,
        text_group_id: text_group.id
      })

    # NOTE: (charles) The Middle English texts (so far) are not very
    # well organized. The data itself appears to be mostly fine, but
    # they're missing titles (Piers Plowman was, at least) or have titles
    # that are way too long.

    version_attrs =
      case parsed do
        %{
          "edition" => edition,
          "source" => "The Center for Hellenic Studies",
          "language" => "english"
        } ->
          %{
            title: edition,
            urn: "#{work.urn}.chs-translation",
            version_type: :translation,
            work_id: work.id
          }

        %{"edition" => edition, "source" => "The Center For Hellenic Studies"} ->
          %{
            title: edition,
            urn: "#{work.urn}.chs-#{Recase.to_camel(edition)}",
            version_type: :edition,
            work_id: work.id
          }

        %{"edition" => edition} ->
          %{
            title: edition,
            urn: "#{work.urn}.#{Recase.to_camel(language_fragment)}",
            version_type: :edition,
            work_id: work.id
          }

        _ ->
          %{
            title: original_title || english_title,
            urn: "#{work.urn}.#{Recase.to_camel(language_fragment)}",
            version_type: :edition,
            work_id: work.id
          }
      end

    {:ok, version} = TextServer.Versions.find_or_create_version(version_attrs)

    source = parsed["source"]
    source_link = parsed["sourceLink"]

    {:ok, exemplar} =
      TextServer.Exemplars.find_or_create_exemplar(%{
        description: description,
        filename: filename,
        filemd5hash: :crypto.hash(:md5, binary) |> Base.encode16(case: :lower),
        form: nil,
        label: nil,
        language_id: language.id,
        title: original_title || english_title,
        source: source,
        source_link: source_link,
        structure: nil,
        urn: "#{version.urn}.#{Recase.to_camel(source)}",
        version_id: version.id
      })

    Iteraptor.to_flatmap(parsed["text"])
    |> Enum.map(fn {k, v} ->
      location = String.split(k, ".") |> Enum.map(&String.to_integer/1)

      TextServer.TextNodes.find_or_create_text_node(%{
        location: location,
        text: v,
        exemplar_id: exemplar.id
      })
    end)

    f
  end

  defp ingest_json(dir, collection) do
    Mix.shell().info("... Ingesting JSON-based texts in #{dir} ... \n")

    ingested_files =
      Path.wildcard("#{dir}/*.json")
      |> Stream.map(fn f -> ingest_json_collection(f, collection) end)
      |> Enum.to_list()
      |> Enum.join("\n")

    Mix.shell().info("... Finished ingesting the following JSON files: ... \n #{ingested_files}")
  end

  defp ingest_xml(dir, collection) do
    Mix.shell().info("... Ingesting XML-based texts in: #{dir} ... \n")

    # We only want directories that have a valid __cts__.xml file. We'll handle
    # differentiating between text_group and work directories below, then when
    # we parse a work's CTS XML file, we'll also read in the XML exemplars in
    # that directory.
    cts_glob = Path.wildcard("#{dir}/**/__cts__.xml")

    text_groups_data =
      cts_glob
      |> Stream.filter(fn f ->
        String.split(f, "/data/") |> List.last() |> String.split("/") |> Enum.count() == 2
      end)
      |> Stream.map(fn f -> parse_text_group_cts(f, collection) end)

    works_data =
      cts_glob
      |> Stream.filter(fn f ->
        String.split(f, "/data/") |> List.last() |> String.split("/") |> Enum.count() > 2
      end)
      |> Stream.map(&parse_work_xml/1)

    text_groups =
      text_groups_data
      |> Enum.map(fn tg ->
        TextServer.Languages.find_or_create_language(%{title: Map.get(tg, :language)})
        TextServer.TextGroups.find_or_create_text_group(Map.delete(tg, :language))
      end)

    works =
      works_data
      |> Enum.map(fn ws ->
        Enum.filter(ws, &Map.has_key?(&1, :text_group_urn))
        |> Enum.map(fn w ->
          text_group = TextServer.TextGroups.get_by_urn(Map.get(w, :text_group_urn))
          work_attrs = Map.take(w, Map.keys(TextServer.Works.Work.__struct__()))

          if text_group != nil do
            TextServer.Works.find_or_create_work(
              Map.put(work_attrs, :text_group_id, text_group.id)
            )
          else
            text_group =
              TextServer.TextGroups.find_or_create_text_group(%{
                collection_id: collection.id,
                title: "Orphaned Work Parent Group",
                urn: w[:text_group_urn]
              })

            TextServer.Works.find_or_create_work(
              Map.put(work_attrs, :text_group_id, text_group.id)
            )
          end
        end)

        Enum.filter(ws, &Map.has_key?(&1, :work_urn))
        |> Enum.map(fn v ->
          work = TextServer.Works.get_by_urn(Map.get(v, :work_urn))

          version_attrs =
            Map.take(v, Map.keys(TextServer.Versions.Version.__struct__()))
            |> Map.put(:work_id, work.id)

          TextServer.Versions.find_or_create_version(version_attrs)
        end)
      end)
  end

  defp ingest_repo(repo) do
    %{title: title, url: url} = repo
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

    {:ok, collection} = TextServer.Collections.find_or_create_collection(collection_attrs)

    if File.dir?(json_dir = Path.join(dest, "cltk_json")) do
      # ingest_json(json_dir, collection)
    else
      ingest_xml(Path.join(dest, "data"), collection)
    end
  end

  defp ingest_repos() do
    TextServer.Texts.repositories()
    |> Stream.map(&ingest_repo/1)
    |> Enum.to_list()
  end
end
