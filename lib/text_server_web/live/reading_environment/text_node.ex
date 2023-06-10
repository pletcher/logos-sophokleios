defmodule TextServerWeb.ReadingEnvironment.TextNode do
  use TextServerWeb, :live_component

  attr :id, :string, required: true
  attr :is_focused, :boolean, default: false
  attr :graphemes_with_tags, :list, required: true
  attr :location, :integer, required: true

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(is_focused: false)}
  end

  @impl true
  def render(assigns) do
    location = assigns[:location] |> Enum.join(".")
    # NOTE: (charles) It's important, unfortunately, for the `for` statement
    # to be on one line so that we don't get extra spaces around elements.
    ~H"""
    <p
      class={["mb-4", "px-4", "rounded", text_node_classes(@is_focused)]}
      phx-click="text-node-click"
      phx-click-away="text-node-click-away"
      phx-target={@myself}
      phx-value-urn={@id}
    >
      <span class="text-slate-500" title={"Location: #{location}"}><%= location %></span>
      <.text_element :for={{graphemes, tags} <- @graphemes_with_tags} tags={tags} text={Enum.join(graphemes)} />
    </p>
    """
  end

  @spec text_node_classes(boolean()) :: String.t()
  defp text_node_classes(is_focused) do
    if is_focused do
      "cursor-context-menu ring-4"
    else
      "cursor-pointer"
    end
  end

  @impl true
  def handle_event("text-node-click", %{"urn" => urn}, socket) do
    {:noreply, socket |> assign(focused_text_node: urn, is_focused: !socket.assigns.is_focused)}
  end

  def handle_event("text-node-click-away", %{"urn" => _urn}, socket) do
    {:noreply, socket |> assign(focused_text_node: nil, is_focused: false)}
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

      Enum.member?(tags |> Enum.map(& &1.name), "image") ->
        image = tags |> Enum.find(&(&1.name == "image"))
        meta = Map.get(image, :metadata, %{})

        if is_nil(meta) do
          ~H"<span />"
        else
          src = Map.get(meta, :src)
          ~H"<img class={classes} src={src} />"
        end

      Enum.member?(tags |> Enum.map(& &1.name), "link") ->
        link = tags |> Enum.find(&(&1.name == "link"))
        meta = Map.get(link, :metadata, %{})
        src = Map.get(meta, :src)

        ~H"""
        <a class={classes} href={src}><%= @text %></a>
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

  defp tag_classes(tag) do
    case tag.name do
      "comment" -> "bg-blue-200 cursor-pointer"
      "emph" -> "italic"
      "image" -> "image mt-10"
      "link" -> "link font-bold underline hover:opacity-75 visited:opacity-60"
      "strong" -> "font-bold"
      "underline" -> "underline"
      _ -> tag.name
    end
  end
end
