defmodule Mix.Tasks.OpenBoss.BuildSelfSignedKeys do
  @shortdoc "Build self-signed keys"

  @moduledoc """
  The OpenBoss build_self_signed_keys mix task; `mix help open_boss.build_self_signed_keys`
  """
  use Mix.Task

  alias X509.Certificate
  alias X509.Certificate.Extension
  alias X509.PrivateKey
  alias X509.PublicKey

  @doc false
  @impl Mix.Task
  def run(_) do
    root_ca_subject_rdn =
      with nil <- System.get_env("ROOT_CA_SUBJECT_RDN") do
        Mix.shell().error(
          "Using default Root Certificate Authority (CA) Relative Distinguished Name (RDN). You should set ROOT_CA_SUBJECT_RDN environment variable!"
        )

        "/C=US/ST=PA/L=Intercourse/O=PennaDutchTech/CN=PennaDutchTech Root CA"
      end

    subject_rdn =
      with nil <- System.get_env("SUBJECT_RDN") do
        Mix.shell().error(
          "Using default Subject Relative Distinguished Name (RDN). You should set SUBJECT_RDN environment variable!"
        )

        "/C=US/ST=PA/L=Intercourse/O=PennaDutchTech/CN=PennaDutchTech"
      end

    subject_an =
      with nil <- System.get_env("SUBJECT_AN") do
        Mix.shell().error(
          "Using default Subject Alternate Name (SAN). You should set SUBJECT_AN environment variable!"
        )

        "open-boss.local"
      end

    Mix.shell().info("Generating new CA key")
    ca_key = PrivateKey.new_ec(:secp256r1)

    Mix.shell().info("Generating new CA cert")

    ca_cert =
      Certificate.self_signed(
        ca_key,
        root_ca_subject_rdn,
        template: :root_ca
      )

    Mix.shell().info("Generating new server key")
    open_boss_key = PrivateKey.new_ec(:secp256r1)

    Mix.shell().info("Generating new server cert")

    open_boss_cert =
      open_boss_key
      |> PublicKey.derive()
      |> Certificate.new(
        subject_rdn,
        ca_cert,
        ca_key,
        extensions: [
          subject_alt_name: Extension.subject_alt_name([subject_an])
        ]
      )

    _ = File.rm("etc/ssl/private/ca_key.pem")
    _ = File.rm("etc/ssl/certs/ca_crt.pem")
    _ = File.rm("etc/ssl/private/open_boss_key.pem")
    _ = File.rm("etc/ssl/certs/open_boss_crt.pem")

    :ok = File.write!("etc/ssl/private/ca_key.pem", PrivateKey.to_pem(ca_key))
    :ok = File.chmod("etc/ssl/private/ca_key.pem", 0o0400)

    :ok = File.write!("etc/ssl/certs/ca_crt.pem", Certificate.to_pem(ca_cert))
    :ok = File.chmod("etc/ssl/certs/ca_crt.pem", 0o0440)

    :ok = File.write!("etc/ssl/private/open_boss_key.pem", PrivateKey.to_pem(open_boss_key))
    :ok = File.chmod("etc/ssl/private/open_boss_key.pem", 0o0400)

    :ok = File.write!("etc/ssl/certs/open_boss_crt.pem", Certificate.to_pem(open_boss_cert))
    :ok = File.chmod("etc/ssl/certs/open_boss_crt.pem", 0o0440)

    Mix.shell().info("Self-signed keys and certs saved")
  end
end
