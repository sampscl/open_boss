defmodule OpenBoss.Devices do
  @moduledoc """
  API for devices
  """

  alias OpenBoss.Devices.Manager

  @type init_param() :: %{
          ip: :inet.socket_address(),
          services: list(String.t()),
          domain: String.t()
        }

  @type id() :: non_neg_integer()

  @type temps() ::
          %{
            pit_1: float() | nil,
            meat_1: float() | nil,
            pit_2: float() | nil,
            meat_2: float() | nil
          }
          | nil

  @type protocol() ::
          %{
            version: non_neg_integer()
          }
          | nil

  @type id_message() ::
          %{
            hw_id: non_neg_integer(),
            device_id: non_neg_integer(),
            uid: {:ok, binary()} | :error,
            pin: non_neg_integer(),
            disabled: boolean()
          }
          | nil

  @type set_temp_limits() ::
          %{
            min: float(),
            max: float()
          }
          | nil

  @type ntp() ::
          %{
            host: String.t()
          }
          | nil

  @type versions() ::
          %{
            app: String.t(),
            boot: String.t(),
            bt: String.t(),
            hw_id: non_neg_integer(),
            next_addr: non_neg_integer(),
            pos: non_neg_integer(),
            revert_avail: any(),
            wifi: String.t()
          }
          | nil

  @type device_state() :: %{
          ip: :inet.socket_address(),
          port: pos_integer(),
          services: list(String.t()),
          domain: String.t(),
          device_id: non_neg_integer(),
          client_id: String.t() | nil,
          mqtt_pid: pid() | nil,
          requested_temp: float() | nil,
          set_temp: float() | nil,
          temps: temps(),
          blower: float() | nil,
          protocol: protocol(),
          id_message: id_message(),
          set_temp_limits: set_temp_limits(),
          ntp: ntp(),
          versions: versions(),
          last_update: DateTime.t() | nil
        }

  @spec list() :: list(device_state())
  defdelegate list, to: Manager

  @spec device_state(device_id :: non_neg_integer()) ::
          {:ok, device_state()} | {:error, :not_found}
  defdelegate device_state(device_id), to: Manager

  @spec set_temp(
          device_id :: non_neg_integer(),
          temp :: float(),
          unit :: :farenheit | :celsius
        ) ::
          :ok | {:error, :not_found} | {:error, any()}
  defdelegate set_temp(device_id, temp, unit), to: Manager
end
