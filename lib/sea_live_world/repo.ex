defmodule SeaLiveWorld.Repo do
  use Ecto.Repo,
    otp_app: :sea_live_world,
    adapter: Ecto.Adapters.Postgres
end
