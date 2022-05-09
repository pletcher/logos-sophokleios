defmodule TextServerWeb.Schema do
  use Absinthe.Schema

  import_types TextServerWeb.Schema.Types.Custom.CtsUrn
  import_types TextServerWeb.Schema.Types.Custom.JSON
  import_types TextServerWeb.Schema.ContentTypes

  alias TextServerWeb.Resolvers

  query do
    field :author, :author do
      arg :id, :id
      arg :slug, :string

      resolve &Resolvers.Texts.find_author_by/3
    end

    field :authors, list_of(:author) do
      arg :limit, :integer
      arg :offset, :integer
      arg :textsearch, :string, deprecate: "Use `textSearch` instead."
      arg :text_search, :string

      resolve &Resolvers.Texts.list_authors/3
    end

    field :authors_count, :integer

    field :collection, :collection do
      arg :id, :id
      arg :slug, :string

      resolve &Resolvers.Texts.find_collection_by/3
    end

    field :collections, list_of(:collection) do
      arg :limit, :integer
      arg :offset, :integer
      arg :textsearch, :string, deprecate: "Use `textSearch` instead."
      arg :text_search, :string
      arg :urn, :cts_urn

      resolve &Resolvers.Texts.list_collections/3
    end

    field :collections_count, :integer

    field :language, :language do
      arg :id, :id
      arg :slug, :string

      resolve &Resolvers.Texts.find_language_by/3
    end

    field :languages, list_of(:language) do
      arg :limit, :integer
      arg :offset, :integer
      arg :textsearch, :string, deprecate: "Use `textSearch` instead."
      arg :text_search, :string

      resolve &Resolvers.Texts.list_languages/3
    end

    field :languages_count, :integer

    field :light_weight_cts, :string do
      arg :urn, :cts_urn

      resolve &Resolvers.CTS.parse_light_weight_cts_urn/3
    end

    field :perseus_cts, :string do
      arg :level, :integer
      arg :request, :string
      arg :urn, :cts_urn

      resolve &Resolvers.CTS.parse_perseus_cts_urn/3
    end

    field :refs_decl, :refs_decl do
      arg :id, non_null(:id)

      resolve &Resolvers.Texts.get_refs_decl/3
    end

    field :text_group, :text_group do
      arg :id, :id
      arg :slug, :string

      resolve &Resolvers.Texts.get_text_group/3
    end

    field :text_groups, list_of(:text_group) do
      arg :limit, :integer
      arg :offset, :integer
      arg :textsearch, :string, deprecate: "Use `textSearch` instead."
      arg :text_search, :string
      arg :urn, :cts_urn
      arg :urns, list_of(:cts_urn)

      resolve &Resolvers.Texts.list_text_groups/3
    end

    field :text_nodes, list_of(:text_node) do
      arg :ends_at_location, list_of(:integer)
      arg :index, :integer
      arg :language, :string
      arg :location, list_of(:integer)
      arg :offset, :integer
      arg :page_size, :integer
      arg :starts_at_index, :integer
      arg :starts_at_location, list_of(:integer)
      arg :urn, non_null(:cts_urn)
      arg :work_id, :id

      resolve &Resolvers.Texts.list_text_nodes/3
    end

    field :text_node_search, :text_node_search_results do
      arg :after, :integer
      arg :before, :integer
      arg :first, :integer
      arg :last, :integer
      arg :textsearch, :string, deprecate: "Use `textSearch` instead."
      arg :text_search, :string
      arg :work_id, :id

      resolve &Resolvers.Texts.search_text_nodes/3
    end

    field :work, :work do
      arg :id, :id
      arg :slug, :string

      resolve &Resolvers.Texts.get_work/3
    end

    field :work_by_urn, :work do
      arg :full_urn, :string

      resolve &Resolvers.Texts.get_work/3
    end

    field :works, list_of(:work) do
      arg :full_urn, :string
      arg :language, :string
      arg :limit, :integer
      arg :offset, :integer
      arg :textsearch, :string, deprecate: "Use `textSearch` instead."
      arg :text_search, :string
      arg :urn, :cts_urn

      resolve &Resolvers.Texts.list_works/3
    end

    field :works_count, :integer

    field :work_search, :work_search_results do
      arg :language, :string
      arg :limit, :integer
      arg :offset, :integer
      arg :textsearch, :string, deprecate: "Use `textSearch` instead."
      arg :text_search, :string

      resolve &Resolvers.Texts.search_works/3
    end
  end

  mutation do
    field :refs_decl_update, :refs_decl do
      arg :id, :id
      arg :refs_decl, :refs_decl_input

      resolve &Resolvers.Texts.update_refs_decl/3
    end

    field :text_node_create, :text_node do
      arg :text_node, non_null(:text_node_input)

      resolve &Resolvers.Texts.create_text_node/3
    end

    field :text_node_remove, :remove_type do
      arg :id, non_null(:id)

      resolve &Resolvers.Texts.delete_text_node/3
    end

    field :text_node_update, :text_node do
      arg :id, non_null(:id)
      arg :text_node, :text_node_input

      resolve &Resolvers.Texts.update_text_node/3
    end

    field :translation_create, :translation do
      arg :translation, non_null(:translation_input)

      resolve &Resolvers.Texts.create_translation/3
    end

    field :translation_remove, :remove_type do
      arg :id, non_null(:id)

      resolve &Resolvers.Texts.delete_translation/3
    end

    field :translation_update, :translation do
      arg :id, non_null(:id)
      arg :translation, :translation_input

      resolve &Resolvers.Texts.update_translation/3
    end

    field :version_update, :version do
      arg :id, non_null(:id)
      arg :version, :version_input

      resolve &Resolvers.Texts.update_version/3
    end

    field :work_create, :work do
      arg :work, non_null(:work_input)

      resolve &Resolvers.Texts.create_work/3
    end

    field :work_remove, :remove_type do
      arg :id, non_null(:id)

      resolve &Resolvers.Texts.delete_work/3
    end

    field :work_update, :work do
      arg :id, non_null(:id)
      arg :work, :work_input

      resolve &Resolvers.Texts.update_work/3
    end
  end
end
