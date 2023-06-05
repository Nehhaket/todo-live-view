defmodule TodoWeb.BoardLive.Show do
  use TodoWeb, :live_view

  alias Todo.Tasks
  alias Todo.Tasks.Board

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    with %Board{} = board <- Tasks.get_board_for_user(id, socket.assigns.current_user.id) do
      {:noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:board, board)}
    else
      _ ->
        {:noreply,
        socket
        |> put_flash(:error, "Board not found")
        |> push_patch(to: ~p"/task_boards", replace: true)}
    end
  end

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"
end
