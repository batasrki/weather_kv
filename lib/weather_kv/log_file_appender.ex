defmodule WeatherKv.LogFileAppender do
  use GenServer

  def start_link(lat_long) do
    GenServer.start_link(__MODULE__, lat_long)
  end

  def record(pid, timestamp, weather) do
    GenServer.call(pid, {timestamp, weather})
  end

  @impl GenServer
  def init(lat_long) do
    log_file_path =
      String.replace(lat_long, ".", "") |> String.replace(" ", "") |> String.replace(",", "_")

    fd = File.open!("#{log_file_path}.db", [:append, :binary])
    {:ok, %{fd: fd, current_offset: 0}}
  end

  @impl GenServer
  def handle_call(
        {timestamp, weather},
        _from,
        %{fd: fd, current_offset: current_offset} = state
      ) do
    serialized_weather = Poison.encode!(weather)
    :ok = IO.binwrite(fd, serialized_weather)
    size = byte_size(serialized_weather)
    WeatherKv.Index.update(timestamp, current_offset, size)
    {:reply, {current_offset, size}, %{state | current_offset: current_offset + size}}
  end
end
