defmodule WeatherKv.DarkSkyMockServer do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link(_args) do
    Plug.Cowboy.http(WeatherKv.DarkSkyMockController, [], port: 8081)
  end
end
