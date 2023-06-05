defmodule Todo.Repo.Migrations.AddBoardTodos do
  use Ecto.Migration

  def change do
    create table(:board_todos) do
      add :title, :string, null: false
      add :completed, :boolean, null: false, default: false
      add :board_id, references(:task_boards, on_delete: :delete_all)

      timestamps()
    end

    create index(:board_todos, [:board_id])
  end
end
