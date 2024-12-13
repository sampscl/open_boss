defmodule OpenBoss.Repo do
  use Ecto.Repo,
    otp_app: :open_boss,
    adapter: Ecto.Adapters.SQLite3
end
