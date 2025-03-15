defmodule OpenBossWeb.NetworkLive.WifiFormComponent do
  @moduledoc """
  Wifi form. Performs the necessary tap-dance to insert wifi configuration
  into a network adapter.
  """
  use OpenBossWeb, :live_component

  alias OpenBoss.Network
  alias OpenBoss.Network.WifiConfiguration

  require Logger

  @impl true
  def update(%{adapter: %{configuration: configuration} = _adapter} = assigns, socket) do
    changeset = WifiConfiguration.changeset(configuration)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:wifi_configuration, configuration)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"wifi_configuration" => wifi_configuration}, socket) do
    changeset =
      socket.assigns.wifi_configuration
      |> WifiConfiguration.changeset(wifi_configuration)
      |> Map.put(:action, :validate)

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
