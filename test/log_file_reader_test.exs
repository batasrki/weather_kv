defmodule LogFileReaderTest do
  use ExUnit.Case

  setup do
    full_filepath =
      Application.get_env(:weather_kv, :filepath) <> Application.get_env(:weather_kv, :filename)

    start_supervised!(
      {WeatherKv.LogFileAppender,
       filepath: Application.get_env(:weather_kv, :filepath),
       filename: Application.get_env(:weather_kv, :filename)}
    )

    on_exit(fn -> :file.delete(full_filepath) end)
  end

  test "given a key, read the content from the log file" do
    {offset, size} = WeatherKv.LogFileAppender.record("1,2", %{a: :b})
    WeatherKv.Index.update("1,2", offset, size)

    {:ok, pid} =
      WeatherKv.LogFileReader.start_link(
        filepath: Application.get_env(:weather_kv, :filepath),
        filename: Application.get_env(:weather_kv, :filename)
      )

    assert {:ok, "{\"a\":\"b\"}"} == WeatherKv.LogFileReader.get(pid, "1,2")
  end
end
