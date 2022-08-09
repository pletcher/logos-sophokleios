defmodule TextServerWeb.ProjectLive.UserSelectComponent do
  use TextServerWeb, :live_component

  def render(assigns) do
    ~H"""
    <section>
      <div class="flex justify-center">
        <div class="mb-3 xl:w-96">
          <label for="user-multiselect" class="form-label inline-block mb-2 text-gray-700 sr-only">
            Start entering an email address
          </label>
          <input
            type="text"
            class="
     	        form-control
     	        block
     	        w-full
     	        px-3
     	        py-1.5
     	        text-base
     	        font-normal
     	        text-gray-700
     	        bg-white bg-clip-padding
     	        border border-solid border-gray-300
     	        rounded
     	        transition
     	        ease-in-out
     	        m-0
     	        focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none
     	      "
            id="user-multiselect"
            placeholder="pylades@mycenae.polis"
          />
        </div>
      </div>
    </section>
    """
  end
end
