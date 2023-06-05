defmodule Todo.Repo.Migrations.CreateTaskBoards do
  use Ecto.Migration

  def change do
    create table(:task_boards) do
      add :title, :string, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:task_boards, [:user_id])
  end
end
