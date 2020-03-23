defmodule SeaLiveWorldWeb.Live.GameTest do
  use SeaLiveWorldWeb.ConnCase
  import Phoenix.LiveViewTest

  alias SeaLiveWorldWeb.Live.Game

  @width 3
  @height 3

  setup %{conn: conn} do
    conn = get(conn, "/game")
    {:ok, conn: conn, live_conn: live(conn)}
  end

  @board %{
    {1, 1} => :free,
    {1, 2} => :free,
    {1, 3} => :penguin,
    {2, 1} => :free,
    {2, 2} => :occ,
    {2, 3} => :penguin,
    {3, 1} => :penguin,
    {3, 2} => :free,
    {3, 3} => :free
  }
  defp new_game(_) do
    assigns = %{
      board: @board,
      field_size: 50,
      gameplay?: true,
      penguin_direction: :penguindown,
      whale_direction: :whaledown,
      penguin_x: 1,
      penguin_y: 1,
      whale_x: @width,
      whale_y: @height,
      penguin_counter: 0,
      whale_counter: 0,
      die_counter: 4,
      die_whale?: false,
      whale_eats?: false,
      character: "penguin"
    }

    socket = %Phoenix.LiveView.Socket{assigns: assigns, endpoint: @endpoint}
    {:ok, socket: socket}
  end

  describe "new_game" do
    # initialize the game
    setup [:new_game]

    test "flow", %{socket: socket} do
      # current_position of penguin
      assert %{assigns: %{penguin_x: x, penguin_y: y, penguin_direction: :penguindown}} = socket
      assert {1, 1} = {x, y}

      # first move penguin
      move_socket = Game.step(:penguin, socket, %{"key" => "ArrowRight"})
      assert %{assigns: %{character: character, penguin_x: new_x, penguin_y: new_y}} = move_socket

      assert {x, y} != {new_x, new_y}
      assert character == "whale"
    end
  end

  test "connected mount", %{live_conn: live_conn} do
    {:ok, view, html} = live_conn
    assert %{module: Game} = view
    assert html =~ "Restart"
  end

  test "Render game as component" do
    assert render_component(Game,
             board: Game.board(@width, @height),
             field_size: 50,
             gameplay?: true,
             penguin_direction: :penguindown,
             whale_direction: :whaledown,
             penguin_x: 1,
             penguin_y: 1,
             whale_x: @width,
             whale_y: @height,
             penguin_counter: 0,
             whale_counter: 0,
             die_counter: 4,
             die_whale?: false,
             whale_eats?: false,
             character: :penguin
           ) =~
             "Restart"
  end

  describe "penguin get_new_position/3 going" do
    test "invalid key" do
      assert :invalid_key =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "k"}
               )
    end

    test "left" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "ArrowLeft"}
               )

      assert {1, 2} = coordinates
      assert "penguinleft" = direction
    end

    test "right" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "ArrowRight"}
               )

      assert {3, 2} = coordinates
      assert "penguinright" = direction
    end

    test "up" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "ArrowUp"}
               )

      assert {2, 1} = coordinates
      assert "penguinup" = direction
    end

    test "down" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "ArrowDown"}
               )

      assert {2, 3} = coordinates
      assert "penguindown" = direction
    end

    test "diagonal up left" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "q"}
               )

      assert {1, 1} = coordinates
      assert "penguindiagonalupleft" = direction
    end

    test "diagonal down left" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "a"}
               )

      assert {1, 3} = coordinates
      assert "penguindiagonaldownleft" = direction
    end

    test "diagonal up right" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "w"}
               )

      assert {3, 1} = coordinates
      assert "penguindiagonalupright" = direction
    end

    test "diagonal down right" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :penguin,
                 %{assigns: %{penguin_x: 2, penguin_y: 2, penguin_direction: "penguinleft"}},
                 %{"key" => "s"}
               )

      assert {3, 3} = coordinates
      assert "penguindiagonaldownright" = direction
    end
  end

  describe "whale get_new_position/3 going" do
    test "invalid key" do
      assert :invalid_key =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whaleleft"}},
                 %{"key" => "k"}
               )
    end

    test "left" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whaleleft"}},
                 %{"key" => "ArrowLeft"}
               )

      assert {1, 2} = coordinates
      assert "whaleleft" = direction
    end

    test "right" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whaleright"}},
                 %{"key" => "ArrowRight"}
               )

      assert {3, 2} = coordinates
      assert "whaleright" = direction
    end

    test "up" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whaleup"}},
                 %{"key" => "ArrowUp"}
               )

      assert {2, 1} = coordinates
      assert "whaleup" = direction
    end

    test "down" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whaledown"}},
                 %{"key" => "ArrowDown"}
               )

      assert {2, 3} = coordinates
      assert "whaledown" = direction
    end

    test "diagonal up left" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whalediagonalupleft"}},
                 %{"key" => "q"}
               )

      assert {1, 1} = coordinates
      assert "whalediagonalupleft" = direction
    end

    test "diagonal down left" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whalediagonaldownleft"}},
                 %{"key" => "a"}
               )

      assert {1, 3} = coordinates
      assert "whalediagonaldownleft" = direction
    end

    test "diagonal up right" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whalediagonalupright"}},
                 %{"key" => "w"}
               )

      assert {3, 1} = coordinates
      assert "whalediagonalupright" = direction
    end

    test "diagonal down right" do
      assert {coordinates, direction} =
               Game.get_new_position(
                 :whale,
                 %{assigns: %{whale_x: 2, whale_y: 2, whale_direction: "whalediagonaldownright"}},
                 %{"key" => "s"}
               )

      assert {3, 3} = coordinates
      assert "whalediagonaldownright" = direction
    end
  end

  describe "whale movement using arrow_keys/2 going" do
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

  describe "penguin movement using arrow_keys/2 going" do
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
