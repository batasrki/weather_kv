use Mix.Config

config :weather_kv,
  darksky_url: "http://localhost:8081/forecast",
  darksky_api_key: "123456",
  filepath: "db/test/",
  filename: "weather_log.db"
