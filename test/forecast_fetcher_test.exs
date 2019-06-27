defmodule ForecastFetcherTest do
  use ExUnit.Case

  setup do
    start_supervised!({WeatherKv.LogFileAppender, "weather_log.db"})

    on_exit(fn ->
      :file.delete("weather_log.db")
    end)
  end

  test "gets a result from the remote endpoint" do
    {:ok, pid} = WeatherKv.ForecastFetcher.start_link(:ok)
    result = WeatherKv.ForecastFetcher.hourly_forecast(pid, "1,1")
    assert "" != result
  end

  test "result is indexed with the lat/long" do
    {:ok, pid} = WeatherKv.ForecastFetcher.start_link(:ok)
    WeatherKv.ForecastFetcher.hourly_forecast(pid, "1,1")
    assert {:error, :not_found} != WeatherKv.Index.lookup("1,1")
  end
end
