defmodule TextServerWeb.ReadLive.Reader do
  use TextServerWeb, :live_view

  def mount(
        %{
          "collection" => collection,
          "text_group" => text_group,
          "work" => work,
          "version" => version
        } = _params,
        _session,
        socket
      ) do
    {:ok,
     socket
     |> assign(
       collection: collection,
       text_group: text_group,
       work: work,
       version: version
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @collection %></h1>
      <h2><%= @text_group %></h2>
      <h3><%= @work %></h3>
      <h4><%= @version %></h4>
    </div>
    """
  end
end
