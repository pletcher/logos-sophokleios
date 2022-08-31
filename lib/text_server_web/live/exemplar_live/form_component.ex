defmodule TextServerWeb.ExemplarLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Exemplars
  alias TextServer.Works

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:exemplar_file,
       accept: ~w(.docx .xml),
       max_entries: 1
     )
     |> assign(:exemplar_file_candidate, nil)
   	 |> assign(:works, [])}
  end

  @impl true
  def update(%{exemplar: exemplar} = assigns, socket) do
    changeset = Exemplars.change_exemplar(exemplar)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"exemplar" => exemplar_params} = _params, socket) do
    changeset =
      socket.assigns.exemplar
      |> Exemplars.change_exemplar(exemplar_params)
      |> Map.put(:action, :validate)

    entries = socket.assigns.uploads.exemplar_file.entries

    exemplar_file_candidate =
      if Enum.count(entries) > 0 do
        Enum.fetch!(entries, 0)
      else
        nil
      end

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:exemplar_file_candidate, exemplar_file_candidate)}
  end

  def handle_event("validate", _params, socket) do
  	{:noreply, socket}
  end

  def handle_event("search_works", %{"work_search" => search_string}, socket) do
  	page = Works.search_works(search_string)
  	works = page.entries
  	selected_work = Enum.find(works, fn w -> w.english_title == search_string end)

  	if is_nil(selected_work) do
	  	{:noreply, socket |> assign(:works, page.entries)}
	  else
	  	{:noreply, socket |> assign(:works, []) |> assign(:selected_work, selected_work)}
	  end
  end

  def handle_event("save", %{"exemplar" => exemplar_params}, socket) do
    file_params =
      consume_uploaded_entries(socket, :exemplar_file, fn %{path: path}, _entry ->
        dest =
          Path.join([
            :code.priv_dir(:text_server),
            "static",
            "uploads",
            "exemplar_files",
            Path.basename(path)
          ])

        file_body = File.read!(path)

        File.write!(file_body, dest)

        {:ok,
         %{
           filename: dest,
           filemd5hash: :crypto.hash(:md5, file_body) |> Base.encode16(case: :lower),
           source: "@@exemplar/user_upload",
           source_link: Routes.static_path(socket, "/uploads/exemplar_files/#{Path.basename(dest)}")
         }}
      end)
      |> List.first()

    unless is_nil(file_params) do
      save_exemplar(socket, socket.assigns.action, exemplar_params, file_params)
    else
      {:noreply, socket}
    end
  end

  defp save_exemplar(socket, :edit, exemplar_params, file_params) do
    case Exemplars.update_exemplar_with_file(
           socket.assigns.exemplar,
           exemplar_params,
           file_params
         ) do
      {:ok, _exemplar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exemplar updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_exemplar(socket, :new, exemplar_params, file_params) do
    case Exemplars.create_exemplar_with_file(exemplar_params, file_params) do
      {:ok, _exemplar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exemplar created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
