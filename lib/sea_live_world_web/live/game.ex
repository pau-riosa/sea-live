defmodule SeaLiveWorldWeb.Live.Game do
  @moduledoc """
  Sea World: a phoenix liveview game inspired by hippo_game_live by medallini
  """
  use Phoenix.LiveView

  alias SeaLiveWorldWeb.PageView

  @default_width 15
  @default_height 10
  @difficulty 12
  @characters ["penguin", "whale"]

  @doc """
  render game page
  """
  def render(assigns) do
    PageView.render("game.html", assigns)
  end

  @doc """
  mount new game
  """
  def mount(_params, _assigns, socket) do
    socket =
      socket
      |> new_game()

    if connected?(socket) do
      {:ok, schedule_tick(socket)}
    else
      {:ok, socket}
    end
  end

  @doc """
  restarts game
  """
  def handle_event("penguin", %{"key" => step}, socket) when step in ["r", "R"],
    do: do_restart(socket)

  def handle_event("whale", %{"key" => step}, socket) when step in ["r", "R"],
    do: do_restart(socket)

  def handle_event("restart", _key, socket), do: do_restart(socket)

  @doc """
  penguin take turns
  """
  def handle_event("penguin", key, %{assigns: %{character: "penguin"}} = socket),
    do: {:noreply, step(:penguin, socket, key)}

  def handle_event("penguin", _key, socket), do: {:noreply, socket}

  @doc """
  whale take turns
  """
  def handle_event("whale", key, %{assigns: %{character: "whale"}} = socket),
    do: {:noreply, step(:whale, socket, key)}

  def handle_event("whale", _key, socket), do: {:noreply, socket}

  def handle_info(:tick, socket) do
    {:noreply, socket}
  end

  @doc """
  new game
  """
  def new_game(socket) do
    assign(socket,
      board: board(),
      field_size: 50,
      gameplay?: true,
      penguin_direction: :penguindown,
      whale_direction: :whaledown,
      penguin_x: 1,
      penguin_y: 1,
      whale_x: @default_width,
      whale_y: @default_height,
      penguin_counter: 0,
      whale_counter: 0,
      die_counter: 4,
      die_whale?: false,
      whale_eats?: false,
      character: select_character(@characters)
    )
  end

  @doc """
  creates the dimension of the board base from
  width and height

  and assign each field as
  occ -> occupied by penguin
  penguin -> occupied by penguin
  whale -> occupied by whale
  free -> space for each character
  """
  def board() do
    for x <- 1..@default_width, y <- 1..@default_height, into: %{} do
      [random] = Enum.take_random(Enum.to_list(1..@difficulty), 1)
      type = field_type(random)
      {{x, y}, type}
    end
  end

  @doc """
  steps to make by penguin/whale in each turn
  """
  def step(character, socket, step) do
    {coordinates, direction} = get_new_position(character, socket, step)
    do_step(character, socket, coordinates, direction, Map.get(socket.assigns.board, coordinates))
  end

  defp do_step(:penguin, socket, {x, y} = coordinates, direction, :free) do
    counter = third_step(socket)
    board = add_penguin(socket, counter, coordinates)

    assign(socket,
      board: board,
      penguin_x: x,
      penguin_y: y,
      penguin_direction: direction,
      penguin_counter: counter,
      character: "whale"
    )
  end

  defp do_step(:penguin, socket, _coordinates, _direction, _result), do: socket

  defp do_step(:whale, socket, _coordinates, _direction, result)
       when result in [:whale, :eatpenguin],
       do: socket

  defp do_step(:whale, socket, {x, y} = coordinates, direction, _result) do
    counter = eight_step(socket)
    board = eat_penguin(socket, counter, coordinates)
    die_counter = die_step(socket)
    whale_eats? = whale_eats?(socket, die_counter, coordinates)
    die_whale? = die_whale?(whale_eats?, die_counter)

    assign(socket,
      board: board,
      whale_x: x,
      whale_y: y,
      whale_direction: direction,
      whale_counter: counter,
      die_counter: die_counter,
      die_whale?: die_whale?,
      whale_eats?: whale_eats?,
      character: "penguin"
    )
  end

  defp get_new_position(
         :penguin,
         %{
           assigns: %{
             penguin_x: x_old,
             penguin_y: y_old,
             penguin_direction: old_direction
           }
         } = _socket,
         %{"key" => step} = _keys
       ) do
    params = %{x_old: x_old, y_old: y_old, old_direction: old_direction, step: step}
    do_get_new_position(arrow_keys(params, "penguin"), {x_old, y_old})
  end

  defp get_new_position(
         :whale,
         %{
           assigns: %{
             whale_x: x_old,
             whale_y: y_old,
             whale_direction: old_direction
           }
         } = _socket,
         %{"key" => step} = _keys
       ) do
    params = %{x_old: x_old, y_old: y_old, old_direction: old_direction, step: step}
    do_get_new_position(arrow_keys(params, "whale"), {x_old, y_old})
  end

  defp do_get_new_position({{x, y}, direction}, old_coordinates)
       when x in 1..@default_width and y in 1..@default_height,
       do: {{x, y}, direction}

  defp do_get_new_position({_, direction}, old_coordinates), do: {old_coordinates, direction}

  defp arrow_keys(%{step: "ArrowLeft", x_old: x_old, y_old: y_old} = _params, type),
    do: {{x_old - 1, y_old}, "#{type}left"}

  defp arrow_keys(%{step: "ArrowRight", x_old: x_old, y_old: y_old} = _params, type),
    do: {{x_old + 1, y_old}, "#{type}right"}

  defp arrow_keys(%{step: "ArrowUp", x_old: x_old, y_old: y_old} = _params, type),
    do: {{x_old, y_old - 1}, "#{type}up"}

  defp arrow_keys(%{step: "ArrowDown", x_old: x_old, y_old: y_old} = _params, type),
    do: {{x_old, y_old + 1}, "#{type}down"}

  defp die_whale?(whale_eats?, counter) do
    cond do
      counter >= 3 && !whale_eats? ->
        true

      true ->
        false
    end
  end

  defp die_step(socket) do
    cond do
      socket.assigns.whale_eats? ->
        0

      socket.assigns.die_whale? ->
        3

      socket.assigns.die_counter >= 3 ->
        0

      true ->
        socket.assigns.die_counter + 1
    end
  end

  defp third_step(socket) do
    if socket.assigns.penguin_counter >= 3, do: 0, else: socket.assigns.penguin_counter + 1
  end

  defp eight_step(socket) do
    if socket.assigns.whale_counter >= 8, do: 0, else: socket.assigns.whale_counter + 1
  end

  defp add_penguin(socket, counter, coordinates) do
    cond do
      counter == 3 ->
        {_value, new_board} =
          Map.get_and_update(socket.assigns.board, coordinates, fn current_value ->
            {current_value, :penguin}
          end)

        new_board

      true ->
        socket.assigns.board
    end
  end

  defp add_whale(socket, counter, coordinates) do
    cond do
      counter == 8 ->
        {_value, new_board} =
          Map.get_and_update(socket.assigns.board, coordinates, fn current_value ->
            if current_value not in [:occ, :eatpenguin, :whale], do: {current_value, :whale}
          end)

        new_board

      true ->
        socket.assigns.board
    end
  end

  defp whale_eats?(socket, counter, coordinates) do
    case Map.get(socket.assigns.board, coordinates) do
      res when res in [:penguin, :occ, :eatpenguin] and counter < 3 ->
        true

      _ ->
        false
    end
  end

  defp eat_penguin(socket, counter, coordinates) do
    case Map.get(socket.assigns.board, coordinates) do
      res when res in [:penguin, :occ] ->
        {_value, new_board} =
          Map.get_and_update(socket.assigns.board, coordinates, fn current_value ->
            {current_value, :eatpenguin}
          end)

        new_board

      _ ->
        add_whale(socket, counter, coordinates)
    end
  end

  defp select_character(characters) do
    Enum.take_random(characters, 1) |> List.first()
  end

  defp do_restart(socket) do
    {:noreply, schedule_tick(new_game(socket))}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 1000)
    socket
  end

  # assigns field type
  defp field_type(random) do
    case random do
      1 -> :occ
      2 -> :penguin
      3 -> :whale
      _ -> :free
    end
  end
end
