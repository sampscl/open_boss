defmodule OpenBoss.Devices.Device do
  @moduledoc """
  Schema for devices table
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @required_fields [:id]
  @fields @required_fields ++
            [
              :ip,
              :port,
              :requested_temp,
              :set_temp,
              :temps,
              :blower,
              :protocol_version,
              :hw_id,
              :device_id,
              :uid,
              :pin,
              :disabled,
              :min_temp,
              :max_temp,
              :ntp_host,
              :app_version,
              :boot_version,
              :bt_version,
              :hw_id_version,
              :next_addr_version,
              :pos_version,
              :revert_avail_version,
              :wifi_version
            ]

  schema "devices" do
    field(:ip, :string)
    field(:port, :integer)
    field(:requested_temp, :float)
    field(:set_temp, :float)
    field(:temps, :map)
    field(:blower, :float)
    field(:protocol_version, :integer)
    field(:hw_id, :integer)
    field(:device_id, :integer)
    field(:uid, :binary)
    field(:pin, :integer)
    field(:disabled, :boolean)
    field(:min_temp, :float)
    field(:max_temp, :float)
    field(:ntp_host, :string)
    field(:app_version, :string)
    field(:boot_version, :string)
    field(:bt_version, :string)
    field(:hw_id_version, :integer)
    field(:next_addr_version, :integer)
    field(:pos_version, :integer)
    field(:revert_avail_version, :boolean)
    field(:wifi_version, :string)
    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = device, params) do
    device
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:id)
  end
end
