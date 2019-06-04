defmodule WeatherKv.LogFileReader do
  use GenServer

  def start_link(lat_long) do
    GenServer.start_link(__MODULE__, lat_long)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @impl GenServer
  def init(lat_long) do
    {:ok, %{fd: open(lat_long)}}
  end

  def open(lat_long) do
    log_file_path = String.replace(lat_long, ".", "") |> String.replace(",", "_")
    File.open!("#{log_file_path}.db", [:read, :binary])
  end

  @impl GenServer
  def handle_call({:get, key}, _from, %{fd: fd} = state) do
    case WeatherKv.Index.lookup(key) do
      {:ok, {offset, size}} ->
        {:reply, :file.pread(fd, offset, size), state}

      {:error, _} = error ->
        {:reply, error, state}
    end
  end
end
