defmodule TodoWeb.BoardLive.Index do
  use TodoWeb, :live_view

  alias Todo.Tasks
  alias Todo.Tasks.Board

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    if connected?(socket) do
      Tasks.subscribe_to_boards_changes(user_id)
    end

    {:ok, stream(socket, :task_boards, Tasks.list_task_boards_for_user(user_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    with %Board{} = board <- Tasks.get_board_for_user(id, socket.assigns.current_user.id) do
      socket
      |> assign(:page_title, "Edit Board")
      |> assign(:board, board)
    else
      _ -> push_navigate(socket, to: ~p"/task_boards", replace: true)
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Board")
    |> assign(:board, %Board{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Task boards")
    |> assign(:board, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with %Board{} = board <- Tasks.get_board_for_user(id, socket.assigns.current_user.id) do
      {:ok, _} = Tasks.delete_board(board)
      Tasks.broadcast_board_delete(board)

      {:noreply, socket}
    else
      _ -> push_navigate(socket, to: ~p"/task_boards", replace: true)
    end
  end

  @impl true
  def handle_info({:board_change, board}, socket) do
    {:noreply, stream_insert(socket, :task_boards, board)}
  end

  @impl true
  def handle_info({:board_delete, board}, socket) do
    {:noreply, stream_delete(socket, :task_boards, board)}
  end
end
