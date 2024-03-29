defmodule WeatherKv.MixProject do
  use Mix.Project

  def project do
    [
      app: :weather_kv,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WeatherKv.Application, []},
      applications: applications(Mix.env())
    ]
  end

  defp applications(:test), do: applications(:default) ++ [:cowboy, :plug, :propcheck]

  defp applications(_), do: [:httpoison]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.6"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~>1.8"},
      {:propcheck, "~>1.1", only: [:test, :dev]}
    ]
  end
end
