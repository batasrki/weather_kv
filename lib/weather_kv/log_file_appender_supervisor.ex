defmodule WeatherKv.LogFileAppenderSupervisor do
  use DynamicSupervisor

  def start_link(:ok) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(lat_long) do
    spec = {WeatherKv.LogFileAppender, lat_long}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
