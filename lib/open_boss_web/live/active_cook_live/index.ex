defmodule OpenBossWeb.ActiveCookLive.Index do
  use OpenBossWeb, :live_view

  alias OpenBoss.ActiveCooks
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("mount")
    {:ok, stream(socket, :active_cooks, ActiveCooks.list_active_cooks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    Logger.info("handle_params: #{inspect(params)}")
    {:noreply, socket}
  end
end
