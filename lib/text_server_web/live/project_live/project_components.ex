defmodule TextServerWeb.ProjectLive.ProjectComponents do
  use TextServerWeb, :component

  def card(%{project: project} = assigns) do
    ~H"""
    <div class="group relative">
      <div class="w-full min-h-80 bg-gray-200 aspect-w-1 aspect-h-1 rounded-md overflow-hidden group-hover:opacity-75 lg:h-80 lg:aspect-none">
        <img
          src="https://tailwindui.com/img/ecommerce-images/product-page-01-related-product-01.jpg"
          alt="Front of men&#039;s Basic Tee in black."
          class="w-full h-full object-center object-cover lg:w-full lg:h-full"
        />
      </div>
      <div class="mt-4 flex justify-between">
        <div>
          <h3 class="text-sm text-gray-700">
            <a href={@url}>
              <span aria-hidden="true" class="absolute inset-0"></span> <%= project.title %>
            </a>
          </h3>
          <p class="mt-1 text-sm text-gray-500"><%= project.description %></p>
        </div>
      </div>
    </div>
    """
  end
end
