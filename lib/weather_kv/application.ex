defmodule WeatherKv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {WeatherKv.ForecastFetcher,
       [
         darksky_url: Application.get_env(:weather_kv, :darksky_url),
         darksky_api_key: Application.get_env(:weather_kv, :darksky_api_key)
       ]},
      {WeatherKv.Index,
       [
         filepath: Application.get_env(:weather_kv, :filepath),
         filename: Application.get_env(:weather_kv, :filename)
       ]}
      # {DynamicSupervisor, strategy: :one_for_one, name: WeatherKv.LogFileAppenderSupervisor}
      # Starts a worker by calling: WeatherKv.Worker.start_link(arg)
      # {WeatherKv.Worker, arg}
    ]

    children =
      if Mix.env() == :test do
        children
      else
        [
          {WeatherKv.LogFileAppender,
           [
             filepath: Application.get_env(:weather_kv, :filepath),
             filename: Application.get_env(:weather_kv, :filename)
           ]}
          | children
        ]
      end

    # IO.inspect(children)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherKv.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
