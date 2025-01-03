defmodule OpenBoss.ActiveCooks do
  @moduledoc """
  Active cooks -- cooks with no stop time and an
  assigned device
  """
  import Ecto.Query, warn: false
  alias OpenBoss.Repo

  alias OpenBoss.Cooks.Cook
  alias OpenBoss.Cooks.CookHistory
  alias OpenBoss.Devices.Device

  @doc """
  Get the active cook for the given device
  """
  @spec get_active_cook(integer(), DateTime.t()) :: nil | Cook.t()
  def get_active_cook(device_id, at_time) do
    Repo.one(
      from(c in Cook,
        where: c.device_id == ^device_id,
        where: c.start_time <= ^at_time,
        where: is_nil(c.stop_time) or c.stop_time >= ^at_time,
        preload: :device
      )
    )
  end

  @doc """
  Returns the list of active cooks

  ## Examples

    iex> list_cooks()
    [%Cook{}, ...]
  """
  @spec list_active_cooks() :: list(Cook.t())
  def list_active_cooks do
    from(c in Cook,
      where: is_nil(c.stop_time),
      where: not is_nil(c.device_id),
      preload: :device
    )
    |> Repo.all()
  end

  @doc """
  If device has a cook for the device.last_communication,
  update the cook history for that cook with a snapshot of
  the device.

  This will update cooks that are no longer active.
  """
  @spec maybe_add_cook_history(Device.t()) :: {:ok, any()} | {:error, any()}
  def maybe_add_cook_history(device) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:cook, fn repo, _ ->
      from(c in Cook,
        where: c.device_id == ^device.id,
        where: c.start_time <= ^device.last_communication,
        where: is_nil(c.stop_time) or c.stop_time >= ^device.last_communication
      )
      |> repo.one()
      |> case do
        nil -> {:error, :no_cook}
        cook -> {:ok, cook}
      end
    end)
    |> Ecto.Multi.insert(:cook_history, fn %{cook: cook} ->
      device_state =
        Map.from_struct(device)
        |> Map.take([:set_temp, :temps, :blower])

      CookHistory.changeset(%CookHistory{}, %{
        cook_id: cook.id,
        timestamp: device.last_communication,
        device_state: device_state
      })
    end)
    |> Repo.transaction()
  end
end
