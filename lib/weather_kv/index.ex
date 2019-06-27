defmodule WeatherKv.Index do
  use GenServer

  def start_link(logfile_path) do
    GenServer.start_link(__MODULE__, logfile_path, name: __MODULE__)
  end

  def update(timestamp, offset, size) do
    GenServer.call(__MODULE__, {:update, timestamp, offset, size})
  end

  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @impl GenServer
  def init(logfile_path) do
    with {:ok, fd} <- File.open(logfile_path, [:read, :binary]),
         {_current_offset, index} = load_offsets(fd) do
      File.close(fd)
      {:ok, index}
    else
      _ -> {:ok, %{}}
    end
  end

  defp load_offsets(fd, index \\ %{}, current_offset \\ 0) do
    :file.position(fd, current_offset)

    with <<_timestamp::big-unsigned-integer-size(64)>> <- IO.binread(fd, 8),
         <<key_size::big-unsigned-integer-size(16)>> <- IO.binread(fd, 2),
         <<value_size::big-unsigned-integer-size(32)>> <- IO.binread(fd, 4),
         key <- IO.binread(fd, key_size) do
      # magic number 14 is the number of bytes from the beginning of the entry to the value
      # 8 + 2 + 4 = 14; Values are from the 3 above lines
      value_abs_offset = current_offset + 14 + key_size
      index = Map.put(index, key, {value_abs_offset, value_size})
      load_offsets(fd, index, value_abs_offset + value_size)
    else
      :eof -> {current_offset, index}
    end
  end

  @impl GenServer
  def handle_call({:update, timestamp, offset, size}, _from, state) do
    new_state = Map.put(state, timestamp, {offset, size})
    {:reply, new_state, new_state}
  end

  @impl GenServer
  def handle_call({:lookup, key}, _from, state) do
    offset_size =
      case Map.get(state, key) do
        {_offset, _size} = offset_size -> {:ok, offset_size}
        nil -> {:error, :not_found}
      end

    {:reply, offset_size, state}
  end
end
