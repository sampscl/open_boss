defmodule OpenBossWeb.DevicesLive.Show do
  use OpenBossWeb, :live_view

  require Logger

  alias OpenBoss.Devices
  alias OpenBoss.Topics

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    device_id = String.to_integer(id)

    case Devices.device_state(device_id) do
      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Device #{device_id} not active")
         |> push_navigate(to: ~p"/devices")}

      {:ok, _device} ->
        if connected?(socket) do
          _ = send(self(), :staleness_check)

          :ok = Phoenix.PubSub.subscribe(OpenBoss.PubSub, Topics.device_state(device_id))
        end

        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    device_id = String.to_integer(id)

    case Devices.device_state(device_id) do
      {:ok, device_state} ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:relative_time_string, "")
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

  @impl true
  def handle_info(:staleness_check, socket) do
    _ = Process.send_after(self(), :staleness_check, :timer.seconds(15))

    {
      :noreply,
      assign(socket, :relative_time_string, Timex.from_now(socket.assigns.device.updated_at))
    }
  end

  defp page_title(:show), do: "Device"
  defp page_title(:edit), do: "Configure Device"
end
