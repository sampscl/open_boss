defmodule OpenBossWeb.DisplayLive.Show do
  use OpenBossWeb, :live_view

  alias OpenBoss.Displays

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:display, Displays.get_display!(id))}
  end

  defp page_title(:show), do: "Show Display"
  defp page_title(:edit), do: "Edit Display"
end
