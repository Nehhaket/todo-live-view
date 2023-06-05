defmodule Todo.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todo.Tasks` context.
  """

  @doc """
  Generate a board.
  """
  def board_fixture(attrs \\ %{}) do
    {:ok, board} =
      attrs
      |> Enum.into(%{
        title: "fixture title"
      })
      |> then(fn attrs ->
        if is_nil(Map.get(attrs, :user_id)) do
          Map.put(attrs, :user_id, Todo.AccountsFixtures.user_fixture().id)
        else
          attrs
        end
      end)
      |> Todo.Tasks.create_board()

    board
  end
end
