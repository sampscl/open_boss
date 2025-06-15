defmodule OpenBossWeb.NetworkController do
  @moduledoc """
  Network controller for endpoints
  """
  use OpenBossWeb, :controller

  alias OpenBoss.Network
  alias OpenBoss.System

  require Logger

  def reset_wifi(conn, _) do
    :ok = Network.put_needs_wifi_config(true)

    {:ok, _pid} =
      Task.start(fn ->
        Logger.warning("Rebooting for WiFi config")
        Process.sleep(1_000)
        System.reboot()
      end)

    redirect(conn, to: ~p"/")
  end
end
