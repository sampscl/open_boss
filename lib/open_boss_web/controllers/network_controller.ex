defmodule OpenBossWeb.NetworkController do
  @moduledoc """
  Network controller for endpoints
  """
  use OpenBossWeb, :controller

  alias OpenBoss.Network
  alias OpenBoss.System

  def reset_wifi(conn, _) do
    Network.list_adapters()
    |> Enum.each(fn
      %{id: id, configuration: %{"type" => VintageNetWiFi}} ->
        _ = Network.reset_to_defaults(id)

      _adapter ->
        :ok
    end)

    {:ok, _pid} = Task.start(&System.reboot/0)

    redirect(conn, to: ~p"/")
  end
end
