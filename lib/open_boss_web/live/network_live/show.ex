defmodule OpenBossWeb.NetworkLive.Show do
  use OpenBossWeb, :live_view

  use Gettext, backend: OpenBossWeb.Gettext

  alias OpenBoss.Network

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:adapter, Network.get_adapter!(id))
    }
  end

  defp page_title(:show), do: "Show Network Adapter"
  defp page_title(:edit), do: "Edit Network Adapter"
end
