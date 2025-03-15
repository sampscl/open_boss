defmodule OpenBoss.TestNetwork do
  @moduledoc """
  Implementation of the network behavior for testing
  """
  alias OpenBoss.Network

  @behaviour Network

  @impl Network
  def list_adapters do
    []
  end

  @impl Network
  def get_adapter!(_device) do
    raise "no such adapter"
  end

  @impl Network
  def apply_configuration(_adapter) do
    :ok
  end
end
