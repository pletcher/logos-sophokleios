defmodule TextServerWeb.ExemplarLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Exemplars
  alias TextServer.Languages

  alias TextServerWeb.Components
  alias TextServerWeb.Icons

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:exemplar_file,
       accept: ~w(.docx .xml),
       max_entries: 1
     )
     |> assign(exemplar_file_candidate: nil)}
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

  def handle_event(
        "save",
        %{"exemplar" => exemplar_params, "selected_work" => work_params},
        socket
      ) do
    file_params =
      consume_uploaded_entries(
        socket,
        :exemplar_file,
        fn %{path: path}, %{client_name: client_name} = _entry ->
          dest =
            Path.join([
              Application.get_env(:text_server, :user_uploads_directory),
              "exemplar_files",
              client_name
            ])

          file_body = File.read!(path)

          File.cp!(path, dest)

          {:ok,
           %{
             "filename" => dest,
             "filemd5hash" => :crypto.hash(:md5, file_body) |> Base.encode16(case: :lower),
             "source" => "@@exemplar/user_upload",
             "source_link" =>
               Routes.static_path(socket, "/uploads/exemplar_files/#{Path.basename(dest)}")
           }}
        end
      )
      |> List.first()

    unless is_nil(file_params) do
      save_exemplar(
        socket,
        socket.assigns.action,
        exemplar_params
        |> Map.merge(file_params)
        |> Map.put("work_id", Map.get(work_params, "work_id"))
      )
    else
      {:noreply, socket}
    end
  end

  defp save_exemplar(socket, :edit, exemplar_params) do
    case Exemplars.update_exemplar(
           socket.assigns.exemplar,
           exemplar_params
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

  defp save_exemplar(socket, :new, exemplar_params) do
    # see documentation for put_assoc/4 for why we're doing it this way
    language_slug = Map.get(exemplar_params, "language") |> Map.get("title")
    language = Languages.get_language_by_slug(language_slug)

    case Exemplars.create_exemplar(
           exemplar_params |> Map.put("language_id", language.id) |> Map.delete("language"),
           socket.assigns.project
         ) do
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
