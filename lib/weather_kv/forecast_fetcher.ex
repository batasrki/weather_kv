defmodule WeatherKv.ForecastFetcher do
  use GenServer

  def start_link(_state) do
    GenServer.start_link(__MODULE__, nil)
  end

  def hourly_forecast(pid, lat_long) do
    GenServer.call(pid, {:hourly_forecast, lat_long})
  end

  @impl GenServer
  def init(_state) do
    {:ok,
     %{
       darksky_url: Application.get_env(:weather_kv, :darksky_url),
       darksky_api_key: Application.get_env(:weather_kv, :darksky_api_key)
     }}
  end

  @impl GenServer
  def handle_call({:hourly_forecast, lat_long}, _from, state) do
    url = state[:darksky_url]
    key = state[:darksky_api_key]
    path_to_forecast = Enum.join([url, key, lat_long], "/")
    with_options = "#{path_to_forecast}?units=ca&exclude=daily,minutely,alerts,flags,currently"
    {:ok, response} = HTTPoison.get(with_options)
    response_body = Poison.Parser.parse!(response.body)
    hourly_data = response_body["hourly"]["data"]

    {current_offset, size} = WeatherKv.LogFileAppender.record(lat_long, hourly_data)
    WeatherKv.Index.update(lat_long, current_offset, size)

    # WeatherKv.LogFileAppender.record(response_body["hourly"]["data"])
    {:reply, response, state}
  end
end
