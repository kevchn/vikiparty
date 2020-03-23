defmodule VikipartyWeb.PageController do
  use VikipartyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
