defmodule Todo.Tasks.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "board_todos" do
    field :title, :string
    field :completed, :boolean, default: true
    belongs_to :board, Todo.Tasks.Board

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :board_id, :completed])
    |> validate_required([:title, :board_id])
  end
end
