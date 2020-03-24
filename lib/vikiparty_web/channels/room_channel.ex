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

  def handle_in("new_msg", %{"body" => body, "username" => username, "is_cmd" => is_cmd}, socket) do
    broadcast! socket, "new_msg", %{body: body, username: username, is_cmd: is_cmd, timestamp: :os.system_time(:millisecond)}
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second))
    })
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    broadcast socket, "new_msg", %{body: "Someone has left", timestamp: :os.system_time(:millisecond)}
    :ok
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
