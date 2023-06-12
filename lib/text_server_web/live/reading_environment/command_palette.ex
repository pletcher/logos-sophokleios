defmodule TextServerWeb.ReadingEnvironment.CommandPalette do
  use TextServerWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(form: to_form(%{"search_string" => ""}), search_string: "")}
  end

  attr :field, Phoenix.HTML.FormField
  attr :rest, :global, include: ~w(type)

  def input(assigns) do
    ~H"""
    <input id={@field.id} name={@field.name} value={@field.value} {@rest} />
    """
  end

  attr :form, :any
  attr :search_results, :list, default: []
  attr :search_string, :string, default: ""

  def render(assigns) do
    # https://tailwindui.com/components/application-ui/navigation/command-palettes#component-5e859372042e1b3b308dc51f3ac8bad6
    ~H"""
    <div>
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
          <div class="mx-auto max-w-3xl transform divide-y divide-gray-100 overflow-hidden rounded-xl bg-white shadow-2xl ring-1 ring-black ring-opacity-5 transition-all">
            <div class="relative">
              <svg
                class="pointer-events-none absolute left-4 top-3.5 h-5 w-5 text-gray-400"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
                  clip-rule="evenodd"
                />
              </svg>
              <.form for={@form} phx-change="search" phx-target={@myself}>
                <.input
                  type="text"
                  field={@form[:search]}
                  class="h-12 w-full border-0 bg-transparent pl-11 pr-4 text-gray-800 placeholder:text-gray-400 focus:ring-0 sm:text-sm"
                  placeholder="Search..."
                  role="combobox"
                  aria-expanded="false"
                  aria-controls="options"
                />
              </.form>
            </div>
            <!-- Empty state, show/hide based on command palette state -->
            <div :if={@search_results == []} class="px-6 py-14 text-center text-sm sm:px-14">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="mx-auto h-6 w-6 text-gray-400"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="w-6 h-6"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 01-.825-.242m9.345-8.334a2.126 2.126 0 00-.476-.095 48.64 48.64 0 00-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0011.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155"
                />
              </svg>
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

  def handle_event("search", %{"search" => search_string}, socket) do
    {:noreply, socket |> assign(search_string: search_string)}
  end
end
