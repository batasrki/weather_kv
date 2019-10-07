defmodule WeatherKv.LogFileAppender do
  use GenServer

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def record(lat_long, weather) do
    GenServer.call(__MODULE__, {lat_long, weather})
  end

  @impl GenServer
  def init(initial) do
    full_filepath = initial[:filepath] <> initial[:filename]
    fd = File.open!(full_filepath, [:append, :binary])
    {:ok, %{fd: fd, current_offset: 0}}
  end

  @impl GenServer
  def handle_call(
        {lat_long, weather},
        _from,
        %{fd: fd, current_offset: current_offset} = state
      ) do
    {data, _key_size, value_rel_offset, value_size} = kv_to_binary(lat_long, weather)
    :ok = IO.binwrite(fd, data)
    value_offset = current_offset + value_rel_offset

    {:reply, {value_offset, value_size}, %{state | current_offset: value_offset + value_size}}
  end

  defp kv_to_binary(key, value) do
    timestamp = :os.system_time(:millisecond)
    key_size = byte_size(key)

    serialized_value = Poison.encode!(value)
    value_size = byte_size(serialized_value)

    timestamp_data = <<timestamp::big-unsigned-integer-size(64)>>
    key_size_data = <<key_size::big-unsigned-integer-size(16)>>
    value_size_data = <<value_size::big-unsigned-integer-size(32)>>
    sizes_data = <<key_size_data::binary, value_size_data::binary>>
    kv_data = <<key::binary, serialized_value::binary>>
    data = <<timestamp_data::binary, sizes_data::binary, kv_data::binary>>

    value_rel_offset = byte_size(timestamp_data) + byte_size(sizes_data) + key_size
    {data, key_size, value_rel_offset, value_size}
  end
end
