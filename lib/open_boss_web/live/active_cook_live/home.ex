defmodule OpenBossWeb.ActiveCookLive.Home do
  use OpenBossWeb, :live_view

  alias OpenBoss.ActiveCooks
  alias OpenBoss.Cooks
  alias OpenBoss.Topics

  @impl true
  def mount(_params, _session, socket) do
    peer_data = get_connect_info(socket, :peer_data)
    localhost_request? = OpenBossWeb.localhost_request?(peer_data)

    if connected?(socket) do
      :ok = Phoenix.PubSub.subscribe(OpenBoss.PubSub, Topics.active_cook_update())
    end

    {:ok,
     assign(socket, :timezone, nil)
     |> assign(:active_cooks, [])
     |> assign(:localhost_request?, localhost_request?)}
  end

  @impl true
  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    {:noreply, assign(socket, :timezone, timezone) |> assign_active_cooks()}
  end

  @impl true
  def handle_event("finish", %{"id" => id}, socket) do
    cook = Cooks.get_cook!(id)
    {:ok, _} = Cooks.update_cook(cook, %{stop_time: DateTime.utc_now()})

    {:noreply, assign_active_cooks(socket)}
  end

  @impl true
  def handle_info({:active_cook, _cook}, socket) do
    {:noreply, assign_active_cooks(socket)}
  end

  @spec assign_active_cooks(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  defp assign_active_cooks(socket) do
    assign(
      socket,
      :active_cooks,
      Enum.sort(ActiveCooks.list_active_cooks(), fn a, b ->
        DateTime.after?(a.start_time, b.start_time)
      end)
      |> Enum.map(&{&1.id, &1})
    )
  end
end
