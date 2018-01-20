# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :asitext, AsitextWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NJQBm3HhPWWhjNB07zPWKDuXsEAJn7f7g5Uk0jiADkqpLQGfB723F6DTs1JcfK2o",
  render_errors: [view: AsitextWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Asitext.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :asitext, :basic_auth, false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
