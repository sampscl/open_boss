defmodule Mix.Tasks.OpenBoss.BuildImage do
  @moduledoc """
  The OpenBoss deploy mix task; `mix help open_boss.deploy`
  """
  use Mix.Task

  @shortdoc "Build a docker image"
  def run(_) do
    {_result, 0} = System.cmd("npm", ["install"], cd: "assets")

    build_result =
      case System.get_env("PLAFORMS", nil) do
        nil ->
          System.cmd("docker", [
            "buildx",
            "build",
            ".",
            "--output",
            "type=docker"
            "--tag",
            "open_boss:latest"
          ])

        platforms ->
          System.cmd("docker", [
            "buildx",
            "build",
            "--platform",
            platforms,
            ".",
            "--output",
            "type=docker"
            "--tag",
            "open_boss:latest"
          ])
      end

    case build_result do
      {_result, 0} ->
        Mix.shell().info("Generated docker image")

      {result, status} ->
        Mix.shell().info("Failed to build docker image. Error #{status}, result: " <> result)
    end
  end
end
