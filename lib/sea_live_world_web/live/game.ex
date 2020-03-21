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

  def handle_event("player", key, socket) do
    if socket.assigns.gameplay? do
      {:noreply, step(socket, key)}
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
      direction: :penguindown,
      penguin_x: 1,
      penguin_y: 1
    )
  end

  @default_width 15
  @default_height 10
  def board() do
    for x <- 1..@default_width, y <- 1..@default_height, into: %{} do
      [random] = Enum.take_random(Enum.to_list(0..1), 1)
      type = field_type(random)
      {{x, y}, type}
    end
  end

  defp field_type(random) do
    case random do
      1 -> :occupied
      _ -> :free
    end
  end

  defp step(socket, step) do
    old_position = {socket.assigns.penguin_x, socket.assigns.penguin_y}

    {{x, y}, direction} = get_new_position(socket, step)

    new_score = Map.get(socket.assigns.board, {x, y})

    assign(socket,
      board: Map.put(socket.assigns.board, old_position, :free),
      penguin_x: x,
      penguin_y: y,
      direction: direction
    )
  end

  defp get_new_position(socket, %{"key" => step} = keys) do
    {x_old, y_old} = {socket.assigns.penguin_x, socket.assigns.penguin_y}
    old_direction = socket.assigns.direction

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
