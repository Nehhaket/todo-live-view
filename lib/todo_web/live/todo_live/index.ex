defmodule TodoWeb.TodoLive.Index do
  use TodoWeb, :live_view

  alias Todo.Tasks
  alias Todo.Tasks.Board
  alias Todo.Tasks.Todo, as: BoardTodo

  @impl true
  def mount(%{"board_id" => board_id}, _session, socket) do
    with %Board{} = board <- Tasks.get_board_for_user(board_id, socket.assigns.current_user.id) do
      if connected?(socket) do
        Tasks.subscribe_to_todos_changes(board.id)
      end

      {:ok,
       socket
       |> assign(:board_id, board.id)
       |> assign(:board_title, board.title)
       |> stream(
         :board_todos,
         Tasks.list_board_todos_for_user(board.id, socket.assigns.current_user.id)
       )}
    else
      _ -> {:ok, push_navigate(socket, to: ~p"/task_boards", replace: true)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"todo_id" => todo_id}) do
    with %BoardTodo{} = todo <-
           Tasks.get_board_todo_for_user(todo_id, socket.assigns.current_user.id) do
      socket
      |> assign(:page_title, "Edit todo")
      |> assign(:todo, todo)
    else
      _ -> push_navigate(socket, to: ~p"/task_boards", replace: true)
    end
  end

  defp apply_action(socket, :new, %{"board_id" => board_id}) do
    with %Board{} <- Tasks.get_board_for_user(board_id, socket.assigns.current_user.id) do
      socket
      |> assign(:page_title, "New todo")
      |> assign(:todo, %BoardTodo{completed: false, board_id: board_id})
    else
      _ -> push_navigate(socket, to: ~p"/board_todos/#{board_id}", replace: true)
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing board todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_event("delete", %{"todo_id" => todo_id}, socket) do
    with %BoardTodo{} = todo <-
           Tasks.get_board_todo_for_user(todo_id, socket.assigns.current_user.id) do
      {:ok, _} = Tasks.delete_board_todo(todo)
      Tasks.broadcast_todo_delete(todo)

      {:noreply, socket}
    else
      _ -> push_navigate(socket, to: ~p"/task_boards", replace: true)
    end
  end

  @impl true
  def handle_event("toggle", %{"todo_id" => todo_id}, socket) do
    with %BoardTodo{} = todo <-
           Tasks.get_board_todo_for_user(todo_id, socket.assigns.current_user.id) do
      {:ok, _} = Tasks.update_board_todo(todo, %{completed: not todo.completed})
      Tasks.broadcast_todo_change(todo)

      {:noreply, socket}
    else
      _ -> push_navigate(socket, to: ~p"/task_boards", replace: true)
    end
  end

  @impl true
  def handle_info({:todo_change, todo}, socket) do
    {:noreply, stream_insert(socket, :board_todos, todo)}
  end

  @impl true
  def handle_info({:todo_delete, todo}, socket) do
    {:noreply, stream_delete(socket, :board_todos, todo)}
  end
end
