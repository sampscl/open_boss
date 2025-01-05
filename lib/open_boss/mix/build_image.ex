defmodule Mix.Tasks.OpenBoss.BuildImage do
  @moduledoc """
  The OpenBoss deploy mix task; `mix help open_boss.deploy`
  """
  use Mix.Task

  @shortdoc "Build a docker image"
  def run(_) do
    {_result, 0} =
      System.cmd("docker", [
        "buildx",
        "build",
        # "--platform",
        # "linux/amd64,linux/arm64",
        ".",
        "--tag",
        "open_boss:latest"
      ])

    Mix.shell().info("Generated docker image")
  end
end
