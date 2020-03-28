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

  def handle_in("new_msg", payload, socket) do
    broadcast! socket, "new_msg", payload
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
    if not Map.has_key?(socket.assigns, :username) do
      assign(socket, "username", generateRandomUsername())
    end
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      username: socket.assigns.username
    })
    {:noreply, socket}
  end

  def generateRandomUsername do
    # Google's "Anonymous Animals" has only 73 animals. They don't care about
    # 74+ person chat rooms because it is so rare.

    # Suppose we generate usernames of the form: CVCVC, where C = consonant, V
    # = vowel. The cardinality of the result set is 21*5*21*5*21 = 231525.
    # Suppose we have a 73 person chat room, where each person retrieves a
    # random name from this set. The probability of no collisions is ~98.9%.
    # For a 10 person chat room, this probability becomes ~99.98%.

    # See calculation and result at:
    # https://www.wolframalpha.com/input/?i=231525%21+%2F+%28231525-73%29%21%29%2F%28231525%5E73%29

    consonants = 'bcdfghjklmnpqrstvwxyz'
    vowels = 'aeiou'
    sampledChars = []
    sampledChars = [Enum.at(consonants, Enum.random(0..(length consonants)-1)) | sampledChars]
    sampledChars = [Enum.at(vowels, Enum.random(0..(length vowels)-1)) | sampledChars]
    sampledChars = [Enum.at(consonants, Enum.random(0..(length consonants)-1)) | sampledChars]
    sampledChars = [Enum.at(vowels, Enum.random(0..(length vowels)-1)) | sampledChars]
    sampledChars = [Enum.at(consonants, Enum.random(0..(length consonants)-1)) | sampledChars]
    List.to_string(sampledChars)
  end

  def terminate(_reason, socket) do
    broadcast socket, "new_msg", %{body: "#{socket.assigns.username} has left",
                                   timestamp: :os.system_time(:millisecond),
                                   is_announcement: true}
    :ok
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

end
