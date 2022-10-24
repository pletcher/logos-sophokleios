defmodule TextServerWeb.ReadingEnvironment.Reader do
  use TextServerWeb, :live_component

  @moduledoc """
  Every screen of TextNodes can be represented as a map of
  List<nodes> and List<elements>.

  When these are rendered, the two lists are merged such that
  every `node` is split into a list where its text is interspersed
  with the starts and ends of `element`s.

  Essentially, this is a rope with the ability to store
  pointers to the `element`s list when an `element` starts
  and ends.

  In its deserialized form, the rope is a binary tree
  where each vertex stores a variable-length of text ---
  i.e., a text node --- its location, and a list of pointers
  to elements that need to be added to it. A node can be
  represented as its own subtree when elements need to be
  inserted into it.

  The rope is then serialized as a string of HTML for
  rendering.

  It should be possible to render a `node` and the `element`s
  "inside" it by splitting the `node`'s text at each `element`'s
  `offset`. If the `element` spans multiple `node`s, it can still
  visually apply to every `node` in between its start and end
  `nodes`.
  """

  def update(%{text_nodes: _text_nodes} = assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  attr :page, :map, required: true
  attr :text_nodes, :list, required: true

  def reading_page(assigns) do
    ~H"""
    <section>
      <%= for text_node <- @text_nodes do %>
        <.text_node graphemes_with_tags={text_node.graphemes_with_tags} location={text_node.location} />
      <% end %>
      <.pagination page={@page} />
    </section>
    """
  end

  attr :page, :map, required: true

  def pagination(assigns) do
    page = assigns[:page]
    current_page = page.page_number
    total_pages = page.total_pages

    ~H"""
    <div class="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6">
      <div class="flex flex-1 justify-between sm:hidden">
        <a href="#" class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Previous</a>
        <a href="#" class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Next</a>
      </div>
      <div class="sm:flex sm:justify-between mx-auto">
        <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
          <.link patch={"?page=#{current_page - 1}"} class={prev_button_classes(current_page)}>
            <span class="sr-only">Previous</span>
            <!-- Heroicon name: mini/chevron-left -->
            <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
            </svg>
          </.link>
          <!-- Current: "z-10 bg-stone-50 border-stone-500 text-stone-600", Default: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50" -->
          <a href="#" aria-current="page" class="relative z-10 inline-flex items-center border border-stone-500 bg-stone-50 px-4 py-2 text-sm font-medium text-stone-600 focus:z-20">1</a>
          <a href="#" class="relative inline-flex items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-20">2</a>
          <a href="#" class="relative hidden items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-20 md:inline-flex">3</a>
          <span class="relative inline-flex items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700">...</span>
          <a href="#" class="relative hidden items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-20 md:inline-flex">8</a>
          <a href="#" class="relative inline-flex items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-20">9</a>
          <a href="#" class="relative inline-flex items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-20">10</a>
          <.link patch={"?page=#{current_page + 1}"} class={next_button_classes(current_page, total_pages)}>
            <span class="sr-only">Next</span>
            <!-- Heroicon name: mini/chevron-right -->
            <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
            </svg>
          </.link>
        </nav>
      </div>
    </div>
    """
  end

  defp nav_button_classes(current_page, i) do
    if current_page == i + 1 do
      ~w(
        relative
        z-10
        inline-flex
        items-center
        border
        border-stone-500
        bg-stone-50
        px-4
        py-2
        text-sm
        font-medium
        text-stone-600
        focus:z-20
      )
    else
      ~w(
        relative
        inline-flex
        items-center
        border
        border-gray-300
        bg-white
        px-4
        py-2
        text-sm
        font-medium
        text-gray-500
        hover:bg-gray-50
        focus:z-20
      )
    end
  end

  defp next_button_classes(current_page, total_pages) do
    if current_page == total_pages do
      ~w(
        relative
        inline-flex
        items-center
        rounded-r-md
        border
        border-gray-300
        bg-white
        px-2
        py-2
        text-sm
        font-medium
        text-gray-100
        disabled
      )
    else
      ~w(
        relative
        inline-flex
        items-center
        rounded-r-md
        border
        border-gray-300
        bg-white
        px-2
        py-2
        text-sm
        font-medium
        text-gray-500
        hover:bg-gray-50
        focus:z-20
      )
    end
  end

  defp prev_button_classes(current_page) do
    if current_page == 1 do
      ~w(
        relative
        inline-flex
        items-center
        rounded-l-md
        border
        border-gray-300
        bg-white
        px-2
        py-2
        text-sm
        font-medium
        text-gray-100
      )
    else
      ~w(
        relative
        inline-flex
        items-center
        rounded-l-md
        border
        border-gray-300
        bg-white
        px-2
        py-2
        text-sm
        font-medium
        text-gray-500
        hover:bg-gray-50
        focus:z-20
      )
    end
  end

  attr :tags, :list, default: []
  attr :text, :string

  def text_element(assigns) do
    tags = assigns[:tags]

    classes =
      tags
      |> Enum.map(&tag_classes/1)
      |> Enum.join(" ")

    if Enum.member?(tags |> Enum.map(& &1.name), "comment") do
      comments =
        tags
        |> Enum.filter(&(&1.name == "comment"))
        |> Enum.map(& &1.metadata[:id])
        |> Jason.encode!()

      ~H"""
      <span class={classes} phx-click="highlight-comments" phx-value-comments={comments}><%= @text %></span>
      """
    else
      ~H"<span class={classes}><%= @text %></span>"
    end
  end

  attr :graphemes_with_tags, :list, required: true
  attr :location, :integer, required: true

  def text_node(assigns) do
    location = assigns[:location] |> Enum.join(".")
    # NOTE: (charles) It's important, unfortunately, for the `for` statement
    # to be on one line so that we don't get extra spaces around elements.
    ~H"""
    <p class="mb-4" title={"Location: #{location}"}>
      <span class="text-slate-500"><%= location %></span>
      <%= for {graphemes, tags} <- @graphemes_with_tags do %><.text_element
        tags={tags}
        text={Enum.join(graphemes)}
      /><% end %>
    </p>
    """
  end

  defp tag_classes(tag) do
    case tag.name do
      "comment" -> "bg-blue-200 cursor-pointer"
      "emph" -> "italic"
      "strong" -> "font-bold"
      "underline" -> "underline"
      _ -> tag.name
    end
  end
end
