defmodule ForecastFetcherTest do
  use ExUnit.Case

  setup do
    full_filepath =
      Application.get_env(:weather_kv, :filepath) <> Application.get_env(:weather_kv, :filename)

    start_supervised!(
      {WeatherKv.LogFileAppender,
       [
         filepath: Application.get_env(:weather_kv, :filepath),
         filename: Application.get_env(:weather_kv, :filename)
       ]}
    )

    on_exit(fn ->
      :file.delete(full_filepath)
    end)
  end

  test "gets a result from the remote endpoint" do
    pid = find_fetcher_pid()
    result = WeatherKv.ForecastFetcher.hourly_forecast(pid, "1,1")
    assert "" != result
  end

  test "result is indexed with the lat/long" do
    pid = find_fetcher_pid()
    WeatherKv.ForecastFetcher.hourly_forecast(pid, "1,1")
    assert {:error, :not_found} != WeatherKv.Index.lookup("1,1")
  end

  defp find_fetcher_pid() do
    pid = Process.whereis(WeatherKv.Supervisor)

    process =
      Supervisor.which_children(pid)
      |> Enum.find(fn spec ->
        {mod, pid, _, _} = spec

        if mod == WeatherKv.ForecastFetcher do
          spec
        else
          nil
        end
      end)

    {_, pid, _, _} = process
    pid
  end
end
