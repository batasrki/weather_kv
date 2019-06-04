defmodule LogFileReaderTest do
  use ExUnit.Case

  @expected_file_path "43844841_-79560515.db"

  setup do
    on_exit(fn -> :file.delete(@expected_file_path) end)
  end

  test "if log file doesn't exist, return an error" do
    assert_raise(File.Error, fn ->
      WeatherKv.LogFileReader.open("43.844841,-79.560515")
    end)
  end

  test "given a key, read the content from the log file" do
    WeatherKv.LogFileAppender.start_link("43.844841,-79.560515")
    WeatherKv.LogFileAppender.record(1, %{a: :b})

    {:ok, pid} = WeatherKv.LogFileReader.start_link("43.844841,-79.560515")

    assert {:ok, "{\"a\":\"b\"}"} == WeatherKv.LogFileReader.get(pid, 1)
  end
end
