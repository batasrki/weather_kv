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
    pid =
      case Map.fetch(state, :writer) do
        :error ->
          get_log_file_appender(lat_long)

        {:ok, pid} ->
          pid
      end

    IO.inspect(pid)
    url = state[:darksky_url]
    key = state[:darksky_api_key]
    path_to_forecast = Enum.join([url, key, lat_long], "/")
    with_options = "#{path_to_forecast}?units=ca&exclude=daily,minutely,alerts,flags,currently"
    {:ok, response} = HTTPoison.get(with_options)
    response_body = Poison.Parser.parse!(response.body)
    hourly_data = response_body["hourly"]["data"]

    Enum.each(hourly_data, fn record ->
      WeatherKv.LogFileAppender.record(pid, record["time"], record)
    end)

    # WeatherKv.LogFileAppender.record(response_body["hourly"]["data"])
    new_state = Map.put(state, :writer, pid)
    {:reply, response, new_state}
  end

  defp get_log_file_appender(lat_long) do
    case WeatherKv.LogFileAppenderSupervisor.start_child(lat_long) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
