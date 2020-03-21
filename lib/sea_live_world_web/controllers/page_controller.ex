defmodule SeaLiveWorldWeb.PageController do
  use SeaLiveWorldWeb, :controller

  def index(conn, _params) do
    live_render(conn, SeaLiveWorldWeb.Live.Game, session: %{"cookies" => conn.cookies})
  end
end
