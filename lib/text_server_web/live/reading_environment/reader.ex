defmodule TextServerWeb.ReadingEnvironment.Reader do
  use TextServerWeb, :live_component

  alias TextServerWeb.Components

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

  attr :top_level_toc, :list, required: true
  attr :second_level_toc, :list, required: true

  def reading_location(assigns) do
    ~H"""
    <.form :let={f} for={:location} phx-change="location-select-change">
      <section class="flex">
        <%= select f, :top_level_location, @top_level_toc, class: top_level_css_classes() %>
        <%= select f, :second_level_location, @second_level_toc, class: second_level_css_classes() %>
      </section>
    </.form>
    """
  end

  defp top_level_css_classes do
    ~w(
      appearance-none
      relative
      resize-none
      flex-1
      py-2
      mb-4
      border
      border-gray-300
      placeholder-gray-500
      text-gray-900
      focus:outline-none
      focus:ring-stone-500
      focus:border-stone-500
      focus:z-10
      sm:text-sm
    )
  end

  defp second_level_css_classes do
    ~w(
      appearance-none
      relative
      resize-none
      flex-1
      py-2
      mb-4
      ml-4
      border
      border-gray-300
      placeholder-gray-500
      text-gray-900
      focus:outline-none
      focus:ring-stone-500
      focus:border-stone-500
      focus:z-10
      sm:text-sm
    )
  end

  attr :text_nodes, :list, required: true

  def reading_page(assigns) do
    ~H"""
    <section>
      <%= for text_node <- @text_nodes do %>
        <.text_node graphemes_with_tags={text_node.graphemes_with_tags} location={text_node.location} />
      <% end %>
    </section>
    """
  end

  attr :tags, :list, default: []
  attr :text, :string

  def text_element(assigns) do
    tags = assigns[:tags]

    classes =
      tags
      |> Enum.map(&tag_classes/1)
      |> Enum.join(" ")

    cond do
      Enum.member?(tags |> Enum.map(& &1.name), "comment") ->
        comments =
          tags
          |> Enum.filter(&(&1.name == "comment"))
          |> Enum.map(& &1.metadata[:id])
          |> Jason.encode!()

        ~H"""
        <span class={classes} phx-click="highlight-comments" phx-value-comments={comments}><%= @text %></span>
        """
      Enum.member?(tags |> Enum.map(& &1.name), "note") ->
        footnote = tags |> Enum.find(&(&1.name == "note"))
        meta = footnote.metadata

        ~H"""
        <span class={classes}><%= @text %><a href={"#_fn-#{meta[:id]}"} id={"_fn-ref-#{meta[:id]}"}><sup>*</sup></a></span>
        """
      true ->
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
