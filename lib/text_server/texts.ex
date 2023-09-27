defmodule TextServer.Texts do
  @moduledoc """
  The Texts context.
  """

  import Ecto.Query, warn: false

  alias TextServer.Works

  def clone_repo(repo) do
    %{:url => url} = repo

    dir = Path.expand(Application.get_env(:text_server, :text_repo_destination, "./tmp"))

    repo_dir_name =
      String.split(url, "/")
      |> List.last()
      |> String.replace(".git", "")

    dest = Path.join(dir, repo_dir_name) |> Path.expand("./")

    System.cmd("git", ["clone", url, dest])
  end

  def clone_repos() do
    TextServer.Texts.repositories()
    |> Enum.map(&clone_repo/1)
  end

  def collection_urn(url) do
    String.split(url, "/")
    |> List.last()
    |> String.replace(Path.extname(url), "")
    |> Recase.to_camel()
  end

  def ingest_repo(repo) do
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
      ingest_json(json_dir, collection)
    end
  end

  def ingest_repos() do
    TextServer.Texts.repositories()
    |> Stream.map(&ingest_repo/1)
    |> Enum.to_list()
  end

  def pull_repo(repo) do
    %{:url => url} = repo
    dir = Path.expand(Application.get_env(:text_server, :text_repo_destination, "./tmp"))

    repo_dir_name =
      String.split(url, "/")
      |> List.last()
      |> String.replace(".git", "")

    dest = Path.join(dir, repo_dir_name) |> Path.expand("./")

    System.cmd("git", ["-C", dest, "pull"])
  end

  def pull_repos() do
    TextServer.Texts.repositories()
    |> Enum.map(&pull_repo/1)
  end

  def get_filename_from_path(s) do
    path_prefix = Path.expand(Application.get_env(:text_server, :text_repo_destination, "tmp"))

    String.replace_prefix(s, "#{path_prefix}/", "")
  end

  defp ingest_json_collection(f, collection) do
    filename = get_filename_from_path(f)

    IO.puts("Ingesting #{filename}")

    [_text_group_fragment, work_fragment, language_fragment] =
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
      Works.find_or_create_work(%{
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
            label: edition,
            urn: "#{work.urn}.chs-translation",
            version_type: :translation,
            work_id: work.id
          }

        %{"edition" => edition, "source" => "The Center For Hellenic Studies"} ->
          %{
            label: edition,
            urn: "#{work.urn}.chs-#{Recase.to_camel(edition)}",
            version_type: :edition,
            work_id: work.id
          }

        %{"edition" => edition} ->
          %{
            label: edition,
            urn: "#{work.urn}.#{Recase.to_camel(language_fragment)}",
            version_type: :edition,
            work_id: work.id
          }

        _ ->
          %{
            label: original_title || english_title,
            urn: "#{work.urn}.#{Recase.to_camel(language_fragment)}",
            version_type: :edition,
            work_id: work.id
          }
      end

    {:ok, version} = TextServer.Versions.find_or_create_version(version_attrs)

    source = parsed["source"]
    source_link = parsed["sourceLink"]

    {:ok, version} =
      TextServer.Versions.find_or_create_version(%{
        description: description,
        filename: filename,
        filemd5hash: :crypto.hash(:md5, binary) |> Base.encode16(case: :lower),
        form: nil,
        label: original_title || english_title,
        language_id: language.id,
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
        version_id: version.id
      })
    end)

    f
  end

  defp ingest_json(dir, collection) do
    IO.puts("... Ingesting JSON-based texts in #{dir} ... \n")

    ingested_files =
      Path.wildcard("#{dir}/*.json")
      |> Stream.map(fn f -> ingest_json_collection(f, collection) end)
      |> Enum.to_list()

    IO.puts("... Finished ingesting the following JSON files: ... \n #{inspect(ingested_files)}")
  end

  def repositories do
    [
      # %{
      #   title: "The Center for Hellenic Studies Greek Texts",
      #   url: "http://gitlab.archimedes.digital/archimedes/greek_text_chs",
      #   urn: "urn:cts:greekLit"
      #   default_language: "greek"
      # },
      %{
        title: "The First Thousand Years of Greek",
        url: "https://github.com/OpenGreekAndLatin/First1KGreek.git",
        urn: "urn:cts:greekLit"
      },
      %{
        title: "Canonical Greek Literature",
        url: "https://github.com/PerseusDL/canonical-greekLit.git",
        urn: "urn:cts:greekLit"
      },
      %{
        title: "Canonical Latin Literature",
        url: "https://github.com/PerseusDL/canonical-latinLit.git",
        urn: "urn:cts:latinLit"
      }
      # %{
      #   title: "Corpus Scriptorum Ecclesiasticorum Latinorum",
      #   url: "https://github.com/OpenGreekAndLatin/csel-dev.git",
      #   urn: "urn:cts:latinLit"
      # },
      # %{
      #   title: "Tanzil Quran Text",
      #   url: "https://github.com/cltk/arabic_text_quranic_corpus.git",
      #   default_language: "arabic"
      # },
      # %{
      #   title: "Sefaria Jewish Texts",
      #   url: "https://github.com/cltk/hebrew_text_sefaria.git",
      #   default_language: "hebrew"
      # },
      # %{
      #   title: "Gita Supersite",
      #   url: "https://github.com/cltk/sanskrit_text_gitasupersite.git",
      #   default_language: "sanskrit"
      # },
      # %{
      #   title: "Classical Bengali Texts",
      #   url: "https://github.com/cltk/bengali_text_wikisource.git",
      #   default_language: "bengali"
      # },
      # %{
      #   title: "Classical Hindi Texts",
      #   url: "https://github.com/cltk/hindi_text_ltrc.git",
      #   default_language: "hindi"
      # },
      # %{
      #   title: "Corpus of Middle English Prose and Verse",
      #   url: "https://github.com/cltk/middle_english_text_cmepv.git",
      #   default_language: "middle_english"
      # },
      # %{
      #   title: "Poeti d'Italia in lingua latina",
      #   url: "https://github.com/cltk/latin_text_poeti_ditalia.git",
      #   default_language: "latin"
      # },
      # %{
      #   title: "Canonical Old Norse Literature",
      #   url: "https://github.com/cltk/old_norse_text_perseus.git",
      #   default_language: "old_norse"
      # },
      # %{
      #   title: "Old English Poetry",
      #   url: "https://github.com/cltk/old_english_text_sacred_texts.git",
      #   default_language: "old_english"
      # },
      # %{
      #   title: "Chinese Buddhist Electronic Text Association 01",
      #   url: "https://github.com/cltk/chinese_text_cbeta_01.git",
      #   default_language: "chinese"
      # }
    ]
  end
end
