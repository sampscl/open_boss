defmodule OpenBoss.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting")

    if :debug == Logger.level() do
      Logger.debug("Turning down the log level in noisy deps")
      Logger.put_application_level(:mdns, :info)
      Logger.put_application_level(:emqtt, :info)
    end

    dbpath =
      Application.fetch_env!(:open_boss, OpenBoss.Repo)
      |> Keyword.fetch!(:database)
      |> Path.dirname()

    if File.exists?(dbpath) do
      Logger.debug("Database directory: #{dbpath}")
    else
      raise "database path does not exist: #{dbpath}"
    end

    children = [
      {Ecto.Migrator, repos: Application.fetch_env!(:open_boss, :ecto_repos)},
      OpenBossWeb.Telemetry,
      OpenBoss.Repo,
      {DNSCluster, query: Application.get_env(:open_boss, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OpenBoss.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: OpenBoss.Finch},
      # Start a worker by calling: OpenBoss.Worker.start_link(arg)
      # {OpenBoss.Worker, arg},
      {Task.Supervisor, name: OpenBoss.TaskSupervisor},
      {OpenBoss.Devices.Manager, []},
      {OpenBoss.Discovery, []},
      # Start to serve requests, typically the last entry
      OpenBossWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OpenBoss.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OpenBossWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
