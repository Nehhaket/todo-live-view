defmodule TodoWeb.BoardLive.FormComponent do
  use TodoWeb, :live_component

  alias Todo.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage board records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="board-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} label="Title" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Board</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{board: board} = assigns, socket) do
    changeset = Tasks.change_board(board)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"board" => board_params}, socket) do
    changeset =
      socket.assigns.board
      |> Tasks.change_board(board_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"board" => board_params}, socket) do
    save_board(socket, socket.assigns.action, board_params)
  end

  defp save_board(socket, :edit, board_params) do
    board_params = Map.put(board_params, "user_id", socket.assigns.current_user.id)

    socket.assigns.board
    |> Tasks.update_board(board_params)
    |> IO.inspect(label: :new_result)
    |> case do
      {:ok, board} ->
        notify_parent({:saved, board})

        {:noreply,
         socket
         |> put_flash(:info, "Board updated successfully")
         |> push_patch(to: socket.assigns.patch, replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_board(socket, :new, board_params) do
    board_params
    |> Map.put("user_id", socket.assigns.current_user.id)
    |> Tasks.create_board()
    |> IO.inspect(label: :new_result)
    |> case do
      {:ok, board} ->
        notify_parent({:saved, board})

        {:noreply,
         socket
         |> put_flash(:info, "Board created successfully")
         |> push_patch(to: socket.assigns.patch, replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
