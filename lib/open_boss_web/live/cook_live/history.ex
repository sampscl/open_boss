defmodule OpenBossWeb.CookLive.History do
  use OpenBossWeb, :live_view

  alias OpenBoss.Cooks
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :timezone, nil)}
  end

  @impl true
  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    {:noreply, assign(socket, :timezone, timezone)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Cook History")
     |> assign(:cook, Cooks.get_cook!(id))
     |> assign(:cook_history, Cooks.get_cook_history_for_id(id))}
  end
end
