defmodule OpenBoss.Devices do
  @moduledoc """
  API for devices
  """

  alias OpenBoss.Devices.Device
  alias OpenBoss.Devices.Manager
  alias OpenBoss.Repo

  @type id() :: non_neg_integer()

  @doc """
  Get a list of all active devices
  """
  @spec list() :: list(Device.t())
  defdelegate list, to: Manager

  @doc """
  Get a list of all devices, active and inactive
  """
  @spec list_all() :: list(Device.t())
  def list_all, do: Repo.all(Device)

  @spec device_state(device_id :: non_neg_integer()) ::
          {:ok, Device.t()} | {:error, :not_found}
  defdelegate device_state(device_id), to: Manager

  @doc """
  Set device desired temp. The device must be online.
  """
  @spec set_temp(
          device_id :: non_neg_integer(),
          temp :: float(),
          unit :: :farenheit | :celsius
        ) ::
          :ok | {:error, :not_found} | {:error, any()}
  defdelegate set_temp(device_id, temp, unit), to: Manager
end
