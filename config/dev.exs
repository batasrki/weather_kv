use Mix.Config

config :weather_kv,
  darksky_url: "https://api.darksky.net/forecast",
  darksky_api_key: "561f731ec4fdff2c7858b8f91258183c",
  filepath: "db/dev/",
  filename: "weather_log.db"
