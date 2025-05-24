defmodule OpenBoss.Target.Network do
  @moduledoc """
  Target implementation
  """
  alias OpenBoss.Network
  alias OpenBoss.Network.Adapter

  require Logger

  @behaviour Network

  @props [
    ["config"],
    ["connection"],
    ["state"],
    ["type"],
    ["addresses"],
    ["wifi", "access_points"],
    ["wifi", "current_ap"]
  ]

  @impl Network
  def list_adapters do
    (VintageNet.configured_interfaces() -- ["lo"]) |> Enum.map(&get_adapter!/1)
  end

  @impl Network
  def get_adapter!(interface) do
    config =
      VintageNet.get_by_prefix(["interface", interface])
      |> Enum.reduce(%{}, fn
        {["interface", ^interface | prop], value}, acc when prop in @props ->
          put_in(acc, prop, value)

        _, acc ->
          acc
      end)

    changeset_from_config(%Adapter{id: interface, mutable: true}, config)
    |> Ecto.Changeset.apply_action!(:get_adapter!)
  end

  @impl Network
  def apply_configuration(_) do
    raise("Not implemented")
  end

  @spec changeset_from_config(Adapter.t(), map()) :: Ecto.Changeset.t()
  defp changeset_from_config(adapter, config) do
    Adapter.changeset(adapter, %{
      mutable: true,
      configuration: config
    })
  end
end
