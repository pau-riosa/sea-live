# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sea_live_world,
  ecto_repos: [SeaLiveWorld.Repo]

# Configures the endpoint
config :sea_live_world, SeaLiveWorldWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c9qrBWCXoh0fWJitOEX+4vzh8l4XqpdSksU3cLCO23j02MwMV/WbupjhhQVNrCcC",
  render_errors: [view: SeaLiveWorldWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SeaLiveWorld.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "lTBUSp8rWmmcAQ/KrMfMCRFqcBw2bbiI"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
