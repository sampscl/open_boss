defmodule OpenBossWeb.CookLive.Show do
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
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cook, Cooks.get_cook!(id))}
  end

  defp page_title(:show), do: "Show Cook"
  defp page_title(:edit), do: "Edit Cook"
end
