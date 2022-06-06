defmodule TextServerWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  alias TextServerWeb.Resolvers

  object :author do
    field :id, :id
    field :english_name, :string
    field :slug, :string
    field :works, list_of(:work)
  end

  object :collection do
    field :id, :id
    field :title, :string
    field :slug, :string
    field :urn, :string
    field :repository, :string
    field :text_groups, list_of(:text_group) do
      arg :textsearch, :string
      arg :urn, :cts_urn
      arg :limit, :integer
      arg :offset, :integer

      resolve &Resolvers.Texts.list_text_groups_in_collection/3
    end
  end

  object :edition do
    field :id, :id
    field :title, :string
    field :slug, :string
    field :description, :string
    field :urn, :string
  end

  object :language do
    field :id, :id
    field :title, :string
    field :slug, :string
  end

  object :page_info do
    field :count, :integer
    field :has_next_page, :boolean
    field :has_previous_page, :boolean
    field :pages, :integer
  end

  object :refs_decl do
    field :id, :id
    field :description, :string
    field :label, :string
    field :match_pattern, :string
    field :replacement_pattern, :string
    field :slug, :string
    field :structure_index, :integer
    field :urn, :string
  end

  object :remove_type do
    field :id, :id
  end

  object :table_of_contents_node do
    field :label, :string
    field :index, :integer
    field :children, list_of(:json)
  end

  object :text_group, name: "TextGroup" do
    field :id, :id
    field :title, :string
    field :slug, :string
    field :collection_id, :integer
    field :works, list_of(:work) do
      arg :textsearch, :string
      arg :urn, :cts_urn
      arg :language, :string
      arg :edition, :string
      arg :limit, :integer
      arg :offset, :integer

      resolve &Resolvers.Texts.list_works_in_text_group/3
    end

    field :work, :work do
      arg :id, :integer
      arg :slug, :string

      resolve &Resolvers.Texts.find_work_by/3
    end
  end

  object :text_node do
    field :id, :id
    field :index, :integer
    field :location, list_of(:integer)
    field :normalized_text, :string
    field :text, :string
    field :urn, :cts_urn
    field :words, list_of(:word)
    field :language, :language

    field :edition, :edition do
      arg :id, :integer
      arg :slug, :string

      resolve &Resolvers.Texts.find_edition_by/3
    end

    field :translation, :translation do
      arg :id, :integer
      arg :slug, :string

      resolve &Resolvers.Texts.find_translation_by/3
    end

    field :version, :version do
      arg :id, :integer
      arg :slug, :string

      resolve &Resolvers.Texts.find_version_by/3
    end
  end

  object :text_node_search_results do
    field :page_info, :page_info
    field :text_nodes, list_of(:text_node)
  end

  object :translation do
    field :id, :id
    field :title, :string
    field :slug, :string
    field :description, :string
    field :urn, :string
  end

  object :version do
    field :id, :id
    field :title, :string
    field :slug, :string
    field :description, :string
    field :urn, :string
  end

  object :word do
    field :word, :string
    field :urn, :cts_urn
  end

  object :work do
    field :id, :id
    field :description, :string
    field :edition, :edition do
      arg :id, :integer
      arg :slug, :string

      resolve &Resolvers.Texts.find_edition_by/3
    end

    field :filemd5hash, :string
    field :filename, :string
    field :form, :string
    field :full_urn, :string
    field :label, :string
    field :language, :language
    field :original_title, :string
    field :refs_decls, list_of(:refs_decl) do
      arg :id, :integer

      resolve &Resolvers.Texts.list_refs_decls/3
    end

    field :slug, :string
    field :structure, :string
    field :table_of_contents, [name: "tableOfContent", type: list_of(:table_of_contents_node)]
    field :text_group_id, [name: "textGroupID", type: :integer]
    field :text_location_next, list_of(:integer) do
      arg :index, :integer
      arg :location, list_of(:integer)
      arg :offset, :integer

      resolve &Resolvers.Texts.find_next_text_location_by/3
    end

    field :text_location_prev, list_of(:integer) do
      arg :index, :integer
      arg :location, list_of(:integer)
      arg :offset, :integer

      resolve &Resolvers.Texts.find_previous_text_location_by/3
    end

    field :text_nodes, list_of(:text_node) do
      arg :ends_at_location, [name: "endsAtLocation", type: list_of(:integer)]
      arg :index, :integer
      arg :location, list_of(:integer)
      arg :offset, :integer
      arg :page_size, :integer
      arg :starts_at_index, :integer
      arg :starts_at_location, list_of(:integer)
      arg :urn, :cts_urn

      resolve &Resolvers.Texts.find_text_nodes_by/3
    end

    field :translation, :translation do
      arg :id, :integer
      arg :slug, :string

      resolve &Resolvers.Texts.find_translation_by/3
    end

    field :urn, :cts_urn
    field :version, :version do
      arg :id, :integer
      arg :slug, :string

      resolve &Resolvers.Texts.find_version_by/3
    end

    field :work_type, :string
  end

  object :work_search_results do
    field :works, list_of(:work)
    field :total, :integer
  end

  input_object :refs_decl_input do
    field :label, :string
    field :slug, :string
    field :description, :string
    field :match_pattern, :string
    field :replacement_pattern, :string
    field :structure_index, :integer
    field :urn, :string
  end

  input_object :text_node_input do
    field :index, :integer
    field :location, list_of(:integer)
    field :normalized_text, :string
    field :text, :string
  end

  input_object :translation_input do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :urn, :string
  end

  input_object :version_input do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :urn, :string
  end

  input_object :work_input do
    field :description, :string
    field :english_title, :string
    field :filemd5hash, :string
    field :filename, :string
    field :form, :string
    field :full_urn, :string
    field :label, :string
    field :original_title, :string
    field :slug, :string
    field :structure, :string
    field :urn, :string
    field :work_type, :string
  end
end
