defmodule Todo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Todo.Repo

  alias Todo.Tasks.Board
  alias Todo.Tasks.Todo, as: BoardTodo

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.
  Only for use in non-user-facing code.

  ## Examples

      iex> get_board!(123)
      %Board{}

      iex> get_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id), do: Repo.get!(Board, id)

  @doc """
  Returns the list of task_boards for given user.

  ## Examples

      iex> list_task_boards_for_user(user_id)
      [%Board{}, ...]

  """
  def list_task_boards_for_user(user_id) do
    Board
    |> where([b], b.user_id == ^user_id)
    |> order_by(:inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single board for user.

  ## Examples

      iex> get_board_for_user(board_owner_id)
      %Board{}

      iex> get_board_for_user(not_owner_id)
      nil

  """
  def get_board_for_user(board_id, user_id) do
    Board
    |> where([b], b.id == ^board_id and b.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end

  @doc """
  Returns the list of todos in a given task board.

  ## Examples

      iex> list_board_todos_for_user(board_id, user_id)
      [%Todo{}, ...]

  """
  def list_board_todos_for_user(board_id, user_id) do
    BoardTodo
    |> join(:left, [t], b in assoc(t, :board))
    |> where([t, b], b.user_id == ^user_id and t.board_id == ^board_id)
    |> order_by(:inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single board todo for user.

  ## Examples

      iex> get_board_todo_for_user(board_owner_id)
      %Todo{}

      iex> get_board_todo_for_user(not_owner_id)
      nil

  """
  def get_board_todo_for_user(todo_id, user_id) do
    BoardTodo
    |> join(:left, [t], b in assoc(t, :board))
    |> where([t, b], t.id == ^todo_id and b.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Creates a todo.

  ## Examples

      iex> create_board_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_board_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board_todo(attrs \\ %{}) do
    %BoardTodo{}
    |> BoardTodo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board_todo(%BoardTodo{} = todo, attrs) do
    todo
    |> BoardTodo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board_todo(%BoardTodo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board_todo(%BoardTodo{} = todo, attrs \\ %{}) do
    BoardTodo.changeset(todo, attrs)
  end

  def subscribe_to_boards_changes(user_id) do
    Phoenix.PubSub.subscribe(Todo.PubSub, "boards:#{user_id}")
  end

  def broadcast_board_change(%Board{} = board) do
    Phoenix.PubSub.broadcast!(Todo.PubSub, "boards:#{board.user_id}", {:board_change, board})
  end

  def broadcast_board_delete(%Board{} = board) do
    Phoenix.PubSub.broadcast!(Todo.PubSub, "boards:#{board.user_id}", {:board_delete, board})
  end

  def subscribe_to_todos_changes(board_id) do
    Phoenix.PubSub.subscribe(Todo.PubSub, "todos:#{board_id}")
  end

  def broadcast_todo_change(%BoardTodo{} = todo) do
    Phoenix.PubSub.broadcast!(Todo.PubSub, "todos:#{todo.board_id}", {:todo_change, todo})
  end

  def broadcast_todo_delete(%BoardTodo{} = todo) do
    Phoenix.PubSub.broadcast!(Todo.PubSub, "todos:#{todo.board_id}", {:todo_delete, todo})
  end
end
