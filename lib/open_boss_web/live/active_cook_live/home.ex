defmodule OpenBossWeb.ActiveCookLive.Home do
  use OpenBossWeb, :live_view

  alias OpenBoss.ActiveCooks
  alias OpenBoss.Cooks

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, :timezone, nil)
     |> stream(:active_cooks, [])}
  end

  @impl true
  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    {:noreply,
     assign(socket, :timezone, timezone)
     |> stream(:active_cooks, ActiveCooks.list_active_cooks())}
  end

  @impl true
  def handle_event("finish", %{"id" => id}, socket) do
    cook = Cooks.get_cook!(id)
    {:ok, _} = Cooks.update_cook(cook, %{stop_time: DateTime.utc_now()})

    {:noreply, stream_delete(socket, :active_cooks, cook)}
  end
end
