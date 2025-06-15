defmodule OpenBoss.Target.Network do
  @moduledoc """
  Target implementation
  """
  alias OpenBoss.Network
  alias OpenBoss.Network.Adapter

  @behaviour Network

  require Logger

  @props [
    ["config"],
    ["connection"],
    ["state"],
    ["type"],
    ["addresses"],
    ["wifi", "access_points"],
    ["wifi", "current_ap"]
  ]

  @empty_adapter %{
    "config" => nil,
    "connection" => nil,
    "state" => nil,
    "type" => nil,
    "addresses" => nil,
    "wifi" => %{
      "access_points" => nil,
      "current_ap" => nil
    }
  }

  @impl Network
  def list_adapters do
    (VintageNet.configured_interfaces() -- ["lo"]) |> Enum.map(&get_adapter!/1)
  end

  @impl Network
  def get_adapter!(interface) do
    config =
      VintageNet.get_by_prefix(["interface", interface])
      |> Enum.reduce(@empty_adapter, fn
        {["interface", ^interface | prop], value}, acc when prop in @props ->
          Logger.debug(inspect({acc, prop, value}, pretty: true, limit: :infinity),
            limit: :infinity
          )

          put_in(acc, prop, value)

        _, acc ->
          acc
      end)

    changeset_from_config(%Adapter{id: interface, mutable: true}, config)
    |> Ecto.Changeset.apply_action!(:get_adapter!)
  end

  @impl Network
  def apply_configuration(_) do
    {:error, "Apply configuration not supported on the host"}
  end

  @impl Network
  def run_vintage_net_wizard do
    VintageNetWizard.run_wizard()
  end

  @spec changeset_from_config(Adapter.t(), map()) :: Ecto.Changeset.t()
  defp changeset_from_config(adapter, config) do
    Adapter.changeset(adapter, %{
      mutable: true,
      configuration: config
    })
  end
end
