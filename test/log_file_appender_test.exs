defmodule LogFileAppenderTest do
  use ExUnit.Case

  @expected_file_path "43844841_-79560515.db"

  setup do
    on_exit(fn -> :file.delete(@expected_file_path) end)
  end

  test "creates test file if it doesn't exist" do
    WeatherKv.LogFileAppender.start_link("43.844841,-79.560515")
    assert File.exists?(@expected_file_path)
  end

  test "appends to an existing file" do
    fd = File.open!(@expected_file_path, [:write, :binary])
    :ok = IO.binwrite(fd, "a")
    File.close(fd)

    WeatherKv.LogFileAppender.start_link("43.844841,-79.560515")
    WeatherKv.LogFileAppender.record(1, "b")

    assert "a\"b\"" == File.read!(@expected_file_path)
  end

  test "returns offset and byte size of stored record" do
    WeatherKv.LogFileAppender.start_link("43.844841,-79.560515")

    {offset, byte_size} = WeatherKv.LogFileAppender.record(1, "b")
    assert 0 == offset
    assert 3 == byte_size
  end
end
