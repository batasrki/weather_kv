defmodule WeatherKv.ForecastFetcher do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def hourly_forecast(lat_long) do
    GenServer.call(__MODULE__, {:hourly_forecast, lat_long})
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:hourly_forecast, lat_long}, _from, state) do
    path_to_forecast = Enum.join(state, "/")
    path_to_forecast = Enum.join([path_to_forecast, lat_long], "/")
    with_options = "#{path_to_forecast}?units=ca&exclude=daily,minutely,alerts,flags,currently"
    {:ok, response} = HTTPoison.get(with_options)
    response_body = Poison.Parser.parse!(response.body)
    hourly_data = response_body["hourly"]["data"]

    Enum.each(hourly_data, fn record ->
      WeatherKv.LogFileAppender.record(record["time"], record)
    end)

    # WeatherKv.LogFileAppender.record(response_body["hourly"]["data"])
    {:reply, response, state}
  end
end
