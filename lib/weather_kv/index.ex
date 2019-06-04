defmodule WeatherKv.Index do
  use GenServer

  def start_link(_nil) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def update(timestamp, offset, size) do
    GenServer.call(__MODULE__, {:update, timestamp, offset, size})
  end

  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @impl GenServer
  def init(index) do
    {:ok, index}
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
