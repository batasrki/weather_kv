defmodule LogFileAppenderTest do
  use ExUnit.Case

  setup do
    full_filepath =
      Application.get_env(:weather_kv, :filepath) <> Application.get_env(:weather_kv, :filename)

    start_supervised!(
      {WeatherKv.LogFileAppender,
       filepath: Application.get_env(:weather_kv, :filepath),
       filename: Application.get_env(:weather_kv, :filename)}
    )

    on_exit(fn ->
      :file.delete(full_filepath)
    end)
  end

  test "appends to an existing file" do
    full_filepath =
      Application.get_env(:weather_kv, :filepath) <> Application.get_env(:weather_kv, :filename)

    WeatherKv.LogFileAppender.record("0", "a")
    WeatherKv.LogFileAppender.record("1", "b")

    codepoints = String.codepoints(File.read!(full_filepath))
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
