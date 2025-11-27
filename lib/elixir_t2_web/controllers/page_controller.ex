defmodule ElixirT2Web.PageController do
  use ElixirT2Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def page1(conn, _params) do
    render(conn, :page1)
  end

  def page2(conn, _params) do
    render(conn, :page2)
  end

  def page3(conn, _params) do
    render(conn, :page3)
  end

  def article(conn, _params) do
    render(conn, :article)
  end
end
