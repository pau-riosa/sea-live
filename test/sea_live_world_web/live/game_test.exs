defmodule SeaLiveWorldWeb.Live.GameTest do
  use SeaLiveWorldWeb.ConnCase
  import Phoenix.LiveViewTest

  alias SeaLiveWorldWeb.Live.Game

  @board [
    {1, 1},
    {1, 2},
    {1, 3},
    {2, 1},
    {2, 2},
    {2, 3},
    {3, 1},
    {3, 2},
    {3, 3}
  ]

  setup %{conn: conn} do
    conn = get(conn, "/game")
    {:ok, live_conn: live(conn)}
  end

  test "connected mount", %{live_conn: live_conn} do
    {:ok, view, html} = live_conn
    assert %{module: Game} = view
    assert html =~ "Restart"
  end

  describe "whale moves" do
    test "left" do
      params = %{step: "ArrowLeft", x_old: 2, y_old: 2}
      assert {{1, 2}, "whaleleft"} = Game.arrow_keys(params, "whale")
    end

    test "right" do
      params = %{step: "ArrowRight", x_old: 2, y_old: 2}
      assert {{3, 2}, "whaleright"} = Game.arrow_keys(params, "whale")
    end

    test "up" do
      params = %{step: "ArrowUp", x_old: 2, y_old: 2}
      assert {{2, 1}, "whaleup"} = Game.arrow_keys(params, "whale")
    end

    test "down" do
      params = %{step: "ArrowDown", x_old: 2, y_old: 2}
      assert {{2, 3}, "whaledown"} = Game.arrow_keys(params, "whale")
    end

    test "diagonal up left" do
      params = %{step: "q", x_old: 2, y_old: 2}
      assert {{1, 1}, "whalediagonalupleft"} = Game.arrow_keys(params, "whale")
    end

    test "diagonal down left" do
      params = %{step: "a", x_old: 2, y_old: 2}
      assert {{1, 3}, "whalediagonaldownleft"} = Game.arrow_keys(params, "whale")
    end

    test "diagonal up right" do
      params = %{step: "w", x_old: 2, y_old: 2}
      assert {{3, 1}, "whalediagonalupright"} = Game.arrow_keys(params, "whale")
    end

    test "diagonal down right" do
      params = %{step: "s", x_old: 2, y_old: 2}
      assert {{3, 3}, "whalediagonaldownright"} = Game.arrow_keys(params, "whale")
    end
  end

  describe "penguin moves" do
    test "left" do
      params = %{step: "ArrowLeft", x_old: 2, y_old: 2}
      assert {{1, 2}, "penguinleft"} = Game.arrow_keys(params, "penguin")
    end

    test "right" do
      params = %{step: "ArrowRight", x_old: 2, y_old: 2}
      assert {{3, 2}, "penguinright"} = Game.arrow_keys(params, "penguin")
    end

    test "up" do
      params = %{step: "ArrowUp", x_old: 2, y_old: 2}
      assert {{2, 1}, "penguinup"} = Game.arrow_keys(params, "penguin")
    end

    test "down" do
      params = %{step: "ArrowDown", x_old: 2, y_old: 2}
      assert {{2, 3}, "penguindown"} = Game.arrow_keys(params, "penguin")
    end

    test "diagonal up left" do
      params = %{step: "q", x_old: 2, y_old: 2}
      assert {{1, 1}, "penguindiagonalupleft"} = Game.arrow_keys(params, "penguin")
    end

    test "diagonal down left" do
      params = %{step: "a", x_old: 2, y_old: 2}
      assert {{1, 3}, "penguindiagonaldownleft"} = Game.arrow_keys(params, "penguin")
    end

    test "diagonal up right" do
      params = %{step: "w", x_old: 2, y_old: 2}
      assert {{3, 1}, "penguindiagonalupright"} = Game.arrow_keys(params, "penguin")
    end

    test "diagonal down right" do
      params = %{step: "s", x_old: 2, y_old: 2}
      assert {{3, 3}, "penguindiagonaldownright"} = Game.arrow_keys(params, "penguin")
    end
  end
end
