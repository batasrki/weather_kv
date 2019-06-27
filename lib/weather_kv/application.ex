defmodule WeatherKv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {WeatherKv.ForecastFetcher, []},
      {WeatherKv.Index, "weather_log.db"}
      # {DynamicSupervisor, strategy: :one_for_one, name: WeatherKv.LogFileAppenderSupervisor}
      # Starts a worker by calling: WeatherKv.Worker.start_link(arg)
      # {WeatherKv.Worker, arg}
    ]

    children =
      cond do
        Mix.env() == :test -> children
        true -> [{WeatherKv.LogFileAppender, "weather_log.db"} | children]
      end

    # IO.puts(children)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherKv.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
