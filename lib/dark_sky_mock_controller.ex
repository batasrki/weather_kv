defmodule WeatherKv.DarkSkyMockController do
  use Plug.Router
  plug(Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Poison)

  plug(:match)
  plug(:dispatch)

  get("/forecast/123456/1,1") do
    # fd = File.open("test/forecast_fixture.txt", [:read, :binary])
    body = File.read!("test/forecast_fixture.txt")
    Plug.Conn.send_resp(conn, 200, body)
  end
end
