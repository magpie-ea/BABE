use Mix.Config

config :logger,
  level: :info

config :magpie, :environment, :prod

config :magpie, MagpieWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# We don't have a basic auth on the demo app, so we need to allow for this flexibility
# Deliberate compile-time variable
config :magpie,
       :no_basic_auth,
       (if System.get_env("MAGPIE_NO_BASIC_AUTH") == "true" do
          true
        else
          false
        end)
