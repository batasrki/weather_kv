defmodule WeatherKv.LogFileReader do
  use GenServer

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial)
  end

  def get(pid, lat_long) do
    GenServer.call(pid, {:get, lat_long})
  end

  @impl GenServer
  def init(initial) do
    full_filepath = initial[:filepath] <> initial[:filename]

    fd = File.open!(full_filepath, [:read, :binary])
    {:ok, %{fd: fd}}
  end

  @impl GenServer
  def handle_call({:get, lat_long}, _from, %{fd: fd} = state) do
    case WeatherKv.Index.lookup(lat_long) do
      {:ok, {offset, size}} ->
        {:reply, :file.pread(fd, offset, size), state}

      {:error, _} = error ->
        {:reply, error, state}
    end
  end
end
