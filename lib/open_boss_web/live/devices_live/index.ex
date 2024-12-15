defmodule OpenBossWeb.DevicesLive.Index do
  use OpenBossWeb, :live_view

  alias OpenBoss.Devices

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = Phoenix.PubSub.subscribe(OpenBoss.PubSub, "device-presence")
    end

    {
      :ok,
      socket
      |> stream(:devices, Devices.list())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    device_id = String.to_integer(id)

    case Devices.device_state(device_id) do
      {:ok, device_state} ->
        socket
        |> assign(:page_title, "Configure Device")
        |> assign(:device, device_state)

      {:error, :not_found} ->
        raise OpenBossWeb.DevicesLive.DeviceIdNotFoundError
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Devices")
    |> assign(:device, nil)
  end

  @impl true
  def handle_info({OpenBossWeb.DevicesLive.FormComponent, {:saved, device}}, socket) do
    {:noreply, stream_insert(socket, :devices, device)}
  end

  @impl true
  def handle_info({:worker_start, device_state}, socket) do
    {:noreply,
     stream_insert(
       socket,
       :devices,
       device_state
     )}
  end

  @impl true
  def handle_info({:worker_lost, device_state}, socket) do
    {:noreply,
     stream_delete(
       socket,
       :devices,
       device_state
     )}
  end
end
