defmodule OpenBossWeb.ActiveCookLive.Home do
  use OpenBossWeb, :live_view

  alias OpenBoss.ActiveCooks

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
end
