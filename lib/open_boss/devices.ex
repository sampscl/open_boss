defmodule OpenBoss.Devices do
  @moduledoc """
  API for devices
  """

  alias OpenBoss.Devices.Device
  alias OpenBoss.Devices.Manager

  @typedoc """
  id type for devices
  """
  @type id() :: non_neg_integer()

  @doc """
  Get a list of all devices, active and inactive
  """
  @spec list() :: list(Device.t())
  def list, do: OpenBoss.Repo.all(Device)

  @doc """
  Get most current state of a given device
  """
  @spec device_state(device_id :: non_neg_integer()) ::
          {:ok, Device.t()} | {:error, :not_found}
  def device_state(device_id) do
    with {:error, :not_found} <- Manager.device_state(device_id),
         device <- OpenBoss.Repo.get(Device, device_id) do
      if device, do: {:ok, device}, else: {:error, :not_found}
    end
  end

  @doc """
  Set device desired temp. The device must be online.
  """
  @spec set_temp(
          device_id :: id(),
          temp :: float(),
          unit :: :farenheit | :celsius
        ) ::
          :ok | {:error, :not_found} | {:error, any()}
  defdelegate set_temp(device_id, temp, unit), to: Manager
end
