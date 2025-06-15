defmodule OpenBoss.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  alias OpenBoss.Boot
  alias OpenBoss.Network

  @impl true
  def start(_type, _args) do
    Logger.info("Starting")

    if Network.needs_wifi_config?() do
      Logger.warning("WiFi configuation needed")
      Network.run_vintage_net_wizard()
    else
      if :debug == Logger.level() do
        Logger.debug("Turning down the log level in noisy deps")
        OpenBoss.Utils.quiet_noisy_deps()
      end

      # Ensure database directory exists so the migrator
      # can create the database (if needed) and migrate it
      dbdir =
        Application.fetch_env!(:open_boss, OpenBoss.Repo)
        |> Keyword.fetch!(:database)
        |> Path.dirname()

      if File.exists?(dbdir) do
        Logger.debug("Database directory exists: #{dbdir}")
      else
        Logger.info("Creating database directory: #{dbdir}")
        File.mkdir_p!(dbdir)
      end

      children =
        [
          {Ecto.Migrator, repos: Application.fetch_env!(:open_boss, :ecto_repos)},
          OpenBossWeb.Telemetry,
          OpenBoss.Repo,
          {Phoenix.PubSub, name: OpenBoss.PubSub},
          # Start a worker by calling: OpenBoss.Worker.start_link(arg)
          # {OpenBoss.Worker, arg},
          {Task.Supervisor, name: OpenBoss.TaskSupervisor},
          {OpenBoss.Devices.Manager, []},
          {OpenBoss.Discovery, []},
          # Start to serve requests, typically the last entry
          OpenBossWeb.Endpoint
        ] ++ children(target())

      # See https://hexdocs.pm/elixir/Supervisor.html
      # for other strategies and supported options
      opts = [strategy: :one_for_one, name: OpenBoss.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OpenBossWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @spec children(atom()) :: list()
  defp children(:host) do
    [
      # Children that only run on the host
    ]
  end

  defp children(:rpi4_kiosk) do
    [
      {OpenBoss.Rpi4Kiosk.Display.Supervisor, []},
      {Boot, :reconcile_displays}
    ]
  end

  defp children(_) do
    [
      # Children for remaining targets
    ]
  end

  @spec target :: atom()
  defp target, do: Application.get_env(:open_boss, :target)
end
