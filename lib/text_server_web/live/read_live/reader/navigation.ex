defmodule TextServerWeb.ReadLive.Reader.Navigation do
  use TextServerWeb, :component

  # `passages` is a chunked list of lists, where each
  # item is a tuple of the form `{{top_level_citation, second_level_citation}, page_number}`
  attr :current_page, :integer
  attr :passage_refs, :list
  attr :unit_labels, :list

  def navigation_menu(assigns) do
    ~H"""
    <%= if length(@unit_labels) == 3 do %>
      <.unit_labels_3 current_page={@current_page} passage_refs={@passage_refs} unit_labels={@unit_labels} />
    <% else %>
      <nav>
        <ul class="menu bg-base-200 w-56 rounded">
          <%= for group <- @passage_refs do %>
            <li>
              <a
                href={"?page=#{elem(List.first(group), 1)}"}
                class={if(@current_page == elem(List.first(group), 1), do: "active")}
              >
                <%= List.first(@unit_labels) |> :string.titlecase() %>
                <%= List.first(group) |> elem(0) |> elem(0) %>
              </a>
            </li>
          <% end %>
        </ul>
      </nav>
    <% end %>
    """
  end

  attr :current_page, :integer
  attr :passage_refs, :list
  attr :unit_labels, :list

  defp unit_labels_3(assigns) do
    ~H"""
    <nav>
      <ul class="menu bg-base-200 w-56 rounded">
        <%= for group <- @passage_refs do %>
          <li>
            <details open={Enum.map(group, &elem(&1, 1)) |> Enum.any?(&(&1 == @current_page))}>
              <summary>
                <%= List.first(@unit_labels) |> :string.titlecase() %> <%= List.first(group) |> elem(0) |> elem(0) %>
              </summary>
              <ul class="overflow-y-auto max-h-48">
                <%!-- This will work for 3-level texts like Pausanias; what about 1- or 2-level texts? --%>
                <%= for passage <- group do %>
                  <li>
                    <a href={"?page=#{elem(passage, 1)}"} class={if(@current_page == elem(passage, 1), do: "active")}>
                      <%= List.first(@unit_labels) |> :string.titlecase() %>
                      <%= List.first(group) |> elem(0) |> elem(0) %>, <%= Enum.at(@unit_labels, 1) |> :string.titlecase() %>
                      <%= elem(passage, 0) |> elem(1) %>
                    </a>
                  </li>
                <% end %>
              </ul>
            </details>
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end
end
