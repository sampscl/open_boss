defmodule Mix.Tasks.OpenBoss.BuildCompose do
  @moduledoc """
  The OpenBoss build_compose mix task; `mix help open_boss.build_compose`
  """
  use Mix.Task

  @shortdoc "Create a docker-compose.yml"
  def run(_) do
    :ok =
      File.write!("etc/docker/compose/open_boss/docker-compose.yml", """
      services:
        open_boss:
          image: open_boss
          # host network mode needed for mDNS to work properly
          network_mode: host
          environment:
            - SECRET_KEY_BASE="#{:crypto.strong_rand_bytes(64) |> Base.encode64(padding: false) |> binary_part(0, 64)}"
            - PHX_HOST=#{System.get_env("PHX_HOST") || "open-boss.local"}
            - PORT=443
            - KEYFILE=/run/secrets/server_key
            - CERTFILE=/run/secrets/server_cert
          volumes:
            - open_boss_database:/var/lib/open_boss
          secrets:
            - source: server_cert
            - source: server_key
      secrets:
        server_cert:
          file: /etc/ssl/certs/open_boss_crt.pem
        server_key:
          file: /etc/ssl/private/open_boss_key.pem
      volumes:
        open_boss_database:
      """)

    Mix.shell().info("Generated docker-compose.yml")
  end
end
