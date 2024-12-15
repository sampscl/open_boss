defmodule OpenBossWeb.DevicesLive.Show do
  use OpenBossWeb, :live_view

  require Logger

  alias OpenBoss.Devices

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      :ok = Phoenix.PubSub.subscribe(OpenBoss.PubSub, "device-state-#{id}")
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    device_id = String.to_integer(id)

    case Devices.device_state(device_id) do
      {:ok, device_state} ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:device, device_state)}

      {:error, :not_found} ->
        raise OpenBossWeb.DevicesLive.DeviceIdNotFoundError
    end
  end

  @impl true
  def handle_info({:device_state, state}, socket) do
    {:noreply, assign(socket, :device, state)}
  end

  @impl true
  def handle_info({OpenBossWeb.DevicesLive.FormComponent, {:saved, device}}, socket) do
    {:noreply, assign(socket, :device, device)}
  end

  defp page_title(:show), do: "Device"
  defp page_title(:edit), do: "Configure Device"
end
