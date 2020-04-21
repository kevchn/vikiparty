defmodule VikipartyWeb.RoomChannel do
  use VikipartyWeb, :channel
  alias VikipartyWeb.Presence

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Send messages to everyone in room with user id and timestamp
  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body,
                                    username: socket.assigns.username,
                                    user_id: socket.assigns.user_id,
                                    timestamp: :os.system_time(:millisecond)}
    {:noreply, socket}
  end

  def handle_in("set_username", %{"username" => username}, socket) do
    socket = assign(socket, :username, username)
    broadcast! socket, "new_msg", %{body: "joined",
                                    username: socket.assigns.username,
                                    user_id: socket.assigns.user_id,
                                    timestamp: :os.system_time(:millisecond),
                                    is_announcement: true}
    {:noreply, socket}
  end

  def handle_in("change_username", %{"username" => username}, socket) do
    broadcast! socket, "new_msg", %{body: "changed username to " <> username,
                                    username: socket.assigns.username,
                                    user_id: socket.assigns.user_id,
                                    timestamp: :os.system_time(:millisecond),
                                    is_announcement: true}
    socket = assign(socket, :username, username)
    {:noreply, socket}
  end

  # After joining, set up user session's username and presence information
  def handle_info(:after_join, socket) do
    socket = assign(socket, :username, "Anonymous")
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
    })
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    broadcast socket, "new_msg", %{body: "left",
                                   username: socket.assigns.username,
                                   timestamp: :os.system_time(:millisecond),
                                   is_announcement: true}
    :ok
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

end
