defmodule OpenBoss.ActiveCooks do
  @moduledoc """
  Active cooks -- cooks with no stop time and an
  assigned device
  """
  import Ecto.Query, warn: false
  alias OpenBoss.Repo

  alias OpenBoss.Cooks.Cook

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
end
