defmodule OpenBossWeb.NetworkController do
  @moduledoc """
  Network controller for endpoints
  """
  use OpenBossWeb, :controller

  alias OpenBoss.Network
  alias OpenBoss.System

  require Logger

  def reset_wifi(conn, _) do
    Logger.warning("Resetting WiFi")

    Network.list_adapters()
    |> Enum.each(fn
      %{id: id, configuration: %{"type" => VintageNetWiFi}} ->
        _ = Network.reset_to_defaults(id)

      _adapter ->
        :ok
    end)

    {:ok, _pid} =
      Task.start(fn ->
        Logger.warning("Rebooting")
        Process.sleep(1_000)
        System.reboot()
      end)

    redirect(conn, to: ~p"/")
  end
end
