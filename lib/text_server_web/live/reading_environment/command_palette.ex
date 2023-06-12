defmodule TextServerWeb.ReadingEnvironment.CommandPalette do
  use TextServerWeb, :live_component

  alias TextServer.TextNodes.TextNode
  alias TextServerWeb.Icons

  def mount(socket) do
    {:ok, socket |> assign(changeset: to_form(TextNode.search_changeset(), as: :search))}
  end

  attr :field, Phoenix.HTML.FormField
  attr :rest, :global, include: ~w(class type)

  def input(assigns) do
    ~H"""
    <input id={@field.id} name={@field.name} value={@field.value} {@rest} />
    """
  end

  attr :changeset, :any
  attr :is_open, :boolean, default: false
  attr :search_results, :list, default: []
  attr :text_node, :map
  attr :urn, :string, required: true

  def render(assigns) do
    # https://tailwindui.com/components/application-ui/navigation/command-palettes#component-5e859372042e1b3b308dc51f3ac8bad6
    ~H"""
    <div class={unless @is_open, do: "hidden"}>
      <div class="relative z-10" role="dialog" aria-modal="true">
        <!--
          Background backdrop, show/hide based on modal state.

          Entering: "ease-out duration-300"
            From: "opacity-0"
            To: "opacity-100"
          Leaving: "ease-in duration-200"
            From: "opacity-100"
            To: "opacity-0"
        -->
        <div class="fixed inset-0 bg-gray-500 bg-opacity-25 transition-opacity"></div>

        <div class="fixed inset-0 z-10 overflow-y-auto p-4 sm:p-6 md:p-20">
          <!--
            Command palette, show/hide based on modal state.

            Entering: "ease-out duration-300"
              From: "opacity-0 scale-95"
              To: "opacity-100 scale-100"
            Leaving: "ease-in duration-200"
              From: "opacity-100 scale-100"
              To: "opacity-0 scale-95"
          -->
          <div class="mx-auto max-w-3xl transform divide-y divide-gray-100 overflow-hidden rounded-xl bg-white shadow-2xl ring-1 ring-black ring-opacity-5 transition-all" phx-click-away="command-palette-click-away" phx-target={@myself}>
            <div class="relative">
              <Icons.search_icon />
              <.form for={@changeset} phx-change="search" phx-target={@myself}>
                <.input
                  type="text"
                  field={@changeset[:search_string]}
                  class="h-12 w-full border-0 bg-transparent pl-11 pr-4 text-gray-800 placeholder:text-gray-400 focus:ring-0 sm:text-sm"
                  placeholder="Search for critica in other versions"
                  role="combobox"
                  aria-expanded="false"
                  aria-controls="options"
                />
              </.form>
            </div>
            <!-- Empty state, show/hide based on command palette state -->
            <div :if={@search_results == []} class="px-6 py-14 text-center text-sm sm:px-14">
              <Icons.critica_icon />
              <p class="mt-4 font-semibold text-gray-900">No critica found.</p>
              <p class="mt-2 text-gray-500">We couldn&apos;t find anything with that term. Please try again.</p>
            </div>
            <div :if={@search_results != []} class="flex divide-x divide-gray-100">
              <!-- Preview Visible: "sm:h-96" -->
              <div class="max-h-96 min-w-0 flex-auto scroll-py-4 overflow-y-auto px-6 py-4 sm:h-96">
                <!-- Default state, show/hide based on command palette state. -->
                <h2 class="mb-4 mt-2 text-xs font-semibold text-gray-500">Recent searches</h2>
                <ul class="-mx-2 text-sm text-gray-700" id="recent" role="listbox">
                  <!-- Active: "bg-gray-100 text-gray-900" -->
                  <li
                    class="group flex cursor-default select-none items-center rounded-md p-2"
                    id="recent-1"
                    role="option"
                    tabindex="-1"
                  >
                    <img
                      src="https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                      alt=""
                      class="h-6 w-6 flex-none rounded-full"
                    />
                    <span class="ml-3 flex-auto truncate">Floyd Miles</span>
                    <!-- Not Active: "hidden" -->
                    <svg
                      class="ml-3 hidden h-5 w-5 flex-none text-gray-400"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  </li>
                </ul>
                <!-- Results, show/hide based on command palette state. -->
                <ul class="-mx-2 text-sm text-gray-700" id="options" role="listbox">
                  <!-- Active: "bg-gray-100 text-gray-900" -->
                  <li
                    class="group flex cursor-default select-none items-center rounded-md p-2"
                    id="option-1"
                    role="option"
                    tabindex="-1"
                  >
                    <img
                      src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                      alt=""
                      class="h-6 w-6 flex-none rounded-full"
                    />
                    <span class="ml-3 flex-auto truncate">Tom Cook</span>
                    <!-- Not Active: "hidden" -->
                    <svg
                      class="ml-3 hidden h-5 w-5 flex-none text-gray-400"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  </li>
                  <li
                    class="group flex cursor-default select-none items-center rounded-md p-2"
                    id="option-2"
                    role="option"
                    tabindex="-1"
                  >
                    <img
                      src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                      alt=""
                      class="h-6 w-6 flex-none rounded-full"
                    />
                    <span class="ml-3 flex-auto truncate">Courtney Henry</span>
                    <svg
                      class="ml-3 hidden h-5 w-5 flex-none text-gray-400"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  </li>
                  <li
                    class="group flex cursor-default select-none items-center rounded-md p-2"
                    id="option-3"
                    role="option"
                    tabindex="-1"
                  >
                    <img
                      src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                      alt=""
                      class="h-6 w-6 flex-none rounded-full"
                    />
                    <span class="ml-3 flex-auto truncate">Dries Vincent</span>
                    <svg
                      class="ml-3 hidden h-5 w-5 flex-none text-gray-400"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  </li>
                  <li
                    class="group flex cursor-default select-none items-center rounded-md p-2"
                    id="option-4"
                    role="option"
                    tabindex="-1"
                  >
                    <img
                      src="https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                      alt=""
                      class="h-6 w-6 flex-none rounded-full"
                    />
                    <span class="ml-3 flex-auto truncate">Kristin Watson</span>
                    <svg
                      class="ml-3 hidden h-5 w-5 flex-none text-gray-400"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  </li>
                  <li
                    class="group flex cursor-default select-none items-center rounded-md p-2"
                    id="option-5"
                    role="option"
                    tabindex="-1"
                  >
                    <img
                      src="https://images.unsplash.com/photo-1517070208541-6ddc4d3efbcb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                      alt=""
                      class="h-6 w-6 flex-none rounded-full"
                    />
                    <span class="ml-3 flex-auto truncate">Jeffrey Webb</span>
                    <svg
                      class="ml-3 hidden h-5 w-5 flex-none text-gray-400"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  </li>
                </ul>
              </div>
              <!-- Active item side-panel, show/hide based on active state -->
              <div class="hidden h-96 w-1/2 flex-none flex-col divide-y divide-gray-100 overflow-y-auto sm:flex">
                <div class="flex-none p-6 text-center">
                  <img
                    src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                    alt=""
                    class="mx-auto h-16 w-16 rounded-full"
                  />
                  <h2 class="mt-3 font-semibold text-gray-900">Tom Cook</h2>
                  <p class="text-sm leading-6 text-gray-500">Director, Product Development</p>
                </div>
                <div class="flex flex-auto flex-col justify-between p-6">
                  <dl class="grid grid-cols-1 gap-x-6 gap-y-3 text-sm text-gray-700">
                    <dt class="col-end-1 font-semibold text-gray-900">Phone</dt>
                    <dd>881-460-8515</dd>
                    <dt class="col-end-1 font-semibold text-gray-900">URL</dt>
                    <dd class="truncate">
                      <a href="https://example.com" class="text-indigo-600 underline">https://example.com</a>
                    </dd>
                    <dt class="col-end-1 font-semibold text-gray-900">Email</dt>
                    <dd class="truncate"><a href="#" class="text-indigo-600 underline">tomcook@example.com</a></dd>
                  </dl>
                  <button
                    type="button"
                    class="mt-6 w-full rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                  >
                    Send message
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"search" => search_params}, socket) do
    changeset =
      TextNode.search_changeset(search_params)
      |> to_form(as: :search)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("command-palette-click-away", _, socket) do
    send self(), {:focused_text_node, nil}
    {:noreply, socket}
  end
end
