# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :vikiparty,
  ecto_repos: [Vikiparty.Repo]

# Configures the endpoint
config :vikiparty, VikipartyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "laOcVc1cqpyXnuB1OVbx/ahCW1N3tHaFfe6pXZZ/BSBrfjHYJ8LL5ggcySAjPsHI",
  render_errors: [view: VikipartyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Vikiparty.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "zYla8La1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
