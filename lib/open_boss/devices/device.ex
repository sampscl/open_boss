defmodule OpenBoss.Devices.Device do
  @moduledoc """
  Schema for devices table
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OpenBoss.Devices.Temps

  @type t() :: %__MODULE__{}

  @required_fields [:id, :last_communication]
  @fields @required_fields ++
            [
              :ip,
              :port,
              :requested_temp,
              :set_temp,
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
              :wifi_version,
              :name
            ]

  @primary_key {:id, :integer, autogenerate: false}

  schema "devices" do
    field(:ip, :string)
    field(:port, :integer)
    field(:requested_temp, :float)
    field(:set_temp, :float)
    embeds_one(:temps, Temps, on_replace: :update)
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
    field(:name, :string)
    field(:last_communication, :utc_datetime_usec)
    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = device, params) do
    device
    |> cast(params, @fields)
    |> cast_embed(:temps)
    |> validate_required(@required_fields)
    |> unique_constraint(:id)
    |> validate_temp(device, :set_temp)
  end

  @spec get_name(t()) :: String.t()
  def get_name(device), do: "#{device.name || device.id}"

  @spec validate_temp(Ecto.Changeset.t(t()), t(), atom()) :: Ecto.Changeset.t(t())
  def validate_temp(cs, %{min_temp: min, max_temp: max}, field)
      when not is_nil(min) and not is_nil(max) do
    cs
    |> validate_number(field, greater_than_or_equal_to: min)
    |> validate_number(field, less_than_or_equal_to: max)
  end

  def validate_temp(cs, _, _), do: cs
end
