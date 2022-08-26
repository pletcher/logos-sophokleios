defmodule TextServerWeb.ExemplarLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Exemplars

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:exemplar_file,
       accept: ~w(.docx .xml),
       external: &presign_upload/2,
       max_entries: 1
     )
     |> assign(:exemplar_file_candidate, nil)}
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

  def handle_event("save", %{"exemplar" => exemplar_params}, socket) do
    save_exemplar(socket, socket.assigns.action, exemplar_params)
  end

  defp save_exemplar(socket, :edit, exemplar_params) do
    case Exemplars.update_exemplar(socket.assigns.exemplar, exemplar_params) do
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
    case Exemplars.create_exemplar(exemplar_params) do
      {:ok, _exemplar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exemplar created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = "ktemata"
    key = "pausanias/exemplars/#{entry.client_name}"

    config = %{
      region: "nyc3",
      access_key_id: System.fetch_env!("S3_ACCESS_KEY"),
      secret_access_key: System.fetch_env!("S3_SECRET_KEY")
    }

    {:ok, fields} =
      Vendor.SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads[entry.upload_config].max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: key, url: "https://ktemata.nyc3.digitaloceanspaces.com", fields: fields}
    {:ok, meta, socket}
  end
end
