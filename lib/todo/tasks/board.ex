defmodule Todo.Tasks.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_boards" do
    field :title, :string
    belongs_to :user, Todo.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
