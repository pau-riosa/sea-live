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
    {2, 3} => :free,
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

  describe "game" do
    # initialize the game
    setup [:new_game]

    test "skip" do
      board = %{
        {1, 1} => :whale,
        {2, 1} => :free,
        {3, 1} => :penguin,
        {1, 2} => :penguin,
        {2, 2} => :whale,
        {3, 2} => :penguin,
        {1, 3} => :penguin,
        {2, 3} => :whale,
        {3, 3} => :occ
      }

      assigns = %{
        board: board,
        penguin_direction: :penguindown,
        penguin_x: 2,
        penguin_y: 2
      }

      socket = %Phoenix.LiveView.Socket{assigns: assigns, endpoint: @endpoint}

      skip(board, socket.assigns.penguin_x, socket.assigns.penguin_y)
      |> raise
    end

    defp skip(board, x, y) do
      compute(x, y)
      |> Enum.sort()
      |> raise

      # board
      # |> Map.to_list()
      # |> Enum.all?(fn field ->
      #   check_neighbor_if_empty(field, x, y)
      # end)
    end

    defp compute(x, y) do
      [
        going_left(x, y),
        going_right(x, y),
        going_up(x, y),
        going_down(x, y),
        going_diagonal_up_left(x, y),
        going_diagonal_down_left(x, y),
        going_diagonal_down_right(x, y),
        going_diagonal_up_right(x, y)
      ]
    end

    defp going_left(x, y), do: {x - 1, y}
    defp going_right(x, y), do: {x + 1, y}
    defp going_up(x, y), do: {x, y - 1}
    defp going_down(x, y), do: {x, y + 1}
    defp going_diagonal_up_left(x, y), do: {x - 1, y - 1}
    defp going_diagonal_down_left(x, y), do: {x - 1, y + 1}
    defp going_diagonal_down_right(x, y), do: {x + 1, y + 1}
    defp going_diagonal_up_right(x, y), do: {x + 1, y - 1}

    defp check_neighbor_if_empty(field, x, y) do
      fn
        {{hx, hy}, type} = field
        when hx == x - 1 and hy == y and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x + 1 and hy == y and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x and hy == y - 1 and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x and hy == y + 1 and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x - 1 and hy == y - 1 and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x - 1 and hy == y + 1 and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x + 1 and hy == y + 1 and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x + 1 and hy == y - 1 and type in [:whale, :occ, :penguin] ->
          true

        {{hx, hy}, type} = field
        when hx == x + 1 and hy == y and type == :free ->
          false

        field ->
          false
      end
    end

    # defp check_neighbors_if_empty(board, x, y) do
    #   Enum.find(board, fn
    #     {{hx, hy}, type}
    #     when hx == x - 1 and hy == y and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x + 1 and hy == y and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x and hy == y - 1 and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x and hy == y + 1 and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x - 1 and hy == y - 1 and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x - 1 and hy == y + 1 and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x + 1 and hy == y + 1 and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x + 1 and hy == y - 1 and type in [:whale, :occ, :penguin] ->
    #       true

    #     {{hx, hy}, type}
    #     when hx == x and hy == y and type == :free ->
    #       true
    #   end)
    # end

    # defp check_neighbors_if_empty([], _x, _y, acc), do: acc

    # defp check_neighbors_if_empty([head_cell | tail_cells], x, y, acc) do
    #   new_head =
    #     case head_cell do
    #       {{hx, hy}, type}
    #       when hx == x - 1 and hy == y and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x + 1 and hy == y and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x and hy == y - 1 and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x and hy == y + 1 and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x - 1 and hy == y - 1 and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x - 1 and hy == y + 1 and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x + 1 and hy == y + 1 and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x + 1 and hy == y - 1 and type != :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, type}
    #       when hx == x and hy == y and type == :free ->
    #         {{hx, hy}, :skip}

    #       {{hx, hy}, _} ->
    #         {{hx, hy}, :turn}
    #     end

    #   acc = acc ++ [new_head]
    #   check_neighbors_if_empty(tail_cells, x, y, acc)
    # end

    test "flow", %{socket: socket} do
      # current position of penguin
      assert %{assigns: %{penguin_x: x, penguin_y: y, penguin_direction: :penguindown}} = socket
      assert {1, 1} = {x, y}

      # current_move: penguin going right
      # next_move: whale
      socket = Game.step(:penguin, socket, %{"key" => "ArrowRight"})

      assert %{
               assigns: %{
                 character: character,
                 penguin_x: new_x,
                 penguin_y: new_y,
                 penguin_counter: counter
               }
             } = socket

      assert {x, y} != {new_x, new_y}
      assert {new_x, new_y} == {2, 1}
      assert character == "whale"
      assert counter == 1

      # current position of whale
      # next_move: whale
      assert %{
               assigns: %{
                 whale_x: x,
                 whale_y: y,
                 whale_direction: :whaledown,
                 whale_counter: counter,
                 die_counter: die_counter
               }
             } = socket

      assert {3, 3} = {x, y}
      assert counter == 0
      assert die_counter == 4

      # current_move: whale going up
      # next_move: penguin
      socket = Game.step(:whale, socket, %{"key" => "ArrowUp"})

      assert %{
               assigns: %{
                 character: character,
                 whale_x: new_x,
                 whale_y: new_y,
                 whale_direction: direction,
                 whale_counter: counter,
                 die_counter: die_counter
               }
             } = socket

      assert {x, y} != {new_x, new_y}
      assert {new_x, new_y} == {3, 2}
      assert counter == 1
      assert die_counter == 0
      assert character == "penguin"
      assert direction == "whaleup"

      # current_move: penguin going diagonal down left
      # next_move: whale
      socket = Game.step(:penguin, socket, %{"key" => "a"})

      assert %{
               assigns: %{
                 character: character,
                 penguin_x: new_x,
                 penguin_y: new_y,
                 penguin_direction: direction,
                 penguin_counter: counter
               }
             } = socket

      assert {new_x, new_y} == {1, 2}
      assert character == "whale"
      assert counter == 2
      assert direction == "penguindiagonaldownleft"

      # current_move: whale going up
      # next_move: penguin
      socket = Game.step(:whale, socket, %{"key" => "ArrowUp"})

      assert %{
               assigns: %{
                 character: character,
                 whale_x: new_x,
                 whale_y: new_y,
                 whale_direction: direction,
                 whale_counter: counter,
                 die_counter: die_counter,
                 board: board
               }
             } = socket

      assert {new_x, new_y} == {3, 1}
      assert counter == 2
      assert die_counter == 1
      assert character == "penguin"
      assert direction == "whaleup"
      # scenario: whale eats up the penguin and free the penguin type field
      assert :free = Map.get(board, {new_x, new_y})

      # current_move: penguin going diagonal down right
      # next_move: whale
      socket = Game.step(:penguin, socket, %{"key" => "s"})

      assert %{
               assigns: %{
                 character: character,
                 penguin_x: new_x,
                 penguin_y: new_y,
                 penguin_direction: direction,
                 penguin_counter: counter,
                 board: board
               }
             } = socket

      assert character == "whale"
      assert counter == 3
      assert direction == "penguindiagonaldownright"
      # scenario: penguin lives in 3 turn, reproduce arbitrarily and takes 1 coordinate randomly
      assert board != @board
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
