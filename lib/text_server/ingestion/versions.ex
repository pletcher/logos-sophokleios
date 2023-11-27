defmodule TextServer.Ingestion.Versions do
  alias TextServer.Collections
  alias TextServer.ElementTypes
  alias TextServer.Languages
  alias TextServer.TextElements
  alias TextServer.TextGroups
  alias TextServer.TextNodes
  alias TextServer.TextTokens
  alias TextServer.Versions
  alias TextServer.Works

  require Logger

  def create_versions do
    {:ok, collection} = create_collection()
    {:ok, text_group} = create_text_group(collection)
    {:ok, work} = create_work(text_group)
    {:ok, language} = create_language()

    for xml_file <- xml_files() do
      xml = File.read!(xml_file)

      {:ok, version} = create_version(work, language, xml)

      version = TextServer.Repo.preload(version, :xml_document)

      if is_nil(version.xml_document) do
        Versions.create_xml_document!(version, %{document: xml})
      end

      create_text_nodes(version)

      version
    end
  end

  defp create_collection do
    Collections.find_or_create_collection(%{
      repository: "https://github.com/PerseusDL/canonical-greekLit",
      urn: "urn:cts:greekLit",
      title: "Perseus Digital Library: Canonical Greek Literature"
    })
  end

  defp create_language do
    Languages.find_or_create_language(%{slug: "grc", title: "Greek"})
  end

  defp create_text_group(%Collections.Collection{} = collection) do
    TextGroups.find_or_create_text_group(%{
      title: "Sophocles",
      urn: "urn:cts:greekLit:tlg0011",
      collection_id: collection.id
    })
  end

  defp create_text_nodes(%Versions.Version{} = version) do
    # make sure we have a fresh version
    version =
      TextServer.Repo.get(Versions.Version, version.id) |> TextServer.Repo.preload(:xml_document)

    {:ok, data} = DataSchema.to_struct(version.xml_document, DataSchemas.Version)

    %{word_count: _word_count, lines: lines} =
      data.body.lines
      |> Enum.reduce(%{word_count: 0, lines: []}, fn line, acc ->
        text = line.text |> String.trim()
        word_count = acc.word_count

        words =
          Regex.split(~r/[[:space:]]+/, text)
          |> Enum.with_index()
          |> Enum.map(fn {word, index} ->
            offset =
              case String.split(text, word, parts: 2) do
                [left, _] -> String.length(left)
                [_] -> nil
              end

            %{
              xml_id: "word_index_#{word_count + index}",
              offset: offset,
              text: word
            }
          end)

        new_line = %{elements: line.elements, location: [line.n], text: text, words: words}

        %{word_count: word_count + length(words), lines: [new_line | acc.lines]}
      end)

    lines = Enum.reverse(lines)

    lines
    |> Enum.with_index()
    |> Enum.each(fn {line, index} ->
      {:ok, text_node} =
        TextNodes.find_or_create_text_node(%{
          n: index,
          location: line.location,
          text: line.text,
          urn: "#{version.urn}:#{Enum.at(line.location, 0)}",
          version_id: version.id
        })

      text_elements =
        line.elements
        |> Enum.map(fn element ->
          {:ok, element_type} = ElementTypes.find_or_create_element_type(%{name: element.name})

          {:ok, text_element} =
            %{
              attributes: Map.new(element.attributes),
              end_offset: element.end_offset,
              element_type_id: element_type.id,
              end_text_node_id: text_node.id,
              start_offset: element.start_offset,
              start_text_node_id: text_node.id
            }
            |> TextElements.find_or_create_text_element()

          text_element
        end)

      TextNodes.tokenize_text_node(text_node)
      |> Enum.each(fn {token, word, offset} ->
        case TextTokens.create_text_token(%{
               content: token,
               offset: offset,
               word: word,
               text_node_id: text_node.id
             }) do
          {:ok, text_token} ->
            relevant_elements =
              text_elements
              |> Enum.filter(fn te ->
                cond do
                  te.start_text_node_id == text_node.id ->
                    text_token.offset >= te.start_offset

                  te.end_text_node_id == text_node.id ->
                    text_token.offset <= te.end_offset

                  true ->
                    # this text element does not match
                    # this token, so return false
                    false
                end
              end)

            relevant_elements
            |> Enum.each(fn text_element ->
              TextTokens.create_text_token_text_element(%{
                text_element_id: text_element.id,
                text_token_id: text_token.id
              })
            end)

            text_token

          {:error, error} ->
            Logger.warning("Invalid token: #{inspect(error)}")
        end
      end)
    end)
  end

  defp create_version(%Works.Work{} = work, %Languages.Language{} = language, xml) do
    Versions.find_or_create_version(%{
      description: "edited by Hugh Lloyd-Jones",
      filename: "lloyd-jones1994/tlg0011.tlg003.ajmc-lj.xml",
      filemd5hash: :crypto.hash(:md5, xml) |> Base.encode16(case: :lower),
      label: "Sophocles' <i>Ajax</i>",
      language_id: language.id,
      urn: "urn:cts:greekLit:tlg0011.tlg003.ajmc-lj",
      version_type: :edition,
      work_id: work.id
    })
  end

  defp create_work(%TextGroups.TextGroup{} = text_group) do
    Works.find_or_create_work(%{
      description: "",
      english_title: "Ajax",
      original_title: "Αἶας",
      urn: "urn:cts:greekLit:tlg0011.tlg003",
      text_group_id: text_group.id
    })
  end

  defp xml_files do
    Path.wildcard("priv/source_texts/xml/*.xml")
    |> Enum.map(&Application.app_dir(:text_server, &1))
  end
end
