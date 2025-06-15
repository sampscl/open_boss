defmodule OpenBossWeb.NetworkLive.NetworkEditComponent do
  @moduledoc """
  Edit a network adapter
  """
  use OpenBossWeb, :live_component

  alias OpenBoss.Network

  @impl true
  def update(%{adapter: adapter} = assigns, socket) do
    changeset = Network.change_adapter(adapter)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"adapter" => adapter_params}, socket) do
    changeset = Network.change_adapter(socket.assigns.adapter, adapter_params)
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"wifi_configuration" => wifi_configuration}, socket) do
    save_adapter(socket, socket.assigns.action, wifi_configuration)
  end

  defp save_adapter(socket, :edit, wifi_configuration) do
    case Network.update_adapter(socket.assigns.adapter, %{configuration: wifi_configuration}) do
      {:ok, adapter} ->
        notify_parent({:saved, adapter})

        {:noreply,
         socket
         |> put_flash(:info, "WiFi settings updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
