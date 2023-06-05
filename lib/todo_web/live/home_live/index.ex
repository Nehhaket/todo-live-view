defmodule TodoWeb.HomeLive.Index do
  use TodoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/users/log_in", replace: true)}
  end
end
