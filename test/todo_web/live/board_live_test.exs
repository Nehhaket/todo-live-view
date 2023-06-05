defmodule TodoWeb.BoardLiveTest do
  use TodoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Todo.TasksFixtures

  defp create_board(%{user: user}) do
    board = board_fixture(%{user_id: user.id})
    %{board: board}
  end


  describe "Index" do
    setup [:register_and_log_in_user, :create_board]

    test "lists all task_boards", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/task_boards")

      assert html =~ "Listing Task boards"
    end

    test "deletes board in listing", %{conn: conn, board: board} do
      {:ok, index_live, _html} = live(conn, ~p"/task_boards")

      assert index_live |> element("#task_boards-#{board.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#task_boards-#{board.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_board]

    test "displays board", %{conn: conn, board: board} do
      {:ok, _show_live, html} = live(conn, ~p"/task_boards/#{board}")

      assert html =~ "Show Board"
    end
  end
end
