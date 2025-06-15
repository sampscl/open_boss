defmodule OpenBoss.Network do
  @moduledoc """
  Network context.
  """

  alias Ecto.Changeset
  alias OpenBoss.Network.Adapter

  @callback list_adapters() :: list(Adapter.t())
  @callback get_adapter!(String.t()) :: Adapter.t()
  @callback apply_configuration(Adapter.t()) ::
              :ok | {:error, any()}
  @callback needs_wifi_config?() :: boolean()
  @callback run_vintage_net_wizard() :: Supervisor.on_start()
  @callback reset_to_defaults(String.t()) :: :ok

  defdelegate list_adapters,
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  defdelegate get_adapter!(interface),
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  defdelegate apply_configuration(adapter),
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  defdelegate change_adapter(adapter, params \\ %{}), to: Adapter, as: :changeset

  defdelegate needs_wifi_config?,
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  defdelegate run_vintage_net_wizard,
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  defdelegate reset_to_defaults(interface),
    to: Application.compile_env!(:open_boss, [__MODULE__, :implementation])

  @spec update_adapter(Adapter.t(), map()) ::
          {:ok, Adapter.t()} | {:error, Changeset.t()}
  def update_adapter(adapter, params) do
    with %{valid?: true} = cs <- change_adapter(adapter, params),
         {:ok, adapter} <- Ecto.Changeset.apply_action(cs, :update) do
      apply_configuration(adapter)
    end
  end

  @spec hostname() :: String.t()
  def hostname do
    {:ok, host} = :inet.gethostname()
    to_string(host) <> ".local"
  end
end
