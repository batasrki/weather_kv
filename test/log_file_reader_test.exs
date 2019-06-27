defmodule LogFileReaderTest do
  use ExUnit.Case

  @expected_file_path "weather_log.db"

  setup do
    start_supervised!({WeatherKv.LogFileAppender, @expected_file_path})
    on_exit(fn -> :file.delete(@expected_file_path) end)
  end

  test "given a key, read the content from the log file" do
    {offset, size} = WeatherKv.LogFileAppender.record("1,2", %{a: :b})
    WeatherKv.Index.update("1,2", offset, size)

    {:ok, pid} = WeatherKv.LogFileReader.start_link("weather_log.db")

    assert {:ok, "{\"a\":\"b\"}"} == WeatherKv.LogFileReader.get(pid, "1,2")
  end
end
