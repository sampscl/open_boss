defmodule OpenBossWeb.NetworkLive.Index do
  use OpenBossWeb, :live_view

  use Gettext, backend: OpenBossWeb.Gettext

  alias OpenBoss.Network
  alias OpenBoss.Network.Adapter

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    adapters = Network.list_adapters()

    if connected?(socket) do
      # This is effectively a no-op when platform == :host
      Enum.each(adapters, fn %{id: id} ->
        :ok = VintageNet.subscribe(["interface", id, "addresses"])
        :ok = VintageNet.subscribe(["interface", id, "connection"])
      end)
    end

    {
      :ok,
      socket
      |> assign(:adapters, adapters)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Adapter")
    |> assign(:adapter, Network.get_adapter!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Network Adapters")
    |> assign(:adapter, nil)
  end

  @impl true
  def handle_info({OpenBossWeb.NetworkLive.WifiFormComponent, {:saved, _adapter}}, socket) do
    {:noreply, assign(socket, :adapters, Network.list_adapters())}
  end

  @impl true
  def handle_info({VintageNet, ["interface", _interface, _prop], _old, _new, _metadata}, socket) do
    {:noreply, socket}
  end
end
