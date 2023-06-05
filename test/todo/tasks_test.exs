defmodule Todo.TasksTest do
  use Todo.DataCase

  alias Todo.Tasks

  describe "task_boards" do
    alias Todo.Tasks.Board

    import Todo.TasksFixtures

    @invalid_attrs %{title: nil}

    test "list_task_boards_for_user/1 returns all task_boards for given user_id" do
      board = board_fixture()
      assert Tasks.list_task_boards_for_user(board.user_id) == [board]
    end

    test "get_board!/1 returns the board with given id" do
      board = board_fixture()
      assert Tasks.get_board!(board.id) == board
    end

    test "create_board/1 with valid data creates a board" do
      user_id = Todo.AccountsFixtures.user_fixture().id()
      title = :rand.uniform(100) |> Integer.to_string()
      valid_attrs = %{user_id: user_id, title: title}

      assert {:ok, %Board{user_id: ^user_id, title: ^title}} = Tasks.create_board(valid_attrs)
    end

    test "create_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_board(@invalid_attrs)
    end

    test "update_board/2 with valid data updates the board" do
      board = board_fixture()
      title = :rand.uniform(100) |> Integer.to_string()
      update_attrs = %{title: title}

      assert {:ok, %Board{title: ^title}} = Tasks.update_board(board, update_attrs)
    end

    test "update_board/2 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_board(board, @invalid_attrs)
      assert board == Tasks.get_board!(board.id)
    end

    test "delete_board/1 deletes the board" do
      board = board_fixture()
      assert {:ok, %Board{}} = Tasks.delete_board(board)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_board!(board.id) end
    end

    test "change_board/1 returns a board changeset" do
      board = board_fixture()
      assert %Ecto.Changeset{} = Tasks.change_board(board)
    end
  end
end
