defmodule OpenBoss.Devices do
  @moduledoc """
  API for devices
  """

  alias OpenBoss.Devices.Device
  alias OpenBoss.Devices.Manager

  @type id() :: non_neg_integer()

  case Application.compile_env!(:open_boss, __MODULE__) |> Keyword.fetch!(:list) do
    :live ->
      @doc """
      Get a list of all active devices
      """
      @spec list() :: list(Device.t())
      defdelegate list, to: Manager

      @doc """
      Get stored state of a given device
      """
      @spec device_state(device_id :: non_neg_integer()) ::
              {:ok, Device.t()} | {:error, :not_found}
      defdelegate device_state(device_id), to: Manager

    :all ->
      @doc """
      Get a list of all devices, active and inactive
      """
      @spec list() :: list(Device.t())
      def list, do: list_all()

      @doc """
      Get most current state of a given device
      """
      @spec device_state(device_id :: non_neg_integer()) ::
              {:ok, Device.t()} | {:error, :not_found}
      def device_state(device_id) do
        case OpenBoss.Repo.get(Device, device_id) do
          nil -> {:error, :not_found}
          device -> {:ok, device}
        end
      end
  end

  @doc """
  List all devices, online or offline
  """
  @spec list_all() :: list(Device.t())
  def list_all, do: OpenBoss.Repo.all(Device)

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
