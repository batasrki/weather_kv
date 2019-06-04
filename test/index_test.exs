defmodule IndexTest do
  use ExUnit.Case

  test "key stores a tuple of offset and byte size" do
    WeatherKv.Index.update(1, 0, 500)
    assert {:ok, {0, 500}} == WeatherKv.Index.lookup(1)
  end

  test "key stores updated offset and byte size" do
    WeatherKv.Index.update(1, 0, 500)
    WeatherKv.Index.update(1, 1000, 501)
    assert {:ok, {1000, 501}} == WeatherKv.Index.lookup(1)
  end
end
