defmodule OpenBoss.Host.Network do
  @moduledoc """
  Host implementation
  """

  alias Ecto.Changeset
  alias OpenBoss.Network
  alias OpenBoss.Network.Adapter

  @behaviour Network

  @impl Network
  def list_adapters do
    {:ok, addrs} = :net.getifaddrs(:default)

    Enum.map(addrs, &convert!/1)
  end

  @impl Network
  def get_adapter!(interface) do
    {:ok, addrs} = :net.getifaddrs(:default)

    interface_clist = to_charlist(interface)

    match =
      Enum.reduce_while(addrs, nil, fn addr, acc ->
        if addr.name == interface_clist do
          {:halt, addr}
        else
          {:cont, acc}
        end
      end)

    convert!(match)
  end

  @impl Network
  def apply_configuration(_adapter) do
    {:error, "configuration changes not supported on host"}
  end

  @impl Network
  def needs_wifi_config?, do: false

  @impl Network
  def run_vintage_net_wizard(), do: raise("VintageNet not implmented on host platform")

  @impl Network
  def reset_to_defaults(_), do: raise("VintageNet not implmented on host platform")

  @spec convert!(:net.ifaddrs()) :: Adapter.t()
  defp convert!(%{name: name, addr: %{family: :inet, addr: addr}}) do
    addr = Tuple.to_list(addr) |> Enum.join(".")

    cs =
      Adapter.changeset(%Adapter{id: to_string(name)}, %{
        addr: addr,
        mutable: false,
        configuration: %{}
      })

    Changeset.apply_action!(cs, :change)
  end

  defp convert!(%{name: name, addr: %{family: :inet6, addr: addr}}) do
    addr = Tuple.to_list(addr) |> Enum.join(":")

    cs =
      Adapter.changeset(%Adapter{id: to_string(name)}, %{
        addr: addr,
        mutable: false,
        configuration: %{}
      })

    Changeset.apply_action!(cs, :change)
  end
end
