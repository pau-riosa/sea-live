defmodule SeaLiveWorldWeb.Live.Game do
  use Phoenix.LiveView

  alias SeaLiveWorldWeb.PageView

  def render(assigns) do
    PageView.render("index.html", assigns)
  end

  def mount(_params, assigns, socket) do
    socket =
      socket
      |> new_board()
      |> assign(scores: [])

    if connected?(socket) do
      {:ok, schedule_tick(socket)}
    else
      {:ok, socket}
    end
  end

  def handle_event("penguin", key, socket) do
    if socket.assigns.gameplay? do
      {:noreply, penguin_step(socket, key)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("whale", key, socket) do
    if socket.assigns.gameplay? do
      {:noreply, whale_step(socket, key)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:tick, socket) do
    {:noreply, socket}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 1000)
    socket
  end

  def new_board(socket) do
    assign(socket,
      board: board(),
      field_size: 50,
      gameplay?: true,
      penguin_direction: :penguindown,
      whale_direction: :whaledown,
      penguin_x: 1,
      penguin_y: 1,
      whale_x: 15,
      whale_y: 10,
      penguin_counter: 0,
      whale_counter: 0
    )
  end

  @default_width 15
  @default_height 10
  @difficulty 12
  def board() do
    for x <- 1..@default_width, y <- 1..@default_height, into: %{} do
      [random] = Enum.take_random(Enum.to_list(1..@difficulty), 1)
      type = field_type(random)
      {{x, y}, type}
    end
  end

  defp field_type(random) do
    case random do
      1 -> :occ
      4 -> :whale
      _ -> :free
    end
  end

  defp penguin_step(socket, step) do
    old_position = {socket.assigns.penguin_x, socket.assigns.penguin_y}
    {{x, y} = coordinates, direction} = get_new_position(socket, step)

    case Map.get(socket.assigns.board, coordinates) do
      :free ->
        counter = third_step(socket)
        board = add_penguin(socket, counter, coordinates)

        assign(socket,
          board: board,
          penguin_x: x,
          penguin_y: y,
          penguin_direction: direction,
          penguin_counter: counter
        )

      _ ->
        socket
    end
  end

  defp third_step(socket) do
    if socket.assigns.penguin_counter >= 3, do: 0, else: socket.assigns.penguin_counter + 1
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

  defp whale_step(socket, step) do
    old_position = {socket.assigns.penguin_x, socket.assigns.penguin_y}
    {{x, y} = coordinates, direction} = get_new_whale_position(socket, step)

    case Map.get(socket.assigns.board, coordinates) do
      res when res in [:whale, :eatpenguin] ->
        socket

      _ ->
        counter = eight_step(socket)
        board = eat_penguin(socket, counter, coordinates)

        assign(socket,
          board: board,
          whale_x: x,
          whale_y: y,
          whale_direction: direction,
          whale_counter: counter
        )
    end
  end

  defp eight_step(socket) do
    if socket.assigns.whale_counter >= 8, do: 0, else: socket.assigns.whale_counter + 1
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

  defp get_new_whale_position(socket, %{"key" => step} = keys) do
    {x_old, y_old} = {socket.assigns.whale_x, socket.assigns.whale_y}
    old_direction = socket.assigns.whale_direction

    {{x, y}, direction} =
      case step do
        "ArrowLeft" -> {{x_old - 1, y_old}, :whaleleft}
        "ArrowRight" -> {{x_old + 1, y_old}, :whaleright}
        "ArrowUp" -> {{x_old, y_old - 1}, :whaleup}
        "ArrowDown" -> {{x_old, y_old + 1}, :whaledown}
        _ -> {{x_old, y_old}, old_direction}
      end

    {x, y} =
      if x in 1..@default_width and y in 1..@default_height do
        {x, y}
      else
        {x_old, y_old}
      end

    {{x, y}, direction}
  end

  defp get_new_position(socket, %{"key" => step} = keys) do
    {x_old, y_old} = {socket.assigns.penguin_x, socket.assigns.penguin_y}
    old_direction = socket.assigns.penguin_direction

    {{x, y}, direction} =
      case step do
        "ArrowLeft" -> {{x_old - 1, y_old}, :penguinleft}
        "ArrowRight" -> {{x_old + 1, y_old}, :penguinright}
        "ArrowUp" -> {{x_old, y_old - 1}, :penguinup}
        "ArrowDown" -> {{x_old, y_old + 1}, :penguindown}
        _ -> {{x_old, y_old}, old_direction}
      end

    {x, y} =
      if x in 1..@default_width and y in 1..@default_height do
        {x, y}
      else
        {x_old, y_old}
      end

    {{x, y}, direction}
  end
end
