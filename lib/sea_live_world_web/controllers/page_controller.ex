defmodule SeaLiveWorldWeb.PageController do
  use SeaLiveWorldWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
