defmodule LogFileAppenderTest do
  use ExUnit.Case

  @expected_file_path "weather_log.db"

  setup do
    start_supervised!({WeatherKv.LogFileAppender, @expected_file_path})

    on_exit(fn ->
      :file.delete(@expected_file_path)
    end)
  end

  test "creates test file if it doesn't exist" do
    # WeatherKv.LogFileAppender.start_link("43.844841,-79.560515")
    assert File.exists?(@expected_file_path)
  end

  test "appends to an existing file" do
    WeatherKv.LogFileAppender.record("0", "a")
    WeatherKv.LogFileAppender.record("1", "b")

    codepoints = String.codepoints(File.read!(@expected_file_path))
    assert Enum.any?(codepoints, fn codepoint -> "a" == codepoint end)
    assert Enum.any?(codepoints, fn codepoint -> "b" == codepoint end)

    # assert "a\"b\"" == File.read!(@expected_file_path)
  end

  test "returns offset and byte size of stored record" do
    # WeatherKv.LogFileAppender.start_link("43.844841,-79.560515")

    {offset, byte_size} = WeatherKv.LogFileAppender.record("1", "b")
    assert 15 == offset
    assert 3 == byte_size
  end
end
